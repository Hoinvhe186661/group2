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
            emailDAO.updateSendingResults(notificationId, 0, 0, "[]", "completed", 
                                        "Không tìm thấy địa chỉ email người nhận");
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
        
        // Create CountDownLatch to wait for all emails to complete
        final CountDownLatch latch = new CountDownLatch(totalEmails);
        
        // Send emails in parallel using thread pool
        for (final String email : recipientEmails) {
            emailExecutor.submit(new Runnable() {
                @Override
                public void run() {
                    // Create new DAO instance for each thread (thread-safe)
                    EmailNotificationDAO threadEmailDAO = new EmailNotificationDAO();
                    try {
                        // Create and send email
                        MimeMessage message = createMessage(session, finalNotification, email);
                        Transport.send(message);
                        
                        // Update DB immediately - success
                        threadEmailDAO.updateSingleEmailResult(notificationId, true, email);
                        successCount.incrementAndGet();
                        logger.info("Email sent successfully to: " + email);
                    } catch (Exception e) {
                        // Update DB immediately - failure
                        threadEmailDAO.updateSingleEmailResult(notificationId, false, email);
                        failedCount.incrementAndGet();
                        logger.log(Level.WARNING, "Failed to send email to: " + email, e);
                    } finally {
                        // Count down latch and check if all emails are done
                        latch.countDown();
                        int completed = completedCount.incrementAndGet();
                        
                        // When all emails are sent, mark notification as completed
                        // Only the last thread should mark as completed
                        if (completed == totalEmails) {
                            threadEmailDAO.markAsCompleted(notificationId);
                            logger.info("All emails processed for notification: " + notificationId + 
                                      " (Success: " + successCount.get() + ", Failed: " + failedCount.get() + ")");
                        }
                    }
                }
            });
        }
        
        // Wait for all emails to complete (with timeout)
        try {
            boolean finished = latch.await(30, TimeUnit.MINUTES); // Max 30 minutes timeout
            if (!finished) {
                logger.warning("Email sending timeout for notification: " + notificationId);
            }
        } catch (InterruptedException e) {
            logger.log(Level.SEVERE, "Email sending interrupted for notification: " + notificationId, e);
            Thread.currentThread().interrupt();
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
                    String filePath = attachmentsArray.getString(i);
                    File file = new File(filePath);
                    
                    if (file.exists() && file.isFile()) {
                        MimeBodyPart attachmentPart = new MimeBodyPart();
                        attachmentPart.attachFile(file);
                        attachmentPart.setFileName(file.getName());
                        multipart.addBodyPart(attachmentPart);
                        logger.info("Attached file: " + file.getName());
                    } else {
                        logger.warning("Attachment file not found: " + filePath);
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
}

