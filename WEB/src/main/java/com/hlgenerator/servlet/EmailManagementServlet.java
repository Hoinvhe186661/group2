package com.hlgenerator.servlet;

import com.hlgenerator.dao.EmailNotificationDAO;
import com.hlgenerator.dao.UserDAO;
import com.hlgenerator.model.EmailNotification;
import com.hlgenerator.model.User;
import com.hlgenerator.service.EmailService;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

@WebServlet("/email-management")
@MultipartConfig(
    maxFileSize = 10485760,      // 10MB per file
    maxRequestSize = 52428800,   // 50MB total
    fileSizeThreshold = 1048576  // 1MB
)
public class EmailManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private EmailNotificationDAO emailDAO;
    private EmailService emailService;

    @Override
    public void init() throws ServletException {
        super.init();
        emailDAO = new EmailNotificationDAO();
        emailService = new EmailService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("isLoggedIn") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String username = (String) session.getAttribute("username");
        String userRole = (String) session.getAttribute("userRole");
        
        // Only admin can access
        if (!"admin".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/admin.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("view".equals(action)) {
            viewEmailNotification(request, response);
        } else if ("create".equals(action)) {
            showCreatePage(request, response);
        } else if ("getUsersByRoles".equals(action)) {
            getUsersByRoles(request, response);
        } else if ("testConnection".equals(action)) {
            testEmailConnection(request, response);
        } else {
            // Default: show list page
            showEmailListPage(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("isLoggedIn") == null) {
            sendJsonResponse(response, false, "Phiên đăng nhập đã hết hạn", null);
            return;
        }
        
        String userRole = (String) session.getAttribute("userRole");
        if (!"admin".equals(userRole)) {
            sendJsonResponse(response, false, "Không có quyền truy cập", null);
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("send".equals(action)) {
            sendEmail(request, response);
        } else if ("filter".equals(action)) {
            filterEmails(request, response);
        } else if ("delete".equals(action)) {
            deleteEmail(request, response);
        } else {
            sendJsonResponse(response, false, "Action không hợp lệ", null);
        }
    }

    private void showEmailListPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            // Get filter parameters
            String emailType = request.getParameter("emailType");
            String status = request.getParameter("status");
            String searchTerm = request.getParameter("search");
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            
            // Get filtered emails
            List<EmailNotification> emails = emailDAO.getEmailNotificationsWithFilters(
                emailType, status, searchTerm, startDate, endDate
            );
            
            request.setAttribute("emails", emails);
            request.setAttribute("filterEmailType", emailType != null ? emailType : "");
            request.setAttribute("filterStatus", status != null ? status : "");
            request.setAttribute("filterSearch", searchTerm != null ? searchTerm : "");
            request.setAttribute("filterStartDate", startDate != null ? startDate : "");
            request.setAttribute("filterEndDate", endDate != null ? endDate : "");
            
            request.getRequestDispatcher("/email_management.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error loading email list page", e);
        }
    }

    private void showCreatePage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            request.getRequestDispatcher("/email_management.jsp?action=create").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error loading create page", e);
        }
    }

    private void viewEmailNotification(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/email-management");
                return;
            }
            
            int id = Integer.parseInt(idParam);
            EmailNotification email = emailDAO.getEmailNotificationById(id);
            
            if (email == null) {
                response.sendRedirect(request.getContextPath() + "/email-management");
                return;
            }
            
            request.setAttribute("email", email);
            request.getRequestDispatcher("/email_management.jsp?action=view").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/email-management");
        }
    }

    private void sendEmail(HttpServletRequest request, HttpServletResponse response) 
            throws IOException, ServletException {
        try {
            HttpSession session = request.getSession(false);
            String username = (String) session.getAttribute("username");
            Integer userId = (Integer) session.getAttribute("userId");
            
            String subject = request.getParameter("subject");
            String content = request.getParameter("content");
            String emailType = request.getParameter("emailType");
            String[] selectedRoles = request.getParameterValues("roles");
            String customEmails = request.getParameter("customEmails");
            
            // Handle file uploads
            JSONArray attachmentsArray = new JSONArray();
            Collection<Part> parts = request.getParts();
            String uploadPath = request.getServletContext().getRealPath("/uploads/email_attachments/");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            for (Part part : parts) {
                if (part.getName().equals("attachments") && part.getSize() > 0) {
                    String fileName = getFileName(part);
                    if (fileName != null && !fileName.isEmpty()) {
                        // Generate unique filename
                        String extension = fileName.substring(fileName.lastIndexOf('.'));
                        String uniqueFileName = UUID.randomUUID().toString() + extension;
                        
                        // Save file
                        File uploadedFile = new File(uploadDir, uniqueFileName);
                        part.write(uploadedFile.getAbsolutePath());
                        
                        // Store relative path
                        String relativePath = uploadedFile.getAbsolutePath();
                        attachmentsArray.put(relativePath);
                    }
                }
            }
            
            // Validation
            if (subject == null || subject.trim().isEmpty()) {
                sendJsonResponse(response, false, "Vui lòng nhập tiêu đề email", null);
                return;
            }
            
            if (content == null || content.trim().isEmpty()) {
                sendJsonResponse(response, false, "Vui lòng nhập nội dung email", null);
                return;
            }
            
            if (emailType == null || (!emailType.equals("internal") && !emailType.equals("marketing"))) {
                sendJsonResponse(response, false, "Loại email không hợp lệ", null);
                return;
            }
            
            // Build recipient roles JSON
            JSONArray rolesArray = new JSONArray();
            if (selectedRoles != null && selectedRoles.length > 0) {
                for (String role : selectedRoles) {
                    rolesArray.put(role);
                }
            }
            
            // Build recipient emails JSON
            JSONArray emailsArray = new JSONArray();
            if (customEmails != null && !customEmails.trim().isEmpty()) {
                String[] emails = customEmails.split("[,\\n]");
                for (String email : emails) {
                    email = email.trim();
                    if (!email.isEmpty() && email.contains("@")) {
                        emailsArray.put(email);
                    }
                }
            }
            
            // Get sender name
            String sentByName = username;
            UserDAO userDAO = new UserDAO();
            if (userId != null) {
                User user = userDAO.getUserById(userId);
                if (user != null && user.getFullName() != null) {
                    sentByName = user.getFullName();
                }
            }
            
            // Create email notification
            EmailNotification notification = new EmailNotification(
                subject, content, emailType,
                rolesArray.toString(), emailsArray.toString(),
                userId, sentByName
            );
            
            // Set attachments
            notification.setAttachments(attachmentsArray.toString());
            
            // Save notification and start background sending
            boolean saved = emailService.saveEmailNotification(notification);
            
            if (saved) {
                // Start sending email in background thread
                emailService.sendEmailInBackground(notification.getId());
                
                // Return immediately
                sendJsonResponse(response, true, "Đã nhận yêu cầu gửi email. Email đang được gửi trong background. Bạn có thể theo dõi trạng thái trong danh sách.", null);
            } else {
                sendJsonResponse(response, false, "Có lỗi xảy ra khi lưu email notification. Vui lòng thử lại.", null);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            sendJsonResponse(response, false, "Lỗi: " + e.getMessage(), null);
        }
    }

    private void getUsersByRoles(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String[] roles = request.getParameterValues("roles[]");
            
            if (roles == null || roles.length == 0) {
                sendJsonResponse(response, false, "Không có role được chọn", null);
                return;
            }
            
            UserDAO userDAO = new UserDAO();
            List<User> users = new ArrayList<>();
            
            for (String role : roles) {
                users.addAll(userDAO.getUsersByRole(role));
            }
            
            // Build response
            JSONArray usersArray = new JSONArray();
            for (User user : users) {
                JSONObject userObj = new JSONObject();
                userObj.put("id", user.getId());
                userObj.put("email", user.getEmail());
                userObj.put("fullName", user.getFullName());
                userObj.put("role", user.getRole());
                userObj.put("roleDisplay", user.getRoleDisplayName());
                usersArray.put(userObj);
            }
            
            JSONObject result = new JSONObject();
            result.put("users", usersArray);
            result.put("count", users.size());
            
            sendJsonResponse(response, true, "Thành công", result);
            
        } catch (Exception e) {
            e.printStackTrace();
            sendJsonResponse(response, false, "Lỗi: " + e.getMessage(), null);
        }
    }

    private void filterEmails(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String emailType = request.getParameter("emailType");
            String status = request.getParameter("status");
            String searchTerm = request.getParameter("search");
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            
            List<EmailNotification> emails = emailDAO.getEmailNotificationsWithFilters(
                emailType, status, searchTerm, startDate, endDate
            );
            
            JSONArray emailsArray = new JSONArray();
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            
            for (EmailNotification email : emails) {
                JSONObject emailObj = new JSONObject();
                emailObj.put("id", email.getId());
                emailObj.put("subject", email.getSubject());
                emailObj.put("emailType", email.getEmailType());
                emailObj.put("emailTypeDisplay", email.getEmailTypeDisplayName());
                emailObj.put("status", email.getStatus());
                emailObj.put("statusDisplay", email.getStatusDisplayName());
                emailObj.put("statusBadge", email.getStatusBadgeClass());
                emailObj.put("recipientCount", email.getRecipientCount());
                emailObj.put("successCount", email.getSuccessCount());
                emailObj.put("failedCount", email.getFailedCount());
                emailObj.put("sentByName", email.getSentByName());
                emailObj.put("createdAt", email.getCreatedAt() != null ? 
                            dateFormat.format(email.getCreatedAt()) : "");
                emailObj.put("sentAt", email.getSentAt() != null ? 
                            dateFormat.format(email.getSentAt()) : "");
                emailsArray.put(emailObj);
            }
            
            JSONObject result = new JSONObject();
            result.put("emails", emailsArray);
            result.put("count", emails.size());
            
            sendJsonResponse(response, true, "Thành công", result);
            
        } catch (Exception e) {
            e.printStackTrace();
            sendJsonResponse(response, false, "Lỗi: " + e.getMessage(), null);
        }
    }

    private void deleteEmail(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                sendJsonResponse(response, false, "ID không hợp lệ", null);
                return;
            }
            
            int id = Integer.parseInt(idParam);
            boolean deleted = emailDAO.deleteEmailNotification(id);
            
            if (deleted) {
                sendJsonResponse(response, true, "Đã xóa email notification", null);
            } else {
                sendJsonResponse(response, false, "Không thể xóa email notification", null);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            sendJsonResponse(response, false, "Lỗi: " + e.getMessage(), null);
        }
    }

    private void testEmailConnection(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            boolean connected = emailService.testConnection();
            
            if (connected) {
                sendJsonResponse(response, true, "Kết nối email thành công", null);
            } else {
                sendJsonResponse(response, false, "Không thể kết nối đến email server", null);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            sendJsonResponse(response, false, "Lỗi: " + e.getMessage(), null);
        }
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, 
                                  String message, JSONObject data) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("success", success);
        jsonResponse.put("message", message);
        if (data != null) {
                jsonResponse.put("data", data);
        }
        
        out.print(jsonResponse.toString());
        out.flush();
    }
    
    /**
     * Extract filename from Part
     */
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] tokens = contentDisposition.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return null;
    }
}

