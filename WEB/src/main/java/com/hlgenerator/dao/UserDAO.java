package com.hlgenerator.dao;

import com.hlgenerator.model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO extends DBConnect {
    private static final Logger logger = Logger.getLogger(UserDAO.class.getName());

    public UserDAO() {
        super();
        if (connection == null) {
            logger.severe("UserDAO: Database connection failed during initialization");
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

    // Add new user
    public boolean addUser(User user) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "INSERT INTO users (username, email, password_hash, full_name, phone, role, permissions, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getRole());
            ps.setString(7, user.getPermissions());
            ps.setBoolean(8, user.isActive());
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error adding user", e);
            return false;
        }
    }

    // Get all users
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        if (!checkConnection()) {
            logger.severe("getAllUsers: Database connection is not available");
            return users;
        }
        String sql = "SELECT * FROM users ORDER BY created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            boolean hasData = false;
            while (rs.next()) {
                hasData = true;
                User user = new User(
                    rs.getInt("id"),
                    rs.getString("username"),
                    rs.getString("email"),
                    rs.getString("password_hash"),
                    rs.getString("full_name"),
                    rs.getString("phone"),
                    rs.getString("role"),
                    rs.getString("permissions"),
                    rs.getBoolean("is_active"),
                    rs.getTimestamp("created_at"),
                    rs.getTimestamp("updated_at")
                );
                users.add(user);
            }
            if (!hasData) {
                logger.warning("getAllUsers: No data found in users table");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting all users", e);
        }
        
        return users;
    }

    // Get user by ID
    public User getUserById(int id) {
        if (!checkConnection()) {
            logger.severe("getUserById: Database connection is not available");
            return null;
        }
        String sql = "SELECT * FROM users WHERE id = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("password_hash"),
                        rs.getString("full_name"),
                        rs.getString("phone"),
                        rs.getString("role"),
                        rs.getString("permissions"),
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting user by ID: " + id, e);
        }
        
        return null;
    }

    // Get user by username
    public User getUserByUsername(String username) {
        if (!checkConnection()) {
            logger.severe("getUserByUsername: Database connection is not available");
            return null;
        }
        String sql = "SELECT * FROM users WHERE username = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("password_hash"),
                        rs.getString("full_name"),
                        rs.getString("phone"),
                        rs.getString("role"),
                        rs.getString("permissions"),
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting user by username: " + username, e);
        }
        
        return null;
    }

    // Get user by email
    public User getUserByEmail(String email) {
        if (!checkConnection()) {
            logger.severe("getUserByEmail: Database connection is not available");
            return null;
        }
        String sql = "SELECT * FROM users WHERE email = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("password_hash"),
                        rs.getString("full_name"),
                        rs.getString("phone"),
                        rs.getString("role"),
                        rs.getString("permissions"),
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting user by email: " + email, e);
        }
        
        return null;
    }

    // Update user
    public boolean updateUser(User user) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "UPDATE users SET username=?, email=?, password_hash=?, full_name=?, phone=?, role=?, permissions=?, is_active=?, updated_at=CURRENT_TIMESTAMP WHERE id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getRole());
            ps.setString(7, user.getPermissions());
            ps.setBoolean(8, user.isActive());
            ps.setInt(9, user.getId());
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating user", e);
            return false;
        }
    }

    // Update user password
    public boolean updateUserPassword(int userId, String newPasswordHash) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "UPDATE users SET password_hash=?, updated_at=CURRENT_TIMESTAMP WHERE id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, userId);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating user password", e);
            return false;
        }
    }

    // Save password reset token and expiry
    public boolean savePasswordResetToken(int userId, String token, Timestamp expiresAt) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "UPDATE users SET reset_token = ?, reset_token_expires_at = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setTimestamp(2, expiresAt);
            ps.setInt(3, userId);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error saving password reset token", e);
            return false;
        }
    }

    // Get user by reset token (validate expiry in Java to avoid timezone issues)
    public User getUserByResetToken(String token) {
        if (!checkConnection()) {
            return null;
        }
        String sql = "SELECT * FROM users WHERE reset_token = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.sql.Timestamp exp = rs.getTimestamp("reset_token_expires_at");
                    if (exp != null && exp.before(new java.util.Date())) {
                        return null; // expired
                    }
                    return new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("password_hash"),
                        rs.getString("full_name"),
                        rs.getString("phone"),
                        rs.getString("role"),
                        rs.getString("permissions"),
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting user by reset token", e);
        }
        return null;
    }

    // Clear password reset token
    public boolean clearPasswordResetToken(int userId) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "UPDATE users SET reset_token = NULL, reset_token_expires_at = NULL WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error clearing password reset token", e);
            return false;
        }
    }

    // Delete user (soft delete - set is_active to false)
    public boolean deleteUser(int id) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "UPDATE users SET is_active=false, updated_at=CURRENT_TIMESTAMP WHERE id=?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting user", e);
            return false;
        }
    }

    // Hard delete user (permanently remove from database)
    public boolean hardDeleteUser(int id) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "DELETE FROM users WHERE id=?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error hard deleting user", e);
            return false;
        }
    }

    // Check if username exists
    public boolean isUsernameExists(String username) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking username existence", e);
        }
        
        return false;
    }

    // Check if username exists (excluding current user for updates)
    public boolean isUsernameExists(String username, int excludeId) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "SELECT COUNT(*) FROM users WHERE username = ? AND id != ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setInt(2, excludeId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking username existence", e);
        }
        
        return false;
    }

    // Check if email exists
    public boolean isEmailExists(String email) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking email existence", e);
        }
        
        return false;
    }

    // Check if email exists (excluding current user for updates)
    public boolean isEmailExists(String email, int excludeId) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "SELECT COUNT(*) FROM users WHERE email = ? AND id != ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, excludeId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking email existence", e);
        }
        
        return false;
    }

    // Search users
    public List<User> searchUsers(String searchTerm) {
        List<User> users = new ArrayList<>();
        if (!checkConnection()) {
            return users;
        }
        String sql = "SELECT * FROM users WHERE " +
                    "username LIKE ? OR " +
                    "email LIKE ? OR " +
                    "full_name LIKE ? OR " +
                    "phone LIKE ? " +
                    "ORDER BY created_at DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String searchPattern = "%" + searchTerm + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User user = new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("password_hash"),
                        rs.getString("full_name"),
                        rs.getString("phone"),
                        rs.getString("role"),
                        rs.getString("permissions"),
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
                    users.add(user);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error searching users", e);
        }
        
        return users;
    }

    // Get users by role
    public List<User> getUsersByRole(String role) {
        List<User> users = new ArrayList<>();
        if (!checkConnection()) {
            return users;
        }
        String sql = "SELECT * FROM users WHERE role = ? ORDER BY created_at DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, role);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User user = new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("password_hash"),
                        rs.getString("full_name"),
                        rs.getString("phone"),
                        rs.getString("role"),
                        rs.getString("permissions"),
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
                    users.add(user);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting users by role: " + role, e);
        }
        
        return users;
    }

    // Activate user
    public boolean activateUser(int id) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "UPDATE users SET is_active=true, updated_at=CURRENT_TIMESTAMP WHERE id=?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error activating user", e);
            return false;
        }
    }

    // Get user count by role
    public int getUserCountByRole(String role) {
        if (!checkConnection()) {
            return 0;
        }
        String sql = "SELECT COUNT(*) FROM users WHERE role = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, role);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting user count by role: " + role, e);
        }
        
        return 0;
    }

    // Get total user count
    public int getTotalUserCount() {
        if (!checkConnection()) {
            return 0;
        }
        String sql = "SELECT COUNT(*) FROM users";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting total user count", e);
        }
        
        return 0;
    }
    
    // Change password
    public boolean changePassword(int userId, String currentPassword, String newPassword) {
        if (!checkConnection()) {
            return false;
        }
        
        try {
            // First check current password
            String checkSql = "SELECT password_hash FROM users WHERE id = ?";
            PreparedStatement checkStmt = connection.prepareStatement(checkSql);
            checkStmt.setInt(1, userId);
            ResultSet rs = checkStmt.executeQuery();
            
            if (!rs.next()) {
                logger.warning("User not found with id: " + userId);
                return false;
            }
            
            String storedPassword = rs.getString("password_hash");
            
            // Check if current password matches (support both plain text and hash)
            String currentPasswordHash = sha256(currentPassword);
            boolean isCurrentPasswordCorrect = 
                currentPassword.equals(storedPassword) || 
                currentPasswordHash.equals(storedPassword);
            
            rs.close();
            checkStmt.close();
            
            if (!isCurrentPasswordCorrect) {
                logger.warning("Current password is incorrect for user id: " + userId);
                return false;
            }
            
            // Update to new password
            String updateSql = "UPDATE users SET password_hash = ? WHERE id = ?";
            PreparedStatement updateStmt = connection.prepareStatement(updateSql);
            updateStmt.setString(1, newPassword);
            updateStmt.setInt(2, userId);
            
            int rowsAffected = updateStmt.executeUpdate();
            updateStmt.close();
            
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error changing password for user id: " + userId, e);
            return false;
        }
    }
    
    // SHA-256 hash helper
    private String sha256(String input) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(input.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }
}
