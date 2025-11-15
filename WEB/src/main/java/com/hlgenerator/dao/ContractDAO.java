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

    // Kiểm tra kết nối database có còn hoạt động không
    private boolean checkConnection() {
        try {
            return connection != null && !connection.isClosed();
        } catch (SQLException e) {
            logger.severe("Error checking database connection: " + e.getMessage());
            return false;
        }
    }

    public boolean isContractNumberExists(String contractNumber) {
        return checkContractNumberExists(contractNumber, null, false);
    }

    public boolean isContractNumberExistsIncludingDeleted(String contractNumber) {
        return checkContractNumberExists(contractNumber, null, true);
    }

    public boolean isContractNumberExistsIncludingDeleted(String contractNumber, int excludeId) {
        return checkContractNumberExists(contractNumber, excludeId, true);
    }

    public boolean isContractNumberExists(String contractNumber, int excludeId) {
        return checkContractNumberExists(contractNumber, excludeId, false);
    }

    // Thêm hợp đồng mới vào database
    public boolean addContract(Contract contract) {
        if (!checkConnection()) return false;
        
        // Kiểm tra số hợp đồng có trùng không
        if (isContractNumberExists(contract.getContractNumber())) {
            logger.warning("Contract number already exists: " + contract.getContractNumber());
            return false;
        }
        
        // Insert hợp đồng vào database
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
                // Lấy ID tự động sinh và set vào contract
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

    // Cập nhật thông tin hợp đồng
    public boolean updateContract(Contract contract) {
        if (!checkConnection()) return false;
        
        // Kiểm tra số hợp đồng có trùng không (loại trừ chính hợp đồng đang sửa)
        if (isContractNumberExists(contract.getContractNumber(), contract.getId())) {
            logger.warning("Contract number already exists for update: " + contract.getContractNumber());
            return false;
        }
        
        // Update hợp đồng trong database
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

    /**
     * Cập nhật trạng thái hợp đồng
     * @param contractId ID của hợp đồng
     * @param status Trạng thái mới
     * @return true nếu cập nhật thành công, false nếu thất bại
     */
    public boolean updateContractStatus(int contractId, String status) {
        if (!checkConnection()) return false;
        String sql = "UPDATE contracts SET status = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, contractId);
            int result = ps.executeUpdate();
            logger.info("Updated contract ID " + contractId + " status to " + status + ", affected rows: " + result);
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating contract status", e);
            return false;
        }
    }

    // Xóa hợp đồng (soft delete - chuyển vào thùng rác)
    public boolean deleteContract(int id) {
        return performSoftDelete(id, null);
    }

    // Xóa hợp đồng kèm thông tin người xóa
    public boolean deleteContract(int id, int deletedBy) {
        return performSoftDelete(id, deletedBy);
    }

    // Khôi phục hợp đồng từ thùng rác về trạng thái "draft"
    public boolean restoreContract(int id) {
        return performRestore(id, "draft");
    }

    // Khôi phục hợp đồng về trạng thái chỉ định
    public boolean restoreContractWithStatus(int id, String status) {
        return performRestore(id, status);
    }

    // Xóa vĩnh viễn hợp đồng khỏi database (chỉ xóa được khi status = 'deleted')
    public boolean permanentlyDeleteContract(int id) {
        if (!checkConnection()) return false;
        String sql = "DELETE FROM contracts WHERE id = ? AND status = 'deleted'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error permanently deleting contract", e);
            return false;
        }
    }

    // Lấy hợp đồng theo ID (kèm thông tin khách hàng)
    public Contract getContractById(int id) {
        if (!checkConnection()) return null;
        String sql = "SELECT c.*, cu.company_name as customer_name, cu.phone as customer_phone FROM contracts c LEFT JOIN customers cu ON cu.id = c.customer_id WHERE c.id=?";
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

    // Lấy tất cả hợp đồng (không bao gồm đã xóa)
    public List<Contract> getAllContracts() {
        List<Contract> list = new ArrayList<>();
        if (!checkConnection()) {
            logger.warning("ContractDAO: No database connection");
            return list;
        }
        String sql = "SELECT c.*, cu.company_name as customer_name, cu.phone as customer_phone FROM contracts c LEFT JOIN customers cu ON cu.id = c.customer_id WHERE c.status != 'deleted' ORDER BY c.id DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            int count = 0;
            while (rs.next()) {
                list.add(mapRow(rs));
                count++;
            }
            logger.info("ContractDAO.getAllContracts: Found " + count + " contracts (excluding deleted)");
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching all contracts", e);
        }
        return list;
    }
    
    /**
     * Lấy tất cả hợp đồng (kể cả deleted) - dùng để debug
     */
    public List<Contract> getAllContractsIncludingDeleted() {
        List<Contract> list = new ArrayList<>();
        if (!checkConnection()) return list;
        String sql = "SELECT c.*, cu.company_name as customer_name, cu.phone as customer_phone FROM contracts c LEFT JOIN customers cu ON cu.id = c.customer_id ORDER BY c.id DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching all contracts including deleted", e);
        }
        return list;
    }

    public int countAllContracts() {
        if (!checkConnection()) return 0;
        String sql = "SELECT COUNT(*) FROM contracts WHERE status != 'deleted'";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting contracts", e);
        }
        return 0;
    }

    public List<Contract> getDeletedContracts() {
        List<Contract> list = new ArrayList<>();
        if (!checkConnection()) return list;
        String sql = "SELECT c.*, cu.company_name as customer_name, cu.phone as customer_phone, u.full_name as deleted_by_name FROM contracts c " +
                    "LEFT JOIN customers cu ON cu.id = c.customer_id " +
                    "LEFT JOIN users u ON c.deleted_by = u.id " +
                    "WHERE c.status = 'deleted' ORDER BY c.deleted_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Contract contract = mapRow(rs);
                // Lưu thông tin người xóa vào một field tạm thời
                contract.setDeletedByName(rs.getString("deleted_by_name"));
                list.add(contract);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching deleted contracts", e);
        }
        return list;
    }

    public List<Contract> getDeletedContractsPage(int page, int pageSize, String search, String sortBy, String sortDir) {
        List<Contract> list = new ArrayList<>();
        if (!checkConnection()) return list;
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;
        
        logger.info("Getting deleted contracts page: " + page + ", size: " + pageSize + ", search: " + search);

        // Xác định cột sắp xếp
        String orderColumn;
        if ("id".equalsIgnoreCase(sortBy)) orderColumn = "c.id";
        else if ("contract_number".equalsIgnoreCase(sortBy)) orderColumn = "c.contract_number";
        else if ("title".equalsIgnoreCase(sortBy)) orderColumn = "c.title";
        else if ("deleted_by_name".equalsIgnoreCase(sortBy)) orderColumn = "u.full_name";
        else orderColumn = "c.deleted_at"; // default

        String direction = "DESC";
        if ("asc".equalsIgnoreCase(sortDir)) direction = "ASC";

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT c.*, cu.company_name as customer_name, cu.phone as customer_phone, u.full_name as deleted_by_name FROM contracts c ");
        sql.append("LEFT JOIN customers cu ON cu.id = c.customer_id ");
        sql.append("LEFT JOIN users u ON c.deleted_by = u.id ");
        sql.append("WHERE c.status = 'deleted' ");

        java.util.List<Object> params = new ArrayList<>();
        addSearchConditions(sql, params, search, "CAST(c.id AS CHAR)", "c.contract_number", "c.title", "u.full_name");

        sql.append("ORDER BY ").append(orderColumn).append(" ").append(direction).append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(offset);

        logger.info("SQL: " + sql.toString());
        logger.info("Params: " + params);
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Contract contract = mapRow(rs);
                    contract.setDeletedByName(rs.getString("deleted_by_name"));
                    list.add(contract);
                }
                logger.info("Found " + list.size() + " deleted contracts");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching deleted contracts page", e);
        }
        return list;
    }

    public int countDeletedContracts(String search) {
        if (!checkConnection()) return 0;
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM contracts c ");
        sql.append("LEFT JOIN users u ON c.deleted_by = u.id ");
        sql.append("WHERE c.status = 'deleted' ");

        java.util.List<Object> params = new ArrayList<>();
        addSearchConditions(sql, params, search, "CAST(c.id AS CHAR)", "c.contract_number", "c.title", "u.full_name");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting deleted contracts", e);
        }
        return 0;
    }

    public List<Contract> getContractsByCustomerId(int customerId) {
        List<Contract> list = new ArrayList<>();
        if (!checkConnection()) return list;
        String sql = "SELECT c.*, cu.company_name as customer_name, cu.phone as customer_phone FROM contracts c LEFT JOIN customers cu ON cu.id = c.customer_id WHERE c.customer_id = ? AND c.status != 'deleted' ORDER BY c.id DESC";
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
        String sql = "SELECT c.*, cu.company_name as customer_name, cu.phone as customer_phone FROM contracts c LEFT JOIN customers cu ON cu.id = c.customer_id WHERE c.status != 'deleted' ORDER BY c.id DESC LIMIT ? OFFSET ?";
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
                                      Date signedFrom, Date signedTo, Date endFrom, Date endTo) {
        if (!checkConnection()) return 0;
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM contracts c LEFT JOIN customers cu ON cu.id = c.customer_id WHERE 1=1");
        java.util.List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) { 
            sql.append(" AND c.status = ?"); 
            params.add(status); 
        } else {
            sql.append(" AND c.status != 'deleted'");
        }
        if (contractType != null && !contractType.isEmpty()) { sql.append(" AND c.contract_type = ?"); params.add(contractType); }
        addSearchConditions(sql, params, search, "CAST(c.id AS CHAR)", "c.contract_number", "c.title", "cu.company_name", "cu.contact_person", "cu.customer_code");
        if (signedFrom != null) { sql.append(" AND c.signed_date >= ?"); params.add(signedFrom); }
        if (signedTo != null) { sql.append(" AND c.signed_date <= ?"); params.add(signedTo); }
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
                                                   Date signedFrom, Date signedTo, Date endFrom, Date endTo,
                                                   String sortBy, String sortDir) {
        List<Contract> list = new ArrayList<>();
        if (!checkConnection()) return list;
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;

        // Whitelist sort columns
        String orderColumn;
        if ("customerName".equalsIgnoreCase(sortBy)) orderColumn = "cu.company_name";
        else if ("signedDate".equalsIgnoreCase(sortBy)) orderColumn = "c.signed_date";
        else if ("endDate".equalsIgnoreCase(sortBy)) orderColumn = "c.end_date";
        else if ("status".equalsIgnoreCase(sortBy)) orderColumn = "c.status";
        else orderColumn = "c.id"; // default id
        String direction = "DESC";
        if ("asc".equalsIgnoreCase(sortDir)) direction = "ASC";

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT c.*, cu.company_name as customer_name, cu.phone as customer_phone FROM contracts c LEFT JOIN customers cu ON cu.id = c.customer_id WHERE 1=1");
        java.util.List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) { 
            sql.append(" AND c.status = ?"); 
            params.add(status); 
        } else {
            sql.append(" AND c.status != 'deleted'");
        }
        if (contractType != null && !contractType.isEmpty()) { sql.append(" AND c.contract_type = ?"); params.add(contractType); }
        addSearchConditions(sql, params, search, "CAST(c.id AS CHAR)", "c.contract_number", "c.title", "cu.company_name", "cu.contact_person", "cu.customer_code");
        if (signedFrom != null) { sql.append(" AND c.signed_date >= ?"); params.add(signedFrom); }
        if (signedTo != null) { sql.append(" AND c.signed_date <= ?"); params.add(signedTo); }
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

    // Kiểm tra số hợp đồng có tồn tại không
    private boolean checkContractNumberExists(String contractNumber, Integer excludeId, boolean includeDeleted) {
        if (!checkConnection()) return false;
        
        // Xây dựng SQL query động
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM contracts WHERE contract_number = ?");
        if (excludeId != null) {
            sql.append(" AND id != ?"); // Loại trừ hợp đồng đang sửa
        }
        if (!includeDeleted) {
            sql.append(" AND status != 'deleted'"); // Không bao gồm đã xóa
        }
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            ps.setString(1, contractNumber);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking contract number existence", e);
            return false;
        }
    }

    // Thực hiện soft delete (chỉ đổi status = 'deleted', không xóa thật)
    private boolean performSoftDelete(int id, Integer deletedBy) {
        if (!checkConnection()) return false;
        
        // Kiểm tra xem các cột deleted_by, deleted_at có tồn tại không
        String[] columnsToCheck = deletedBy != null ? 
            new String[]{"deleted_by", "deleted_at"} : 
            new String[]{"deleted_at"};
        
        try {
            String checkSql = "SELECT " + String.join(", ", columnsToCheck) + " FROM contracts WHERE id = ? LIMIT 1";
            try (PreparedStatement checkPs = connection.prepareStatement(checkSql)) {
                checkPs.setInt(1, id);
                checkPs.executeQuery();
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Columns do not exist, using fallback method", e);
            // Nếu không có cột deleted_at thì chỉ cập nhật status
            String sql = "UPDATE contracts SET status = 'deleted' WHERE id = ?";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, id);
                int result = ps.executeUpdate();
                String logMsg = deletedBy != null ? 
                    "Fallback soft delete contract ID " + id + " by user " + deletedBy :
                    "Fallback soft delete contract ID " + id;
                logger.info(logMsg + ", affected rows: " + result);
                return result > 0;
            } catch (SQLException ex) {
                logger.log(Level.SEVERE, "Error in fallback soft delete", ex);
                return false;
            }
        }
        
        // Soft delete với deleted_at và deleted_by (nếu có)
        String sql = deletedBy != null ? 
            "UPDATE contracts SET status = 'deleted', deleted_by = ?, deleted_at = CURRENT_TIMESTAMP WHERE id = ?" :
            "UPDATE contracts SET status = 'deleted', deleted_at = CURRENT_TIMESTAMP WHERE id = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (deletedBy != null) {
                ps.setInt(1, deletedBy);
                ps.setInt(2, id);
            } else {
                ps.setInt(1, id);
            }
            int result = ps.executeUpdate();
            String logMsg = deletedBy != null ? 
                "Soft delete contract ID " + id + " by user " + deletedBy :
                "Soft delete contract ID " + id;
            logger.info(logMsg + ", affected rows: " + result);
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error soft deleting contract", e);
            return false;
        }
    }

    // Khôi phục hợp đồng từ thùng rác về trạng thái chỉ định
    private boolean performRestore(int id, String status) {
        if (!checkConnection()) return false;
        
        // Kiểm tra xem các cột deleted_by, deleted_at có tồn tại không
        try {
            String checkSql = "SELECT deleted_by, deleted_at FROM contracts WHERE id = ? LIMIT 1";
            try (PreparedStatement checkPs = connection.prepareStatement(checkSql)) {
                checkPs.setInt(1, id);
                checkPs.executeQuery();
            }
            // Nếu có các cột, reset chúng về NULL khi khôi phục
            String sql = "UPDATE contracts SET status = ?, deleted_by = NULL, deleted_at = NULL WHERE id = ? AND status = 'deleted'";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setString(1, status);
                ps.setInt(2, id);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            // Nếu không có các cột, chỉ cập nhật status
            logger.log(Level.INFO, "Columns deleted_by, deleted_at do not exist, using fallback restore method", e);
            String sql = "UPDATE contracts SET status = ? WHERE id = ? AND status = 'deleted'";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setString(1, status);
                ps.setInt(2, id);
                return ps.executeUpdate() > 0;
            } catch (SQLException ex) {
                logger.log(Level.SEVERE, "Error restoring contract", ex);
                return false;
            }
        }
    }

    // Thêm điều kiện tìm kiếm vào SQL query
    private void addSearchConditions(StringBuilder sql, List<Object> params, String search, String... columns) {
        if (search != null && !search.isEmpty()) {
            sql.append(" AND (");
            // Tìm kiếm trong các cột chỉ định
            for (int i = 0; i < columns.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append(columns[i]).append(" LIKE ?");
                params.add("%" + search + "%");
            }
            // Nếu search là số thì tìm chính xác theo ID
            try {
                int exactId = Integer.parseInt(search.trim());
                sql.append(" OR c.id = ?");
                params.add(exactId);
            } catch (NumberFormatException ignore) { /* not numeric */ }
            sql.append(")");
        }
    }

    // Chuyển đổi ResultSet thành đối tượng Contract
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
        
        // Lấy thông tin khách hàng nếu query có JOIN với bảng customers
        try {
            c.setCustomerName(rs.getString("customer_name"));
        } catch (SQLException e) {
            // Field không tồn tại trong một số query
        }
        try {
            c.setCustomerPhone(rs.getString("customer_phone"));
        } catch (SQLException e) {
            // Field không tồn tại trong một số query
        }
        
        // Lấy thông tin xóa nếu có
        try {
            c.setDeletedAt(rs.getTimestamp("deleted_at"));
        } catch (SQLException e) {
            // Field không tồn tại trong một số query
        }
        
        return c;
    }

    /**
     * Sinh số hợp đồng tự động theo định dạng: HD-YYYYMMDD-XXXX
     * - YYYYMMDD: ngày hiện tại theo múi giờ DB
     * - XXXX: số thứ tự tăng dần trong ngày, bắt đầu từ 0001
     * Bảo đảm không trùng với bản ghi (kể cả trong thùng rác).
     */
    public String generateNextContractNumber() {
        if (!checkConnection()) return null;
        // Lấy ngày hiện tại từ database để đồng bộ múi giờ
        String currentYmd = null;
        try (PreparedStatement ps = connection.prepareStatement("SELECT DATE_FORMAT(CURRENT_DATE, '%Y%m%d')")) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentYmd = rs.getString(1);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Error fetching current date from DB, fallback to JVM time", e);
        }
        if (currentYmd == null) {
            // Nếu không lấy được từ DB thì dùng thời gian JVM
            java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd");
            currentYmd = java.time.LocalDate.now().format(fmt);
        }

        String prefix = "HD-" + currentYmd + "-"; // VD: HD-20251103-
        String like = prefix + "%";

        int nextSeq = 1;
        String lastNumber = null;
        // Lấy số hợp đồng lớn nhất trong ngày (kể cả đã xóa) để tăng số thứ tự
        String sql = "SELECT contract_number FROM contracts WHERE contract_number LIKE ? ORDER BY contract_number DESC LIMIT 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, like);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    lastNumber = rs.getString(1);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching last contract number by prefix", e);
        }

        // Tăng số thứ tự dựa trên số hợp đồng lớn nhất
        if (lastNumber != null && lastNumber.startsWith(prefix)) {
            String tail = lastNumber.substring(prefix.length());
            try {
                nextSeq = Integer.parseInt(tail) + 1;
            } catch (NumberFormatException ignore) {
                nextSeq = 1;
            }
        }

        // Thử tối đa 10 lần để tránh xung đột khi nhiều request cùng lúc
        for (int attempt = 0; attempt < 10; attempt++) {
            String candidate = prefix + String.format("%04d", nextSeq);
            if (!isContractNumberExistsIncludingDeleted(candidate)) {
                return candidate; // Tìm thấy số không trùng
            }
            nextSeq++;
        }

        // Nếu vẫn trùng thì dùng UUID để đảm bảo unique
        String fallback = prefix + java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        return fallback;
    }
    
    public static class ContractDeliveryStats {
        private final int totalProducts;
        private final int deliveredProducts;

        public ContractDeliveryStats(int totalProducts, int deliveredProducts) {
            this.totalProducts = Math.max(totalProducts, 0);
            this.deliveredProducts = Math.max(deliveredProducts, 0);
        }

        public int getTotalProducts() {
            return totalProducts;
        }

        public int getDeliveredProducts() {
            return deliveredProducts;
        }

        public boolean isFullyDelivered() {
            return totalProducts > 0 && deliveredProducts >= totalProducts;
        }
    }

    public ContractDeliveryStats getContractDeliveryStats(int contractId) {
        if (!checkConnection()) {
            return new ContractDeliveryStats(0, 0);
        }

        String sql = "SELECT COUNT(*) AS total_products, " +
                     "SUM(CASE WHEN COALESCE(delivery_status, 'not_delivered') = 'delivered' THEN 1 ELSE 0 END) AS delivered_products " +
                     "FROM contract_products WHERE contract_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("total_products");
                    int delivered = rs.getInt("delivered_products");
                    return new ContractDeliveryStats(total, delivered);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting contract delivery stats for contract ID: " + contractId, e);
        }
        return new ContractDeliveryStats(0, 0);
    }

    /**
     * Lấy danh sách sản phẩm của hợp đồng
     * @param contractId ID của hợp đồng
     * @return Danh sách Map chứa thông tin sản phẩm (productId, quantity, productCode, productName, unit)
     */
    public List<java.util.Map<String, Object>> getContractProducts(int contractId) {
        List<java.util.Map<String, Object>> contractProducts = new ArrayList<>();
        if (!checkConnection()) {
            return contractProducts;
        }
        
        String sql = "SELECT cp.product_id, cp.quantity, p.product_code, p.product_name, p.unit, " +
                    "COALESCE(cp.delivery_status, 'not_delivered') AS delivery_status " +
                    "FROM contract_products cp " +
                    "LEFT JOIN products p ON p.id = cp.product_id " +
                    "WHERE cp.contract_id = ? ORDER BY cp.id";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> product = new java.util.HashMap<>();
                    product.put("productId", rs.getInt("product_id"));
                    product.put("quantity", rs.getBigDecimal("quantity"));
                    product.put("productCode", rs.getString("product_code"));
                    product.put("productName", rs.getString("product_name"));
                    product.put("unit", rs.getString("unit"));
                    product.put("deliveryStatus", rs.getString("delivery_status"));
                    contractProducts.add(product);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting contract products for contract ID: " + contractId, e);
        }
        
        return contractProducts;
    }
    
    /**
     * Lấy danh sách sản phẩm chưa bàn giao của hợp đồng (dùng cho xuất kho)
     * @param contractId ID của hợp đồng
     * @return Danh sách Map chứa thông tin sản phẩm chưa bàn giao (productId, quantity, productCode, productName, unit)
     */
    public List<java.util.Map<String, Object>> getContractProductsNotDelivered(int contractId) {
        List<java.util.Map<String, Object>> contractProducts = new ArrayList<>();
        if (!checkConnection()) {
            return contractProducts;
        }
        
        String sql = "SELECT cp.product_id, cp.quantity, p.product_code, p.product_name, p.unit, " +
                    "COALESCE(cp.delivery_status, 'not_delivered') AS delivery_status " +
                    "FROM contract_products cp " +
                    "LEFT JOIN products p ON p.id = cp.product_id " +
                    "WHERE cp.contract_id = ? " +
                    "AND COALESCE(cp.delivery_status, 'not_delivered') != 'delivered' " +
                    "ORDER BY cp.id";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> product = new java.util.HashMap<>();
                    product.put("productId", rs.getInt("product_id"));
                    product.put("quantity", rs.getBigDecimal("quantity"));
                    product.put("productCode", rs.getString("product_code"));
                    product.put("productName", rs.getString("product_name"));
                    product.put("unit", rs.getString("unit"));
                    product.put("deliveryStatus", rs.getString("delivery_status"));
                    contractProducts.add(product);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting contract products not delivered for contract ID: " + contractId, e);
        }
        
        return contractProducts;
    }
}


