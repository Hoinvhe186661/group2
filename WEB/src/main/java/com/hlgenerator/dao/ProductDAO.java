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
            // Cho phép để trống giá bán ban đầu: nếu <= 0 thì set NULL
            if (product.getUnitPrice() > 0) {
                ps.setDouble(6, product.getUnitPrice());
            } else {
                ps.setNull(6, java.sql.Types.DECIMAL);
            }
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

        StringBuilder sql = new StringBuilder("SELECT p.*, s.company_name as supplier_name " +
                                             "FROM products p " +
                                             "LEFT JOIN suppliers s ON p.supplier_id = s.id " +
                                             "WHERE 1=1");
        List<Object> params = new ArrayList<>();

        // Thêm điều kiện lọc
        if (supplierId != null && !supplierId.trim().isEmpty()) {
            sql.append(" AND p.supplier_id = ?");
            params.add(Integer.parseInt(supplierId));
        }

        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND BINARY p.category = BINARY ?");
            params.add(category.trim());
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND p.status = ?");
            params.add(status.trim());
        }

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND (p.product_code LIKE ? OR p.product_name LIKE ? OR p.description LIKE ? " +
                      "OR p.category LIKE ? OR s.company_name LIKE ? OR CAST(p.unit_price AS CHAR) LIKE ? " +
                      "OR CASE WHEN p.status = 'active' THEN 'Đang bán' WHEN p.status = 'discontinued' THEN 'Ngừng bán' ELSE p.status END LIKE ?)");
            String likeTerm = "%" + searchTerm.trim() + "%";
            params.add(likeTerm); // product_code
            params.add(likeTerm); // product_name
            params.add(likeTerm); // description
            params.add(likeTerm); // category
            params.add(likeTerm); // supplier_name
            params.add(likeTerm); // unit_price
            params.add(likeTerm); // status (tiếng Việt)
        }

        sql.append(" ORDER BY p.created_at DESC");
        sql.append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        // Debug log
        System.out.println("=== FILTER PRODUCTS SQL DEBUG ===");
        System.out.println("SQL Query: " + sql.toString());
        System.out.println("Parameters: " + params);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            // Set parameters với UTF-8 encoding
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    ps.setString(i + 1, (String) param);
                } else {
                    ps.setObject(i + 1, param);
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = createProductFromResultSet(rs);
                    products.add(product);
                }
            }
        } catch (SQLException e) {
            System.err.println("SQL Error: " + e.getMessage());
            System.err.println("SQL Query: " + sql.toString());
            e.printStackTrace();
            lastError = "Lỗi khi lấy danh sách sản phẩm đã lọc: " + e.getMessage();
        }
        return products;
    }

    /**
     * Cập nhật unit_price nếu đang NULL hoặc 0
     */
    public boolean updateUnitPriceIfEmpty(int productId, double newPrice) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }

        String sql = "UPDATE products SET unit_price = ? WHERE id = ? AND (unit_price IS NULL OR unit_price = 0)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDouble(1, newPrice);
            ps.setInt(2, productId);
            int updated = ps.executeUpdate();
            return updated > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi cập nhật giá bán mặc định: " + e.getMessage();
            return false;
        }
    }

    /**
     * Đếm tổng số sản phẩm đã lọc
     */
    public int getFilteredProductsCount(String supplierId, String category, String status, String searchTerm) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return 0;
        }

        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products p " +
                                             "LEFT JOIN suppliers s ON p.supplier_id = s.id " +
                                             "WHERE 1=1");
        List<Object> params = new ArrayList<>();

        // Thêm điều kiện lọc
        if (supplierId != null && !supplierId.trim().isEmpty()) {
            sql.append(" AND p.supplier_id = ?");
            params.add(Integer.parseInt(supplierId));
        }

        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND BINARY p.category = BINARY ?");
            params.add(category.trim());
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND p.status = ?");
            params.add(status.trim());
        }

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND (p.product_code LIKE ? OR p.product_name LIKE ? OR p.description LIKE ? " +
                      "OR p.category LIKE ? OR s.company_name LIKE ? OR CAST(p.unit_price AS CHAR) LIKE ? " +
                      "OR CASE WHEN p.status = 'active' THEN 'Đang bán' WHEN p.status = 'discontinued' THEN 'Ngừng bán' ELSE p.status END LIKE ?)");
            String likeTerm = "%" + searchTerm.trim() + "%";
            params.add(likeTerm); // product_code
            params.add(likeTerm); // product_name
            params.add(likeTerm); // description
            params.add(likeTerm); // category
            params.add(likeTerm); // supplier_name
            params.add(likeTerm); // unit_price
            params.add(likeTerm); // status (tiếng Việt)
        }

        // Debug log
        System.out.println("=== COUNT PRODUCTS SQL DEBUG ===");
        System.out.println("SQL Query: " + sql.toString());
        System.out.println("Parameters: " + params);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            // Set parameters với UTF-8 encoding
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    ps.setString(i + 1, (String) param);
                } else {
                    ps.setObject(i + 1, param);
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("SQL Count Error: " + e.getMessage());
            System.err.println("SQL Query: " + sql.toString());
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
     * Ẩn sản phẩm (soft delete) - chuyển status thành 'discontinued'
     */
    public boolean hideProduct(int productId) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }

        String sql = "UPDATE products SET status = 'discontinued' WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi ẩn sản phẩm: " + e.getMessage();
            return false;
        }
    }

    /**
     * Hiện lại sản phẩm - chuyển status thành 'active'
     */
    public boolean showProduct(int productId) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }

        String sql = "UPDATE products SET status = 'active' WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi hiện sản phẩm: " + e.getMessage();
            return false;
        }
    }

    /**
     * Ẩn tất cả sản phẩm của một nhà cung cấp
     */
    public boolean hideProductsBySupplier(int supplierId) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }

        String sql = "UPDATE products SET status = 'discontinued' WHERE supplier_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi ẩn sản phẩm theo nhà cung cấp: " + e.getMessage();
            return false;
        }
    }

    /**
     * Đếm số lượng sản phẩm active của một nhà cung cấp
     */
    public int countActiveProductsBySupplier(int supplierId) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return 0;
        }

        String sql = "SELECT COUNT(*) FROM products WHERE supplier_id = ? AND status = 'active'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
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
     * Kiểm tra mã sản phẩm có tồn tại không
     * Tác giả: Sơn Lê
     * @param productCode - Mã sản phẩm cần kiểm tra
     * @return true nếu mã đã tồn tại, false nếu chưa có
     */
    public boolean isProductCodeExists(String productCode) {
        return isProductCodeExists(productCode, -1);
    }
    
    /**
     * Kiểm tra mã sản phẩm có tồn tại không (trừ ID hiện tại)
     * Tác giả: Sơn Lê
     * @param productCode - Mã sản phẩm cần kiểm tra
     * @param excludeId - ID sản phẩm cần loại trừ (dùng khi update)
     * @return true nếu mã đã tồn tại, false nếu chưa có
     */
    public boolean isProductCodeExists(String productCode, int excludeId) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }
        
        String sql = "SELECT COUNT(*) FROM products WHERE product_code = ?";
        if (excludeId > 0) {
            sql += " AND id != ?";
        }
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, productCode);
            if (excludeId > 0) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            lastError = "Lỗi khi kiểm tra mã sản phẩm: " + e.getMessage();
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy lỗi cuối cùng
     */
    public String getLastError() {
        return lastError;
    }
}