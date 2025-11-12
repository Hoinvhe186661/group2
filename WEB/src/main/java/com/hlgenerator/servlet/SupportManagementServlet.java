package com.hlgenerator.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.hlgenerator.dao.SupportRequestDAO;
import com.hlgenerator.dao.UserDAO;
import com.hlgenerator.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
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
        
        // Sắp xếp lại theo thời gian tạo mới nhất lên đầu (created_at DESC)
        Collections.sort(filteredTickets, new Comparator<Map<String, Object>>() {
            @Override
            public int compare(Map<String, Object> t1, Map<String, Object> t2) {
                java.sql.Timestamp ts1 = (java.sql.Timestamp) t1.get("createdAt");
                java.sql.Timestamp ts2 = (java.sql.Timestamp) t2.get("createdAt");
                
                // Nếu cả hai đều null, coi như bằng nhau
                if (ts1 == null && ts2 == null) {
                    return 0;
                }
                // Nếu ts1 null, đặt nó xuống cuối
                if (ts1 == null) {
                    return 1;
                }
                // Nếu ts2 null, đặt nó xuống cuối
                if (ts2 == null) {
                    return -1;
                }
                
                // So sánh ngược lại để mới nhất lên đầu (DESC)
                return ts2.compareTo(ts1);
            }
        });
        
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
                    // Validate resolution - tối đa 1000 từ
                    if (resolution != null && !resolution.trim().isEmpty()) {
                        int wordCount = countWords(resolution);
                        if (wordCount > 1000) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Giải pháp xử lý không được vượt quá 1000 từ. Hiện tại bạn đã nhập " + wordCount + " từ. Vui lòng rút gọn nội dung.");
                            out.print(jsonResponse.toString());
                            return;
                        }
                    }
                    
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
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("isLoggedIn") == null) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Chưa đăng nhập");
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
    
    /**
     * Đếm số từ trong một chuỗi văn bản
     * @param text Chuỗi văn bản cần đếm
     * @return Số từ trong văn bản
     */
    private int countWords(String text) {
        if (text == null || text.trim().isEmpty()) {
            return 0;
        }
        
        // Loại bỏ các khoảng trắng thừa và tách theo khoảng trắng
        String trimmed = text.trim();
        if (trimmed.isEmpty()) {
            return 0;
        }
        
        // Tách theo khoảng trắng (whitespace) và lọc các phần tử rỗng
        String[] words = trimmed.split("\\s+");
        int count = 0;
        for (String word : words) {
            if (word != null && !word.trim().isEmpty()) {
                count++;
            }
        }
        
        return count;
    }
}

