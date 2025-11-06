package com.hlgenerator.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ContactDAO extends DBConnect {
    private static final Logger logger = Logger.getLogger(ContactDAO.class.getName());

    public ContactDAO() {
        super();
        if (connection == null) {
            logger.severe("ContactDAO: Database connection failed during initialization");
        }
    }

    /**
     * Lưu tin nhắn liên hệ mới
     */
    public boolean saveContactMessage(String fullName, String email, String phone, String message) {
        if (connection == null) {
            logger.severe("Database connection is not available");
            return false;
        }

        String sql = "INSERT INTO contact_messages (full_name, email, phone, message, status) VALUES (?, ?, ?, ?, 'new')";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, message);
            
            int result = ps.executeUpdate();
            if (result > 0) {
                logger.info("Contact message saved successfully: " + email);
                return true;
            } else {
                logger.warning("Failed to save contact message");
                return false;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error saving contact message", e);
            return false;
        }
    }

    /**
     * Lấy tất cả tin nhắn liên hệ
     */
    public List<Map<String, Object>> getAllContactMessages() {
        return getContactMessagesWithFilters(null, null, null);
    }
    
    /**
     * Lấy tin nhắn liên hệ với bộ lọc
     */
    public List<Map<String, Object>> getContactMessagesWithFilters(String status, String startDate, String endDate) {
        List<Map<String, Object>> messages = new ArrayList<>();
        
        if (connection == null) {
            logger.severe("Database connection is not available");
            return messages;
        }

        StringBuilder sql = new StringBuilder(
            "SELECT id, full_name, email, phone, message, status, created_at, replied_at " +
            "FROM contact_messages WHERE 1=1"
        );
        
        List<Object> params = new ArrayList<>();
        
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status.trim());
        }
        
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND DATE(created_at) >= ?");
            params.add(startDate.trim());
        }
        
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND DATE(created_at) <= ?");
            params.add(endDate.trim());
        }
        
        sql.append(" ORDER BY created_at DESC");
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> message = new HashMap<>();
                    message.put("id", rs.getInt("id"));
                    message.put("fullName", rs.getString("full_name"));
                    message.put("email", rs.getString("email"));
                    message.put("phone", rs.getString("phone"));
                    message.put("message", rs.getString("message"));
                    message.put("status", rs.getString("status"));
                    message.put("createdAt", rs.getTimestamp("created_at"));
                    Timestamp repliedAt = rs.getTimestamp("replied_at");
                    message.put("repliedAt", repliedAt != null ? repliedAt : null);
                    
                    messages.add(message);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting contact messages with filters", e);
        }
        
        return messages;
    }

    /**
     * Cập nhật trạng thái tin nhắn
     */
    public boolean updateMessageStatus(int messageId, String status) {
        if (connection == null) {
            logger.severe("Database connection is not available");
            return false;
        }

        String sql = "UPDATE contact_messages SET status = ?, replied_at = ? WHERE id = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            if ("replied".equals(status)) {
                ps.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            } else {
                ps.setTimestamp(2, null);
            }
            ps.setInt(3, messageId);
            
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating message status", e);
            return false;
        }
    }

    /**
     * Đếm số tin nhắn chưa đọc
     */
    public int countUnreadMessages() {
        if (connection == null) {
            logger.severe("Database connection is not available");
            return 0;
        }

        String sql = "SELECT COUNT(*) as count FROM contact_messages WHERE status = 'new'";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting unread messages", e);
        }
        
        return 0;
    }
}




