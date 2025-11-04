package com.hlgenerator.dao;

import com.hlgenerator.model.WorkOrderTask;
import com.hlgenerator.model.WorkOrderTaskAssignment;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class WorkOrderTaskDAO extends DBConnect {
    private static final Logger logger = Logger.getLogger(WorkOrderTaskDAO.class.getName());

    public WorkOrderTaskDAO() {
        super();
        if (connection == null) {
            logger.severe("WorkOrderTaskDAO: Database connection failed during initialization");
        }
    }

    // Check database connection
    private boolean checkConnection() {
        try {
            if (connection == null || connection.isClosed()) {
                logger.severe("Database connection is not available");
                return false;
            }
            return true;
        } catch (SQLException e) {
            logger.severe("Error checking database connection: " + e.getMessage());
            return false;
        }
    }

    /**
     * Create a new task for a work order
     */
    public int createTask(WorkOrderTask task) {
        if (!checkConnection()) {
            return -1;
        }

        String sql = "INSERT INTO tasks (work_order_id, task_number, task_description, status, priority, " +
                     "estimated_hours, notes) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, task.getWorkOrderId());
            ps.setString(2, generateTaskNumber(task.getWorkOrderId()));
            ps.setString(3, task.getTaskDescription());
            ps.setString(4, task.getStatus() != null ? task.getStatus() : "pending");
            ps.setString(5, task.getPriority() != null ? task.getPriority() : "medium");
            
            if (task.getEstimatedHours() != null) {
                ps.setBigDecimal(6, task.getEstimatedHours());
            } else {
                ps.setNull(6, Types.DECIMAL);
            }
            
            ps.setString(7, task.getNotes());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error creating task", e);
        }
        return -1;
    }

    /**
     * Generate task number for a work order
     */
    private String generateTaskNumber(int workOrderId) {
        String sql = "SELECT COUNT(*) + 1 as next_num FROM tasks WHERE work_order_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "T-" + String.format("%03d", rs.getInt("next_num"));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error generating task number", e);
        }
        return "T-001";
    }

    /**
     * Get all tasks for a work order with assigned user info
     */
    public List<WorkOrderTask> getTasksByWorkOrderId(int workOrderId) {
        List<WorkOrderTask> tasks = new ArrayList<>();
        if (!checkConnection()) {
            return tasks;
        }

        String sql = "SELECT t.*, u.full_name AS assigned_to_name " +
                     "FROM tasks t " +
                     "LEFT JOIN task_assignments ta ON t.id = ta.task_id AND ta.role = 'assignee' " +
                     "LEFT JOIN users u ON ta.user_id = u.id " +
                     "WHERE t.work_order_id = ? " +
                     "ORDER BY t.created_at ASC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tasks.add(mapResultSetToTask(rs));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting tasks for work order: " + workOrderId, e);
        }
        return tasks;
    }

    /**
     * Get a task by ID
     */
    public WorkOrderTask getTaskById(int taskId) {
        if (!checkConnection()) {
            return null;
        }

        String sql = "SELECT t.*, u.full_name AS assigned_to_name " +
                     "FROM tasks t " +
                     "LEFT JOIN task_assignments ta ON t.id = ta.task_id AND ta.role = 'assignee' " +
                     "LEFT JOIN users u ON ta.user_id = u.id " +
                     "WHERE t.id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTask(rs);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting task by ID: " + taskId, e);
        }
        return null;
    }

    /**
     * Update task
     */
    public boolean updateTask(WorkOrderTask task) {
        if (!checkConnection()) {
            return false;
        }

        String sql = "UPDATE tasks SET task_description = ?, status = ?, priority = ?, " +
                     "estimated_hours = ?, actual_hours = ?, start_date = ?, completion_date = ?, " +
                     "notes = ? WHERE id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, task.getTaskDescription());
            ps.setString(2, task.getStatus());
            ps.setString(3, task.getPriority());
            
            if (task.getEstimatedHours() != null) {
                ps.setBigDecimal(4, task.getEstimatedHours());
            } else {
                ps.setNull(4, Types.DECIMAL);
            }
            
            if (task.getActualHours() != null) {
                ps.setBigDecimal(5, task.getActualHours());
            } else {
                ps.setNull(5, Types.DECIMAL);
            }
            
            if (task.getStartDate() != null) {
                ps.setTimestamp(6, task.getStartDate());
            } else {
                ps.setNull(6, Types.TIMESTAMP);
            }
            
            if (task.getCompletionDate() != null) {
                ps.setTimestamp(7, task.getCompletionDate());
            } else {
                ps.setNull(7, Types.TIMESTAMP);
            }
            
            ps.setString(8, task.getNotes());
            ps.setInt(9, task.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating task: " + task.getId(), e);
            return false;
        }
    }

    /**
     * Delete task
     */
    public boolean deleteTask(int taskId) {
        if (!checkConnection()) {
            return false;
        }

        String sql = "DELETE FROM tasks WHERE id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting task: " + taskId, e);
            return false;
        }
    }

    /**
     * Assign task to user
     * - If task status is 'rejected', update status to 'pending' when reassigning
     * - If task status is 'in_progress', create a new task with status 'pending' for the new user
     */
    public int assignTaskToUser(int taskId, int userId, String role) {
        if (!checkConnection()) {
            return -1;
        }

        logger.info("Assigning task " + taskId + " to user " + userId + " with role " + role);

        try {
            // First, get current task status
            WorkOrderTask task = getTaskById(taskId);
            if (task == null) {
                logger.warning("Task not found: " + taskId);
                return -1;
            }
            
            // Start transaction
            connection.setAutoCommit(false);
            
            // If task status is 'in_progress', create a new task instead of reassigning
            if ("in_progress".equals(task.getStatus())) {
                // Create new task based on the current task
                WorkOrderTask newTask = new WorkOrderTask();
                newTask.setWorkOrderId(task.getWorkOrderId());
                newTask.setTaskDescription(task.getTaskDescription());
                newTask.setPriority(task.getPriority());
                newTask.setStatus("pending"); // New task starts with pending status
                newTask.setEstimatedHours(task.getEstimatedHours());
                
                // Create the new task
                int newTaskId = createTask(newTask);
                if (newTaskId <= 0) {
                    connection.rollback();
                    connection.setAutoCommit(true);
                    logger.warning("Failed to create new task for in_progress task");
                    return -1;
                }
                
                // Assign the new task to the new user
                String sql = "INSERT INTO task_assignments (task_id, user_id, role) " +
                             "VALUES (?, ?, ?)";
                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setInt(1, newTaskId);
                    ps.setInt(2, userId);
                    ps.setString(3, role);
                    ps.executeUpdate();
                }
                
                // Commit transaction
                connection.commit();
                connection.setAutoCommit(true);
                
                logger.info("Created new task " + newTaskId + " for in_progress task " + taskId + " and assigned to user " + userId);
                return newTaskId; // Return the new task ID
            }
            
            // For other statuses, update assignment normally
            String sql = "INSERT INTO task_assignments (task_id, user_id, role) " +
                         "VALUES (?, ?, ?) " +
                         "ON DUPLICATE KEY UPDATE role = VALUES(role)";

            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, taskId);
                ps.setInt(2, userId);
                ps.setString(3, role);
                ps.executeUpdate();
            }
            
            // If task status is 'rejected', update to 'pending' when reassigning
            if ("rejected".equals(task.getStatus())) {
                String updateSql = "UPDATE tasks SET status = 'pending', updated_at = NOW() WHERE id = ?";
                try (PreparedStatement ps = connection.prepareStatement(updateSql)) {
                    ps.setInt(1, taskId);
                    int updateResult = ps.executeUpdate();
                    logger.info("Updated task " + taskId + " status from 'rejected' to 'pending': " + updateResult + " row(s) affected");
                }
            }
            
            // Commit transaction
            connection.commit();
            connection.setAutoCommit(true);
            
            logger.info("Assignment completed successfully");
            return taskId; // Return the original task ID
            
        } catch (SQLException e) {
            try {
                connection.rollback();
                connection.setAutoCommit(true);
            } catch (SQLException rollbackEx) {
                logger.log(Level.SEVERE, "Error rolling back transaction", rollbackEx);
            }
            logger.log(Level.SEVERE, "Error assigning task to user", e);
            return -1;
        }
    }

    /**
     * Remove task assignment
     */
    public boolean removeTaskAssignment(int taskId, int userId) {
        if (!checkConnection()) {
            return false;
        }

        String sql = "DELETE FROM task_assignments WHERE task_id = ? AND user_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error removing task assignment", e);
            return false;
        }
    }

    /**
     * Get all assignments for a task
     */
    public List<WorkOrderTaskAssignment> getTaskAssignments(int taskId) {
        List<WorkOrderTaskAssignment> assignments = new ArrayList<>();
        if (!checkConnection()) {
            return assignments;
        }

        String sql = "SELECT ta.*, u.full_name, u.email " +
                     "FROM task_assignments ta " +
                     "JOIN users u ON ta.user_id = u.id " +
                     "WHERE ta.task_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WorkOrderTaskAssignment assignment = new WorkOrderTaskAssignment();
                    assignment.setId(rs.getInt("id"));
                    assignment.setTaskId(rs.getInt("task_id"));
                    assignment.setUserId(rs.getInt("user_id"));
                    assignment.setRole(rs.getString("role"));
                    assignment.setAssignedAt(rs.getTimestamp("assigned_at"));
                    assignments.add(assignment);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting task assignments", e);
        }
        return assignments;
    }

    /**
     * Map ResultSet to WorkOrderTask object
     */
    private WorkOrderTask mapResultSetToTask(ResultSet rs) throws SQLException {
        WorkOrderTask task = new WorkOrderTask();
        task.setId(rs.getInt("id"));
        task.setWorkOrderId(rs.getInt("work_order_id"));
        task.setTaskNumber(rs.getString("task_number"));
        task.setTaskDescription(rs.getString("task_description"));
        task.setStatus(rs.getString("status"));
        task.setPriority(rs.getString("priority"));
        task.setEstimatedHours(rs.getBigDecimal("estimated_hours"));
        task.setActualHours(rs.getBigDecimal("actual_hours"));
        task.setStartDate(rs.getTimestamp("start_date"));
        task.setCompletionDate(rs.getTimestamp("completion_date"));
        task.setNotes(rs.getString("notes"));
        
        // Map report fields if present
        try {
            task.setWorkDescription(rs.getString("work_description"));
        } catch (SQLException e) {
            // Column might not be present
        }
        try {
            task.setIssuesFound(rs.getString("issues_found"));
        } catch (SQLException e) {
            // Column might not be present
        }
        try {
            BigDecimal completionPercentage = rs.getBigDecimal("completion_percentage");
            if (completionPercentage != null) {
                task.setCompletionPercentage(completionPercentage);
            }
        } catch (SQLException e) {
            // Column might not be present
        }
        try {
            task.setAttachments(rs.getString("attachments"));
        } catch (SQLException e) {
            // Column might not be present
        }
        try {
            task.setRejectionReason(rs.getString("rejection_reason"));
        } catch (SQLException e) {
            // Column might not be present
        }
        
        task.setCreatedAt(rs.getTimestamp("created_at"));
        task.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        // Map assigned_to_name if present
        try {
            String assignedToName = rs.getString("assigned_to_name");
            if (assignedToName != null && !assignedToName.isEmpty()) {
                task.setAssignedToName(assignedToName);
            }
        } catch (SQLException e) {
            // Column might not be present in all queries
        }
        
        return task;
    }

    /**
     * Get count of tasks by work order and status
     */
    public int getTaskCountByStatus(int workOrderId, String status) {
        if (!checkConnection()) {
            return 0;
        }

        String sql = "SELECT COUNT(*) as count FROM tasks WHERE work_order_id = ? AND status = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting task count", e);
        }
        return 0;
    }
}

