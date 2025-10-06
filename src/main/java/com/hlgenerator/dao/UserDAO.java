package com.hlgenerator.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO extends DBConnect {

    public static class UserRecord {
        public int id;
        public String username;
        public String email;
        public String passwordHash;
        public String fullName;
        public String role;
        public boolean isActive;
    }

    public UserRecord findByUsername(String username) {
        String sql = "SELECT id, username, email, password_hash, full_name, role, is_active FROM users WHERE username = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                UserRecord u = new UserRecord();
                u.id = rs.getInt("id");
                u.username = rs.getString("username");
                u.email = rs.getString("email");
                u.passwordHash = rs.getString("password_hash");
                u.fullName = rs.getString("full_name");
                u.role = rs.getString("role");
                u.isActive = rs.getBoolean("is_active");
                return u;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean verifyPassword(String rawPassword, String storedHashOrPlain) {
        if (storedHashOrPlain == null) return false;
        String val = storedHashOrPlain.trim();
        try {
            if (val.startsWith("$2a$") || val.startsWith("$2b$") || val.startsWith("$2y$")) {
                return org.mindrot.jbcrypt.BCrypt.checkpw(rawPassword, val);
            }
        } catch (Exception ignore) {}
        return rawPassword != null && rawPassword.equals(val);
    }
}


