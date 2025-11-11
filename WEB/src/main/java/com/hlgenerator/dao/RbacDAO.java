package com.hlgenerator.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * RBAC data access for resolving permissions for roles/users.
 */
public class RbacDAO extends DBConnect {
	private static final Logger logger = Logger.getLogger(RbacDAO.class.getName());

	public RbacDAO() {
		super();
	}

	public Set<String> getAllPermissionKeys() {
		Set<String> result = new HashSet<String>();
		String sql = "SELECT perm_key FROM permissions";
		try (PreparedStatement ps = connection.prepareStatement(sql);
		     ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				result.add(rs.getString(1));
			}
		} catch (SQLException e) {
			logger.log(Level.SEVERE, "Error fetching all permission keys", e);
		}
		return result;
	}

	public Set<String> getPermissionKeysByRoleKey(String roleKey) {
		Set<String> result = new HashSet<String>();
		String sql =
			"SELECT p.perm_key " +
			"FROM roles r " +
			"JOIN role_permissions rp ON rp.role_id = r.id " +
			"JOIN permissions p ON p.id = rp.permission_id " +
			"WHERE r.role_key = ?";
		try (PreparedStatement ps = connection.prepareStatement(sql)) {
			ps.setString(1, roleKey);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					result.add(rs.getString(1));
				}
			}
		} catch (SQLException e) {
			logger.log(Level.SEVERE, "Error fetching permissions for role: " + roleKey, e);
		}
		return result;
	}
}


