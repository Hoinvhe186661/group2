package com.hlgenerator.model;

import java.sql.Timestamp;

public class WorkOrderTaskAssignment {
    private int id;
    private int taskId;
    private int userId;
    private String role; // assignee, reviewer, etc.
    private Timestamp assignedAt;

    // Constructors
    public WorkOrderTaskAssignment() {}

    public WorkOrderTaskAssignment(int taskId, int userId, String role) {
        this.taskId = taskId;
        this.userId = userId;
        this.role = role;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getTaskId() {
        return taskId;
    }

    public void setTaskId(int taskId) {
        this.taskId = taskId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Timestamp getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(Timestamp assignedAt) {
        this.assignedAt = assignedAt;
    }
}



