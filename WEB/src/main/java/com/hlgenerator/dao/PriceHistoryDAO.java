package com.hlgenerator.dao;

import com.hlgenerator.model.PriceHistory;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PriceHistoryDAO {
    private Connection connection;
    private String lastError;

    public PriceHistoryDAO() {
        DBConnect dbConnect = new DBConnect();
        this.connection = dbConnect.connection;
    }

    public boolean insert(PriceHistory h) {
        if (connection == null) { lastError = "Không thể kết nối đến cơ sở dữ liệu"; return false; }
        String sql = "INSERT INTO product_price_history (product_id, price_type, old_price, new_price, reason, reference_type, reference_id, updated_by) VALUES (?,?,?,?,?,?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, h.getProductId());
            ps.setString(2, h.getPriceType());
            if (h.getOldPrice() != null) ps.setDouble(3, h.getOldPrice()); else ps.setNull(3, Types.DECIMAL);
            if (h.getNewPrice() != null) ps.setDouble(4, h.getNewPrice()); else ps.setNull(4, Types.DECIMAL);
            ps.setString(5, h.getReason());
            ps.setString(6, h.getReferenceType());
            if (h.getReferenceId() != null) ps.setInt(7, h.getReferenceId()); else ps.setNull(7, Types.INTEGER);
            if (h.getUpdatedBy() != null) ps.setInt(8, h.getUpdatedBy()); else ps.setNull(8, Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); lastError = e.getMessage(); return false; }
    }

    public List<PriceHistory> getRecentByProduct(int productId, String priceType, int limit) {
        List<PriceHistory> list = new ArrayList<>();
        if (connection == null) return list;
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ph.*, p.product_code, p.product_name, u.full_name AS updated_by_name ");
        sql.append("FROM product_price_history ph ");
        sql.append("INNER JOIN products p ON ph.product_id = p.id ");
        sql.append("LEFT JOIN users u ON ph.updated_by = u.id ");
        sql.append("WHERE ph.product_id = ? ");
        if (priceType != null && !priceType.trim().isEmpty()) { sql.append("AND ph.price_type = ? "); }
        sql.append("ORDER BY ph.updated_at DESC ");
        if (limit > 0) { sql.append("LIMIT ?"); }
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, productId);
            if (priceType != null && !priceType.trim().isEmpty()) { ps.setString(idx++, priceType); }
            if (limit > 0) { ps.setInt(idx, limit); }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) { list.add(map(rs)); }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<PriceHistory> getFilteredPriceHistory(Integer productId, String priceType, String search,
                                                      int page, int pageSize) {
        List<PriceHistory> list = new ArrayList<>();
        if (connection == null) return list;
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ph.*, p.product_code, p.product_name, u.full_name AS updated_by_name ");
        sql.append("FROM product_price_history ph ");
        sql.append("INNER JOIN products p ON ph.product_id = p.id ");
        sql.append("LEFT JOIN users u ON ph.updated_by = u.id WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (productId != null) { sql.append("AND ph.product_id = ? "); params.add(productId); }
        if (priceType != null && !priceType.trim().isEmpty()) { sql.append("AND ph.price_type = ? "); params.add(priceType.trim()); }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(p.product_name) LIKE ? OR LOWER(p.product_code) LIKE ? OR LOWER(COALESCE(ph.reason,'')) LIKE ?) ");
            String like = "%" + search.trim().toLowerCase() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        sql.append("ORDER BY ph.updated_at DESC LIMIT ? OFFSET ?");
        int offset = (page - 1) * pageSize;
        params.add(pageSize); params.add(offset);
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) { ps.setObject(i + 1, params.get(i)); }
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) list.add(map(rs)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public int getFilteredPriceHistoryCount(Integer productId, String priceType, String search) {
        if (connection == null) return 0;
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM product_price_history ph INNER JOIN products p ON ph.product_id = p.id WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (productId != null) { sql.append("AND ph.product_id = ? "); params.add(productId); }
        if (priceType != null && !priceType.trim().isEmpty()) { sql.append("AND ph.price_type = ? "); params.add(priceType.trim()); }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(p.product_name) LIKE ? OR LOWER(p.product_code) LIKE ? OR LOWER(COALESCE(ph.reason,'')) LIKE ?) ");
            String like = "%" + search.trim().toLowerCase() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) { ps.setObject(i + 1, params.get(i)); }
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int countUpdates(int productId, String priceType, Integer days) {
        if (connection == null) return 0;
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM product_price_history WHERE product_id = ?");
        List<Object> params = new ArrayList<>();
        params.add(productId);
        if (priceType != null && !priceType.trim().isEmpty()) { sql.append(" AND price_type = ?"); params.add(priceType); }
        if (days != null && days > 0) { sql.append(" AND updated_at >= (NOW() - INTERVAL ? DAY)"); params.add(days); }
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) { ps.setObject(i + 1, params.get(i)); }
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public Double getLatestPrice(int productId, String priceType) {
        if (connection == null) return null;
        String sql = "SELECT new_price FROM product_price_history WHERE product_id = ? AND price_type = ? ORDER BY updated_at DESC LIMIT 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId); ps.setString(2, priceType);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) { double v = rs.getDouble(1); return rs.wasNull() ? null : v; } }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    private PriceHistory map(ResultSet rs) throws SQLException {
        PriceHistory h = new PriceHistory();
        h.setId(rs.getInt("id"));
        h.setProductId(rs.getInt("product_id"));
        h.setPriceType(rs.getString("price_type"));
        double op = rs.getDouble("old_price"); h.setOldPrice(rs.wasNull()? null : op);
        double np = rs.getDouble("new_price"); h.setNewPrice(rs.wasNull()? null : np);
        h.setReason(rs.getString("reason"));
        h.setReferenceType(rs.getString("reference_type"));
        int rid = rs.getInt("reference_id"); h.setReferenceId(rs.wasNull()? null : rid);
        int ub = rs.getInt("updated_by"); h.setUpdatedBy(rs.wasNull()? null : ub);
        h.setUpdatedAt(rs.getTimestamp("updated_at"));
        h.setProductCode(rs.getString("product_code"));
        h.setProductName(rs.getString("product_name"));
        h.setUpdatedByName(rs.getString("updated_by_name"));
        return h;
    }

    public String getLastError() { return lastError; }
}


