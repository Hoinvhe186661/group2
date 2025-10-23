package com.hlgenerator.dao;

import com.hlgenerator.model.Supplier;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SupplierDAO extends DBConnect {
    private String lastError;
    public String getLastError() { return lastError; }

    /**
     * Thêm nhà cung cấp mới vào cơ sở dữ liệu
     */
    public boolean addSupplier(Supplier supplier) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }
        
        // Kiểm tra kết nối còn hoạt động không
        try {
            if (connection.isClosed()) {
                lastError = "Kết nối cơ sở dữ liệu đã bị đóng";
                return false;
            }
        } catch (SQLException e) {
            lastError = "Lỗi kiểm tra kết nối: " + e.getMessage();
            return false;
        }
        
        String sql = "INSERT INTO suppliers (supplier_code, company_name, contact_person, email, phone, address, bank_info, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, supplier.getSupplierCode());
            ps.setString(2, supplier.getCompanyName());
            ps.setString(3, supplier.getContactPerson());
            ps.setString(4, supplier.getEmail());
            ps.setString(5, supplier.getPhone());
            ps.setString(6, supplier.getAddress());
            ps.setString(7, supplier.getBankInfo());
            ps.setString(8, supplier.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            lastError = "Lỗi thêm nhà cung cấp: " + e.getMessage();
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy danh sách tất cả nhà cung cấp
     */
    public List<Supplier> getAllSuppliers() {
        List<Supplier> list = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return list;
        }
        
        // Kiểm tra kết nối còn hoạt động không
        try {
            if (connection.isClosed()) {
                lastError = "Kết nối cơ sở dữ liệu đã bị đóng";
                return list;
            }
        } catch (SQLException e) {
            lastError = "Lỗi kiểm tra kết nối: " + e.getMessage();
            return list;
        }
        
        String sql = "SELECT * FROM suppliers ORDER BY created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
        ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            lastError = "Lỗi lấy danh sách nhà cung cấp: " + e.getMessage();
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy nhà cung cấp theo ID
     */
    public Supplier getSupplierById(int id) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return null;
        }
        
        String sql = "SELECT * FROM suppliers WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Cập nhật thông tin nhà cung cấp
     */
    public boolean updateSupplier(Supplier s) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }
        
        String sql = "UPDATE suppliers SET supplier_code=?, company_name=?, contact_person=?, email=?, phone=?, address=?, bank_info=?, status=? WHERE id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, s.getSupplierCode());
            ps.setString(2, s.getCompanyName());
            ps.setString(3, s.getContactPerson());
            ps.setString(4, s.getEmail());
            ps.setString(5, s.getPhone());
            ps.setString(6, s.getAddress());
            ps.setString(7, s.getBankInfo());
            ps.setString(8, s.getStatus());
            ps.setInt(9, s.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Xóa nhà cung cấp theo ID
     */
    public boolean deleteSupplier(int id) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }
        
        String sql = "DELETE FROM suppliers WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy danh sách nhà cung cấp có lọc và phân trang
     */
    public List<Supplier> getFilteredSuppliers(String companyName, String contactPerson, String status, String keyword) {
        List<Supplier> list = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return list;
        }
        
        // Kiểm tra kết nối còn hoạt động không
        try {
            if (connection.isClosed()) {
                lastError = "Kết nối cơ sở dữ liệu đã bị đóng";
                return list;
            }
        } catch (SQLException e) {
            lastError = "Lỗi kiểm tra kết nối: " + e.getMessage();
            return list;
        }
        
        StringBuilder sql = new StringBuilder("SELECT * FROM suppliers WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        if (companyName != null && !companyName.trim().isEmpty()) {
            sql.append(" AND company_name = ?");
            params.add(companyName);
        }
        
        if (contactPerson != null && !contactPerson.trim().isEmpty()) {
            sql.append(" AND contact_person = ?");
            params.add(contactPerson);
        }
        
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status);
        }
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(supplier_code) LIKE LOWER(?) OR LOWER(company_name) LIKE LOWER(?) OR LOWER(contact_person) LIKE LOWER(?) OR LOWER(email) LIKE LOWER(?) OR LOWER(phone) LIKE LOWER(?))");
            String likeKeyword = "%" + keyword + "%";
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
        }
        
        sql.append(" ORDER BY created_at DESC");
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            lastError = "Lỗi lọc nhà cung cấp: " + e.getMessage();
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy danh sách nhà cung cấp với lọc backend bằng SQL query
     */
    public List<Supplier> getSuppliersWithBackendFilter(String companyName, String contactPerson, String status, String keyword, int page, int pageSize) {
        List<Supplier> list = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return list;
        }
        
        // Kiểm tra kết nối còn hoạt động không
        try {
            if (connection.isClosed()) {
                lastError = "Kết nối cơ sở dữ liệu đã bị đóng";
                return list;
            }
        } catch (SQLException e) {
            lastError = "Lỗi kiểm tra kết nối: " + e.getMessage();
            return list;
        }
        
        StringBuilder sql = new StringBuilder("SELECT * FROM suppliers WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        // Lọc theo tên công ty (partial match từ dropdown)
        if (companyName != null && !companyName.trim().isEmpty()) {
            sql.append(" AND LOWER(company_name) LIKE LOWER(?)");
            params.add("%" + companyName + "%");
        }
        
        // Lọc theo người liên hệ (partial match từ dropdown)
        if (contactPerson != null && !contactPerson.trim().isEmpty()) {
            sql.append(" AND LOWER(contact_person) LIKE LOWER(?)");
            params.add("%" + contactPerson + "%");
        }
        
        // Lọc theo trạng thái
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status);
        }
        
        // Tìm kiếm tổng quát - tìm kiếm trong tất cả các trường
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(supplier_code) LIKE LOWER(?) OR LOWER(company_name) LIKE LOWER(?) OR LOWER(contact_person) LIKE LOWER(?) OR LOWER(email) LIKE LOWER(?) OR LOWER(phone) LIKE LOWER(?) OR LOWER(address) LIKE LOWER(?) OR LOWER(bank_info) LIKE LOWER(?))");
            String likeKeyword = "%" + keyword + "%";
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
        }
        
        sql.append(" ORDER BY created_at DESC");
        
        // Thêm phân trang
        if (page > 0 && pageSize > 0) {
            int offset = (page - 1) * pageSize;
            sql.append(" LIMIT ? OFFSET ?");
            params.add(pageSize);
            params.add(offset);
        }
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            lastError = "Lỗi lọc nhà cung cấp: " + e.getMessage();
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm tổng số nhà cung cấp với điều kiện lọc
     */
    public int countSuppliersWithFilter(String companyName, String contactPerson, String status, String keyword) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return 0;
        }
        
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM suppliers WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        // Lọc theo tên công ty (partial match từ dropdown)
        if (companyName != null && !companyName.trim().isEmpty()) {
            sql.append(" AND LOWER(company_name) LIKE LOWER(?)");
            params.add("%" + companyName + "%");
        }
        
        // Lọc theo người liên hệ (partial match từ dropdown)
        if (contactPerson != null && !contactPerson.trim().isEmpty()) {
            sql.append(" AND LOWER(contact_person) LIKE LOWER(?)");
            params.add("%" + contactPerson + "%");
        }
        
        // Lọc theo trạng thái
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status);
        }
        
        // Tìm kiếm tổng quát - tìm kiếm trong tất cả các trường
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(supplier_code) LIKE LOWER(?) OR LOWER(company_name) LIKE LOWER(?) OR LOWER(contact_person) LIKE LOWER(?) OR LOWER(email) LIKE LOWER(?) OR LOWER(phone) LIKE LOWER(?) OR LOWER(address) LIKE LOWER(?) OR LOWER(bank_info) LIKE LOWER(?))");
            String likeKeyword = "%" + keyword + "%";
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
        }
        
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
            lastError = "Lỗi đếm nhà cung cấp: " + e.getMessage();
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Kiểm tra supplier_code có tồn tại không
     */
    public boolean isSupplierCodeExists(String supplierCode) {
        return isSupplierCodeExists(supplierCode, -1);
    }
    
    /**
     * Kiểm tra supplier_code có tồn tại không (trừ ID hiện tại)
     */
    public boolean isSupplierCodeExists(String supplierCode, int excludeId) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }
        
        String sql = "SELECT COUNT(*) FROM suppliers WHERE supplier_code = ?";
        if (excludeId > 0) {
            sql += " AND id != ?";
        }
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, supplierCode);
            if (excludeId > 0) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Ẩn nhà cung cấp (soft delete) - chuyển status thành 'inactive'
     * Đồng thời ẩn tất cả sản phẩm của nhà cung cấp này
     */
    public boolean hideSupplier(int supplierId) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }

        try {
            // Bắt đầu transaction
            connection.setAutoCommit(false);

            // 1. Ẩn tất cả sản phẩm của nhà cung cấp này
            String hideProductsSQL = "UPDATE products SET status = 'discontinued' WHERE supplier_id = ?";
            try (PreparedStatement ps1 = connection.prepareStatement(hideProductsSQL)) {
                ps1.setInt(1, supplierId);
                ps1.executeUpdate();
            }

            // 2. Ẩn nhà cung cấp
            String hideSupplierSQL = "UPDATE suppliers SET status = 'inactive' WHERE id = ?";
            try (PreparedStatement ps2 = connection.prepareStatement(hideSupplierSQL)) {
                ps2.setInt(1, supplierId);
                ps2.executeUpdate();
            }

            // Commit transaction
            connection.commit();
            connection.setAutoCommit(true);
            return true;

        } catch (SQLException e) {
            // Rollback nếu có lỗi
            try {
                connection.rollback();
                connection.setAutoCommit(true);
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            lastError = "Lỗi khi ẩn nhà cung cấp: " + e.getMessage();
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Hiện lại nhà cung cấp - chuyển status thành 'active'
     * Lưu ý: Không tự động hiện lại sản phẩm, cần hiện thủ công
     */
    public boolean showSupplier(int supplierId) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }

        String sql = "UPDATE suppliers SET status = 'active' WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            lastError = "Lỗi khi hiện nhà cung cấp: " + e.getMessage();
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Map dữ liệu từ ResultSet thành đối tượng Supplier
     */
    private Supplier mapRow(ResultSet rs) throws SQLException {
        Supplier s = new Supplier();
        s.setId(rs.getInt("id"));
        s.setSupplierCode(rs.getString("supplier_code"));
        s.setCompanyName(rs.getString("company_name"));
        s.setContactPerson(rs.getString("contact_person"));
        s.setEmail(rs.getString("email"));
        s.setPhone(rs.getString("phone"));
        s.setAddress(rs.getString("address"));
        s.setBankInfo(rs.getString("bank_info"));
        s.setStatus(rs.getString("status"));
        return s;
    }
}
