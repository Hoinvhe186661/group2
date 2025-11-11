<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Set, java.util.HashSet, com.hlgenerator.util.AuthorizationUtil, com.hlgenerator.util.Permission" %>
<%
    // Lấy userRole từ session (sử dụng biến local để tránh conflict với file cha)
    String menuUserRole = (String) session.getAttribute("userRole");
    
    // Tạo Set permissions mặc định dựa trên role
    Set<String> defaultPermissions = new HashSet<String>();
    
    if ("admin".equals(menuUserRole)) {
        // ADMIN: Dashboard, Quản lý người dùng, Setting, Quản lý email
        defaultPermissions.add(Permission.VIEW_DASHBOARD.getCode());
        defaultPermissions.add(Permission.MANAGE_USERS.getCode());
        defaultPermissions.add(Permission.MANAGE_SETTINGS.getCode());
        defaultPermissions.add(Permission.MANAGE_EMAIL.getCode());
    } else if ("customer_support".equals(menuUserRole)) {
        // Hỗ Trợ Khách Hàng: Dashboard, Quản lý yêu cầu hỗ trợ, Quản lý feedback, 
        // Quản lý Hợp đồng, Quản lý liên hệ, Quản lý khách hàng
        defaultPermissions.add(Permission.VIEW_DASHBOARD.getCode());
        defaultPermissions.add(Permission.MANAGE_SUPPORT.getCode());
        defaultPermissions.add(Permission.VIEW_SUPPORT.getCode());
        defaultPermissions.add(Permission.MANAGE_FEEDBACK.getCode());
        defaultPermissions.add(Permission.MANAGE_CONTRACTS.getCode());
        defaultPermissions.add(Permission.MANAGE_CONTACTS.getCode());
        defaultPermissions.add(Permission.MANAGE_CUSTOMERS.getCode());
    } else if ("storekeeper".equals(menuUserRole)) {
        // Quản lý kho: Quản lý sản phẩm, Nhà cung cấp, Quản lý kho
        defaultPermissions.add(Permission.MANAGE_PRODUCTS.getCode());
        defaultPermissions.add(Permission.VIEW_PRODUCTS.getCode());
        defaultPermissions.add(Permission.MANAGE_SUPPLIERS.getCode());
        defaultPermissions.add(Permission.VIEW_SUPPLIERS.getCode());
        defaultPermissions.add(Permission.MANAGE_INVENTORY.getCode());
        defaultPermissions.add(Permission.VIEW_INVENTORY.getCode());
    } else if ("head_technician".equals(menuUserRole)) {
        // Trưởng phòng: Dashboard, Yêu cầu hỗ trợ kỹ thuật, Đơn hàng công việc, Quản lý nhân viên kỹ thuật
        defaultPermissions.add(Permission.VIEW_DASHBOARD.getCode());
        defaultPermissions.add(Permission.MANAGE_TECH_SUPPORT.getCode());
        defaultPermissions.add(Permission.MANAGE_WORK_ORDERS.getCode());
        defaultPermissions.add(Permission.MANAGE_TASKS.getCode());
    } else if ("technical_staff".equals(menuUserRole)) {
        // Nhân viên kỹ thuật: Chỉ có quyền xem công việc
        defaultPermissions.add(Permission.VIEW_TASKS.getCode());
    }
    
    // Lấy permissions từ session (các quyền đã được phân quyền thêm)
    Set<String> assignedPermissions = new HashSet<String>();
    Object permsObj = session.getAttribute(AuthorizationUtil.SESSION_PERMISSIONS);
    if (permsObj instanceof Set) {
        @SuppressWarnings("unchecked")
        Set<String> perms = (Set<String>) permsObj;
        assignedPermissions = perms;
    } else if (permsObj instanceof java.util.Collection) {
        java.util.Collection<?> collection = (java.util.Collection<?>) permsObj;
        for (Object obj : collection) {
            if (obj != null) {
                assignedPermissions.add(obj.toString());
            }
        }
    }
    
    // Merge permissions: mặc định + đã phân quyền
    Set<String> permissions = new HashSet<String>(defaultPermissions);
    permissions.addAll(assignedPermissions);
    
    // Lấy current page để highlight menu item
    String currentPageUri = request.getRequestURI();
    String contextPath = request.getContextPath();
    if (currentPageUri.startsWith(contextPath)) {
        currentPageUri = currentPageUri.substring(contextPath.length());
    }
%>
<ul class="sidebar-menu">
    <!-- Dashboard -->
    <% if (permissions.contains(Permission.VIEW_DASHBOARD.getCode())) { %>
    <li <%= currentPageUri.contains("admin") || currentPageUri.equals("/") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/admin.jsp">
            <i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
        </a>
    </li>
    <% } %>
    
    <!-- Quản lý người dùng -->
    <% if (permissions.contains(Permission.MANAGE_USERS.getCode())) { %>
    <li <%= currentPageUri.contains("users") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/users">
            <i class="fa fa-user-secret"></i> <span>Quản lý người dùng</span>
        </a>
    </li>
    <% } %>
    
    <!-- Quản lý khách hàng -->
    <% if (permissions.contains(Permission.MANAGE_CUSTOMERS.getCode()) || permissions.contains(Permission.VIEW_CUSTOMER_PROFILE.getCode())) { %>
    <li <%= currentPageUri.contains("customers") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/customers">
            <i class="fa fa-user-circle"></i> <span>Quản lý khách hàng</span>
        </a>
    </li>
    <% } %>
    
    <!-- Hỗ trợ -->
    <% if (permissions.contains(Permission.MANAGE_SUPPORT.getCode()) || permissions.contains(Permission.VIEW_SUPPORT.getCode()) || permissions.contains(Permission.MANAGE_TECH_SUPPORT.getCode())) { %>
    <li <%= currentPageUri.contains("support") ? "class=\"active treeview\"" : "class=\"treeview\"" %>>
        <a href="#">
            <i class="fa fa-life-ring"></i> <span>Hỗ trợ</span>
            <i class="fa fa-angle-left pull-right"></i>
        </a>
        <ul class="treeview-menu">
            <% if (permissions.contains(Permission.MANAGE_SUPPORT.getCode()) || permissions.contains(Permission.VIEW_SUPPORT.getCode())) { %>
            <li <%= currentPageUri.contains("support_management") ? "class=\"active\"" : "" %>>
                <a href="<%= contextPath %>/support_management.jsp">
                    <i class="fa fa-circle-o"></i> Quản lý hỗ trợ
                </a>
            </li>
            <% } %>
            <% if (permissions.contains(Permission.MANAGE_TECH_SUPPORT.getCode())) { %>
            <li <%= currentPageUri.contains("tech_support") && !currentPageUri.contains("technical_staff") ? "class=\"active\"" : "" %>>
                <a href="<%= contextPath %>/tech_support_management.jsp">
                    <i class="fa fa-circle-o"></i> Hỗ trợ kỹ thuật
                </a>
            </li>
            <li <%= currentPageUri.contains("technical_staff") ? "class=\"active\"" : "" %>>
                <a href="<%= contextPath %>/technical_staff_management.jsp">
                    <i class="fa fa-circle-o"></i> Quản lý nhân viên kỹ thuật
                </a>
            </li>
            <% } %>
        </ul>
    </li>
    <% } %>
    
    <!-- Công việc -->
    <% if (permissions.contains(Permission.MANAGE_TASKS.getCode()) || permissions.contains(Permission.VIEW_TASKS.getCode())) { %>
    <li <%= currentPageUri.contains("task") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/my_tasks.jsp">
            <i class="fa fa-tasks"></i> <span>Công việc</span>
        </a>
    </li>
    <% } %>
    
    <!-- Đơn hàng -->
    <% if (permissions.contains(Permission.MANAGE_WORK_ORDERS.getCode())) { %>
    <li <%= currentPageUri.contains("work_order") || currentPageUri.contains("orders") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/work_orders.jsp">
            <i class="fa fa-file-text"></i> <span>Đơn hàng</span>
        </a>
    </li>
    <% } %>
    
    <!-- Sản phẩm -->
    <% if (permissions.contains(Permission.MANAGE_PRODUCTS.getCode()) || permissions.contains(Permission.VIEW_PRODUCTS.getCode())) { %>
    <li <%= currentPageUri.contains("product") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/products.jsp">
            <i class="fa fa-cube"></i> <span>Quản lý sản phẩm</span>
        </a>
    </li>
    <% } %>
    
    <!-- Kho hàng -->
    <% if (permissions.contains(Permission.MANAGE_INVENTORY.getCode()) || permissions.contains(Permission.VIEW_INVENTORY.getCode())) { %>
    <li <%= currentPageUri.contains("inventory") || currentPageUri.contains("stock") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/inventory.jsp">
            <i class="fa fa-archive"></i> <span>Quản lý kho hàng</span>
        </a>
    </li>
    <% } %>
    
    <!-- Nhà cung cấp -->
    <% if (permissions.contains(Permission.MANAGE_SUPPLIERS.getCode()) || permissions.contains(Permission.VIEW_SUPPLIERS.getCode())) { %>
    <li <%= currentPageUri.contains("supplier") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/supplier.jsp">
            <i class="fa fa-truck"></i> <span>Nhà cung cấp</span>
        </a>
    </li>
    <% } %>
    
    <!-- Email -->
    <% if (permissions.contains(Permission.MANAGE_EMAIL.getCode())) { %>
    <li <%= currentPageUri.contains("email") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/email-management">
            <i class="fa fa-envelope"></i> <span>Quản lý Email</span>
        </a>
    </li>
    <% } %>
    
    <!-- Báo cáo -->
    <% if (permissions.contains(Permission.VIEW_REPORTS.getCode())) { %>
    <li <%= currentPageUri.contains("report") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/reports.jsp">
            <i class="fa fa-bar-chart"></i> <span>Báo cáo</span>
        </a>
    </li>
    <% } %>
    
    <!-- Liên hệ -->
    <% if (permissions.contains(Permission.MANAGE_CONTACTS.getCode())) { %>
    <li <%= currentPageUri.contains("contact") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/contact_management.jsp">
            <i class="fa fa-address-book"></i> <span>Quản lý liên hệ</span>
        </a>
    </li>
    <% } %>
    
    <!-- Hợp đồng -->
    <% if (permissions.contains(Permission.MANAGE_CONTRACTS.getCode())) { %>
    <li <%= currentPageUri.contains("contract") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/contracts.jsp">
            <i class="fa fa-file-contract"></i> <span>Quản lý hợp đồng</span>
        </a>
    </li>
    <% } %>
    
    <!-- Phản hồi -->
    <% if (permissions.contains(Permission.MANAGE_FEEDBACK.getCode())) { %>
    <li <%= currentPageUri.contains("feedback") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/feedback_management.jsp">
            <i class="fa fa-comments"></i> <span>Quản lý phản hồi</span>
        </a>
    </li>
    <% } %>
    
    <!-- Cài đặt -->
    <% if (permissions.contains(Permission.MANAGE_SETTINGS.getCode())) { %>
    <li <%= currentPageUri.contains("settings") ? "class=\"active\"" : "" %>>
        <a href="<%= contextPath %>/settings.jsp">
            <i class="fa fa-cog"></i> <span>Cài đặt</span>
        </a>
    </li>
    <% } %>
</ul>

