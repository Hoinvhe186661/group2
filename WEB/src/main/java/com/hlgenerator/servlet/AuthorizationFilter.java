package com.hlgenerator.servlet;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class AuthorizationFilter implements Filter {

	private final Set<String> publicPaths = new HashSet<String>();
	private final Map<String, String> pathPermissionMap = new HashMap<String, String>();

	@Override
	public void init(FilterConfig filterConfig) {
		// Public/unprotected endpoints
		publicPaths.add("/");
		publicPaths.add("/index.jsp");
		publicPaths.add("/login");
		publicPaths.add("/login.jsp");
		publicPaths.add("/logout");
		publicPaths.add("/error/404.jsp");
		publicPaths.add("/error/500.jsp");

		// Static resources
		publicPaths.add("/css/");
		publicPaths.add("/js/");
		publicPaths.add("/img/");
		publicPaths.add("/fonts/");
		publicPaths.add("/assets/");

		// Map protected JSPs/paths to permission keys
		pathPermissionMap.put("/role_permissions.jsp", "manage_permissions");
		pathPermissionMap.put("/users", "manage_users");
		pathPermissionMap.put("/email-management", "manage_email");
		pathPermissionMap.put("/settings.jsp", "manage_settings");

		pathPermissionMap.put("/support_management.jsp", "manage_support_requests");
		pathPermissionMap.put("/feedback_management.jsp", "manage_feedback");
		pathPermissionMap.put("/contracts.jsp", "manage_contracts");
		pathPermissionMap.put("/contact_management.jsp", "manage_contacts");
		pathPermissionMap.put("/customers.jsp", "manage_customers");

		pathPermissionMap.put("/my_tasks.jsp", "view_my_tasks");
		pathPermissionMap.put("/tech_support_management.jsp", "manage_tech_support_requests");
		pathPermissionMap.put("/work_orders.jsp", "manage_work_orders");
		pathPermissionMap.put("/technical_staff_management.jsp", "manage_technical_staff");

		pathPermissionMap.put("/products.jsp", "manage_products");
		pathPermissionMap.put("/supplier.jsp", "manage_suppliers");
		pathPermissionMap.put("/inventory.jsp", "manage_inventory");

		pathPermissionMap.put("/support.jsp", "submit_support_request");
		pathPermissionMap.put("/contact.jsp", "submit_contact");
	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		HttpServletRequest req = (HttpServletRequest) request;
		HttpServletResponse resp = (HttpServletResponse) response;

		String context = req.getContextPath();
		String uri = req.getRequestURI();
		String path = uri.substring(context.length());
		
		// Normalize path: remove query string if present
		if (path.contains("?")) {
			path = path.substring(0, path.indexOf("?"));
		}

		// Allow public paths and static resources
		if (isPublic(path)) {
			chain.doFilter(request, response);
			return;
		}

		// Require login
		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("isLoggedIn") == null) {
			resp.sendRedirect(context + "/login.jsp");
			return;
		}

		// Check permission if mapping exists
		String required = resolveRequiredPermission(path);
		if (required == null) {
			// No mapping → deny by default for security
			System.out.println("AUTH FILTER: No permission mapping for path: " + path + ", denying access");
			resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
			resp.sendRedirect(context + "/error/403.jsp");
			return;
		}

		@SuppressWarnings("unchecked")
		Set<String> userPerms = (Set<String>) session.getAttribute("userPermissions");
		if (userPerms == null) {
			userPerms = new HashSet<String>();
		}
		
		String role = (String) session.getAttribute("userRole");
		
		// Debug logging
		System.out.println("AUTH FILTER: Path=" + path + ", Required=" + required + ", Role=" + role + ", HasPermission=" + userPerms.contains(required));
		
		// Check permission - admin cũng phải có quyền tương ứng
		if (userPerms.contains(required)) {
			chain.doFilter(request, response);
			return;
		}

		// Forbidden
		System.out.println("AUTH FILTER: Access DENIED for role=" + role + " to path=" + path + " (required permission: " + required + ")");
		resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
		resp.sendRedirect(context + "/error/403.jsp");
	}

	private boolean isPublic(String path) {
		if (publicPaths.contains(path)) return true;
		// Prefix-based for static
		for (String p : publicPaths) {
			if (p.endsWith("/") && path.startsWith(p)) return true;
		}
		return false;
	}

	private String resolveRequiredPermission(String path) {
		// Normalize path: ensure it starts with /
		if (!path.startsWith("/")) {
			path = "/" + path;
		}
		
		// Exact match first
		if (pathPermissionMap.containsKey(path)) {
			return pathPermissionMap.get(path);
		}
		
		// Try exact match with filename only (for cases like /some/path/customers.jsp)
		String filename = path.substring(path.lastIndexOf("/"));
		if (pathPermissionMap.containsKey(filename)) {
			return pathPermissionMap.get(filename);
		}
		
		// Also try by JSP filename endings (backward compatibility)
		for (Map.Entry<String, String> e : pathPermissionMap.entrySet()) {
			if (path.endsWith(e.getKey())) {
				return e.getValue();
			}
		}
		return null;
	}

	@Override
	public void destroy() {
	}
}


