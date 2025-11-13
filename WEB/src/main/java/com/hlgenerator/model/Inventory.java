package com.hlgenerator.model;

import java.sql.Timestamp;

/**
 * Model cho bảng inventory
 * Quản lý thông tin tồn kho của từng sản phẩm
 */
public class Inventory {
    private int id;
    private int productId;
    private String warehouseLocation;
    private int currentStock;
    private int minStock;
    private int maxStock;
    private Timestamp lastUpdated;
    private int reservedQuantity;
    
    // Thông tin bổ sung từ JOIN
    private String productCode;
    private String productName;
    private String category;
    private String unit;
    private double unitPrice;
    private String imageUrl;
    
    // Constructors
    public Inventory() {
    }
    
    public Inventory(int productId, String warehouseLocation, int currentStock, int minStock, int maxStock) {
        this.productId = productId;
        this.warehouseLocation = warehouseLocation;
        this.currentStock = currentStock;
        this.minStock = minStock;
        this.maxStock = maxStock;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getProductId() {
        return productId;
    }
    
    public void setProductId(int productId) {
        this.productId = productId;
    }
    
    public String getWarehouseLocation() {
        return warehouseLocation;
    }
    
    public void setWarehouseLocation(String warehouseLocation) {
        this.warehouseLocation = warehouseLocation;
    }
    
    public int getCurrentStock() {
        return currentStock;
    }
    
    public void setCurrentStock(int currentStock) {
        this.currentStock = currentStock;
    }
    
    public int getMinStock() {
        return minStock;
    }
    
    public void setMinStock(int minStock) {
        this.minStock = minStock;
    }
    
    public int getMaxStock() {
        return maxStock;
    }
    
    public void setMaxStock(int maxStock) {
        this.maxStock = maxStock;
    }
    
    public int getReservedQuantity() {
        return reservedQuantity;
    }
    
    public void setReservedQuantity(int reservedQuantity) {
        this.reservedQuantity = reservedQuantity;
    }
    
    public Timestamp getLastUpdated() {
        return lastUpdated;
    }
    
    public void setLastUpdated(Timestamp lastUpdated) {
        this.lastUpdated = lastUpdated;
    }
    
    // JOIN fields getters/setters
    public String getProductCode() {
        return productCode;
    }
    
    public void setProductCode(String productCode) {
        this.productCode = productCode;
    }
    
    public String getProductName() {
        return productName;
    }
    
    public void setProductName(String productName) {
        this.productName = productName;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public String getUnit() {
        return unit;
    }
    
    public void setUnit(String unit) {
        this.unit = unit;
    }
    
    public double getUnitPrice() {
        return unitPrice;
    }
    
    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }
    
    public String getImageUrl() {
        return imageUrl;
    }
    
    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
    
    public int getAvailableStock() {
        // Cho phép số âm để hiển thị thiếu
        return currentStock - reservedQuantity;
    }
    
    /**
     * Kiểm tra xem tồn kho có đang ở mức thấp không
     */
    public boolean isLowStock() {
        int available = getAvailableStock();
        return available > 0 && available <= minStock;
    }
    
    /**
     * Kiểm tra xem sản phẩm có hết hàng không
     */
    public boolean isOutOfStock() {
        return getAvailableStock() <= 0;
    }
    
    /**
     * Lấy trạng thái tồn kho dạng text
     */
    public String getStockStatus() {
        if (isOutOfStock()) {
            return "out_of_stock";
        } else if (isLowStock()) {
            return "low_stock";
        } else {
            return "normal";
        }
    }
    
    /**
     * Lấy mô tả trạng thái tồn kho
     */
    public String getStockStatusDescription() {
        if (isOutOfStock()) {
            return "Hết hàng";
        } else if (isLowStock()) {
            return "Sắp hết";
        } else {
            return "Bình thường";
        }
    }
}

