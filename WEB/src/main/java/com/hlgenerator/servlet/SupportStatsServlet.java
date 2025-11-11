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
                
            } else if ("getById".equals(action)) {
                // Lấy chi tiết một support request theo ID
                String idParam = request.getParameter("id");
                if (idParam != null && !idParam.trim().isEmpty()) {
                    try {
                        int id = Integer.parseInt(idParam);
                        Map<String, Object> ticket = supportDAO.getSupportRequestById(id);
                        
                        if (ticket != null) {
                            jsonResponse.addProperty("success", true);
                            jsonResponse.add("data", gson.toJsonTree(ticket));
                        } else {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Không tìm thấy yêu cầu hỗ trợ");
                        }
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "ID không hợp lệ");
                    }
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin ID");
                }
                
            } else if ("getTechnicalStaff".equals(action)) {
                // CHỈ lấy danh sách trưởng phòng kỹ thuật (head_technician)
                com.hlgenerator.dao.UserDAO userDAO = new com.hlgenerator.dao.UserDAO();
                java.util.List<com.hlgenerator.model.User> headTechs = userDAO.getUsersByRole("head_technician");
                
                // CHỈ trả về trưởng phòng kỹ thuật
                java.util.List<Map<String, Object>> allTechStaff = new java.util.ArrayList<>();
                
                for (com.hlgenerator.model.User user : headTechs) {
                    Map<String, Object> techUser = new java.util.HashMap<>();
                    techUser.put("id", user.getId());
                    techUser.put("name", user.getFullName());
                    techUser.put("role", "Trưởng phòng Kỹ thuật");
                    techUser.put("email", user.getEmail());
                    allTechStaff.add(techUser);
                }
                
                System.out.println("DEBUG: Found " + allTechStaff.size() + " head technicians for forwarding");
                
                jsonResponse.addProperty("success", true);
                jsonResponse.add("data", gson.toJsonTree(allTechStaff));
                
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
        } finally {
            if (out != null) {
                out.print(jsonResponse.toString());
                out.flush();
                out.close();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // QUAN TRỌNG: Phải set encoding TRƯỚC KHI đọc bất kỳ parameter nào
        try {
            request.setCharacterEncoding("UTF-8");
        } catch (Exception e) {
            System.out.println("Warning: Could not set request encoding: " + e.getMessage());
        }
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();
        
        try {
            // ĐÚNG: Đọc parameters sau khi đã set encoding, TRONG try block
            String action = request.getParameter("action");
            System.out.println("POST Action received: " + action);
            System.out.println("Request method: " + request.getMethod());
            System.out.println("Content type: " + request.getContentType());
            
            if ("createSupportRequest".equals(action)) {
                // Tạo yêu cầu hỗ trợ mới
                String subject = request.getParameter("subject");
                String description = request.getParameter("description");
                String category = request.getParameter("category");
                String priority = request.getParameter("priority");
                String deleteOldId = request.getParameter("delete_old_id");
                
                System.out.println("DEBUG: subject=" + subject + ", category=" + category);
                
                // Lấy customer_id từ session
                HttpSession session = request.getSession(false);
                Integer customerId = null;
                Integer userId = null;
                String userRole = null;
                
                if (session != null) {
                    customerId = (Integer) session.getAttribute("customerId");
                    userId = (Integer) session.getAttribute("userId");
                    userRole = (String) session.getAttribute("userRole");
                    System.out.println("DEBUG: customerId=" + customerId + ", userId=" + userId + ", userRole=" + userRole);
                    
                    // Nếu không có customerId, tự động tạo/lấy customer từ user info
                    if (customerId == null && userId != null) {
                        try {
                            com.hlgenerator.dao.CustomerDAO customerDAO = new com.hlgenerator.dao.CustomerDAO();
                            String email = (String) session.getAttribute("email");
                            String fullName = (String) session.getAttribute("fullName");
                            String username = (String) session.getAttribute("username");
                            
                            System.out.println("DEBUG: Attempting to get/create customer for email=" + email);
                            
                            // Tìm customer theo email
                            com.hlgenerator.model.Customer customer = null;
                            if (email != null && !email.trim().isEmpty()) {
                                customer = customerDAO.getCustomerByEmail(email.trim());
                            }
                            
                            // Nếu không tìm thấy, tạo customer mới
                            if (customer == null) {
                                String code = customerDAO.generateNextCustomerCode();
                                com.hlgenerator.model.Customer newCustomer = new com.hlgenerator.model.Customer();
                                newCustomer.setCustomerCode(code);
                                newCustomer.setCompanyName(fullName != null ? fullName : username);
                                newCustomer.setContactPerson(fullName != null ? fullName : username);
                                newCustomer.setEmail(email != null ? email.trim() : "");
                                newCustomer.setPhone("");
                                newCustomer.setAddress("");
                                newCustomer.setTaxCode("");
                                newCustomer.setCustomerType("individual");
                                newCustomer.setStatus("active");
                                
                                if (customerDAO.addCustomer(newCustomer)) {
                                    customer = customerDAO.getCustomerByEmail(email != null ? email.trim() : "");
                                    System.out.println("DEBUG: Created new customer with ID " + (customer != null ? customer.getId() : "null"));
                                }
                            }
                            
                            if (customer != null) {
                                customerId = customer.getId();
                                session.setAttribute("customerId", customerId);
                                System.out.println("DEBUG: Set customerId to " + customerId);
                            }
                        } catch (Exception e) {
                            System.out.println("ERROR: Failed to get/create customer: " + e.getMessage());
                            e.printStackTrace();
                        }
                    }
                }
                
                if (customerId == null) {
                    System.out.println("ERROR: customerId is still null after attempting to create");
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Không thể xác định thông tin khách hàng. Vui lòng liên hệ quản trị viên.");
                    out.print(jsonResponse.toString());
                    out.flush();
                    return;
                }
                
                if (subject == null || subject.trim().isEmpty() ||
                    description == null || description.trim().isEmpty() ||
                    category == null || category.trim().isEmpty()) {
                    
                    System.out.println("ERROR: Missing required fields");
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Vui lòng điền đầy đủ thông tin");
                } else {
                    System.out.println("DEBUG: Calling supportDAO.create()...");
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
                    System.out.println("DEBUG: supportDAO.create() returned: " + success);
                    
                    if (success) {
                        jsonResponse.addProperty("success", true);
                        // Kiểm tra nếu có delete_old_id thì đây là cập nhật, không phải tạo mới
                        if (deleteOldId != null && !deleteOldId.trim().isEmpty()) {
                            jsonResponse.addProperty("message", "Yêu cầu hỗ trợ đã được cập nhật thành công");
                        } else {
                            jsonResponse.addProperty("message", "Yêu cầu hỗ trợ đã được tạo thành công");
                            jsonResponse.addProperty("ticketNumber", "SR-" + System.currentTimeMillis());
                        }
                        System.out.println("SUCCESS: Support request " + (deleteOldId != null && !deleteOldId.trim().isEmpty() ? "updated" : "created"));
                    } else {
                        String error = supportDAO.getLastError();
                        System.out.println("ERROR: Failed to create - " + error);
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "Lỗi tạo yêu cầu: " + (error != null ? error : "Unknown error"));
                    }
                }
                System.out.println("DEBUG: End of createSupportRequest block");
                
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
                // Chuyển tiếp yêu cầu hỗ trợ KỸ THUẬT
                String idParam = request.getParameter("id");
                String forwardNote = request.getParameter("forwardNote");
                String forwardPriority = request.getParameter("forwardPriority");
                String assignedToParam = request.getParameter("assignedTo");
                
                System.out.println("DEBUG: Forward action - ID=" + idParam + ", assignedTo=" + assignedToParam);
                
                if (idParam == null || idParam.trim().isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin ID");
                } else {
                    try {
                        int id = Integer.parseInt(idParam);
                        
                        // Kiểm tra xem ticket có tồn tại và có phải technical không
                        Map<String, Object> ticket = supportDAO.getSupportRequestById(id);
                        if (ticket == null) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Không tìm thấy ticket");
                            out.print(jsonResponse.toString());
                            out.flush();
                            return;
                        }
                        
                        String currentCategory = (String) ticket.get("category");
                        String currentStatus = (String) ticket.get("status");
                        Integer currentAssignedTo = (Integer) ticket.get("assignedTo");
                        
                        System.out.println("DEBUG: Current category=" + currentCategory);
                        System.out.println("DEBUG: Current status=" + currentStatus);
                        System.out.println("DEBUG: Current assignedTo=" + currentAssignedTo);
                        
                        // CHỈ cho phép forward ticket technical
                        if (!"technical".equals(currentCategory)) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Chỉ có thể chuyển tiếp yêu cầu kỹ thuật!");
                            out.print(jsonResponse.toString());
                            out.flush();
                            return;
                        }
                        
                        // Kiểm tra: Chỉ cho phép forward ticket có status "open" (chưa được forward)
                        // Nếu ticket đã là "in_progress" và đã được assign, nghĩa là đã được forward rồi
                        if ("in_progress".equals(currentStatus) && currentAssignedTo != null && currentAssignedTo > 0) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Yêu cầu này đã được chuyển tiếp và đang xử lý rồi. Không thể chuyển tiếp lại!");
                            out.print(jsonResponse.toString());
                            out.flush();
                            return;
                        }
                        
                        // Kiểm tra: Nếu ticket đã resolved hoặc closed, không cho forward
                        if ("resolved".equals(currentStatus) || "closed".equals(currentStatus)) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Yêu cầu này đã được giải quyết hoặc đóng. Không thể chuyển tiếp!");
                            out.print(jsonResponse.toString());
                            out.flush();
                            return;
                        }
                        
                        // Set default values
                        if (forwardNote == null) forwardNote = "";
                        if (forwardPriority == null) forwardPriority = "medium";
                        
                        // Parse assignedTo - CHỈ nhận một ID
                        Integer assignedToId = null;
                        if (assignedToParam != null && !assignedToParam.trim().isEmpty()) {
                            try {
                                // Đảm bảo chỉ là một số, không phải nhiều ID
                                if (assignedToParam.contains(",")) {
                                    jsonResponse.addProperty("success", false);
                                    jsonResponse.addProperty("message", "Chỉ có thể chuyển tiếp đến một trưởng phòng tại một thời điểm!");
                                    out.print(jsonResponse.toString());
                                    out.flush();
                                    return;
                                }
                                
                                assignedToId = Integer.parseInt(assignedToParam.trim());
                                System.out.println("DEBUG: Assigning to user ID: " + assignedToId);
                                
                                // Kiểm tra user có phải head_technician không
                                com.hlgenerator.dao.UserDAO userDAO = new com.hlgenerator.dao.UserDAO();
                                com.hlgenerator.model.User assignedUser = userDAO.getUserById(assignedToId);
                                if (assignedUser == null) {
                                    jsonResponse.addProperty("success", false);
                                    jsonResponse.addProperty("message", "Không tìm thấy người nhận!");
                                    out.print(jsonResponse.toString());
                                    out.flush();
                                    return;
                                }
                                
                                if (!"head_technician".equals(assignedUser.getRole())) {
                                    jsonResponse.addProperty("success", false);
                                    jsonResponse.addProperty("message", "Chỉ có thể chuyển tiếp đến trưởng phòng kỹ thuật!");
                                    out.print(jsonResponse.toString());
                                    out.flush();
                                    return;
                                }
                                
                            } catch (NumberFormatException e) {
                                System.out.println("WARNING: Invalid assignedTo value: " + assignedToParam);
                                jsonResponse.addProperty("success", false);
                                jsonResponse.addProperty("message", "ID người nhận không hợp lệ!");
                                out.print(jsonResponse.toString());
                                out.flush();
                                return;
                            }
                        } else {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Vui lòng chọn trưởng phòng kỹ thuật để chuyển tiếp!");
                            out.print(jsonResponse.toString());
                            out.flush();
                            return;
                        }
                        
                        // Cập nhật ticket: đặt category='technical', status='in_progress', assign người nhận
                        // CHỈ cập nhật ticket ID này
                        String newInternalNotes = "CHUYỂN TIẾP ĐẾN BỘ PHẬN KỸ THUẬT" + 
                                                (forwardNote.isEmpty() ? "" : " - Ghi chú: " + forwardNote);
                        
                        System.out.println("DEBUG: Forwarding ticket ID=" + id + " to head_technician ID=" + assignedToId + " with priority=" + forwardPriority);
                        
                        // Update: set category to 'technical', update priority, status, add notes, assign user
                        // CHỈ cập nhật một ticket ID
                        boolean success = supportDAO.updateSupportRequest(id, "technical", forwardPriority, "in_progress", null, newInternalNotes, assignedToId);
                        
                        if (success) {
                            System.out.println("SUCCESS: Ticket forwarded to technical department");
                            String message = "Đã chuyển tiếp yêu cầu đến Bộ phận Kỹ thuật thành công!";
                            if (assignedToId != null) {
                                message += " (Đã phân công)";
                            }
                            jsonResponse.addProperty("success", true);
                            jsonResponse.addProperty("message", message);
                        } else {
                            System.out.println("ERROR: Failed to forward - " + supportDAO.getLastError());
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Lỗi chuyển tiếp: " + supportDAO.getLastError());
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
        } finally {
            if (out != null) {
                String responseStr = jsonResponse.toString();
                System.out.println("DEBUG: Sending response: " + responseStr);
                System.out.println("Response length: " + responseStr.length());
                out.print(responseStr);
                out.flush();
                out.close();
            }
        }
    }
}
