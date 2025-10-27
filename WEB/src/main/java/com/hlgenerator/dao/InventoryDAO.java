package com.hlgenerator.dao;

import com.hlgenerator.model.Inventory;
import com.hlgenerator.model.StockHistory;
import java.sql.*;
import java.util.*;

/**
 * DAO class cho quản lý tồn kho (Inventory & Stock History)
 * Xử lý các thao tác CRUD và nghiệp vụ kho
 */
public class InventoryDAO {
    private Connection connection;
    private String lastError;
    
    public InventoryDAO() {
        DBConnect dbConnect = new DBConnect();
        this.connection = dbConnect.connection;
    }
    
    /**
     * Lấy tất cả tồn kho (kèm thông tin sản phẩm)
     */
    public List<Inventory> getAllInventory() {
        List<Inventory> inventoryList = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return inventoryList;
        }
        
        String sql = "SELECT i.*, p.product_code, p.product_name, p.category, p.unit, p.unit_price, p.image_url " +
                     "FROM inventory i " +
                     "INNER JOIN products p ON i.product_id = p.id " +
                     "ORDER BY i.last_updated DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                inventoryList.add(createInventoryFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy danh sách tồn kho: " + e.getMessage();
        }
        
        return inventoryList;
    }
    
    /**
     * Lấy tồn kho với bộ lọc và phân trang (Backend Processing)
     */
    public List<Inventory> getFilteredInventory(String category, String warehouse, 
                                                 String stockStatus, String search, 
                                                 int page, int pageSize) {
        List<Inventory> inventoryList = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return inventoryList;
        }
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT i.*, p.product_code, p.product_name, p.category, p.unit, p.unit_price, p.image_url ");
        sql.append("FROM inventory i ");
        sql.append("INNER JOIN products p ON i.product_id = p.id ");
        sql.append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        // Lọc theo danh mục
        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND p.category = ? ");
            params.add(category);
        }
        
        // Lọc theo vị trí kho
        if (warehouse != null && !warehouse.trim().isEmpty()) {
            sql.append("AND i.warehouse_location = ? ");
            params.add(warehouse);
        }
        
        // Lọc theo trạng thái tồn kho
        if (stockStatus != null && !stockStatus.trim().isEmpty()) {
            switch (stockStatus) {
                case "out":
                    sql.append("AND i.current_stock <= 0 ");
                    break;
                case "low":
                    sql.append("AND i.current_stock > 0 AND i.current_stock <= i.min_stock ");
                    break;
                case "normal":
                    sql.append("AND i.current_stock > i.min_stock ");
                    break;
            }
        }
        
        // Tìm kiếm theo tên hoặc mã sản phẩm
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (p.product_name LIKE ? OR p.product_code LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        sql.append("ORDER BY i.last_updated DESC ");
        
        // Phân trang
        int offset = (page - 1) * pageSize;
        sql.append("LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(offset);
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    inventoryList.add(createInventoryFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lọc tồn kho: " + e.getMessage();
        }
        
        return inventoryList;
    }
    
    /**
     * Đếm tổng số tồn kho theo bộ lọc (cho phân trang)
     */
    public int getFilteredInventoryCount(String category, String warehouse, 
                                         String stockStatus, String search) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return 0;
        }
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM inventory i ");
        sql.append("INNER JOIN products p ON i.product_id = p.id ");
        sql.append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND p.category = ? ");
            params.add(category);
        }
        
        if (warehouse != null && !warehouse.trim().isEmpty()) {
            sql.append("AND i.warehouse_location = ? ");
            params.add(warehouse);
        }
        
        if (stockStatus != null && !stockStatus.trim().isEmpty()) {
            switch (stockStatus) {
                case "out":
                    sql.append("AND i.current_stock <= 0 ");
                    break;
                case "low":
                    sql.append("AND i.current_stock > 0 AND i.current_stock <= i.min_stock ");
                    break;
                case "normal":
                    sql.append("AND i.current_stock > i.min_stock ");
                    break;
            }
        }
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (p.product_name LIKE ? OR p.product_code LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
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
            lastError = "Lỗi khi đếm tồn kho: " + e.getMessage();
        }
        
        return 0;
    }
    
    /**
     * Lấy tồn kho theo product_id và warehouse
     */
    public Inventory getInventoryByProductAndWarehouse(int productId, String warehouseLocation) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return null;
        }
        
        String sql = "SELECT i.*, p.product_code, p.product_name, p.category, p.unit, p.unit_price, p.image_url " +
                     "FROM inventory i " +
                     "INNER JOIN products p ON i.product_id = p.id " +
                     "WHERE i.product_id = ? AND i.warehouse_location = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setString(2, warehouseLocation);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return createInventoryFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy tồn kho: " + e.getMessage();
        }
        
        return null;
    }
    
    /**
     * Cập nhật số lượng tồn kho
     */
    public boolean updateStock(int productId, String warehouseLocation, int newStock) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }
        
        String sql = "UPDATE inventory SET current_stock = ? WHERE product_id = ? AND warehouse_location = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, newStock);
            ps.setInt(2, productId);
            ps.setString(3, warehouseLocation);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi cập nhật tồn kho: " + e.getMessage();
            return false;
        }
    }
    
    /**
     * Cộng số lượng vào tồn kho (nhập kho)
     */
    public boolean addStock(int productId, String warehouseLocation, int quantity) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }
        
        // Kiểm tra xem đã có inventory record chưa
        Inventory existing = getInventoryByProductAndWarehouse(productId, warehouseLocation);
        
        if (existing == null) {
            // Chưa có -> Tạo mới
            String insertSql = "INSERT INTO inventory (product_id, warehouse_location, current_stock, min_stock, max_stock) " +
                              "VALUES (?, ?, ?, 0, 1000)";
            try (PreparedStatement ps = connection.prepareStatement(insertSql)) {
                ps.setInt(1, productId);
                ps.setString(2, warehouseLocation);
                ps.setInt(3, quantity);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                e.printStackTrace();
                lastError = "Lỗi khi tạo inventory: " + e.getMessage();
                return false;
            }
        } else {
            // Đã có -> Cập nhật
            String updateSql = "UPDATE inventory SET current_stock = current_stock + ? " +
                              "WHERE product_id = ? AND warehouse_location = ?";
            try (PreparedStatement ps = connection.prepareStatement(updateSql)) {
                ps.setInt(1, quantity);
                ps.setInt(2, productId);
                ps.setString(3, warehouseLocation);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                e.printStackTrace();
                lastError = "Lỗi khi cộng tồn kho: " + e.getMessage();
                return false;
            }
        }
    }
    
    /**
     * Trừ số lượng từ tồn kho (xuất kho)
     */
    public boolean subtractStock(int productId, String warehouseLocation, int quantity) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }
        
        String sql = "UPDATE inventory SET current_stock = current_stock - ? " +
                     "WHERE product_id = ? AND warehouse_location = ? AND current_stock >= ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, productId);
            ps.setString(3, warehouseLocation);
            ps.setInt(4, quantity); // Đảm bảo có đủ hàng
            
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected == 0) {
                lastError = "Không đủ hàng trong kho để xuất";
                return false;
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi trừ tồn kho: " + e.getMessage();
            return false;
        }
    }
    
    /**
     * Thêm bản ghi vào lịch sử xuất nhập kho
     */
    public boolean addStockHistory(StockHistory history) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }
        
        String sql = "INSERT INTO stock_history (product_id, warehouse_location, movement_type, quantity, " +
                     "reference_type, reference_id, unit_cost, notes, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, history.getProductId());
            ps.setString(2, history.getWarehouseLocation());
            ps.setString(3, history.getMovementType());
            ps.setInt(4, history.getQuantity());
            ps.setString(5, history.getReferenceType());
            
            if (history.getReferenceId() != null) {
                ps.setInt(6, history.getReferenceId());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            
            if (history.getUnitCost() != null) {
                ps.setDouble(7, history.getUnitCost());
            } else {
                ps.setNull(7, Types.DOUBLE);
            }
            
            ps.setString(8, history.getNotes());
            
            if (history.getCreatedBy() != null) {
                ps.setInt(9, history.getCreatedBy());
            } else {
                ps.setNull(9, Types.INTEGER);
            }
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi ghi lịch sử: " + e.getMessage();
            return false;
        }
    }
    
    /**
     * Lấy lịch sử xuất nhập kho (tất cả hoặc theo product)
     */
    public List<StockHistory> getStockHistory(Integer productId, int limit) {
        List<StockHistory> historyList = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return historyList;
        }
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT sh.*, p.product_code, p.product_name, u.full_name as created_by_name ");
        sql.append("FROM stock_history sh ");
        sql.append("INNER JOIN products p ON sh.product_id = p.id ");
        sql.append("LEFT JOIN users u ON sh.created_by = u.id ");
        
        if (productId != null) {
            sql.append("WHERE sh.product_id = ? ");
        }
        
        sql.append("ORDER BY sh.created_at DESC ");
        
        if (limit > 0) {
            sql.append("LIMIT ?");
        }
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            
            if (productId != null) {
                ps.setInt(paramIndex++, productId);
            }
            
            if (limit > 0) {
                ps.setInt(paramIndex, limit);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    historyList.add(createStockHistoryFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy lịch sử: " + e.getMessage();
        }
        
        return historyList;
    }
    
    /**
     * Lấy thống kê dashboard
     */
    public Map<String, Integer> getInventoryStatistics() {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("totalProducts", 0);
        stats.put("totalStock", 0);
        stats.put("lowStockCount", 0);
        stats.put("outOfStockCount", 0);
        
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return stats;
        }
        
        String sql = "SELECT " +
                     "COUNT(DISTINCT product_id) as total_products, " +
                     "SUM(current_stock) as total_stock, " +
                     "SUM(CASE WHEN current_stock > 0 AND current_stock <= min_stock THEN 1 ELSE 0 END) as low_stock, " +
                     "SUM(CASE WHEN current_stock <= 0 THEN 1 ELSE 0 END) as out_of_stock " +
                     "FROM inventory";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                stats.put("totalProducts", rs.getInt("total_products"));
                stats.put("totalStock", rs.getInt("total_stock"));
                stats.put("lowStockCount", rs.getInt("low_stock"));
                stats.put("outOfStockCount", rs.getInt("out_of_stock"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy thống kê: " + e.getMessage();
        }
        
        return stats;
    }
    
    /**
     * Lấy danh sách các category từ products
     */
    public List<String> getAllCategories() {
        List<String> categories = new ArrayList<>();
        if (connection == null) return categories;
        
        String sql = "SELECT DISTINCT category FROM products WHERE category IS NOT NULL ORDER BY category";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return categories;
    }
    
    /**
     * Lấy danh sách các warehouse location
     */
    public List<String> getAllWarehouseLocations() {
        List<String> locations = new ArrayList<>();
        if (connection == null) return locations;
        
        String sql = "SELECT DISTINCT warehouse_location FROM inventory ORDER BY warehouse_location";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                locations.add(rs.getString("warehouse_location"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return locations;
    }
    
    // Helper methods
    private Inventory createInventoryFromResultSet(ResultSet rs) throws SQLException {
        Inventory inventory = new Inventory();
        inventory.setId(rs.getInt("id"));
        inventory.setProductId(rs.getInt("product_id"));
        inventory.setWarehouseLocation(rs.getString("warehouse_location"));
        inventory.setCurrentStock(rs.getInt("current_stock"));
        inventory.setMinStock(rs.getInt("min_stock"));
        inventory.setMaxStock(rs.getInt("max_stock"));
        inventory.setLastUpdated(rs.getTimestamp("last_updated"));
        
        // JOIN fields
        inventory.setProductCode(rs.getString("product_code"));
        inventory.setProductName(rs.getString("product_name"));
        inventory.setCategory(rs.getString("category"));
        inventory.setUnit(rs.getString("unit"));
        inventory.setUnitPrice(rs.getDouble("unit_price"));
        inventory.setImageUrl(rs.getString("image_url"));
        
        return inventory;
    }
    
    private StockHistory createStockHistoryFromResultSet(ResultSet rs) throws SQLException {
        StockHistory history = new StockHistory();
        history.setId(rs.getInt("id"));
        history.setProductId(rs.getInt("product_id"));
        history.setWarehouseLocation(rs.getString("warehouse_location"));
        history.setMovementType(rs.getString("movement_type"));
        history.setQuantity(rs.getInt("quantity"));
        history.setReferenceType(rs.getString("reference_type"));
        
        int refId = rs.getInt("reference_id");
        history.setReferenceId(rs.wasNull() ? null : refId);
        
        double unitCost = rs.getDouble("unit_cost");
        history.setUnitCost(rs.wasNull() ? null : unitCost);
        
        history.setNotes(rs.getString("notes"));
        
        int createdBy = rs.getInt("created_by");
        history.setCreatedBy(rs.wasNull() ? null : createdBy);
        
        history.setCreatedAt(rs.getTimestamp("created_at"));
        
        // JOIN fields
        history.setProductCode(rs.getString("product_code"));
        history.setProductName(rs.getString("product_name"));
        history.setCreatedByName(rs.getString("created_by_name"));
        
        return history;
    }
    
    public String getLastError() {
        return lastError;
    }
}

