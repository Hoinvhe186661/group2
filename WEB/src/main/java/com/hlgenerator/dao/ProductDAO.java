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

    /**
     * Cập nhật giá bán (unit_price) theo productId
     */
    public boolean updateUnitPrice(int productId, double newPrice) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }
        String sql = "UPDATE products SET unit_price = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDouble(1, newPrice);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi cập nhật giá bán: " + e.getMessage();
            return false;
        }
    }

    /**
     * Xóa cứng một sản phẩm, bao gồm toàn bộ dữ liệu phụ thuộc để tránh lỗi ràng buộc khóa ngoại.
     */
    public boolean deleteProduct(int id) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }

        boolean previousAutoCommit = true;
        try {
            previousAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);

            cleanupProductDependencies(id);

            String sql = "DELETE FROM products WHERE id = ?";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, id);
                int result = ps.executeUpdate();
                if (result == 0) {
                    connection.rollback();
                    lastError = "Không tìm thấy sản phẩm cần xóa";
                    return false;
                }
                connection.commit();
                return true;
            }
        } catch (SQLException e) {
            tryingRollback(e);
            return false;
        } finally {
            restoreAutoCommit(previousAutoCommit);
        }
    }

    /**
     * Xóa dữ liệu phụ thuộc của sản phẩm khỏi các bảng không hỗ trợ cascade delete.
     */
    private void cleanupProductDependencies(int productId) throws SQLException {
        deleteDependentRows("DELETE FROM contract_products WHERE product_id = ?", productId);
        deleteDependentRows("DELETE FROM invoice_items WHERE product_id = ?", productId);
        deleteDependentRows("DELETE FROM product_price_history WHERE product_id = ?", productId);
        deleteDependentRows("DELETE FROM inventory WHERE product_id = ?", productId);
        deleteDependentRows("DELETE FROM stock_history WHERE product_id = ?", productId);
    }

    /**
     * Thực thi câu lệnh DELETE tham số hóa cho một bảng phụ thuộc.
     */
    private void deleteDependentRows(String sql, int productId) throws SQLException {
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        }
    }

    /**
     * Khôi phục trạng thái auto-commit sau khi xử lý giao dịch xóa.
     */
    private void restoreAutoCommit(boolean previousAutoCommit) {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException ignore) {
        }
    }

    /**
     * Thực hiện rollback khi giao dịch xóa gặp lỗi và lưu thông báo lỗi cuối cùng.
     */
    private void tryingRollback(SQLException originalException) {
        if (connection != null) {
            try {
                connection.rollback();
            } catch (SQLException rollbackEx) {
                lastError = "Lỗi khi rollback sau khi xóa sản phẩm: " + rollbackEx.getMessage();
                rollbackEx.printStackTrace();
                return;
            }
        }
        lastError = "Lỗi khi xóa sản phẩm: " + originalException.getMessage();
        originalException.printStackTrace();
    }

    /**
     *Lấy danh sách sản phẩm đã lọc với phân trang
     */
    public List<Product> getFilteredProducts(String supplierId, String category, String status, 
                                           String searchTerm, int page, int pageSize) {
        return getFilteredProducts(supplierId, category, status, searchTerm, page, pageSize, null);
    }

    /**
     *Lấy danh sách sản phẩm đã lọc với phân trang và sắp xếp
     * @param sortBy "price_asc", "price_desc", hoặc null (mặc định: created_at DESC)
     */
    public List<Product> getFilteredProducts(String supplierId, String category, String status, 
                                           String searchTerm, int page, int pageSize, String sortBy) {
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
            // Chỉ tìm trong product_name và product_code để kết quả chính xác hơn
            // Tìm kiếm không phân biệt hoa thường
            sql.append(" AND (LOWER(p.product_name) LIKE ? OR LOWER(p.product_code) LIKE ?)");
            String likeTerm = "%" + searchTerm.trim().toLowerCase() + "%";
            params.add(likeTerm); // product_name
            params.add(likeTerm); // product_code
        }

        // Sắp xếp
        if ("price_asc".equals(sortBy)) {
            sql.append(" ORDER BY p.unit_price ASC, p.created_at DESC");
        } else if ("price_desc".equals(sortBy)) {
            sql.append(" ORDER BY p.unit_price DESC, p.created_at DESC");
        } else {
            sql.append(" ORDER BY p.created_at DESC");
        }
        
        sql.append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

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
     * Lấy danh sách sản phẩm đã lọc với tìm kiếm chính xác hơn (tìm theo nhiều từ)
     * Mỗi từ trong search term phải xuất hiện trong product_name hoặc product_code
     */
    public List<Product> getFilteredProductsWithExactSearch(String supplierId, String category, String status, 
                                                           String searchTerm, int page, int pageSize, String sortBy) {
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

        // Tìm kiếm chính xác: chỉ tìm trong product_name, không tách từ
        // Tìm sản phẩm có tên chứa chuỗi search term
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            String searchLower = searchTerm.trim().toLowerCase();
            // Chỉ tìm trong product_name, tìm exact string (không tách từ)
            sql.append(" AND LOWER(p.product_name) LIKE ?");
            String likeTerm = "%" + searchLower + "%";
            params.add(likeTerm);
        }

        // Sắp xếp
        if ("price_asc".equals(sortBy)) {
            sql.append(" ORDER BY p.unit_price ASC, p.created_at DESC");
        } else if ("price_desc".equals(sortBy)) {
            sql.append(" ORDER BY p.unit_price DESC, p.created_at DESC");
        } else {
            sql.append(" ORDER BY p.created_at DESC");
        }
        
        sql.append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
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
            e.printStackTrace();
            lastError = "Lỗi khi lấy danh sách sản phẩm đã lọc: " + e.getMessage();
        }
        return products;
    }

    /**
     * Đếm tổng số sản phẩm đã lọc với tìm kiếm chính xác hơn
     */
    public int getFilteredProductsCountWithExactSearch(String supplierId, String category, String status, String searchTerm) {
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

        // Tìm kiếm chính xác: chỉ tìm trong product_name, không tách từ
        // Tìm sản phẩm có tên chứa chuỗi search term
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            String searchLower = searchTerm.trim().toLowerCase();
            // Chỉ tìm trong product_name, tìm exact string (không tách từ)
            sql.append(" AND LOWER(p.product_name) LIKE ?");
            String likeTerm = "%" + searchLower + "%";
            params.add(likeTerm);
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
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
            e.printStackTrace();
            lastError = "Lỗi khi đếm sản phẩm: " + e.getMessage();
        }
        return 0;
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
            // Chỉ tìm trong product_name và product_code để kết quả chính xác hơn
            // Tìm kiếm không phân biệt hoa thường
            sql.append(" AND (LOWER(p.product_name) LIKE ? OR LOWER(p.product_code) LIKE ?)");
            String likeTerm = "%" + searchTerm.trim().toLowerCase() + "%";
            params.add(likeTerm); // product_name
            params.add(likeTerm); // product_code
        }

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
     * @param productCode - Mã sản phẩm cần kiểm tra
     * @return true nếu mã đã tồn tại, false nếu chưa có
     */
    public boolean isProductCodeExists(String productCode) {
        return isProductCodeExists(productCode, -1);
    }
    
    /**
     * Kiểm tra mã sản phẩm có tồn tại không (trừ ID hiện tại)
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
     * Sinh mã sản phẩm tự động theo định dạng: GEN-YYYYMMDD-XXXX
     * - YYYYMMDD: ngày hiện tại theo múi giờ DB
     * - XXXX: số thứ tự tăng dần trong ngày, bắt đầu từ 0001
     * Bảo đảm không trùng với bản ghi.
     */
    public String generateNextProductCode() {
        if (connection == null) {
            // Thử khởi tạo lại connection
            DBConnect dbConnect = new DBConnect();
            this.connection = dbConnect.connection;
            if (connection == null) {
                lastError = "Không thể kết nối đến cơ sở dữ liệu";
                return null;
            }
        }
        
        // Kiểm tra connection còn hoạt động không
        try {
            if (connection.isClosed()) {
                // Thử khởi tạo lại connection
                DBConnect dbConnect = new DBConnect();
                this.connection = dbConnect.connection;
                if (connection == null || connection.isClosed()) {
                    lastError = "Kết nối cơ sở dữ liệu đã bị đóng";
                    return null;
                }
            }
        } catch (SQLException e) {
            lastError = "Lỗi kiểm tra kết nối: " + e.getMessage();
            e.printStackTrace();
            return null;
        }
        
        // Lấy ngày theo định dạng yyyymmdd từ DB để đồng bộ múi giờ với DB
        String currentYmd = null;
        try (PreparedStatement ps = connection.prepareStatement("SELECT DATE_FORMAT(CURRENT_DATE, '%Y%m%d')")) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentYmd = rs.getString(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        if (currentYmd == null) {
            java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd");
            currentYmd = java.time.LocalDate.now().format(fmt);
        }

        String prefix = "GEN-" + currentYmd + "-"; // e.g. GEN-20251109-
        String like = prefix + "%";

        int nextSeq = 1;
        String lastNumber = null;
        // Lấy mã sản phẩm lớn nhất theo prefix rồi tăng +1
        String sql = "SELECT product_code FROM products WHERE product_code LIKE ? ORDER BY product_code DESC LIMIT 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, like);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    lastNumber = rs.getString(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (lastNumber != null && lastNumber.startsWith(prefix)) {
            String tail = lastNumber.substring(prefix.length());
            try {
                nextSeq = Integer.parseInt(tail) + 1;
            } catch (NumberFormatException ignore) {
                nextSeq = 1;
            }
        }

        // Thử tối đa 10 lần để tránh xung đột song song hiếm gặp
        for (int attempt = 0; attempt < 10; attempt++) {
            String candidate = prefix + String.format("%04d", nextSeq);
            if (!isProductCodeExists(candidate)) {
                return candidate;
            }
            nextSeq++;
        }

        // Cuối cùng nếu vẫn trùng, tạo chuỗi ngẫu nhiên an toàn hơn
        String fallback = prefix + java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        return fallback;
    }
    
    /**
     * Lấy danh sách sản phẩm chính (featured products) để hiển thị trên trang chủ
     * @param limit Số lượng sản phẩm cần lấy (mặc định 3)
     * @return Danh sách sản phẩm active, sắp xếp ngẫu nhiên
     */
    public List<Product> getFeaturedProducts(int limit) {
        List<Product> products = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return products;
        }

        String sql = "SELECT p.*, s.company_name as supplier_name " +
                    "FROM products p " +
                    "LEFT JOIN suppliers s ON p.supplier_id = s.id " +
                    "WHERE p.status = 'active' " +
                    "ORDER BY RAND() " +
                    "LIMIT ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = createProductFromResultSet(rs);
                    products.add(product);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy danh sách sản phẩm chính: " + e.getMessage();
        }
        return products;
    }
    
    /**
     * Lấy lỗi cuối cùng
     */
    public String getLastError() {
        return lastError;
    }
}