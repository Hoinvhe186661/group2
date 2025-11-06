package com.hlgenerator.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ActivityLogDAO extends DBConnect {
    private static final Logger logger = Logger.getLogger(ActivityLogDAO.class.getName());

    public ActivityLogDAO() {
        super();
        if (connection == null) {
            logger.severe("ActivityLogDAO: Database connection failed during initialization");
        }
    }

    // Check database connection
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

    /**
     * Thêm activity log vào database
     */
    public boolean addActivityLog(Integer userId, String action, String tableName, Integer recordId, 
                                  String details, String ipAddress) {
        if (!checkConnection()) {
            return false;
        }

        String sql = "INSERT INTO activity_logs (user_id, action, table_name, record_id, details, ip_address) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (userId != null) {
                ps.setInt(1, userId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setString(2, action);
            if (tableName != null) {
                ps.setString(3, tableName);
            } else {
                ps.setNull(3, java.sql.Types.VARCHAR);
            }
            if (recordId != null) {
                ps.setInt(4, recordId);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            if (details != null) {
                ps.setString(5, details);
            } else {
                ps.setNull(5, java.sql.Types.VARCHAR);
            }
            if (ipAddress != null) {
                ps.setString(6, ipAddress);
            } else {
                ps.setNull(6, java.sql.Types.VARCHAR);
            }
            
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error adding activity log", e);
            return false;
        }
    }

    /**
     * Lấy danh sách activity logs gần đây (cho dashboard)
     */
    public List<Map<String, Object>> getRecentActivityLogs(int limit) {
        List<Map<String, Object>> logs = new ArrayList<>();
        if (!checkConnection()) {
            return logs;
        }

        String sql = "SELECT al.id, al.user_id, al.action, al.table_name, al.record_id, al.details, " +
                     "al.ip_address, al.created_at, u.username, u.full_name " +
                     "FROM activity_logs al " +
                     "LEFT JOIN users u ON al.user_id = u.id " +
                     "ORDER BY al.created_at DESC " +
                     "LIMIT ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> log = new LinkedHashMap<>();
                    log.put("id", rs.getInt("id"));
                    log.put("userId", rs.getObject("user_id"));
                    log.put("action", rs.getString("action"));
                    log.put("tableName", rs.getString("table_name"));
                    log.put("recordId", rs.getObject("record_id"));
                    log.put("details", rs.getString("details"));
                    log.put("ipAddress", rs.getString("ip_address"));
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    log.put("createdAt", createdAt);
                    log.put("time", createdAt != null ? createdAt.getTime() : System.currentTimeMillis());
                    log.put("username", rs.getString("username"));
                    log.put("fullName", rs.getString("full_name"));
                    logs.add(log);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting recent activity logs", e);
        }
        
        return logs;
    }

    /**
     * Lấy activity logs theo user_id
     */
    public List<Map<String, Object>> getActivityLogsByUserId(int userId, int limit) {
        List<Map<String, Object>> logs = new ArrayList<>();
        if (!checkConnection()) {
            return logs;
        }

        String sql = "SELECT al.id, al.user_id, al.action, al.table_name, al.record_id, al.details, " +
                     "al.ip_address, al.created_at, u.username, u.full_name " +
                     "FROM activity_logs al " +
                     "LEFT JOIN users u ON al.user_id = u.id " +
                     "WHERE al.user_id = ? " +
                     "ORDER BY al.created_at DESC " +
                     "LIMIT ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> log = new LinkedHashMap<>();
                    log.put("id", rs.getInt("id"));
                    log.put("userId", rs.getInt("user_id"));
                    log.put("action", rs.getString("action"));
                    log.put("tableName", rs.getString("table_name"));
                    log.put("recordId", rs.getObject("record_id"));
                    log.put("details", rs.getString("details"));
                    log.put("ipAddress", rs.getString("ip_address"));
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    log.put("createdAt", createdAt);
                    log.put("time", createdAt != null ? createdAt.getTime() : System.currentTimeMillis());
                    log.put("username", rs.getString("username"));
                    log.put("fullName", rs.getString("full_name"));
                    logs.add(log);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting activity logs by user id", e);
        }
        
        return logs;
    }

    /**
     * Lấy activity logs theo table_name
     */
    public List<Map<String, Object>> getActivityLogsByTable(String tableName, int limit) {
        List<Map<String, Object>> logs = new ArrayList<>();
        if (!checkConnection()) {
            return logs;
        }

        String sql = "SELECT al.id, al.user_id, al.action, al.table_name, al.record_id, al.details, " +
                     "al.ip_address, al.created_at, u.username, u.full_name " +
                     "FROM activity_logs al " +
                     "LEFT JOIN users u ON al.user_id = u.id " +
                     "WHERE al.table_name = ? " +
                     "ORDER BY al.created_at DESC " +
                     "LIMIT ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, tableName);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> log = new LinkedHashMap<>();
                    log.put("id", rs.getInt("id"));
                    log.put("userId", rs.getObject("user_id"));
                    log.put("action", rs.getString("action"));
                    log.put("tableName", rs.getString("table_name"));
                    log.put("recordId", rs.getObject("record_id"));
                    log.put("details", rs.getString("details"));
                    log.put("ipAddress", rs.getString("ip_address"));
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    log.put("createdAt", createdAt);
                    log.put("time", createdAt != null ? createdAt.getTime() : System.currentTimeMillis());
                    log.put("username", rs.getString("username"));
                    log.put("fullName", rs.getString("full_name"));
                    logs.add(log);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting activity logs by table", e);
        }
        
        return logs;
    }
}

