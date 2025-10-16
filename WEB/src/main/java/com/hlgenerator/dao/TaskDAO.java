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
		sql.append("wo.work_order_number, wo.title AS work_order_title, wo.scheduled_date, ");
		sql.append("t.start_date, t.completion_date ");
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
					a.setStartDate(rs.getTimestamp("start_date"));
					a.setCompletionDate(rs.getTimestamp("completion_date"));
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
		sql.append("wo.work_order_number, wo.title AS work_order_title ");
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
			sql.append("AND ( ");
			sql.append("t.task_number LIKE ? OR t.task_description LIKE ? OR ");
			sql.append("wo.work_order_number LIKE ? OR wo.title LIKE ? ");
			sql.append(") ");
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
			sql.append("AND (t.task_number LIKE ? OR t.task_description LIKE ? OR wo.work_order_number LIKE ? OR wo.title LIKE ?) ");
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
		sql.append("wo.work_order_number, wo.title AS work_order_title, wo.scheduled_date, ");
		sql.append("t.start_date, t.completion_date ");
		sql.append("FROM task_assignments ta ");
		sql.append("JOIN tasks t ON ta.task_id = t.id ");
		sql.append("JOIN work_orders wo ON t.work_order_id = wo.id ");
		sql.append("WHERE ta.user_id = ? ");
		if (status != null && !status.isEmpty()) sql.append("AND t.status = ? ");
		if (priority != null && !priority.isEmpty()) sql.append("AND t.priority = ? ");
		if (scheduledFrom != null) sql.append("AND wo.scheduled_date >= ? ");
		if (scheduledTo != null) sql.append("AND wo.scheduled_date <= ? ");
		if (keyword != null && !keyword.isEmpty()) {
			sql.append("AND (t.task_number LIKE ? OR t.task_description LIKE ? OR wo.work_order_number LIKE ? OR wo.title LIKE ?) ");
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
					a.setScheduledDate(rs.getTimestamp("scheduled_date"));
					a.setStartDate(rs.getTimestamp("start_date"));
					a.setCompletionDate(rs.getTimestamp("completion_date"));
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
		t.setNotes(rs.getString("notes"));
		t.setCreatedAt(rs.getTimestamp("created_at"));
		t.setUpdatedAt(rs.getTimestamp("updated_at"));
		return t;
	}
}


