package com.hlgenerator.dao;

import com.hlgenerator.model.Feedback;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FeedbackDAO extends DBConnect {
    private String lastError;

    /**
     * Tạo feedback mới cho ticket
     */
    public boolean createFeedback(int ticketId, int customerId, int rating, String comment, String imagePath) {
        try {
            if (connection == null || connection.isClosed()) {
                lastError = "DB connection is not available";
                return false;
            }
        } catch (SQLException e) {
            lastError = "DB connection check failed: " + e.getMessage();
            return false;
        }
        
        // Kiểm tra xem ticket đã có feedback chưa (nếu có thì update thay vì insert)
        Feedback existingFeedback = getFeedbackByTicketId(ticketId);
        if (existingFeedback != null) {
            // Update feedback hiện có
            return updateFeedback(existingFeedback.getId(), rating, comment, imagePath);
        }
        
        String sql = "INSERT INTO ticket_feedback (ticket_id, customer_id, rating, comment, image_path) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, customerId);
            ps.setInt(3, rating);
            ps.setString(4, comment != null ? comment : "");
            ps.setString(5, imagePath != null ? imagePath : null);
            
            int result = ps.executeUpdate();
            lastError = null;
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
            return false;
        }
    }
    
    /**
     * Overload method để tương thích với code cũ
     */
    public boolean createFeedback(int ticketId, int customerId, int rating, String comment) {
        return createFeedback(ticketId, customerId, rating, comment, null);
    }
    
    /**
     * Cập nhật feedback
     */
    public boolean updateFeedback(int feedbackId, int rating, String comment, String imagePath) {
        try {
            if (connection == null || connection.isClosed()) {
                lastError = "DB connection is not available";
                return false;
            }
        } catch (SQLException e) {
            lastError = "DB connection check failed: " + e.getMessage();
            return false;
        }
        
        String sql = "UPDATE ticket_feedback SET rating = ?, comment = ?, image_path = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, rating);
            ps.setString(2, comment != null ? comment : "");
            ps.setString(3, imagePath != null ? imagePath : null);
            ps.setInt(4, feedbackId);
            
            int result = ps.executeUpdate();
            lastError = null;
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
            return false;
        }
    }
    
    /**
     * Overload method để tương thích với code cũ
     */
    public boolean updateFeedback(int feedbackId, int rating, String comment) {
        return updateFeedback(feedbackId, rating, comment, null);
    }
    
    /**
     * Lấy feedback theo ID
     */
    public Feedback getFeedbackById(int feedbackId) {
        try {
            if (connection == null || connection.isClosed()) {
                lastError = "DB connection is not available";
                return null;
            }
        } catch (SQLException e) {
            lastError = "DB connection check failed: " + e.getMessage();
            return null;
        }
        
        String sql = "SELECT id, ticket_id, customer_id, rating, comment, image_path, created_at, updated_at " +
                     "FROM ticket_feedback WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, feedbackId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Feedback feedback = new Feedback();
                feedback.setId(rs.getInt("id"));
                feedback.setTicketId(rs.getInt("ticket_id"));
                feedback.setCustomerId(rs.getInt("customer_id"));
                feedback.setRating(rs.getInt("rating"));
                feedback.setComment(rs.getString("comment"));
                feedback.setImagePath(rs.getString("image_path"));
                feedback.setCreatedAt(rs.getTimestamp("created_at"));
                feedback.setUpdatedAt(rs.getTimestamp("updated_at"));
                return feedback;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
        }
        return null;
    }
    
    /**
     * Lấy feedback theo ticket ID
     */
    public Feedback getFeedbackByTicketId(int ticketId) {
        try {
            if (connection == null || connection.isClosed()) {
                lastError = "DB connection is not available";
                return null;
            }
        } catch (SQLException e) {
            lastError = "DB connection check failed: " + e.getMessage();
            return null;
        }
        
        String sql = "SELECT id, ticket_id, customer_id, rating, comment, image_path, created_at, updated_at " +
                     "FROM ticket_feedback WHERE ticket_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Feedback feedback = new Feedback();
                feedback.setId(rs.getInt("id"));
                feedback.setTicketId(rs.getInt("ticket_id"));
                feedback.setCustomerId(rs.getInt("customer_id"));
                feedback.setRating(rs.getInt("rating"));
                feedback.setComment(rs.getString("comment"));
                feedback.setImagePath(rs.getString("image_path"));
                feedback.setCreatedAt(rs.getTimestamp("created_at"));
                feedback.setUpdatedAt(rs.getTimestamp("updated_at"));
                return feedback;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
        }
        return null;
    }
    
    /**
     * Lấy feedback theo ticket ID dạng Map (dùng cho API)
     */
    public Map<String, Object> getFeedbackMapByTicketId(int ticketId) {
        Feedback feedback = getFeedbackByTicketId(ticketId);
        if (feedback == null) {
            return null;
        }
        
        Map<String, Object> map = new HashMap<>();
        map.put("id", feedback.getId());
        map.put("ticketId", feedback.getTicketId());
        map.put("customerId", feedback.getCustomerId());
        map.put("rating", feedback.getRating());
        map.put("comment", feedback.getComment());
        map.put("imagePath", feedback.getImagePath());
        map.put("ratingDisplay", feedback.getRatingDisplay());
        map.put("ratingStars", feedback.getRatingStars());
        map.put("createdAt", feedback.getCreatedAt());
        map.put("updatedAt", feedback.getUpdatedAt());
        return map;
    }
    
    /**
     * Lấy tất cả feedback của một khách hàng
     */
    public List<Feedback> getFeedbacksByCustomerId(int customerId) {
        List<Feedback> feedbacks = new ArrayList<>();
        try {
            if (connection == null || connection.isClosed()) {
                lastError = "DB connection is not available";
                return feedbacks;
            }
        } catch (SQLException e) {
            lastError = "DB connection check failed: " + e.getMessage();
            return feedbacks;
        }
        
        String sql = "SELECT id, ticket_id, customer_id, rating, comment, image_path, created_at, updated_at " +
                     "FROM ticket_feedback WHERE customer_id = ? ORDER BY created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Feedback feedback = new Feedback();
                feedback.setId(rs.getInt("id"));
                feedback.setTicketId(rs.getInt("ticket_id"));
                feedback.setCustomerId(rs.getInt("customer_id"));
                feedback.setRating(rs.getInt("rating"));
                feedback.setComment(rs.getString("comment"));
                feedback.setImagePath(rs.getString("image_path"));
                feedback.setCreatedAt(rs.getTimestamp("created_at"));
                feedback.setUpdatedAt(rs.getTimestamp("updated_at"));
                feedbacks.add(feedback);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
        }
        return feedbacks;
    }
    
    /**
     * Lấy thống kê rating trung bình
     */
    public Map<String, Object> getRatingStats() {
        Map<String, Object> stats = new HashMap<>();
        try {
            if (connection == null || connection.isClosed()) {
                return stats;
            }
        } catch (SQLException e) {
            return stats;
        }
        
        String sql = "SELECT AVG(rating) as avgRating, COUNT(*) as totalFeedbacks, " +
                     "SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) as rating5, " +
                     "SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) as rating4, " +
                     "SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) as rating3, " +
                     "SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) as rating2, " +
                     "SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) as rating1 " +
                     "FROM ticket_feedback";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                double avgRating = rs.getDouble("avgRating");
                if (rs.wasNull()) {
                    avgRating = 0;
                }
                stats.put("avgRating", Math.round(avgRating * 10.0) / 10.0); // Làm tròn 1 chữ số
                stats.put("totalFeedbacks", rs.getInt("totalFeedbacks"));
                stats.put("rating5", rs.getInt("rating5"));
                stats.put("rating4", rs.getInt("rating4"));
                stats.put("rating3", rs.getInt("rating3"));
                stats.put("rating2", rs.getInt("rating2"));
                stats.put("rating1", rs.getInt("rating1"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }
    
    /**
     * Lấy tất cả feedback với thông tin ticket và customer (cho customer_support)
     */
    public List<Map<String, Object>> getAllFeedbacksWithDetails() {
        return getAllFeedbacksWithDetails(null, null, null, null);
    }
    
    /**
     * Lấy danh sách feedback với filter
     * @param customerName Tên khách hàng (LIKE search)
     * @param ticketNumber Mã ticket (LIKE search)
     * @param rating Đánh giá (exact match)
     * @param category Danh mục ticket (exact match)
     * @return Danh sách feedback
     */
    public List<Map<String, Object>> getAllFeedbacksWithDetails(String customerName, String ticketNumber, Integer rating, String category) {
        List<Map<String, Object>> feedbacks = new ArrayList<>();
        try {
            if (connection == null || connection.isClosed()) {
                lastError = "DB connection is not available";
                return feedbacks;
            }
        } catch (SQLException e) {
            lastError = "DB connection check failed: " + e.getMessage();
            return feedbacks;
        }
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT tf.id, tf.ticket_id, tf.customer_id, tf.rating, tf.comment, tf.image_path, ");
        sql.append("tf.created_at, tf.updated_at, ");
        sql.append("sr.ticket_number, sr.subject as ticket_subject, sr.category, sr.status as ticket_status, ");
        sql.append("c.company_name, c.contact_person as customer_name, c.email as customer_email, c.phone as customer_phone ");
        sql.append("FROM ticket_feedback tf ");
        sql.append("LEFT JOIN support_requests sr ON tf.ticket_id = sr.id ");
        sql.append("LEFT JOIN customers c ON tf.customer_id = c.id ");
        sql.append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        // Filter by customer name
        if (customerName != null && !customerName.trim().isEmpty()) {
            sql.append("AND c.contact_person LIKE ? ");
            params.add("%" + customerName.trim() + "%");
        }
        
        // Filter by ticket number
        if (ticketNumber != null && !ticketNumber.trim().isEmpty()) {
            sql.append("AND sr.ticket_number LIKE ? ");
            params.add("%" + ticketNumber.trim() + "%");
        }
        
        // Filter by rating
        if (rating != null) {
            sql.append("AND tf.rating = ? ");
            params.add(rating);
        }
        
        // Filter by category
        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND sr.category = ? ");
            params.add(category.trim());
        }
        
        sql.append("ORDER BY tf.created_at DESC");
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    ps.setString(i + 1, (String) param);
                } else if (param instanceof Integer) {
                    ps.setInt(i + 1, (Integer) param);
                }
            }
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> feedback = new HashMap<>();
                feedback.put("id", rs.getInt("id"));
                feedback.put("ticketId", rs.getInt("ticket_id"));
                feedback.put("customerId", rs.getInt("customer_id"));
                feedback.put("rating", rs.getInt("rating"));
                feedback.put("comment", rs.getString("comment"));
                feedback.put("imagePath", rs.getString("image_path"));
                feedback.put("createdAt", rs.getTimestamp("created_at"));
                feedback.put("updatedAt", rs.getTimestamp("updated_at"));
                
                // Ticket info
                feedback.put("ticketNumber", rs.getString("ticket_number"));
                feedback.put("ticketSubject", rs.getString("ticket_subject"));
                feedback.put("ticketCategory", rs.getString("category"));
                feedback.put("ticketStatus", rs.getString("ticket_status"));
                
                // Customer info
                feedback.put("customerName", rs.getString("customer_name"));
                feedback.put("customerCompany", rs.getString("company_name"));
                feedback.put("customerEmail", rs.getString("customer_email"));
                feedback.put("customerPhone", rs.getString("customer_phone"));
                
                // Helper fields
                Feedback fb = new Feedback();
                fb.setRating(rs.getInt("rating"));
                feedback.put("ratingDisplay", fb.getRatingDisplay());
                feedback.put("ratingStars", fb.getRatingStars());
                
                feedbacks.add(feedback);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
            System.err.println("Error in getAllFeedbacksWithDetails: " + e.getMessage());
            System.err.println("SQL: " + sql.toString());
            System.err.println("Params count: " + params.size());
        } catch (Exception e) {
            e.printStackTrace();
            lastError = e.getMessage();
            System.err.println("Unexpected error in getAllFeedbacksWithDetails: " + e.getMessage());
        }
        return feedbacks;
    }
    
    public String getLastError() {
        return lastError;
    }
    
    /**
     * Xóa feedback
     */
    public boolean deleteFeedback(int feedbackId) {
        try {
            if (connection == null || connection.isClosed()) {
                lastError = "DB connection is not available";
                return false;
            }
        } catch (SQLException e) {
            lastError = "DB connection check failed: " + e.getMessage();
            return false;
        }
        
        String sql = "DELETE FROM ticket_feedback WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, feedbackId);
            int result = ps.executeUpdate();
            lastError = null;
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
            return false;
        }
    }
}

