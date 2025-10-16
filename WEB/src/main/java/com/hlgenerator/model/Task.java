package com.hlgenerator.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Task {
	private int id;
	private int workOrderId;
	private String taskNumber;
	private String taskDescription;
	private String status; // pending, in_progress, completed, cancelled
	private String priority; // low, medium, high, urgent
	private BigDecimal estimatedHours;
	private BigDecimal actualHours;
	private Timestamp startDate;
	private Timestamp completionDate;
	private String notes;
	private Timestamp createdAt;
	private Timestamp updatedAt;

	public int getId() { return id; }
	public void setId(int id) { this.id = id; }

	public int getWorkOrderId() { return workOrderId; }
	public void setWorkOrderId(int workOrderId) { this.workOrderId = workOrderId; }

	public String getTaskNumber() { return taskNumber; }
	public void setTaskNumber(String taskNumber) { this.taskNumber = taskNumber; }

	public String getTaskDescription() { return taskDescription; }
	public void setTaskDescription(String taskDescription) { this.taskDescription = taskDescription; }

	public String getStatus() { return status; }
	public void setStatus(String status) { this.status = status; }

	public String getPriority() { return priority; }
	public void setPriority(String priority) { this.priority = priority; }

	public BigDecimal getEstimatedHours() { return estimatedHours; }
	public void setEstimatedHours(BigDecimal estimatedHours) { this.estimatedHours = estimatedHours; }

	public BigDecimal getActualHours() { return actualHours; }
	public void setActualHours(BigDecimal actualHours) { this.actualHours = actualHours; }

	public Timestamp getStartDate() { return startDate; }
	public void setStartDate(Timestamp startDate) { this.startDate = startDate; }

	public Timestamp getCompletionDate() { return completionDate; }
	public void setCompletionDate(Timestamp completionDate) { this.completionDate = completionDate; }

	public String getNotes() { return notes; }
	public void setNotes(String notes) { this.notes = notes; }

	public Timestamp getCreatedAt() { return createdAt; }
	public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

	public Timestamp getUpdatedAt() { return updatedAt; }
	public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}


