package com.hlgenerator.dao;

import com.hlgenerator.model.EmailNotification;
import org.json.JSONArray;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EmailNotificationDAO extends DBConnect {
    private static final Logger logger = Logger.getLogger(EmailNotificationDAO.class.getName());

    public EmailNotificationDAO() {
        super();
        if (connection == null) {
            logger.severe("EmailNotificationDAO: Database connection failed during initialization");
        }
    }

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

    // Add new email notification record
    public boolean addEmailNotification(EmailNotification notification) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "INSERT INTO email_notifications (subject, content, email_type, recipient_roles, " +
                    "recipient_emails, recipient_count, success_count, failed_count, failed_recipients, " +
                    "status, sent_by, sent_by_name, scheduled_at, attachments) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, notification.getSubject());
            ps.setString(2, notification.getContent());
            ps.setString(3, notification.getEmailType());
            ps.setString(4, notification.getRecipientRoles());
            ps.setString(5, notification.getRecipientEmails());
            ps.setInt(6, notification.getRecipientCount());
            ps.setInt(7, notification.getSuccessCount());
            ps.setInt(8, notification.getFailedCount());
            ps.setString(9, notification.getFailedRecipients());
            ps.setString(10, notification.getStatus());
            if (notification.getSentBy() == null) {
                ps.setNull(11, Types.INTEGER);
            } else {
                ps.setInt(11, notification.getSentBy());
            }
            ps.setString(12, notification.getSentByName());
            if (notification.getScheduledAt() == null) {
                ps.setNull(13, Types.TIMESTAMP);
            } else {
                ps.setTimestamp(13, notification.getScheduledAt());
            }
            ps.setString(14, notification.getAttachments());
            
            int result = ps.executeUpdate();
            if (result > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        notification.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
            return false;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error adding email notification", e);
            return false;
        }
    }

    // Update email notification status and results
    public boolean updateEmailNotification(EmailNotification notification) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "UPDATE email_notifications SET subject=?, content=?, email_type=?, " +
                    "recipient_roles=?, recipient_emails=?, recipient_count=?, success_count=?, " +
                    "failed_count=?, failed_recipients=?, status=?, sent_by=?, sent_by_name=?, " +
                    "scheduled_at=?, sent_at=?, completed_at=?, error_message=?, attachments=?, " +
                    "updated_at=CURRENT_TIMESTAMP WHERE id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, notification.getSubject());
            ps.setString(2, notification.getContent());
            ps.setString(3, notification.getEmailType());
            ps.setString(4, notification.getRecipientRoles());
            ps.setString(5, notification.getRecipientEmails());
            ps.setInt(6, notification.getRecipientCount());
            ps.setInt(7, notification.getSuccessCount());
            ps.setInt(8, notification.getFailedCount());
            ps.setString(9, notification.getFailedRecipients());
            ps.setString(10, notification.getStatus());
            if (notification.getSentBy() == null) {
                ps.setNull(11, Types.INTEGER);
            } else {
                ps.setInt(11, notification.getSentBy());
            }
            ps.setString(12, notification.getSentByName());
            if (notification.getScheduledAt() == null) {
                ps.setNull(13, Types.TIMESTAMP);
            } else {
                ps.setTimestamp(13, notification.getScheduledAt());
            }
            if (notification.getSentAt() == null) {
                ps.setNull(14, Types.TIMESTAMP);
            } else {
                ps.setTimestamp(14, notification.getSentAt());
            }
            if (notification.getCompletedAt() == null) {
                ps.setNull(15, Types.TIMESTAMP);
            } else {
                ps.setTimestamp(15, notification.getCompletedAt());
            }
            ps.setString(16, notification.getErrorMessage());
            ps.setString(17, notification.getAttachments());
            ps.setInt(18, notification.getId());
            
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating email notification", e);
            return false;
        }
    }

    // Get email notification by ID
    public EmailNotification getEmailNotificationById(int id) {
        if (!checkConnection()) {
            return null;
        }
        String sql = "SELECT * FROM email_notifications WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return createEmailNotificationFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting email notification by ID: " + id, e);
        }
        return null;
    }

    // Get all email notifications
    public List<EmailNotification> getAllEmailNotifications() {
        List<EmailNotification> notifications = new ArrayList<>();
        if (!checkConnection()) {
            return notifications;
        }
        String sql = "SELECT * FROM email_notifications ORDER BY created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                notifications.add(createEmailNotificationFromResultSet(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting all email notifications", e);
        }
        return notifications;
    }

    // Get email notifications with filters (with pagination)
    public List<EmailNotification> getEmailNotificationsWithFilters(String emailType, String status, 
                                                                   String searchTerm, 
                                                                   String startDate, String endDate,
                                                                   int offset, int limit) {
        List<EmailNotification> notifications = new ArrayList<>();
        if (!checkConnection()) {
            return notifications;
        }
        
        StringBuilder sql = new StringBuilder("SELECT * FROM email_notifications WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        if (emailType != null && !emailType.isEmpty()) {
            sql.append(" AND email_type = ?");
            params.add(emailType);
        }
        
        if (status != null && !status.isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status);
        }
        
        if (searchTerm != null && !searchTerm.isEmpty()) {
            sql.append(" AND (subject LIKE ? OR content LIKE ? OR sent_by_name LIKE ?)");
            String searchPattern = "%" + searchTerm + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND DATE(created_at) >= ?");
            params.add(startDate);
        }
        
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND DATE(created_at) <= ?");
            params.add(endDate);
        }
        
        sql.append(" ORDER BY created_at DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    notifications.add(createEmailNotificationFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting email notifications with filters", e);
        }
        return notifications;
    }
    
    // Get total count of email notifications with filters (for pagination)
    public int getEmailNotificationsCount(String emailType, String status, 
                                         String searchTerm, 
                                         String startDate, String endDate) {
        if (!checkConnection()) {
            return 0;
        }
        
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) as total FROM email_notifications WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        if (emailType != null && !emailType.isEmpty()) {
            sql.append(" AND email_type = ?");
            params.add(emailType);
        }
        
        if (status != null && !status.isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status);
        }
        
        if (searchTerm != null && !searchTerm.isEmpty()) {
            sql.append(" AND (subject LIKE ? OR content LIKE ? OR sent_by_name LIKE ?)");
            String searchPattern = "%" + searchTerm + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND DATE(created_at) >= ?");
            params.add(startDate);
        }
        
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND DATE(created_at) <= ?");
            params.add(endDate);
        }
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting email notifications count", e);
        }
        return 0;
    }
    
    // Legacy method for backward compatibility
    public List<EmailNotification> getEmailNotificationsWithFilters(String emailType, String status, 
                                                                   String searchTerm, 
                                                                   String startDate, String endDate) {
        return getEmailNotificationsWithFilters(emailType, status, searchTerm, startDate, endDate, 0, Integer.MAX_VALUE);
    }

    // Update status
    public boolean updateStatus(int id, String status) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "UPDATE email_notifications SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating email notification status", e);
            return false;
        }
    }

    // Update sending results
    public boolean updateSendingResults(int id, int successCount, int failedCount, 
                                       String failedRecipients, String status, 
                                       String errorMessage) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "UPDATE email_notifications SET success_count = ?, failed_count = ?, " +
                    "failed_recipients = ?, status = ?, error_message = ?, " +
                    "completed_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, successCount);
            ps.setInt(2, failedCount);
            ps.setString(3, failedRecipients);
            ps.setString(4, status);
            ps.setString(5, errorMessage);
            ps.setInt(6, id);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating sending results", e);
            return false;
        }
    }

    // Set sent_at timestamp
    public boolean setSentAt(int id) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "UPDATE email_notifications SET sent_at = CURRENT_TIMESTAMP, " +
                    "status = 'sending', updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error setting sent_at", e);
            return false;
        }
    }

    // Update single email result immediately (optimized for parallel sending)
    public boolean updateSingleEmailResult(int notificationId, boolean success, String email) {
        if (!checkConnection()) {
            return false;
        }
        String sql;
        if (success) {
            // Increment success_count
            sql = "UPDATE email_notifications SET success_count = success_count + 1, " +
                  "updated_at = CURRENT_TIMESTAMP WHERE id = ?";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, notificationId);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Error updating single email success for notification: " + notificationId, e);
                return false;
            }
        } else {
            // Increment failed_count and add to failed_recipients
            // First get current failed_recipients
            String currentFailed = null;
            String selectSql = "SELECT failed_recipients FROM email_notifications WHERE id = ?";
            try (PreparedStatement selectPs = connection.prepareStatement(selectSql)) {
                selectPs.setInt(1, notificationId);
                try (ResultSet rs = selectPs.executeQuery()) {
                    if (rs.next()) {
                        currentFailed = rs.getString("failed_recipients");
                    }
                }
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Error reading failed_recipients for notification: " + notificationId, e);
            }
            
            // Build new failed_recipients JSON
            String newFailedRecipients;
            try {
                JSONArray failedArray;
                if (currentFailed == null || currentFailed.trim().isEmpty() || currentFailed.equals("[]")) {
                    failedArray = new JSONArray();
                } else {
                    failedArray = new JSONArray(currentFailed);
                }
                failedArray.put(email);
                newFailedRecipients = failedArray.toString();
            } catch (Exception e) {
                logger.log(Level.WARNING, "Error parsing failed_recipients JSON, using simple array", e);
                newFailedRecipients = "[\"" + email.replace("\"", "\\\"") + "\"]";
            }
            
            // Update with new failed_recipients
            sql = "UPDATE email_notifications SET failed_count = failed_count + 1, " +
                  "failed_recipients = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setString(1, newFailedRecipients);
                ps.setInt(2, notificationId);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Error updating single email failure for notification: " + notificationId, e);
                return false;
            }
        }
    }

    // Mark notification as completed (with status)
    public boolean markAsCompleted(int notificationId, String status) {
        if (!checkConnection()) {
            return false;
        }
        // Validate status
        if (status == null || (!status.equals("completed") && !status.equals("failed") && !status.equals("partial"))) {
            status = "completed"; // Default to completed
        }
        String sql = "UPDATE email_notifications SET status = ?, " +
                    "completed_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, notificationId);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error marking notification as completed: " + notificationId, e);
            return false;
        }
    }
    
    // Legacy method for backward compatibility
    public boolean markAsCompleted(int notificationId) {
        return markAsCompleted(notificationId, "completed");
    }

    // Delete email notification (only if not sending)
    public boolean deleteEmailNotification(int id) {
        if (!checkConnection()) {
            return false;
        }
        // Check if email is currently sending
        String checkSql = "SELECT status FROM email_notifications WHERE id = ?";
        try (PreparedStatement checkPs = connection.prepareStatement(checkSql)) {
            checkPs.setInt(1, id);
            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    if ("sending".equals(status)) {
                        logger.warning("Cannot delete email notification " + id + " - currently sending");
                        return false;
                    }
                } else {
                    logger.warning("Email notification not found: " + id);
                    return false;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking email notification status before delete", e);
            return false;
        }
        
        // Delete the notification
        String sql = "DELETE FROM email_notifications WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting email notification", e);
            return false;
        }
    }

    // Helper method to create EmailNotification from ResultSet
    private EmailNotification createEmailNotificationFromResultSet(ResultSet rs) throws SQLException {
        EmailNotification notification = new EmailNotification();
        notification.setId(rs.getInt("id"));
        notification.setSubject(rs.getString("subject"));
        notification.setContent(rs.getString("content"));
        notification.setEmailType(rs.getString("email_type"));
        notification.setRecipientRoles(rs.getString("recipient_roles"));
        notification.setRecipientEmails(rs.getString("recipient_emails"));
        notification.setRecipientCount(rs.getInt("recipient_count"));
        notification.setSuccessCount(rs.getInt("success_count"));
        notification.setFailedCount(rs.getInt("failed_count"));
        notification.setFailedRecipients(rs.getString("failed_recipients"));
        notification.setStatus(rs.getString("status"));
        
        int sentBy = rs.getInt("sent_by");
        if (!rs.wasNull()) {
            notification.setSentBy(sentBy);
        }
        
        notification.setSentByName(rs.getString("sent_by_name"));
        
        Timestamp scheduledAt = rs.getTimestamp("scheduled_at");
        if (scheduledAt != null) {
            notification.setScheduledAt(scheduledAt);
        }
        
        Timestamp sentAt = rs.getTimestamp("sent_at");
        if (sentAt != null) {
            notification.setSentAt(sentAt);
        }
        
        Timestamp completedAt = rs.getTimestamp("completed_at");
        if (completedAt != null) {
            notification.setCompletedAt(completedAt);
        }
        
        notification.setErrorMessage(rs.getString("error_message"));
        notification.setAttachments(rs.getString("attachments"));
        notification.setCreatedAt(rs.getTimestamp("created_at"));
        notification.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return notification;
    }
}

