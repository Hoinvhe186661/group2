package com.hlgenerator.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.hlgenerator.dao.WorkOrderDAO;
import com.hlgenerator.dao.WorkOrderTaskDAO;
import com.hlgenerator.dao.SupportRequestDAO;
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
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/api/work-orders")
public class WorkOrderServlet extends HttpServlet {
    
    private WorkOrderDAO workOrderDAO;
    private WorkOrderTaskDAO taskDAO;
    private SupportRequestDAO supportDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        workOrderDAO = new WorkOrderDAO();
        taskDAO = new WorkOrderTaskDAO();
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
                
            } else if ("syncTicketStatus".equals(action)) {
                // Sync ticket status for all completed work orders
                syncCompletedWorkOrdersWithTickets(jsonResponse);
                
            } else if ("checkByTicket".equals(action)) {
                // Kiểm tra xem ticket đã có work order chưa
                String ticketIdParam = request.getParameter("ticketId");
                String titleParam = request.getParameter("title");
                String customerIdParam = request.getParameter("customerId");
                
                if (ticketIdParam == null || ticketIdParam.isEmpty() ||
                    titleParam == null || titleParam.trim().isEmpty() ||
                    customerIdParam == null || customerIdParam.isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin ticket");
                } else {
                    try {
                        int customerId = Integer.parseInt(customerIdParam);
                        WorkOrder existingWorkOrder = workOrderDAO.getWorkOrderByTicketInfo(titleParam.trim(), customerId);
                        
                        if (existingWorkOrder != null) {
                            jsonResponse.addProperty("success", true);
                            jsonResponse.addProperty("exists", true);
                            jsonResponse.addProperty("workOrderNumber", existingWorkOrder.getWorkOrderNumber());
                            jsonResponse.addProperty("workOrderId", existingWorkOrder.getId());
                        } else {
                            jsonResponse.addProperty("success", true);
                            jsonResponse.addProperty("exists", false);
                        }
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "ID khách hàng không hợp lệ");
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
                String ticketIdParam = request.getParameter("ticketId");
                
                if (title == null || title.trim().isEmpty() || 
                    description == null || description.trim().isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin bắt buộc (tiêu đề, mô tả)");
                    out.print(jsonResponse.toString());
                    return;
                }
                
                // Validate: Check if ticket already has a work order
                if (ticketIdParam != null && !ticketIdParam.isEmpty() && !"null".equals(ticketIdParam) && !"undefined".equals(ticketIdParam)) {
                    try {
                        int customerId = Integer.parseInt(customerIdParam);
                        if (customerId > 0) {
                            // Check if work order already exists for this ticket
                            WorkOrder existingWorkOrder = workOrderDAO.getWorkOrderByTicketInfo(title.trim(), customerId);
                            if (existingWorkOrder != null) {
                                jsonResponse.addProperty("success", false);
                                jsonResponse.addProperty("message", "Ticket này đã có work order. Mã work order: " + existingWorkOrder.getWorkOrderNumber());
                                jsonResponse.addProperty("existingWorkOrderId", existingWorkOrder.getId());
                                jsonResponse.addProperty("existingWorkOrderNumber", existingWorkOrder.getWorkOrderNumber());
                                out.print(jsonResponse.toString());
                                return;
                            }
                        }
                    } catch (NumberFormatException e) {
                        // Continue if customerId is invalid, will be caught later
                    }
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
                
                // Store ticketId in description for later reference (format: ...description...\n\n[TICKET_ID:123])
                // This is CRITICAL for linking work order back to ticket when closing
                if (ticketIdParam != null && !ticketIdParam.isEmpty() && !"null".equals(ticketIdParam) && !"undefined".equals(ticketIdParam)) {
                    try {
                        int ticketId = Integer.parseInt(ticketIdParam);
                        // Append ticket ID to description in a parseable format
                        String currentDescription = workOrder.getDescription() != null ? workOrder.getDescription() : "";
                        if (!currentDescription.contains("[TICKET_ID:")) {
                            // Always append ticket ID, even if description is empty
                            String newDescription = currentDescription.isEmpty() 
                                ? "[TICKET_ID:" + ticketId + "]" 
                                : currentDescription + "\n\n[TICKET_ID:" + ticketId + "]";
                            workOrder.setDescription(newDescription);
                            System.out.println("✓ Stored ticket ID " + ticketId + " in work order description");
                        } else {
                            System.out.println("⚠ Ticket ID already exists in work order description");
                        }
                    } catch (NumberFormatException e) {
                        System.out.println("✗ Invalid ticket ID format: " + ticketIdParam);
                    }
                } else {
                    System.out.println("⚠ WARNING: No ticket ID provided when creating work order. Ticket status may not update automatically when closing work order.");
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
                
            } else if ("close".equals(action)) {
                // Đóng work order (chỉ cho phép khi không còn tasks đang thực hiện)
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
                            // Check if work order is already closed/completed
                            if ("completed".equals(workOrder.getStatus()) || "cancelled".equals(workOrder.getStatus())) {
                                jsonResponse.addProperty("success", false);
                                jsonResponse.addProperty("message", "Đơn hàng này đã được đóng hoặc hủy rồi");
                            } else {
                                // Validate: Check if there are active tasks (in_progress only)
                                boolean hasActiveTasks = taskDAO.hasActiveTasks(id);
                                if (hasActiveTasks) {
                                    int activeTaskCount = taskDAO.getActiveTaskCount(id);
                                    jsonResponse.addProperty("success", false);
                                    jsonResponse.addProperty("message", "Không thể đóng đơn hàng. Vẫn còn " + activeTaskCount + " nhiệm vụ đang thực hiện (in_progress). Vui lòng hoàn thành tất cả nhiệm vụ đang thực hiện trước khi đóng.");
                                    jsonResponse.addProperty("activeTaskCount", activeTaskCount);
                                } else {
                                    // Close work order - set status to completed
                                    workOrder.setStatus("completed");
                                    
                                    // Set completion date if not already set
                                    if (workOrder.getCompletionDate() == null) {
                                        workOrder.setCompletionDate(new Date(System.currentTimeMillis()));
                                    }
                                    
                                    boolean success = workOrderDAO.updateWorkOrder(workOrder);
                                    
                                    if (success) {
                                        // Update ticket status to resolved when work order is closed
                                        updateTicketStatusWhenClosingWorkOrder(workOrder);
                                        
                                        jsonResponse.addProperty("success", true);
                                        jsonResponse.addProperty("message", "Đóng đơn hàng thành công");
                                    } else {
                                        jsonResponse.addProperty("success", false);
                                        jsonResponse.addProperty("message", "Lỗi đóng đơn hàng");
                                    }
                                }
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
    
    /**
     * Update ticket status to resolved when work order is closed
     * Finds ticket by:
     * 1. Parsing ticket ID from description (format: [TICKET_ID:123]) - MOST RELIABLE
     * 2. If not found, matching work order title with ticket subject and customer_id
     * 3. If still not found, try to find any technical ticket for this customer that is not resolved
     */
    private void updateTicketStatusWhenClosingWorkOrder(WorkOrder workOrder) {
        try {
            System.out.println("========================================");
            System.out.println("=== UPDATING TICKET STATUS WHEN CLOSING WORK ORDER ===");
            System.out.println("Work Order ID: " + workOrder.getId());
            System.out.println("Work Order Number: " + workOrder.getWorkOrderNumber());
            System.out.println("Work Order Title: [" + workOrder.getTitle() + "]");
            System.out.println("Work Order Customer ID: " + workOrder.getCustomerId());
            System.out.println("Work Order Description: " + (workOrder.getDescription() != null ? 
                (workOrder.getDescription().length() > 200 ? workOrder.getDescription().substring(0, 200) + "..." : workOrder.getDescription()) 
                : "null"));
            
            Map<String, Object> ticket = null;
            Integer ticketIdFromDescription = null;
            String methodUsed = "";
            
            // Method 1: Try to extract ticket ID from description (MOST RELIABLE)
            if (workOrder.getDescription() != null && workOrder.getDescription().contains("[TICKET_ID:")) {
                try {
                    String desc = workOrder.getDescription();
                    int startIdx = desc.indexOf("[TICKET_ID:") + 11;
                    int endIdx = desc.indexOf("]", startIdx);
                    if (endIdx > startIdx) {
                        String ticketIdStr = desc.substring(startIdx, endIdx).trim();
                        ticketIdFromDescription = Integer.parseInt(ticketIdStr);
                        System.out.println("✓ Found ticket ID in description: " + ticketIdFromDescription);
                        
                        // Get ticket by ID
                        ticket = supportDAO.getSupportRequestById(ticketIdFromDescription);
                        if (ticket != null) {
                            methodUsed = "ticket_id_from_description";
                            System.out.println("✓ SUCCESS: Found ticket by ID from description: " + ticket.get("ticketNumber"));
                        } else {
                            System.out.println("✗ Ticket ID " + ticketIdFromDescription + " not found in database");
                        }
                    }
                } catch (Exception e) {
                    System.out.println("✗ Error parsing ticket ID from description: " + e.getMessage());
                    e.printStackTrace();
                }
            } else {
                System.out.println("⚠ No [TICKET_ID:xxx] found in work order description");
            }
            
            // Method 2: If ticket ID not found in description, try matching by title and customer_id
            String titleToSearch = workOrder.getTitle() != null ? workOrder.getTitle().trim() : "";
            if (ticket == null && titleToSearch != null && !titleToSearch.isEmpty() && workOrder.getCustomerId() > 0) {
                System.out.println("Trying Method 2: Match by title and customer_id...");
                System.out.println("  Searching for ticket with:");
                System.out.println("    Subject: [" + titleToSearch + "]");
                System.out.println("    Customer ID: " + workOrder.getCustomerId());
                
                ticket = supportDAO.getSupportRequestBySubjectAndCustomer(
                    titleToSearch, 
                    workOrder.getCustomerId()
                );
                
                if (ticket != null) {
                    methodUsed = "title_and_customer_match";
                    System.out.println("✓ SUCCESS: Found ticket by title and customer match");
                } else {
                    System.out.println("✗ No ticket found with matching title and customer_id");
                }
            }
            
            // Method 3: Last resort - find any technical ticket for this customer that is not resolved
            // This fallback is already handled in getSupportRequestBySubjectAndCustomer method
            if (ticket == null && workOrder.getCustomerId() > 0) {
                System.out.println("⚠ Method 3: Fallback already handled in getSupportRequestBySubjectAndCustomer");
                System.out.println("   It will try to find any technical ticket for customer " + workOrder.getCustomerId() + " that is not resolved");
            }
            
            if (ticket != null) {
                Integer ticketId = (Integer) ticket.get("id");
                String currentStatus = (String) ticket.get("status");
                String ticketSubject = (String) ticket.get("subject");
                String ticketNumber = (String) ticket.get("ticketNumber");
                
                System.out.println("\n--- FOUND TICKET ---");
                System.out.println("  Ticket ID: " + ticketId);
                System.out.println("  Ticket Number: " + ticketNumber);
                System.out.println("  Ticket Subject: [" + ticketSubject + "]");
                System.out.println("  Ticket Current Status: " + currentStatus);
                System.out.println("  Found using method: " + methodUsed);
                
                // Only update if ticket is not already resolved/closed
                if (ticketId != null && !"resolved".equals(currentStatus) && !"closed".equals(currentStatus)) {
                    System.out.println("\n--- UPDATING TICKET STATUS ---");
                    System.out.println("  From: '" + currentStatus + "'");
                    System.out.println("  To: 'resolved'");
                    
                    // Update ticket status to resolved
                    boolean updated = supportDAO.updateSupportRequest(
                        ticketId, 
                        null, // category - don't change
                        null, // priority - don't change
                        "resolved", // status
                        "Đơn hàng công việc đã hoàn thành: " + workOrder.getWorkOrderNumber(), // resolution
                        null,  // internalNotes - don't change
                        null   // assignedTo - don't change
                    );
                    
                    if (updated) {
                        System.out.println("✓✓✓ SUCCESS: Updated ticket " + ticketId + " (" + ticketNumber + ") status to 'resolved'");
                        System.out.println("   Work Order: " + workOrder.getWorkOrderNumber());
                        System.out.println("   Resolution: Đơn hàng công việc đã hoàn thành: " + workOrder.getWorkOrderNumber());
                    } else {
                        System.out.println("✗✗✗ FAILED: Failed to update ticket " + ticketId + " status");
                        System.out.println("   Error: " + supportDAO.getLastError());
                    }
                } else if (ticketId != null) {
                    System.out.println("⚠ Ticket " + ticketId + " is already resolved/closed (status: " + currentStatus + "), skipping update");
                }
            } else {
                System.out.println("\n✗✗✗ NO TICKET FOUND FOR WORK ORDER");
                System.out.println("  Work Order: " + workOrder.getWorkOrderNumber());
                System.out.println("  Title: [" + titleToSearch + "]");
                System.out.println("  Customer ID: " + workOrder.getCustomerId());
                System.out.println("  Description contains [TICKET_ID:]: " + 
                    (workOrder.getDescription() != null && workOrder.getDescription().contains("[TICKET_ID:")));
                
                System.out.println("\n  Possible reasons:");
                System.out.println("  1. Ticket ID was not stored in work order description when creating work order");
                System.out.println("  2. Ticket subject does not match work order title exactly");
                System.out.println("  3. Ticket customer_id does not match work order customer_id");
                System.out.println("  4. Ticket has already been resolved/closed");
                System.out.println("  5. Ticket was deleted or does not exist");
            }
            
            System.out.println("========================================");
            System.out.println("=== END TICKET STATUS UPDATE ===");
            System.out.println("========================================\n");
            
        } catch (Exception e) {
            System.out.println("✗✗✗ CRITICAL ERROR: Error updating ticket status when closing work order");
            System.out.println("   Error: " + e.getMessage());
            e.printStackTrace();
            // Don't throw exception - ticket update failure shouldn't prevent work order from closing
        }
    }
    
    /**
     * Sync ticket status for all completed work orders that haven't been synced yet
     * This is useful for fixing tickets that weren't updated when work order was closed
     */
    private void syncCompletedWorkOrdersWithTickets(JsonObject jsonResponse) {
        try {
            System.out.println("========================================");
            System.out.println("=== SYNCING TICKET STATUS FOR COMPLETED WORK ORDERS ===");
            
            // Get all completed work orders
            List<WorkOrder> allWorkOrders = workOrderDAO.getAllWorkOrders();
            List<WorkOrder> completedWorkOrders = new ArrayList<>();
            
            for (WorkOrder wo : allWorkOrders) {
                if ("completed".equals(wo.getStatus())) {
                    completedWorkOrders.add(wo);
                }
            }
            
            System.out.println("Found " + completedWorkOrders.size() + " completed work orders");
            
            int syncedCount = 0;
            int failedCount = 0;
            int alreadyResolvedCount = 0;
            
            for (WorkOrder workOrder : completedWorkOrders) {
                System.out.println("\n--- Processing Work Order: " + workOrder.getWorkOrderNumber() + " ---");
                
                // Try to find associated ticket
                Map<String, Object> ticket = null;
                Integer ticketId = null;
                
                // Method 1: Extract ticket ID from description
                if (workOrder.getDescription() != null && workOrder.getDescription().contains("[TICKET_ID:")) {
                    try {
                        String desc = workOrder.getDescription();
                        int startIdx = desc.indexOf("[TICKET_ID:") + 11;
                        int endIdx = desc.indexOf("]", startIdx);
                        if (endIdx > startIdx) {
                            String ticketIdStr = desc.substring(startIdx, endIdx).trim();
                            ticketId = Integer.parseInt(ticketIdStr);
                            ticket = supportDAO.getSupportRequestById(ticketId);
                        }
                    } catch (Exception e) {
                        System.out.println("Error parsing ticket ID: " + e.getMessage());
                    }
                }
                
                // Method 2: Match by title and customer_id
                if (ticket == null && workOrder.getTitle() != null && workOrder.getCustomerId() > 0) {
                    ticket = supportDAO.getSupportRequestBySubjectAndCustomer(
                        workOrder.getTitle().trim(), 
                        workOrder.getCustomerId()
                    );
                }
                
                if (ticket != null) {
                    ticketId = (Integer) ticket.get("id");
                    String currentStatus = (String) ticket.get("status");
                    String ticketNumber = (String) ticket.get("ticketNumber");
                    
                    System.out.println("  Found ticket: " + ticketNumber + " (ID: " + ticketId + ")");
                    System.out.println("  Current status: " + currentStatus);
                    
                    // Only update if not already resolved/closed
                    if (!"resolved".equals(currentStatus) && !"closed".equals(currentStatus)) {
                        boolean updated = supportDAO.updateSupportRequest(
                            ticketId,
                            null, null,
                            "resolved",
                            "Đơn hàng công việc đã hoàn thành: " + workOrder.getWorkOrderNumber(),
                            null, null
                        );
                        
                        if (updated) {
                            System.out.println("  ✓ Updated ticket " + ticketId + " status to 'resolved'");
                            syncedCount++;
                        } else {
                            System.out.println("  ✗ Failed to update ticket " + ticketId + ": " + supportDAO.getLastError());
                            failedCount++;
                        }
                    } else {
                        System.out.println("  ⚠ Ticket already resolved/closed, skipping");
                        alreadyResolvedCount++;
                    }
                } else {
                    System.out.println("  ✗ No ticket found for work order " + workOrder.getWorkOrderNumber());
                    failedCount++;
                }
            }
            
            System.out.println("\n=== SYNC SUMMARY ===");
            System.out.println("  Total completed work orders: " + completedWorkOrders.size());
            System.out.println("  Successfully synced: " + syncedCount);
            System.out.println("  Already resolved: " + alreadyResolvedCount);
            System.out.println("  Failed/Not found: " + failedCount);
            System.out.println("========================================\n");
            
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("message", "Đã đồng bộ " + syncedCount + " ticket(s)");
            jsonResponse.addProperty("syncedCount", syncedCount);
            jsonResponse.addProperty("alreadyResolvedCount", alreadyResolvedCount);
            jsonResponse.addProperty("failedCount", failedCount);
            
        } catch (Exception e) {
            System.out.println("✗✗✗ CRITICAL ERROR in syncCompletedWorkOrdersWithTickets: " + e.getMessage());
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Lỗi khi đồng bộ: " + e.getMessage());
        }
    }
}

