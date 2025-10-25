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
        System.out.println("Getting all support requests...");
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
            System.out.println("Error in getAllSupportRequests: " + e.getMessage());
            e.printStackTrace();
            lastError = e.getMessage();
        }
        System.out.println("Returning " + out.size() + " support requests");
        return out;
    }

    public boolean updateSupportRequest(int id, String category, String priority, String status, String resolution, String internalNotes) {
        return updateSupportRequest(id, category, priority, status, resolution, internalNotes, null);
    }
    
    // Overload method with assignedTo parameter
    public boolean updateSupportRequest(int id, String category, String priority, String status, String resolution, String internalNotes, Integer assignedTo) {
        try {
            if (connection == null || connection.isClosed()) {
                lastError = "DB connection is not available";
                return false;
            }
        } catch (SQLException e) {
            lastError = "DB connection check failed: " + e.getMessage();
            return false;
        }
        
        // Build dynamic SQL based on which fields are provided
        StringBuilder sql = new StringBuilder("UPDATE support_requests SET ");
        List<Object> params = new ArrayList<>();
        boolean first = true;
        
        if (category != null) {
            sql.append("category = ?");
            params.add(category);
            first = false;
        }
        
        if (priority != null) {
            if (!first) sql.append(", ");
            sql.append("priority = ?");
            params.add(priority);
            first = false;
        }
        
        if (status != null) {
            if (!first) sql.append(", ");
            sql.append("status = ?, resolved_at = CASE WHEN ? = 'resolved' OR ? = 'closed' THEN NOW() ELSE resolved_at END");
            params.add(status);
            params.add(status);
            params.add(status);
            first = false;
        }
        
        if (resolution != null) {
            if (!first) sql.append(", ");
            sql.append("resolution = ?");
            params.add(resolution);
            first = false;
        }
        
        if (assignedTo != null) {
            if (!first) sql.append(", ");
            sql.append("assigned_to = ?");
            params.add(assignedTo);
            first = false;
        }
        
        sql.append(" WHERE id = ?");
        params.add(id);
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof Integer) {
                    ps.setInt(i + 1, (Integer) param);
                } else {
                    ps.setString(i + 1, (String) param);
                }
            }
            
            int result = ps.executeUpdate();
            lastError = null;
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
            return false;
        }
    }

    // Lấy thống kê tổng quan cho dashboard
    public Map<String, Object> getSupportStats() {
        Map<String, Object> stats = new HashMap<>();
        try {
            // Ticket khẩn cấp
            String urgentSql = "SELECT COUNT(*) FROM support_requests WHERE priority = 'urgent' AND status IN ('open', 'in_progress')";
            try (PreparedStatement ps = connection.prepareStatement(urgentSql)) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    stats.put("urgentTickets", rs.getInt(1));
                }
            }

            // Tổng ticket đang mở
            String openSql = "SELECT COUNT(*) FROM support_requests WHERE status IN ('open', 'in_progress')";
            try (PreparedStatement ps = connection.prepareStatement(openSql)) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    stats.put("totalOpenTickets", rs.getInt(1));
                }
            }

            // Đã giải quyết hôm nay
            String resolvedTodaySql = "SELECT COUNT(*) FROM support_requests WHERE DATE(resolved_at) = CURDATE() AND status = 'resolved'";
            try (PreparedStatement ps = connection.prepareStatement(resolvedTodaySql)) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    stats.put("resolvedToday", rs.getInt(1));
                }
            }

            // Tỷ lệ hài lòng (giả lập - cần thêm bảng feedback)
            stats.put("satisfactionRate", "92%");

            // Phân loại theo danh mục
            String categorySql = "SELECT category, COUNT(*) FROM support_requests WHERE status IN ('open', 'in_progress') GROUP BY category";
            try (PreparedStatement ps = connection.prepareStatement(categorySql)) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    String category = rs.getString(1);
                    int count = rs.getInt(2);
                    switch (category) {
                        case "technical":
                            stats.put("technicalTickets", count);
                            break;
                        case "billing":
                            stats.put("billingTickets", count);
                            break;
                        case "general":
                            stats.put("generalTickets", count);
                            break;
                        case "complaint":
                            stats.put("complaintTickets", count);
                            break;
                    }
                }
            }

            // Tin nhắn chưa đọc (giả lập)
            stats.put("unreadMessages", 4);
            stats.put("unreadNotifications", 2);

        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
        }
        return stats;
    }

    // Lấy danh sách ticket gần đây
    public List<Map<String, Object>> getRecentTickets(int limit) {
        String sql = "SELECT sr.id, sr.ticket_number, sr.subject, sr.category, sr.priority, sr.status, sr.created_at, " +
                     "c.company_name, c.contact_person " +
                     "FROM support_requests sr " +
                     "LEFT JOIN customers c ON sr.customer_id = c.id " +
                     "ORDER BY sr.created_at DESC LIMIT ?";
        List<Map<String, Object>> tickets = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> ticket = new HashMap<>();
                ticket.put("id", rs.getInt("id"));
                ticket.put("ticketNumber", rs.getString("ticket_number"));
                ticket.put("subject", rs.getString("subject"));
                ticket.put("category", rs.getString("category"));
                ticket.put("priority", rs.getString("priority"));
                ticket.put("status", rs.getString("status"));
                ticket.put("customerName", rs.getString("company_name"));
                ticket.put("contactPerson", rs.getString("contact_person"));
                ticket.put("createdAt", rs.getTimestamp("created_at"));
                tickets.add(ticket);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
        }
        return tickets;
    }

    // Lấy chi tiết một support request theo ID
    public Map<String, Object> getSupportRequestById(int id) {
        System.out.println("Getting support request by id: " + id);
        String sql = "SELECT sr.id, sr.ticket_number, sr.customer_id, sr.subject, sr.description, sr.category, " +
                     "sr.priority, sr.status, sr.assigned_to, sr.history, sr.resolution, sr.created_at, sr.resolved_at, " +
                     "c.company_name, c.contact_person, c.email as customer_email, c.phone as customer_phone, " +
                     "c.address as customer_address, " +
                     "u.full_name as assigned_to_name, u.email as assigned_to_email " +
                     "FROM support_requests sr " +
                     "LEFT JOIN customers c ON sr.customer_id = c.id " +
                     "LEFT JOIN users u ON sr.assigned_to = u.id " +
                     "WHERE sr.id = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Map<String, Object> ticket = new HashMap<>();
                ticket.put("id", rs.getInt("id"));
                ticket.put("ticketNumber", rs.getString("ticket_number"));
                ticket.put("customerId", rs.getInt("customer_id"));
                ticket.put("subject", rs.getString("subject"));
                ticket.put("description", rs.getString("description"));
                ticket.put("category", rs.getString("category"));
                ticket.put("priority", rs.getString("priority"));
                ticket.put("status", rs.getString("status"));
                ticket.put("assignedTo", rs.getObject("assigned_to"));
                ticket.put("assignedToName", rs.getString("assigned_to_name"));
                ticket.put("assignedToEmail", rs.getString("assigned_to_email"));
                ticket.put("history", rs.getString("history"));
                ticket.put("resolution", rs.getString("resolution"));
                ticket.put("customerName", rs.getString("company_name"));
                ticket.put("customerContact", rs.getString("contact_person"));
                ticket.put("customerEmail", rs.getString("customer_email"));
                ticket.put("customerPhone", rs.getString("customer_phone"));
                ticket.put("customerAddress", rs.getString("customer_address"));
                ticket.put("createdAt", rs.getTimestamp("created_at"));
                ticket.put("resolvedAt", rs.getTimestamp("resolved_at"));
                
                System.out.println("Found ticket: " + ticket.get("ticketNumber"));
                return ticket;
            }
        } catch (SQLException e) {
            System.out.println("Error in getSupportRequestById: " + e.getMessage());
            e.printStackTrace();
            lastError = e.getMessage();
        }
        System.out.println("No ticket found with id: " + id);
        return null;
    }
}



