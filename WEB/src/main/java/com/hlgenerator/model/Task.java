package com.hlgenerator.model;

import org.json.JSONArray;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Task {
	private int id;
	private int workOrderId;
	private String taskNumber;
	private String taskDescription;
	private String status; // pending, in_progress, completed, cancelled, rejected
	private String priority; // low, medium, high, urgent
	private BigDecimal estimatedHours;
	private BigDecimal actualHours;
	private Timestamp startDate;
	private Timestamp completionDate;
	private Timestamp deadline;
	private String rejectionReason;
	private String notes;
	private String workDescription; // NEW: Mô tả công việc đã thực hiện
	private String issuesFound; // NEW: Vấn đề phát sinh
	private BigDecimal completionPercentage; // NEW: Phần trăm hoàn thành
	private String attachments; // NEW: JSON string chứa danh sách file
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

	public Timestamp getDeadline() { return deadline; }
	public void setDeadline(Timestamp deadline) { this.deadline = deadline; }

	public String getRejectionReason() { return rejectionReason; }
	public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

	public String getNotes() { return notes; }
	public void setNotes(String notes) { this.notes = notes; }

	// NEW FIELDS
	public String getWorkDescription() { return workDescription; }
	public void setWorkDescription(String workDescription) { this.workDescription = workDescription; }

	public String getIssuesFound() { return issuesFound; }
	public void setIssuesFound(String issuesFound) { this.issuesFound = issuesFound; }

	public BigDecimal getCompletionPercentage() { return completionPercentage; }
	public void setCompletionPercentage(BigDecimal completionPercentage) { this.completionPercentage = completionPercentage; }

	public String getAttachments() { return attachments; }
	public void setAttachments(String attachments) { this.attachments = attachments; }

	// Helper method to parse attachments JSON to List
	public List<String> getAttachmentsList() {
		if (attachments == null || attachments.trim().isEmpty()) {
			return new ArrayList<>();
		}
		try {
			JSONArray arr = new JSONArray(attachments);
			List<String> list = new ArrayList<>();
			for (int i = 0; i < arr.length(); i++) {
				list.add(arr.getString(i));
			}
			return list;
		} catch (Exception e) {
			return new ArrayList<>();
		}
	}

	public Timestamp getCreatedAt() { return createdAt; }
	public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

	public Timestamp getUpdatedAt() { return updatedAt; }
	public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}


