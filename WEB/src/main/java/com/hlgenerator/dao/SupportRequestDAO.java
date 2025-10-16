package com.hlgenerator.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SupportRequestDAO extends DBConnect {
    private String lastError;

    public List<Map<String, Object>> listByCustomerId(int customerId) {
        String sql = "SELECT id, ticket_number, subject, description, category, priority, status, assigned_to, history, resolution, created_at, resolved_at, " +
                     "DATE(created_at) AS created_local_date " +
                     "FROM support_requests WHERE customer_id = ? ORDER BY created_at DESC";
        List<Map<String, Object>> out = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("ticketNumber", rs.getString("ticket_number"));
                row.put("subject", rs.getString("subject"));
                row.put("description", rs.getString("description"));
                row.put("category", rs.getString("category"));
                row.put("priority", rs.getString("priority"));
                row.put("status", rs.getString("status"));
                row.put("assignedTo", rs.getString("assigned_to"));
                row.put("history", rs.getString("history"));
                row.put("resolution", rs.getString("resolution"));
                java.sql.Timestamp ts = rs.getTimestamp("created_at");
                row.put("createdAt", ts);
                try {
                    String local = rs.getString("created_local_date");
                    if (local != null && !local.isEmpty()) {
                        row.put("createdDate", local); // yyyy-MM-dd from DB
                    } else if (ts != null) {
                        java.time.LocalDate ld = ts.toInstant()
                            .atZone(java.time.ZoneId.of("Asia/Ho_Chi_Minh"))
                            .toLocalDate();
                        row.put("createdDate", ld.toString());
                    }
                } catch (Exception ignore) {
                    if (ts != null) {
                        java.time.LocalDate ld = ts.toInstant()
                            .atZone(java.time.ZoneId.of("Asia/Ho_Chi_Minh"))
                            .toLocalDate();
                        row.put("createdDate", ld.toString());
                    }
                }
                row.put("resolvedAt", rs.getTimestamp("resolved_at"));
                out.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return out;
    }

    public boolean create(int customerId, String subject, String description, String category, String priority) {
        try {
            if (connection == null || connection.isClosed()) {
                lastError = "DB connection is not available";
                return false;
            }
        } catch (SQLException e) {
            lastError = "DB connection check failed: " + e.getMessage();
            return false;
        }
        String sql = "INSERT INTO support_requests (ticket_number, customer_id, subject, description, category, priority, status) VALUES (?, ?, ?, ?, ?, ?, 'open')";
        String ticketNumber = "SR-" + System.currentTimeMillis();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, ticketNumber);
            ps.setInt(2, customerId);
            ps.setString(3, subject);
            ps.setString(4, description);
            ps.setString(5, category);
            ps.setString(6, priority);
            int result = ps.executeUpdate();
            lastError = null;
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
            return false;
        }
    }

    public String getLastError() {
        return lastError;
    }

    public boolean deleteById(int id) {
        try {
            if (connection == null || connection.isClosed()) {
                lastError = "DB connection is not available";
                return false;
            }
        } catch (SQLException e) {
            lastError = "DB connection check failed: " + e.getMessage();
            return false;
        }
        String sql = "DELETE FROM support_requests WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            int result = ps.executeUpdate();
            lastError = null;
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
            return false;
        }
    }

    public List<Map<String, Object>> getAllSupportRequests() {
        String sql = "SELECT sr.id, sr.ticket_number, sr.subject, sr.description, sr.category, sr.priority, sr.status, " +
                     "sr.assigned_to, sr.history, sr.resolution, sr.created_at, sr.resolved_at, " +
                     "c.company_name, c.contact_person, c.email as customer_email, c.phone as customer_phone, " +
                     "u.full_name as assigned_to_name, " +
                     "DATE(sr.created_at) AS created_local_date " +
                     "FROM support_requests sr " +
                     "LEFT JOIN customers c ON sr.customer_id = c.id " +
                     "LEFT JOIN users u ON sr.assigned_to = u.id " +
                     "ORDER BY sr.created_at DESC";
        List<Map<String, Object>> out = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("ticketNumber", rs.getString("ticket_number"));
                row.put("subject", rs.getString("subject"));
                row.put("description", rs.getString("description"));
                row.put("category", rs.getString("category"));
                row.put("priority", rs.getString("priority"));
                row.put("status", rs.getString("status"));
                row.put("assignedTo", rs.getString("assigned_to"));
                row.put("assignedToName", rs.getString("assigned_to_name"));
                row.put("history", rs.getString("history"));
                row.put("resolution", rs.getString("resolution"));
                row.put("customerName", rs.getString("company_name"));
                row.put("customerContact", rs.getString("contact_person"));
                row.put("customerEmail", rs.getString("customer_email"));
                row.put("customerPhone", rs.getString("customer_phone"));
                
                java.sql.Timestamp ts = rs.getTimestamp("created_at");
                row.put("createdAt", ts);
                try {
                    String local = rs.getString("created_local_date");
                    if (local != null && !local.isEmpty()) {
                        row.put("createdDate", local);
                    } else if (ts != null) {
                        java.time.LocalDate ld = ts.toInstant()
                            .atZone(java.time.ZoneId.of("Asia/Ho_Chi_Minh"))
                            .toLocalDate();
                        row.put("createdDate", ld.toString());
                    }
                } catch (Exception ignore) {
                    if (ts != null) {
                        java.time.LocalDate ld = ts.toInstant()
                            .atZone(java.time.ZoneId.of("Asia/Ho_Chi_Minh"))
                            .toLocalDate();
                        row.put("createdDate", ld.toString());
                    }
                }
                row.put("resolvedAt", rs.getTimestamp("resolved_at"));
                out.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
        }
        return out;
    }

    public boolean updateSupportRequest(int id, String category, String priority, String status, String resolution, String internalNotes) {
        try {
            if (connection == null || connection.isClosed()) {
                lastError = "DB connection is not available";
                return false;
            }
        } catch (SQLException e) {
            lastError = "DB connection check failed: " + e.getMessage();
            return false;
        }
        
        String sql = "UPDATE support_requests SET category = ?, priority = ?, status = ?, resolution = ?, " +
                     "resolved_at = CASE WHEN ? = 'resolved' OR ? = 'closed' THEN NOW() ELSE resolved_at END " +
                     "WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, category);
            ps.setString(2, priority);
            ps.setString(3, status);
            ps.setString(4, resolution);
            ps.setString(5, status);
            ps.setString(6, status);
            ps.setInt(7, id);
            
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



