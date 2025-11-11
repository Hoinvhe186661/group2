package com.hlgenerator.servlet;

import com.google.gson.JsonObject;
import com.hlgenerator.dao.ContactDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

@WebServlet("/contact-management")
public class ContactManagementServlet extends HttpServlet {
    
    private ContactDAO contactDAO;
    
    @Override
    public void init() throws ServletException {
        contactDAO = new ContactDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // Kiểm tra nếu là API request
        String action = request.getParameter("action");
        if (action != null) {
            handleApiRequest(request, response);
            return;
        }
        
        response.setContentType("text/html; charset=UTF-8");
        
        // Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("isLoggedIn") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String userRole = (String) session.getAttribute("userRole");
        
        if (!"customer_support".equals(userRole) && !"admin".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        
        // Lấy filter parameters
        String filterStatus = request.getParameter("status");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String search = request.getParameter("q");
        //phân trang 
        
        // Lấy tham số phân trang
        String pageParam = request.getParameter("page");
        String sizeParam = request.getParameter("size");
        int currentPage = 1;
        int pageSize = 10;
        try {
            if (pageParam != null) currentPage = Integer.parseInt(pageParam);
        } catch (Exception ignored) {}
        try {
            if (sizeParam != null) pageSize = Integer.parseInt(sizeParam);
        } catch (Exception ignored) {}
        if (currentPage < 1) currentPage = 1;
        if (pageSize < 1) pageSize = 10;
        
        // Đếm tổng số tin nhắn với bộ lọc
        int total = contactDAO.countContactMessagesFiltered(filterStatus, startDate, endDate, search);
        int totalPages = (int) Math.ceil(total / (double) pageSize);
        if (totalPages == 0) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        
        // Lấy tin nhắn liên hệ với phân trang và bộ lọc
        List<Map<String, Object>> filteredMessages = contactDAO.getContactMessagesPageFiltered(
            currentPage, pageSize, filterStatus, startDate, endDate, search
        );
        
        // Set attributes
        request.setAttribute("messages", filteredMessages);
        request.setAttribute("filterStatus", filterStatus);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("search", search);
        request.setAttribute("totalMessages", total);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("unreadCount", contactDAO.countUnreadMessages());
        
        // Forward to JSP
        request.getRequestDispatcher("/contact_management.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();
        
        try {
            String action = request.getParameter("action");
            if (action == null) {
                action = "updateStatus";
            }
            
            // Xử lý submit form liên hệ (không cần đăng nhập)
            if ("submitContact".equals(action)) {
                handleSubmitContact(request, response, jsonResponse);
                out.print(jsonResponse.toString());
                out.close();
                return;
            }
            
            // Các action khác cần đăng nhập
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("isLoggedIn") == null) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Chưa đăng nhập");
                out.print(jsonResponse.toString());
                return;
            }
            
            String userRole = (String) session.getAttribute("userRole");
            
            // Kiểm tra quyền
            if (!"customer_support".equals(userRole) && !"admin".equals(userRole)) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Không có quyền truy cập");
                out.print(jsonResponse.toString());
                return;
            }
            
            if ("updateStatus".equals(action)) {
                // Cập nhật trạng thái tin nhắn
                String idParam = request.getParameter("id");
                String status = request.getParameter("status");
                String contactMethod = request.getParameter("contactMethod");
                String address = request.getParameter("address");
                String customerType = request.getParameter("customerType");
                String companyName = request.getParameter("companyName");
                String taxCode = request.getParameter("taxCode");
                String contactContent = request.getParameter("contactContent");
                
                if (idParam == null || idParam.trim().isEmpty() || status == null || status.trim().isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin ID hoặc status");
                } else {
                    try {
                        int messageId = Integer.parseInt(idParam);
                        boolean success;
                        
                        // Nếu có các thông tin bổ sung, sử dụng method mở rộng
                        if (contactMethod != null && !contactMethod.trim().isEmpty()) {
                            success = contactDAO.updateMessageStatusWithDetails(
                                messageId, 
                                status.trim(), 
                                contactMethod.trim(),
                                address != null ? address.trim() : null,
                                customerType != null ? customerType.trim() : null,
                                companyName != null ? companyName.trim() : null,
                                taxCode != null ? taxCode.trim() : null,
                                contactContent != null ? contactContent.trim() : null
                            );
                        } else {
                            success = contactDAO.updateMessageStatus(messageId, status.trim());
                        }
                        
                        if (success) {
                            jsonResponse.addProperty("success", true);
                            jsonResponse.addProperty("message", "Cập nhật trạng thái thành công");
                        } else {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Lỗi cập nhật trạng thái");
                        }
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "ID không hợp lệ");
                    }
                }
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Action không hợp lệ: " + action);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Lỗi server: " + e.getMessage());
        } finally {
            out.print(jsonResponse.toString());
            out.close();
        }
    }
    
    /**
     * Xử lý submit form liên hệ với validation đầy đủ
     */
    private void handleSubmitContact(HttpServletRequest request, HttpServletResponse response, 
                                     JsonObject jsonResponse) throws IOException {
        // Lấy thông tin từ form
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String message = request.getParameter("message");
        
        // Validation: Kiểm tra các trường bắt buộc
        if (fullName == null || fullName.trim().isEmpty()) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Vui lòng nhập họ tên");
            return;
        }
        
        if (email == null || email.trim().isEmpty()) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Vui lòng nhập email");
            return;
        }
        
        if (phone == null || phone.trim().isEmpty()) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Vui lòng nhập số điện thoại");
            return;
        }
        
        if (message == null || message.trim().isEmpty()) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Vui lòng nhập nội dung tin nhắn");
            return;
        }
        
        // Trim các giá trị
        fullName = fullName.trim();
        email = email.trim();
        phone = phone.trim();
        message = message.trim();
        
        // Validation: Kiểm tra độ dài tối đa
        if (fullName.length() > 100) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Họ tên chỉ được phép tối đa 100 ký tự");
            return;
        }
        
        if (email.length() > 100) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Email chỉ được phép tối đa 100 ký tự");
            return;
        }
        
        if (message.length() > 100) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Nội dung tin nhắn chỉ được phép tối đa 100 ký tự");
            return;
        }
        
        // Validation: Kiểm tra định dạng email (phải thuộc miền gmail.com hoặc fpt.edu.vn)
        // Giống với validation trong SettingsServlet
        if (!email.matches("^[a-zA-Z0-9._%+-]+@(gmail\\.com|fpt\\.edu\\.vn)$")) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Email liên hệ chỉ được phép dùng miền gmail.com hoặc fpt.edu.vn");
            return;
        }
        
        // Validation: Kiểm tra định dạng số điện thoại (10-11 chữ số)
        // Giống với validation trong settings.jsp
        if (!phone.matches("^[0-9]{10,11}$")) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Số điện thoại phải gồm 10 hoặc 11 chữ số");
            return;
        }
        
        // Lưu tin nhắn liên hệ
        try {
            boolean success = contactDAO.saveContactMessage(fullName, email, phone, message);
            
            if (success) {
                // Thêm activity log cho tin nhắn liên hệ mới (nếu có ActionLogUtil)
                try {
                    com.hlgenerator.util.ActionLogUtil.addAction(request, "Tin nhắn liên hệ mới", 
                        "contact_messages", null, 
                        "Tin nhắn liên hệ từ: " + fullName + " (" + email + ")", "info");
                } catch (Exception e) {
                    // Bỏ qua nếu ActionLogUtil không tồn tại
                }
                
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("message", "Cảm ơn bạn đã liên hệ! Chúng tôi sẽ phản hồi sớm nhất có thể.");
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Có lỗi xảy ra khi gửi liên hệ. Vui lòng thử lại sau.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Lỗi máy chủ: " + e.getMessage());
        }
    }
    
    private void handleApiRequest(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();
        
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("isLoggedIn") == null) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Chưa đăng nhập");
                out.print(jsonResponse.toString());
                return;
            }
            
            String action = request.getParameter("action");
            
            if ("getStats".equals(action)) {
                int unreadCount = contactDAO.countUnreadMessages();
                List<Map<String, Object>> allMessages = contactDAO.getAllContactMessages();
                
                int newCount = 0;
                int repliedCount = 0;
                int totalCount = allMessages.size();
                
                for (Map<String, Object> message : allMessages) {
                    String status = (String) message.get("status");
                    if ("new".equals(status)) {
                        newCount++;
                    } else if ("replied".equals(status)) {
                        repliedCount++;
                    }
                }
                
                JsonObject stats = new JsonObject();
                stats.addProperty("unreadCount", unreadCount);
                stats.addProperty("newCount", newCount);
                stats.addProperty("repliedCount", repliedCount);
                stats.addProperty("totalCount", totalCount);
                
                jsonResponse.addProperty("success", true);
                jsonResponse.add("data", stats);
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Action không hợp lệ");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Lỗi server: " + e.getMessage());
        } finally {
            out.print(jsonResponse.toString());
            out.close();
        }
    }
}

