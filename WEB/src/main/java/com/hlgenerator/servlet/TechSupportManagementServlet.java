package com.hlgenerator.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.hlgenerator.dao.SupportRequestDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/api/tech-support")
public class TechSupportManagementServlet extends HttpServlet {
    
    private SupportRequestDAO supportDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        supportDAO = new SupportRequestDAO();
        gson = new Gson();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set encoding
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
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
            
            // Kiểm tra quyền: chỉ head_technician và admin mới xem được
            if (!"head_technician".equals(userRole) && !"admin".equals(userRole)) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Không có quyền truy cập");
                out.print(jsonResponse.toString());
                return;
            }
            
            String action = request.getParameter("action");
            System.out.println("TechSupport GET Action: " + action);
            
            if ("list".equals(action) || action == null) {
                // Lấy danh sách tất cả ticket technical
                List<Map<String, Object>> allTickets = supportDAO.getAllSupportRequests();
                
                // Lọc chỉ lấy ticket technical
                List<Map<String, Object>> technicalTickets = new ArrayList<>();
                
                // Lọc theo filter parameters
                String filterStatus = request.getParameter("status");
                String filterPriority = request.getParameter("priority");
                String filterCategory = request.getParameter("category");
                
                for (Map<String, Object> ticket : allTickets) {
                    String category = (String) ticket.get("category");
                    
                    // Chỉ lấy ticket technical
                    if (!"technical".equals(category)) {
                        continue;
                    }
                    
                    // Apply filters
                    if (filterStatus != null && !filterStatus.isEmpty()) {
                        if (!filterStatus.equals(ticket.get("status"))) {
                            continue;
                        }
                    }
                    
                    if (filterPriority != null && !filterPriority.isEmpty()) {
                        if (!filterPriority.equals(ticket.get("priority"))) {
                            continue;
                        }
                    }
                    
                    if (filterCategory != null && !filterCategory.isEmpty()) {
                        if (!filterCategory.equals(ticket.get("category"))) {
                            continue;
                        }
                    }
                    
                    technicalTickets.add(ticket);
                }
                
                System.out.println("Found " + technicalTickets.size() + " technical tickets");
                
                jsonResponse.addProperty("success", true);
                jsonResponse.add("data", gson.toJsonTree(technicalTickets));
                
            } else if ("stats".equals(action)) {
                // Thống kê ticket technical
                List<Map<String, Object>> allTickets = supportDAO.getAllSupportRequests();
                
                int total = 0;
                int open = 0;
                int inProgress = 0;
                int resolved = 0;
                
                for (Map<String, Object> ticket : allTickets) {
                    String category = (String) ticket.get("category");
                    if ("technical".equals(category)) {
                        total++;
                        String status = (String) ticket.get("status");
                        
                        if ("open".equals(status)) {
                            open++;
                        } else if ("in_progress".equals(status)) {
                            inProgress++;
                        } else if ("resolved".equals(status)) {
                            resolved++;
                        }
                    }
                }
                
                JsonObject stats = new JsonObject();
                stats.addProperty("total", total);
                stats.addProperty("open", open);
                stats.addProperty("inProgress", inProgress);
                stats.addProperty("resolved", resolved);
                
                jsonResponse.addProperty("success", true);
                jsonResponse.add("data", stats);
                
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Action không hợp lệ");
            }
            
        } catch (Exception e) {
            System.out.println("Error in TechSupport GET: " + e.getMessage());
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
        
        // Set encoding
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
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
            if (!"head_technician".equals(userRole) && !"admin".equals(userRole)) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Không có quyền thực hiện");
                out.print(jsonResponse.toString());
                return;
            }
            
            String action = request.getParameter("action");
            System.out.println("TechSupport POST Action: " + action);
            
            if ("update".equals(action)) {
                // Cập nhật ticket technical
                String idParam = request.getParameter("id");
                String category = request.getParameter("category");
                String priority = request.getParameter("priority");
                String status = request.getParameter("status");
                String resolution = request.getParameter("resolution");
                String internalNotes = request.getParameter("internalNotes");
                String assignedTo = request.getParameter("assignedTo");
                
                if (idParam == null || idParam.isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu ID ticket");
                } else {
                    try {
                        int ticketId = Integer.parseInt(idParam);
                        Integer assignedToId = null;
                        
                        if (assignedTo != null && !assignedTo.isEmpty()) {
                            try {
                                assignedToId = Integer.parseInt(assignedTo);
                            } catch (NumberFormatException e) {
                                // Ignore
                            }
                        }
                        
                        boolean success = supportDAO.updateSupportRequest(
                            ticketId, category, priority, status, resolution, internalNotes, assignedToId
                        );
                        
                        if (success) {
                            jsonResponse.addProperty("success", true);
                            jsonResponse.addProperty("message", "Cập nhật ticket thành công");
                        } else {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Lỗi cập nhật: " + supportDAO.getLastError());
                        }
                        
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "ID không hợp lệ");
                    }
                }
                
            } else if ("assign".equals(action)) {
                // Assign ticket cho technical staff
                String idParam = request.getParameter("id");
                String technicianId = request.getParameter("technicianId");
                
                if (idParam == null || technicianId == null) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin");
                } else {
                    try {
                        int ticketId = Integer.parseInt(idParam);
                        int techId = Integer.parseInt(technicianId);
                        
                        // Update assigned_to và status
                        boolean success = supportDAO.updateSupportRequest(
                            ticketId, null, null, "in_progress", null, null, techId
                        );
                        
                        if (success) {
                            jsonResponse.addProperty("success", true);
                            jsonResponse.addProperty("message", "Đã phân công kỹ thuật viên");
                        } else {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Lỗi phân công: " + supportDAO.getLastError());
                        }
                        
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "Thông tin không hợp lệ");
                    }
                }
                
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Action không hợp lệ");
            }
            
        } catch (Exception e) {
            System.out.println("Error in TechSupport POST: " + e.getMessage());
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Lỗi server: " + e.getMessage());
        }
        
        out.print(jsonResponse.toString());
        out.flush();
    }
}


