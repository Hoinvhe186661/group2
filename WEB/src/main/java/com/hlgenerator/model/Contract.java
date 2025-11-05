package com.hlgenerator.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class Contract {
    private int id;
    private String contractNumber;
    private int customerId;
    private String contractType;
    private String title;
    private Date startDate;
    private Date endDate;
    private BigDecimal contractValue;
    private String status; // draft, active, completed, terminated, expired
    private String terms;
    private Date signedDate;
    private Integer createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String deletedByName; // Tạm thời để lưu tên người xóa
    private String customerName; // Tên khách hàng
    private String customerPhone; // Số điện thoại khách hàng

    public Contract() {
    }

    public Contract(
            int id,
            String contractNumber,
            int customerId,
            String contractType,
            String title,
            Date startDate,
            Date endDate,
            BigDecimal contractValue,
            String status,
            String terms,
            Date signedDate,
            Integer createdBy,
            Timestamp createdAt,
            Timestamp updatedAt) {
        this.id = id;
        this.contractNumber = contractNumber;
        this.customerId = customerId;
        this.contractType = contractType;
        this.title = title;
        this.startDate = startDate;
        this.endDate = endDate;
        this.contractValue = contractValue;
        this.status = status;
        this.terms = terms;
        this.signedDate = signedDate;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Contract(
            String contractNumber,
            int customerId,
            String contractType,
            String title,
            Date startDate,
            Date endDate,
            BigDecimal contractValue,
            String status,
            String terms,
            Date signedDate,
            Integer createdBy) {
        this.contractNumber = contractNumber;
        this.customerId = customerId;
        this.contractType = contractType;
        this.title = title;
        this.startDate = startDate;
        this.endDate = endDate;
        this.contractValue = contractValue;
        this.status = status;
        this.terms = terms;
        this.signedDate = signedDate;
        this.createdBy = createdBy;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getContractNumber() {
        return contractNumber;
    }

    public void setContractNumber(String contractNumber) {
        this.contractNumber = contractNumber;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getContractType() {
        return contractType;
    }

    public void setContractType(String contractType) {
        this.contractType = contractType;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public BigDecimal getContractValue() {
        return contractValue;
    }

    public void setContractValue(BigDecimal contractValue) {
        this.contractValue = contractValue;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getTerms() {
        return terms;
    }

    public void setTerms(String terms) {
        this.terms = terms;
    }

    public Date getSignedDate() {
        return signedDate;
    }

    public void setSignedDate(Date signedDate) {
        this.signedDate = signedDate;
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

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getDeletedByName() {
        return deletedByName;
    }

    public void setDeletedByName(String deletedByName) {
        this.deletedByName = deletedByName;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }
}
