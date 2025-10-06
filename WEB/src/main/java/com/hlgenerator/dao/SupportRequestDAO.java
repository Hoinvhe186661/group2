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
        String sql = "SELECT id, ticket_number, subject, description, category, priority, status, created_at, resolved_at, " +
                     "DATE(CONVERT_TZ(created_at, '+00:00', '+07:00')) AS created_local_date " +
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
}



