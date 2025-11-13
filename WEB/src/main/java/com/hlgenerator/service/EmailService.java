package com.hlgenerator.service;

import com.hlgenerator.dao.EmailNotificationDAO;
import com.hlgenerator.dao.UserDAO;
import com.hlgenerator.model.EmailNotification;
import com.hlgenerator.model.User;
import org.json.JSONArray;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import java.io.File;
import java.io.InputStream;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.Executors;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EmailService {
    private static final Logger logger = Logger.getLogger(EmailService.class.getName());
    private static final int MAX_CONCURRENT_EMAILS = 10; // Số email gửi đồng thời tối đa
    private static final ExecutorService emailExecutor = Executors.newFixedThreadPool(MAX_CONCURRENT_EMAILS);
    
    private Properties mailProperties;
    private String smtpHost;
    private int smtpPort;
    private String smtpUsername;
    private String smtpPassword;
    
    public EmailService() {
        loadMailProperties();
    }
    
    private void loadMailProperties() {
        try {
            InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties");
            Properties props = new Properties();
            if (input != null) {
                props.load(input);
                smtpHost = props.getProperty("mail.smtp.host", "smtp.gmail.com");
                smtpPort = Integer.parseInt(props.getProperty("mail.smtp.port", "587"));
                smtpUsername = props.getProperty("mail.smtp.username");
                smtpPassword = props.getProperty("mail.smtp.password");
                
                mailProperties = new Properties();
                mailProperties.put("mail.smtp.host", smtpHost);
                mailProperties.put("mail.smtp.port", String.valueOf(smtpPort));
                mailProperties.put("mail.smtp.auth", props.getProperty("mail.smtp.auth", "true"));
                mailProperties.put("mail.smtp.starttls.enable", props.getProperty("mail.smtp.starttls.enable", "true"));
                mailProperties.put("mail.mime.charset", props.getProperty("mail.mime.charset", "UTF-8"));
                mailProperties.put("mail.smtp.connectiontimeout", props.getProperty("mail.smtp.connectiontimeout", "10000"));
                mailProperties.put("mail.smtp.timeout", props.getProperty("mail.smtp.timeout", "10000"));
                mailProperties.put("mail.smtp.writetimeout", props.getProperty("mail.smtp.writetimeout", "10000"));
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error loading mail properties", e);
            // Set defaults
            mailProperties = new Properties();
            mailProperties.put("mail.smtp.host", "smtp.gmail.com");
            mailProperties.put("mail.smtp.port", "587");
            mailProperties.put("mail.smtp.auth", "true");
            mailProperties.put("mail.smtp.starttls.enable", "true");
            mailProperties.put("mail.mime.charset", "UTF-8");
        }
    }
    
    /**
     * Save email notification and return immediately (for background processing)
     */
    public boolean saveEmailNotification(EmailNotification notification) {
        EmailNotificationDAO emailDAO = new EmailNotificationDAO();
        
        // Save the notification record with pending status
        notification.setStatus("pending");
        if (!emailDAO.addEmailNotification(notification)) {
            logger.severe("Failed to save email notification record");
            return false;
        }
        
        return true;
    }
    
    /**
     * Send email in background thread (doesn't block)
     */
    public void sendEmailInBackground(final int notificationId) {
        Thread emailThread = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    sendEmailNotification(notificationId);
                } catch (Exception e) {
                    logger.log(Level.SEVERE, "Error sending email in background: " + notificationId, e);
                }
            }
        });
        emailThread.setDaemon(true);
        emailThread.start();
    }
    
    /**
     * Send email to multiple recipients based on roles or email addresses
     * Optimized: sends emails in parallel and updates DB immediately after each email
     * This method is called in background thread
     */
    void sendEmailNotification(int notificationId) {
        EmailNotificationDAO emailDAO = new EmailNotificationDAO();
        EmailNotification notification = emailDAO.getEmailNotificationById(notificationId);
        
        if (notification == null) {
            logger.severe("Email notification not found: " + notificationId);
            return;
        }
        
        // Update status to sending
        emailDAO.updateStatus(notificationId, "sending");
        emailDAO.setSentAt(notificationId);
        
        // Get recipient emails
        List<String> recipientEmails = getRecipientEmails(notification);
        
        if (recipientEmails.isEmpty()) {
            logger.warning("No recipient emails found for notification: " + notificationId);
            emailDAO.updateSendingResults(notificationId, 0, 0, "[]", "failed", 
                                        "Không tìm thấy địa chỉ email người nhận");
            return;
        }
        
        // Limit maximum recipients (prevent spam)
        if (recipientEmails.size() > 5000) {
            logger.warning("Recipient count exceeds limit (5000) for notification: " + notificationId);
            emailDAO.updateSendingResults(notificationId, 0, 0, "[]", "failed", 
                                        "Số lượng người nhận vượt quá giới hạn (tối đa 5000 người)");
            return;
        }
        
        // Update recipient count
        notification.setRecipientCount(recipientEmails.size());
        notification.setRecipientEmails(new JSONArray(recipientEmails).toString());
        emailDAO.updateEmailNotification(notification);
        
        // Create mail session (reusable for all emails)
        final Session session = createMailSession();
        final EmailNotification finalNotification = notification;
        
        // Use atomic counters for thread-safe counting
        final AtomicInteger successCount = new AtomicInteger(0);
        final AtomicInteger failedCount = new AtomicInteger(0);
        final AtomicInteger completedCount = new AtomicInteger(0);
        final int totalEmails = recipientEmails.size();
        final AtomicInteger finalStatusSet = new AtomicInteger(0); // To prevent race condition
        
        // Create CountDownLatch to wait for all emails to complete
        final CountDownLatch latch = new CountDownLatch(totalEmails);
        
        // Send emails in parallel using thread pool
        for (final String email : recipientEmails) {
            emailExecutor.submit(new Runnable() {
                @Override
                public void run() {
                    // Create new DAO instance for each thread (thread-safe)
                    EmailNotificationDAO threadEmailDAO = new EmailNotificationDAO();
                    boolean success = false;
                    Exception lastException = null;
                    
                    // Try sending with retry (max 2 attempts)
                    for (int attempt = 1; attempt <= 2; attempt++) {
                        try {
                            // Create and send email
                            MimeMessage message = createMessage(session, finalNotification, email);
                            
                            // Send with timeout (30 seconds per email)
                            ExecutorService timeoutExecutor = Executors.newSingleThreadExecutor();
                            try {
                                Future<Void> sendFuture = timeoutExecutor.submit(new Callable<Void>() {
                                    @Override
                                    public Void call() throws Exception {
                                        Transport.send(message);
                                        return null;
                                    }
                                });
                                
                                try {
                                    sendFuture.get(30, TimeUnit.SECONDS);
                                    success = true;
                                    break; // Success, exit retry loop
                                } catch (TimeoutException e) {
                                    sendFuture.cancel(true);
                                    throw new Exception("Email sending timeout for: " + email, e);
                                } finally {
                                    timeoutExecutor.shutdown();
                                }
                            } catch (Exception e) {
                                timeoutExecutor.shutdownNow();
                                throw e;
                            }
                        } catch (Exception e) {
                            lastException = e;
                            if (attempt < 2) {
                                logger.log(Level.WARNING, "Failed to send email to: " + email + " (attempt " + attempt + "), retrying...", e);
                                // Wait 2 seconds before retry
                                try {
                                    Thread.sleep(2000);
                                } catch (InterruptedException ie) {
                                    Thread.currentThread().interrupt();
                                    break;
                                }
                            } else {
                                logger.log(Level.WARNING, "Failed to send email to: " + email + " (after " + attempt + " attempts)", e);
                            }
                        }
                    }
                    
                    // Update DB based on result
                    if (success) {
                        threadEmailDAO.updateSingleEmailResult(notificationId, true, email);
                        successCount.incrementAndGet();
                        logger.info("Email sent successfully to: " + email);
                    } else {
                        threadEmailDAO.updateSingleEmailResult(notificationId, false, email);
                        failedCount.incrementAndGet();
                        logger.log(Level.WARNING, "Failed to send email to: " + email + " after retries", lastException);
                    }
                    
                    // Count down latch
                    latch.countDown();
                    int completed = completedCount.incrementAndGet();
                    
                    // When all emails are sent, mark notification with appropriate status
                    // Use atomic operation to ensure only one thread sets the final status
                    if (completed == totalEmails && finalStatusSet.compareAndSet(0, 1)) {
                        int successCountValue = successCount.get();
                        int failedCountValue = failedCount.get();
                        
                        String finalStatus;
                        if (failedCountValue == 0) {
                            finalStatus = "completed";
                        } else if (successCountValue == 0) {
                            finalStatus = "failed";
                        } else {
                            finalStatus = "partial";
                        }
                        
                        threadEmailDAO.markAsCompleted(notificationId, finalStatus);
                        logger.info("All emails processed for notification: " + notificationId + 
                                  " (Success: " + successCountValue + ", Failed: " + failedCountValue + ", Status: " + finalStatus + ")");
                    }
                }
            });
        }
        
        // Wait for all emails to complete (with timeout)
        try {
            boolean finished = latch.await(30, TimeUnit.MINUTES); // Max 30 minutes timeout
            if (!finished) {
                logger.warning("Email sending timeout for notification: " + notificationId);
                // Mark as failed if timeout
                if (finalStatusSet.compareAndSet(0, 1)) {
                    emailDAO.updateStatus(notificationId, "failed");
                    emailDAO.updateSendingResults(notificationId, successCount.get(), failedCount.get() + (totalEmails - completedCount.get()), 
                                                 "[]", "failed", "Timeout: Không thể gửi tất cả email trong thời gian cho phép");
                }
            }
        } catch (InterruptedException e) {
            logger.log(Level.SEVERE, "Email sending interrupted for notification: " + notificationId, e);
            Thread.currentThread().interrupt();
            if (finalStatusSet.compareAndSet(0, 1)) {
                emailDAO.updateStatus(notificationId, "failed");
            }
        }
    }
    
    /**
     * Get recipient emails based on roles or direct email addresses
     * Logic:
     * - If marketing type AND has roles selected: send to roles + customers
     * - If marketing type AND only has personal emails (no roles): send ONLY to personal emails, NOT to customers
     * - If internal type: send to roles or personal emails as specified
     */
    private List<String> getRecipientEmails(EmailNotification notification) {
        List<String> emails = new ArrayList<>();
        Set<String> emailSet = new HashSet<>(); // To avoid duplicates
        boolean hasRoles = false;
        
        try {
            // Get emails from recipient_emails JSON if provided (personal emails)
            if (notification.getRecipientEmails() != null && !notification.getRecipientEmails().isEmpty()) {
                JSONArray emailArray = new JSONArray(notification.getRecipientEmails());
                for (int i = 0; i < emailArray.length(); i++) {
                    String email = emailArray.getString(i);
                    if (email != null && !email.trim().isEmpty()) {
                        emailSet.add(email.trim().toLowerCase());
                    }
                }
            }
            
            // Get emails from roles
            if (notification.getRecipientRoles() != null && !notification.getRecipientRoles().isEmpty()) {
                JSONArray roleArray = new JSONArray(notification.getRecipientRoles());
                // Check if roles array is not empty (not just "[]")
                if (roleArray.length() > 0) {
                    hasRoles = true;
                    UserDAO userDAO = new UserDAO();
                    
                    for (int i = 0; i < roleArray.length(); i++) {
                        String role = roleArray.getString(i);
                        if (role != null && !role.trim().isEmpty()) {
                            List<User> users = userDAO.getUsersByRole(role);
                            
                            for (User user : users) {
                                if (user.getEmail() != null && !user.getEmail().trim().isEmpty()) {
                                    emailSet.add(user.getEmail().trim().toLowerCase());
                                }
                            }
                        }
                    }
                }
            }
            
            // Only get customer emails if:
            // 1. Email type is marketing
            // 2. AND has roles selected (not just personal emails)
            // This means: if marketing but only personal emails (no roles), don't send to customers
            if ("marketing".equals(notification.getEmailType()) && hasRoles) {
                // Get customer emails from customers table
                emails.addAll(getCustomerEmails());
                logger.info("Marketing email with roles selected - including customer emails");
            } else if ("marketing".equals(notification.getEmailType()) && !hasRoles) {
                logger.info("Marketing email with only personal emails - NOT including customer emails");
            }
            
            emails.addAll(emailSet);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error getting recipient emails", e);
        }
        
        return emails;
    }
    
    /**
     * Get customer emails from database
     */
    private List<String> getCustomerEmails() {
        List<String> emails = new ArrayList<>();
        try {
            com.hlgenerator.dao.CustomerDAO customerDAO = new com.hlgenerator.dao.CustomerDAO();
            java.util.List<com.hlgenerator.model.Customer> customers = customerDAO.getAllCustomers();
            for (com.hlgenerator.model.Customer customer : customers) {
                if (customer.getEmail() != null && !customer.getEmail().trim().isEmpty() 
                    && "active".equals(customer.getStatus())) {
                    emails.add(customer.getEmail().trim().toLowerCase());
                }
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error getting customer emails", e);
        }
        return emails;
    }
    
    /**
     * Create mail session
     */
    private Session createMailSession() {
        return Session.getInstance(mailProperties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(smtpUsername, smtpPassword);
            }
        });
    }
    
    /**
     * Create MimeMessage with attachments support
     */
    private MimeMessage createMessage(Session session, EmailNotification notification, String recipientEmail) 
            throws Exception {
        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(smtpUsername, "HL Generator Solutions"));
        message.setRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
        message.setSubject(notification.getSubject(), "UTF-8");
        
        // Create multipart message
        MimeMultipart multipart = new MimeMultipart();
        
        // Add email content
        MimeBodyPart contentPart = new MimeBodyPart();
        String htmlContent = convertToHtml(notification.getContent());
        contentPart.setContent(htmlContent, "text/html; charset=UTF-8");
        multipart.addBodyPart(contentPart);
        
        // Add attachments if any
        if (notification.getAttachments() != null && !notification.getAttachments().isEmpty()) {
            try {
                JSONArray attachmentsArray = new JSONArray(notification.getAttachments());
                for (int i = 0; i < attachmentsArray.length(); i++) {
                    String relativePath = attachmentsArray.getString(i);
                    File file = null;
                    
                    // Try multiple path resolution strategies
                    // Strategy 1: Relative path from webapp (most common)
                    String webappPath = System.getProperty("catalina.base");
                    if (webappPath != null) {
                        // Try with /webapps/ROOT prefix
                        String absolutePath1 = webappPath + "/webapps/ROOT/" + relativePath;
                        file = new File(absolutePath1);
                        if (!file.exists()) {
                            // Try without ROOT (for exploded WAR)
                            String absolutePath2 = webappPath + "/webapps/" + relativePath;
                            file = new File(absolutePath2);
                        }
                    }
                    
                    // Strategy 2: If still not found, try as absolute path (backward compatibility)
                    if (file == null || !file.exists()) {
                        file = new File(relativePath);
                    }
                    
                    // Strategy 3: Try relative to current working directory
                    if (!file.exists()) {
                        file = new File(System.getProperty("user.dir") + "/" + relativePath);
                    }
                    
                    if (file.exists() && file.isFile()) {
                        MimeBodyPart attachmentPart = new MimeBodyPart();
                        attachmentPart.attachFile(file);
                        // Extract filename from path
                        String fileName = file.getName();
                        if (fileName == null || fileName.isEmpty()) {
                            fileName = relativePath.substring(relativePath.lastIndexOf('/') + 1);
                        }
                        attachmentPart.setFileName(fileName);
                        multipart.addBodyPart(attachmentPart);
                        logger.info("Attached file: " + fileName + " from path: " + relativePath);
                    } else {
                        logger.warning("Attachment file not found: " + relativePath);
                    }
                }
            } catch (Exception e) {
                logger.log(Level.WARNING, "Error processing attachments", e);
            }
        }
        
        // Set the multipart as message content
        message.setContent(multipart);
        
        return message;
    }
    
    /**
     * Convert plain text to HTML format
     */
    private String convertToHtml(String content) {
        if (content == null || content.isEmpty()) {
            return "<html><body></body></html>";
        }
        
        // If content already contains HTML tags, return as is
        if (content.contains("<html") || content.contains("<div") || content.contains("<p")) {
            return content;
        }
        
        // Otherwise, convert line breaks to <br> tags
        String html = content.replace("\n", "<br>");
        
        return "<html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>" +
               "<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>" +
               html +
               "</div>" +
               "<hr style='border: none; border-top: 1px solid #eee; margin: 20px 0;'>" +
               "<p style='font-size: 12px; color: #999; text-align: center;'>" +
               "Email này được gửi từ hệ thống HL Generator Solutions" +
               "</p>" +
               "</body></html>";
    }
    
    /**
     * Test email connection
     */
    public boolean testConnection() {
        try {
            Session session = createMailSession();
            Transport transport = session.getTransport("smtp");
            transport.connect(smtpHost, smtpPort, smtpUsername, smtpPassword);
            transport.close();
            return true;
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Email connection test failed", e);
            return false;
        }
    }
    
    /**
     * Send account credentials email to a new user
     * This method sends email directly without creating EmailNotification record
     * 
     * @param recipientEmail Email address of the recipient
     * @param username Username for the account
     * @param password Plain text password (will be shown in email)
     * @param fullName Full name of the user
     * @return true if email sent successfully, false otherwise
     */
    public boolean sendAccountCredentialsEmail(String recipientEmail, String username, String password, String fullName) {
        if (recipientEmail == null || recipientEmail.trim().isEmpty()) {
            logger.warning("Cannot send account credentials email: recipient email is empty");
            return false;
        }
        
        try {
            Session session = createMailSession();
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(smtpUsername, "HL Generator Solutions"));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
            message.setSubject("Thông tin tài khoản của bạn - HL Generator Solutions", "UTF-8");
            
            // Create HTML content for the email
            String htmlContent = buildAccountCredentialsEmailContent(username, password, fullName);
            
            MimeBodyPart contentPart = new MimeBodyPart();
            contentPart.setContent(htmlContent, "text/html; charset=UTF-8");
            
            MimeMultipart multipart = new MimeMultipart();
            multipart.addBodyPart(contentPart);
            message.setContent(multipart);
            
            // Send email with timeout
            ExecutorService timeoutExecutor = Executors.newSingleThreadExecutor();
            try {
                Future<Boolean> sendFuture = timeoutExecutor.submit(new Callable<Boolean>() {
                    @Override
                    public Boolean call() throws Exception {
                        Transport.send(message);
                        return true;
                    }
                });
                
                try {
                    sendFuture.get(30, TimeUnit.SECONDS);
                    logger.info("Account credentials email sent successfully to: " + recipientEmail);
                    return true;
                } catch (TimeoutException e) {
                    sendFuture.cancel(true);
                    logger.log(Level.WARNING, "Email sending timeout for: " + recipientEmail, e);
                    return false;
                } finally {
                    timeoutExecutor.shutdown();
                }
            } catch (Exception e) {
                timeoutExecutor.shutdownNow();
                throw e;
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error sending account credentials email to: " + recipientEmail, e);
            return false;
        }
    }
    
    /**
     * Build HTML content for account credentials email
     */
    private String buildAccountCredentialsEmailContent(String username, String password, String fullName) {
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html>");
        html.append("<html>");
        html.append("<head>");
        html.append("<meta charset='UTF-8'>");
        html.append("<style>");
        html.append("body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; background-color: #f4f4f4; margin: 0; padding: 0; }");
        html.append(".container { max-width: 600px; margin: 20px auto; background-color: #ffffff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }");
        html.append(".header { text-align: center; border-bottom: 3px solid #007bff; padding-bottom: 20px; margin-bottom: 30px; }");
        html.append(".header h1 { color: #007bff; margin: 0; }");
        html.append(".content { margin: 20px 0; }");
        html.append(".credentials-box { background-color: #f8f9fa; border: 2px solid #dee2e6; border-radius: 5px; padding: 20px; margin: 20px 0; }");
        html.append(".credential-item { margin: 15px 0; }");
        html.append(".credential-label { font-weight: bold; color: #495057; margin-bottom: 5px; }");
        html.append(".credential-value { font-size: 16px; color: #212529; background-color: #ffffff; padding: 10px; border-radius: 4px; border: 1px solid #ced4da; font-family: 'Courier New', monospace; }");
        html.append(".warning { background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 4px; }");
        html.append(".warning strong { color: #856404; }");
        html.append(".footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #dee2e6; text-align: center; color: #6c757d; font-size: 12px; }");
        html.append(".button { display: inline-block; padding: 12px 30px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 5px; margin: 20px 0; }");
        html.append("</style>");
        html.append("</head>");
        html.append("<body>");
        html.append("<div class='container'>");
        html.append("<div class='header'>");
        html.append("<h1>Chào mừng đến với HL Generator Solutions</h1>");
        html.append("</div>");
        html.append("<div class='content'>");
        html.append("<p>Xin chào <strong>").append(escapeHtml(fullName != null ? fullName : "")).append("</strong>,</p>");
        html.append("<p>Tài khoản của bạn đã được tạo thành công. Dưới đây là thông tin đăng nhập của bạn:</p>");
        html.append("<div class='credentials-box'>");
        html.append("<div class='credential-item'>");
        html.append("<div class='credential-label'>Tên đăng nhập:</div>");
        html.append("<div class='credential-value'>").append(escapeHtml(username)).append("</div>");
        html.append("</div>");
        html.append("<div class='credential-item'>");
        html.append("<div class='credential-label'>Mật khẩu:</div>");
        html.append("<div class='credential-value'>").append(escapeHtml(password)).append("</div>");
        html.append("</div>");
        html.append("</div>");
        html.append("<div class='warning'>");
        html.append("<strong>⚠️ Lưu ý quan trọng:</strong>");
        html.append("<ul style='margin: 10px 0; padding-left: 20px;'>");
        html.append("<li>Vui lòng đổi mật khẩu ngay sau khi đăng nhập lần đầu</li>");
        html.append("<li>Không chia sẻ thông tin đăng nhập với bất kỳ ai</li>");
        html.append("<li>Nếu bạn không yêu cầu tài khoản này, vui lòng liên hệ với quản trị viên</li>");
        html.append("</ul>");
        html.append("</div>");
        html.append("<p style='text-align: center;'>");
        html.append("<a href='http://localhost:8080/demo/login.jsp' class='button' style='color: #ffffff;'>Đăng nhập ngay</a>");
        html.append("</p>");
        html.append("</div>");
        html.append("<div class='footer'>");
        html.append("<p>Email này được gửi tự động từ hệ thống HL Generator Solutions</p>");
        html.append("<p>Vui lòng không trả lời email này</p>");
        html.append("</div>");
        html.append("</div>");
        html.append("</body>");
        html.append("</html>");
        
        return html.toString();
    }
    
    /**
     * Escape HTML special characters
     */
    private String escapeHtml(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#39;");
    }
}

