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
     * Lấy đơn giá nhập gần nhất (unit_cost) của sản phẩm từ lịch sử nhập kho
     */
    public Double getLastUnitCost(int productId) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return null;
        }
        String sql = "SELECT unit_cost FROM stock_history WHERE product_id = ? AND movement_type = 'in' " +
                     "AND unit_cost IS NOT NULL ORDER BY created_at DESC LIMIT 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double v = rs.getDouble(1);
                    if (rs.wasNull()) return null;
                    return v;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy giá nhập gần nhất: " + e.getMessage();
        }
        return null;
    }

    /**
     * Tổng tồn tất cả kho của một sản phẩm
     */
    public Integer getTotalStock(int productId) {
        if (connection == null) { lastError = "Không thể kết nối đến cơ sở dữ liệu"; return 0; }
        String sql = "SELECT COALESCE(SUM(current_stock),0) FROM inventory WHERE product_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        } catch (SQLException e) { e.printStackTrace(); lastError = "Lỗi khi lấy tổng tồn: " + e.getMessage(); }
        return 0;
    }

    public Integer getReservedStock(int productId) {
        if (connection == null) { lastError = "Không thể kết nối đến cơ sở dữ liệu"; return 0; }
        String sql = "SELECT COALESCE(SUM(reserved_quantity),0) FROM inventory WHERE product_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        } catch (SQLException e) { e.printStackTrace(); lastError = "Lỗi khi lấy số lượng giữ chỗ: " + e.getMessage(); }
        return 0;
    }

    public Integer getAvailableStock(int productId) {
        if (connection == null) { lastError = "Không thể kết nối đến cơ sở dữ liệu"; return 0; }
        // Cho phép số âm để hiển thị thiếu (không dùng GREATEST)
        String sql = "SELECT COALESCE(SUM(current_stock - reserved_quantity),0) FROM inventory WHERE product_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        } catch (SQLException e) { e.printStackTrace(); lastError = "Lỗi khi lấy tồn kho khả dụng: " + e.getMessage(); }
        return 0;
    }

    /**
     * Tồn theo từng vị trí kho của sản phẩm
     */
    public List<Map<String, Object>> getWarehouseStocks(int productId) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (connection == null) return list;
        String sql = "SELECT warehouse_location, current_stock, reserved_quantity FROM inventory WHERE product_id = ? ORDER BY warehouse_location";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("warehouse", rs.getString("warehouse_location"));
                    int stock = rs.getInt("current_stock");
                    int reserved = rs.getInt("reserved_quantity");
                    int available = stock - reserved;
                    // Cho phép available âm để hiển thị thiếu
                    m.put("stock", stock);
                    m.put("reserved", reserved);
                    m.put("available", available);
                    list.add(m);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Số lượng đã bán (tổng xuất kho)
     */
    public Integer getQuantitySold(int productId) {
        if (connection == null) { lastError = "Không thể kết nối đến cơ sở dữ liệu"; return 0; }
        String sql = "SELECT COALESCE(SUM(quantity),0) FROM stock_history WHERE product_id = ? AND movement_type = 'out'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        } catch (SQLException e) { e.printStackTrace(); lastError = "Lỗi khi lấy số lượng đã bán: " + e.getMessage(); }
        return 0;
    }

    /**
     * Lấy product_id từ inventory.id (fallback khi client gửi nhầm inventory id)
     */
    public Integer getProductIdByInventoryId(int inventoryId) {
        if (connection == null) { lastError = "Không thể kết nối đến cơ sở dữ liệu"; return null; }
        String sql = "SELECT product_id FROM inventory WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, inventoryId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        } catch (SQLException e) { e.printStackTrace(); lastError = "Lỗi khi lấy product_id: " + e.getMessage(); }
        return null;
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
            String updateSql = "UPDATE inventory SET current_stock = current_stock + ?, last_updated = CURRENT_TIMESTAMP " +
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
        
        String sql = "UPDATE inventory SET current_stock = current_stock - ?, last_updated = CURRENT_TIMESTAMP " +
                     "WHERE product_id = ? AND warehouse_location = ? AND (current_stock - reserved_quantity) >= ?";
        
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
    
    public boolean increaseReservedStock(int productId, int quantity) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }
        if (quantity <= 0) {
            return true;
        }
        
        String sql = "SELECT id, current_stock, reserved_quantity FROM inventory WHERE product_id = ? ORDER BY (current_stock - reserved_quantity) DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                List<int[]> rows = new ArrayList<int[]>();
                while (rs.next()) {
                    rows.add(new int[] { rs.getInt("id"), rs.getInt("current_stock"), rs.getInt("reserved_quantity") });
                }
                int remaining = quantity;
                for (int[] row : rows) {
                    int available = row[1] - row[2];
                    if (available <= 0) {
                        continue;
                    }
                    int toReserve = Math.min(available, remaining);
                    if (toReserve <= 0) {
                        continue;
                    }
                    if (!adjustReservedQuantity(row[0], toReserve)) {
                        return false;
                    }
                    remaining -= toReserve;
                    if (remaining <= 0) {
                        break;
                    }
                }
                if (remaining > 0) {
                    lastError = "Không đủ tồn kho khả dụng để giữ chỗ";
                    return false;
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi cập nhật số lượng giữ chỗ: " + e.getMessage();
            return false;
        }
    }
    
    public boolean releaseReservedStock(int productId, String warehouseLocation, int quantity) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return false;
        }
        if (quantity <= 0) {
            return true;
        }
        int remaining = quantity;
        if (warehouseLocation != null && !warehouseLocation.trim().isEmpty()) {
            String targetSql = "SELECT id, reserved_quantity FROM inventory WHERE product_id = ? AND warehouse_location = ?";
            try (PreparedStatement ps = connection.prepareStatement(targetSql)) {
                ps.setInt(1, productId);
                ps.setString(2, warehouseLocation);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int id = rs.getInt("id");
                        int reserved = rs.getInt("reserved_quantity");
                        int toRelease = Math.min(reserved, remaining);
                        if (toRelease > 0) {
                            if (!adjustReservedQuantity(id, -toRelease)) {
                                return false;
                            }
                            remaining -= toRelease;
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
                lastError = "Lỗi khi giải phóng số lượng giữ chỗ: " + e.getMessage();
                return false;
            }
        }
        if (remaining <= 0) {
            return true;
        }
        String sql = "SELECT id, reserved_quantity FROM inventory WHERE product_id = ? AND reserved_quantity > 0 ORDER BY reserved_quantity DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next() && remaining > 0) {
                    int id = rs.getInt("id");
                    int reserved = rs.getInt("reserved_quantity");
                    if (reserved <= 0) {
                        continue;
                    }
                    int toRelease = Math.min(reserved, remaining);
                    if (!adjustReservedQuantity(id, -toRelease)) {
                        return false;
                    }
                    remaining -= toRelease;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi giải phóng số lượng giữ chỗ: " + e.getMessage();
            return false;
        }
        return remaining <= 0;
    }
    
    public boolean releaseReservedStock(int productId, int quantity) {
        return releaseReservedStock(productId, null, quantity);
    }
    
    private boolean adjustReservedQuantity(int inventoryId, int delta) {
        String sql = "UPDATE inventory SET reserved_quantity = reserved_quantity + ?, last_updated = CURRENT_TIMESTAMP " +
                     "WHERE id = ? AND reserved_quantity + ? >= 0";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, delta);
            ps.setInt(2, inventoryId);
            ps.setInt(3, delta);
            int updated = ps.executeUpdate();
            if (updated <= 0) {
                lastError = "Không thể cập nhật số lượng giữ chỗ (delta=" + delta + ")";
                return false;
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi điều chỉnh số lượng giữ chỗ: " + e.getMessage();
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
     * Lấy lịch sử có lọc và phân trang từ backend
     */
    public List<StockHistory> getFilteredStockHistory(Integer productId, String movementType,
                                                      String warehouse, String search,
                                                      int page, int pageSize) {
        return getFilteredStockHistory(productId, movementType, warehouse, search, null, null, page, pageSize);
    }
    
    /**
     * Lấy lịch sử có lọc và phân trang từ backend (với lọc theo ngày)
     */
    public List<StockHistory> getFilteredStockHistory(Integer productId, String movementType,
                                                      String warehouse, String search,
                                                      String dateFrom, String dateTo,
                                                      int page, int pageSize) {
        List<StockHistory> historyList = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return historyList;
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT sh.*, p.product_code, p.product_name, u.full_name as created_by_name ");
        sql.append("FROM stock_history sh ");
        sql.append("INNER JOIN products p ON sh.product_id = p.id ");
        sql.append("LEFT JOIN users u ON sh.created_by = u.id WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        if (productId != null) { sql.append("AND sh.product_id = ? "); params.add(productId); }
        if (movementType != null && !movementType.trim().isEmpty()) { sql.append("AND sh.movement_type = ? "); params.add(movementType.trim()); }
        if (warehouse != null && !warehouse.trim().isEmpty()) { sql.append("AND sh.warehouse_location = ? "); params.add(warehouse.trim()); }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (p.product_name LIKE ? OR p.product_code LIKE ? OR COALESCE(sh.notes,'') LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sql.append("AND DATE(sh.created_at) >= ? ");
            params.add(dateFrom);
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sql.append("AND DATE(sh.created_at) <= ? ");
            params.add(dateTo);
        }

        sql.append("ORDER BY sh.created_at DESC LIMIT ? OFFSET ?");

        int offset = (page - 1) * pageSize;
        params.add(pageSize);
        params.add(offset);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) { ps.setObject(i + 1, params.get(i)); }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) { historyList.add(createStockHistoryFromResultSet(rs)); }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy lịch sử: " + e.getMessage();
        }
        return historyList;
    }

    /**
     * Đếm tổng số lịch sử theo bộ lọc (phục vụ phân trang)
     */
    public int getFilteredStockHistoryCount(Integer productId, String movementType,
                                            String warehouse, String search) {
        return getFilteredStockHistoryCount(productId, movementType, warehouse, search, null, null);
    }
    
    /**
     * Đếm tổng số lịch sử theo bộ lọc (phục vụ phân trang, với lọc theo ngày)
     */
    public int getFilteredStockHistoryCount(Integer productId, String movementType,
                                            String warehouse, String search,
                                            String dateFrom, String dateTo) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return 0;
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM stock_history sh INNER JOIN products p ON sh.product_id = p.id WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (productId != null) { sql.append("AND sh.product_id = ? "); params.add(productId); }
        if (movementType != null && !movementType.trim().isEmpty()) { sql.append("AND sh.movement_type = ? "); params.add(movementType.trim()); }
        if (warehouse != null && !warehouse.trim().isEmpty()) { sql.append("AND sh.warehouse_location = ? "); params.add(warehouse.trim()); }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (p.product_name LIKE ? OR p.product_code LIKE ? OR COALESCE(sh.notes,'') LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sql.append("AND DATE(sh.created_at) >= ? ");
            params.add(dateFrom);
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sql.append("AND DATE(sh.created_at) <= ? ");
            params.add(dateTo);
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) { ps.setObject(i + 1, params.get(i)); }
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) { return rs.getInt(1); } }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi đếm lịch sử: " + e.getMessage();
        }
        return 0;
    }
    
    /**
     * Lấy lịch sử tồn kho với tồn kho trước/sau mỗi giao dịch
     * Tính tồn kho từ đầu (0) cho tất cả giao dịch theo thứ tự thời gian
     */
    public List<Map<String, Object>> getStockBalanceHistory(Integer productId, String warehouse, 
                                                             String search, String dateFrom, String dateTo,
                                                             int page, int pageSize) {
        List<Map<String, Object>> resultList = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return resultList;
        }

        // Lấy tất cả lịch sử (không lọc ngày) để tính tồn kho từ đầu
        // Sau đó sẽ lọc theo ngày khi hiển thị
        StringBuilder allHistorySql = new StringBuilder();
        allHistorySql.append("SELECT sh.*, p.product_code, p.product_name, u.full_name as created_by_name ");
        allHistorySql.append("FROM stock_history sh ");
        allHistorySql.append("INNER JOIN products p ON sh.product_id = p.id ");
        allHistorySql.append("LEFT JOIN users u ON sh.created_by = u.id WHERE 1=1 ");

        List<Object> allParams = new ArrayList<>();
        if (productId != null) { allHistorySql.append("AND sh.product_id = ? "); allParams.add(productId); }
        if (warehouse != null && !warehouse.trim().isEmpty()) { allHistorySql.append("AND sh.warehouse_location = ? "); allParams.add(warehouse.trim()); }
        if (search != null && !search.trim().isEmpty()) {
            allHistorySql.append("AND (p.product_name LIKE ? OR p.product_code LIKE ? OR COALESCE(sh.notes,'') LIKE ?) ");
            String like = "%" + search.trim() + "%";
            allParams.add(like); allParams.add(like); allParams.add(like);
        }
        allHistorySql.append("ORDER BY sh.product_id, sh.warehouse_location, sh.created_at ASC");

        // Map để lưu tồn kho hiện tại theo (productId, warehouse) - bắt đầu từ 0
        Map<String, Integer> currentStockMap = new HashMap<>();
        List<Map<String, Object>> allHistory = new ArrayList<>();

        try (PreparedStatement ps = connection.prepareStatement(allHistorySql.toString())) {
            for (int i = 0; i < allParams.size(); i++) { ps.setObject(i + 1, allParams.get(i)); }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int pId = rs.getInt("product_id");
                    String wh = rs.getString("warehouse_location");
                    String key = pId + "_" + wh;
                    
                    // Lấy tồn kho trước giao dịch (bắt đầu từ 0)
                    int stockBeforeRaw = currentStockMap.getOrDefault(key, 0);
                    int stockBeforeDisplay = Math.max(stockBeforeRaw, 0);
                    
                    // Tính tồn kho sau giao dịch
                    String movementType = rs.getString("movement_type");
                    int quantity = rs.getInt("quantity");
                    int stockAfterRaw = stockBeforeRaw;
                    if ("in".equals(movementType)) {
                        stockAfterRaw = stockBeforeRaw + quantity;
                    } else if ("out".equals(movementType)) {
                        stockAfterRaw = stockBeforeRaw - quantity;
                    } else if ("adjustment".equals(movementType)) {
                        stockAfterRaw = stockBeforeRaw + quantity; // adjustment có thể âm hoặc dương
                    }
                    if (stockAfterRaw < 0) {
                        stockAfterRaw = 0;
                    }
                    int stockAfterDisplay = Math.max(stockAfterRaw, 0);
                    
                    // Cập nhật tồn kho hiện tại
                    currentStockMap.put(key, stockAfterRaw);
                    
                    // Tạo map cho kết quả
                    Map<String, Object> item = new HashMap<>();
                    item.put("id", rs.getInt("id"));
                    item.put("productId", pId);
                    item.put("productCode", rs.getString("product_code"));
                    item.put("productName", rs.getString("product_name"));
                    item.put("warehouseLocation", wh);
                    item.put("movementType", movementType);
                    item.put("quantity", quantity);
                    item.put("stockBefore", stockBeforeDisplay);
                    item.put("stockAfter", stockAfterDisplay);
                    item.put("createdAt", rs.getTimestamp("created_at"));
                    item.put("createdByName", rs.getString("created_by_name"));
                    
                    // Snapshot tồn kho hiện tại (real-time)
                    try {
                        Inventory currentInv = getInventoryByProductAndWarehouse(pId, wh);
                        if (currentInv != null) {
                            item.put("currentStock", currentInv.getCurrentStock());
                            item.put("reservedStock", currentInv.getReservedQuantity());
                            item.put("availableStock", currentInv.getAvailableStock());
                        } else {
                            item.put("currentStock", 0);
                            item.put("reservedStock", 0);
                            item.put("availableStock", 0);
                        }
                    } catch (Exception ex) {
                        item.put("currentStock", 0);
                        item.put("reservedStock", 0);
                        item.put("availableStock", 0);
                    }
                    
                    allHistory.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy lịch sử tồn kho: " + e.getMessage();
            return resultList;
        }
        
        // Lọc theo ngày nếu có
        if ((dateFrom != null && !dateFrom.trim().isEmpty()) || (dateTo != null && !dateTo.trim().isEmpty())) {
            java.util.Iterator<Map<String, Object>> it = allHistory.iterator();
            while (it.hasNext()) {
                Map<String, Object> item = it.next();
                Timestamp createdAt = (Timestamp) item.get("createdAt");
                if (createdAt == null) {
                    it.remove();
                    continue;
                }
                java.sql.Date itemDate = new java.sql.Date(createdAt.getTime());
                
                if (dateFrom != null && !dateFrom.trim().isEmpty()) {
                    java.sql.Date fromDate = java.sql.Date.valueOf(dateFrom);
                    if (itemDate.before(fromDate)) {
                        it.remove();
                        continue;
                    }
                }
                if (dateTo != null && !dateTo.trim().isEmpty()) {
                    java.sql.Date toDate = java.sql.Date.valueOf(dateTo);
                    if (itemDate.after(toDate)) {
                        it.remove();
                        continue;
                    }
                }
            }
        }
        
        // Sắp xếp lại theo thời gian giảm dần
        allHistory.sort((a, b) -> {
            Timestamp t1 = (Timestamp) a.get("createdAt");
            Timestamp t2 = (Timestamp) b.get("createdAt");
            if (t1 == null && t2 == null) return 0;
            if (t1 == null) return 1;
            if (t2 == null) return -1;
            return t2.compareTo(t1); // Giảm dần
        });
        
        // Phân trang
        int start = (page - 1) * pageSize;
        int end = Math.min(start + pageSize, allHistory.size());
        if (start < allHistory.size()) {
            return allHistory.subList(start, end);
        }
        return new ArrayList<>();
    }
    
    /**
     * Đếm tổng số lịch sử tồn kho theo bộ lọc
     */
    public int getStockBalanceHistoryCount(Integer productId, String warehouse, 
                                           String search, String dateFrom, String dateTo) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return 0;
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM stock_history sh INNER JOIN products p ON sh.product_id = p.id WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (productId != null) { sql.append("AND sh.product_id = ? "); params.add(productId); }
        if (warehouse != null && !warehouse.trim().isEmpty()) { sql.append("AND sh.warehouse_location = ? "); params.add(warehouse.trim()); }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (p.product_name LIKE ? OR p.product_code LIKE ? OR COALESCE(sh.notes,'') LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sql.append("AND DATE(sh.created_at) >= ? ");
            params.add(dateFrom);
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sql.append("AND DATE(sh.created_at) <= ? ");
            params.add(dateTo);
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) { ps.setObject(i + 1, params.get(i)); }
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) { return rs.getInt(1); } }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi đếm lịch sử tồn kho: " + e.getMessage();
        }
        return 0;
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
     * Lấy danh sách sản phẩm với tổng tồn kho (gộp tất cả các kho)
     */
    public List<Map<String, Object>> getProductsWithStock(String category, String search, 
                                                           String stockStatus, int page, int pageSize) {
        List<Map<String, Object>> result = new ArrayList<>();
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return result;
        }
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ");
        sql.append("p.id as product_id, ");
        sql.append("p.product_code, ");
        sql.append("p.product_name, ");
        sql.append("p.category, ");
        sql.append("p.unit, ");
        sql.append("p.unit_price, ");
        sql.append("p.image_url, ");
        sql.append("COALESCE(SUM(i.current_stock), 0) as total_stock, ");
        sql.append("COALESCE(SUM(i.reserved_quantity), 0) as reserved_stock, ");
        sql.append("COALESCE(SUM(GREATEST(i.current_stock - i.reserved_quantity, 0)), 0) as available_stock, ");
        sql.append("(SELECT COALESCE(SUM(cp.quantity), 0) FROM contract_products cp ");
        sql.append(" WHERE cp.product_id = p.id AND (cp.delivery_status IS NULL OR cp.delivery_status != 'delivered')) as total_required, ");
        sql.append("MIN(i.min_stock) as min_stock, ");
        sql.append("MAX(i.max_stock) as max_stock ");
        sql.append("FROM products p ");
        sql.append("LEFT JOIN inventory i ON p.id = i.product_id ");
        sql.append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        // Lọc theo danh mục
        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND p.category = ? ");
            params.add(category);
        }
        
        // Tìm kiếm theo tên hoặc mã sản phẩm
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (p.product_name LIKE ? OR p.product_code LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        sql.append("GROUP BY p.id, p.product_code, p.product_name, p.category, p.unit, p.unit_price, p.image_url ");
        
        // Lọc theo trạng thái tồn kho (sau khi GROUP BY)
        if (stockStatus != null && !stockStatus.trim().isEmpty()) {
            switch (stockStatus) {
                case "out":
                    sql.append("HAVING COALESCE(available_stock, 0) <= 0 ");
                    break;
                case "low":
                    sql.append("HAVING COALESCE(available_stock, 0) > 0 AND COALESCE(available_stock, 0) <= COALESCE(min_stock, 0) ");
                    break;
                case "normal":
                    sql.append("HAVING COALESCE(available_stock, 0) > COALESCE(min_stock, 0) ");
                    break;
            }
        }
        
        sql.append("ORDER BY MAX(i.last_updated) IS NULL, MAX(i.last_updated) DESC, p.product_name ASC ");
        
        // Phân trang
        int offset = (page - 1) * pageSize;
        sql.append("LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(offset);
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> product = new HashMap<>();
                    product.put("productId", rs.getInt("product_id"));
                    product.put("productCode", rs.getString("product_code"));
                    product.put("productName", rs.getString("product_name"));
                    product.put("category", rs.getString("category"));
                    product.put("unit", rs.getString("unit"));
                    product.put("unitPrice", rs.getDouble("unit_price"));
                    product.put("imageUrl", rs.getString("image_url"));
                    int totalStock = rs.getInt("total_stock");
                    int reservedStockRaw = rs.getInt("reserved_stock");
                    // Giữ chỗ thực tế = min(reservedStock, totalStock) - chỉ tính phần có trong kho
                    int reservedStock = Math.min(reservedStockRaw, totalStock);
                    product.put("totalStock", totalStock);
                    product.put("reservedStock", reservedStock);
                    product.put("availableStock", rs.getInt("available_stock"));
                    int totalRequired = rs.getInt("total_required");
                    product.put("totalRequired", totalRequired);
                    // Tính số lượng thiếu: totalRequired - totalStock (có thể âm)
                    int shortage = totalRequired - totalStock;
                    product.put("shortage", shortage);
                    product.put("minStock", rs.getInt("min_stock"));
                    int maxStock = rs.getInt("max_stock");
                    product.put("maxStock", rs.wasNull() ? null : maxStock);
                    result.add(product);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            lastError = "Lỗi khi lấy danh sách sản phẩm với tồn kho: " + e.getMessage();
        }
        
        return result;
    }
    
    /**
     * Đếm số lượng sản phẩm có tồn kho (với bộ lọc)
     */
    public int getProductsWithStockCount(String category, String search, String stockStatus) {
        if (connection == null) {
            lastError = "Không thể kết nối đến cơ sở dữ liệu";
            return 0;
        }
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(DISTINCT p.id) ");
        sql.append("FROM products p ");
        sql.append("LEFT JOIN inventory i ON p.id = i.product_id ");
        sql.append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND p.category = ? ");
            params.add(category);
        }
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (p.product_name LIKE ? OR p.product_code LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        sql.append("GROUP BY p.id ");
        
        if (stockStatus != null && !stockStatus.trim().isEmpty()) {
            switch (stockStatus) {
                case "out":
                    sql.append("HAVING COALESCE(SUM(GREATEST(i.current_stock - i.reserved_quantity, 0)), 0) <= 0 ");
                    break;
                case "low":
                    sql.append("HAVING COALESCE(SUM(GREATEST(i.current_stock - i.reserved_quantity, 0)), 0) > 0 ");
                    sql.append("AND COALESCE(SUM(GREATEST(i.current_stock - i.reserved_quantity, 0)), 0) <= COALESCE(MIN(i.min_stock), 0) ");
                    break;
                case "normal":
                    sql.append("HAVING COALESCE(SUM(GREATEST(i.current_stock - i.reserved_quantity, 0)), 0) > COALESCE(MIN(i.min_stock), 0) ");
                    break;
            }
        }
        
        // Đếm số lượng sản phẩm sau khi GROUP BY
        String countSql = "SELECT COUNT(*) FROM (" + sql.toString() + ") as subquery";
        
        try (PreparedStatement ps = connection.prepareStatement(countSql)) {
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
            lastError = "Lỗi khi đếm sản phẩm với tồn kho: " + e.getMessage();
        }
        
        return 0;
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
        try {
            inventory.setReservedQuantity(rs.getInt("reserved_quantity"));
        } catch (SQLException ignore) {
            inventory.setReservedQuantity(0);
        }
        
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

