package com.hlgenerator.model;

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
	private Timestamp startDate;     // from tasks
	private Timestamp completionDate; // from tasks

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

	public Timestamp getStartDate() { return startDate; }
	public void setStartDate(Timestamp startDate) { this.startDate = startDate; }

	public Timestamp getCompletionDate() { return completionDate; }
	public void setCompletionDate(Timestamp completionDate) { this.completionDate = completionDate; }
}


