<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Set" %>
<%
    // Kiểm tra đăng nhập
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Kiểm tra quyền: chỉ người có quyền manage_technical_staff mới truy cập được
    @SuppressWarnings("unchecked")
    Set<String> userPermissions = (Set<String>) session.getAttribute("userPermissions");
    if (userPermissions == null || !userPermissions.contains("manage_technical_staff")) {
        response.sendRedirect(request.getContextPath() + "/error/403.jsp");
        return;
    }
    
    // Lấy tham số filter và pagination
    String pageParam = request.getParameter("page");
    String sizeParam = request.getParameter("size");
    int currentPage = 1;
    int pageSize = 10;
    try { if (pageParam != null) currentPage = Integer.parseInt(pageParam); } catch (Exception ignored) {}
    try { if (sizeParam != null) pageSize = Integer.parseInt(sizeParam); } catch (Exception ignored) {}
    if (currentPage < 1) currentPage = 1;
    if (pageSize < 1) pageSize = 10;
    
    String statusFilter = request.getParameter("status");
    String priorityFilter = request.getParameter("priority");
    String searchKeyword = request.getParameter("q");
    String startDateFromParam = request.getParameter("startDateFrom");
    String startDateToParam = request.getParameter("startDateTo");
    String deadlineFromParam = request.getParameter("deadlineFrom");
    String deadlineToParam = request.getParameter("deadlineTo");
    
    // Normalize empty strings to null
    if (statusFilter != null && statusFilter.trim().isEmpty()) statusFilter = null;
    if (priorityFilter != null && priorityFilter.trim().isEmpty()) priorityFilter = null;
    if (searchKeyword != null && searchKeyword.trim().isEmpty()) searchKeyword = null;
    
    // Parse date parameters
    java.sql.Date startDateFrom = null;
    java.sql.Date startDateTo = null;
    java.sql.Date deadlineFrom = null;
    java.sql.Date deadlineTo = null;
    try {
        if (startDateFromParam != null && !startDateFromParam.trim().isEmpty()) {
            startDateFrom = java.sql.Date.valueOf(startDateFromParam);
        }
    } catch (Exception ignored) {}
    try {
        if (startDateToParam != null && !startDateToParam.trim().isEmpty()) {
            startDateTo = java.sql.Date.valueOf(startDateToParam);
        }
    } catch (Exception ignored) {}
    try {
        if (deadlineFromParam != null && !deadlineFromParam.trim().isEmpty()) {
            deadlineFrom = java.sql.Date.valueOf(deadlineFromParam);
        }
    } catch (Exception ignored) {}
    try {
        if (deadlineToParam != null && !deadlineToParam.trim().isEmpty()) {
            deadlineTo = java.sql.Date.valueOf(deadlineToParam);
        }
    } catch (Exception ignored) {}
    
    // Load data từ DAO
    com.hlgenerator.dao.WorkOrderTaskDAO taskDAO = new com.hlgenerator.dao.WorkOrderTaskDAO();
    java.util.Map<String, Object> result = taskDAO.getTechnicalStaffTasksFlatList(statusFilter, priorityFilter, searchKeyword, 
            startDateFrom, startDateTo, deadlineFrom, deadlineTo, currentPage, pageSize);
    java.util.List<java.util.Map<String, Object>> tasks = (java.util.List<java.util.Map<String, Object>>) result.get("data");
    int total = (Integer) result.get("total");
    int totalPages = (int) Math.ceil(total / (double) pageSize);
    if (totalPages == 0) totalPages = 1;
    if (currentPage > totalPages) currentPage = totalPages;
    
    // Helper function để format date
    java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("dd/MM/yyyy");
%>
<%!
    String formatDate(java.sql.Timestamp ts) {
        if (ts == null) return "-";
        try {
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
            return sdf.format(ts);
        } catch (Exception e) {
            return "-";
        }
    }
    
    String getPriorityLabel(String priority) {
        if (priority == null) return "N/A";
        if ("urgent".equals(priority)) return "Khẩn cấp";
        if ("high".equals(priority)) return "Cao";
        if ("medium".equals(priority)) return "Trung bình";
        if ("low".equals(priority)) return "Thấp";
        return priority;
    }
    
    String getStatusLabel(String status) {
        if (status == null) return "N/A";
        if ("pending".equals(status)) return "Chờ xử lý";
        if ("in_progress".equals(status)) return "Đang thực hiện";
        if ("completed".equals(status)) return "Hoàn thành";
        if ("rejected".equals(status)) return "Đã từ chối";
        if ("cancelled".equals(status)) return "Đã hủy";
        return status;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Nhân Viên | HL Generator</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <!-- bootstrap 3.0.2 -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- font Awesome -->
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Ionicons -->
    <link href="css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <!-- DataTables -->
    <link href="css/datatables/dataTables.bootstrap.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="css/style.css" rel="stylesheet" type="text/css" />
    
    <style>
        .filter-section {
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 15px;
            margin-bottom: 15px;
        }
        .filter-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            cursor: pointer;
        }
        .filter-content {
            display: none;
        }
        .filter-content.show {
            display: block;
        }
        .filter-content .filter-row {
            display: flex;
            gap: 8px;
            align-items: flex-end;
            margin-bottom: 10px;
        }
        .filter-group {
            flex: 1;
            min-width: 150px;
        }
        .filter-group.small {
            flex: 0 0 120px;
        }
        .filter-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: normal;
            font-size: 12px;
        }
        .filter-actions {
            display: flex;
            gap: 8px;
            align-items: flex-end;
        }
        .filter-actions .btn {
            height: 32px;
            padding: 6px 14px;
            font-size: 12px;
            white-space: nowrap;
        }
        .badge {
            padding: 4px 10px;
            font-size: 11px;
            font-weight: 600;
            border-radius: 12px;
        }
        .badge-urgent { background-color: #d9534f !important; color: white; }
        .badge-high { background-color: #f0ad4e !important; color: white; }
        .badge-medium { background-color: #5bc0de !important; color: white; }
        .badge-low { background-color: #5cb85c !important; color: white; }
        .badge-pending { background-color: #f0ad4e !important; color: white; }
        .badge-in_progress { background-color: #5bc0de !important; color: white; }
        .badge-completed { background-color: #5cb85c !important; color: white; }
        .badge-rejected { background-color: #d9534f !important; color: white; }
        .badge-cancelled { background-color: #777 !important; color: white; }
        #filterToggleIcon {
            transition: transform 0.3s;
        }
        #filterToggleIcon.rotated {
            transform: rotate(180deg);
        }
        @media (max-width: 768px) {
            .filter-row {
                flex-direction: column;
                align-items: stretch;
            }
            .filter-group {
                min-width: 100%;
            }
            .filter-actions {
                width: 100%;
            }
            .filter-actions .btn {
                flex: 1;
            }
        }
        
        /* Fix tràn chữ trong sidebar */
        .sidebar-menu li a {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            word-wrap: break-word;
            max-width: 100%;
            font-size: 13px !important;
            padding: 10px 5px 10px 15px !important;
        }
        
        .sidebar-menu li a span {
            display: inline-block;
            max-width: calc(100% - 30px);
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            vertical-align: top;
            font-size: 13px !important;
        }
        
        .sidebar-menu li a i {
            margin-right: 8px;
            width: 20px;
            text-align: center;
            flex-shrink: 0;
            font-size: 14px !important;
        }
        
        /* Đảm bảo sidebar có đủ không gian */
        .left-side {
            overflow-x: hidden;
        }
        
        .sidebar {
            overflow-x: hidden;
            overflow-y: auto;
        }
        
        /* Giảm font-size cho logo trong sidebar nếu có */
        .sidebar .logo {
            font-size: 16px !important;
            padding: 15px 10px !important;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
    </style>
</head>
<body class="skin-black">
    <!-- header logo -->
    <header class="header">
        <a href="headtech.jsp" class="logo">
            Quản Lý Nhân Viên
        </a>
        <!-- Header Navbar -->
        <nav class="navbar navbar-static-top" role="navigation">
            <!-- Sidebar toggle button-->
            <a href="#" class="navbar-btn sidebar-toggle" data-toggle="offcanvas" role="button">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </a>
            <div class="navbar-right">
                <ul class="nav navbar-nav">
                    <!-- User Account -->
                    <li class="dropdown user user-menu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="fa fa-user"></i>
                            <span><%= username %> <i class="caret"></i></span>
                        </a>
                        <ul class="dropdown-menu dropdown-custom dropdown-menu-right">
                            <li class="dropdown-header text-center">Tài khoản</li>
                            <li>
                                <a href="profile.jsp">
                                <i class="fa fa-user fa-fw pull-right"></i>
                                    Hồ sơ
                                </a>
                                <a href="settings.jsp">
                                <i class="fa fa-cog fa-fw pull-right"></i>
                                    Cài đặt
                                </a>
                            </li>
                            <li class="divider"></li>
                            <li>
                                <a href="logout"><i class="fa fa-ban fa-fw pull-right"></i> Đăng xuất</a>
                            </li>
                        </ul>
                    </li>
                </ul>
            </div>
        </nav>
    </header>
    
    <div class="wrapper row-offcanvas row-offcanvas-left">
		<jsp:include page="partials/sidebar.jsp"/>

        <aside class="right-side">
            <section class="content-header">
                <h1>
                    Quản Lý Nhân Viên
                    <small>Xem công việc của từng nhân viên</small>
                </h1>
                <ol class="breadcrumb">
                    <li><a href="headtech.jsp"><i class="fa fa-dashboard"></i> Trang chủ</a></li>
                    <li class="active">Quản lý nhân viên</li>
                </ol>
            </section>

            <section class="content">
                <div class="row">
                    <div class="col-xs-12">
                        <div class="panel">
                            <header class="panel-heading">
                                <h3>Danh sách nhiệm vụ nhân viên kỹ thuật</h3>
                            </header>
                            <div class="panel-body table-responsive">
                                <div class="filter-section">
                                    <div class="filter-header" onclick="toggleFilters()">
                                        <h4><i class="fa fa-filter"></i> Bộ lọc</h4>
                                        <i class="fa fa-chevron-down" id="filterToggleIcon"></i>
                                    </div>
                                    <div class="filter-content" id="filterContent">
                                        <form method="get" action="technical_staff_management.jsp">
                                            <div class="filter-row">
                                                <div class="filter-group">
                                                    <label for="statusFilter">Trạng thái</label>
                                                    <select class="form-control" id="statusFilter" name="status">
                                                        <option value="" <%= statusFilter == null || "".equals(statusFilter) ? "selected" : "" %>>Tất cả</option>
                                                        <option value="pending" <%= "pending".equals(statusFilter) ? "selected" : "" %>>Chờ xử lý</option>
                                                        <option value="in_progress" <%= "in_progress".equals(statusFilter) ? "selected" : "" %>>Đang thực hiện</option>
                                                        <option value="completed" <%= "completed".equals(statusFilter) ? "selected" : "" %>>Hoàn thành</option>
                                                        <option value="rejected" <%= "rejected".equals(statusFilter) ? "selected" : "" %>>Đã từ chối</option>
                                                        <option value="cancelled" <%= "cancelled".equals(statusFilter) ? "selected" : "" %>>Đã hủy</option>
                                                    </select>
                                                </div>
                                                <div class="filter-group">
                                                    <label for="priorityFilter">Độ ưu tiên</label>
                                                    <select class="form-control" id="priorityFilter" name="priority">
                                                        <option value="" <%= priorityFilter == null || "".equals(priorityFilter) ? "selected" : "" %>>Tất cả</option>
                                                        <option value="urgent" <%= "urgent".equals(priorityFilter) ? "selected" : "" %>>Khẩn cấp</option>
                                                        <option value="high" <%= "high".equals(priorityFilter) ? "selected" : "" %>>Cao</option>
                                                        <option value="medium" <%= "medium".equals(priorityFilter) ? "selected" : "" %>>Trung bình</option>
                                                        <option value="low" <%= "low".equals(priorityFilter) ? "selected" : "" %>>Thấp</option>
                                                    </select>
                                                </div>
                                                <div class="filter-group">
                                                    <label for="search">Tìm kiếm</label>
                                                    <input type="text" class="form-control" id="search" name="q" placeholder="Tên NV, mã task, mô tả..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
                                                </div>
                                            </div>
                                            <div class="filter-row">
                                                <div class="filter-group">
                                                    <label for="startDateFrom">Ngày giao từ</label>
                                                    <input type="date" class="form-control" id="startDateFrom" name="startDateFrom" value="<%= startDateFromParam != null ? startDateFromParam : "" %>">
                                                </div>
                                                <div class="filter-group">
                                                    <label for="startDateTo">Ngày giao đến</label>
                                                    <input type="date" class="form-control" id="startDateTo" name="startDateTo" value="<%= startDateToParam != null ? startDateToParam : "" %>">
                                                </div>
                                                <div class="filter-group">
                                                    <label for="deadlineFrom">Deadline từ</label>
                                                    <input type="date" class="form-control" id="deadlineFrom" name="deadlineFrom" value="<%= deadlineFromParam != null ? deadlineFromParam : "" %>">
                                                </div>
                                                <div class="filter-group">
                                                    <label for="deadlineTo">Deadline đến</label>
                                                    <input type="date" class="form-control" id="deadlineTo" name="deadlineTo" value="<%= deadlineToParam != null ? deadlineToParam : "" %>">
                                                </div>
                                            </div>
                                            <div class="filter-row">
                                                <div class="filter-group small">
                                                    <label for="pageSize">Hiển thị</label>
                                                    <select class="form-control" id="pageSize" name="size" onchange="this.form.submit()">
                                                        <option value="10" <%= pageSize == 10 ? "selected" : "" %>>10</option>
                                                        <option value="25" <%= pageSize == 25 ? "selected" : "" %>>25</option>
                                                        <option value="50" <%= pageSize == 50 ? "selected" : "" %>>50</option>
                                                        <option value="100" <%= pageSize == 100 ? "selected" : "" %>>100</option>
                                                    </select>
                                                </div>
                                                <div class="filter-actions">
                                                    <button type="submit" class="btn btn-primary">
                                                        <i class="fa fa-filter"></i> Lọc
                                                    </button>
                                                    <a href="technical_staff_management.jsp" class="btn btn-default">
                                                        <i class="fa fa-times"></i> Xóa lọc
                                                    </a>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                                
                                <table class="table table-hover" id="tasksTable">
                                    <thead>
                                        <tr>
                                            <th>STT</th>
                                            <th>Nhân viên</th>
                                            <th>Email</th>
                                            <th>Mã Task</th>
                                            <th>Mô tả</th>
                                            <th>Work Order</th>
                                            <th>Độ ưu tiên</th>
                                            <th>Trạng thái</th>
                                            <th>Giờ ước tính</th>
                                            <th>Ngày giao</th>
                                            <th>Deadline</th>
                                            <th>Ngày hoàn thành</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tasksTableBody">
                                        <%
                                            if (tasks != null && !tasks.isEmpty()) {
                                                // Tính STT dựa trên phân trang: STT = (trang hiện tại - 1) * số bản ghi mỗi trang + 1
                                                int stt = (currentPage - 1) * pageSize + 1;
                                                for (java.util.Map<String, Object> task : tasks) {
                                        %>
                                        <tr>
                                            <td><%= stt++ %></td>
                                            <td><%= task.get("staffName") != null ? task.get("staffName") : "-" %></td>
                                            <td><%= task.get("staffEmail") != null ? task.get("staffEmail") : "-" %></td>
                                            <td><strong><%= task.get("taskNumber") != null ? task.get("taskNumber") : "-" %></strong></td>
                                            <td><%= task.get("taskDescription") != null ? task.get("taskDescription") : "-" %></td>
                                            <td><%= task.get("workOrderNumber") != null ? task.get("workOrderNumber") : "-" %></td>
                                            <td>
                                                <%
                                                    String priority = (String) task.get("priority");
                                                    if (priority != null) {
                                                %>
                                                <span class="badge badge-<%= priority %>"><%= getPriorityLabel(priority) %></span>
                                                <%
                                                    } else {
                                                %>
                                                <span class="badge">N/A</span>
                                                <%
                                                    }
                                                %>
                                            </td>
                                            <td>
                                                <%
                                                    String status = (String) task.get("status");
                                                    if (status != null) {
                                                %>
                                                <span class="badge badge-<%= status %>"><%= getStatusLabel(status) %></span>
                                                <%
                                                    } else {
                                                %>
                                                <span class="badge">N/A</span>
                                                <%
                                                    }
                                                %>
                                            </td>
                                            <td class="text-center">
                                                <%
                                                    java.math.BigDecimal estimatedHours = (java.math.BigDecimal) task.get("estimatedHours");
                                                    if (estimatedHours != null) {
                                                %>
                                                <%= String.format("%.1f", estimatedHours) %>h
                                                <%
                                                    } else {
                                                %>
                                                -
                                                <%
                                                    }
                                                %>
                                            </td>
                                            <td class="text-center"><%= formatDate((java.sql.Timestamp) task.get("startDate")) %></td>
                                            <td class="text-center"><%= formatDate((java.sql.Timestamp) task.get("deadline")) %></td>
                                            <td class="text-center">
                                                <%
                                                    java.sql.Timestamp completionDate = (java.sql.Timestamp) task.get("completionDate");
                                                    String statusStr = (String) task.get("status");
                                                    if (completionDate != null) {
                                                        if ("completed".equals(statusStr)) {
                                                %>
                                                <span class="text-success" style="font-weight: bold;"><i class="fa fa-check-circle"></i> <%= formatDate(completionDate) %></span>
                                                <%
                                                        } else {
                                                %>
                                                <%= formatDate(completionDate) %>
                                                <%
                                                        }
                                                    } else {
                                                %>
                                                -
                                                <%
                                                    }
                                                %>
                                            </td>
                                        </tr>
                                        <%
                                                }
                                            } else {
                                        %>
                                        <tr>
                                            <td colspan="12" class="text-center text-muted">Không có dữ liệu</td>
                                        </tr>
                                        <%
                                            }
                                        %>
                                    </tbody>
                                </table>

                                <div class="row" style="margin-top: 10px;">
                                    <div class="col-md-6">
                                        <div id="tasksPaginationInfo" class="text-muted" style="line-height: 34px;">
                                            <%
                                                int _startIdx = (currentPage - 1) * pageSize + 1;
                                                int _endIdx = Math.min(currentPage * pageSize, total);
                                                if (total == 0) { _startIdx = 0; _endIdx = 0; }
                                            %>
                                            Hiển thị <%= _startIdx %> - <%= _endIdx %> của <%= total %> nhiệm vụ
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <nav aria-label="Phân trang nhiệm vụ" class="pull-right">
                                            <ul class="pagination pagination-sm" style="margin: 0;">
                                                <%
                                                    // Xây base query giữ nguyên filter
                                                    java.util.List<String> _p = new java.util.ArrayList<String>();
                                                    try { String v = request.getParameter("status"); if (v != null && !v.isEmpty()) _p.add("status=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    try { String v = request.getParameter("priority"); if (v != null && !v.isEmpty()) _p.add("priority=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    try { String v = request.getParameter("q"); if (v != null && !v.isEmpty()) _p.add("q=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    try { String v = request.getParameter("startDateFrom"); if (v != null && !v.isEmpty()) _p.add("startDateFrom=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    try { String v = request.getParameter("startDateTo"); if (v != null && !v.isEmpty()) _p.add("startDateTo=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    try { String v = request.getParameter("deadlineFrom"); if (v != null && !v.isEmpty()) _p.add("deadlineFrom=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    try { String v = request.getParameter("deadlineTo"); if (v != null && !v.isEmpty()) _p.add("deadlineTo=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    _p.add("size=" + pageSize);
                                                    String _base = "technical_staff_management.jsp" + (_p.isEmpty() ? "" : ("?" + String.join("&", _p)));
                                                    // Nút prev
                                                    int _prev = Math.max(1, currentPage - 1);
                                                %>
                                                <li class="<%= currentPage == 1 ? "disabled" : "" %>"><a href="<%= _base + "&page=" + _prev %>">&laquo;</a></li>
                                                <%
                                                    int _s = Math.max(1, currentPage - 2);
                                                    int _e = Math.min(totalPages, currentPage + 2);
                                                    if (_s > 1) {
                                                %>
                                                <li><a href="<%= _base + "&page=1" %>">1</a></li>
                                                <%= (_s > 2) ? "<li class=\"disabled\"><span>...</span></li>" : "" %>
                                                <%
                                                    }
                                                    for (int i = _s; i <= _e; i++) {
                                                %>
                                                <li class="<%= i == currentPage ? "active" : "" %>"><a href="<%= _base + "&page=" + i %>"><%= i %></a></li>
                                                <%
                                                    }
                                                    if (_e < totalPages) {
                                                %>
                                                <%= (_e < totalPages - 1) ? "<li class=\"disabled\"><span>...</span></li>" : "" %>
                                                <li><a href="<%= _base + "&page=" + totalPages %>"><%= totalPages %></a></li>
                                                <%
                                                    }
                                                    int _next = Math.min(totalPages, currentPage + 1);
                                                %>
                                                <li class="<%= currentPage == totalPages ? "disabled" : "" %>"><a href="<%= _base + "&page=" + _next %>">&raquo;</a></li>
                                            </ul>
                                        </nav>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </aside>
    </div>

    <!-- jQuery -->
    <script src="js/jquery.min.js"></script>
    <!-- Bootstrap -->
    <script src="js/bootstrap.min.js"></script>
    <!-- DataTables -->
    <script src="js/plugins/datatables/jquery.dataTables.js" type="text/javascript"></script>
    <script src="js/plugins/datatables/dataTables.bootstrap.js" type="text/javascript"></script>
    <!-- AdminLTE App -->
    <script src="js/AdminLTE/app.js"></script>

    <script>
        var tasksTable;
        
        // Toggle filter visibility
        function toggleFilters() {
            var content = document.getElementById('filterContent');
            var icon = document.getElementById('filterToggleIcon');
            if (content.classList.contains('show')) {
                content.classList.remove('show');
                icon.classList.remove('rotated');
            } else {
                content.classList.add('show');
                icon.classList.add('rotated');
            }
        }
        
        // Load filter state from localStorage
        function loadFilterState() {
            try {
                return localStorage.getItem('techStaffFilterExpanded') === 'true';
            } catch (e) {
                return false;
            }
        }
        
        // Save filter state to localStorage
        function saveFilterState(expanded) {
            try {
                localStorage.setItem('techStaffFilterExpanded', expanded ? 'true' : 'false');
            } catch (e) {
                // Ignore
            }
        }
        
        // Khi trang load lại: giữ trạng thái cũ
        document.addEventListener('DOMContentLoaded', function() {
            var content = document.getElementById('filterContent');
            var icon = document.getElementById('filterToggleIcon');
            if (loadFilterState()) {
                content.classList.add('show');
                icon.classList.add('rotated');
            } else {
                content.classList.remove('show');
                icon.classList.remove('rotated');
            }
        });
        
        // Update filter state when toggled
        var originalToggleFilters = toggleFilters;
        toggleFilters = function() {
            originalToggleFilters();
            var content = document.getElementById('filterContent');
            saveFilterState(content.classList.contains('show'));
        };

        $(document).ready(function() {
            // Kiểm tra và hủy DataTable cũ nếu đã tồn tại
            if ($.fn.DataTable.isDataTable('#tasksTable')) {
                $('#tasksTable').DataTable().destroy();
            }
            
            tasksTable = $('#tasksTable').DataTable({
                "language": { "url": "//cdn.datatables.net/plug-ins/1.10.25/i18n/Vietnamese.json" },
                "processing": false,
                "serverSide": false,
                "paging": false,
                "searching": false,
                "dom": 'lrt',
                "ordering": true,
                "info": false,
                "autoWidth": false,
                "responsive": true,
                "order": [[0, "desc"]],
                "retrieve": true
            });
            // Safety: remove filter container if any existed from previous inits
            $('#tasksTable_filter').remove();
        });
    </script>
</body>
</html>
