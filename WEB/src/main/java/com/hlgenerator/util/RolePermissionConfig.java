package com.hlgenerator.util;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * Provides the mapping between built-in roles and their default permission sets.
 * Custom user permissions (stored per user) will extend or override these defaults.
 */
public final class RolePermissionConfig {
    private static final Map<String, Set<String>> ROLE_PERMISSIONS;

    static {
        Map<String, Set<String>> map = new HashMap<>();

        // ADMIN: Dashboard, Quản lý người dùng, Setting, Quản lý email
        map.put("admin", Permission.set(
            Permission.VIEW_DASHBOARD,
            Permission.MANAGE_USERS,
            Permission.MANAGE_SETTINGS,
            Permission.MANAGE_EMAIL
        ));

        // Hỗ Trợ Khách Hàng: Dashboard, Quản lý yêu cầu hỗ trợ, Quản lý feedback, 
        // Quản lý Hợp đồng, Quản lý liên hệ, Quản lý khách hàng
        map.put("customer_support", Permission.set(
            Permission.VIEW_DASHBOARD,
            Permission.MANAGE_SUPPORT,
            Permission.VIEW_SUPPORT,
            Permission.MANAGE_FEEDBACK,
            Permission.MANAGE_CONTRACTS,
            Permission.MANAGE_CONTACTS,
            Permission.MANAGE_CUSTOMERS
        ));

        // Trưởng phòng: Dashboard, Yêu cầu hỗ trợ kỹ thuật, Đơn hàng công việc, Quản lý nhân viên kỹ thuật
        map.put("head_technician", Permission.set(
            Permission.VIEW_DASHBOARD,
            Permission.MANAGE_TECH_SUPPORT,
            Permission.MANAGE_WORK_ORDERS,
            Permission.MANAGE_TASKS,
            Permission.VIEW_TASKS
        ));

        // Nhân viên kỹ thuật: Chỉ có quyền xem công việc
        map.put("technical_staff", Permission.set(
            Permission.VIEW_TASKS
        ));

        // Quản lý kho: Quản lý sản phẩm, Nhà cung cấp, Quản lý kho
        map.put("storekeeper", Permission.set(
            Permission.MANAGE_PRODUCTS,
            Permission.VIEW_PRODUCTS,
            Permission.MANAGE_SUPPLIERS,
            Permission.VIEW_SUPPLIERS,
            Permission.MANAGE_INVENTORY,
            Permission.VIEW_INVENTORY
        ));

        map.put("customer", Permission.set(
            Permission.VIEW_CUSTOMER_PROFILE,
            Permission.VIEW_SUPPORT,
            Permission.VIEW_TASKS
        ));

        map.put("guest", Collections.emptySet());

        ROLE_PERMISSIONS = Collections.unmodifiableMap(map);
    }

    private RolePermissionConfig() {
    }

    public static Set<String> getDefaultPermissions(String role) {
        if (role == null) {
            return Collections.emptySet();
        }
        return ROLE_PERMISSIONS.getOrDefault(role, Collections.emptySet());
    }
}

