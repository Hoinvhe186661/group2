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
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
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
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int generatedId = rs.getInt(1);
                        contract.setId(generatedId);
                    }
                }
                return true;
            }
            return false;
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

    public int countAllContracts() {
        if (!checkConnection()) return 0;
        String sql = "SELECT COUNT(*) FROM contracts";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting contracts", e);
        }
        return 0;
    }

    public List<Contract> getContractsByCustomerId(int customerId) {
        List<Contract> list = new ArrayList<>();
        if (!checkConnection()) return list;
        String sql = "SELECT * FROM contracts WHERE customer_id = ? ORDER BY id DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching contracts by customer id", e);
        }
        return list;
    }

    public List<Contract> getContractsPage(int page, int pageSize) {
        List<Contract> list = new ArrayList<>();
        if (!checkConnection()) return list;
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;
        String sql = "SELECT * FROM contracts ORDER BY id DESC LIMIT ? OFFSET ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, pageSize);
            ps.setInt(2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching contracts page", e);
        }
        return list;
    }

    public int countContractsFiltered(String status, String contractType, String search,
                                      Date startFrom, Date startTo, Date endFrom, Date endTo) {
        if (!checkConnection()) return 0;
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM contracts c LEFT JOIN customers cu ON cu.id = c.customer_id WHERE 1=1");
        java.util.List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) { sql.append(" AND c.status = ?"); params.add(status); }
        if (contractType != null && !contractType.isEmpty()) { sql.append(" AND c.contract_type = ?"); params.add(contractType); }
        if (search != null && !search.isEmpty()) {
            sql.append(" AND (CAST(c.id AS CHAR) LIKE ? OR c.contract_number LIKE ? OR c.title LIKE ? OR cu.company_name LIKE ? OR cu.contact_person LIKE ? OR cu.customer_code LIKE ?");
            String like = "%" + search + "%";
            params.add(like); params.add(like); params.add(like); params.add(like); params.add(like); params.add(like);
            try {
                int exactId = Integer.parseInt(search.trim());
                sql.append(" OR c.id = ?");
                params.add(exactId);
            } catch (NumberFormatException ignore) { /* not numeric */ }
            sql.append(")");
        }
        if (startFrom != null) { sql.append(" AND c.start_date >= ?"); params.add(startFrom); }
        if (startTo != null) { sql.append(" AND c.start_date <= ?"); params.add(startTo); }
        if (endFrom != null) { sql.append(" AND c.end_date >= ?"); params.add(endFrom); }
        if (endTo != null) { sql.append(" AND c.end_date <= ?"); params.add(endTo); }
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting filtered contracts", e);
        }
        return 0;
    }

    public List<Contract> getContractsPageFiltered(int page, int pageSize, String status, String contractType, String search,
                                                   Date startFrom, Date startTo, Date endFrom, Date endTo,
                                                   String sortBy, String sortDir) {
        List<Contract> list = new ArrayList<>();
        if (!checkConnection()) return list;
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;

        // Whitelist sort columns
        String orderColumn;
        if ("customerName".equalsIgnoreCase(sortBy)) orderColumn = "cu.company_name";
        else if ("startDate".equalsIgnoreCase(sortBy)) orderColumn = "c.start_date";
        else if ("endDate".equalsIgnoreCase(sortBy)) orderColumn = "c.end_date";
        else if ("status".equalsIgnoreCase(sortBy)) orderColumn = "c.status";
        else orderColumn = "c.id"; // default id
        String direction = "DESC";
        if ("asc".equalsIgnoreCase(sortDir)) direction = "ASC";

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT c.* FROM contracts c LEFT JOIN customers cu ON cu.id = c.customer_id WHERE 1=1");
        java.util.List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) { sql.append(" AND c.status = ?"); params.add(status); }
        if (contractType != null && !contractType.isEmpty()) { sql.append(" AND c.contract_type = ?"); params.add(contractType); }
        if (search != null && !search.isEmpty()) {
            sql.append(" AND (CAST(c.id AS CHAR) LIKE ? OR c.contract_number LIKE ? OR c.title LIKE ? OR cu.company_name LIKE ? OR cu.contact_person LIKE ? OR cu.customer_code LIKE ?");
            String like = "%" + search + "%";
            params.add(like); params.add(like); params.add(like); params.add(like); params.add(like); params.add(like);
            try {
                int exactId = Integer.parseInt(search.trim());
                sql.append(" OR c.id = ?");
                params.add(exactId);
            } catch (NumberFormatException ignore) { /* not numeric */ }
            sql.append(")");
        }
        if (startFrom != null) { sql.append(" AND c.start_date >= ?"); params.add(startFrom); }
        if (startTo != null) { sql.append(" AND c.start_date <= ?"); params.add(startTo); }
        if (endFrom != null) { sql.append(" AND c.end_date >= ?"); params.add(endFrom); }
        if (endTo != null) { sql.append(" AND c.end_date <= ?"); params.add(endTo); }
        sql.append(" ORDER BY ").append(orderColumn).append(" ").append(direction).append(" LIMIT ? OFFSET ?");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object p : params) { ps.setObject(idx++, p); }
            ps.setInt(idx++, pageSize);
            ps.setInt(idx, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching filtered contracts page", e);
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


