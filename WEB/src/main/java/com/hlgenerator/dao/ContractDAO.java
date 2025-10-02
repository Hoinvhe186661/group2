package com.hlgenerator.dao;

import com.hlgenerator.model.Contract;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ContractDAO extends DBConnect {
    private static final Logger logger = Logger.getLogger(ContractDAO.class.getName());

    public ContractDAO() {
        super();
        if (connection == null) {
            logger.severe("ContractDAO: Database connection failed during initialization");
        }
    }

    private boolean checkConnection() {
        try {
            return connection != null && !connection.isClosed();
        } catch (SQLException e) {
            logger.severe("Error checking database connection: " + e.getMessage());
            return false;
        }
    }

    public boolean addContract(Contract contract) {
        if (!checkConnection()) return false;
        String sql = "INSERT INTO contracts (contract_number, customer_id, contract_type, title, start_date, end_date, contract_value, status, terms, signed_date, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, contract.getContractNumber());
            ps.setInt(2, contract.getCustomerId());
            ps.setString(3, contract.getContractType());
            ps.setString(4, contract.getTitle());
            ps.setDate(5, contract.getStartDate());
            ps.setDate(6, contract.getEndDate());
            ps.setBigDecimal(7, contract.getContractValue());
            ps.setString(8, contract.getStatus());
            ps.setString(9, contract.getTerms());
            ps.setDate(10, contract.getSignedDate());
            if (contract.getCreatedBy() == null) {
                ps.setNull(11, Types.INTEGER);
            } else {
                ps.setInt(11, contract.getCreatedBy());
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error adding contract", e);
            return false;
        }
    }

    public boolean updateContract(Contract contract) {
        if (!checkConnection()) return false;
        String sql = "UPDATE contracts SET contract_number=?, customer_id=?, contract_type=?, title=?, start_date=?, end_date=?, contract_value=?, status=?, terms=?, signed_date=? WHERE id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, contract.getContractNumber());
            ps.setInt(2, contract.getCustomerId());
            ps.setString(3, contract.getContractType());
            ps.setString(4, contract.getTitle());
            ps.setDate(5, contract.getStartDate());
            ps.setDate(6, contract.getEndDate());
            ps.setBigDecimal(7, contract.getContractValue());
            ps.setString(8, contract.getStatus());
            ps.setString(9, contract.getTerms());
            ps.setDate(10, contract.getSignedDate());
            ps.setInt(11, contract.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating contract", e);
            return false;
        }
    }

    public boolean deleteContract(int id) {
        if (!checkConnection()) return false;
        String sql = "DELETE FROM contracts WHERE id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting contract", e);
            return false;
        }
    }

    public Contract getContractById(int id) {
        if (!checkConnection()) return null;
        String sql = "SELECT * FROM contracts WHERE id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching contract by id", e);
        }
        return null;
    }

    public List<Contract> getAllContracts() {
        List<Contract> list = new ArrayList<>();
        if (!checkConnection()) return list;
        String sql = "SELECT * FROM contracts ORDER BY id DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching all contracts", e);
        }
        return list;
    }

    private Contract mapRow(ResultSet rs) throws SQLException {
        Contract c = new Contract();
        c.setId(rs.getInt("id"));
        c.setContractNumber(rs.getString("contract_number"));
        c.setCustomerId(rs.getInt("customer_id"));
        c.setContractType(rs.getString("contract_type"));
        c.setTitle(rs.getString("title"));
        c.setStartDate(rs.getDate("start_date"));
        c.setEndDate(rs.getDate("end_date"));
        c.setContractValue(rs.getBigDecimal("contract_value"));
        c.setStatus(rs.getString("status"));
        c.setTerms(rs.getString("terms"));
        c.setSignedDate(rs.getDate("signed_date"));
        int createdBy = rs.getInt("created_by");
        c.setCreatedBy(rs.wasNull() ? null : createdBy);
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));
        return c;
    }
}


