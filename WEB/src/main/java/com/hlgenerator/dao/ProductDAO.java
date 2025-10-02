package com.hlgenerator.dao;

import com.hlgenerator.model.Product;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO extends DBConnect {
    private String lastError;

    public String getLastError() {
        return lastError;
    }
    
    public boolean addProduct(Product product) {
        String sql = "INSERT INTO products (product_code, product_name, category, description, unit, unit_price, supplier_id, specifications, image_url, warranty_months, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
            lastError = null; // Clear previous errors on success
            return result > 0;
            
        } catch (SQLException e) {
            lastError = e.getMessage();
            System.err.println("Error adding product: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products ORDER BY created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Product product = new Product();
                product.setId(rs.getInt("id"));
                product.setProductCode(rs.getString("product_code"));
                product.setProductName(rs.getString("product_name"));
                product.setCategory(rs.getString("category"));
                product.setDescription(rs.getString("description"));
                product.setUnit(rs.getString("unit"));
                product.setUnitPrice(rs.getDouble("unit_price"));
                product.setSupplierId(rs.getInt("supplier_id"));
                product.setSpecifications(rs.getString("specifications"));
                product.setImageUrl(rs.getString("image_url"));
                product.setWarrantyMonths(rs.getInt("warranty_months"));
                product.setStatus(rs.getString("status"));
                products.add(product);
            }
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
        }
        return products;
    }

    public Product getProductById(int id) {
        String sql = "SELECT * FROM products WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product product = new Product();
                    product.setId(rs.getInt("id"));
                    product.setProductCode(rs.getString("product_code"));
                    product.setProductName(rs.getString("product_name"));
                    product.setCategory(rs.getString("category"));
                    product.setDescription(rs.getString("description"));
                    product.setUnit(rs.getString("unit"));
                    product.setUnitPrice(rs.getDouble("unit_price"));
                    product.setSupplierId(rs.getInt("supplier_id"));
                    product.setSpecifications(rs.getString("specifications"));
                    product.setImageUrl(rs.getString("image_url"));
                    product.setWarrantyMonths(rs.getInt("warranty_months"));
                    product.setStatus(rs.getString("status"));
                    return product;
                }
            }
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateProduct(Product product) {
        String sql = "UPDATE products SET product_code=?, product_name=?, category=?, description=?, unit=?, unit_price=?, supplier_id=?, specifications=?, image_url=?, warranty_months=?, status=? WHERE id=?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteProduct(int id) {
        String sql = "DELETE FROM products WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
            return false;
        }
    }
    
    // Statistics methods
    public int getTotalProducts() {
        String sql = "SELECT COUNT(*) FROM products";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getTotalCategories() {
        String sql = "SELECT COUNT(DISTINCT category) FROM products WHERE category IS NOT NULL AND category != ''";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getActiveProducts() {
        String sql = "SELECT COUNT(*) FROM products WHERE status = 'active'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getLowStockProducts() {
        // Sản phẩm "sắp hết hàng" là những sản phẩm có giá thấp (dưới 1 triệu VNĐ) 
        // hoặc bảo hành ngắn (dưới 6 tháng) - có thể là hàng thanh lý
        String sql = "SELECT COUNT(*) FROM products WHERE (unit_price < 1000000 OR warranty_months < 6) AND status = 'active'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
        }
        return 0;
    }
    
    // Method để lấy tất cả thống kê trong một lần query (tối ưu hiệu suất)
    public java.util.Map<String, Integer> getAllStatistics() {
        java.util.Map<String, Integer> stats = new java.util.HashMap<>();
        
        // Query tổng hợp để lấy tất cả thống kê cùng lúc
        String sql = "SELECT " +
                    "COUNT(*) as total_products, " +
                    "COUNT(DISTINCT category) as total_categories, " +
                    "SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_products, " +
                    "SUM(CASE WHEN (unit_price < 1000000 OR warranty_months < 6) AND status = 'active' THEN 1 ELSE 0 END) as low_stock_products " +
                    "FROM products WHERE category IS NOT NULL AND category != ''";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("totalProducts", rs.getInt("total_products"));
                stats.put("totalCategories", rs.getInt("total_categories"));
                stats.put("activeProducts", rs.getInt("active_products"));
                stats.put("lowStockProducts", rs.getInt("low_stock_products"));
            }
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
            // Trả về giá trị mặc định nếu có lỗi
            stats.put("totalProducts", 0);
            stats.put("totalCategories", 0);
            stats.put("activeProducts", 0);
            stats.put("lowStockProducts", 0);
        }
        
        return stats;
    }
    
    // Method để lấy danh sách tất cả danh mục
    public java.util.List<String> getAllCategories() {
        java.util.List<String> categories = new java.util.ArrayList<>();
        String sql = "SELECT DISTINCT category FROM products WHERE category IS NOT NULL AND category != '' ORDER BY category";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
        } catch (SQLException e) {
            lastError = e.getMessage();
            e.printStackTrace();
        }
        
        return categories;
    }
}
