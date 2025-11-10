package com.hlgenerator.util;

import org.json.JSONArray;
import org.json.JSONException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Helper functions for handling authentication and authorization checks.
 */
public final class AuthorizationUtil {
    public static final String SESSION_PERMISSIONS = "permissions";

    private AuthorizationUtil() {
    }

    public static boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && Boolean.TRUE.equals(session.getAttribute("isLoggedIn"));
    }

    public static boolean hasPermission(HttpServletRequest request, Permission permission) {
        return hasAnyPermission(request, Collections.singleton(permission.getCode()));
    }

    public static boolean hasAnyPermission(HttpServletRequest request, Permission... permissions) {
        if (permissions == null || permissions.length == 0) {
            return true;
        }
        Set<String> codes = Stream.of(permissions)
            .filter(Objects::nonNull)
            .map(Permission::getCode)
            .collect(Collectors.toSet());
        return hasAnyPermission(request, codes);
    }

    public static boolean hasAnyPermission(HttpServletRequest request, Collection<String> permissionCodes) {
        if (permissionCodes == null || permissionCodes.isEmpty()) {
            return true;
        }
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }

        Object stored = session.getAttribute(SESSION_PERMISSIONS);
        if (stored instanceof Set) {
            @SuppressWarnings("unchecked")
            Set<String> perms = (Set<String>) stored;
            return intersects(perms, permissionCodes);
        }

        if (stored instanceof Collection) {
            Collection<?> collection = (Collection<?>) stored;
            Set<String> perms = collection.stream()
                .filter(Objects::nonNull)
                .map(Object::toString)
                .collect(Collectors.toSet());
            session.setAttribute(SESSION_PERMISSIONS, perms);
            return intersects(perms, permissionCodes);
        }

        if (stored instanceof String) {
            Set<String> perms = parsePermissions((String) stored);
            session.setAttribute(SESSION_PERMISSIONS, perms);
            return intersects(perms, permissionCodes);
        }

        return false;
    }

    public static boolean requirePermission(HttpServletRequest request,
                                            HttpServletResponse response,
                                            Permission permission) throws IOException {
        if (!isLoggedIn(request)) {
            redirectToLogin(request, response);
            return false;
        }

        if (!hasPermission(request, permission)) {
            denyAccess(request, response);
            return false;
        }

        return true;
    }

    public static boolean requireAnyPermission(HttpServletRequest request,
                                               HttpServletResponse response,
                                               Permission... permissions) throws IOException {
        if (!isLoggedIn(request)) {
            redirectToLogin(request, response);
            return false;
        }

        if (!hasAnyPermission(request, permissions)) {
            denyAccess(request, response);
            return false;
        }

        return true;
    }

    public static void storePermissions(HttpSession session, Set<String> permissionCodes) {
        if (session == null) {
            return;
        }
        session.setAttribute(SESSION_PERMISSIONS, permissionCodes != null
            ? Collections.unmodifiableSet(new HashSet<>(permissionCodes))
            : Collections.emptySet());
    }

    public static Set<String> resolveEffectivePermissions(String role, String customPermissionsJson) {
        Set<String> effective = new HashSet<>(RolePermissionConfig.getDefaultPermissions(role));
        effective.addAll(parsePermissions(customPermissionsJson));
        return effective;
    }

    public static Set<String> parsePermissions(String permissionsJson) {
        if (permissionsJson == null || permissionsJson.trim().isEmpty()) {
            return Collections.emptySet();
        }
        try {
            JSONArray array = new JSONArray(permissionsJson);
            Set<String> result = new HashSet<>(array.length());
            for (int i = 0; i < array.length(); i++) {
                String value = array.optString(i, null);
                if (value != null && !value.trim().isEmpty()) {
                    result.add(value.trim());
                }
            }
            return result;
        } catch (JSONException ex) {
            // Fallback: treat as comma separated values
            String[] parts = permissionsJson.split(",");
            Set<String> result = new HashSet<>(parts.length);
            for (String part : parts) {
                if (part != null && !part.trim().isEmpty()) {
                    result.add(part.trim());
                }
            }
            return result;
        }
    }

    private static void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String contextPath = request.getContextPath() == null ? "" : request.getContextPath();
        response.sendRedirect(contextPath + "/login.jsp");
    }

    private static void denyAccess(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String contextPath = request.getContextPath() == null ? "" : request.getContextPath();
        response.sendRedirect(contextPath + "/403.jsp");
    }

    private static boolean intersects(Collection<String> source, Collection<String> target) {
        for (String code : target) {
            if (source.contains(code)) {
                return true;
            }
        }
        return false;
    }
}

