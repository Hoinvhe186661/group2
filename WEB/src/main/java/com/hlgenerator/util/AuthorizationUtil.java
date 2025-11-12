package com.hlgenerator.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.HashSet;
import java.util.Set;

/**
 * Utility class để kiểm tra quyền truy cập của user
 */
public class AuthorizationUtil {
    
    /**
     * Kiểm tra xem user có quyền cụ thể không
     * @param request HttpServletRequest để lấy session
     * @param permissionKey Key của permission cần kiểm tra (ví dụ: Permission.MANAGE_INVENTORY)
     * @return true nếu user có quyền, false nếu không
     */
    public static boolean hasPermission(HttpServletRequest request, String permissionKey) {
        if (request == null || permissionKey == null) {
            return false;
        }
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        
        // Lấy permissions từ session
        @SuppressWarnings("unchecked")
        Set<String> userPermissions = (Set<String>) session.getAttribute("userPermissions");
        
        if (userPermissions == null || userPermissions.isEmpty()) {
            return false;
        }
        
        // Kiểm tra permission
        return userPermissions.contains(permissionKey);
    }
    
    /**
     * Kiểm tra xem user có bất kỳ quyền nào trong danh sách không
     * @param request HttpServletRequest để lấy session
     * @param permissionKeys Mảng các permission keys cần kiểm tra
     * @return true nếu user có ít nhất một quyền trong danh sách
     */
    public static boolean hasAnyPermission(HttpServletRequest request, String... permissionKeys) {
        if (request == null || permissionKeys == null || permissionKeys.length == 0) {
            return false;
        }
        
        for (String key : permissionKeys) {
            if (hasPermission(request, key)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Kiểm tra xem user có tất cả quyền trong danh sách không
     * @param request HttpServletRequest để lấy session
     * @param permissionKeys Mảng các permission keys cần kiểm tra
     * @return true nếu user có tất cả quyền trong danh sách
     */
    public static boolean hasAllPermissions(HttpServletRequest request, String... permissionKeys) {
        if (request == null || permissionKeys == null || permissionKeys.length == 0) {
            return false;
        }
        
        for (String key : permissionKeys) {
            if (!hasPermission(request, key)) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Lấy tất cả permissions của user từ session
     * @param request HttpServletRequest để lấy session
     * @return Set các permission keys, empty set nếu không có
     */
    public static Set<String> getUserPermissions(HttpServletRequest request) {
        Set<String> permissions = new HashSet<String>();
        
        if (request == null) {
            return permissions;
        }
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            return permissions;
        }
        
        @SuppressWarnings("unchecked")
        Set<String> userPermissions = (Set<String>) session.getAttribute("userPermissions");
        
        if (userPermissions != null) {
            permissions.addAll(userPermissions);
        }
        
        return permissions;
    }
    
    /**
     * Kiểm tra xem user có role cụ thể không
     * @param request HttpServletRequest để lấy session
     * @param role Role cần kiểm tra (ví dụ: "admin", "storekeeper")
     * @return true nếu user có role đó
     */
    public static boolean hasRole(HttpServletRequest request, String role) {
        if (request == null || role == null) {
            return false;
        }
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        
        String userRole = (String) session.getAttribute("userRole");
        return role.equalsIgnoreCase(userRole);
    }
}

