package com.hlgenerator.util;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

/**
 * Centralized permission codes used throughout the application.
 * Prefer referencing the enum constants instead of hard-coded strings
 * to keep permission usage consistent.
 */
public enum Permission {
    VIEW_DASHBOARD("dashboard:view"),
    MANAGE_USERS("users:manage"),
    MANAGE_CUSTOMERS("customers:manage"),
    VIEW_CUSTOMER_PROFILE("customers:view_profile"),
    MANAGE_SUPPORT("support:manage"),
    VIEW_SUPPORT("support:view"),
    MANAGE_TECH_SUPPORT("support:tech_manage"),
    MANAGE_TASKS("tasks:manage"),
    VIEW_TASKS("tasks:view"),
    MANAGE_WORK_ORDERS("workorders:manage"),
    MANAGE_PRODUCTS("products:manage"),
    VIEW_PRODUCTS("products:view"),
    MANAGE_INVENTORY("inventory:manage"),
    VIEW_INVENTORY("inventory:view"),
    MANAGE_SUPPLIERS("suppliers:manage"),
    VIEW_SUPPLIERS("suppliers:view"),
    MANAGE_EMAIL("email:manage"),
    MANAGE_SETTINGS("settings:manage"),
    VIEW_REPORTS("reports:view"),
    MANAGE_CONTACTS("contacts:manage"),
    MANAGE_CONTRACTS("contracts:manage"),
    MANAGE_FEEDBACK("feedback:manage");

    private final String code;

    Permission(String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    }

    /**
     * Convenience method to create an immutable set from a list of permissions.
     */
    public static Set<String> set(Permission... permissions) {
        if (permissions == null || permissions.length == 0) {
            return Collections.emptySet();
        }
        Set<String> result = new HashSet<>(permissions.length);
        Arrays.stream(permissions).forEach(p -> result.add(p.code));
        return Collections.unmodifiableSet(result);
    }
}

