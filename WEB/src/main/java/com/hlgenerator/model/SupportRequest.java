package com.hlgenerator.model;

import java.sql.Timestamp;

public class SupportRequest {
    private int id;
    private String ticketNumber;
    private int customerId;
    private String subject;
    private String description;
    private String category; // 'technical', 'billing', 'general', 'complaint'
    private String priority; // 'low', 'medium', 'high', 'urgent'
    private String status; // 'open', 'in_progress', 'resolved', 'closed'
    private Integer assignedTo; // User ID of assigned support staff
    private String history; // JSON string for request history
    private String resolution;
    private Timestamp createdAt;
    private Timestamp resolvedAt;

    // Constructors
    public SupportRequest() {}

    public SupportRequest(String ticketNumber, int customerId, String subject, 
                         String description, String category, String priority, 
                         String status, Integer assignedTo) {
        this.ticketNumber = ticketNumber;
        this.customerId = customerId;
        this.subject = subject;
        this.description = description;
        this.category = category;
        this.priority = priority;
        this.status = status;
        this.assignedTo = assignedTo;
    }

    public SupportRequest(int id, String ticketNumber, int customerId, String subject,
                         String description, String category, String priority, String status,
                         Integer assignedTo, String history, String resolution,
                         Timestamp createdAt, Timestamp resolvedAt) {
        this.id = id;
        this.ticketNumber = ticketNumber;
        this.customerId = customerId;
        this.subject = subject;
        this.description = description;
        this.category = category;
        this.priority = priority;
        this.status = status;
        this.assignedTo = assignedTo;
        this.history = history;
        this.resolution = resolution;
        this.createdAt = createdAt;
        this.resolvedAt = resolvedAt;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTicketNumber() {
        return ticketNumber;
    }

    public void setTicketNumber(String ticketNumber) {
        this.ticketNumber = ticketNumber;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(Integer assignedTo) {
        this.assignedTo = assignedTo;
    }

    public String getHistory() {
        return history;
    }

    public void setHistory(String history) {
        this.history = history;
    }

    public String getResolution() {
        return resolution;
    }

    public void setResolution(String resolution) {
        this.resolution = resolution;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getResolvedAt() {
        return resolvedAt;
    }

    public void setResolvedAt(Timestamp resolvedAt) {
        this.resolvedAt = resolvedAt;
    }

    // Helper methods
    public String getCategoryDisplayName() {
        switch (category) {
            case "technical":
                return "Kỹ thuật";
            case "billing":
                return "Thanh toán";
            case "general":
                return "Tổng quát";
            case "complaint":
                return "Khiếu nại";
            default:
                return category;
        }
    }

    public String getPriorityDisplayName() {
        switch (priority) {
            case "low":
                return "Thấp";
            case "medium":
                return "Trung bình";
            case "high":
                return "Cao";
            case "urgent":
                return "Khẩn cấp";
            default:
                return priority;
        }
    }

    public String getStatusDisplayName() {
        switch (status) {
            case "open":
                return "Mở";
            case "in_progress":
                return "Đang xử lý";
            case "resolved":
                return "Đã giải quyết";
            case "closed":
                return "Đã đóng";
            default:
                return status;
        }
    }

    public String getPriorityColor() {
        switch (priority) {
            case "low":
                return "success";
            case "medium":
                return "warning";
            case "high":
                return "danger";
            case "urgent":
                return "danger";
            default:
                return "secondary";
        }
    }

    public String getStatusColor() {
        switch (status) {
            case "open":
                return "primary";
            case "in_progress":
                return "warning";
            case "resolved":
                return "success";
            case "closed":
                return "secondary";
            default:
                return "secondary";
        }
    }

    public boolean isResolved() {
        return "resolved".equals(status) || "closed".equals(status);
    }

    public boolean isOpen() {
        return "open".equals(status) || "in_progress".equals(status);
    }

    @Override
    public String toString() {
        return "SupportRequest{" +
                "id=" + id +
                ", ticketNumber='" + ticketNumber + '\'' +
                ", customerId=" + customerId +
                ", subject='" + subject + '\'' +
                ", category='" + category + '\'' +
                ", priority='" + priority + '\'' +
                ", status='" + status + '\'' +
                ", assignedTo=" + assignedTo +
                ", createdAt=" + createdAt +
                '}';
    }
}
