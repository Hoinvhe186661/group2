package com.hlgenerator.model;

import java.sql.Timestamp;

/**
 * Model cho bảng product_price_history
 * Lưu lịch sử cập nhật giá mua/bán cho sản phẩm
 */
public class PriceHistory {
    private int id;
    private int productId;
    private String priceType; // 'purchase', 'selling'
    private Double oldPrice;
    private Double newPrice;
    private String reason;
    private String referenceType;
    private Integer referenceId;
    private Integer updatedBy;
    private Timestamp updatedAt;
    
    // Thông tin bổ sung từ JOIN
    private String productCode;
    private String productName;
    private String updatedByName; // Tên người cập nhật
    
    // Constructors
    public PriceHistory() {
    }
    
    public PriceHistory(int productId, String priceType, Double newPrice) {
        this.productId = productId;
        this.priceType = priceType;
        this.newPrice = newPrice;
    }
    
    public PriceHistory(int productId, String priceType, Double oldPrice, Double newPrice, 
                       String reason, String referenceType, Integer referenceId, Integer updatedBy) {
        this.productId = productId;
        this.priceType = priceType;
        this.oldPrice = oldPrice;
        this.newPrice = newPrice;
        this.reason = reason;
        this.referenceType = referenceType;
        this.referenceId = referenceId;
        this.updatedBy = updatedBy;
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
    
    public String getPriceType() {
        return priceType;
    }
    
    public void setPriceType(String priceType) {
        this.priceType = priceType;
    }
    
    public Double getOldPrice() {
        return oldPrice;
    }
    
    public void setOldPrice(Double oldPrice) {
        this.oldPrice = oldPrice;
    }
    
    public Double getNewPrice() {
        return newPrice;
    }
    
    public void setNewPrice(Double newPrice) {
        this.newPrice = newPrice;
    }
    
    public String getReason() {
        return reason;
    }
    
    public void setReason(String reason) {
        this.reason = reason;
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
    
    public Integer getUpdatedBy() {
        return updatedBy;
    }
    
    public void setUpdatedBy(Integer updatedBy) {
        this.updatedBy = updatedBy;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
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
    
    public String getUpdatedByName() {
        return updatedByName;
    }
    
    public void setUpdatedByName(String updatedByName) {
        this.updatedByName = updatedByName;
    }
    
    /**
     * Lấy mô tả loại giá
     */
    public String getPriceTypeDescription() {
        if (priceType == null) return "";
        
        switch (priceType.toLowerCase()) {
            case "purchase":
                return "Giá mua";
            case "selling":
                return "Giá bán";
            default:
                return priceType;
        }
    }
    
    /**
     * Kiểm tra xem đây có phải là giá mua không
     */
    public boolean isPurchasePrice() {
        return "purchase".equalsIgnoreCase(priceType);
    }
    
    /**
     * Kiểm tra xem đây có phải là giá bán không
     */
    public boolean isSellingPrice() {
        return "selling".equalsIgnoreCase(priceType);
    }
    
    /**
     * Tính phần trăm thay đổi giá
     */
    public Double getPriceChangePercent() {
        if (oldPrice == null || oldPrice == 0 || newPrice == null) {
            return null;
        }
        return ((newPrice - oldPrice) / oldPrice) * 100;
    }
}

