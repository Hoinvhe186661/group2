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
     * Tác giả: Sơn Lê
     */
    public boolean addSupplier(Supplier supplier) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
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
            lastError = e.getMessage();
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy danh sách tất cả nhà cung cấp
     * Tác giả: Sơn Lê
     */
    public List<Supplier> getAllSuppliers() {
        List<Supplier> list = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return list;
        }
        
        String sql = "SELECT * FROM suppliers ORDER BY created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
        ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy nhà cung cấp theo ID
     * Tác giả: Sơn Lê
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
     * Tác giả: Sơn Lê
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
     * Tác giả: Sơn Lê
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
     * Tác giả: Sơn Lê
     */
    public List<Supplier> getFilteredSuppliers(String companyName, String contactPerson, String status, String keyword) {
        List<Supplier> list = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
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
            lastError = e.getMessage();
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Map dữ liệu từ ResultSet thành đối tượng Supplier
     * Tác giả: Sơn Lê
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
