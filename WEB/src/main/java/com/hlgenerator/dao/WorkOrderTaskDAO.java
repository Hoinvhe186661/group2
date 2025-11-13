package com.hlgenerator.dao;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.hlgenerator.model.WorkOrderTask;
import com.hlgenerator.model.WorkOrderTaskAssignment;

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

        // Build dynamic SQL based on whether start_date and deadline are provided
        StringBuilder sqlBuilder = new StringBuilder("INSERT INTO tasks (work_order_id, task_number, task_description, status, priority, ");
        
        sqlBuilder.append("estimated_hours, notes");
        if (task.getStartDate() != null) {
            sqlBuilder.append(", start_date");
        }
        if (task.getDeadline() != null) {
            sqlBuilder.append(", deadline");
        }
        sqlBuilder.append(") VALUES (?, ?, ?, ?, ?, ?, ?");
        if (task.getStartDate() != null) {
            sqlBuilder.append(", ?");
        }
        if (task.getDeadline() != null) {
            sqlBuilder.append(", ?");
        }
        sqlBuilder.append(")");

        try (PreparedStatement ps = connection.prepareStatement(sqlBuilder.toString(), Statement.RETURN_GENERATED_KEYS)) {
            int paramIndex = 1;
            ps.setInt(paramIndex++, task.getWorkOrderId());
            ps.setString(paramIndex++, generateTaskNumber(task.getWorkOrderId()));
            ps.setString(paramIndex++, task.getTaskDescription());
            ps.setString(paramIndex++, task.getStatus() != null ? task.getStatus() : "pending");
            ps.setString(paramIndex++, task.getPriority() != null ? task.getPriority() : "medium");
            
            if (task.getEstimatedHours() != null) {
                ps.setBigDecimal(paramIndex++, task.getEstimatedHours());
            } else {
                ps.setNull(paramIndex++, Types.DECIMAL);
            }
            
            ps.setString(paramIndex++, task.getNotes());
            
            if (task.getStartDate() != null) {
                ps.setTimestamp(paramIndex++, task.getStartDate());
            }
            if (task.getDeadline() != null) {
                ps.setTimestamp(paramIndex++, task.getDeadline());
            }

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
     * Generate unique random task number
     * Format: T-[4 digits]
     * Example: T-1234, T-5678, T-9012
     */
    private String generateTaskNumber(int workOrderId) {
        java.util.Random random = new java.util.Random();
        int maxAttempts = 100; // Tối đa 100 lần thử để tránh vòng lặp vô hạn
        String prefix = "T-";
        
        for (int attempt = 0; attempt < maxAttempts; attempt++) {
            // Tạo 4 số ngẫu nhiên (0000-9999)
            int randomNumber = random.nextInt(10000); // 0-9999
            String numberPart = String.format("%04d", randomNumber); // Format thành 4 chữ số với leading zeros
            
            // Tạo mã: prefix + 4 số
            String taskNumber = prefix + numberPart;
            
            // Kiểm tra xem mã đã tồn tại chưa trong toàn bộ database
            if (!isTaskNumberExists(taskNumber)) {
                return taskNumber;
            }
        }
        
        // Nếu sau 100 lần thử vẫn không tìm được mã unique, dùng timestamp làm fallback
        logger.warning("Could not generate unique task number after " + maxAttempts + " attempts, using timestamp");
        return prefix + String.format("%04d", (int)(System.currentTimeMillis() % 10000)); // Lấy 4 chữ số cuối của timestamp
    }
    
    /**
     * Kiểm tra xem task number đã tồn tại chưa trong toàn bộ database
     */
    private boolean isTaskNumberExists(String taskNumber) {
        if (!checkConnection()) {
            return false;
        }
        
        String sql = "SELECT COUNT(*) as count FROM tasks WHERE task_number = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, taskNumber);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Error checking task number existence: " + taskNumber, e);
            // Nếu có lỗi, giả sử mã đã tồn tại để tránh duplicate
            return true;
        }
        
        return false;
    }

    /**
     * Get all tasks for a work order with assigned user info
     */
    public List<WorkOrderTask> getTasksByWorkOrderId(int workOrderId) {
        return getTasksByWorkOrderId(workOrderId, null, null);
    }
    
    /**
     * Get all tasks for a work order with assigned user info, filtered by priority and status
     */
    public List<WorkOrderTask> getTasksByWorkOrderId(int workOrderId, String priority, String status) {
        List<WorkOrderTask> tasks = new ArrayList<>();
        if (!checkConnection()) {
            return tasks;
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT t.*, u.full_name AS assigned_to_name ");
        sql.append("FROM tasks t ");
        sql.append("LEFT JOIN task_assignments ta ON t.id = ta.task_id AND ta.role = 'assignee' ");
        sql.append("LEFT JOIN users u ON ta.user_id = u.id ");
        sql.append("WHERE t.work_order_id = ? ");
        
        if (priority != null && !priority.isEmpty()) {
            sql.append("AND t.priority = ? ");
        }
        
        if (status != null && !status.isEmpty()) {
            sql.append("AND t.status = ? ");
        }
        
        sql.append("ORDER BY t.created_at ASC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            ps.setInt(paramIndex++, workOrderId);
            
            if (priority != null && !priority.isEmpty()) {
                ps.setString(paramIndex++, priority);
            }
            
            if (status != null && !status.isEmpty()) {
                ps.setString(paramIndex++, status);
            }
            
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
                     "deadline = ?, notes = ? WHERE id = ?";

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
            
            if (task.getDeadline() != null) {
                ps.setTimestamp(8, task.getDeadline());
            } else {
                ps.setNull(8, Types.TIMESTAMP);
            }
            
            ps.setString(9, task.getNotes());
            ps.setInt(10, task.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating task: " + task.getId(), e);
            return false;
        }
    }

    /**
     * Delete task
     * Returns: 1 for success, 0 for failure, -1 if task is completed (cannot delete)
     */
    public int deleteTask(int taskId) {
        if (!checkConnection()) {
            return 0;
        }

        // First check if task is completed
        WorkOrderTask task = getTaskById(taskId);
        if (task != null && "completed".equals(task.getStatus())) {
            return -1; // Cannot delete completed task
        }

        String sql = "DELETE FROM tasks WHERE id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            int result = ps.executeUpdate();
            return result > 0 ? 1 : 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting task: " + taskId, e);
            return 0;
        }
    }
    
    /**
     * Check if work order has any active tasks (status = 'in_progress')
     * Returns true if there are active tasks, false otherwise
     */
    public boolean hasActiveTasks(int workOrderId) {
        if (!checkConnection()) {
            return false;
        }

        String sql = "SELECT COUNT(*) as count FROM tasks WHERE work_order_id = ? AND status = 'in_progress'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking active tasks for work order: " + workOrderId, e);
        }
        return false;
    }
    
    /**
     * Get count of active tasks (status = 'in_progress') for a work order
     * Returns the count of tasks with status 'in_progress'
     */
    public int getActiveTaskCount(int workOrderId) {
        if (!checkConnection()) {
            return 0;
        }

        String sql = "SELECT COUNT(*) as count FROM tasks WHERE work_order_id = ? AND status = 'in_progress'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting active task count for work order: " + workOrderId, e);
        }
        return 0;
    }
    
    /**
     * Check if work order has any incomplete tasks (status = 'pending' or 'in_progress')
     * Returns true if there are incomplete tasks, false otherwise
     */
    public boolean hasIncompleteTasks(int workOrderId) {
        if (!checkConnection()) {
            return false;
        }

        String sql = "SELECT COUNT(*) as count FROM tasks WHERE work_order_id = ? AND status IN ('pending', 'in_progress')";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking incomplete tasks for work order: " + workOrderId, e);
        }
        return false;
    }
    
    /**
     * Get count of incomplete tasks (status = 'pending' or 'in_progress') for a work order
     * Returns a map with counts for pending and in_progress tasks
     */
    public java.util.Map<String, Integer> getIncompleteTaskCounts(int workOrderId) {
        java.util.Map<String, Integer> counts = new java.util.HashMap<>();
        counts.put("pending", 0);
        counts.put("in_progress", 0);
        counts.put("total", 0);
        
        if (!checkConnection()) {
            return counts;
        }

        String sql = "SELECT status, COUNT(*) as count FROM tasks WHERE work_order_id = ? AND status IN ('pending', 'in_progress') GROUP BY status";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                int total = 0;
                while (rs.next()) {
                    String status = rs.getString("status");
                    int count = rs.getInt("count");
                    counts.put(status, count);
                    total += count;
                }
                counts.put("total", total);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting incomplete task counts for work order: " + workOrderId, e);
        }
        return counts;
    }

    /**
     * Check if task has an assignment with role 'assignee'
     * Returns the user_id if assigned, -1 if not assigned
     */
    private int getAssignedUserId(int taskId) {
        if (!checkConnection()) {
            return -1;
        }
        
        String sql = "SELECT user_id FROM task_assignments WHERE task_id = ? AND role = 'assignee' LIMIT 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Error checking task assignment", e);
        }
        return -1;
    }

    /**
     * Assign task to user
     * - If task already has an assignment (pending or in_progress), create a new task with status 'pending' for the new user
     * - If task status is 'rejected' and no assignment, update status to 'pending' when assigning
     * - Task mới luôn có status 'pending', chỉ chuyển sang 'in_progress' khi nhân viên acknowledge
     */
    public int assignTaskToUser(int taskId, int userId, String role) {
        return assignTaskToUser(taskId, userId, role, null, null);
    }
    
    public int assignTaskToUser(int taskId, int userId, String role, java.sql.Timestamp startDate, java.sql.Timestamp deadline) {
        if (!checkConnection()) {
            return -1;
        }

        logger.info("Assigning task " + taskId + " to user " + userId + " with role " + role);

        try {
            // First, get current task
            WorkOrderTask task = getTaskById(taskId);
            if (task == null) {
                logger.warning("Task not found: " + taskId);
                return -1;
            }
            
            // Check if task is completed - cannot reassign
            if ("completed".equals(task.getStatus())) {
                logger.warning("Cannot assign completed task " + taskId);
                return -1;
            }
            
            // Check if task is in_progress - cannot reassign to different user
            if ("in_progress".equals(task.getStatus())) {
                // Check if assigning to the same user (allow) or different user (deny)
                int existingAssignedUserId = getAssignedUserId(taskId);
                if (existingAssignedUserId > 0 && existingAssignedUserId != userId) {
                    // Task is in progress and assigned to different user - cannot reassign
                    logger.warning("Cannot reassign task " + taskId + " that is in progress to different user");
                    return -1;
                }
                // If assigning to same user or task has no assignment, allow but don't create new task
                // Just update assignment if needed (though this shouldn't happen normally)
            }
            
            // Start transaction
            connection.setAutoCommit(false);
            
            // Check if task already has an assignment with role 'assignee'
            int existingAssignedUserId = getAssignedUserId(taskId);
            boolean hasExistingAssignment = (existingAssignedUserId > 0);
            boolean isAssigningToDifferentUser = hasExistingAssignment && (existingAssignedUserId != userId);
            
            // If task already has assignment and we're assigning to a different user, create new task
            // But NOT if task is in_progress (already checked above)
            if (isAssigningToDifferentUser && !"in_progress".equals(task.getStatus())) {
                // Check if there's already a task with same description and user in pending/in_progress
                if (hasDuplicateActiveTaskWithUser(task.getWorkOrderId(), task.getTaskDescription(), userId)) {
                    connection.rollback();
                    connection.setAutoCommit(true);
                    logger.warning("Cannot create new task: duplicate task with same description and user already exists");
                    return -1; // Will be handled by servlet to show appropriate error
                }
                
                // Create new task based on the current task
                WorkOrderTask newTask = new WorkOrderTask();
                newTask.setWorkOrderId(task.getWorkOrderId());
                newTask.setTaskDescription(task.getTaskDescription());
                newTask.setPriority(task.getPriority());
                newTask.setStatus("pending"); // New task always starts with pending status
                newTask.setEstimatedHours(task.getEstimatedHours());
                // Set start date and deadline: use provided values, or copy from original task if not provided
                if (startDate != null) {
                    newTask.setStartDate(startDate);
                } else if (task.getStartDate() != null) {
                    // Copy start date from original task if not provided
                    newTask.setStartDate(task.getStartDate());
                }
                if (deadline != null) {
                    newTask.setDeadline(deadline);
                } else if (task.getDeadline() != null) {
                    // Copy deadline from original task if not provided
                    newTask.setDeadline(task.getDeadline());
                }
                
                // Create the new task
                int newTaskId = createTask(newTask);
                if (newTaskId <= 0) {
                    connection.rollback();
                    connection.setAutoCommit(true);
                    logger.warning("Failed to create new task for reassignment");
                    return -1;
                }
                
                // Assign the new task to the new user
                // Đảm bảo role luôn là 'assignee'
                String finalRole = (role != null && !role.isEmpty()) ? role : "assignee";
                String sql = "INSERT INTO task_assignments (task_id, user_id, role) " +
                             "VALUES (?, ?, ?)";
                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setInt(1, newTaskId);
                    ps.setInt(2, userId);
                    ps.setString(3, finalRole);
                    ps.executeUpdate();
                }
                
                // Commit transaction
                connection.commit();
                connection.setAutoCommit(true);
                
                logger.info("Created new task " + newTaskId + " for task " + taskId + " and assigned to user " + userId);
                return newTaskId; // Return the new task ID
            }
            
            // If assigning to same user or task doesn't have assignment yet, check for duplicate
            if (!hasExistingAssignment || existingAssignedUserId == userId) {
                // Check if there's already a task with same description and user in pending/in_progress
                if (hasDuplicateActiveTaskWithUser(task.getWorkOrderId(), task.getTaskDescription(), userId)) {
                    connection.rollback();
                    connection.setAutoCommit(true);
                    logger.warning("Cannot assign task: duplicate task with same description and user already exists");
                    return -1; // Will be handled by servlet to show appropriate error
                }
            }
            
            // If task doesn't have assignment yet, or assigning to same user, proceed with normal assignment
            // Đảm bảo role luôn là 'assignee' khi assign task
            String finalRole = (role != null && !role.isEmpty()) ? role : "assignee";
            String sql = "INSERT INTO task_assignments (task_id, user_id, role) " +
                         "VALUES (?, ?, ?) " +
                         "ON DUPLICATE KEY UPDATE role = VALUES(role)";

            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, taskId);
                ps.setInt(2, userId);
                ps.setString(3, finalRole);
                ps.executeUpdate();
            }
            
            // Update task with start date, deadline, and status if needed
            boolean needUpdateTask = false;
            StringBuilder updateTaskSql = new StringBuilder("UPDATE tasks SET ");
            List<Object> updateParams = new ArrayList<>();
            
            // For start date: use provided value, or keep existing if not provided
            // When reassigning a rejected task, preserve the original start_date if not explicitly provided
            if (startDate != null) {
                updateTaskSql.append("start_date = ?");
                updateParams.add(startDate);
                needUpdateTask = true;
            } else if (task.getStartDate() != null && !isAssigningToDifferentUser) {
                // If not provided and task has start_date, keep it when reassigning to same task
                // This ensures rejected task's start_date is preserved when reassigning
                updateTaskSql.append("start_date = ?");
                updateParams.add(task.getStartDate());
                needUpdateTask = true;
            }
            
            // For deadline: use provided value, or keep existing if not provided
            // When reassigning a rejected task, preserve the original deadline if not explicitly provided
            if (deadline != null) {
                if (needUpdateTask) {
                    updateTaskSql.append(", ");
                }
                updateTaskSql.append("deadline = ?");
                updateParams.add(deadline);
                needUpdateTask = true;
            } else if (task.getDeadline() != null && !isAssigningToDifferentUser) {
                // If not provided and task has deadline, keep it when reassigning to same task
                // This ensures rejected task's deadline is preserved when reassigning
                if (needUpdateTask) {
                    updateTaskSql.append(", ");
                }
                updateTaskSql.append("deadline = ?");
                updateParams.add(task.getDeadline());
                needUpdateTask = true;
            }
            
            // If task status is 'rejected', update to 'pending' when assigning
            if ("rejected".equals(task.getStatus())) {
                if (needUpdateTask) {
                    updateTaskSql.append(", ");
                }
                updateTaskSql.append("status = 'pending'");
                needUpdateTask = true;
            }
            
            if (needUpdateTask) {
                updateTaskSql.append(", updated_at = NOW() WHERE id = ?");
                updateParams.add(taskId);
                try (PreparedStatement ps = connection.prepareStatement(updateTaskSql.toString())) {
                    for (int i = 0; i < updateParams.size(); i++) {
                        ps.setObject(i + 1, updateParams.get(i));
                    }
                    int updateResult = ps.executeUpdate();
                    logger.info("Updated task " + taskId + " with start_date, deadline, and/or status: " + updateResult + " row(s) affected");
                }
            }
            
            // Commit transaction
            connection.commit();
            connection.setAutoCommit(true);
            
            logger.info("Assignment completed successfully for task " + taskId);
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
        try {
            task.setDeadline(rs.getTimestamp("deadline"));
        } catch (SQLException e) {
            // Column might not be present in older database
        }
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

    /**
     * Get count of tasks that are currently in progress (status = 'in_progress') assigned to a user
     * Only counts tasks that have been acknowledged and are being worked on, not pending assignments
     */
    public int getActiveTaskCountForUser(int userId) {
        if (!checkConnection()) {
            return 0;
        }

        String sql = "SELECT COUNT(*) as count " +
                     "FROM task_assignments ta " +
                     "JOIN tasks t ON ta.task_id = t.id " +
                     "WHERE ta.user_id = ? AND ta.role = 'assignee' " +
                     "AND t.status = 'in_progress'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting active task count for user", e);
        }
        return 0;
    }

    /**
     * Get list of tasks that are currently in progress (status = 'in_progress') assigned to a user
     * Returns list of tasks with work order information
     */
    public List<java.util.Map<String, Object>> getActiveTasksForUser(int userId) {
        List<java.util.Map<String, Object>> tasks = new ArrayList<>();
        if (!checkConnection()) {
            return tasks;
        }

        String sql = "SELECT t.id, t.task_number, t.task_description, t.status, t.priority, " +
                     "wo.id as work_order_id, wo.work_order_number, wo.title as work_order_title " +
                     "FROM task_assignments ta " +
                     "JOIN tasks t ON ta.task_id = t.id " +
                     "JOIN work_orders wo ON t.work_order_id = wo.id " +
                     "WHERE ta.user_id = ? AND ta.role = 'assignee' " +
                     "AND t.status = 'in_progress' " +
                     "ORDER BY t.updated_at DESC, t.created_at DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> task = new java.util.HashMap<>();
                    task.put("id", rs.getInt("id"));
                    task.put("taskNumber", rs.getString("task_number"));
                    task.put("taskDescription", rs.getString("task_description"));
                    task.put("status", rs.getString("status"));
                    task.put("priority", rs.getString("priority"));
                    task.put("workOrderId", rs.getInt("work_order_id"));
                    task.put("workOrderNumber", rs.getString("work_order_number"));
                    task.put("workOrderTitle", rs.getString("work_order_title"));
                    tasks.add(task);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting active tasks for user", e);
        }
        return tasks;
    }

    /**
     * Check if a task with the same description already exists in the work order with pending or in_progress status
     * Returns true if duplicate task exists (pending or in_progress), false otherwise
     */
    public boolean hasDuplicateActiveTask(int workOrderId, String taskDescription) {
        if (!checkConnection()) {
            return false;
        }

        String sql = "SELECT COUNT(*) as count " +
                     "FROM tasks " +
                     "WHERE work_order_id = ? " +
                     "AND LOWER(TRIM(task_description)) = LOWER(TRIM(?)) " +
                     "AND status IN ('pending', 'in_progress')";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            ps.setString(2, taskDescription);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking duplicate active task", e);
        }
        return false;
    }
    
    /**
     * Get total actual hours from all tasks for a work order
     * Returns sum of actual_hours from all tasks that have actual_hours not null
     */
    public BigDecimal getTotalActualHoursForWorkOrder(int workOrderId) {
        if (!checkConnection()) {
            return BigDecimal.ZERO;
        }

        String sql = "SELECT COALESCE(SUM(actual_hours), 0) as total_hours " +
                     "FROM tasks " +
                     "WHERE work_order_id = ? AND actual_hours IS NOT NULL";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal total = rs.getBigDecimal("total_hours");
                    return total != null ? total : BigDecimal.ZERO;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting total actual hours for work order: " + workOrderId, e);
        }
        return BigDecimal.ZERO;
    }
    
    /**
     * Get total estimated hours from all tasks for a work order
     * Returns sum of estimated_hours from all tasks that have estimated_hours not null
     */
    public BigDecimal getTotalEstimatedHoursForWorkOrder(int workOrderId) {
        if (!checkConnection()) {
            return BigDecimal.ZERO;
        }

        // Không tính các task có status = 'rejected' vào tổng giờ ước tính
        String sql = "SELECT COALESCE(SUM(estimated_hours), 0) as total_hours " +
                     "FROM tasks " +
                     "WHERE work_order_id = ? AND estimated_hours IS NOT NULL AND status != 'rejected'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal total = rs.getBigDecimal("total_hours");
                    return total != null ? total : BigDecimal.ZERO;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting total estimated hours for work order: " + workOrderId, e);
        }
        return BigDecimal.ZERO;
    }
    
    /**
     * Get total estimated hours for work order excluding a specific task (for update validation)
     * Excludes tasks with status = 'rejected' and the specified taskId
     */
    public BigDecimal getTotalEstimatedHoursForWorkOrderExcludingTask(int workOrderId, int excludeTaskId) {
        if (!checkConnection()) {
            return BigDecimal.ZERO;
        }

        // Không tính các task có status = 'rejected' và task đang được update vào tổng giờ ước tính
        String sql = "SELECT COALESCE(SUM(estimated_hours), 0) as total_hours " +
                     "FROM tasks " +
                     "WHERE work_order_id = ? AND estimated_hours IS NOT NULL " +
                     "AND status != 'rejected' AND id != ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            ps.setInt(2, excludeTaskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal total = rs.getBigDecimal("total_hours");
                    return total != null ? total : BigDecimal.ZERO;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting total estimated hours for work order excluding task: " + workOrderId + ", excludeTaskId: " + excludeTaskId, e);
        }
        return BigDecimal.ZERO;
    }
    
    /**
     * Check if a task with the same description and assigned user already exists in the work order 
     * with pending or in_progress status
     * Returns true if duplicate task exists (pending or in_progress) with same description and user, false otherwise
     */
    public boolean hasDuplicateActiveTaskWithUser(int workOrderId, String taskDescription, int userId) {
        if (!checkConnection()) {
            return false;
        }

        String sql = "SELECT COUNT(*) as count " +
                     "FROM tasks t " +
                     "JOIN task_assignments ta ON t.id = ta.task_id AND ta.role = 'assignee' " +
                     "WHERE t.work_order_id = ? " +
                     "AND LOWER(TRIM(t.task_description)) = LOWER(TRIM(?)) " +
                     "AND ta.user_id = ? " +
                     "AND t.status IN ('pending', 'in_progress')";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            ps.setString(2, taskDescription);
            ps.setInt(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking duplicate active task with user", e);
        }
        return false;
    }
    
    /**
     * Get the status of duplicate task if exists (for better error message)
     * Returns status string if duplicate exists, null otherwise
     */
    public String getDuplicateTaskStatus(int workOrderId, String taskDescription) {
        if (!checkConnection()) {
            return null;
        }

        String sql = "SELECT status " +
                     "FROM tasks " +
                     "WHERE work_order_id = ? " +
                     "AND LOWER(TRIM(task_description)) = LOWER(TRIM(?)) " +
                     "AND status IN ('pending', 'in_progress') " +
                     "LIMIT 1";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            ps.setString(2, taskDescription);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting duplicate task status", e);
        }
        return null;
    }
    
    /**
     * Get the status of duplicate task with same user if exists (for better error message)
     * Returns status string if duplicate exists, null otherwise
     */
    public String getDuplicateTaskStatusWithUser(int workOrderId, String taskDescription, int userId) {
        if (!checkConnection()) {
            return null;
        }

        String sql = "SELECT t.status " +
                     "FROM tasks t " +
                     "JOIN task_assignments ta ON t.id = ta.task_id AND ta.role = 'assignee' " +
                     "WHERE t.work_order_id = ? " +
                     "AND LOWER(TRIM(t.task_description)) = LOWER(TRIM(?)) " +
                     "AND ta.user_id = ? " +
                     "AND t.status IN ('pending', 'in_progress') " +
                     "LIMIT 1";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrderId);
            ps.setString(2, taskDescription);
            ps.setInt(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting duplicate task status with user", e);
        }
        return null;
    }
    
    /**
     * Fix task assignments: Update all task_assignments with NULL or wrong role to 'assignee'
     * Returns the number of fixed records
     */
    public int fixTaskAssignmentsRole() {
        if (!checkConnection()) {
            return 0;
        }
        
        try {
            // Update assignments with NULL or empty role to 'assignee'
            String sql = "UPDATE task_assignments SET role = 'assignee' " +
                         "WHERE role IS NULL OR role = '' OR role != 'assignee'";
            
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                int updatedRows = ps.executeUpdate();
                logger.info("Fixed " + updatedRows + " task assignments with wrong role");
                return updatedRows;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fixing task assignments role", e);
            return 0;
        }
    }
    
    /**
     * Assign task directly to user without complex logic
     * Used when creating a new task and assigning immediately
     * Returns true if successful, false otherwise
     */
    public boolean assignTaskDirectly(int taskId, int userId, String role) {
        if (!checkConnection()) {
            return false;
        }
        
        // Đảm bảo role luôn là 'assignee'
        String finalRole = (role != null && !role.isEmpty()) ? role : "assignee";
        
        try {
            // Kiểm tra xem task đã có assignment với role='assignee' chưa
            int existingAssignedUserId = getAssignedUserId(taskId);
            if (existingAssignedUserId > 0 && existingAssignedUserId != userId) {
                // Task đã có assignment cho user khác, không thể assign trực tiếp
                logger.warning("Task " + taskId + " already assigned to user " + existingAssignedUserId);
                return false;
            }
            
            // Insert assignment với ON DUPLICATE KEY UPDATE để tránh lỗi nếu đã tồn tại
            String sql = "INSERT INTO task_assignments (task_id, user_id, role) " +
                         "VALUES (?, ?, ?) " +
                         "ON DUPLICATE KEY UPDATE role = VALUES(role)";
            
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, taskId);
                ps.setInt(2, userId);
                ps.setString(3, finalRole);
                int rowsAffected = ps.executeUpdate();
                
                if (rowsAffected > 0) {
                    logger.info("Successfully assigned task " + taskId + " to user " + userId + " with role " + finalRole);
                    return true;
                } else {
                    logger.warning("Failed to assign task " + taskId + " to user " + userId);
                    return false;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error assigning task directly: " + taskId + " to user " + userId, e);
            return false;
        }
    }
    
    /**
     * Lấy danh sách user_id đã từ chối task
     * Logic: Lấy tất cả user_id đã từ chối task này (task có status = 'rejected' và có assignment)
     * Returns list of user IDs who rejected this task
     */
    public List<Integer> getRejectedUserIdsForTask(int taskId) {
        List<Integer> rejectedUserIds = new ArrayList<>();
        if (!checkConnection()) {
            return rejectedUserIds;
        }
        
        // Lấy task info để biết work_order_id và task_description
        WorkOrderTask task = getTaskById(taskId);
        if (task == null) {
            return rejectedUserIds;
        }
        
        // Lấy danh sách user_id đã từ chối task này HOẶC các task khác với cùng description trong cùng work_order
        // Nếu task có status = 'rejected', thì những user đã được assign là những user đã từ chối
        String sql = "SELECT DISTINCT ta.user_id " +
                     "FROM task_assignments ta " +
                     "JOIN tasks t ON ta.task_id = t.id " +
                     "WHERE t.work_order_id = ? " +
                     "AND LOWER(TRIM(t.task_description)) = LOWER(TRIM(?)) " +
                     "AND t.status = 'rejected' " +
                     "AND ta.role = 'assignee'";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, task.getWorkOrderId());
            ps.setString(2, task.getTaskDescription());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rejectedUserIds.add(rs.getInt("user_id"));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting rejected user IDs for task: " + taskId, e);
        }
        return rejectedUserIds;
    }
    
    /**
     * Get all technical staff with their assigned tasks
     * Returns list of users with their tasks
     * @param statusFilter Filter by task status (null or empty for all)
     * @param priorityFilter Filter by task priority (null or empty for all)
     * @param searchKeyword Search keyword for staff name, task number, or task description (null or empty for all)
     */
    public List<java.util.Map<String, Object>> getAllTechnicalStaffWithTasks(String statusFilter, String priorityFilter, String searchKeyword) {
        List<java.util.Map<String, Object>> result = new ArrayList<>();
        if (!checkConnection()) {
            return result;
        }
        
        try {
            // Get all technical staff users
            com.hlgenerator.dao.UserDAO userDAO = new com.hlgenerator.dao.UserDAO();
            List<com.hlgenerator.model.User> technicalStaff = userDAO.getUsersByRole("technical_staff");
            
            // Filter staff by search keyword if provided
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                String keyword = searchKeyword.toLowerCase().trim();
                List<com.hlgenerator.model.User> filteredStaff = new ArrayList<>();
                for (com.hlgenerator.model.User user : technicalStaff) {
                    boolean matches = false;
                    if (user.getFullName() != null && user.getFullName().toLowerCase().contains(keyword)) {
                        matches = true;
                    }
                    if (!matches && user.getEmail() != null && user.getEmail().toLowerCase().contains(keyword)) {
                        matches = true;
                    }
                    if (matches) {
                        filteredStaff.add(user);
                    }
                }
                technicalStaff = filteredStaff;
            }
            
            // For each user, get their assigned tasks with filters
            for (com.hlgenerator.model.User user : technicalStaff) {
                java.util.Map<String, Object> staffData = new java.util.HashMap<>();
                staffData.put("id", user.getId());
                staffData.put("fullName", user.getFullName());
                staffData.put("email", user.getEmail());
                staffData.put("role", user.getRole());
                
                // Build SQL with filters
                StringBuilder sqlBuilder = new StringBuilder();
                sqlBuilder.append("SELECT t.*, wo.work_order_number, wo.title AS work_order_title ");
                sqlBuilder.append("FROM tasks t ");
                sqlBuilder.append("JOIN task_assignments ta ON t.id = ta.task_id ");
                sqlBuilder.append("JOIN work_orders wo ON t.work_order_id = wo.id ");
                sqlBuilder.append("WHERE ta.user_id = ? AND ta.role = 'assignee' ");
                
                // Add status filter
                if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                    sqlBuilder.append("AND t.status = ? ");
                }
                
                // Add priority filter
                if (priorityFilter != null && !priorityFilter.trim().isEmpty()) {
                    sqlBuilder.append("AND t.priority = ? ");
                }
                
                // Add search keyword filter for task
                if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                    sqlBuilder.append("AND (LOWER(t.task_number) LIKE LOWER(?) OR LOWER(t.task_description) LIKE LOWER(?) OR LOWER(wo.work_order_number) LIKE LOWER(?)) ");
                }
                
                sqlBuilder.append("ORDER BY t.updated_at DESC, t.created_at DESC");
                
                List<java.util.Map<String, Object>> tasks = new ArrayList<>();
                try (PreparedStatement ps = connection.prepareStatement(sqlBuilder.toString())) {
                    int paramIndex = 1;
                    ps.setInt(paramIndex++, user.getId());
                    
                    if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                        ps.setString(paramIndex++, statusFilter);
                    }
                    
                    if (priorityFilter != null && !priorityFilter.trim().isEmpty()) {
                        ps.setString(paramIndex++, priorityFilter);
                    }
                    
                    if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                        String keywordPattern = "%" + searchKeyword.trim() + "%";
                        ps.setString(paramIndex++, keywordPattern);
                        ps.setString(paramIndex++, keywordPattern);
                        ps.setString(paramIndex++, keywordPattern);
                    }
                    
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            java.util.Map<String, Object> task = new java.util.HashMap<>();
                            task.put("id", rs.getInt("id"));
                            task.put("taskNumber", rs.getString("task_number"));
                            task.put("taskDescription", rs.getString("task_description"));
                            task.put("status", rs.getString("status"));
                            task.put("priority", rs.getString("priority"));
                            task.put("estimatedHours", rs.getBigDecimal("estimated_hours"));
                            task.put("startDate", rs.getTimestamp("start_date"));
                            task.put("deadline", rs.getTimestamp("deadline"));
                            task.put("completionDate", rs.getTimestamp("completion_date"));
                            task.put("workOrderNumber", rs.getString("work_order_number"));
                            task.put("workOrderTitle", rs.getString("work_order_title"));
                            tasks.add(task);
                        }
                    }
                }
                
                // Only add staff if they have tasks or if no filters are applied
                // If filters are applied and staff has no matching tasks, skip them
                boolean hasFilters = (statusFilter != null && !statusFilter.trim().isEmpty()) ||
                                 (priorityFilter != null && !priorityFilter.trim().isEmpty()) ||
                                 (searchKeyword != null && !searchKeyword.trim().isEmpty());
                
                if (!hasFilters || tasks.size() > 0) {
                    staffData.put("tasks", tasks);
                    result.add(staffData);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting technical staff with tasks", e);
        }
        
        return result;
    }
    
    /**
     * Get all technical staff tasks as flat list (for table display)
     * Returns list of tasks with staff information, with pagination support
     * @param statusFilter Filter by task status (null or empty for all)
     * @param priorityFilter Filter by task priority (null or empty for all)
     * @param searchKeyword Search keyword for staff name, task number, or task description (null or empty for all)
     * @param startDateFrom Filter by start date from (null for no filter)
     * @param startDateTo Filter by start date to (null for no filter)
     * @param deadlineFrom Filter by deadline from (null for no filter)
     * @param deadlineTo Filter by deadline to (null for no filter)
     * @param page Page number (1-based)
     * @param pageSize Page size
     * @return Map containing "data" (list of tasks) and "total" (total count)
     */
    public java.util.Map<String, Object> getTechnicalStaffTasksFlatList(String statusFilter, String priorityFilter, String searchKeyword, 
            java.sql.Date startDateFrom, java.sql.Date startDateTo, java.sql.Date deadlineFrom, java.sql.Date deadlineTo, 
            int page, int pageSize) {
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        List<java.util.Map<String, Object>> tasksList = new ArrayList<>();
        int total = 0;
        
        if (!checkConnection()) {
            result.put("data", tasksList);
            result.put("total", total);
            return result;
        }
        
        try {
            // Build count query
            StringBuilder countSql = new StringBuilder();
            countSql.append("SELECT COUNT(DISTINCT t.id) ");
            countSql.append("FROM tasks t ");
            countSql.append("JOIN task_assignments ta ON t.id = ta.task_id ");
            countSql.append("JOIN work_orders wo ON t.work_order_id = wo.id ");
            countSql.append("JOIN users u ON ta.user_id = u.id ");
            countSql.append("WHERE ta.role = 'assignee' AND u.role = 'technical_staff' ");
            
            // Build data query
            StringBuilder dataSql = new StringBuilder();
            dataSql.append("SELECT t.id, t.task_number, t.task_description, t.status, t.priority, ");
            dataSql.append("t.estimated_hours, t.start_date, t.deadline, t.completion_date, ");
            dataSql.append("wo.work_order_number, wo.title AS work_order_title, ");
            dataSql.append("u.id AS staff_id, u.full_name AS staff_name, u.email AS staff_email ");
            dataSql.append("FROM tasks t ");
            dataSql.append("JOIN task_assignments ta ON t.id = ta.task_id ");
            dataSql.append("JOIN work_orders wo ON t.work_order_id = wo.id ");
            dataSql.append("JOIN users u ON ta.user_id = u.id ");
            dataSql.append("WHERE ta.role = 'assignee' AND u.role = 'technical_staff' ");
            
            // Add filters
            List<String> conditions = new ArrayList<>();
            List<Object> params = new ArrayList<>();
            
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                conditions.add("t.status = ?");
                params.add(statusFilter);
            }
            
            if (priorityFilter != null && !priorityFilter.trim().isEmpty()) {
                conditions.add("t.priority = ?");
                params.add(priorityFilter);
            }
            
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                String keywordPattern = "%" + searchKeyword.trim() + "%";
                conditions.add("(LOWER(u.full_name) LIKE LOWER(?) OR LOWER(u.email) LIKE LOWER(?) OR LOWER(t.task_number) LIKE LOWER(?) OR LOWER(t.task_description) LIKE LOWER(?) OR LOWER(wo.work_order_number) LIKE LOWER(?))");
                params.add(keywordPattern);
                params.add(keywordPattern);
                params.add(keywordPattern);
                params.add(keywordPattern);
                params.add(keywordPattern);
            }
            
            // Filter by start date
            if (startDateFrom != null) {
                conditions.add("t.start_date >= ?");
                params.add(startDateFrom);
            }
            if (startDateTo != null) {
                conditions.add("t.start_date <= ?");
                params.add(startDateTo);
            }
            
            // Filter by deadline
            if (deadlineFrom != null) {
                conditions.add("t.deadline >= ?");
                params.add(deadlineFrom);
            }
            if (deadlineTo != null) {
                conditions.add("t.deadline <= ?");
                params.add(deadlineTo);
            }
            
            if (!conditions.isEmpty()) {
                String whereClause = "AND " + String.join(" AND ", conditions);
                countSql.append(whereClause);
                dataSql.append(whereClause);
            }
            
            dataSql.append("ORDER BY t.updated_at DESC, t.created_at DESC ");
            dataSql.append("LIMIT ? OFFSET ?");
            
            // Execute count query
            try (PreparedStatement countPs = connection.prepareStatement(countSql.toString())) {
                int paramIndex = 1;
                for (Object param : params) {
                    countPs.setObject(paramIndex++, param);
                }
                try (ResultSet countRs = countPs.executeQuery()) {
                    if (countRs.next()) {
                        total = countRs.getInt(1);
                    }
                }
            }
            
            // Execute data query
            try (PreparedStatement dataPs = connection.prepareStatement(dataSql.toString())) {
                int paramIndex = 1;
                for (Object param : params) {
                    dataPs.setObject(paramIndex++, param);
                }
                int offset = (page - 1) * pageSize;
                dataPs.setInt(paramIndex++, pageSize);
                dataPs.setInt(paramIndex, offset);
                
                try (ResultSet rs = dataPs.executeQuery()) {
                    while (rs.next()) {
                        java.util.Map<String, Object> task = new java.util.HashMap<>();
                        task.put("id", rs.getInt("id"));
                        task.put("taskNumber", rs.getString("task_number"));
                        task.put("taskDescription", rs.getString("task_description"));
                        task.put("status", rs.getString("status"));
                        task.put("priority", rs.getString("priority"));
                        task.put("estimatedHours", rs.getBigDecimal("estimated_hours"));
                        task.put("startDate", rs.getTimestamp("start_date"));
                        task.put("deadline", rs.getTimestamp("deadline"));
                        task.put("completionDate", rs.getTimestamp("completion_date"));
                        task.put("workOrderNumber", rs.getString("work_order_number"));
                        task.put("workOrderTitle", rs.getString("work_order_title"));
                        task.put("staffId", rs.getInt("staff_id"));
                        task.put("staffName", rs.getString("staff_name"));
                        task.put("staffEmail", rs.getString("staff_email"));
                        tasksList.add(task);
                    }
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting technical staff tasks flat list", e);
        }
        
        result.put("data", tasksList);
        result.put("total", total);
        return result;
    }
}

