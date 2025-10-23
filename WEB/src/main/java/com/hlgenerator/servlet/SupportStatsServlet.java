package com.hlgenerator.servlet;

import com.hlgenerator.dao.SupportRequestDAO;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

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

@WebServlet("/api/support-stats")
public class SupportStatsServlet extends HttpServlet {
    private SupportRequestDAO supportDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        super.init();
        supportDAO = new SupportRequestDAO();
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();
        
        try {
            String action = request.getParameter("action");
            System.out.println("GET Action received: " + action);
            
            if ("getStats".equals(action)) {
                // Lấy thống kê tổng quan
                Map<String, Object> stats = supportDAO.getSupportStats();
                jsonResponse.addProperty("success", true);
                jsonResponse.add("data", gson.toJsonTree(stats));
                
            } else if ("getRecentTickets".equals(action)) {
                // Lấy danh sách ticket gần đây
                int limit = 10;
                String limitParam = request.getParameter("limit");
                if (limitParam != null) {
                    try {
                        limit = Integer.parseInt(limitParam);
                    } catch (NumberFormatException e) {
                        limit = 10;
                    }
                }
                
                List<Map<String, Object>> tickets = supportDAO.getRecentTickets(limit);
                jsonResponse.addProperty("success", true);
                jsonResponse.add("data", gson.toJsonTree(tickets));
                
            } else if ("getAllTickets".equals(action) || "list".equals(action)) {
                // Lấy ticket theo khách hàng đang đăng nhập
                HttpSession session = request.getSession(false);
                if (session == null || session.getAttribute("isLoggedIn") == null) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Chưa đăng nhập");
                } else {
                    // Lấy customerId từ session
                    Integer customerId = (Integer) session.getAttribute("customerId");
                    if (customerId == null) {
                        // Fallback: lấy từ userId nếu không có customerId
                        Integer userId = (Integer) session.getAttribute("userId");
                        customerId = userId; // Giả sử userId = customerId
                    }
                    
                    if (customerId != null) {
                        List<Map<String, Object>> customerTickets = supportDAO.listByCustomerId(customerId);
                        jsonResponse.addProperty("success", true);
                        jsonResponse.add("data", gson.toJsonTree(customerTickets));
                    } else {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "Không tìm thấy thông tin khách hàng");
                    }
                }
                
            } else {
                System.out.println("Unknown GET action: " + action);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Action không hợp lệ: " + action);
            }
            
        } catch (Exception e) {
            System.out.println("Error in doGet: " + e.getMessage());
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Lỗi server: " + e.getMessage());
        }
        
        out.print(jsonResponse.toString());
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();
        
        try {
            String action = request.getParameter("action");
            System.out.println("POST Action received: " + action);
            
            if ("createSupportRequest".equals(action)) {
                // Tạo yêu cầu hỗ trợ mới
                String subject = request.getParameter("subject");
                String description = request.getParameter("description");
                String category = request.getParameter("category");
                String priority = request.getParameter("priority");
                String deleteOldId = request.getParameter("delete_old_id");
                
                // Lấy customer_id từ session
                HttpSession session = request.getSession(false);
                Integer customerId = null;
                if (session != null) {
                    customerId = (Integer) session.getAttribute("customerId");
                    if (customerId == null) {
                        // Fallback: lấy từ userId nếu không có customerId
                        Integer userId = (Integer) session.getAttribute("userId");
                        customerId = userId; // Giả sử userId = customerId
                    }
                }
                
                if (customerId == null) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Không tìm thấy thông tin khách hàng");
                    out.print(jsonResponse.toString());
                    out.flush();
                    return;
                }
                
                if (subject == null || subject.trim().isEmpty() ||
                    description == null || description.trim().isEmpty() ||
                    category == null || category.trim().isEmpty()) {
                    
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Vui lòng điền đầy đủ thông tin");
                } else {
                    // Set priority mặc định nếu không có
                    if (priority == null || priority.trim().isEmpty()) {
                        priority = "medium";
                    }
                    
                    // Xóa ticket cũ nếu có delete_old_id
                    if (deleteOldId != null && !deleteOldId.trim().isEmpty()) {
                        try {
                            int oldId = Integer.parseInt(deleteOldId);
                            supportDAO.deleteById(oldId);
                        } catch (NumberFormatException e) {
                            // Ignore invalid old ID
                        }
                    }
                    
                    boolean success = supportDAO.create(customerId.intValue(), subject, description, category, priority);
                    
                    if (success) {
                        jsonResponse.addProperty("success", true);
                        jsonResponse.addProperty("message", "Yêu cầu hỗ trợ đã được tạo thành công");
                        jsonResponse.addProperty("ticketNumber", "SR-" + System.currentTimeMillis());
                    } else {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "Lỗi tạo yêu cầu: " + supportDAO.getLastError());
                    }
                }
                
            } else if ("cancel".equals(action)) {
                // Hủy yêu cầu hỗ trợ
                String idParam = request.getParameter("id");
                if (idParam != null && !idParam.trim().isEmpty()) {
                    try {
                        int id = Integer.parseInt(idParam);
                        boolean success = supportDAO.deleteById(id);
                        
                        if (success) {
                            jsonResponse.addProperty("success", true);
                            jsonResponse.addProperty("message", "Đã hủy yêu cầu thành công");
                        } else {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Lỗi hủy yêu cầu: " + supportDAO.getLastError());
                        }
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "ID không hợp lệ");
                    }
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin ID");
                }
                
            } else if ("update".equals(action)) {
                // Cập nhật yêu cầu hỗ trợ - chỉ cho phép chỉnh sửa priority, status, resolution, internalNotes
                String idParam = request.getParameter("id");
                String priority = request.getParameter("priority");
                String status = request.getParameter("status");
                String resolution = request.getParameter("resolution");
                String internalNotes = request.getParameter("internalNotes");
                
                if (idParam == null || idParam.trim().isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin ID");
                } else {
                    try {
                        int id = Integer.parseInt(idParam);
                        
                        // Set default values cho các trường được phép chỉnh sửa
                        if (priority == null) priority = "medium";
                        if (status == null) status = "open";
                        if (resolution == null) resolution = "";
                        if (internalNotes == null) internalNotes = "";
                        
                        // Chỉ cập nhật các trường được phép chỉnh sửa
                        boolean success = supportDAO.updateSupportRequest(id, null, priority, status, resolution, internalNotes);
                        
                        if (success) {
                            jsonResponse.addProperty("success", true);
                            jsonResponse.addProperty("message", "Cập nhật yêu cầu thành công");
                        } else {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Lỗi cập nhật yêu cầu: " + supportDAO.getLastError());
                        }
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "ID không hợp lệ");
                    }
                }
                
            } else if ("forward".equals(action)) {
                // Chuyển tiếp yêu cầu hỗ trợ
                String idParam = request.getParameter("id");
                String department = request.getParameter("department");
                String forwardNote = request.getParameter("forwardNote");
                String forwardPriority = request.getParameter("forwardPriority");
                
                if (idParam == null || idParam.trim().isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin ID");
                } else if (department == null || department.trim().isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Vui lòng chọn bộ phận chuyển tiếp");
                } else {
                    try {
                        int id = Integer.parseInt(idParam);
                        
                        // Set default values
                        if (forwardNote == null) forwardNote = "";
                        if (forwardPriority == null) forwardPriority = "medium";
                        
                        // Cập nhật ticket với thông tin chuyển tiếp
                        String departmentName = "head_technical".equals(department) ? "Trưởng phòng Kỹ thuật" : department;
                        String newInternalNotes = "CHUYỂN TIẾP - Bộ phận: " + departmentName + 
                                                (forwardNote.isEmpty() ? "" : ", Ghi chú: " + forwardNote);
                        
                        boolean success = supportDAO.updateSupportRequest(id, null, forwardPriority, "in_progress", "", newInternalNotes);
                        
                        if (success) {
                            jsonResponse.addProperty("success", true);
                            jsonResponse.addProperty("message", "Chuyển tiếp yêu cầu thành công đến " + departmentName);
                        } else {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Lỗi chuyển tiếp yêu cầu: " + supportDAO.getLastError());
                        }
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "ID không hợp lệ");
                    }
                }
                
            } else {
                System.out.println("Unknown POST action: " + action);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Action không hợp lệ: " + action);
            }
            
        } catch (Exception e) {
            System.out.println("Error in doPost: " + e.getMessage());
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Lỗi server: " + e.getMessage());
        }
        
        out.print(jsonResponse.toString());
        out.flush();
    }
}
