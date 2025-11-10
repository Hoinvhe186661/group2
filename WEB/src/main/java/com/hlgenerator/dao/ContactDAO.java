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
            "SELECT id, full_name, email, phone, message, status, created_at, replied_at, contact_method, " +
            "address, customer_type, company_name, tax_code " +
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
                    // Lấy contact_method, có thể null nếu cột chưa tồn tại hoặc giá trị null
                    try {
                        String contactMethod = rs.getString("contact_method");
                        message.put("contactMethod", contactMethod);
                    } catch (Exception e) {
                        // Cột contact_method có thể chưa tồn tại
                        message.put("contactMethod", null);
                    }
                    
                    // Lấy các thông tin bổ sung
                    try {
                        String address = rs.getString("address");
                        message.put("address", address);
                    } catch (Exception e) {
                        message.put("address", null);
                    }
                    
                    try {
                        String customerType = rs.getString("customer_type");
                        message.put("customerType", customerType);
                    } catch (Exception e) {
                        message.put("customerType", null);
                    }
                    
                    try {
                        String companyName = rs.getString("company_name");
                        message.put("companyName", companyName);
                    } catch (Exception e) {
                        message.put("companyName", null);
                    }
                    
                    try {
                        String taxCode = rs.getString("tax_code");
                        message.put("taxCode", taxCode);
                    } catch (Exception e) {
                        message.put("taxCode", null);
                    }
                    
                    messages.add(message);
                }
            }
        } catch (SQLException e) {
            // Nếu lỗi do cột contact_method không tồn tại, thử lại với query không có cột này
            if (e.getMessage() != null && e.getMessage().contains("Unknown column 'contact_method'")) {
                logger.info("contact_method column does not exist, retrying without it");
                StringBuilder sqlWithoutMethod = new StringBuilder(
                    "SELECT id, full_name, email, phone, message, status, created_at, replied_at " +
                    "FROM contact_messages WHERE 1=1"
                );
                List<Object> params2 = new ArrayList<>();
                
                if (status != null && !status.trim().isEmpty()) {
                    sqlWithoutMethod.append(" AND status = ?");
                    params2.add(status.trim());
                }
                
                if (startDate != null && !startDate.trim().isEmpty()) {
                    sqlWithoutMethod.append(" AND DATE(created_at) >= ?");
                    params2.add(startDate.trim());
                }
                
                if (endDate != null && !endDate.trim().isEmpty()) {
                    sqlWithoutMethod.append(" AND DATE(created_at) <= ?");
                    params2.add(endDate.trim());
                }
                
                sqlWithoutMethod.append(" ORDER BY created_at DESC");
                
                try (PreparedStatement ps = connection.prepareStatement(sqlWithoutMethod.toString())) {
                    for (int i = 0; i < params2.size(); i++) {
                        ps.setObject(i + 1, params2.get(i));
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
                            message.put("contactMethod", null);
                            
                            messages.add(message);
                        }
                    }
                } catch (SQLException e2) {
                    logger.log(Level.SEVERE, "Error getting contact messages with filters (retry)", e2);
                }
            } else {
                logger.log(Level.SEVERE, "Error getting contact messages with filters", e);
            }
        }
        
        return messages;
    }

    /**
     * Cập nhật trạng thái tin nhắn
     */
    public boolean updateMessageStatus(int messageId, String status) {
        return updateMessageStatusWithMethod(messageId, status, null);
    }
    
    /**
     * Cập nhật trạng thái tin nhắn với đầy đủ thông tin
     */
    public boolean updateMessageStatusWithDetails(int messageId, String status, String contactMethod, 
                                                   String address, String customerType, String companyName, String taxCode) {
        if (connection == null) {
            logger.severe("Database connection is not available");
            return false;
        }

        StringBuilder sql = new StringBuilder("UPDATE contact_messages SET status = ?, replied_at = ?");
        List<Object> params = new ArrayList<>();
        
        params.add(status);
        if ("replied".equals(status)) {
            params.add(new Timestamp(System.currentTimeMillis()));
        } else {
            params.add(null);
        }
        
        // Thêm contact_method
        if (contactMethod != null && !contactMethod.trim().isEmpty()) {
            sql.append(", contact_method = ?");
            params.add(contactMethod.trim());
        }
        
        // Thêm address
        if (address != null && !address.trim().isEmpty()) {
            sql.append(", address = ?");
            params.add(address.trim());
        }
        
        // Thêm customer_type
        if (customerType != null && !customerType.trim().isEmpty()) {
            sql.append(", customer_type = ?");
            params.add(customerType.trim());
        }
        
        // Thêm company_name
        if (companyName != null && !companyName.trim().isEmpty()) {
            sql.append(", company_name = ?");
            params.add(companyName.trim());
        }
        
        // Thêm tax_code
        if (taxCode != null && !taxCode.trim().isEmpty()) {
            sql.append(", tax_code = ?");
            params.add(taxCode.trim());
        }
        
        sql.append(" WHERE id = ?");
        params.add(messageId);
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            // Nếu lỗi do thiếu cột, thử tạo các cột và update lại
            if (e.getMessage().contains("Unknown column")) {
                try {
                    createContactMessageColumns();
                    // Thử lại update
                    return updateMessageStatusWithDetails(messageId, status, contactMethod, address, customerType, companyName, taxCode);
                } catch (SQLException alterE) {
                    logger.log(Level.SEVERE, "Error creating columns or updating", alterE);
                    // Nếu không tạo được cột, vẫn cập nhật status và replied_at
                    try (PreparedStatement fallbackPs = connection.prepareStatement(
                        "UPDATE contact_messages SET status = ?, replied_at = ? WHERE id = ?")) {
                        fallbackPs.setString(1, status);
                        if ("replied".equals(status)) {
                            fallbackPs.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
                        } else {
                            fallbackPs.setTimestamp(2, null);
                        }
                        fallbackPs.setInt(3, messageId);
                        return fallbackPs.executeUpdate() > 0;
                    } catch (SQLException fallbackE) {
                        logger.log(Level.SEVERE, "Error in fallback update", fallbackE);
                        return false;
                    }
                }
            }
            logger.log(Level.SEVERE, "Error updating message status with details", e);
            return false;
        }
    }
    
    /**
     * Tạo các cột mới nếu chưa có
     */
    private void createContactMessageColumns() throws SQLException {
        try (PreparedStatement ps = connection.prepareStatement(
            "ALTER TABLE contact_messages " +
            "ADD COLUMN IF NOT EXISTS contact_method VARCHAR(255) NULL, " +
            "ADD COLUMN IF NOT EXISTS address VARCHAR(500) NULL, " +
            "ADD COLUMN IF NOT EXISTS customer_type VARCHAR(50) NULL, " +
            "ADD COLUMN IF NOT EXISTS company_name VARCHAR(255) NULL, " +
            "ADD COLUMN IF NOT EXISTS tax_code VARCHAR(50) NULL")) {
            ps.executeUpdate();
        } catch (SQLException e) {
            // Nếu không hỗ trợ IF NOT EXISTS, thử từng cột một
            String[] columns = {
                "contact_method VARCHAR(255) NULL",
                "address VARCHAR(500) NULL",
                "customer_type VARCHAR(50) NULL",
                "company_name VARCHAR(255) NULL",
                "tax_code VARCHAR(50) NULL"
            };
            
            for (String column : columns) {
                try {
                    try (PreparedStatement alterPs = connection.prepareStatement(
                        "ALTER TABLE contact_messages ADD COLUMN " + column)) {
                        alterPs.executeUpdate();
                    }
                } catch (SQLException colE) {
                    // Cột đã tồn tại, bỏ qua
                    if (!colE.getMessage().contains("Duplicate column")) {
                        throw colE;
                    }
                }
            }
        }
    }
    
    /**
     * Cập nhật trạng thái tin nhắn với phương thức liên hệ
     */
    public boolean updateMessageStatusWithMethod(int messageId, String status, String contactMethod) {
        if (connection == null) {
            logger.severe("Database connection is not available");
            return false;
        }

        String sql;
        if (contactMethod != null && !contactMethod.trim().isEmpty()) {
            // Kiểm tra xem có cột contact_method không, nếu không thì dùng ALTER TABLE để thêm
            // Tạm thời lưu vào một cột notes hoặc tạo cột mới
            sql = "UPDATE contact_messages SET status = ?, replied_at = ?, contact_method = ? WHERE id = ?";
        } else {
            sql = "UPDATE contact_messages SET status = ?, replied_at = ? WHERE id = ?";
        }
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            if ("replied".equals(status)) {
                ps.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            } else {
                ps.setTimestamp(2, null);
            }
            
            if (contactMethod != null && !contactMethod.trim().isEmpty()) {
                ps.setString(3, contactMethod.trim());
                ps.setInt(4, messageId);
            } else {
                ps.setInt(3, messageId);
            }
            
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            // Nếu lỗi do không có cột contact_method, thử tạo cột và update lại
            if (e.getMessage().contains("Unknown column 'contact_method'")) {
                try {
                    // Tạo cột contact_method nếu chưa có
                    try (PreparedStatement alterPs = connection.prepareStatement(
                        "ALTER TABLE contact_messages ADD COLUMN contact_method VARCHAR(255) NULL")) {
                        alterPs.executeUpdate();
                    }
                    // Thử lại update
                    return updateMessageStatusWithMethod(messageId, status, contactMethod);
                } catch (SQLException alterE) {
                    logger.log(Level.SEVERE, "Error creating contact_method column or updating", alterE);
                    // Nếu không tạo được cột, vẫn cập nhật status và replied_at
                    try (PreparedStatement fallbackPs = connection.prepareStatement(
                        "UPDATE contact_messages SET status = ?, replied_at = ? WHERE id = ?")) {
                        fallbackPs.setString(1, status);
                        if ("replied".equals(status)) {
                            fallbackPs.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
                        } else {
                            fallbackPs.setTimestamp(2, null);
                        }
                        fallbackPs.setInt(3, messageId);
                        return fallbackPs.executeUpdate() > 0;
                    } catch (SQLException fallbackE) {
                        logger.log(Level.SEVERE, "Error in fallback update", fallbackE);
                        return false;
                    }
                }
            }
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
//phân trangang
    /**
     * Đếm tổng số tin nhắn với bộ lọc
     */
    public int countContactMessagesFiltered(String status, String startDate, String endDate, String search) {
        if (connection == null) {
            logger.severe("Database connection is not available");
            return 0;
        }

        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM contact_messages WHERE 1=1"
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
        
        // Thêm điều kiện search
        addSearchConditions(sql, params, search, "CAST(id AS CHAR)", "full_name", "email", "phone", "message");
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting filtered contact messages", e);
        }
        
        return 0;
    }

    /**
     * Lấy tin nhắn liên hệ với phân trang và bộ lọc
     */
    public List<Map<String, Object>> getContactMessagesPageFiltered(int page, int pageSize, String status, String startDate, String endDate, String search) {
        List<Map<String, Object>> messages = new ArrayList<>();
        
        if (connection == null) {
            logger.severe("Database connection is not available");
            return messages;
        }

        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder(
            "SELECT id, full_name, email, phone, message, status, created_at, replied_at, contact_method, " +
            "address, customer_type, company_name, tax_code " +
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
        
        // Thêm điều kiện search
        addSearchConditions(sql, params, search, "CAST(id AS CHAR)", "full_name", "email", "phone", "message");
        
        // Sắp xếp liên hệ mới nhất lên đầu
        sql.append(" ORDER BY created_at DESC LIMIT ? OFFSET ?");
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object p : params) {
                ps.setObject(idx++, p);
            }
            ps.setInt(idx++, pageSize);
            ps.setInt(idx, offset);
            
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
                    // Lấy contact_method, có thể null nếu cột chưa tồn tại hoặc giá trị null
                    try {
                        String contactMethod = rs.getString("contact_method");
                        message.put("contactMethod", contactMethod);
                    } catch (Exception e) {
                        // Cột contact_method có thể chưa tồn tại
                        message.put("contactMethod", null);
                    }
                    
                    // Lấy các thông tin bổ sung
                    try {
                        String address = rs.getString("address");
                        message.put("address", address);
                    } catch (Exception e) {
                        message.put("address", null);
                    }
                    
                    try {
                        String customerType = rs.getString("customer_type");
                        message.put("customerType", customerType);
                    } catch (Exception e) {
                        message.put("customerType", null);
                    }
                    
                    try {
                        String companyName = rs.getString("company_name");
                        message.put("companyName", companyName);
                    } catch (Exception e) {
                        message.put("companyName", null);
                    }
                    
                    try {
                        String taxCode = rs.getString("tax_code");
                        message.put("taxCode", taxCode);
                    } catch (Exception e) {
                        message.put("taxCode", null);
                    }
                    
                    messages.add(message);
                }
            }
        } catch (SQLException e) {
            // Nếu lỗi do cột contact_method không tồn tại, thử lại với query không có cột này
            if (e.getMessage() != null && e.getMessage().contains("Unknown column 'contact_method'")) {
                logger.info("contact_method column does not exist, retrying without it");
                StringBuilder sqlWithoutMethod = new StringBuilder(
                    "SELECT id, full_name, email, phone, message, status, created_at, replied_at " +
                    "FROM contact_messages WHERE 1=1"
                );
                List<Object> params2 = new ArrayList<>();
                
                if (status != null && !status.trim().isEmpty()) {
                    sqlWithoutMethod.append(" AND status = ?");
                    params2.add(status.trim());
                }
                
                if (startDate != null && !startDate.trim().isEmpty()) {
                    sqlWithoutMethod.append(" AND DATE(created_at) >= ?");
                    params2.add(startDate.trim());
                }
                
                if (endDate != null && !endDate.trim().isEmpty()) {
                    sqlWithoutMethod.append(" AND DATE(created_at) <= ?");
                    params2.add(endDate.trim());
                }
                
                addSearchConditions(sqlWithoutMethod, params2, search, "CAST(id AS CHAR)", "full_name", "email", "phone", "message");
                
                sqlWithoutMethod.append(" ORDER BY created_at DESC LIMIT ? OFFSET ?");
                
                try (PreparedStatement ps = connection.prepareStatement(sqlWithoutMethod.toString())) {
                    int idx = 1;
                    for (Object p : params2) {
                        ps.setObject(idx++, p);
                    }
                    ps.setInt(idx++, pageSize);
                    ps.setInt(idx, offset);
                    
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
                            message.put("contactMethod", null);
                            
                            messages.add(message);
                        }
                    }
                } catch (SQLException e2) {
                    logger.log(Level.SEVERE, "Error getting contact messages page with filters (retry)", e2);
                }
            } else {
                logger.log(Level.SEVERE, "Error getting contact messages page with filters", e);
            }
        }
        
        return messages;
    }

    /**
     * Lấy danh sách khách hàng đã liên hệ (trạng thái replied)
     */
    public List<Map<String, Object>> getContactedCustomers() {
        return getContactMessagesWithFilters("replied", null, null);
    }

    /**
     * Helper method để thêm search conditions (giống ContractDAO)
     */
    private void addSearchConditions(StringBuilder sql, List<Object> params, String search, String... columns) {
        if (search != null && !search.isEmpty()) {
            sql.append(" AND (");
            for (int i = 0; i < columns.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append(columns[i]).append(" LIKE ?");
                params.add("%" + search + "%");
            }
            // Thêm exact ID search nếu search là số
            try {
                int exactId = Integer.parseInt(search.trim());
                sql.append(" OR id = ?");
                params.add(exactId);
            } catch (NumberFormatException ignore) {
                // not numeric, ignore
            }
            sql.append(")");
        }
    }
}




