package com.hlgenerator.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.hlgenerator.dao.WorkOrderDAO;
import com.hlgenerator.model.WorkOrder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

@WebServlet("/api/work-orders")
public class WorkOrderServlet extends HttpServlet {
    
    private WorkOrderDAO workOrderDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        workOrderDAO = new WorkOrderDAO();
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
            
            String action = request.getParameter("action");
            System.out.println("WorkOrder GET Action: " + action);
            
            if ("list".equals(action) || action == null) {
                // Lấy danh sách work orders
                List<WorkOrder> workOrders = workOrderDAO.getAllWorkOrders();
                
                jsonResponse.addProperty("success", true);
                jsonResponse.add("data", gson.toJsonTree(workOrders));
                
            } else if ("get".equals(action)) {
                // Lấy work order theo ID
                String idParam = request.getParameter("id");
                if (idParam == null || idParam.isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu ID work order");
                } else {
                    try {
                        int id = Integer.parseInt(idParam);
                        WorkOrder workOrder = workOrderDAO.getWorkOrderById(id);
                        
                        if (workOrder != null) {
                            jsonResponse.addProperty("success", true);
                            jsonResponse.add("data", gson.toJsonTree(workOrder));
                        } else {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Không tìm thấy work order");
                        }
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "ID không hợp lệ");
                    }
                }
                
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Action không hợp lệ");
            }
            
        } catch (Exception e) {
            System.out.println("Error in WorkOrder GET: " + e.getMessage());
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
            
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                // Try to get from username if userId not available
                String username = (String) session.getAttribute("username");
                if (username != null) {
                    // You may need to look up userId from username if needed
                    userId = 1; // Default fallback, should be handled better in production
                }
            }
            
            String action = request.getParameter("action");
            System.out.println("WorkOrder POST Action: " + action);
            
            if ("create".equals(action)) {
                // Tạo work order mới
                WorkOrder workOrder = new WorkOrder();
                
                // Required fields
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                String customerIdParam = request.getParameter("customerId");
                
                if (title == null || title.trim().isEmpty() || 
                    description == null || description.trim().isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin bắt buộc (tiêu đề, mô tả)");
                    out.print(jsonResponse.toString());
                    return;
                }
                
                workOrder.setTitle(title.trim());
                workOrder.setDescription(description.trim());
                
                // customerId là bắt buộc (database yêu cầu NOT NULL)
                if (customerIdParam != null && !customerIdParam.isEmpty() && !"null".equals(customerIdParam) && !"undefined".equals(customerIdParam)) {
                    try {
                        int customerId = Integer.parseInt(customerIdParam);
                        if (customerId > 0) {
                            workOrder.setCustomerId(customerId);
                        } else {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "ID khách hàng không hợp lệ");
                            out.print(jsonResponse.toString());
                            return;
                        }
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "ID khách hàng không hợp lệ: " + customerIdParam);
                        out.print(jsonResponse.toString());
                        return;
                    }
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin khách hàng. Không thể tạo work order.");
                    out.print(jsonResponse.toString());
                    return;
                }
                
                // Optional fields
                String contractIdParam = request.getParameter("contractId");
                if (contractIdParam != null && !contractIdParam.isEmpty() && !"null".equals(contractIdParam)) {
                    try {
                        workOrder.setContractId(Integer.parseInt(contractIdParam));
                    } catch (NumberFormatException e) {
                        // Ignore invalid contract ID
                    }
                }
                
                String priority = request.getParameter("priority");
                if (priority != null && !priority.isEmpty()) {
                    workOrder.setPriority(priority);
                } else {
                    workOrder.setPriority("medium");
                }
                
                String status = request.getParameter("status");
                if (status != null && !status.isEmpty()) {
                    workOrder.setStatus(status);
                } else {
                    workOrder.setStatus("in_progress");
                }
                
                String assignedToParam = request.getParameter("assignedTo");
                if (assignedToParam != null && !assignedToParam.isEmpty() && !"null".equals(assignedToParam)) {
                    try {
                        workOrder.setAssignedTo(Integer.parseInt(assignedToParam));
                    } catch (NumberFormatException e) {
                        // Ignore invalid assignedTo ID
                    }
                }
                
                String estimatedHoursParam = request.getParameter("estimatedHours");
                if (estimatedHoursParam != null && !estimatedHoursParam.isEmpty() && !"null".equals(estimatedHoursParam)) {
                    try {
                        workOrder.setEstimatedHours(new BigDecimal(estimatedHoursParam));
                    } catch (NumberFormatException e) {
                        // Ignore invalid estimated hours
                    }
                }
                
                String scheduledDateParam = request.getParameter("scheduledDate");
                if (scheduledDateParam != null && !scheduledDateParam.isEmpty() && !"null".equals(scheduledDateParam)) {
                    try {
                        workOrder.setScheduledDate(Date.valueOf(scheduledDateParam));
                    } catch (IllegalArgumentException e) {
                        // Ignore invalid date format
                    }
                }
                
                // Set created_by from session
                if (userId != null) {
                    workOrder.setCreatedBy(userId);
                }
                
                // Create work order
                WorkOrder created = workOrderDAO.createWorkOrder(workOrder);
                
                if (created != null) {
                    jsonResponse.addProperty("success", true);
                    jsonResponse.addProperty("message", "Tạo work order thành công");
                    jsonResponse.addProperty("workOrderNumber", created.getWorkOrderNumber());
                    jsonResponse.addProperty("id", created.getId());
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Lỗi tạo work order");
                }
                
            } else if ("update".equals(action)) {
                // Cập nhật work order
                String idParam = request.getParameter("id");
                if (idParam == null || idParam.isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu ID work order");
                } else {
                    try {
                        int id = Integer.parseInt(idParam);
                        WorkOrder workOrder = workOrderDAO.getWorkOrderById(id);
                        
                        if (workOrder == null) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Không tìm thấy work order");
                        } else {
                            // Update fields
                            String title = request.getParameter("title");
                            if (title != null && !title.trim().isEmpty()) {
                                workOrder.setTitle(title.trim());
                            }
                            
                            String description = request.getParameter("description");
                            if (description != null && !description.trim().isEmpty()) {
                                workOrder.setDescription(description.trim());
                            }
                            
                            String priority = request.getParameter("priority");
                            if (priority != null && !priority.isEmpty()) {
                                workOrder.setPriority(priority);
                            }
                            
                            String status = request.getParameter("status");
                            if (status != null && !status.isEmpty()) {
                                workOrder.setStatus(status);
                            }
                            
                            String assignedToParam = request.getParameter("assignedTo");
                            if (assignedToParam != null && !assignedToParam.isEmpty() && !"null".equals(assignedToParam)) {
                                try {
                                    workOrder.setAssignedTo(Integer.parseInt(assignedToParam));
                                } catch (NumberFormatException e) {
                                    workOrder.setAssignedTo(null);
                                }
                            } else {
                                workOrder.setAssignedTo(null);
                            }
                            
                            String estimatedHoursParam = request.getParameter("estimatedHours");
                            if (estimatedHoursParam != null && !estimatedHoursParam.isEmpty() && !"null".equals(estimatedHoursParam)) {
                                try {
                                    workOrder.setEstimatedHours(new BigDecimal(estimatedHoursParam));
                                } catch (NumberFormatException e) {
                                    workOrder.setEstimatedHours(null);
                                }
                            } else {
                                workOrder.setEstimatedHours(null);
                            }
                            
                            String actualHoursParam = request.getParameter("actualHours");
                            if (actualHoursParam != null && !actualHoursParam.isEmpty() && !"null".equals(actualHoursParam)) {
                                try {
                                    workOrder.setActualHours(new BigDecimal(actualHoursParam));
                                } catch (NumberFormatException e) {
                                    workOrder.setActualHours(null);
                                }
                            } else {
                                workOrder.setActualHours(null);
                            }
                            
                            String scheduledDateParam = request.getParameter("scheduledDate");
                            if (scheduledDateParam != null && !scheduledDateParam.isEmpty() && !"null".equals(scheduledDateParam)) {
                                try {
                                    workOrder.setScheduledDate(Date.valueOf(scheduledDateParam));
                                } catch (IllegalArgumentException e) {
                                    workOrder.setScheduledDate(null);
                                }
                            } else {
                                workOrder.setScheduledDate(null);
                            }
                            
                            String completionDateParam = request.getParameter("completionDate");
                            if (completionDateParam != null && !completionDateParam.isEmpty() && !"null".equals(completionDateParam)) {
                                try {
                                    workOrder.setCompletionDate(Date.valueOf(completionDateParam));
                                } catch (IllegalArgumentException e) {
                                    workOrder.setCompletionDate(null);
                                }
                            } else {
                                workOrder.setCompletionDate(null);
                            }
                            
                            boolean success = workOrderDAO.updateWorkOrder(workOrder);
                            
                            if (success) {
                                jsonResponse.addProperty("success", true);
                                jsonResponse.addProperty("message", "Cập nhật work order thành công");
                            } else {
                                jsonResponse.addProperty("success", false);
                                jsonResponse.addProperty("message", "Lỗi cập nhật work order");
                            }
                        }
                        
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "ID không hợp lệ");
                    }
                }
                
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Action không hợp lệ");
            }
            
        } catch (Exception e) {
            System.out.println("Error in WorkOrder POST: " + e.getMessage());
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Lỗi server: " + e.getMessage());
        }
        
        out.print(jsonResponse.toString());
        out.flush();
    }
}

