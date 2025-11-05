package com.hlgenerator.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class SettingsDAO extends DBConnect {
    private static final Logger logger = Logger.getLogger(SettingsDAO.class.getName());

    public SettingsDAO() {
        super();
        if (connection == null) {
            logger.severe("SettingsDAO: Database connection failed during initialization");
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
     * Lấy giá trị setting theo key
     */
    public String getSetting(String key) {
        if (!checkConnection()) {
            return null;
        }
        
        String sql = "SELECT setting_value FROM settings WHERE setting_key = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("setting_value");
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting setting: " + key, e);
        }
        return null;
    }

    /**
     * Lấy tất cả settings
     */
    public Map<String, String> getAllSettings() {
        Map<String, String> settings = new HashMap<>();
        if (!checkConnection()) {
            return settings;
        }
        
        String sql = "SELECT setting_key, setting_value FROM settings";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                settings.put(rs.getString("setting_key"), rs.getString("setting_value"));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting all settings", e);
        }
        return settings;
    }

    /**
     * Cập nhật hoặc thêm mới setting
     */
    public boolean saveSetting(String key, String value, String description, Integer updatedBy) {
        if (!checkConnection()) {
            return false;
        }
        
        // Kiểm tra xem setting đã tồn tại chưa
        String checkSql = "SELECT id FROM settings WHERE setting_key = ?";
        try (PreparedStatement checkPs = connection.prepareStatement(checkSql)) {
            checkPs.setString(1, key);
            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next()) {
                    // Update existing setting
                    String updateSql = "UPDATE settings SET setting_value = ?, description = ?, updated_by = ?, updated_at = CURRENT_TIMESTAMP WHERE setting_key = ?";
                    try (PreparedStatement updatePs = connection.prepareStatement(updateSql)) {
                        updatePs.setString(1, value);
                        if (description != null && !description.trim().isEmpty()) {
                            updatePs.setString(2, description);
                        } else {
                            updatePs.setNull(2, java.sql.Types.VARCHAR);
                        }
                        if (updatedBy != null) {
                            updatePs.setInt(3, updatedBy);
                        } else {
                            updatePs.setNull(3, java.sql.Types.INTEGER);
                        }
                        updatePs.setString(4, key);
                        return updatePs.executeUpdate() > 0;
                    }
                } else {
                    // Insert new setting
                    String insertSql = "INSERT INTO settings (setting_key, setting_value, description, updated_by) VALUES (?, ?, ?, ?)";
                    try (PreparedStatement insertPs = connection.prepareStatement(insertSql)) {
                        insertPs.setString(1, key);
                        insertPs.setString(2, value);
                        if (description != null && !description.trim().isEmpty()) {
                            insertPs.setString(3, description);
                        } else {
                            insertPs.setNull(3, java.sql.Types.VARCHAR);
                        }
                        if (updatedBy != null) {
                            insertPs.setInt(4, updatedBy);
                        } else {
                            insertPs.setNull(4, java.sql.Types.INTEGER);
                        }
                        return insertPs.executeUpdate() > 0;
                    }
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error saving setting: " + key, e);
            return false;
        }
    }

    /**
     * Lưu nhiều settings cùng lúc
     */
    public boolean saveSettings(Map<String, String> settings, Integer updatedBy) {
        if (!checkConnection() || settings == null || settings.isEmpty()) {
            logger.warning("saveSettings: Invalid connection or empty settings");
            return false;
        }
        
        boolean allSuccess = true;
        int successCount = 0;
        int failCount = 0;
        
        for (Map.Entry<String, String> entry : settings.entrySet()) {
            try {
                boolean result = saveSetting(entry.getKey(), entry.getValue(), null, updatedBy);
                if (result) {
                    successCount++;
                    logger.info("Saved setting: " + entry.getKey() + " = " + entry.getValue());
                } else {
                    failCount++;
                    logger.warning("Failed to save setting: " + entry.getKey());
                    allSuccess = false;
                }
            } catch (Exception e) {
                failCount++;
                logger.log(Level.SEVERE, "Exception saving setting: " + entry.getKey(), e);
                allSuccess = false;
            }
        }
        
        logger.info("saveSettings completed: " + successCount + " success, " + failCount + " failed");
        return allSuccess;
    }
}

