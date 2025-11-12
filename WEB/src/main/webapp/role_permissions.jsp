<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.util.stream.*, com.hlgenerator.dao.DBConnect" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    // Admin core permissions that cannot be removed
    final Set<String> ADMIN_CORE_PERMS = new HashSet<String>(Arrays.asList(
        "manage_permissions","manage_users","manage_settings","manage_email"
    ));

    boolean isLoggedIn = Boolean.TRUE.equals(session.getAttribute("isLoggedIn"));
    String currentRole = (String) session.getAttribute("userRole");
    if (!isLoggedIn || currentRole == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Kiểm tra quyền: chỉ người có quyền manage_permissions mới truy cập được
    @SuppressWarnings("unchecked")
    Set<String> userPermissions = (Set<String>) session.getAttribute("userPermissions");
    if (userPermissions == null || !userPermissions.contains("manage_permissions")) {
        response.sendRedirect(request.getContextPath() + "/error/403.jsp");
        return;
    }

    // Handle POST to update matrix
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnect.getConnectionFromProperties();
            conn.setAutoCommit(false);

            // Load role ids and keys
            Map<String,Integer> roleKeyToId = new HashMap<String,Integer>();
            Statement st = null;
            ResultSet rs = null;
            try {
                st = conn.createStatement();
                rs = st.executeQuery("SELECT id, role_key, is_system FROM roles");
                while (rs.next()) {
                    roleKeyToId.put(rs.getString("role_key"), rs.getInt("id"));
                }
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception ignore) {}
                try { if (st != null) st.close(); } catch (Exception ignore) {}
            }
            // Load perm ids and keys
            Map<String,Integer> permKeyToId = new HashMap<String,Integer>();
            st = null;
            rs = null;
            try {
                st = conn.createStatement();
                rs = st.executeQuery("SELECT id, perm_key FROM permissions");
                while (rs.next()) {
                    permKeyToId.put(rs.getString("perm_key"), rs.getInt("id"));
                }
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception ignore) {}
                try { if (st != null) st.close(); } catch (Exception ignore) {}
            }

            // For each role, clear then insert selected permissions
            for (Map.Entry<String,Integer> r : roleKeyToId.entrySet()) {
                String roleKey = r.getKey();
                int roleId = r.getValue();
                // Collect submitted permissions for this role
                String[] selected = request.getParameterValues("perm__" + roleKey);
                Set<String> selectedSet = new HashSet<String>();
                if (selected != null) {
                    selectedSet.addAll(Arrays.asList(selected));
                }
                // Enforce admin core perms cannot be removed
                if ("admin".equals(roleKey)) {
                    selectedSet.addAll(ADMIN_CORE_PERMS);
                }
                // Delete existing
                ps = conn.prepareStatement("DELETE FROM role_permissions WHERE role_id = ?");
                ps.setInt(1, roleId);
                ps.executeUpdate();
                ps.close();
                // Insert new
                ps = conn.prepareStatement("INSERT INTO role_permissions (role_id, permission_id) VALUES (?, ?)");
                for (String permKey : selectedSet) {
                    Integer pid = permKeyToId.get(permKey);
                    if (pid != null) {
                        ps.setInt(1, roleId);
                        ps.setInt(2, pid);
                        ps.addBatch();
                    }
                }
                ps.executeBatch();
                ps.close();
            }
            conn.commit();
            request.setAttribute("saved", true);
        } catch (Exception e) {
            if (e instanceof SQLException) {
                try { if (conn != null) conn.rollback(); } catch (Exception ignore) {}
            }
            request.setAttribute("error", e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignore) {}
            try { if (conn != null) conn.close(); } catch (Exception ignore) {}
        }
    }

    // Load roles, permissions, current mapping
    List<Map<String,Object>> roles = new ArrayList<Map<String,Object>>();
    List<Map<String,Object>> perms = new ArrayList<Map<String,Object>>();
    Map<String, Set<String>> roleToPermKeys = new HashMap<String, Set<String>>();

    Connection conn2 = null;
    Statement st2 = null;
    ResultSet rs2 = null;
    try {
        conn2 = DBConnect.getConnectionFromProperties();
        // Load roles
        try {
            st2 = conn2.createStatement();
            rs2 = st2.executeQuery("SELECT id, role_key, role_name, is_system FROM roles ORDER BY is_system DESC, role_key");
            while (rs2.next()) {
                Map<String,Object> r = new HashMap<String,Object>();
                r.put("id", rs2.getInt("id"));
                r.put("key", rs2.getString("role_key"));
                r.put("name", rs2.getString("role_name"));
                r.put("system", rs2.getBoolean("is_system"));
                roles.add(r);
            }
        } finally {
            try { if (rs2 != null) rs2.close(); } catch (Exception ignore) {}
            try { if (st2 != null) st2.close(); } catch (Exception ignore) {}
        }
        // Load permissions
        try {
            st2 = conn2.createStatement();
            rs2 = st2.executeQuery("SELECT id, perm_key, perm_name, group_name FROM permissions ORDER BY COALESCE(group_name,'zzz'), perm_key");
            while (rs2.next()) {
                Map<String,Object> p = new HashMap<String,Object>();
                p.put("id", rs2.getInt("id"));
                p.put("key", rs2.getString("perm_key"));
                p.put("name", rs2.getString("perm_name"));
                p.put("group", rs2.getString("group_name"));
                perms.add(p);
            }
        } finally {
            try { if (rs2 != null) rs2.close(); } catch (Exception ignore) {}
            try { if (st2 != null) st2.close(); } catch (Exception ignore) {}
        }
        // Load role-permission mapping
        try {
            st2 = conn2.createStatement();
            rs2 = st2.executeQuery(
                "SELECT r.role_key, p.perm_key " +
                "FROM role_permissions rp " +
                "JOIN roles r ON r.id = rp.role_id " +
                "JOIN permissions p ON p.id = rp.permission_id");
            while (rs2.next()) {
                String rk = rs2.getString(1);
                String pk = rs2.getString(2);
                if (!roleToPermKeys.containsKey(rk)) {
                    roleToPermKeys.put(rk, new HashSet<String>());
                }
                roleToPermKeys.get(rk).add(pk);
            }
        } finally {
            try { if (rs2 != null) rs2.close(); } catch (Exception ignore) {}
            try { if (st2 != null) st2.close(); } catch (Exception ignore) {}
        }
    } catch (Exception e) {
        request.setAttribute("error", e.getMessage());
    } finally {
        try { if (conn2 != null) conn2.close(); } catch (Exception ignore) {}
    }

    // Group permissions by group_name for nicer layout
    Map<String, List<Map<String,Object>>> groupedPerms = new LinkedHashMap<String, List<Map<String,Object>>>();
    for (Map<String,Object> p : perms) {
        String g = p.get("group") != null ? (String)p.get("group") : "Khác";
        if (!groupedPerms.containsKey(g)) {
            groupedPerms.put(g, new ArrayList<Map<String,Object>>());
        }
        groupedPerms.get(g).add(p);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng điều khiển | Phân quyền</title>
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css" rel="stylesheet" type="text/css" />
    <style>
        .perm-matrix { overflow-x:auto; }
        .perm-matrix table { min-width: 960px; }
        th.sticky { position: sticky; top: 0; background: #fff; z-index: 2; }
        .perm-group { background:#f8f9fa; font-weight:600; }
        .badge-core { background:#dc3545; }
    </style>
</head>
<body class="skin-black">
    <header class="header">
        <a href="admin" class="logo">Bảng điều khiển</a>
        <nav class="navbar navbar-static-top" role="navigation"></nav>
    </header>
    <div class="wrapper row-offcanvas row-offcanvas-left">
		<jsp:include page="partials/sidebar.jsp"/>
        <aside class="right-side">
            <section class="content">
                <div class="panel">
                    <header class="panel-heading">
                        <h3 style="margin:0">Phân quyền theo ma trận</h3>
                    </header>
                    <div class="panel-body">
                        <%
                            if (request.getAttribute("saved") != null) {
                        %>
                        <div class="alert alert-success"><i class="fa fa-check"></i> Đã lưu phân quyền thành công.</div>
                        <% } %>
                        <%
                            if (request.getAttribute("error") != null) {
                        %>
                        <div class="alert alert-danger"><i class="fa fa-times"></i> Lỗi: <%= request.getAttribute("error") %></div>
                        <% } %>
                        <form method="post" class="perm-matrix">
                            <table class="table table-bordered table-hover">
                                <thead>
                                    <tr>
                                        <th class="sticky">Quyền</th>
                                        <% for (Map<String,Object> r : roles) { %>
                                            <th class="text-center sticky"><%= r.get("name") %><br><small>(<%= r.get("key") %>)</small></th>
                                        <% } %>
                                    </tr>
                                </thead>
                                <tbody>
                                <% for (Map.Entry<String, List<Map<String,Object>>> entry : groupedPerms.entrySet()) { %>
                                    <tr class="perm-group"><td colspan="<%= roles.size()+1 %>"><%= entry.getKey() %></td></tr>
                                    <% for (Map<String,Object> p : entry.getValue()) {
                                           String pk = (String)p.get("key");
                                           String pn = (String)p.get("name");
                                    %>
                                    <tr>
                                        <td>
                                            <strong><%= pn %></strong>
                                            <br><small class="text-muted"><%= pk %></small>
                                            <% if (ADMIN_CORE_PERMS.contains(pk)) { %>
                                                <span class="badge badge-core">Cốt lõi Admin</span>
                                            <% } %>
                                        </td>
                                        <% for (Map<String,Object> r : roles) {
                                               String rk = (String)r.get("key");
                                               boolean isAdmin = "admin".equals(rk);
                                               Set<String> existing = roleToPermKeys.containsKey(rk) ? roleToPermKeys.get(rk) : Collections.<String>emptySet();
                                               boolean checked = existing.contains(pk) ||
                                                   (isAdmin && ADMIN_CORE_PERMS.contains(pk));
                                               boolean disabled = isAdmin && ADMIN_CORE_PERMS.contains(pk);
                                        %>
                                            <td class="text-center">
                                                <input type="checkbox"
                                                       name="perm__<%= rk %>"
                                                       value="<%= pk %>"
                                                       <%= checked ? "checked" : "" %>
                                                       <%= disabled ? "disabled" : "" %> />
                                            </td>
                                        <% } %>
                                    </tr>
                                    <% } %>
                                <% } %>
                                </tbody>
                            </table>
                            <div class="text-right">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa fa-save"></i> Lưu thay đổi
                                </button>
                            </div>
                        </form>
                        <hr>
                        <p class="text-muted">
                            Lưu ý: Các quyền cốt lõi của Admin không thể bị xóa. Bạn có thể thêm quyền mới cho Admin.
                        </p>
                    </div>
                </div>
            </section>
        </aside>
    </div>
    <script src="js/jquery.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>

