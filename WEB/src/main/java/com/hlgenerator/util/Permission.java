package com.hlgenerator.util;

/**
 * Constants cho các permission keys trong hệ thống
 */
public class Permission {
    // Core Admin Permissions
    public static final String MANAGE_PERMISSIONS = "manage_permissions";
    public static final String MANAGE_USERS = "manage_users";
    public static final String MANAGE_SETTINGS = "manage_settings";
    public static final String MANAGE_EMAIL = "manage_email";
    public static final String SEND_MARKETING_EMAIL = "send_marketing_email";
    
    // Inventory Permissions
    public static final String MANAGE_INVENTORY = "manage_inventory";
    public static final String VIEW_INVENTORY = "view_inventory";
    
    // Product Permissions
    public static final String MANAGE_PRODUCTS = "manage_products";
    
    // Supplier Permissions
    public static final String MANAGE_SUPPLIERS = "manage_suppliers";
    
    // Contract Permissions
    public static final String MANAGE_CONTRACTS = "manage_contracts";
    
    // Customer Permissions
    public static final String MANAGE_CUSTOMERS = "manage_customers";
    
    // Contact Permissions
    public static final String MANAGE_CONTACTS = "manage_contacts";
    
    // Support Permissions
    public static final String MANAGE_SUPPORT_REQUESTS = "manage_support_requests";
    public static final String SUBMIT_SUPPORT_REQUEST = "submit_support_request";
    
    // Feedback Permissions
    public static final String MANAGE_FEEDBACK = "manage_feedback";
    
    // Task Permissions
    public static final String VIEW_MY_TASKS = "view_my_tasks";
    
    // Tech Support Permissions
    public static final String MANAGE_TECH_SUPPORT_REQUESTS = "manage_tech_support_requests";
    
    // Work Order Permissions
    public static final String MANAGE_WORK_ORDERS = "manage_work_orders";
    
    // Technical Staff Permissions
    public static final String MANAGE_TECHNICAL_STAFF = "manage_technical_staff";
    
    // Private constructor để ngăn instantiation
    private Permission() {
        throw new UnsupportedOperationException("Permission class cannot be instantiated");
    }
}

