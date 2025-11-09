package com.hlgenerator.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.hlgenerator.dao.WorkOrderTaskDAO;
import com.hlgenerator.dao.WorkOrderDAO;
import com.hlgenerator.model.WorkOrderTask;
import com.hlgenerator.model.WorkOrderTaskAssignment;
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
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

/**
 * Servlet for handling Work Order Task operations
 * API endpoints:
 * - GET  /api/work-order-tasks?action=list&workOrderId=...
 * - POST /api/work-order-tasks?action=create
 * - POST /api/work-order-tasks?action=update
 * - POST /api/work-order-tasks?action=delete
 * - POST /api/work-order-tasks?action=assign
 * - POST /api/work-order-tasks?action=removeAssignment
 */
@WebServlet("/api/work-order-tasks")
public class WorkOrderTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger(WorkOrderTaskServlet.class.getName());
    
    private WorkOrderTaskDAO taskDAO;
    private WorkOrderDAO workOrderDAO;
    private com.hlgenerator.dao.UserDAO userDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        super.init();
        taskDAO = new WorkOrderTaskDAO();
        workOrderDAO = new WorkOrderDAO();
        userDAO = new com.hlgenerator.dao.UserDAO();
        gson = new Gson();
        logger.info("WorkOrderTaskServlet initialized successfully");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
            String action = request.getParameter("action");
            
            if ("list".equals(action)) {
                handleListTasks(request, response);
            } else if ("assignments".equals(action)) {
                handleListAssignments(request, response);
            } else if ("activeTaskCount".equals(action)) {
                handleGetActiveTaskCount(request, response);
            } else if ("fixAssignments".equals(action)) {
                handleFixTaskAssignments(request, response);
            } else if ("getAvailableUsers".equals(action)) {
                handleGetAvailableUsersForAssignment(request, response);
            } else {
                sendError(response, "Invalid action");
            }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        if ("create".equals(action)) {
            handleCreateTask(request, response);
        } else if ("update".equals(action)) {
            handleUpdateTask(request, response);
        } else if ("delete".equals(action)) {
            handleDeleteTask(request, response);
        } else if ("assign".equals(action)) {
            handleAssignTask(request, response);
        } else if ("removeAssignment".equals(action)) {
            handleRemoveAssignment(request, response);
        } else {
            sendError(response, "Invalid action");
        }
    }

    private void handleListTasks(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String workOrderIdParam = request.getParameter("workOrderId");
        String priority = request.getParameter("priority");
        String status = request.getParameter("status");
        
        try {
            if (workOrderIdParam == null || workOrderIdParam.isEmpty()) {
                sendError(response, "Work order ID is required");
                return;
            }
            
            int workOrderId = Integer.parseInt(workOrderIdParam);
            
            // Get filtered tasks by priority and status
            List<WorkOrderTask> tasks = taskDAO.getTasksByWorkOrderId(workOrderId, priority, status);
            
            JsonObject result = new JsonObject();
            result.addProperty("success", true);
            result.add("data", gson.toJsonTree(tasks));
            
            sendJson(response, result);
            
        } catch (NumberFormatException e) {
            sendError(response, "Invalid work order ID");
        } catch (Exception e) {
            logger.severe("Error listing tasks: " + e.getMessage());
            sendError(response, "Error listing tasks: " + e.getMessage());
        }
    }

    private void handleListAssignments(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String taskIdParam = request.getParameter("taskId");
        
        try {
            if (taskIdParam == null || taskIdParam.isEmpty()) {
                sendError(response, "Task ID is required");
                return;
            }
            
            int taskId = Integer.parseInt(taskIdParam);
            List<WorkOrderTaskAssignment> assignments = taskDAO.getTaskAssignments(taskId);
            
            JsonObject result = new JsonObject();
            result.addProperty("success", true);
            result.add("data", gson.toJsonTree(assignments));
            
            sendJson(response, result);
            
        } catch (NumberFormatException e) {
            sendError(response, "Invalid task ID");
        } catch (Exception e) {
            logger.severe("Error listing assignments: " + e.getMessage());
            sendError(response, "Error listing assignments: " + e.getMessage());
        }
    }

    private void handleGetActiveTaskCount(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String userIdParam = request.getParameter("userId");
        
        try {
            if (userIdParam == null || userIdParam.isEmpty()) {
                sendError(response, "User ID is required");
                return;
            }
            
            int userId = Integer.parseInt(userIdParam);
            int activeTaskCount = taskDAO.getActiveTaskCountForUser(userId);
            
            JsonObject result = new JsonObject();
            result.addProperty("success", true);
            result.addProperty("count", activeTaskCount);
            
            sendJson(response, result);
            
        } catch (NumberFormatException e) {
            sendError(response, "Invalid user ID");
        } catch (Exception e) {
            logger.severe("Error getting active task count: " + e.getMessage());
            sendError(response, "Error getting active task count: " + e.getMessage());
        }
    }

    private void handleCreateTask(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                sendError(response, "Unauthorized: Please login");
                return;
            }
            
            String workOrderIdParam = request.getParameter("workOrderId");
            String taskDescription = request.getParameter("taskDescription");
            String priority = request.getParameter("priority");
            String estimatedHoursParam = request.getParameter("estimatedHours");
            String notes = request.getParameter("notes");
            String assignToUserIdParam = request.getParameter("assignToUserId"); // User ID để tự động assign
            String startDateParam = request.getParameter("startDate");
            String deadlineParam = request.getParameter("deadline");
            
            if (workOrderIdParam == null || workOrderIdParam.isEmpty()) {
                sendError(response, "Work order ID is required");
                return;
            }
            
            if (taskDescription == null || taskDescription.trim().isEmpty()) {
                sendError(response, "Task description is required");
                return;
            }
            
            String trimmedDescription = taskDescription.trim();
            if (trimmedDescription.length() > 150) {
                sendError(response, "Mô tả công việc không được vượt quá 150 ký tự. Hiện tại: " + trimmedDescription.length() + " ký tự");
                return;
            }
            
            int workOrderId = Integer.parseInt(workOrderIdParam);
            
            // Check if work order is completed or cancelled - cannot create tasks for closed work orders
            WorkOrder workOrder = workOrderDAO.getWorkOrderById(workOrderId);
            if (workOrder == null) {
                sendError(response, "Work order not found");
                return;
            }
            
            String workOrderStatus = workOrder.getStatus();
            if ("completed".equals(workOrderStatus) || "cancelled".equals(workOrderStatus) || "rejected".equals(workOrderStatus)) {
                String statusText = "";
                if ("completed".equals(workOrderStatus)) {
                    statusText = "Đã hoàn thành";
                } else if ("cancelled".equals(workOrderStatus)) {
                    statusText = "Đã hủy";
                } else if ("rejected".equals(workOrderStatus)) {
                    statusText = "Đã từ chối";
                }
                String actionText = "";
                if ("completed".equals(workOrderStatus)) {
                    actionText = "hoàn thành";
                } else if ("cancelled".equals(workOrderStatus)) {
                    actionText = "hủy";
                } else if ("rejected".equals(workOrderStatus)) {
                    actionText = "từ chối";
                }
                sendError(response, "Không thể tạo công việc mới cho đơn hàng đã " + actionText + ". Trạng thái đơn hàng: " + statusText);
                return;
            }
            
            // Nếu có assignToUserId, kiểm tra duplicate với user đó
            // Nếu không có assignToUserId, kiểm tra duplicate chung
            Integer assignToUserId = null;
            if (assignToUserIdParam != null && !assignToUserIdParam.isEmpty() && !"null".equals(assignToUserIdParam)) {
                try {
                    assignToUserId = Integer.parseInt(assignToUserIdParam);
                    
                    // Kiểm tra duplicate task với cùng description và user
                    if (taskDAO.hasDuplicateActiveTaskWithUser(workOrderId, trimmedDescription, assignToUserId)) {
                        String duplicateStatus = taskDAO.getDuplicateTaskStatusWithUser(workOrderId, trimmedDescription, assignToUserId);
                        String errorMessage;
                        if ("pending".equals(duplicateStatus)) {
                            errorMessage = "Công việc này với cùng mô tả và cùng nhân viên đã tồn tại và đang chờ xác nhận. Vui lòng kiểm tra lại danh sách công việc.";
                        } else if ("in_progress".equals(duplicateStatus)) {
                            errorMessage = "Công việc này với cùng mô tả và cùng nhân viên đã tồn tại và đang được thực hiện. Vui lòng kiểm tra lại danh sách công việc.";
                        } else {
                            errorMessage = "Công việc này với cùng mô tả và cùng nhân viên đã tồn tại. Vui lòng kiểm tra lại danh sách công việc.";
                        }
                        sendError(response, errorMessage);
                        return;
                    }
                } catch (NumberFormatException e) {
                    // Invalid user ID, ignore and continue without auto-assign
                    assignToUserId = null;
                }
            } else {
                // Không có assignToUserId, kiểm tra duplicate chung
                if (taskDAO.hasDuplicateActiveTask(workOrderId, trimmedDescription)) {
                    String duplicateStatus = taskDAO.getDuplicateTaskStatus(workOrderId, trimmedDescription);
                    String errorMessage;
                    if ("pending".equals(duplicateStatus)) {
                        errorMessage = "Công việc này đã tồn tại và đang chờ xác nhận. Vui lòng kiểm tra lại danh sách công việc.";
                    } else if ("in_progress".equals(duplicateStatus)) {
                        errorMessage = "Công việc này đã tồn tại và đang được thực hiện. Vui lòng kiểm tra lại danh sách công việc.";
                    } else {
                        errorMessage = "Công việc này đã tồn tại. Vui lòng kiểm tra lại danh sách công việc.";
                    }
                    sendError(response, errorMessage);
                    return;
                }
            }
            
            // Parse dates if provided
            java.sql.Timestamp startDate = null;
            java.sql.Timestamp deadline = null;
            try {
                if (startDateParam != null && !startDateParam.isEmpty() && !"null".equals(startDateParam)) {
                    // Parse date string (YYYY-MM-DD) to Timestamp
                    java.sql.Date date = java.sql.Date.valueOf(startDateParam);
                    startDate = new java.sql.Timestamp(date.getTime());
                }
                if (deadlineParam != null && !deadlineParam.isEmpty() && !"null".equals(deadlineParam)) {
                    // Parse date string (YYYY-MM-DD) to Timestamp
                    java.sql.Date date = java.sql.Date.valueOf(deadlineParam);
                    deadline = new java.sql.Timestamp(date.getTime());
                }
            } catch (IllegalArgumentException e) {
                sendError(response, "Invalid date format. Please use YYYY-MM-DD format.");
                return;
            }
            
            WorkOrderTask task = new WorkOrderTask();
            task.setWorkOrderId(workOrderId);
            task.setTaskDescription(trimmedDescription);
            task.setPriority(priority != null ? priority : "medium");
            task.setStatus("pending");
            task.setStartDate(startDate);
            task.setDeadline(deadline);
            
            if (estimatedHoursParam != null && !estimatedHoursParam.isEmpty()) {
                try {
                    BigDecimal estimatedHours = new BigDecimal(estimatedHoursParam);
                    // Validate: tối thiểu > 0, không cho phép số âm
                    if (estimatedHours.compareTo(BigDecimal.ZERO) <= 0) {
                        sendError(response, "Giờ ước tính phải lớn hơn 0");
                        return;
                    }
                    
                    // Kiểm tra tổng giờ ước tính của tất cả tasks (bao gồm task mới) không được vượt quá giờ ước tính của work order
                    BigDecimal workOrderEstimatedHours = workOrder.getEstimatedHours();
                    if (workOrderEstimatedHours != null && workOrderEstimatedHours.compareTo(BigDecimal.ZERO) > 0) {
                        // Work order có giờ ước tính, cần kiểm tra tổng
                        // Tính tổng giờ ước tính của các tasks hiện tại
                        BigDecimal totalEstimatedHours = taskDAO.getTotalEstimatedHoursForWorkOrder(workOrderId);
                        // Cộng thêm giờ ước tính của task mới
                        BigDecimal newTotalEstimatedHours = totalEstimatedHours.add(estimatedHours);
                        
                        // Kiểm tra tổng không được vượt quá giờ ước tính của work order
                        if (newTotalEstimatedHours.compareTo(workOrderEstimatedHours) > 0) {
                            BigDecimal remainingHours = workOrderEstimatedHours.subtract(totalEstimatedHours);
                            if (remainingHours.compareTo(BigDecimal.ZERO) <= 0) {
                                sendError(response, "Không thể tạo công việc mới. Tổng giờ ước tính của các công việc hiện tại (" + 
                                    totalEstimatedHours + "h) đã đạt hoặc vượt quá giờ ước tính của đơn hàng (" + workOrderEstimatedHours + "h).");
                            } else {
                                sendError(response, "Không thể tạo công việc mới. Nếu tạo công việc này (" + estimatedHours + 
                                    "h), tổng giờ ước tính sẽ là " + newTotalEstimatedHours + "h, vượt quá giờ ước tính của đơn hàng (" + 
                                    workOrderEstimatedHours + "h). Còn lại: " + remainingHours + "h.");
                            }
                            return;
                        }
                    } else {
                        // Work order không có giờ ước tính, kiểm tra max 100
                        if (estimatedHours.compareTo(new BigDecimal("100")) > 0) {
                            sendError(response, "Giờ ước tính không được vượt quá 100 giờ");
                            return;
                        }
                    }
                    
                    task.setEstimatedHours(estimatedHours);
                } catch (NumberFormatException e) {
                    sendError(response, "Giờ ước tính không hợp lệ: " + estimatedHoursParam);
                    return;
                }
            }
            
            if (notes != null && !notes.trim().isEmpty()) {
                task.setNotes(notes.trim());
            }
            
            int createdTaskId = taskDAO.createTask(task);
            
            if (createdTaskId > 0) {
                // Nếu có assignToUserId, tự động assign task cho user đó
                boolean assignmentSuccess = false;
                String assignmentMessage = "";
                int finalTaskId = createdTaskId; // Task ID cuối cùng (có thể là task mới hoặc task gốc)
                
                if (assignToUserId != null && assignToUserId > 0) {
                    try {
                        // Task mới vừa tạo, chưa có assignment, nên assign trực tiếp
                        // Đảm bảo role='assignee' để nhân viên kỹ thuật nhận được task
                        boolean directAssignSuccess = taskDAO.assignTaskDirectly(createdTaskId, assignToUserId, "assignee");
                        
                        if (directAssignSuccess) {
                            assignmentSuccess = true;
                            finalTaskId = createdTaskId; // Sử dụng task gốc vì đã assign thành công
                            // Lấy task_number từ task vừa tạo
                            WorkOrderTask assignedTask = taskDAO.getTaskById(createdTaskId);
                            String taskNumber = (assignedTask != null && assignedTask.getTaskNumber() != null) ? 
                                assignedTask.getTaskNumber() : "N/A";
                            assignmentMessage = " Đã tự động phân công cho nhân viên kỹ thuật với mã task " + taskNumber + ".";
                        } else {
                            // Nếu direct assign thất bại, thử dùng assignTaskToUser (có thể tạo task mới)
                            int assignedTaskId = taskDAO.assignTaskToUser(createdTaskId, assignToUserId, "assignee");
                            
                            if (assignedTaskId > 0) {
                                assignmentSuccess = true;
                                finalTaskId = assignedTaskId;
                                if (assignedTaskId != createdTaskId) {
                                    // Một task mới được tạo (task đã có assignment)
                                    assignmentMessage = " Đã tạo task mới và phân công cho nhân viên.";
                                } else {
                                    // Task hiện tại được assign
                                    assignmentMessage = " Đã tự động phân công cho nhân viên.";
                                }
                            } else {
                                assignmentMessage = " Task đã được tạo nhưng phân công thất bại. Vui lòng phân công thủ công.";
                            }
                        }
                    } catch (Exception e) {
                        logger.warning("Error auto-assigning task " + createdTaskId + " to user " + assignToUserId + ": " + e.getMessage());
                        assignmentMessage = " Task đã được tạo nhưng phân công thất bại: " + e.getMessage() + ". Vui lòng phân công thủ công.";
                    }
                }
                
                // Get the final task with full details (có thể là task gốc hoặc task mới)
                WorkOrderTask finalTask = taskDAO.getTaskById(finalTaskId);
                JsonObject result = new JsonObject();
                result.addProperty("success", true);
                result.addProperty("message", "Tạo công việc thành công." + assignmentMessage);
                result.add("data", gson.toJsonTree(finalTask));
                result.addProperty("assigned", assignmentSuccess);
                if (assignmentSuccess && assignToUserId != null) {
                    result.addProperty("assignedToUserId", assignToUserId);
                }
                sendJson(response, result);
            } else {
                sendError(response, "Failed to create task");
            }
            
        } catch (NumberFormatException e) {
            sendError(response, "Invalid work order ID");
        } catch (Exception e) {
            logger.severe("Error creating task: " + e.getMessage());
            sendError(response, "Error creating task: " + e.getMessage());
        }
    }

    private void handleUpdateTask(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                sendError(response, "Unauthorized: Please login");
                return;
            }
            
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                sendError(response, "Task ID is required");
                return;
            }
            
            int id = Integer.parseInt(idParam);
            WorkOrderTask task = taskDAO.getTaskById(id);
            
            if (task == null) {
                sendError(response, "Task not found");
                return;
            }
            
            String taskDescription = request.getParameter("taskDescription");
            if (taskDescription != null && !taskDescription.trim().isEmpty()) {
                String trimmedDescription = taskDescription.trim();
                if (trimmedDescription.length() > 150) {
                    sendError(response, "Mô tả công việc không được vượt quá 150 ký tự. Hiện tại: " + trimmedDescription.length() + " ký tự");
                    return;
                }
                task.setTaskDescription(trimmedDescription);
            }
            
            String status = request.getParameter("status");
            if (status != null) {
                task.setStatus(status);
            }
            
            String priority = request.getParameter("priority");
            if (priority != null) {
                task.setPriority(priority);
            }
            
            String estimatedHoursParam = request.getParameter("estimatedHours");
            if (estimatedHoursParam != null && !estimatedHoursParam.isEmpty()) {
                try {
                    BigDecimal estimatedHours = new BigDecimal(estimatedHoursParam);
                    // Validate: tối thiểu > 0, không cho phép số âm
                    if (estimatedHours.compareTo(BigDecimal.ZERO) <= 0) {
                        sendError(response, "Giờ ước tính phải lớn hơn 0");
                        return;
                    }
                    
                    // Lấy work order để kiểm tra giờ ước tính
                    WorkOrder workOrder = workOrderDAO.getWorkOrderById(task.getWorkOrderId());
                    if (workOrder != null) {
                        BigDecimal workOrderEstimatedHours = workOrder.getEstimatedHours();
                        if (workOrderEstimatedHours != null && workOrderEstimatedHours.compareTo(BigDecimal.ZERO) > 0) {
                            // Work order có giờ ước tính, cần kiểm tra tổng
                            // Tính tổng giờ ước tính của các tasks hiện tại (trừ task đang được update và các task rejected)
                            // Sử dụng method riêng để exclude task đang update và các task rejected
                            BigDecimal totalEstimatedHours = taskDAO.getTotalEstimatedHoursForWorkOrderExcludingTask(
                                task.getWorkOrderId(), task.getId());
                            // Cộng thêm giờ ước tính mới của task
                            BigDecimal newTotalEstimatedHours = totalEstimatedHours.add(estimatedHours);
                            
                            // Kiểm tra tổng không được vượt quá giờ ước tính của work order
                            if (newTotalEstimatedHours.compareTo(workOrderEstimatedHours) > 0) {
                                BigDecimal remainingHours = workOrderEstimatedHours.subtract(totalEstimatedHours);
                                if (remainingHours.compareTo(BigDecimal.ZERO) <= 0) {
                                    sendError(response, "Không thể cập nhật công việc. Tổng giờ ước tính của các công việc khác (" + 
                                        totalEstimatedHours + "h) đã đạt hoặc vượt quá giờ ước tính của đơn hàng (" + workOrderEstimatedHours + "h).");
                                } else {
                                    sendError(response, "Không thể cập nhật công việc. Nếu cập nhật giờ ước tính thành " + estimatedHours + 
                                        "h, tổng giờ ước tính sẽ là " + newTotalEstimatedHours + "h, vượt quá giờ ước tính của đơn hàng (" + 
                                        workOrderEstimatedHours + "h). Còn lại: " + remainingHours + "h.");
                                }
                                return;
                            }
                        } else {
                            // Work order không có giờ ước tính, kiểm tra max 100
                            if (estimatedHours.compareTo(new BigDecimal("100")) > 0) {
                                sendError(response, "Giờ ước tính không được vượt quá 100 giờ");
                                return;
                            }
                        }
                    } else {
                        // Không tìm thấy work order, kiểm tra max 100
                        if (estimatedHours.compareTo(new BigDecimal("100")) > 0) {
                            sendError(response, "Giờ ước tính không được vượt quá 100 giờ");
                            return;
                        }
                    }
                    
                    task.setEstimatedHours(estimatedHours);
                } catch (NumberFormatException e) {
                    sendError(response, "Giờ ước tính không hợp lệ: " + estimatedHoursParam);
                    return;
                }
            }
            
            String actualHoursParam = request.getParameter("actualHours");
            if (actualHoursParam != null && !actualHoursParam.isEmpty()) {
                try {
                    task.setActualHours(new BigDecimal(actualHoursParam));
                } catch (NumberFormatException e) {
                    logger.warning("Invalid actual hours: " + actualHoursParam);
                }
            }
            
            String notes = request.getParameter("notes");
            if (notes != null) {
                task.setNotes(notes);
            }
            
            boolean success = taskDAO.updateTask(task);
            
            JsonObject result = new JsonObject();
            result.addProperty("success", success);
            if (success) {
                result.addProperty("message", "Task updated successfully");
            } else {
                result.addProperty("message", "Failed to update task");
            }
            sendJson(response, result);
            
        } catch (NumberFormatException e) {
            sendError(response, "Invalid task ID");
        } catch (Exception e) {
            logger.severe("Error updating task: " + e.getMessage());
            sendError(response, "Error updating task: " + e.getMessage());
        }
    }

    private void handleDeleteTask(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                sendError(response, "Unauthorized: Please login");
                return;
            }
            
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                sendError(response, "Task ID is required");
                return;
            }
            
            int id = Integer.parseInt(idParam);
            int resultCode = taskDAO.deleteTask(id);
            
            JsonObject result = new JsonObject();
            if (resultCode == -1) {
                // Task is completed, cannot delete
                result.addProperty("success", false);
                result.addProperty("message", "Không thể xóa nhiệm vụ đã hoàn thành");
            } else if (resultCode == 1) {
                // Successfully deleted
                result.addProperty("success", true);
                result.addProperty("message", "Xóa công việc thành công");
            } else {
                // Failed to delete
                result.addProperty("success", false);
                result.addProperty("message", "Không thể xóa công việc");
            }
            sendJson(response, result);
            
        } catch (NumberFormatException e) {
            sendError(response, "Invalid task ID");
        } catch (Exception e) {
            logger.severe("Error deleting task: " + e.getMessage());
            sendError(response, "Error deleting task: " + e.getMessage());
        }
    }

    private void handleAssignTask(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                sendError(response, "Unauthorized: Please login");
                return;
            }
            
            String taskIdParam = request.getParameter("taskId");
            String userIdParam = request.getParameter("userId");
            String role = request.getParameter("role");
            String startDateParam = request.getParameter("startDate");
            String deadlineParam = request.getParameter("deadline");
            
            if (taskIdParam == null || taskIdParam.isEmpty()) {
                sendError(response, "Task ID is required");
                return;
            }
            
            if (userIdParam == null || userIdParam.isEmpty()) {
                sendError(response, "User ID is required");
                return;
            }
            
            int taskId = Integer.parseInt(taskIdParam);
            int userId = Integer.parseInt(userIdParam);
            
            // Parse dates if provided
            java.sql.Timestamp startDate = null;
            java.sql.Timestamp deadline = null;
            try {
                if (startDateParam != null && !startDateParam.isEmpty() && !"null".equals(startDateParam)) {
                    // Parse date string (YYYY-MM-DD) to Timestamp
                    java.sql.Date date = java.sql.Date.valueOf(startDateParam);
                    startDate = new java.sql.Timestamp(date.getTime());
                }
                if (deadlineParam != null && !deadlineParam.isEmpty() && !"null".equals(deadlineParam)) {
                    // Parse date string (YYYY-MM-DD) to Timestamp
                    java.sql.Date date = java.sql.Date.valueOf(deadlineParam);
                    deadline = new java.sql.Timestamp(date.getTime());
                }
            } catch (IllegalArgumentException e) {
                sendError(response, "Invalid date format. Please use YYYY-MM-DD format.");
                return;
            }
            
            // Kiểm tra xem task có đã hoàn thành không
            WorkOrderTask task = taskDAO.getTaskById(taskId);
            if (task == null) {
                sendError(response, "Task not found");
                return;
            }
            
            // Kiểm tra work order status trước khi cho phép phân công
            WorkOrder workOrder = workOrderDAO.getWorkOrderById(task.getWorkOrderId());
            if (workOrder == null) {
                sendError(response, "Không tìm thấy đơn hàng công việc");
                return;
            }
            if ("completed".equals(workOrder.getStatus()) || "cancelled".equals(workOrder.getStatus()) || "rejected".equals(workOrder.getStatus())) {
                String statusText = "";
                if ("completed".equals(workOrder.getStatus())) {
                    statusText = "Đã hoàn thành";
                } else if ("cancelled".equals(workOrder.getStatus())) {
                    statusText = "Đã hủy";
                } else if ("rejected".equals(workOrder.getStatus())) {
                    statusText = "Đã từ chối";
                }
                JsonObject result = new JsonObject();
                result.addProperty("success", false);
                result.addProperty("message", "Không thể phân công công việc cho đơn hàng đã đóng! Trạng thái đơn hàng: " + statusText);
                sendJson(response, result);
                return;
            }
            
            if ("completed".equals(task.getStatus())) {
                JsonObject result = new JsonObject();
                result.addProperty("success", false);
                result.addProperty("message", "Công việc đã hoàn thành không thể giao cho người khác");
                sendJson(response, result);
                return;
            }
            
            // Kiểm tra nếu task đang thực hiện (in_progress)
            if ("in_progress".equals(task.getStatus())) {
                // Kiểm tra xem task đã được phân công cho ai chưa
                List<WorkOrderTaskAssignment> assignments = taskDAO.getTaskAssignments(taskId);
                boolean isAssignedToDifferentUser = false;
                if (assignments != null && !assignments.isEmpty()) {
                    for (WorkOrderTaskAssignment assignment : assignments) {
                        if ("assignee".equals(assignment.getRole()) && assignment.getUserId() != userId) {
                            isAssignedToDifferentUser = true;
                            break;
                        }
                    }
                }
                
                if (isAssignedToDifferentUser) {
                    JsonObject result = new JsonObject();
                    result.addProperty("success", false);
                    result.addProperty("message", "Công việc đang được thực hiện không thể phân công cho người khác");
                    sendJson(response, result);
                    return;
                }
            }
            
            // Đảm bảo role luôn là 'assignee' khi assign task
            String finalRole = (role != null && !role.isEmpty() && !"null".equals(role)) ? role : "assignee";
            if (!"assignee".equals(finalRole)) {
                finalRole = "assignee"; // Force to assignee
            }
            int assignedTaskId = taskDAO.assignTaskToUser(taskId, userId, finalRole, startDate, deadline);
            
            JsonObject result = new JsonObject();
            if (assignedTaskId > 0) {
                result.addProperty("success", true);
                if (assignedTaskId != taskId) {
                    // A new task was created (task already had assignment)
                    result.addProperty("message", "Đã tạo công việc mới với trạng thái 'Chờ xử lý' và phân công cho nhân viên. Nhân viên cần xác nhận để bắt đầu thực hiện.");
                    result.addProperty("newTaskId", assignedTaskId);
                } else {
                    // Original task was assigned (first time assignment)
                    result.addProperty("message", "Phân công công việc thành công. Nhân viên cần xác nhận để bắt đầu thực hiện.");
                }
            } else {
                result.addProperty("success", false);
                // Check for duplicate task with same description and user
                String duplicateStatus = taskDAO.getDuplicateTaskStatusWithUser(task.getWorkOrderId(), task.getTaskDescription(), userId);
                if (duplicateStatus != null) {
                    if ("pending".equals(duplicateStatus)) {
                        result.addProperty("message", "Công việc này với cùng mô tả và cùng nhân viên đã tồn tại và đang chờ xác nhận. Vui lòng kiểm tra lại danh sách công việc.");
                    } else if ("in_progress".equals(duplicateStatus)) {
                        result.addProperty("message", "Công việc này với cùng mô tả và cùng nhân viên đã tồn tại và đang được thực hiện. Vui lòng kiểm tra lại danh sách công việc.");
                    } else {
                        result.addProperty("message", "Công việc này với cùng mô tả và cùng nhân viên đã tồn tại. Vui lòng kiểm tra lại danh sách công việc.");
                    }
                } else if ("in_progress".equals(task.getStatus())) {
                    result.addProperty("message", "Công việc đang được thực hiện không thể phân công cho người khác");
                } else {
                    result.addProperty("message", "Không thể phân công công việc");
                }
            }
            sendJson(response, result);
            
        } catch (NumberFormatException e) {
            sendError(response, "Invalid ID");
        } catch (Exception e) {
            logger.severe("Error assigning task: " + e.getMessage());
            sendError(response, "Error assigning task: " + e.getMessage());
        }
    }

    private void handleRemoveAssignment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                sendError(response, "Unauthorized: Please login");
                return;
            }
            
            String taskIdParam = request.getParameter("taskId");
            String userIdParam = request.getParameter("userId");
            
            if (taskIdParam == null || taskIdParam.isEmpty()) {
                sendError(response, "Task ID is required");
                return;
            }
            
            if (userIdParam == null || userIdParam.isEmpty()) {
                sendError(response, "User ID is required");
                return;
            }
            
            int taskId = Integer.parseInt(taskIdParam);
            int userId = Integer.parseInt(userIdParam);
            
            boolean success = taskDAO.removeTaskAssignment(taskId, userId);
            
            JsonObject result = new JsonObject();
            result.addProperty("success", success);
            if (success) {
                result.addProperty("message", "Assignment removed successfully");
            } else {
                result.addProperty("message", "Failed to remove assignment");
            }
            sendJson(response, result);
            
        } catch (NumberFormatException e) {
            sendError(response, "Invalid ID");
        } catch (Exception e) {
            logger.severe("Error removing assignment: " + e.getMessage());
            sendError(response, "Error removing assignment: " + e.getMessage());
        }
    }
    
    /**
     * Fix task assignments: Update all task_assignments with NULL or wrong role to 'assignee'
     * This is a utility method to fix existing data
     */
    private void handleFixTaskAssignments(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                sendError(response, "Unauthorized: Please login");
                return;
            }
            
            // Check if user is admin or head_technician
            String userRole = (String) session.getAttribute("userRole");
            if (!"admin".equals(userRole) && !"head_technician".equals(userRole)) {
                sendError(response, "Unauthorized: Only admin or head_technician can fix assignments");
                return;
            }
            
            // Fix assignments with NULL or empty role
            int fixedCount = taskDAO.fixTaskAssignmentsRole();
            
            JsonObject result = new JsonObject();
            result.addProperty("success", true);
            result.addProperty("message", "Đã sửa " + fixedCount + " task assignment(s) có role NULL hoặc không đúng.");
            result.addProperty("fixedCount", fixedCount);
            sendJson(response, result);
            
        } catch (Exception e) {
            logger.severe("Error fixing task assignments: " + e.getMessage());
            sendError(response, "Error fixing task assignments: " + e.getMessage());
        }
    }
    
    /**
     * Lấy danh sách users available for task assignment (exclude users đã từ chối task)
     * GET /api/work-order-tasks?action=getAvailableUsers&taskId=?
     */
    private void handleGetAvailableUsersForAssignment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                sendError(response, "Unauthorized: Please login");
                return;
            }
            
            String taskIdParam = request.getParameter("taskId");
            int taskId = -1;
            if (taskIdParam != null && !taskIdParam.isEmpty()) {
                try {
                    taskId = Integer.parseInt(taskIdParam);
                } catch (NumberFormatException e) {
                    // Invalid taskId, ignore and return all users
                }
            }
            
            // Lấy tất cả technical staff users
            List<com.hlgenerator.model.User> allTechnicalStaff = userDAO.getUsersByRole("technical_staff");
            
            // Nếu có taskId, lấy danh sách user_id đã từ chối task đó
            List<Integer> rejectedUserIds = new ArrayList<>();
            if (taskId > 0) {
                rejectedUserIds = taskDAO.getRejectedUserIdsForTask(taskId);
            }
            
            // Filter ra những user đã từ chối
            List<com.hlgenerator.model.User> availableUsers = new ArrayList<>();
            for (com.hlgenerator.model.User user : allTechnicalStaff) {
                if (!rejectedUserIds.contains(user.getId())) {
                    availableUsers.add(user);
                }
            }
            
            // Build response
            com.google.gson.JsonArray usersArray = new com.google.gson.JsonArray();
            for (com.hlgenerator.model.User user : availableUsers) {
                com.google.gson.JsonObject userObj = new com.google.gson.JsonObject();
                userObj.addProperty("id", user.getId());
                userObj.addProperty("fullName", user.getFullName());
                userObj.addProperty("email", user.getEmail());
                userObj.addProperty("role", user.getRole());
                usersArray.add(userObj);
            }
            
            JsonObject result = new JsonObject();
            result.addProperty("success", true);
            result.add("data", usersArray);
            result.addProperty("total", availableUsers.size());
            if (taskId > 0) {
                result.addProperty("excludedCount", rejectedUserIds.size());
            }
            sendJson(response, result);
            
        } catch (Exception e) {
            logger.severe("Error getting available users for assignment: " + e.getMessage());
            sendError(response, "Error getting available users: " + e.getMessage());
        }
    }

    private void sendJson(HttpServletResponse response, JsonObject json) throws IOException {
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    private void sendError(HttpServletResponse response, String message) throws IOException {
        JsonObject result = new JsonObject();
        result.addProperty("success", false);
        result.addProperty("message", message);
        sendJson(response, result);
    }
}

