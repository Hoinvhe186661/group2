package com.hlgenerator.dao;

import com.hlgenerator.model.Product;
import java.sql.*;
import java.util.*;


public class ProductDAO {
    private Connection connection;
    private String lastError;

    
    public ProductDAO() {
        DBConnect dbConnect = new DBConnect();
        this.connection = dbConnect.connection;
    }

    
    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return products;
        }

        String sql = "SELECT p.*, s.company_name as supplier_name FROM products p LEFT JOIN suppliers s ON p.supplier_id = s.id ORDER BY p.created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Product product = createProductFromResultSet(rs);
                products.add(product);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy danh sách sản phẩm: " + e.getMessage();
        }
        return products;
    }

    
    public Product getProductById(int id) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return null;
        }

        String sql = "SELECT p.*, s.company_name as supplier_name FROM products p LEFT JOIN suppliers s ON p.supplier_id = s.id WHERE p.id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return createProductFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy sản phẩm: " + e.getMessage();
        }
        return null;
    }

    
    public boolean addProduct(Product product) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }

        String sql = "INSERT INTO products (product_code, product_name, category, description, " +
                    "unit, unit_price, supplier_id, specifications, image_url, warranty_months, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, product.getProductCode());
            ps.setString(2, product.getProductName());
            ps.setString(3, product.getCategory());
            ps.setString(4, product.getDescription());
            ps.setString(5, product.getUnit());
            ps.setDouble(6, product.getUnitPrice());
            ps.setInt(7, product.getSupplierId());
            ps.setString(8, product.getSpecifications());
            ps.setString(9, product.getImageUrl());
            ps.setInt(10, product.getWarrantyMonths());
            ps.setString(11, product.getStatus());

            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi thêm sản phẩm: " + e.getMessage();
            return false;
        }
    }

    
    public boolean updateProduct(Product product) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }

        String sql = "UPDATE products SET product_code = ?, product_name = ?, category = ?, " +
                    "description = ?, unit = ?, unit_price = ?, supplier_id = ?, specifications = ?, " +
                    "image_url = ?, warranty_months = ?, status = ? WHERE id = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, product.getProductCode());
            ps.setString(2, product.getProductName());
            ps.setString(3, product.getCategory());
            ps.setString(4, product.getDescription());
            ps.setString(5, product.getUnit());
            ps.setDouble(6, product.getUnitPrice());
            ps.setInt(7, product.getSupplierId());
            ps.setString(8, product.getSpecifications());
            ps.setString(9, product.getImageUrl());
            ps.setInt(10, product.getWarrantyMonths());
            ps.setString(11, product.getStatus());
            ps.setInt(12, product.getId());

            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi cập nhật sản phẩm: " + e.getMessage();
            return false;
        }
    }

    
    public boolean deleteProduct(int id) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }

        String sql = "DELETE FROM products WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi xóa sản phẩm: " + e.getMessage();
            return false;
        }
    }

    /**
     *Lấy danh sách sản phẩm đã lọc với phân trang
     */
    public List<Product> getFilteredProducts(String supplierId, String category, String status, 
                                           String searchTerm, int page, int pageSize) {
        List<Product> products = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return products;
        }

        StringBuilder sql = new StringBuilder("SELECT p.*, s.company_name as supplier_name FROM products p LEFT JOIN suppliers s ON p.supplier_id = s.id WHERE 1=1");
        List<Object> params = new ArrayList<>();

        // Thêm điều kiện lọc
        if (supplierId != null && !supplierId.trim().isEmpty()) {
            sql.append(" AND supplier_id = ?");
            params.add(Integer.parseInt(supplierId));
        }

        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND category = ?");
            params.add(category);
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status);
        }

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND (LOWER(product_code) LIKE LOWER(?) OR LOWER(product_name) LIKE LOWER(?) " +
                      "OR LOWER(description) LIKE LOWER(?))");
            String likeTerm = "%" + searchTerm + "%";
            params.add(likeTerm);
            params.add(likeTerm);
            params.add(likeTerm);
        }

        sql.append(" ORDER BY created_at DESC");
        sql.append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = createProductFromResultSet(rs);
                    products.add(product);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy danh sách sản phẩm đã lọc: " + e.getMessage();
        }
        return products;
    }

    /**
     * Đếm tổng số sản phẩm đã lọc
     */
    public int getFilteredProductsCount(String supplierId, String category, String status, String searchTerm) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return 0;
        }

        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products p LEFT JOIN suppliers s ON p.supplier_id = s.id WHERE 1=1");
        List<Object> params = new ArrayList<>();

        // Thêm điều kiện lọc
        if (supplierId != null && !supplierId.trim().isEmpty()) {
            sql.append(" AND supplier_id = ?");
            params.add(Integer.parseInt(supplierId));
        }

        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND category = ?");
            params.add(category);
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status);
        }

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND (LOWER(product_code) LIKE LOWER(?) OR LOWER(product_name) LIKE LOWER(?) " +
                      "OR LOWER(description) LIKE LOWER(?))");
            String likeTerm = "%" + searchTerm + "%";
            params.add(likeTerm);
            params.add(likeTerm);
            params.add(likeTerm);
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
            e.printStackTrace();
            lastError = "Lỗi khi đếm sản phẩm: " + e.getMessage();
        }
        return 0;
    }

    /**
     * Lấy tất cả danh mục sản phẩm
     */
    public List<String> getAllCategories() {
        List<String> categories = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return categories;
        }

        String sql = "SELECT DISTINCT category FROM products WHERE category IS NOT NULL ORDER BY category";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy danh sách danh mục: " + e.getMessage();
        }
        return categories;
    }

    /**
     * Lấy thống kê sản phẩm
     */
    public Map<String, Integer> getAllStatistics() {
        Map<String, Integer> statistics = new HashMap<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return statistics;
        }

        String sql = "SELECT " +
                    "COUNT(*) as total, " +
                    "COUNT(CASE WHEN status = 'active' THEN 1 END) as active, " +
                    "COUNT(CASE WHEN status = 'inactive' THEN 1 END) as inactive " +
                    "FROM products";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                statistics.put("total", rs.getInt("total"));
                statistics.put("active", rs.getInt("active"));
                statistics.put("inactive", rs.getInt("inactive"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy thống kê: " + e.getMessage();
        }
        return statistics;
    }

    /**
     * Tạo đối tượng Product từ ResultSet
     */
    private Product createProductFromResultSet(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setId(rs.getInt("id"));
        product.setProductCode(rs.getString("product_code"));
        product.setProductName(rs.getString("product_name"));
        product.setCategory(rs.getString("category"));
        product.setDescription(rs.getString("description"));
        product.setUnit(rs.getString("unit"));
        product.setUnitPrice(rs.getDouble("unit_price"));
        product.setSupplierId(rs.getInt("supplier_id"));
        product.setSupplierName(rs.getString("supplier_name")); // Thêm tên nhà cung cấp
        product.setSpecifications(rs.getString("specifications"));
        product.setImageUrl(rs.getString("image_url"));
        product.setWarrantyMonths(rs.getInt("warranty_months"));
        product.setStatus(rs.getString("status"));
        return product;
    }

    /**
     * Lấy lỗi cuối cùng
     */
    public String getLastError() {
        return lastError;
    }
}