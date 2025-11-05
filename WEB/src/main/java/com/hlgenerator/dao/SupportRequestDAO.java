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

    // Method mới: Lấy danh sách với phân trang, lọc, tìm kiếm, sắp xếp
    public Map<String, Object> listByCustomerIdWithFilters(int customerId, int page, int pageSize, 
                                                            String search, String filterStatus, String filterCategory,
                                                            String sortField, String sortDirection) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> data = new ArrayList<>();
        
        try {
            // Xây dựng WHERE clause
            StringBuilder whereClause = new StringBuilder("customer_id = ?");
            List<Object> params = new ArrayList<>();
            params.add(customerId);
            
            // Tìm kiếm: tìm trong subject, description, category, ticket_number
            if (search != null && !search.trim().isEmpty()) {
                whereClause.append(" AND (");
                whereClause.append("subject LIKE ? OR ");
                whereClause.append("description LIKE ? OR ");
                whereClause.append("category LIKE ? OR ");
                whereClause.append("ticket_number LIKE ?");
                whereClause.append(")");
                String searchPattern = "%" + search.trim() + "%";
                params.add(searchPattern);
                params.add(searchPattern);
                params.add(searchPattern);
                params.add(searchPattern);
            }
            
            // Lọc theo trạng thái
            if (filterStatus != null && !filterStatus.trim().isEmpty()) {
                if ("waiting".equals(filterStatus)) {
                    whereClause.append(" AND (status = 'open' OR status = 'pending')");
                } else {
                    whereClause.append(" AND status = ?");
                    params.add(filterStatus);
                }
            }
            
            // Lọc theo loại yêu cầu
            if (filterCategory != null && !filterCategory.trim().isEmpty()) {
                whereClause.append(" AND category = ?");
                params.add(filterCategory);
            }
            
            // Xây dựng ORDER BY clause
            String orderBy = "created_at DESC"; // Mặc định
            if (sortField != null && !sortField.trim().isEmpty()) {
                String field = sortField.trim().toLowerCase();
                String direction = (sortDirection != null && "desc".equalsIgnoreCase(sortDirection.trim())) ? "DESC" : "ASC";
                
                switch (field) {
                    case "id":
                        orderBy = "id " + direction;
                        break;
                    case "date":
                    case "created_at":
                    case "createdat":
                        orderBy = "created_at " + direction;
                        break;
                    case "subject":
                        orderBy = "subject " + direction;
                        break;
                    case "category":
                        orderBy = "category " + direction;
                        break;
                    case "status":
                        orderBy = "status " + direction;
                        break;
                    default:
                        orderBy = "created_at DESC";
                }
            }
            
            // Đếm tổng số record (cho phân trang)
            String countSql = "SELECT COUNT(*) FROM support_requests WHERE " + whereClause.toString();
            int totalRecords = 0;
            try (PreparedStatement countPs = connection.prepareStatement(countSql)) {
                for (int i = 0; i < params.size(); i++) {
                    Object param = params.get(i);
                    if (param instanceof Integer) {
                        countPs.setInt(i + 1, (Integer) param);
                    } else {
                        countPs.setString(i + 1, (String) param);
                    }
                }
                ResultSet countRs = countPs.executeQuery();
                if (countRs.next()) {
                    totalRecords = countRs.getInt(1);
                }
            }
            
            // Tính toán phân trang
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
            int offset = (page - 1) * pageSize;
            
            // Lấy dữ liệu với phân trang
            String dataSql = "SELECT id, ticket_number, subject, description, category, priority, status, assigned_to, history, resolution, created_at, resolved_at, " +
                           "DATE(created_at) AS created_local_date " +
                           "FROM support_requests WHERE " + whereClause.toString() + 
                           " ORDER BY " + orderBy + 
                           " LIMIT ? OFFSET ?";
            
            try (PreparedStatement dataPs = connection.prepareStatement(dataSql)) {
                int paramIndex = 1;
                for (Object param : params) {
                    if (param instanceof Integer) {
                        dataPs.setInt(paramIndex, (Integer) param);
                    } else {
                        dataPs.setString(paramIndex, (String) param);
                    }
                    paramIndex++;
                }
                dataPs.setInt(paramIndex++, pageSize);
                dataPs.setInt(paramIndex++, offset);
                
                ResultSet rs = dataPs.executeQuery();
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
                    data.add(row);
                }
            }
            
            // Đóng gói kết quả
            result.put("data", data);
            result.put("totalRecords", totalRecords);
            result.put("totalPages", totalPages);
            result.put("currentPage", page);
            result.put("pageSize", pageSize);
            
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = e.getMessage();
            result.put("data", new ArrayList<>());
            result.put("totalRecords", 0);
            result.put("totalPages", 0);
            result.put("currentPage", page);
            result.put("pageSize", pageSize);
        }
        
        return result;
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
        String sql = "SELECT sr.id, sr.ticket_number, sr.customer_id, sr.subject, sr.description, sr.category, sr.priority, sr.status, " +
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
                // Lấy customer_id, kiểm tra NULL đúng cách
                // Lưu ý quan trọng: 
                // - Nếu dùng getInt() trực tiếp trên NULL, JDBC trả về 0 (KHÔNG phải null)
                // - Phải dùng getObject() để kiểm tra null, HOẶC dùng wasNull() sau getInt()
                // Cách 1: Dùng getObject() - đơn giản và rõ ràng
                Object customerIdObj = rs.getObject("customer_id");
                if (customerIdObj != null) {
                    // Convert sang Integer
                    if (customerIdObj instanceof Number) {
                        int customerId = ((Number) customerIdObj).intValue();
                        row.put("customerId", customerId);
                    } else {
                        try {
                            int customerId = Integer.parseInt(customerIdObj.toString());
                            row.put("customerId", customerId);
                        } catch (NumberFormatException e) {
                            row.put("customerId", null);
                        }
                    }
                } else {
                    // customer_id là NULL trong database
                    row.put("customerId", null);
                }
                row.put("subject", rs.getString("subject"));
                row.put("description", rs.getString("description"));
                row.put("category", rs.getString("category"));
                row.put("priority", rs.getString("priority"));
                row.put("status", rs.getString("status"));
                row.put("assignedTo", rs.getString("assigned_to"));
                row.put("assignedToName", rs.getString("assigned_to_name"));
                row.put("history", rs.getString("history"));
                row.put("resolution", rs.getString("resolution"));
                row.put("customerName", rs.getString("contact_person"));
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
                ticket.put("customerName", rs.getString("contact_person"));
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
                // Lấy customer_id, kiểm tra NULL đúng cách
                // Lưu ý quan trọng: 
                // - Nếu dùng getInt() trực tiếp trên NULL, JDBC trả về 0 (KHÔNG phải null)
                // - Phải dùng getObject() để kiểm tra null
                Object customerIdObj = rs.getObject("customer_id");
                if (customerIdObj != null) {
                    // Convert sang Integer
                    if (customerIdObj instanceof Number) {
                        int customerId = ((Number) customerIdObj).intValue();
                        ticket.put("customerId", customerId);
                    } else {
                        try {
                            int customerId = Integer.parseInt(customerIdObj.toString());
                            ticket.put("customerId", customerId);
                        } catch (NumberFormatException e) {
                            ticket.put("customerId", null);
                        }
                    }
                } else {
                    // customer_id là NULL trong database
                    ticket.put("customerId", null);
                }
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
                ticket.put("customerName", rs.getString("contact_person"));
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

    /**
     * Get support request ticket by subject and customer ID
     * Used to find ticket associated with a work order
     * @param subject The subject/title of the ticket
     * @param customerId The customer ID
     * @return Map with ticket data or null if not found
     */
    public Map<String, Object> getSupportRequestBySubjectAndCustomer(String subject, int customerId) {
        System.out.println("Getting support request by subject: [" + subject + "], customerId: " + customerId);
        
        // Normalize subject for matching (trim and handle potential encoding issues)
        String normalizedSubject = subject != null ? subject.trim() : "";
        
        // Try exact match first
        String sql = "SELECT sr.id, sr.ticket_number, sr.customer_id, sr.subject, sr.description, sr.category, " +
                     "sr.priority, sr.status, sr.assigned_to, sr.history, sr.resolution, sr.created_at, sr.resolved_at, " +
                     "c.company_name, c.contact_person, c.email as customer_email, c.phone as customer_phone, " +
                     "c.address as customer_address, " +
                     "u.full_name as assigned_to_name, u.email as assigned_to_email " +
                     "FROM support_requests sr " +
                     "LEFT JOIN customers c ON sr.customer_id = c.id " +
                     "LEFT JOIN users u ON sr.assigned_to = u.id " +
                     "WHERE TRIM(sr.subject) = ? AND sr.customer_id = ? " +
                     "ORDER BY sr.created_at DESC LIMIT 1";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, normalizedSubject);
            ps.setInt(2, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Map<String, Object> ticket = new HashMap<>();
                ticket.put("id", rs.getInt("id"));
                ticket.put("ticketNumber", rs.getString("ticket_number"));
                
                Object customerIdObj = rs.getObject("customer_id");
                if (customerIdObj != null) {
                    if (customerIdObj instanceof Number) {
                        int cId = ((Number) customerIdObj).intValue();
                        ticket.put("customerId", cId);
                    } else {
                        try {
                            int cId = Integer.parseInt(customerIdObj.toString());
                            ticket.put("customerId", cId);
                        } catch (NumberFormatException e) {
                            ticket.put("customerId", null);
                        }
                    }
                } else {
                    ticket.put("customerId", null);
                }
                
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
                ticket.put("customerName", rs.getString("contact_person"));
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
            System.out.println("Error in getSupportRequestBySubjectAndCustomer: " + e.getMessage());
            e.printStackTrace();
            lastError = e.getMessage();
        }
        
        // If exact match not found, try to find any technical ticket for this customer that is not resolved
        System.out.println("Exact match not found. Trying fallback: find technical ticket for customer " + customerId);
        sql = "SELECT sr.id, sr.ticket_number, sr.customer_id, sr.subject, sr.description, sr.category, " +
              "sr.priority, sr.status, sr.assigned_to, sr.history, sr.resolution, sr.created_at, sr.resolved_at, " +
              "c.company_name, c.contact_person, c.email as customer_email, c.phone as customer_phone, " +
              "c.address as customer_address, " +
              "u.full_name as assigned_to_name, u.email as assigned_to_email " +
              "FROM support_requests sr " +
              "LEFT JOIN customers c ON sr.customer_id = c.id " +
              "LEFT JOIN users u ON sr.assigned_to = u.id " +
              "WHERE sr.customer_id = ? AND sr.category = 'technical' " +
              "AND sr.status NOT IN ('resolved', 'closed') " +
              "ORDER BY sr.created_at DESC LIMIT 1";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Map<String, Object> ticket = new HashMap<>();
                ticket.put("id", rs.getInt("id"));
                ticket.put("ticketNumber", rs.getString("ticket_number"));
                
                Object customerIdObj = rs.getObject("customer_id");
                if (customerIdObj != null) {
                    if (customerIdObj instanceof Number) {
                        int cId = ((Number) customerIdObj).intValue();
                        ticket.put("customerId", cId);
                    } else {
                        try {
                            int cId = Integer.parseInt(customerIdObj.toString());
                            ticket.put("customerId", cId);
                        } catch (NumberFormatException e) {
                            ticket.put("customerId", null);
                        }
                    }
                } else {
                    ticket.put("customerId", null);
                }
                
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
                ticket.put("customerName", rs.getString("contact_person"));
                ticket.put("customerContact", rs.getString("contact_person"));
                ticket.put("customerEmail", rs.getString("customer_email"));
                ticket.put("customerPhone", rs.getString("customer_phone"));
                ticket.put("customerAddress", rs.getString("customer_address"));
                ticket.put("createdAt", rs.getTimestamp("created_at"));
                ticket.put("resolvedAt", rs.getTimestamp("resolved_at"));
                
                System.out.println("Found ticket (fallback): " + ticket.get("ticketNumber") + " (subject: " + ticket.get("subject") + ")");
                return ticket;
            }
        } catch (SQLException e) {
            System.out.println("Error in fallback search: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("No ticket found with subject: [" + subject + "], customerId: " + customerId);
        return null;
    }
}



