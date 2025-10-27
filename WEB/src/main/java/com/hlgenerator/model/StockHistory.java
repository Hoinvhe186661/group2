package com.hlgenerator.model;

import java.sql.Timestamp;

/**
 * Model cho bảng stock_history
 * Lưu lịch sử xuất nhập kho
 */
public class StockHistory {
    private int id;
    private int productId;
    private String warehouseLocation;
    private String movementType; // 'in', 'out', 'adjustment'
    private int quantity;
    private String referenceType; // 'contract', 'purchase_order', 'sales', etc.
    private Integer referenceId;
    private Double unitCost;
    private String notes;
    private Integer createdBy;
    private Timestamp createdAt;
    
    // Thông tin bổ sung từ JOIN
    private String productCode;
    private String productName;
    private String createdByName; // Tên người thực hiện
    
    // Constructors
    public StockHistory() {
    }
    
    public StockHistory(int productId, String warehouseLocation, String movementType, int quantity) {
        this.productId = productId;
        this.warehouseLocation = warehouseLocation;
        this.movementType = movementType;
        this.quantity = quantity;
    }
    
    public StockHistory(int productId, String warehouseLocation, String movementType, 
                       int quantity, String referenceType, Integer referenceId, 
                       Double unitCost, String notes, Integer createdBy) {
        this.productId = productId;
        this.warehouseLocation = warehouseLocation;
        this.movementType = movementType;
        this.quantity = quantity;
        this.referenceType = referenceType;
        this.referenceId = referenceId;
        this.unitCost = unitCost;
        this.notes = notes;
        this.createdBy = createdBy;
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
    
    public String getMovementType() {
        return movementType;
    }
    
    public void setMovementType(String movementType) {
        this.movementType = movementType;
    }
    
    public int getQuantity() {
        return quantity;
    }
    
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    
    public String getReferenceType() {
        return referenceType;
    }
    
    public void setReferenceType(String referenceType) {
        this.referenceType = referenceType;
    }
    
    public Integer getReferenceId() {
        return referenceId;
    }
    
    public void setReferenceId(Integer referenceId) {
        this.referenceId = referenceId;
    }
    
    public Double getUnitCost() {
        return unitCost;
    }
    
    public void setUnitCost(Double unitCost) {
        this.unitCost = unitCost;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
    }
    
    public Integer getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    // JOIN fields
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
    
    public String getCreatedByName() {
        return createdByName;
    }
    
    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }
    
    /**
     * Lấy mô tả loại giao dịch
     */
    public String getMovementTypeDescription() {
        if (movementType == null) return "";
        
        switch (movementType.toLowerCase()) {
            case "in":
                return "Nhập kho";
            case "out":
                return "Xuất kho";
            case "adjustment":
                return "Điều chỉnh";
            default:
                return movementType;
        }
    }
    
    /**
     * Lấy mô tả loại tham chiếu
     */
    public String getReferenceTypeDescription() {
        if (referenceType == null) return "";
        
        switch (referenceType.toLowerCase()) {
            case "contract":
                return "Hợp đồng";
            case "purchase_order":
                return "Đơn đặt hàng";
            case "sales":
                return "Bán hàng";
            case "return":
                return "Trả hàng";
            case "warranty":
                return "Bảo hành";
            case "damaged":
                return "Hư hỏng";
            case "adjustment":
                return "Điều chỉnh";
            default:
                return referenceType;
        }
    }
    
    /**
     * Kiểm tra xem đây có phải là giao dịch nhập kho không
     */
    public boolean isStockIn() {
        return "in".equalsIgnoreCase(movementType);
    }
    
    /**
     * Kiểm tra xem đây có phải là giao dịch xuất kho không
     */
    public boolean isStockOut() {
        return "out".equalsIgnoreCase(movementType);
    }
}

