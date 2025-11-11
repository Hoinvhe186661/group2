package com.hlgenerator.dao;

import com.hlgenerator.model.Task;
import com.hlgenerator.model.TaskAssignment;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TaskDAO extends DBConnect {

	public List<TaskAssignment> getAssignmentsForUser(int userId, String statusFilter) {
		List<TaskAssignment> results = new ArrayList<>();
		StringBuilder sql = new StringBuilder();
		sql.append("SELECT ta.id, ta.task_id, ta.user_id, ta.role, ta.assigned_at, ");
		sql.append("t.task_number, t.task_description, t.status AS task_status, t.priority AS task_priority, ");
		sql.append("t.estimated_hours, ");
		sql.append("wo.work_order_number, wo.title AS work_order_title, wo.scheduled_date, ");
		sql.append("wo.customer_id, wo.description AS work_order_description, ");
		sql.append("t.acknowledged_at, t.start_date, t.completion_date, t.rejection_reason AS rejection_reason, ");
		sql.append("(SELECT sr.description FROM support_requests sr ");
		sql.append(" WHERE sr.customer_id = wo.customer_id ");
		sql.append(" AND (sr.subject = wo.title OR wo.description LIKE CONCAT('%[TICKET_ID:', sr.id, ']%')) ");
		sql.append(" ORDER BY sr.created_at DESC LIMIT 1) AS ticket_description ");
		sql.append("FROM task_assignments ta ");
		sql.append("JOIN tasks t ON ta.task_id = t.id ");
		sql.append("JOIN work_orders wo ON t.work_order_id = wo.id ");
		sql.append("WHERE ta.user_id = ? ");
		if (statusFilter != null && !statusFilter.isEmpty()) {
			sql.append("AND t.status = ? ");
		}
		sql.append("ORDER BY t.updated_at DESC, t.created_at DESC");

		try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
			ps.setInt(1, userId);
			if (statusFilter != null && !statusFilter.isEmpty()) {
				ps.setString(2, statusFilter);
			}
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					TaskAssignment a = new TaskAssignment();
					a.setId(rs.getInt("id"));
					a.setTaskId(rs.getInt("task_id"));
					a.setUserId(rs.getInt("user_id"));
					a.setRole(rs.getString("role"));
					a.setAssignedAt(rs.getTimestamp("assigned_at"));
					a.setTaskNumber(rs.getString("task_number"));
					a.setTaskDescription(rs.getString("task_description"));
					a.setTaskStatus(rs.getString("task_status"));
					a.setTaskPriority(rs.getString("task_priority"));
					a.setWorkOrderNumber(rs.getString("work_order_number"));
					a.setWorkOrderTitle(rs.getString("work_order_title"));
					a.setScheduledDate(rs.getTimestamp("scheduled_date"));
					a.setAcknowledgedAt(rs.getTimestamp("acknowledged_at"));
					a.setStartDate(rs.getTimestamp("start_date"));
					a.setCompletionDate(rs.getTimestamp("completion_date"));
					a.setRejectionReason(rs.getString("rejection_reason"));
					a.setEstimatedHours(rs.getBigDecimal("estimated_hours"));
					a.setTicketDescription(rs.getString("ticket_description"));
					results.add(a);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return results;
	}

	public List<TaskAssignment> getAssignmentsForUser(
			int userId,
			String status,
			String priority,
			java.sql.Date scheduledFrom,
			java.sql.Date scheduledTo,
			String keyword
	) {
		List<TaskAssignment> results = new ArrayList<>();
		StringBuilder sql = new StringBuilder();
		sql.append("SELECT ta.id, ta.task_id, ta.user_id, ta.role, ta.assigned_at, ");
		sql.append("t.task_number, t.task_description, t.status AS task_status, t.priority AS task_priority, ");
		sql.append("t.estimated_hours, ");
		sql.append("wo.work_order_number, wo.title AS work_order_title, ");
		sql.append("wo.customer_id, wo.description AS work_order_description, ");
		sql.append("t.rejection_reason AS rejection_reason, ");
		sql.append("(SELECT sr.description FROM support_requests sr ");
		sql.append(" WHERE sr.customer_id = wo.customer_id ");
		sql.append(" AND (sr.subject = wo.title OR wo.description LIKE CONCAT('%[TICKET_ID:', sr.id, ']%')) ");
		sql.append(" ORDER BY sr.created_at DESC LIMIT 1) AS ticket_description ");
		sql.append("FROM task_assignments ta ");
		sql.append("JOIN tasks t ON ta.task_id = t.id ");
		sql.append("JOIN work_orders wo ON t.work_order_id = wo.id ");
		sql.append("WHERE ta.user_id = ? ");
		if (status != null && !status.isEmpty()) {
			sql.append("AND t.status = ? ");
		}
		if (priority != null && !priority.isEmpty()) {
			sql.append("AND t.priority = ? ");
		}
		if (scheduledFrom != null) {
			sql.append("AND wo.scheduled_date >= ? ");
		}
		if (scheduledTo != null) {
			sql.append("AND wo.scheduled_date <= ? ");
		}
		if (keyword != null && !keyword.isEmpty()) {
			sql.append("AND (LOWER(t.task_number) LIKE LOWER(?) OR LOWER(t.task_description) LIKE LOWER(?)) ");
		}
		sql.append("ORDER BY t.updated_at DESC, t.created_at DESC");

		try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
			int idx = 1;
			ps.setInt(idx++, userId);
			if (status != null && !status.isEmpty()) {
				ps.setString(idx++, status);
			}
			if (priority != null && !priority.isEmpty()) {
				ps.setString(idx++, priority);
			}
			if (scheduledFrom != null) {
				ps.setDate(idx++, scheduledFrom);
			}
		if (scheduledTo != null) {
			ps.setDate(idx++, scheduledTo);
		}
		if (keyword != null && !keyword.isEmpty()) {
			String like = "%" + keyword + "%";
			ps.setString(idx++, like);
			ps.setString(idx++, like);
		}
		try (ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				TaskAssignment a = new TaskAssignment();
				a.setId(rs.getInt("id"));
				a.setTaskId(rs.getInt("task_id"));
				a.setUserId(rs.getInt("user_id"));
				a.setRole(rs.getString("role"));
				a.setAssignedAt(rs.getTimestamp("assigned_at"));
				a.setTaskNumber(rs.getString("task_number"));
				a.setTaskDescription(rs.getString("task_description"));
				a.setTaskStatus(rs.getString("task_status"));
				a.setTaskPriority(rs.getString("task_priority"));
				a.setWorkOrderNumber(rs.getString("work_order_number"));
				a.setWorkOrderTitle(rs.getString("work_order_title"));
				a.setEstimatedHours(rs.getBigDecimal("estimated_hours"));
				a.setTicketDescription(rs.getString("ticket_description"));
				// No time fields selected in this query beyond scheduledDate; acknowledgedAt isn't needed here
				results.add(a);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return results;
	}

	public int countAssignmentsForUser(
			int userId,
			String status,
			String priority,
			java.sql.Date scheduledFrom,
			java.sql.Date scheduledTo,
			String keyword
	) {
		StringBuilder sql = new StringBuilder();
		sql.append("SELECT COUNT(*) AS cnt ");
		sql.append("FROM task_assignments ta ");
		sql.append("JOIN tasks t ON ta.task_id = t.id ");
		sql.append("JOIN work_orders wo ON t.work_order_id = wo.id ");
		sql.append("WHERE ta.user_id = ? ");
		if (status != null && !status.isEmpty()) sql.append("AND t.status = ? ");
		if (priority != null && !priority.isEmpty()) sql.append("AND t.priority = ? ");
		if (scheduledFrom != null) sql.append("AND wo.scheduled_date >= ? ");
		if (scheduledTo != null) sql.append("AND wo.scheduled_date <= ? ");
		if (keyword != null && !keyword.isEmpty()) {
			sql.append("AND (LOWER(t.task_number) LIKE LOWER(?) OR LOWER(t.task_description) LIKE LOWER(?)) ");
		}
		try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
			int idx = 1;
			ps.setInt(idx++, userId);
			if (status != null && !status.isEmpty()) ps.setString(idx++, status);
			if (priority != null && !priority.isEmpty()) ps.setString(idx++, priority);
		if (scheduledFrom != null) ps.setDate(idx++, scheduledFrom);
		if (scheduledTo != null) ps.setDate(idx++, scheduledTo);
		if (keyword != null && !keyword.isEmpty()) {
			String like = "%" + keyword + "%";
			ps.setString(idx++, like);
			ps.setString(idx++, like);
		}
		try (ResultSet rs = ps.executeQuery()) {
			if (rs.next()) return rs.getInt("cnt");
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return 0;
	}

	public List<TaskAssignment> getAssignmentsForUserPaged(
			int userId,
			String status,
			String priority,
			java.sql.Date scheduledFrom,
			java.sql.Date scheduledTo,
			String keyword,
			int limit,
			int offset
	) {
		List<TaskAssignment> results = new ArrayList<>();
		StringBuilder sql = new StringBuilder();
		sql.append("SELECT ta.id, ta.task_id, ta.user_id, ta.role, ta.assigned_at, ");
		sql.append("t.task_number, t.task_description, t.status AS task_status, t.priority AS task_priority, ");
		sql.append("t.estimated_hours, ");
		sql.append("wo.work_order_number, wo.title AS work_order_title, wo.scheduled_date, ");
		sql.append("wo.customer_id, wo.description AS work_order_description, ");
		sql.append("t.acknowledged_at, t.start_date, t.completion_date, t.rejection_reason AS rejection_reason, ");
		sql.append("(SELECT sr.description FROM support_requests sr ");
		sql.append(" WHERE sr.customer_id = wo.customer_id ");
		sql.append(" AND (sr.subject = wo.title OR wo.description LIKE CONCAT('%[TICKET_ID:', sr.id, ']%')) ");
		sql.append(" ORDER BY sr.created_at DESC LIMIT 1) AS ticket_description ");
		sql.append("FROM task_assignments ta ");
		sql.append("JOIN tasks t ON ta.task_id = t.id ");
		sql.append("JOIN work_orders wo ON t.work_order_id = wo.id ");
		sql.append("WHERE ta.user_id = ? ");
		if (status != null && !status.isEmpty()) sql.append("AND t.status = ? ");
		if (priority != null && !priority.isEmpty()) sql.append("AND t.priority = ? ");
		if (scheduledFrom != null) sql.append("AND wo.scheduled_date >= ? ");
		if (scheduledTo != null) sql.append("AND wo.scheduled_date <= ? ");
		if (keyword != null && !keyword.isEmpty()) {
			sql.append("AND (LOWER(t.task_number) LIKE LOWER(?) OR LOWER(t.task_description) LIKE LOWER(?)) ");
		}
		sql.append("ORDER BY t.updated_at DESC, t.created_at DESC ");
		sql.append("LIMIT ? OFFSET ?");

		try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
			int idx = 1;
			ps.setInt(idx++, userId);
			if (status != null && !status.isEmpty()) ps.setString(idx++, status);
			if (priority != null && !priority.isEmpty()) ps.setString(idx++, priority);
		if (scheduledFrom != null) ps.setDate(idx++, scheduledFrom);
		if (scheduledTo != null) ps.setDate(idx++, scheduledTo);
		if (keyword != null && !keyword.isEmpty()) {
			String like = "%" + keyword + "%";
			ps.setString(idx++, like);
			ps.setString(idx++, like);
		}
		ps.setInt(idx++, limit);
		ps.setInt(idx, offset);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					TaskAssignment a = new TaskAssignment();
					a.setId(rs.getInt("id"));
					a.setTaskId(rs.getInt("task_id"));
					a.setUserId(rs.getInt("user_id"));
					a.setRole(rs.getString("role"));
					a.setAssignedAt(rs.getTimestamp("assigned_at"));
					a.setTaskNumber(rs.getString("task_number"));
					a.setTaskDescription(rs.getString("task_description"));
					a.setTaskStatus(rs.getString("task_status"));
					a.setTaskPriority(rs.getString("task_priority"));
					a.setWorkOrderNumber(rs.getString("work_order_number"));
					a.setWorkOrderTitle(rs.getString("work_order_title"));
					a.setRejectionReason(rs.getString("rejection_reason"));
					a.setScheduledDate(rs.getTimestamp("scheduled_date"));
					a.setAcknowledgedAt(rs.getTimestamp("acknowledged_at"));
					a.setStartDate(rs.getTimestamp("start_date"));
					a.setCompletionDate(rs.getTimestamp("completion_date"));
					a.setEstimatedHours(rs.getBigDecimal("estimated_hours"));
					a.setTicketDescription(rs.getString("ticket_description"));
					results.add(a);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return results;
	}

	public Task getTaskById(int taskId) {
		String sql = "SELECT * FROM tasks WHERE id = ?";
		try (PreparedStatement ps = connection.prepareStatement(sql)) {
			ps.setInt(1, taskId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return mapTask(rs);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return null;
	}

	public TaskAssignment getAssignmentDetail(int taskId, int userId) {
		StringBuilder sql = new StringBuilder();
		sql.append("SELECT ta.id, ta.task_id, ta.user_id, ta.role, ta.assigned_at, ");
		sql.append("t.task_number, t.task_description, t.status AS task_status, t.priority AS task_priority, ");
		sql.append("t.estimated_hours, ");
		sql.append("wo.work_order_number, wo.title AS work_order_title, wo.scheduled_date, ");
		sql.append("wo.customer_id, wo.description AS work_order_description, ");
		sql.append("t.acknowledged_at, t.start_date, t.completion_date, t.rejection_reason AS rejection_reason, ");
		sql.append("(SELECT sr.description FROM support_requests sr ");
		sql.append(" WHERE sr.customer_id = wo.customer_id ");
		sql.append(" AND (sr.subject = wo.title OR wo.description LIKE CONCAT('%[TICKET_ID:', sr.id, ']%')) ");
		sql.append(" ORDER BY sr.created_at DESC LIMIT 1) AS ticket_description ");
		sql.append("FROM task_assignments ta ");
		sql.append("JOIN tasks t ON ta.task_id = t.id ");
		sql.append("JOIN work_orders wo ON t.work_order_id = wo.id ");
		sql.append("WHERE ta.task_id = ? AND ta.user_id = ? ");
		sql.append("LIMIT 1");

		try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
			ps.setInt(1, taskId);
			ps.setInt(2, userId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					TaskAssignment a = new TaskAssignment();
					a.setId(rs.getInt("id"));
					a.setTaskId(rs.getInt("task_id"));
					a.setUserId(rs.getInt("user_id"));
					a.setRole(rs.getString("role"));
					a.setAssignedAt(rs.getTimestamp("assigned_at"));
					a.setTaskNumber(rs.getString("task_number"));
					a.setTaskDescription(rs.getString("task_description"));
					a.setTaskStatus(rs.getString("task_status"));
					a.setTaskPriority(rs.getString("task_priority"));
					a.setWorkOrderNumber(rs.getString("work_order_number"));
					a.setWorkOrderTitle(rs.getString("work_order_title"));
					a.setScheduledDate(rs.getTimestamp("scheduled_date"));
					a.setAcknowledgedAt(rs.getTimestamp("acknowledged_at"));
					a.setStartDate(rs.getTimestamp("start_date"));
					a.setCompletionDate(rs.getTimestamp("completion_date"));
					a.setRejectionReason(rs.getString("rejection_reason"));
					a.setEstimatedHours(rs.getBigDecimal("estimated_hours"));
					a.setTicketDescription(rs.getString("ticket_description"));
					return a;
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return null;
	}

	// New: acknowledge task (user clicks "Nhận")
	public boolean acknowledgeTask(int taskId) {
		String sql = "UPDATE tasks SET status = 'in_progress', acknowledged_at = NOW(), updated_at = NOW() WHERE id = ?";
		try (PreparedStatement ps = connection.prepareStatement(sql)) {
			ps.setInt(1, taskId);
			return ps.executeUpdate() > 0;
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}

	public boolean updateTaskStatus(int taskId, String status, Timestamp startDate, Timestamp completionDate, String notes, java.math.BigDecimal actualHours) {
		StringBuilder sql = new StringBuilder("UPDATE tasks SET updated_at = NOW()");
		List<Object> params = new ArrayList<>();
		if (status != null) { sql.append(", status = ?"); params.add(status); }
		if (startDate != null) { sql.append(", start_date = ?"); params.add(startDate); }
		if (completionDate != null) { sql.append(", completion_date = ?"); params.add(completionDate); }
		if (notes != null) { sql.append(", notes = ?"); params.add(notes); }
		if (actualHours != null) { sql.append(", actual_hours = ?"); params.add(actualHours); }
		sql.append(" WHERE id = ?");
		params.add(taskId);

		try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
			for (int i = 0; i < params.size(); i++) {
				Object p = params.get(i);
				if (p instanceof String) ps.setString(i + 1, (String)p);
				else if (p instanceof Timestamp) ps.setTimestamp(i + 1, (Timestamp)p);
				else if (p instanceof java.math.BigDecimal) ps.setBigDecimal(i + 1, (java.math.BigDecimal)p);
				else if (p instanceof Integer) ps.setInt(i + 1, (Integer)p);
				else ps.setObject(i + 1, p);
			}
			return ps.executeUpdate() > 0;
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}

	public boolean rejectTask(int taskId, String rejectionReason) {
		System.out.println("TaskDAO - rejectTask called with taskId: " + taskId + ", reason: " + rejectionReason);
		String sql = "UPDATE tasks SET status = 'rejected', rejection_reason = ?, completion_percentage = 0, updated_at = NOW() WHERE id = ?";
		try (PreparedStatement ps = connection.prepareStatement(sql)) {
			ps.setString(1, rejectionReason);
			ps.setInt(2, taskId);
			int result = ps.executeUpdate();
			System.out.println("TaskDAO - rejectTask result: " + result);
			return result > 0;
		} catch (SQLException e) {
			System.out.println("TaskDAO - rejectTask error: " + e.getMessage());
			e.printStackTrace();
			return false;
		}
	}

	// NEW METHOD: Complete task with detailed report
	public boolean completeTask(int taskId, java.math.BigDecimal actualHours, 
	                           java.math.BigDecimal completionPercentage,
	                           String workDescription, String issuesFound, 
	                           String notes, List<String> attachments) {
		String sql = "UPDATE tasks SET " +
		             "status = 'completed', " +
		             "completion_date = NOW(), " +
		             "actual_hours = ?, " +
		             "completion_percentage = ?, " +
		             "work_description = ?, " +
		             "issues_found = ?, " +
		             "notes = ?, " +
		             "attachments = ?, " +
		             "updated_at = NOW() " +
		             "WHERE id = ?";
		
		try (PreparedStatement ps = connection.prepareStatement(sql)) {
			ps.setBigDecimal(1, actualHours);
			ps.setBigDecimal(2, completionPercentage);
			ps.setString(3, workDescription);
			ps.setString(4, issuesFound);
			ps.setString(5, notes);
			
			// Convert List<String> to JSON string
			String attachmentsJson = null;
			if (attachments != null && !attachments.isEmpty()) {
				org.json.JSONArray jsonArray = new org.json.JSONArray(attachments);
				attachmentsJson = jsonArray.toString();
			}
			ps.setString(6, attachmentsJson);
			ps.setInt(7, taskId);
			
			return ps.executeUpdate() > 0;
			
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}

	private Task mapTask(ResultSet rs) throws SQLException {
		Task t = new Task();
		t.setId(rs.getInt("id"));
		t.setWorkOrderId(rs.getInt("work_order_id"));
		t.setTaskNumber(rs.getString("task_number"));
		t.setTaskDescription(rs.getString("task_description"));
		t.setStatus(rs.getString("status"));
		t.setPriority(rs.getString("priority"));
		t.setEstimatedHours(rs.getBigDecimal("estimated_hours"));
		t.setActualHours(rs.getBigDecimal("actual_hours"));
		t.setStartDate(rs.getTimestamp("start_date"));
		t.setCompletionDate(rs.getTimestamp("completion_date"));
		t.setRejectionReason(rs.getString("rejection_reason"));
		t.setNotes(rs.getString("notes"));
		// NEW FIELDS
		t.setWorkDescription(rs.getString("work_description"));
		t.setIssuesFound(rs.getString("issues_found"));
		t.setCompletionPercentage(rs.getBigDecimal("completion_percentage"));
		t.setAttachments(rs.getString("attachments"));
		t.setCreatedAt(rs.getTimestamp("created_at"));
		t.setUpdatedAt(rs.getTimestamp("updated_at"));
		return t;
	}
}


