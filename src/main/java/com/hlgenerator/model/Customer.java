package com.hlgenerator.model;

import java.sql.Timestamp;

public class Customer {
    private int id;
    private String customerCode;
    private String companyName;
    private String contactPerson;
    private String email;
    private String phone;
    private String address;
    private String taxCode;
    private String customerType; // 'individual' or 'company'
    private String status; // 'active' or 'inactive'
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Default constructor
    public Customer() {}

    // Constructor with all fields
    public Customer(int id, String customerCode, String companyName, String contactPerson, 
                   String email, String phone, String address, String taxCode, 
                   String customerType, String status, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.customerCode = customerCode;
        this.companyName = companyName;
        this.contactPerson = contactPerson;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.taxCode = taxCode;
        this.customerType = customerType;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Constructor for creating new customer (without id and timestamps)
    public Customer(String customerCode, String companyName, String contactPerson, 
                   String email, String phone, String address, String taxCode, String customerType) {
        this.customerCode = customerCode;
        this.companyName = companyName;
        this.contactPerson = contactPerson;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.taxCode = taxCode;
        this.customerType = customerType;
        this.status = "active"; // Default status
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCustomerCode() {
        return customerCode;
    }

    public void setCustomerCode(String customerCode) {
        this.customerCode = customerCode;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getContactPerson() {
        return contactPerson;
    }

    public void setContactPerson(String contactPerson) {
        this.contactPerson = contactPerson;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getTaxCode() {
        return taxCode;
    }

    public void setTaxCode(String taxCode) {
        this.taxCode = taxCode;
    }

    public String getCustomerType() {
        return customerType;
    }

    public void setCustomerType(String customerType) {
        this.customerType = customerType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "Customer{" +
                "id=" + id +
                ", customerCode='" + customerCode + '\'' +
                ", companyName='" + companyName + '\'' +
                ", contactPerson='" + contactPerson + '\'' +
                ", email='" + email + '\'' +
                ", phone='" + phone + '\'' +
                ", address='" + address + '\'' +
                ", taxCode='" + taxCode + '\'' +
                ", customerType='" + customerType + '\'' +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
