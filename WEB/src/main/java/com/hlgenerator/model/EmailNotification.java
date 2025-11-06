package com.hlgenerator.model;

import java.sql.Timestamp;

public class EmailNotification {
    private int id;
    private String subject;
    private String content;
    private String emailType; // 'internal' or 'marketing'
    private String recipientRoles; // JSON array string
    private String recipientEmails; // JSON array string
    private int recipientCount;
    private int successCount;
    private int failedCount;
    private String failedRecipients; // JSON array string
    private String status; // 'pending' (chờ gửi), 'sending' (đang gửi), 'completed' (hoàn thành)
    private Integer sentBy; // User ID
    private String sentByName;
    private Timestamp scheduledAt;
    private Timestamp sentAt;
    private Timestamp completedAt;
    private String errorMessage;
    private String attachments; // JSON array string of file paths
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Constructors
    public EmailNotification() {}

    public EmailNotification(String subject, String content, String emailType, 
                            String recipientRoles, String recipientEmails, 
                            Integer sentBy, String sentByName) {
        this.subject = subject;
        this.content = content;
        this.emailType = emailType;
        this.recipientRoles = recipientRoles;
        this.recipientEmails = recipientEmails;
        this.sentBy = sentBy;
        this.sentByName = sentByName;
        this.status = "pending";
        this.recipientCount = 0;
        this.successCount = 0;
        this.failedCount = 0;
    }

    // Full constructor
    public EmailNotification(int id, String subject, String content, String emailType,
                            String recipientRoles, String recipientEmails,
                            int recipientCount, int successCount, int failedCount,
                            String failedRecipients, String status, Integer sentBy,
                            String sentByName, Timestamp scheduledAt, Timestamp sentAt,
                            Timestamp completedAt, String errorMessage,
                            Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.subject = subject;
        this.content = content;
        this.emailType = emailType;
        this.recipientRoles = recipientRoles;
        this.recipientEmails = recipientEmails;
        this.recipientCount = recipientCount;
        this.successCount = successCount;
        this.failedCount = failedCount;
        this.failedRecipients = failedRecipients;
        this.status = status;
        this.sentBy = sentBy;
        this.sentByName = sentByName;
        this.scheduledAt = scheduledAt;
        this.sentAt = sentAt;
        this.completedAt = completedAt;
        this.errorMessage = errorMessage;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getEmailType() {
        return emailType;
    }

    public void setEmailType(String emailType) {
        this.emailType = emailType;
    }

    public String getRecipientRoles() {
        return recipientRoles;
    }

    public void setRecipientRoles(String recipientRoles) {
        this.recipientRoles = recipientRoles;
    }

    public String getRecipientEmails() {
        return recipientEmails;
    }

    public void setRecipientEmails(String recipientEmails) {
        this.recipientEmails = recipientEmails;
    }

    public int getRecipientCount() {
        return recipientCount;
    }

    public void setRecipientCount(int recipientCount) {
        this.recipientCount = recipientCount;
    }

    public int getSuccessCount() {
        return successCount;
    }

    public void setSuccessCount(int successCount) {
        this.successCount = successCount;
    }

    public int getFailedCount() {
        return failedCount;
    }

    public void setFailedCount(int failedCount) {
        this.failedCount = failedCount;
    }

    public String getFailedRecipients() {
        return failedRecipients;
    }

    public void setFailedRecipients(String failedRecipients) {
        this.failedRecipients = failedRecipients;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getSentBy() {
        return sentBy;
    }

    public void setSentBy(Integer sentBy) {
        this.sentBy = sentBy;
    }

    public String getSentByName() {
        return sentByName;
    }

    public void setSentByName(String sentByName) {
        this.sentByName = sentByName;
    }

    public Timestamp getScheduledAt() {
        return scheduledAt;
    }

    public void setScheduledAt(Timestamp scheduledAt) {
        this.scheduledAt = scheduledAt;
    }

    public Timestamp getSentAt() {
        return sentAt;
    }

    public void setSentAt(Timestamp sentAt) {
        this.sentAt = sentAt;
    }

    public Timestamp getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(Timestamp completedAt) {
        this.completedAt = completedAt;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public String getAttachments() {
        return attachments;
    }

    public void setAttachments(String attachments) {
        this.attachments = attachments;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    // Helper methods
    public String getEmailTypeDisplayName() {
        if ("internal".equals(emailType)) {
            return "Nội bộ";
        } else if ("marketing".equals(emailType)) {
            return "Marketing";
        }
        return emailType;
    }

    public String getStatusDisplayName() {
        switch (status) {
            case "pending":
                return "Chờ gửi";
            case "sending":
                return "Đang gửi";
            case "completed":
                return "Hoàn thành";
            default:
                return status != null ? status : "Chờ gửi";
        }
    }

    public String getStatusBadgeClass() {
        switch (status) {
            case "pending":
                return "label-warning";
            case "sending":
                return "label-info";
            case "completed":
                return "label-success";
            default:
                return "label-default";
        }
    }

    @Override
    public String toString() {
        return "EmailNotification{" +
                "id=" + id +
                ", subject='" + subject + '\'' +
                ", emailType='" + emailType + '\'' +
                ", status='" + status + '\'' +
                ", recipientCount=" + recipientCount +
                ", successCount=" + successCount +
                ", failedCount=" + failedCount +
                '}';
    }
}

