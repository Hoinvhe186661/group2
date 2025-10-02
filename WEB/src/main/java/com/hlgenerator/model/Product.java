package com.hlgenerator.model;

public class Product {
    private int id;
    private String productCode;
    private String productName;
    private String category;
    private String unit;
    private String description;
    private double unitPrice;
    private int supplierId;
    private String specifications;
    private String imageUrl;
    private int warrantyMonths;
    private String status;

    public Product() {}

    public Product(String productCode, String productName, String category, String unit, String description, double unitPrice, int supplierId, String specifications, String imageUrl, int warrantyMonths, String status) {
        this.productCode = productCode;
        this.productName = productName;
        this.category = category;
        this.unit = unit;
        this.description = description;
        this.unitPrice = unitPrice;
        this.supplierId = supplierId;
        this.specifications = specifications;
        this.imageUrl = imageUrl;
        this.warrantyMonths = warrantyMonths;
        this.status = status;
    }

    // Getters and setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getProductCode() { return productCode; }
    public void setProductCode(String productCode) { this.productCode = productCode; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }
    public int getSupplierId() { return supplierId; }
    public void setSupplierId(int supplierId) { this.supplierId = supplierId; }
    public String getSpecifications() { return specifications; }
    public void setSpecifications(String specifications) { this.specifications = specifications; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public int getWarrantyMonths() { return warrantyMonths; }
    public void setWarrantyMonths(int warrantyMonths) { this.warrantyMonths = warrantyMonths; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
