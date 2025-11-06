package com.hlgenerator.servlet;

import com.hlgenerator.dao.SettingsDAO;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/settings")
public class SettingsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private SettingsDAO settingsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            settingsDAO = new SettingsDAO();
            System.out.println("SettingsServlet: Initialized successfully");
        } catch (Exception e) {
            System.err.println("SettingsServlet initialization failed: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        // Check authentication
        if (!isAuthenticated(request)) {
            sendJsonResponse(response, false, "Không có quyền truy cập", null);
            return;
        }

        String action = request.getParameter("action");
        PrintWriter out = response.getWriter();

        try {
            // Mặc định trả về tất cả settings nếu không có action hoặc action là getAll
            if (action == null || action.isEmpty() || "getAll".equals(action)) {
                Map<String, String> settings = settingsDAO.getAllSettings();
                JSONObject result = new JSONObject();
                result.put("success", true);
                JSONObject data = new JSONObject();
                for (Map.Entry<String, String> entry : settings.entrySet()) {
                    data.put(entry.getKey(), entry.getValue());
                }
                result.put("data", data);
                out.print(result.toString());
            } else {
                sendJsonResponse(response, false, "Action không hợp lệ", null);
            }
        } catch (Exception e) {
            sendJsonResponse(response, false, "Lỗi máy chủ: " + e.getMessage(), null);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        // Check authentication
        if (!isAuthenticated(request)) {
            sendJsonResponse(response, false, "Không có quyền truy cập", null);
            return;
        }

        String action = request.getParameter("action");
        System.out.println("SettingsServlet POST: Received action = '" + action + "'");
        System.out.println("SettingsServlet POST: Content-Type = " + request.getContentType());
        System.out.println("SettingsServlet POST: Request method = " + request.getMethod());
        
        // Debug: In tất cả parameters
        System.out.println("SettingsServlet POST: All parameters:");
        request.getParameterMap().forEach((key, values) -> {
            System.out.println("  " + key + " = " + java.util.Arrays.toString(values));
        });

        try {
            HttpSession session = request.getSession(false);
            Integer userId = (Integer) session.getAttribute("userId");

            if (action == null || action.trim().isEmpty()) {
                System.err.println("SettingsServlet POST: Action is null or empty");
                sendJsonResponse(response, false, "Action không được để trống", null);
                return;
            }

            if ("saveGeneral".equals(action)) {
                handleSaveGeneralSettings(request, response, userId);
            } else if ("saveEmail".equals(action)) {
                handleSaveEmailSettings(request, response, userId);
            } else {
                System.err.println("SettingsServlet POST: Unknown action: " + action);
                sendJsonResponse(response, false, "Action không hợp lệ: " + action, null);
            }
        } catch (Exception e) {
            sendJsonResponse(response, false, "Lỗi máy chủ: " + e.getMessage(), null);
        }
    }

    private void handleSaveGeneralSettings(HttpServletRequest request, HttpServletResponse response, Integer userId) 
            throws IOException {
        Map<String, String> settings = new HashMap<>();
        
        // Lấy các giá trị từ form
        String siteName = request.getParameter("siteName");
        String siteDescription = request.getParameter("siteDescription");
        String siteEmail = request.getParameter("siteEmail");
        String sitePhone = request.getParameter("sitePhone");
        String siteAddress = request.getParameter("siteAddress");

        // Validate email domain nếu có truyền lên
        if (siteEmail != null && !siteEmail.trim().isEmpty()) {
            String email = siteEmail.trim();
            // Chỉ chấp nhận gmail.com hoặc fpt.edu.vn
            if (!email.matches("^[a-zA-Z0-9._%+-]+@(gmail\\.com|fpt\\.edu\\.vn)$")) {
                sendJsonResponse(response, false, "Email liên hệ chỉ được phép dùng miền gmail.com hoặc fpt.edu.vn", null);
                return;
            }
        }

        // Validate số điện thoại nếu có truyền lên
        if (sitePhone != null && !sitePhone.trim().isEmpty()) {
            String phone = sitePhone.trim();
            // Chỉ cho phép số, 10 hoặc 11 chữ số
            if (!phone.matches("^[0-9]{10,11}$")) {
                sendJsonResponse(response, false, "Số điện thoại chỉ được phép chứa số và có độ dài 10 hoặc 11 chữ số", null);
                return;
            }
        }

        // Validate địa chỉ nếu có truyền lên (không được để trống nếu có giá trị)
        if (siteAddress != null && siteAddress.trim().isEmpty()) {
            sendJsonResponse(response, false, "Địa chỉ không được để trống", null);
            return;
        }

        // Lưu tất cả các giá trị, kể cả giá trị rỗng
        if (siteName != null) {
            settings.put("site_name", siteName.trim());
        }
        if (siteDescription != null) {
            settings.put("site_description", siteDescription.trim());
        }
        if (siteEmail != null) {
            settings.put("site_email", siteEmail.trim());
        }
        if (sitePhone != null) {
            settings.put("site_phone", sitePhone.trim());
        }
        if (siteAddress != null) {
            settings.put("site_address", siteAddress.trim());
        }

        System.out.println("Saving general settings: " + settings);
        System.out.println("User ID: " + userId);
        
        boolean success = settingsDAO.saveSettings(settings, userId);
        
        if (success) {
            // Đồng bộ mail.smtp.username trong database.properties nếu siteEmail được cập nhật
            if (siteEmail != null && !siteEmail.trim().isEmpty()) {
                try {
                    updateSmtpUsernameInProperties(siteEmail.trim());
                } catch (Exception e) {
                    // Không chặn phản hồi thành công vì cài đặt chung đã lưu, chỉ log cảnh báo
                    System.err.println("Warning: Không thể cập nhật mail.smtp.username trong database.properties: " + e.getMessage());
                    e.printStackTrace();
                }
            }
            // Thêm activity log
            com.hlgenerator.util.ActionLogUtil.addAction(request, "Cập nhật cài đặt chung", "settings", null, 
                "Đã cập nhật cài đặt chung hệ thống", "success");
            System.out.println("General settings saved successfully");
            sendJsonResponse(response, true, "Đã lưu cài đặt chung thành công", null);
        } else {
            System.err.println("Failed to save general settings");
            sendJsonResponse(response, false, "Lỗi khi lưu cài đặt chung", null);
        }
    }

    /**
     * Cập nhật khóa mail.smtp.username trong database.properties ở các vị trí khả dĩ.
     * Ưu tiên cập nhật file nguồn tại src/main/resources và, nếu có, file triển khai trong WEB-INF/classes.
     */
    private void updateSmtpUsernameInProperties(String newEmail) throws IOException {
        java.util.List<java.io.File> candidateFiles = new java.util.ArrayList<>();

        // 1) File nguồn trong dự án (khi chạy dev/build)
        String projectPath = System.getProperty("user.dir");
        if (projectPath != null) {
            java.io.File srcProps = new java.io.File(projectPath, "src/main/resources/database.properties");
            if (srcProps.exists() && srcProps.isFile()) {
                candidateFiles.add(srcProps);
            }
        }

        // 2) File properties đã triển khai trong lớp (nếu server cho phép ghi)
        try {
            String deployedPath = getServletContext().getRealPath("/WEB-INF/classes/database.properties");
            if (deployedPath != null) {
                java.io.File deployedProps = new java.io.File(deployedPath);
                if (deployedProps.exists() && deployedProps.isFile()) {
                    candidateFiles.add(deployedProps);
                }
            }
        } catch (Exception ignore) {
            // Bỏ qua, có thể không chạy trong môi trường cho phép realPath
        }

        if (candidateFiles.isEmpty()) {
            throw new IOException("Không tìm thấy database.properties để cập nhật");
        }

        for (java.io.File file : candidateFiles) {
            java.util.Properties props = new java.util.Properties();
            try (java.io.FileInputStream fis = new java.io.FileInputStream(file)) {
                props.load(fis);
            }

            props.setProperty("mail.smtp.username", newEmail);

            // Lưu lại. Lưu ý: phương thức store sẽ ghi lại file, có thể thay đổi thứ tự khóa.
            try (java.io.FileOutputStream fos = new java.io.FileOutputStream(file)) {
                props.store(fos, "Updated by SettingsServlet: sync mail.smtp.username with siteEmail");
            }

            System.out.println("Updated mail.smtp.username in: " + file.getAbsolutePath());
        }
    }

    private void handleSaveEmailSettings(HttpServletRequest request, HttpServletResponse response, Integer userId) 
            throws IOException {
        Map<String, String> settings = new HashMap<>();
        
        // Lấy các giá trị từ form
        String smtpHost = request.getParameter("smtpHost");
        String smtpPort = request.getParameter("smtpPort");
        String smtpUsername = request.getParameter("smtpUsername");
        String smtpPassword = request.getParameter("smtpPassword");
        String smtpEncryption = request.getParameter("smtpEncryption");
        String emailNotifications = request.getParameter("emailNotifications");

        if (smtpHost != null) {
            settings.put("smtp_host", smtpHost);
        }
        if (smtpPort != null) {
            settings.put("smtp_port", smtpPort);
        }
        if (smtpUsername != null) {
            settings.put("smtp_username", smtpUsername);
        }
        if (smtpPassword != null && !smtpPassword.trim().isEmpty()) {
            settings.put("smtp_password", smtpPassword);
        }
        if (smtpEncryption != null) {
            settings.put("smtp_encryption", smtpEncryption);
        }
        if (emailNotifications != null) {
            settings.put("email_notifications", emailNotifications);
        } else {
            settings.put("email_notifications", "false");
        }

        boolean success = settingsDAO.saveSettings(settings, userId);
        
        if (success) {
            // Thêm activity log
            com.hlgenerator.util.ActionLogUtil.addAction(request, "Cập nhật cài đặt email", "settings", null, 
                "Đã cập nhật cài đặt email hệ thống", "success");
            sendJsonResponse(response, true, "Đã lưu cài đặt email thành công", null);
        } else {
            sendJsonResponse(response, false, "Lỗi khi lưu cài đặt email", null);
        }
    }

    private boolean isAuthenticated(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            System.out.println("SettingsServlet: Session is null");
            return false;
        }
        
        // Log tất cả session attributes để debug
        System.out.println("SettingsServlet: Session ID = " + session.getId());
        System.out.println("SettingsServlet: All session attributes:");
        java.util.Enumeration<String> attrNames = session.getAttributeNames();
        while (attrNames.hasMoreElements()) {
            String attrName = attrNames.nextElement();
            Object attrValue = session.getAttribute(attrName);
            System.out.println("  " + attrName + " = " + attrValue + " (type: " + (attrValue != null ? attrValue.getClass().getName() : "null") + ")");
        }
        
        Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
        String username = (String) session.getAttribute("username");
        String userRole = (String) session.getAttribute("userRole");
        
        System.out.println("SettingsServlet: isLoggedIn = " + isLoggedIn + ", username = " + username + ", userRole = " + userRole);
        
        if (username == null || isLoggedIn == null || !isLoggedIn) {
            System.out.println("SettingsServlet: User not logged in");
            return false;
        }
        
       
        // Nếu cần chỉ admin mới truy cập được, giữ nguyên logic này
        boolean isAdmin = "admin".equalsIgnoreCase(userRole);
        System.out.println("SettingsServlet: Is admin = " + isAdmin);
        
        if (!isAdmin) {
            System.out.println("SettingsServlet: Access denied - User role '" + userRole + "' is not admin");
        }
        
        return isAdmin;
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, String message, Object data) 
            throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject result = new JSONObject();
        result.put("success", success);
        result.put("message", message);
        if (data != null) {
            result.put("data", data);
        }
        out.print(result.toString());
    }
}

