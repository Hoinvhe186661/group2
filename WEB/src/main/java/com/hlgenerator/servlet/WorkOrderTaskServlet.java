package com.hlgenerator.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.hlgenerator.dao.WorkOrderTaskDAO;
import com.hlgenerator.model.WorkOrderTask;
import com.hlgenerator.model.WorkOrderTaskAssignment;

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
    private Gson gson;

    @Override
    public void init() throws ServletException {
        super.init();
        taskDAO = new WorkOrderTaskDAO();
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
        
        try {
            if (workOrderIdParam == null || workOrderIdParam.isEmpty()) {
                sendError(response, "Work order ID is required");
                return;
            }
            
            int workOrderId = Integer.parseInt(workOrderIdParam);
            List<WorkOrderTask> tasks = taskDAO.getTasksByWorkOrderId(workOrderId);
            
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
            
            WorkOrderTask task = new WorkOrderTask();
            task.setWorkOrderId(Integer.parseInt(workOrderIdParam));
            task.setTaskDescription(taskDescription.trim());
            task.setPriority(priority != null ? priority : "medium");
            task.setStatus("pending");
            
            if (estimatedHoursParam != null && !estimatedHoursParam.isEmpty()) {
                try {
                    task.setEstimatedHours(new BigDecimal(estimatedHoursParam));
                } catch (NumberFormatException e) {
                    logger.warning("Invalid estimated hours: " + estimatedHoursParam);
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
                task.setTaskDescription(taskDescription.trim());
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
                    task.setEstimatedHours(new BigDecimal(estimatedHoursParam));
                } catch (NumberFormatException e) {
                    logger.warning("Invalid estimated hours: " + estimatedHoursParam);
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
            boolean success = taskDAO.deleteTask(id);
            
            JsonObject result = new JsonObject();
            result.addProperty("success", success);
            if (success) {
                result.addProperty("message", "Task deleted successfully");
            } else {
                result.addProperty("message", "Failed to delete task");
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
            
            boolean success = taskDAO.assignTaskToUser(taskId, userId, role != null ? role : "assignee");
            
            JsonObject result = new JsonObject();
            result.addProperty("success", success);
            if (success) {
                result.addProperty("message", "Task assigned successfully");
            } else {
                result.addProperty("message", "Failed to assign task");
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

