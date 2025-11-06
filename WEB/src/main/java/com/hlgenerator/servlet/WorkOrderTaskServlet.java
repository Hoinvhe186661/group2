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
    private Gson gson;

    @Override
    public void init() throws ServletException {
        super.init();
        taskDAO = new WorkOrderTaskDAO();
        workOrderDAO = new WorkOrderDAO();
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
            if ("completed".equals(workOrderStatus) || "cancelled".equals(workOrderStatus)) {
                sendError(response, "Không thể tạo công việc mới cho đơn hàng đã đóng hoặc đã hủy. Trạng thái đơn hàng: " + 
                    ("completed".equals(workOrderStatus) ? "Đã hoàn thành" : "Đã hủy"));
                return;
            }
            
            // Check for duplicate active task (pending or in_progress) with same description
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
            
            WorkOrderTask task = new WorkOrderTask();
            task.setWorkOrderId(workOrderId);
            task.setTaskDescription(trimmedDescription);
            task.setPriority(priority != null ? priority : "medium");
            task.setStatus("pending");
            
            if (estimatedHoursParam != null && !estimatedHoursParam.isEmpty()) {
                try {
                    BigDecimal estimatedHours = new BigDecimal(estimatedHoursParam);
                    // Validate: tối thiểu > 0, không cho phép số âm
                    if (estimatedHours.compareTo(BigDecimal.ZERO) <= 0) {
                        sendError(response, "Giờ ước tính phải lớn hơn 0");
                        return;
                    }
                    
                    // Kiểm tra giờ ước tính của task không được vượt quá giờ ước tính của work order
                    BigDecimal workOrderEstimatedHours = workOrder.getEstimatedHours();
                    if (workOrderEstimatedHours != null && workOrderEstimatedHours.compareTo(BigDecimal.ZERO) > 0) {
                        // Work order có giờ ước tính, task không được vượt quá
                        if (estimatedHours.compareTo(workOrderEstimatedHours) > 0) {
                            sendError(response, "Giờ ước tính của công việc (" + estimatedHours + "h) không được vượt quá giờ ước tính của đơn hàng (" + workOrderEstimatedHours + "h)");
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
                // Get the created task with full details
                WorkOrderTask createdTask = taskDAO.getTaskById(createdTaskId);
                JsonObject result = new JsonObject();
                result.addProperty("success", true);
                result.add("data", gson.toJsonTree(createdTask));
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
                            // Work order có giờ ước tính, task không được vượt quá
                            if (estimatedHours.compareTo(workOrderEstimatedHours) > 0) {
                                sendError(response, "Giờ ước tính của công việc (" + estimatedHours + "h) không được vượt quá giờ ước tính của đơn hàng (" + workOrderEstimatedHours + "h)");
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
            
            // Kiểm tra xem task có đã hoàn thành không
            WorkOrderTask task = taskDAO.getTaskById(taskId);
            if (task == null) {
                sendError(response, "Task not found");
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
            
            int assignedTaskId = taskDAO.assignTaskToUser(taskId, userId, role != null ? role : "assignee");
            
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

