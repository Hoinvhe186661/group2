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
        
        // Lấy tin nhắn liên hệ với bộ lọc
        List<Map<String, Object>> filteredMessages = contactDAO.getContactMessagesWithFilters(
            filterStatus, startDate, endDate
        );
        
        // Set attributes
        request.setAttribute("messages", filteredMessages);
        request.setAttribute("filterStatus", filterStatus);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("totalMessages", filteredMessages.size());
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
            // Kiểm tra đăng nhập
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
            
            String action = request.getParameter("action");
            if (action == null) {
                action = "updateStatus";
            }
            
            if ("updateStatus".equals(action)) {
                // Cập nhật trạng thái tin nhắn
                String idParam = request.getParameter("id");
                String status = request.getParameter("status");
                
                if (idParam == null || idParam.trim().isEmpty() || status == null || status.trim().isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin ID hoặc status");
                } else {
                    try {
                        int messageId = Integer.parseInt(idParam);
                        boolean success = contactDAO.updateMessageStatus(messageId, status.trim());
                        
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

