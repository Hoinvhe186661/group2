package com.hlgenerator.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.hlgenerator.dao.SupportRequestDAO;
import com.hlgenerator.dao.UserDAO;
import com.hlgenerator.model.User;
import com.hlgenerator.util.AuthorizationUtil;
import com.hlgenerator.util.Permission;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet({"/support-management", "/demo/support-management", "/support-update"})
public class SupportManagementServlet extends HttpServlet {
    
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        gson = new Gson();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set encoding TRƯỚC KHI đọc bất kỳ parameter nào
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // Kiểm tra nếu là API request
        String action = request.getParameter("action");
        if (action != null) {
            handleApiRequest(request, response);
            return;
        }
        
        response.setContentType("text/html; charset=UTF-8");
        
        if (!AuthorizationUtil.isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        if (!AuthorizationUtil.hasPermission(request, Permission.MANAGE_SUPPORT)) {
            response.sendRedirect(request.getContextPath() + "/403.jsp");
            return;
        }
        
        
        
        String filterStatus = request.getParameter("status");
        String filterPriority = request.getParameter("priority");
        String filterCategory = request.getParameter("category");
        
       
        SupportRequestDAO supportDAO = new SupportRequestDAO();
        List<Map<String, Object>> allTickets = supportDAO.getAllSupportRequests();
        
        
        List<Map<String, Object>> filteredTickets = new ArrayList<Map<String, Object>>();
        
        for (Map<String, Object> ticket : allTickets) {
            boolean matchStatus = (filterStatus == null || filterStatus.isEmpty() || 
                                  filterStatus.equals(ticket.get("status")));
            boolean matchPriority = (filterPriority == null || filterPriority.isEmpty() || 
                                    filterPriority.equals(ticket.get("priority")));
            boolean matchCategory = (filterCategory == null || filterCategory.isEmpty() || 
                                    filterCategory.equals(ticket.get("category")));
            
            if (matchStatus && matchPriority && matchCategory) {
                filteredTickets.add(ticket);
            }
        }
        
        
        
        
        request.setAttribute("tickets", filteredTickets);
        request.setAttribute("filterStatus", filterStatus);
        request.setAttribute("filterPriority", filterPriority);
        request.setAttribute("filterCategory", filterCategory);
        request.setAttribute("totalTickets", filteredTickets.size());
        
        
        request.getRequestDispatcher("/support_management.jsp").forward(request, response);
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
            if (!AuthorizationUtil.isLoggedIn(request)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Chưa đăng nhập");
                out.print(jsonResponse.toString());
                return;
            }
            
            if (!AuthorizationUtil.hasPermission(request, Permission.MANAGE_SUPPORT)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Không có quyền truy cập");
                out.print(jsonResponse.toString());
                return;
            }

            String action = request.getParameter("action");
            if (action == null) {
                action = "update"; // Default action cho support-update
            }
            
            SupportRequestDAO supportDAO = new SupportRequestDAO();
            
            if ("update".equals(action)) {
                // Cập nhật ticket (priority, assigned_to, status)
                String idParam = request.getParameter("id");
                String priority = request.getParameter("priority");
                String status = request.getParameter("status");
                String assignedTo = request.getParameter("assignedTo");
                String resolution = request.getParameter("resolution");
                
                if (idParam == null || idParam.trim().isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin ID");
                } else {
                    try {
                        int ticketId = Integer.parseInt(idParam);
                        Integer assignedToId = null;
                        
                        if (assignedTo != null && !assignedTo.trim().isEmpty()) {
                            try {
                                assignedToId = Integer.parseInt(assignedTo);
                            } catch (NumberFormatException e) {
                                // Ignore
                            }
                        }
                        
                        boolean success = supportDAO.updateSupportRequest(
                            ticketId, null, priority, status, resolution, null, assignedToId
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
            if (!AuthorizationUtil.isLoggedIn(request)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Chưa đăng nhập");
                out.print(jsonResponse.toString());
                return;
            }
            if (!AuthorizationUtil.hasPermission(request, Permission.MANAGE_SUPPORT)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Không có quyền truy cập");
                out.print(jsonResponse.toString());
                return;
            }
            String action = request.getParameter("action");
            
            if ("getHeadTechnicians".equals(action)) {
                UserDAO userDAO = new UserDAO();
                List<User> headTechs = userDAO.getUsersByRole("head_technician");
                
                List<Map<String, Object>> headTechList = new ArrayList<>();
                for (User user : headTechs) {
                    Map<String, Object> techUser = new HashMap<>();
                    techUser.put("id", user.getId());
                    techUser.put("name", user.getFullName());
                    techUser.put("email", user.getEmail());
                    headTechList.add(techUser);
                }
                
                jsonResponse.addProperty("success", true);
                jsonResponse.add("data", gson.toJsonTree(headTechList));
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

