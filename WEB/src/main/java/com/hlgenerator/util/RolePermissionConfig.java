package com.hlgenerator.util;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
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

        map.put("admin", collectAllPermissions());

        map.put("customer_support", Permission.set(
            Permission.VIEW_DASHBOARD,
            Permission.MANAGE_CUSTOMERS,
            Permission.MANAGE_SUPPORT,
            Permission.VIEW_SUPPORT,
            Permission.MANAGE_CONTACTS,
            Permission.MANAGE_FEEDBACK,
            Permission.VIEW_REPORTS
        ));

        map.put("head_technician", Permission.set(
            Permission.VIEW_DASHBOARD,
            Permission.MANAGE_TECH_SUPPORT,
            Permission.MANAGE_TASKS,
            Permission.MANAGE_WORK_ORDERS,
            Permission.VIEW_SUPPORT,
            Permission.VIEW_REPORTS
        ));

        map.put("technical_staff", Permission.set(
            Permission.VIEW_TASKS,
            Permission.VIEW_SUPPORT,
            Permission.VIEW_PRODUCTS,
            Permission.VIEW_INVENTORY
        ));

        map.put("storekeeper", Permission.set(
            Permission.MANAGE_PRODUCTS,
            Permission.MANAGE_INVENTORY,
            Permission.MANAGE_SUPPLIERS,
            Permission.VIEW_REPORTS
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

    private static Set<String> collectAllPermissions() {
        Set<String> all = new HashSet<>();
        for (Permission permission : Permission.values()) {
            all.add(permission.getCode());
        }
        return Collections.unmodifiableSet(all);
    }
}

