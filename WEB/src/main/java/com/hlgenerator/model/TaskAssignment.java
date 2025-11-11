package com.hlgenerator.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class TaskAssignment {
	private int id;
	private int taskId;
	private int userId;
	private String role;
	private Timestamp assignedAt;

    // Optional joined fields for display
	private String taskNumber;
	private String taskDescription;
	private String taskStatus;
	private String taskPriority;
	private String workOrderNumber;
	private String workOrderTitle;
	private Timestamp scheduledDate; // from work_orders
	private Timestamp acknowledgedAt; // from tasks.acknowledged_at
	private Timestamp startDate;     // from tasks
	private Timestamp completionDate; // from tasks
	private Timestamp deadline; // from tasks.deadline
	private String rejectionReason;  // from tasks
	private BigDecimal estimatedHours; // from tasks.estimated_hours
	private String ticketDescription;  // from support_requests.description

	public int getId() { return id; }
	public void setId(int id) { this.id = id; }

	public int getTaskId() { return taskId; }
	public void setTaskId(int taskId) { this.taskId = taskId; }

	public int getUserId() { return userId; }
	public void setUserId(int userId) { this.userId = userId; }

	public String getRole() { return role; }
	public void setRole(String role) { this.role = role; }

	public Timestamp getAssignedAt() { return assignedAt; }
	public void setAssignedAt(Timestamp assignedAt) { this.assignedAt = assignedAt; }

	public String getTaskNumber() { return taskNumber; }
	public void setTaskNumber(String taskNumber) { this.taskNumber = taskNumber; }

	public String getTaskDescription() { return taskDescription; }
	public void setTaskDescription(String taskDescription) { this.taskDescription = taskDescription; }

	public String getTaskStatus() { return taskStatus; }
	public void setTaskStatus(String taskStatus) { this.taskStatus = taskStatus; }

	public String getTaskPriority() { return taskPriority; }
	public void setTaskPriority(String taskPriority) { this.taskPriority = taskPriority; }

	public String getWorkOrderNumber() { return workOrderNumber; }
	public void setWorkOrderNumber(String workOrderNumber) { this.workOrderNumber = workOrderNumber; }

	public String getWorkOrderTitle() { return workOrderTitle; }
	public void setWorkOrderTitle(String workOrderTitle) { this.workOrderTitle = workOrderTitle; }

	public Timestamp getScheduledDate() { return scheduledDate; }
	public void setScheduledDate(Timestamp scheduledDate) { this.scheduledDate = scheduledDate; }

	public Timestamp getAcknowledgedAt() { return acknowledgedAt; }
	public void setAcknowledgedAt(Timestamp acknowledgedAt) { this.acknowledgedAt = acknowledgedAt; }

	public Timestamp getStartDate() { return startDate; }
	public void setStartDate(Timestamp startDate) { this.startDate = startDate; }

	public Timestamp getCompletionDate() { return completionDate; }
	public void setCompletionDate(Timestamp completionDate) { this.completionDate = completionDate; }

	public Timestamp getDeadline() { return deadline; }
	public void setDeadline(Timestamp deadline) { this.deadline = deadline; }

	public String getRejectionReason() { return rejectionReason; }
	public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

	public BigDecimal getEstimatedHours() { return estimatedHours; }
	public void setEstimatedHours(BigDecimal estimatedHours) { this.estimatedHours = estimatedHours; }

	public String getTicketDescription() { return ticketDescription; }
	public void setTicketDescription(String ticketDescription) { this.ticketDescription = ticketDescription; }

	public org.json.JSONObject toJSON() {
		org.json.JSONObject obj = new org.json.JSONObject();
		obj.put("id", id);
		obj.put("taskId", taskId);
		obj.put("userId", userId);
		obj.put("role", role);
		obj.put("assignedAt", assignedAt);
		obj.put("taskNumber", taskNumber);
		obj.put("taskDescription", taskDescription);
		obj.put("taskStatus", taskStatus);
		obj.put("taskPriority", taskPriority);
		obj.put("workOrderNumber", workOrderNumber);
		obj.put("workOrderTitle", workOrderTitle);
		obj.put("scheduledDate", scheduledDate);
		obj.put("acknowledgedAt", acknowledgedAt);
		obj.put("startDate", startDate);
		obj.put("completionDate", completionDate);
		obj.put("deadline", deadline);
		obj.put("rejectionReason", rejectionReason);
		obj.put("estimatedHours", estimatedHours);
		obj.put("ticketDescription", ticketDescription);
		return obj;
	}
}


