package com.hlgenerator.model;

import java.sql.Timestamp;

public class Feedback {
    private int id;
    private int ticketId;
    private int customerId;
    private int rating; // 1-5 sao
    private String comment;
    private String imagePath; // Đường dẫn đến ảnh feedback
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Constructors
    public Feedback() {}
    
    public Feedback(int ticketId, int customerId, int rating, String comment) {
        this.ticketId = ticketId;
        this.customerId = customerId;
        this.rating = rating;
        this.comment = comment;
    }
    
    public Feedback(int ticketId, int customerId, int rating, String comment, String imagePath) {
        this.ticketId = ticketId;
        this.customerId = customerId;
        this.rating = rating;
        this.comment = comment;
        this.imagePath = imagePath;
    }
    
    public Feedback(int id, int ticketId, int customerId, int rating, String comment, 
                    Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.ticketId = ticketId;
        this.customerId = customerId;
        this.rating = rating;
        this.comment = comment;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    public Feedback(int id, int ticketId, int customerId, int rating, String comment, String imagePath,
                    Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.ticketId = ticketId;
        this.customerId = customerId;
        this.rating = rating;
        this.comment = comment;
        this.imagePath = imagePath;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getTicketId() {
        return ticketId;
    }
    
    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }
    
    public int getCustomerId() {
        return customerId;
    }
    
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }
    
    public int getRating() {
        return rating;
    }
    
    public void setRating(int rating) {
        this.rating = rating;
    }
    
    public String getComment() {
        return comment;
    }
    
    public void setComment(String comment) {
        this.comment = comment;
    }
    
    public String getImagePath() {
        return imagePath;
    }
    
    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
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
    
    // Helper methods
    public String getRatingDisplay() {
        switch (rating) {
            case 1:
                return "Rất không hài lòng";
            case 2:
                return "Không hài lòng";
            case 3:
                return "Bình thường";
            case 4:
                return "Hài lòng";
            case 5:
                return "Rất hài lòng";
            default:
                return "Chưa đánh giá";
        }
    }
    
    public String getRatingStars() {
        StringBuilder stars = new StringBuilder();
        for (int i = 0; i < rating; i++) {
            stars.append("★");
        }
        for (int i = rating; i < 5; i++) {
            stars.append("☆");
        }
        return stars.toString();
    }
    
    @Override
    public String toString() {
        return "Feedback{" +
                "id=" + id +
                ", ticketId=" + ticketId +
                ", customerId=" + customerId +
                ", rating=" + rating +
                ", comment='" + comment + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}

