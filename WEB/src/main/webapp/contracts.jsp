<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Set" %>
<%
    // Kiểm tra đăng nhập
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    String userRole = (String) session.getAttribute("userRole");
    String currentStatus = request.getParameter("status");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Kiểm tra quyền: chỉ người có quyền manage_contracts mới truy cập được
    @SuppressWarnings("unchecked")
    Set<String> userPermissions = (Set<String>) session.getAttribute("userPermissions");
    if (userPermissions == null || !userPermissions.contains("manage_contracts")) {
        response.sendRedirect(request.getContextPath() + "/error/403.jsp");
        return;
    }
%>
<%!
    // Hàm dịch trạng thái sang tiếng Việt
    String translateStatus(String status) {
        if (status == null) return "-";
        if ("draft".equals(status)) return "Nháp";
        if ("active".equals(status)) return "Hiệu Lực";
        if ("terminated".equals(status)) return "Chấm Dứt";
        if ("deleted".equals(status)) return "Đã xóa";
        return status;
    }
    
    // Hàm format số tiền với dấu chấm ngăn cách hàng nghìn (không có dấu thập phân)
    String formatCurrencyValue(String value) {
        if (value == null || value.trim().isEmpty() || "-".equals(value)) {
            return "-";
        }
        try {
            // Parse số, bỏ dấu thập phân
            double numValue = Double.parseDouble(value);
            long longValue = (long) numValue;
            
            // Format với dấu chấm ngăn cách hàng nghìn (theo chuẩn Việt Nam)
            java.text.DecimalFormatSymbols symbols = new java.text.DecimalFormatSymbols(java.util.Locale.getDefault());
            symbols.setGroupingSeparator('.');
            java.text.DecimalFormat formatter = new java.text.DecimalFormat("#,###", symbols);
            return formatter.format(longValue);
        } catch (NumberFormatException e) {
            return value; // Trả về giá trị gốc nếu không parse được
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng điều khiển | Quản lý hợp đồng</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <link href="css/datatables/dataTables.bootstrap.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css" rel="stylesheet" type="text/css" />
    <link href='http://fonts.googleapis.com/css?family=Lato' rel='stylesheet' type='text/css'>
    <style>
        .has-error {
            border-color: #a94442 !important;
            box-shadow: inset 0 1px 1px rgba(0,0,0,.075), 0 0 6px #ce8483 !important;
        }
        .help-block.text-danger {
            margin-top: 5px;
            font-size: 12px;
        }
        .text-danger {
            color: #a94442 !important;
        }
        .form-group label .text-danger {
            font-weight: bold;
        }
        
        /* Style cho thông báo trong modal */
        #contractErrorAlert {
            border-radius: 6px;
            font-weight: 500;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        #contractErrorAlert.alert-success {
            background-color: #d4edda;
            border-color: #c3e6cb;
            color: #155724;
        }
        #contractErrorAlert.alert-danger {
            background-color: #f8d7da;
            border-color: #f5c6cb;
            color: #721c24;
        }
        #contractErrorAlert.alert-warning {
            background-color: #fff3cd;
            border-color: #ffeaa7;
            color: #856404;
        }
        #contractErrorAlert.alert-info {
            background-color: #d1ecf1;
            border-color: #bee5eb;
            color: #0c5460;
        }
        /* Đảm bảo dropdown khách hàng hiển thị đúng trong modal (fix chồng lấn/z-index) */
        #contractModal { z-index: 1051 !important; }
        #contractModal .modal-content { overflow: visible !important; }
        #contractModal .modal-dialog { overflow: visible !important; z-index: 1051 !important; }
        #contractModal .modal-body { overflow: visible !important; }
        #contractModal .form-group { overflow: visible !important; position: relative; }
        /* Fix riêng cho form-group chứa select customerId - target chính xác form-group có label "Khách hàng" */
        #contractModal .form-group:has(label[for="customerId"]) {
            overflow: visible !important;
            position: relative;
            z-index: 9998;
        }
        /* Fallback cho trình duyệt không hỗ trợ :has() - target form-group thứ 2 trong col-md-6 đầu tiên */
        #contractModal .col-md-6:first-child .form-group:nth-child(2) {
            overflow: visible !important;
            position: relative;
            z-index: 9998;
        }
        #contractModal select#customerId { 
            position: relative; 
            z-index: 9999 !important; 
            background-color: #ffffff !important; 
            color: #333333 !important; 
        }
        /* Đảm bảo dropdown options hiển thị trên modal backdrop khi focus */
        #contractModal select#customerId:focus {
            z-index: 10000 !important;
            position: relative;
        }
        /* Đảm bảo select không bị che khi đang mở */
        #contractModal select#customerId option {
            background-color: #ffffff !important;
            color: #333333 !important;
        }
        /* Khi select được mở, tạm thời làm backdrop trong suốt và không tương tác */
        body.modal-open.selecting-customer .modal-backdrop {
            opacity: 0 !important;
            pointer-events: none !important;
        }
        
        /* Styles for filter section */
        .filter-section {
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 15px;
            margin-bottom: 15px;
        }

        /* Thùng rác: chống tràn chữ, dùng dấu … cho cột dài */
        #deletedContractsModal .table { table-layout: fixed; width: 100%; }
        #deletedContractsModal th, #deletedContractsModal td { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        #deletedContractsModal .truncate { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: block; }
        .filter-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            cursor: pointer;
        }
        .filter-header h4 {
            margin: 0;
            font-size: 14px;
            font-weight: 600;
            color: #495057;
        }
        .filter-header i {
            transition: transform 0.3s;
        }
        .filter-header i.rotated {
            transform: rotate(180deg);
        }
        .filter-content {
            display: none;
        }
        .filter-content.show {
            display: block;
        }
        .filter-row {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 10px;
        }
        .filter-row:last-child {
            margin-bottom: 0;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            min-width: 140px;
            flex: 1 1 auto;
        }
        .filter-group.small {
            min-width: 100px;
            flex: 0 0 auto;
        }
        .filter-group label {
            font-weight: 600;
            margin-bottom: 4px;
            font-size: 12px;
            color: #495057;
        }
        .filter-group .form-control {
            height: 32px;
            font-size: 12px;
            padding: 6px 10px;
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
        
        @media (max-width: 1200px) {
            .filter-group {
                min-width: 120px;
            }
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
    </style>
</head>
<body class="skin-black">
    <header class="header">
        <a href="customersupport.jsp" class="logo">
            Hỗ Trợ Khách Hàng
        </a>
        <nav class="navbar navbar-static-top" role="navigation">
            <a href="#" class="navbar-btn sidebar-toggle" data-toggle="offcanvas" role="button">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </a>
            <div class="navbar-right">
                <ul class="nav navbar-nav">
                    <li class="dropdown user user-menu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="fa fa-user"></i>
                            <span><%= (session.getAttribute("fullName") != null && !((String)session.getAttribute("fullName")).isEmpty()) ? (String)session.getAttribute("fullName") : username %> <i class="caret"></i></span>
                        </a>
                        <ul class="dropdown-menu dropdown-custom dropdown-menu-right">
                            <li class="dropdown-header text-center">Tài khoản</li>
                            <li>
                                <a href="profile.jsp"><i class="fa fa-user fa-fw pull-right"></i> Hồ sơ</a>
                                <a href="settings.jsp"><i class="fa fa-cog fa-fw pull-right"></i> Cài đặt</a>
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
            <section class="content">
                <div class="row">
                    <div class="col-xs-12">
                        <div class="panel">
                            <header class="panel-heading">
                                <h3>Quản lý hợp đồng</h3>
                                <div class="panel-tools">
                                    <% if (!"deleted".equals(currentStatus)) { %>
                                    <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#contractModal">
                                        <i class="fa fa-plus"></i> Thêm hợp đồng mới
                                    </button>
                                    <% } %>
                                    <button class="btn btn-warning btn-sm" onclick="showDeletedContracts()" style="margin-left: 5px;">
                                        <i class="fa fa-trash"></i> Thùng rác
                                    </button>
                                    <% if ("deleted".equals(currentStatus)) { %>
                                    <a href="contracts.jsp" class="btn btn-success btn-sm" style="margin-left: 5px;">
                                        <i class="fa fa-arrow-left"></i> Quay lại danh sách chính
                                    </a>
                                    <% } %>
                                </div>
                            </header>
                            <div class="panel-body table-responsive">
                                <%
                                    if ("deleted".equals(currentStatus)) {
                                %>
                                <div class="alert alert-warning" style="margin-bottom: 15px;">
                                    <i class="fa fa-exclamation-triangle"></i> 
                                    <strong>Đang xem hợp đồng đã bị xóa</strong> - Các hợp đồng này đã được chuyển vào thùng rác. 
                                    Bạn có thể khôi phục hoặc xóa vĩnh viễn chúng.
                                </div>
                                <% } %>
                                <div class="filter-section">
                                    <div class="filter-header" onclick="toggleFilters()">
                                        <h4><i class="fa fa-filter"></i> Bộ lọc</h4>
                                        <i class="fa fa-chevron-down" id="filterToggleIcon"></i>
                                    </div>
                                    <div class="filter-content" id="filterContent">
                                        <form method="get" action="contracts.jsp">
                                            <div class="filter-row">
                                                <div class="filter-group">
                                                    <label for="statusFilter">Trạng thái</label>
                                                    <select class="form-control" id="statusFilter" name="status">
                                                        <option value="" <%= request.getParameter("status") == null || "".equals(request.getParameter("status")) ? "selected" : "" %>>Tất cả</option>
                                                        <option value="draft" <%= "draft".equals(request.getParameter("status")) ? "selected" : "" %>>Nháp</option>
                                                        <option value="active" <%= "active".equals(request.getParameter("status")) ? "selected" : "" %>>Hiệu Lực</option>
                                                        <option value="terminated" <%= "terminated".equals(request.getParameter("status")) ? "selected" : "" %>>Chấm Dứt</option>
                                                        <option value="deleted" <%= "deleted".equals(request.getParameter("status")) ? "selected" : "" %>>Đã xóa</option>
                                                    </select>
                                                </div>
                                                <div class="filter-group">
                                                    <label for="search">Tìm kiếm</label>
                                                    <input type="text" class="form-control" id="search" name="q" placeholder="ID, số HĐ, tên KH" value="<%= request.getParameter("q") != null ? request.getParameter("q") : "" %>">
                                                </div>
                                            </div>
                                            <div class="filter-row">
                                                <div class="filter-group">
                                                    <label for="signedFrom">Ngày ký từ</label>
                                                    <input type="date" class="form-control" id="signedFrom" name="signedFrom" value="<%= request.getParameter("signedFrom") != null ? request.getParameter("signedFrom") : "" %>">
                                                </div>
                                                <div class="filter-group">
                                                    <label for="signedTo">Đến</label>
                                                    <input type="date" class="form-control" id="signedTo" name="signedTo" value="<%= request.getParameter("signedTo") != null ? request.getParameter("signedTo") : "" %>">
                                                </div>
                                            </div>
                                            <div class="filter-row">
                                                <div class="filter-group small">
                                                    <label for="pageSize">Hiển thị</label>
                                                    <select class="form-control" id="pageSize" name="size" onchange="this.form.submit()">
                                                        <%
                                                            int _sz = 10;
                                                            try { String sp = request.getParameter("size"); if (sp != null) _sz = Integer.parseInt(sp); } catch (Exception ignored) {}
                                                        %>
                                                        <option value="10" <%= _sz == 10 ? "selected" : "" %>>10</option>
                                                        <option value="25" <%= _sz == 25 ? "selected" : "" %>>25</option>
                                                        <option value="50" <%= _sz == 50 ? "selected" : "" %>>50</option>
                                                        <option value="100" <%= _sz == 100 ? "selected" : "" %>>100</option>
                                                    </select>
                                                </div>
                                                <div class="filter-actions">
                                                    <button type="submit" class="btn btn-primary">
                                                        <i class="fa fa-filter"></i> Lọc
                                                    </button>
                                                    <a href="contracts.jsp" class="btn btn-default">
                                                        <i class="fa fa-times"></i> Xóa lọc
                                                    </a>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                                <table class="table table-hover" id="contractsTable">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>ID KH</th>
                                            <th>Số hợp đồng</th>
                                            <th>Tên khách hàng</th>
                                            <th>Số điện thoại</th>
                                            <th>Loại</th>
                                            <th>Tiêu đề</th>
                                            <th>Ngày ký</th>
                                            <th>Kết thúc</th>
                                            <th>Giá trị</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="contractsTableBody">
                                        <%
                                            com.hlgenerator.dao.ContractDAO dao = new com.hlgenerator.dao.ContractDAO();
                                            String pageParam = request.getParameter("page");
                                            String sizeParam = request.getParameter("size");
                                            int currentPage = 1;
                                            int pageSize = 10;
                                            try { if (pageParam != null) currentPage = Integer.parseInt(pageParam); } catch (Exception ignored) {}
                                            try { if (sizeParam != null) pageSize = Integer.parseInt(sizeParam); } catch (Exception ignored) {}
                                            if (currentPage < 1) currentPage = 1;
                                            if (pageSize < 1) pageSize = 10;
                                            String status = request.getParameter("status");
                                            String contractType = null; // Luôn là 'Bán hàng', không cần filter
                                            String search = request.getParameter("q");
                                            java.sql.Date signedFrom = null, signedTo = null, endFrom = null, endTo = null;
                                            try { String v = request.getParameter("signedFrom"); if (v != null && !v.isEmpty()) signedFrom = java.sql.Date.valueOf(v); } catch (Exception ignored) {}
                                            try { String v = request.getParameter("signedTo"); if (v != null && !v.isEmpty()) signedTo = java.sql.Date.valueOf(v); } catch (Exception ignored) {}
                                            try { String v = request.getParameter("endFrom"); if (v != null && !v.isEmpty()) endFrom = java.sql.Date.valueOf(v); } catch (Exception ignored) {}
                                            try { String v = request.getParameter("endTo"); if (v != null && !v.isEmpty()) endTo = java.sql.Date.valueOf(v); } catch (Exception ignored) {}
                                            String sortBy = request.getParameter("sortBy");
                                            String sortDir = request.getParameter("sortDir");
                                            int total = dao.countContractsFiltered(status, contractType, search, signedFrom, signedTo, endFrom, endTo);
                                            int totalPages = (int) Math.ceil(total / (double) pageSize);
                                            if (totalPages == 0) totalPages = 1;
                                            if (currentPage > totalPages) currentPage = totalPages;
                                            java.util.List<com.hlgenerator.model.Contract> contracts = dao.getContractsPageFiltered(currentPage, pageSize, status, contractType, search, signedFrom, signedTo, endFrom, endTo, sortBy, sortDir);
                                            for (com.hlgenerator.model.Contract c : contracts) {
                                        %>
                                        <tr>
                                            <td><%= c.getId() %></td>
                                            <td><%= c.getCustomerId() %></td>
                                            <td><%= c.getContractNumber() %></td>
                                            <td><%= c.getCustomerName() != null ? c.getCustomerName() : "-" %></td>
                                            <td><%= c.getCustomerPhone() != null ? c.getCustomerPhone() : "-" %></td>
                                            <td><%= c.getContractType() != null ? c.getContractType() : "-" %></td>
                                            <td><%= c.getTitle() != null ? c.getTitle() : "-" %></td>
                                            <td><%= c.getSignedDate() != null ? c.getSignedDate() : "-" %></td>
                                            <td><%= "terminated".equals(c.getStatus()) ? (c.getEndDate() != null ? c.getEndDate() : "-") : "Vô thời hạn" %></td>
                                            <td><%= formatCurrencyValue(c.getContractValue() != null ? c.getContractValue().toString() : "-") %></td>
                                            <td><%= translateStatus(c.getStatus()) %></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="viewContract('<%= c.getId() %>')"><i class="fa fa-eye"></i> Xem</button>
                                                <% if (!"deleted".equals(c.getStatus())) { %>
                                                    <button class="btn btn-warning btn-xs" onclick="editContract('<%= c.getId() %>')"><i class="fa fa-edit"></i> Sửa</button>
                                                    <button class="btn btn-danger btn-xs" onclick="deleteContract('<%= c.getId() %>')"><i class="fa fa-trash"></i> Xóa</button>
                                                <% } else { %>
                                                    <button class="btn btn-success btn-xs" onclick="restoreContract('<%= c.getId() %>')"><i class="fa fa-undo"></i> Khôi phục</button>
                                                    <button class="btn btn-danger btn-xs" onclick="permanentlyDeleteContract('<%= c.getId() %>')"><i class="fa fa-trash"></i> Xóa vĩnh viễn</button>
                                                <% } %>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>

                                <div class="row" style="margin-top: 10px;">
                                    <div class="col-md-6">
                                        <div id="contractsPaginationInfo" class="text-muted" style="line-height: 34px;">
                                            <%
                                                int _startIdx = (currentPage - 1) * pageSize + 1;
                                                int _endIdx = Math.min(currentPage * pageSize, total);
                                                if (total == 0) { _startIdx = 0; _endIdx = 0; }
                                            %>
                                            Hiển thị <%= _startIdx %> - <%= _endIdx %> của <%= total %> hợp đồng
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <nav aria-label="Phân trang hợp đồng" class="pull-right">
                                            <ul class="pagination pagination-sm" style="margin: 0;">
                                                <%
                                                    // Xây base query giữ nguyên filter
                                                    java.util.List<String> _p = new java.util.ArrayList<String>();
                                                    try { String v = request.getParameter("status"); if (v != null && !v.isEmpty()) _p.add("status=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    try { String v = request.getParameter("q"); if (v != null && !v.isEmpty()) _p.add("q=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    try { String v = request.getParameter("signedFrom"); if (v != null && !v.isEmpty()) _p.add("signedFrom=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    try { String v = request.getParameter("signedTo"); if (v != null && !v.isEmpty()) _p.add("signedTo=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    try { String v = request.getParameter("endFrom"); if (v != null && !v.isEmpty()) _p.add("endFrom=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    try { String v = request.getParameter("endTo"); if (v != null && !v.isEmpty()) _p.add("endTo=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    try { String v = request.getParameter("sortBy"); if (v != null && !v.isEmpty()) _p.add("sortBy=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    try { String v = request.getParameter("sortDir"); if (v != null && !v.isEmpty()) _p.add("sortDir=" + java.net.URLEncoder.encode(v, "UTF-8")); } catch (Exception ignored) {}
                                                    _p.add("size=" + pageSize);
                                                    String _base = "contracts.jsp" + (_p.isEmpty() ? "" : ("?" + String.join("&", _p)));
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


    <!-- Modal thêm/sửa hợp đồng -->
    <div class="modal fade" id="contractModal" tabindex="-1" role="dialog" aria-labelledby="contractModalLabel">
        <div class="modal-dialog modal-lg" role="document" style="width: 95%; max-width: 1400px;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="contractModalLabel">Thêm hợp đồng mới</h4>
                </div>
                <div class="modal-body">
                    <!-- Vùng hiển thị thông báo lỗi -->
                    <div id="contractErrorAlert" class="alert alert-danger alert-dismissible" style="display: none; margin-bottom: 20px;">
                        <button type="button" class="close" onclick="hideModalAlert()" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <span id="contractErrorText"></span>
                    </div>
                    
                    <form id="contractForm">
                        <input type="hidden" id="contractId">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="contractNumber">Số hợp đồng <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="contractNumber" required readonly style="background-color: #f5f5f5; cursor: not-allowed;">
                                    <div class="help-block text-danger" id="contractNumberError" style="display: none;"></div>
                                    <small class="text-muted">Số hợp đồng sẽ được hệ thống sinh tự động</small>
                                </div>
                                <div class="form-group">
                                    <label for="customerId">Khách hàng <span class="text-danger">*</span></label>
                                    <select class="form-control" id="customerId" required>
                                        <option value="">Chọn khách hàng...</option>
                                    </select>
                                    <div class="help-block text-danger" id="customerIdError" style="display: none;"></div>
                                </div>
                                <div class="form-group">
                                    <label for="contractType">Loại hợp đồng</label>
                                    <input type="text" class="form-control" id="contractType" value="Bán hàng" readonly style="background-color: #f5f5f5; cursor: not-allowed;">
                                </div>
                                <div class="form-group">
                                    <label for="title">Tiêu đề <span id="titleRequired" class="text-danger" style="display: none;">*</span></label>
                                    <input type="text" class="form-control" id="title" placeholder="Nhập tiêu đề hợp đồng" maxlength="150">
                                    <small class="text-muted"><span id="titleCount">0</span>/150</small>
                                    <span class="help-block text-danger" id="titleError" style="display: none;"></span>
                                </div>
                                <div class="form-group">
                                    <label for="terms">Điều khoản <span id="termsRequired" class="text-danger" style="display: none;">*</span></label>
                                    <textarea class="form-control" id="terms" rows="6" placeholder="Nhập các điều khoản của hợp đồng (xuống dòng để tách ý)" maxlength="2000" style="resize: vertical; line-height: 1.5;"></textarea>
                                    <small class="text-muted">Gõ Enter để xuống dòng • <span id="termsCount">0</span>/2000</small>
                                    <span class="help-block text-danger" id="termsError" style="display: none;"></span>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Thời hạn</label>
                                    <input type="text" class="form-control" id="contractDuration" value="Vô thời hạn" readonly style="background-color: #f5f5f5; cursor: not-allowed;">
                                </div>
                                <div class="form-group">
                                    <label for="signedDate">Ngày ký <span class="text-danger" id="signedDateRequired">*</span></label>
                                    <input type="date" class="form-control" id="signedDate">
                                    <div class="help-block text-danger" id="signedDateError" style="display: none;"></div>
                                    <small class="text-muted" id="signedDateHint">Bắt buộc khi hợp đồng không phải "Nháp"</small>
                                </div>
                                <!-- endDate: chỉ hiển thị khi status = "terminated" -->
                                <div class="form-group" id="endDateGroup" style="display: none;">
                                    <label for="endDate">Ngày chấm dứt <span class="text-danger">*</span></label>
                                    <input type="date" class="form-control" id="endDate">
                                    <div class="help-block text-danger" id="endDateError" style="display: none;"></div>
                                    <small class="text-muted">Ngày chấm dứt phải sau hoặc bằng ngày ký</small>
                                </div>
                                <div class="form-group">
                                    <label for="contractValue">Giá trị hợp đồng</label>
                                    <div class="input-group">
                                        <input type="text" class="form-control" id="contractValue" placeholder="0" style="text-align: right;">
                                        <span class="input-group-addon">VNĐ</span>
                                        <span class="input-group-btn">
                                            <button class="btn btn-info" type="button" onclick="updateContractValueFromProducts()" title="Tự động cập nhật từ tổng sản phẩm">
                                                <i class="fa fa-calculator"></i> Tự động
                                            </button>
                                        </span>
                                    </div>
                                    <div class="help-block text-danger" id="contractValueError" style="display: none;"></div>
                                    <div class="alert alert-warning" id="contractValueWarning" style="display: none; margin-top: 5px; padding: 8px; font-size: 12px;">
                                        <i class="fa fa-exclamation-triangle"></i> 
                                        <strong>Lưu ý:</strong> Giá trị hợp đồng khác với tổng giá trị sản phẩm. 
                                        <span id="contractValueDiff"></span>
                                    </div>
                                    <small class="text-muted">Nhấn "Tự động" để cập nhật từ tổng giá trị sản phẩm. Có thể nhập thủ công nếu có chiết khấu/phí khác.</small>
                                </div>
                                <div class="form-group">
                                    <label for="status">Trạng thái</label>
                                    <select id="status" class="form-control">
                                        <option value="draft">Nháp</option>
                                        <option value="active">Hiệu Lực</option>
                                        <option value="terminated">Chấm Dứt</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Phần quản lý sản phẩm trong hợp đồng -->
                        <hr>
                        <div class="row">
                            <div class="col-md-8">
                                <h5><i class="fa fa-list"></i> Sản phẩm trong hợp đồng</h5>
                            </div>
                            <div class="col-md-4 text-right">
                                <button class="btn btn-primary btn-sm" onclick="showAddProductForm()">
                                    <i class="fa fa-plus"></i> Thêm sản phẩm
                                </button>
                            </div>
                        </div>
                        
                        <!-- Bảng sản phẩm -->
                        <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
                            <table class="table table-striped table-hover" id="contractProductsTable">
                                <thead class="thead-dark" style="position: sticky; top: 0; z-index: 10;">
                                    <tr>
                                        <th width="6%" class="text-center">STT</th>
                                        <th width="10%" class="text-center">Product ID</th>
                                        <th width="18%" class="text-center">Mô tả</th>
                                        <th width="8%" class="text-center">Số lượng</th>
                                        <th width="10%" class="text-center">Đơn giá</th>
                                        <th width="10%" class="text-center">Thành tiền</th>
                                        <th width="7%" class="text-center">Bảo hành</th>
                                        <th width="8%" class="text-center">Ghi chú</th>
                                        <th width="12%" class="text-center">Trạng thái bàn giao</th>
                                        <th width="8%" class="text-center">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody id="contractProductsTableBody">
                                    <tr id="noProductsRow">
                                        <td colspan="10" class="text-center text-muted">
                                            <i class="fa fa-info-circle"></i> Chưa có sản phẩm nào. Nhấn "Thêm sản phẩm" để bắt đầu.
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- Tổng tiền -->
                        <div class="row" style="margin-top: 15px;">
                            <div class="col-md-8"></div>
                            <div class="col-md-4">
                                <div class="alert alert-info" style="margin-bottom: 0;">
                                    <strong>Tổng giá trị hợp đồng: <span id="totalContractValue" class="text-primary" style="font-size: 16px;">0 VNĐ</span></strong>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Form thêm/sửa sản phẩm (ẩn mặc định) -->
                        <div id="productFormContainer" style="display: none; margin-top: 20px;">
                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h5 class="panel-title">
                                        <i class="fa fa-edit"></i> 
                                        <span id="productFormTitle">Thêm sản phẩm mới</span>
                                        <button type="button" class="close pull-right" onclick="hideAddProductForm()" style="margin-top: -5px; color: white;">
                                            <span style="font-size: 18px;">&times;</span>
                                        </button>
                                    </h5>
                                </div>
                                <div class="panel-body" style="padding: 20px;">
                                    <form id="productForm">
                                        <input type="hidden" id="editingProductIndex" value="">
                                        
                                        <!-- Dòng 1: Chọn sản phẩm -->
                                        <div class="row">
                                            <div class="col-md-6">
                                                <label><strong>Sản phẩm <span class="text-danger">*</span></strong></label>
                                                <select class="form-control" id="newProductId" required style="height: 40px; font-size: 14px;">
                                                    <option value="">Chọn sản phẩm...</option>
                                                </select>
                                            </div>
                                            <div class="col-md-3">
                                                <label><strong>Số lượng <span class="text-danger">*</span></strong></label>
                                                <input type="number" step="0.01" min="0" class="form-control" id="newQuantity" placeholder="Nhập số lượng" required style="height: 40px; font-size: 14px;">
                                            </div>
                                            <div class="col-md-3">
                                                <label><strong>Bảo hành (tháng)</strong></label>
                                                <input type="number" min="0" class="form-control" id="newWarrantyMonths" placeholder="12" readonly style="height: 40px; font-size: 14px; background-color: #f5f5f5;">
                                            </div>
                                        </div>
                                        <div class="row" style="margin-top: 8px;">
                                            <div class="col-md-6">
                                                <small id="stockInfo" class="text-muted"></small>
                                            </div>
                                        </div>
                                        
                                        <!-- Dòng 2: Thông tin sản phẩm (tự động điền) -->
                                        <div class="row" style="margin-top: 15px;">
                                            <div class="col-md-6">
                                                <label><strong>Mô tả sản phẩm</strong></label>
                                                <textarea class="form-control" id="newDescription" rows="2" placeholder="Mô tả sẽ tự động điền khi chọn sản phẩm" readonly style="font-size: 14px;"></textarea>
                                            </div>
                                            <div class="col-md-3">
                                                <label><strong>Đơn giá (VNĐ)</strong></label>
                                                <input type="text" class="form-control" id="newUnitPrice" placeholder="Giá sẽ tự động điền" readonly style="height: 40px; font-size: 14px; background-color: #f5f5f5;">
                                            </div>
                                            <div class="col-md-3">
                                                <label><strong>Thành tiền (VNĐ)</strong></label>
                                                <input type="text" class="form-control" id="newLineTotal" placeholder="Tự động tính" readonly style="height: 40px; font-size: 14px; background-color: #e8f5e8; font-weight: bold;">
                                            </div>
                                        </div>
                                        
                                        <!-- Dòng 3: Ghi chú và nút -->
                                        <div class="row" style="margin-top: 15px;">
                                            <div class="col-md-8">
                                                <label><strong>Ghi chú</strong></label>
                                                <input type="text" class="form-control" id="newNotes" placeholder="Ghi chú thêm về sản phẩm này..." style="height: 40px; font-size: 14px;">
                                            </div>
                                            <div class="col-md-4">
                                                <label>&nbsp;</label>
                                                <div style="margin-top: 5px;">
                                                    <button type="button" class="btn btn-success btn-lg" onclick="addProductToContract()" style="margin-right: 10px;">
                                                        <i class="fa fa-save"></i> Lưu sản phẩm
                                                    </button>
                                                    <button type="button" class="btn btn-default btn-lg" onclick="hideAddProductForm()">
                                                        <i class="fa fa-times"></i> Hủy
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="saveContract()">Lưu</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal xác nhận đẹp -->
    <div class="modal fade" id="confirmModal" tabindex="-1" role="dialog" aria-labelledby="confirmModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header" style="background-color: #f0ad4e; color: white;">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="color: white; opacity: 0.8;">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="confirmModalLabel">
                        <i class="fa fa-exclamation-triangle"></i> Xác nhận
                    </h4>
                </div>
                <div class="modal-body" id="confirmModalBody" style="padding: 25px; font-size: 14px; line-height: 1.8;">
                    <!-- Nội dung sẽ được điền bằng JavaScript -->
                </div>
                <div class="modal-footer" style="padding: 15px 25px;">
                    <button type="button" class="btn btn-default" id="confirmModalCancel" data-dismiss="modal">
                        <i class="fa fa-times"></i> Hủy
                    </button>
                    <button type="button" class="btn btn-primary" id="confirmModalOk">
                        <i class="fa fa-check"></i> Xác nhận
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal xem chi tiết -->
    <div class="modal fade" id="contractDetailModal" tabindex="-1" role="dialog" aria-labelledby="contractDetailModalLabel">
        <div class="modal-dialog modal-lg" role="document" style="width: 95%; max-width: 1200px;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="contractDetailModalLabel">Chi tiết hợp đồng</h4>
                </div>
                <div class="modal-body" id="contractDetail" style="max-height: 70vh; overflow: auto; word-break: break-word; overflow-wrap: anywhere;"></div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal thùng rác -->
    <div class="modal fade" id="deletedContractsModal" tabindex="-1" role="dialog" aria-labelledby="deletedContractsModalLabel">
        <div class="modal-dialog modal-xl" role="document" style="width: 95%; max-width: 1400px;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="deletedContractsModalLabel">Thùng rác - Hợp đồng đã xóa</h4>
                </div>
                <div class="modal-body">
                    <!-- Form tìm kiếm và sắp xếp -->
                    <div class="row" style="margin-bottom: 15px;">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label for="deletedSearch">Tìm kiếm:</label>
                                <input type="text" class="form-control" id="deletedSearch" placeholder="ID, số HĐ, tiêu đề...">
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group">
                                <label for="deletedSortBy">Sắp xếp theo:</label>
                                <select class="form-control" id="deletedSortBy">
                                    <option value="deleted_at">Ngày xóa</option>
                                    <option value="id">ID hợp đồng</option>
                                    <option value="contract_number">Số hợp đồng</option>
                                    <option value="title">Tiêu đề</option>
                                    <option value="deleted_by_name">Người xóa</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <label for="deletedSortDir">Thứ tự:</label>
                                <select class="form-control" id="deletedSortDir">
                                    <option value="desc">Mới nhất</option>
                                    <option value="asc">Cũ nhất</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <label for="deletedPageSize">Số dòng:</label>
                                <select class="form-control" id="deletedPageSize">
                                    <option value="10">10</option>
                                    <option value="25">25</option>
                                    <option value="50">50</option>
                                    <option value="100">100</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-1">
                            <div class="form-group">
                                <label>&nbsp;</label>
                                <button class="btn btn-primary form-control" onclick="loadDeletedContracts()">
                                    <i class="fa fa-search"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Bảng dữ liệu -->
                    <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                        <table class="table table-hover" id="deletedContractsTable">
                            <thead class="thead-dark" style="position: sticky; top: 0; z-index: 10;">
                                <tr>
                                    <th width="8%">ID</th>
                                    <th width="8%">ID KH</th>
                                    <th width="14%">Số hợp đồng</th>
                                    <th width="14%">Tên khách hàng</th>
                                    <th width="18%">Tiêu đề</th>
                                    <th width="12%">Người xóa</th>
                                    <th width="11%">Ngày xóa</th>
                                    <th width="15%">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody id="deletedContractsTableBody">
                                <tr>
                                    <td colspan="8" class="text-center text-muted">
                                        <i class="fa fa-spinner fa-spin"></i> Đang tải...
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Phân trang -->
                    <div class="row" style="margin-top: 15px;">
                        <div class="col-md-12">
                            <div class="row">
                                <div class="col-md-6">
                                    <div id="deletedPaginationInfo" class="text-muted" style="line-height: 34px;">
                                        Hiển thị 0 - 0 của 0 bản ghi
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <nav aria-label="Phân trang thùng rác" class="pull-right">
                                        <ul class="pagination pagination-sm" id="deletedPagination" style="margin: 0;">
                                            <!-- Sẽ được tạo động bằng JavaScript -->
                                        </ul>
                                    </nav>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>


    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
    <script src="js/jquery.min.js" type="text/javascript"></script>
    <script src="js/jquery-ui-1.10.3.min.js" type="text/javascript"></script>
    <script src="js/bootstrap.min.js" type="text/javascript"></script>
    <script src="js/plugins/datatables/jquery.dataTables.js" type="text/javascript"></script>
    <script src="js/plugins/datatables/dataTables.bootstrap.js" type="text/javascript"></script>
    <script src="js/Director/app.js" type="text/javascript"></script>

    <script type="text/javascript">
        var contractsTable;
        var currentEditingId = null;
        var isEditingMode = false; // Biến để kiểm tra đang sửa hay thêm mới

        var contractProducts = []; // Mảng lưu sản phẩm tạm thời
        
        // Hàm dịch trạng thái sang tiếng Việt
        function translateStatus(status) {
            if (!status) return '-';
            var statusMap = {
                'draft': 'Nháp',
                'active': 'Hiệu Lực',
                'terminated': 'Chấm Dứt',
                'deleted': 'Đã xóa'
            };
            return statusMap[status] || status;
        }
        
        // --- ĐOẠN MỚI: Lưu và khôi phục trạng thái bộ lọc ---
        function saveFilterState(isExpanded) {
            localStorage.setItem('contractsFilterExpanded', isExpanded ? '1' : '0');
        }
        function loadFilterState() {
            return localStorage.getItem('contractsFilterExpanded') === '1';
        }
        // Gọi hàm này luôn khi chuyển trạng thái filter (trong toggleFilters)
        function toggleFilters() {
            var content = document.getElementById('filterContent');
            var icon = document.getElementById('filterToggleIcon');
            var expanded;
            if (content.classList.contains('show')) {
                content.classList.remove('show');
                icon.classList.remove('rotated');
                expanded = false;
            } else {
                content.classList.add('show');
                icon.classList.add('rotated');
                expanded = true;
            }
            saveFilterState(expanded);
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

        $(document).ready(function() {
            // Kiểm tra và hủy DataTable cũ nếu đã tồn tại
            if ($.fn.DataTable.isDataTable('#contractsTable')) {
                $('#contractsTable').DataTable().destroy();
            }
            
            contractsTable = $('#contractsTable').DataTable({
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
                "columnDefs": [{ "targets": [10], "orderable": false, "searchable": false }],
                "retrieve": true
            });
            // Safety: remove filter container if any existed from previous inits
            $('#contractsTable_filter').remove();
            
            // Load danh sách khách hàng
            loadCustomers();

        });

        function loadCustomers() {
            console.log('Loading customers...');
            $.get('api/contracts', { action: 'customers' }, function(resp) {
                console.log('Customers response:', resp);
                if (resp.success) {
                    var options = '<option value="">Chọn khách hàng...</option>';
                    if (resp.data && resp.data.length > 0) {
                        resp.data.forEach(function(customer) {
                            options += '<option value="' + customer.id + '">' + 
                                      customer.customerCode + ' - ' + customer.companyName + 
                                      ' (' + customer.contactPerson + ')</option>';
                        });
                    } else {
                        options += '<option value="" disabled>Không có khách hàng nào</option>';
                    }
                    $('#customerId').html(options);
                    console.log('Customers loaded successfully');
                } else {
                    console.error('Error loading customers:', resp.message);
                    $('#customerId').html('<option value="" disabled>Lỗi tải khách hàng: ' + (resp.message || 'Unknown error') + '</option>');
                }
            }, 'json').fail(function(xhr, status, error) {
                console.error('AJAX error loading customers:', status, error);
                $('#customerId').html('<option value="" disabled>Lỗi kết nối: ' + error + '</option>');
            });
        }

        function loadProducts() {
            console.log('Loading products...');
            $.get('api/contracts', { action: 'products' }, function(resp) {
                console.log('Products response:', resp);
                if (resp.success) {
                    var options = '<option value="">Chọn sản phẩm...</option>';
                    if (resp.data && resp.data.length > 0) {
                        resp.data.forEach(function(product) {
                            options += '<option value="' + product.id + '" data-description="' + (product.description || '') + '" data-unitprice="' + product.unitPrice + '" data-warranty="' + (product.warrantyMonths != null ? product.warrantyMonths : '') + '" data-quantity="' + (product.quantity != null ? product.quantity : 0) + '">' + 
                                      product.productCode + ' - ' + product.productName + 
                                      ' (' + formatCurrency(product.unitPrice) + ' VNĐ, tồn: ' + (product.quantity != null ? formatCurrency(product.quantity) : 0) + ')</option>';
                        });
                    } else {
                        options += '<option value="" disabled>Không có sản phẩm nào</option>';
                    }
                    $('#newProductId').html(options);
                    console.log('Products loaded successfully');
                } else {
                    console.error('Error loading products:', resp.message);
                    $('#newProductId').html('<option value="" disabled>Lỗi tải sản phẩm: ' + (resp.message || 'Unknown error') + '</option>');
                }
            }, 'json').fail(function(xhr, status, error) {
                console.error('AJAX error loading products:', status, error);
                $('#newProductId').html('<option value="" disabled>Lỗi kết nối: ' + error + '</option>');
            });
        }

        function viewContract(id) {
            $.get('api/contracts', { action: 'get', id: id }, function(resp) {
                if (resp.success) {
                    var c = resp.data;
                    // Chuyển xuống dòng trong điều khoản để hiển thị đẹp
                    var rawTerms = (c.terms || '-');
                    var safeTerms = $('<div/>').text(rawTerms).html().replace(/\n/g, '<br>');
                    var html = '' +
                        '<div class="row" style="margin-bottom: 10px;">' +
                        '  <div class="col-sm-6">' +
                        '    <p><strong>ID:</strong> ' + c.id + '</p>' +
                        '    <p><strong>Số hợp đồng:</strong> ' + c.contractNumber + '</p>' +
                        '    <p><strong>Khách hàng:</strong> ' + (c.customerName || c.customerId) + '</p>' +
                        '    <p><strong>Số điện thoại:</strong> ' + (c.customerPhone || '-') + '</p>' +
                        '  </div>' +
                        '  <div class="col-sm-6">' +
                        '    <p><strong>Loại:</strong> ' + (c.contractType || '-') + '</p>' +
                        (function(){ var endLabel = (c.status === 'terminated') ? 'Ngày chấm dứt' : 'Ngày kết thúc'; var endValue = (c.status === 'terminated') ? (c.endDate || '-') : 'Vô thời hạn'; return '    <p><strong>' + endLabel + ':</strong> ' + endValue + '</p>'; })() +
                        '    <p><strong>Ngày ký:</strong> ' + (c.signedDate || '-') + '</p>' +
                        '  </div>' +
                        '</div>' +
                        '<div class="well" style="padding: 10px;">' +
                        '  <p style="margin-bottom: 6px;"><strong>Tiêu đề:</strong></p>' +
                        '  <div style="white-space: normal;">' + (c.title || '-') + '</div>' +
                        '</div>' +
                        '<div class="well" style="padding: 10px;">' +
                        '  <p style="margin-bottom: 6px;"><strong>Điều khoản:</strong></p>' +
                        '  <div style="white-space: normal;">' + safeTerms + '</div>' +
                        '</div>' +
                        '<div class="well" style="padding: 10px;">' +
                        '  <p style="margin-bottom: 6px;"><strong>Giá trị:</strong></p>' +
                        '  <div>' + (c.contractValue ? formatCurrency(parseFloat(c.contractValue)) : '-') + '</div>' +
                        '  <p style="margin-top:10px;"><strong>Trạng thái:</strong> ' + translateStatus(c.status) + '</p>' +
                        '</div>' +
                        '<h5><i class="fa fa-list"></i> Sản phẩm gắn với hợp đồng</h5>' +
                        '<div class="table-responsive">' +
                        '  <table class="table table-striped table-hover" style="table-layout: fixed; width: 100%;">' +
                        '    <thead>' +
                        '      <tr class="text-center">' +
                        '        <th style="width:8%" class="text-center">STT</th>' +
                        '        <th style="width:12%" class="text-center">Product ID</th>' +
                        '        <th style="width:25%" class="text-center">Mô tả</th>' +
                        '        <th style="width:10%" class="text-center">Số lượng</th>' +
                        '        <th style="width:12%" class="text-center">Đơn giá</th>' +
                        '        <th style="width:12%" class="text-center">Thành tiền</th>' +
                        '        <th style="width:15%" class="text-center">Trạng thái bàn giao</th>' +
                        '      </tr>' +
                        '    </thead>' +
                        '    <tbody id="contractDetailProductsBody" style="word-break: break-word; overflow-wrap: anywhere;">' +
                        '      <tr><td colspan="7" class="text-center text-muted"><i class="fa fa-spinner fa-spin"></i> Đang tải sản phẩm...</td></tr>' +
                        '    </tbody>' +
                        '  </table>' +
                        '</div>';
                    $('#contractDetail').html(html);

                    // Load products for this contract and render into the details modal
                    $.get('api/contract-items', { contractId: id }, function(itemsResp) {
                        var tbody = $('#contractDetailProductsBody');
                        if (itemsResp && itemsResp.success) {
                            var items = itemsResp.data || [];
                            if (items.length === 0) {
                                tbody.html('<tr><td colspan="7" class="text-center text-muted"><i class="fa fa-info-circle"></i> Hợp đồng chưa có sản phẩm</td></tr>');
                                return;
                            }
                            var rows = '';
                            var idx = 1;
                            items.forEach(function(p) {
                                var qty = p.quantity ? formatCurrency(p.quantity) : '0';
                                var price = p.unitPrice ? formatCurrencyWithUnit(p.unitPrice) : '<span class="text-muted">0 VNĐ</span>';
                                var line = (p.quantity && p.unitPrice) ? (parseFloat(p.quantity) * parseFloat(p.unitPrice)) : 0;
                                
                                // Xác định trạng thái bàn giao
                                var deliveryStatus = p.deliveryStatus || 'not_delivered';
                                var deliveryStatusText = '';
                                if (deliveryStatus === 'delivered') {
                                    deliveryStatusText = '<span class="label label-success"><i class="fa fa-check-circle"></i> Đã bàn giao</span>';
                                } else {
                                    deliveryStatusText = '<span class="label label-warning"><i class="fa fa-clock-o"></i> Chưa bàn giao</span>';
                                }
                                
                                rows += '<tr class="text-center">' +
                                    '<td class="text-center">' + (idx++) + '</td>' +
                                    '<td class="text-center">' + p.productId + '</td>' +
                                    '<td class="text-center">' + (p.description || '<span class="text-muted">-</span>') + '</td>' +
                                    '<td class="text-center">' + qty + '</td>' +
                                    '<td class="text-center text-nowrap">' + price + '</td>' +
                                    '<td class="text-center text-nowrap"><strong class="text-primary">' + formatCurrencyWithUnit(line) + '</strong></td>' +
                                    '<td class="text-center">' + deliveryStatusText + '</td>' +
                                '</tr>';
                            });
                            tbody.html(rows);
                        } else {
                            tbody.html('<tr><td colspan="7" class="text-center text-danger">Không tải được danh sách sản phẩm</td></tr>');
                        }
                    }, 'json').fail(function() {
                        $('#contractDetailProductsBody').html('<tr><td colspan="7" class="text-center text-danger">Lỗi kết nối khi tải sản phẩm</td></tr>');
                    });

                    $('#contractDetailModal').modal('show');
                } else {
                    showAlert(resp.message, 'danger');
                }
            }, 'json');
        }

        function editContract(id) {
            // Kiểm tra xem có đang xem hợp đồng đã bị xóa không
            var currentStatus = '<%= request.getParameter("status") %>';
            if (currentStatus === 'deleted') {
                showAlert('Không thể chỉnh sửa hợp đồng đã bị xóa. Vui lòng khôi phục trước.', 'warning');
                return;
            }
            
            // Load danh sách khách hàng trước, sau đó mới load thông tin hợp đồng
            // Đảm bảo dropdown có đầy đủ options trước khi set giá trị
            $.get('api/contracts', { action: 'customers' }, function(customersResp) {
                // Load danh sách khách hàng vào dropdown
                if (customersResp.success) {
                    var options = '<option value="">Chọn khách hàng...</option>';
                    if (customersResp.data && customersResp.data.length > 0) {
                        customersResp.data.forEach(function(customer) {
                            options += '<option value="' + customer.id + '">' + 
                                      customer.customerCode + ' - ' + customer.companyName + 
                                      ' (' + customer.contactPerson + ')</option>';
                        });
                    } else {
                        options += '<option value="" disabled>Không có khách hàng nào</option>';
                    }
                    $('#customerId').html(options);
                } else {
                    $('#customerId').html('<option value="" disabled>Lỗi tải khách hàng: ' + (customersResp.message || 'Unknown error') + '</option>');
                }
                
                // Sau khi đã load xong danh sách khách hàng, mới load thông tin hợp đồng
                $.get('api/contracts', { action: 'get', id: id }, function(resp) {
                    if (resp.success) {
                        var c = resp.data;
                        currentEditingId = c.id;
                        $('#contractId').val(c.id);
                        $('#contractNumber').val(c.contractNumber);
                        // Bây giờ mới set giá trị customerId sau khi đã có options
                        $('#customerId').val(c.customerId);
                        $('#contractType').val('Bán hàng'); // Luôn là 'Bán hàng'
                        $('#title').val(c.title || '');
                        $('#signedDate').val(formatDateInput(c.signedDate));
                        // Format giá trị hợp đồng với dấu phẩy ngăn cách
                        var contractValue = parseFloat(c.contractValue) || 0;
                        $('#contractValue').val(contractValue > 0 ? formatCurrency(contractValue) : '');
                        previousTotalValue = contractValue; // Lưu giá trị ban đầu
                        $('#status').val(c.status || 'draft');
                        $('#terms').val(c.terms || '');
                        // Set endDate sau khi set status để trigger show/hide
                        $('#endDate').val(formatDateInput(c.endDate));
                        // Trigger change event để hiển thị/ẩn endDate theo status
                        $('#status').trigger('change');
                        $('#contractModalLabel').text('Chỉnh sửa hợp đồng');
                        
                        // Load sản phẩm của hợp đồng
                        loadContractProducts(id);
                        
                        // Ẩn form sản phẩm khi mở modal
                        hideAddProductForm();
                        
                        // Không tự động cập nhật giá trị hợp đồng khi đang sửa
                        isEditingMode = true;
                        
                        $('#contractModal').modal('show');
                    } else {
                        showAlert(resp.message, 'danger');
                    }
                }, 'json');
            }, 'json').fail(function() {
                // Nếu load customers thất bại, vẫn tiếp tục load hợp đồng
                $('#customerId').html('<option value="" disabled>Lỗi kết nối khi tải khách hàng</option>');
                $.get('api/contracts', { action: 'get', id: id }, function(resp) {
                    if (resp.success) {
                        var c = resp.data;
                        currentEditingId = c.id;
                        $('#contractId').val(c.id);
                        $('#contractNumber').val(c.contractNumber);
                        $('#customerId').val(c.customerId);
                        $('#contractType').val('Bán hàng');
                        $('#title').val(c.title || '');
                        $('#signedDate').val(formatDateInput(c.signedDate));
                        // Format giá trị hợp đồng với dấu phẩy ngăn cách
                        var contractValue = parseFloat(c.contractValue) || 0;
                        $('#contractValue').val(contractValue > 0 ? formatCurrency(contractValue) : '');
                        previousTotalValue = contractValue; // Lưu giá trị ban đầu
                        $('#status').val(c.status || 'draft');
                        $('#terms').val(c.terms || '');
                        // Set endDate sau khi set status để trigger show/hide
                        $('#endDate').val(formatDateInput(c.endDate));
                        // Trigger change event để hiển thị/ẩn endDate theo status
                        $('#status').trigger('change');
                        $('#contractModalLabel').text('Chỉnh sửa hợp đồng');
                        loadContractProducts(id);
                        hideAddProductForm();
                        isEditingMode = true;
                        $('#contractModal').modal('show');
                    } else {
                        showAlert(resp.message, 'danger');
                    }
                }, 'json');
            });
        }

        function loadContractProducts(contractId) {
            $.get('api/contract-items', { contractId: contractId }, function(resp) {
                if (resp.success) {
                    contractProducts = resp.data || [];
                    renderContractProducts();
                }
            }, 'json');
        }

        function renderContractProducts() {
            var tbody = $('#contractProductsTableBody');
            var noProductsRow = $('#noProductsRow');
            
            if (contractProducts.length === 0) {
                tbody.html('<tr id="noProductsRow"><td colspan="10" class="text-center text-muted"><i class="fa fa-info-circle"></i> Chưa có sản phẩm nào. Nhấn "Thêm sản phẩm" để bắt đầu.</td></tr>');
                updateTotalValue();
                return;
            }
            
            var rows = '';
            var totalValue = 0;
            
            contractProducts.forEach(function(product, index) {
                var lineTotal = product.quantity && product.unitPrice ? 
                    (parseFloat(product.quantity) * parseFloat(product.unitPrice)) : 0;
                totalValue += lineTotal;
                
                // Xác định trạng thái bàn giao
                var deliveryStatus = product.deliveryStatus || 'not_delivered';
                var deliveryStatusText = '';
                var deliveryStatusClass = '';
                if (deliveryStatus === 'delivered') {
                    deliveryStatusText = '<span class="label label-success"><i class="fa fa-check-circle"></i> Đã bàn giao</span>';
                    deliveryStatusClass = 'text-success';
                } else {
                    deliveryStatusText = '<span class="label label-warning"><i class="fa fa-clock-o"></i> Chưa bàn giao</span>';
                    deliveryStatusClass = 'text-warning';
                }
                
                rows += '<tr class="text-center">' +
                    '<td class="text-center">' + (index + 1) + '</td>' +
                    '<td class="text-center">' + product.productId + '</td>' +
                    '<td class="text-center">' + (product.description || '<span class="text-muted">-</span>') + '</td>' +
                    '<td class="text-center">' + (product.quantity ? formatCurrency(product.quantity) : '0') + '</td>' +
                    '<td class="text-center text-nowrap">' + (product.unitPrice ? formatCurrencyWithUnit(product.unitPrice) : '<span class="text-muted">0 VNĐ</span>') + '</td>' +
                    '<td class="text-center text-nowrap"><strong class="text-primary">' + formatCurrencyWithUnit(lineTotal) + '</strong></td>' +
                    '<td class="text-center">' + (product.warrantyMonths ? product.warrantyMonths + ' <span class="text-muted">tháng</span>' : '<span class="text-muted">-</span>') + '</td>' +
                    '<td class="text-center">' + (product.notes || '<span class="text-muted">-</span>') + '</td>' +
                    '<td class="text-center ' + deliveryStatusClass + '">' + deliveryStatusText + '</td>' +
                    '<td class="text-center">' +
                        '<button class="btn btn-warning btn-xs" onclick="editProductFromContract(' + index + ')" title="Sửa">' +
                        '<i class="fa fa-edit"></i></button> ' +
                        '<button class="btn btn-danger btn-xs" onclick="removeProductFromContract(' + index + ')" title="Xóa">' +
                        '<i class="fa fa-trash"></i></button>' +
                    '</td>' +
                '</tr>';
            });
            
            tbody.html(rows);
            updateTotalValue(totalValue);
        }

        // Hiển thị form thêm sản phẩm
        function showAddProductForm() {
            $('#productFormContainer').show();
            $('#productFormTitle').text('Thêm sản phẩm mới');
            $('#editingProductIndex').val('');
            clearProductForm();
            loadProducts(); // Load danh sách sản phẩm
        }
        
        // Ẩn form thêm sản phẩm
        function hideAddProductForm() {
            $('#productFormContainer').hide();
            clearProductForm();
        }
        
        // Xóa form sản phẩm
        function clearProductForm() {
            $('#newProductId').val('');
            $('#newDescription').val('');
            $('#newQuantity').val('');
            $('#newUnitPrice').val('');
            $('#newWarrantyMonths').val('');
            $('#newNotes').val('');
            $('#newLineTotal').val('');
            $('#stockInfo').html(''); // Xóa thông tin tồn kho
        }
        
        // Sửa sản phẩm
        function editProductFromContract(index) {
            var product = contractProducts[index];
            
            // Load danh sách sản phẩm trước
            loadProducts();
            
            // Sau khi load xong, set giá trị
            setTimeout(function() {
                $('#newProductId').val(product.productId);
                $('#newDescription').val(product.description || '');
                $('#newQuantity').val(product.quantity);
                $('#newUnitPrice').val(formatCurrency(product.unitPrice));
                $('#newWarrantyMonths').val(product.warrantyMonths || '');
                $('#newNotes').val(product.notes || '');
                $('#editingProductIndex').val(index);
                $('#productFormTitle').text('Sửa sản phẩm');
                $('#productFormContainer').show();
                
                // Cập nhật thông tin tồn kho
                var selectedOption = $('#newProductId').find('option:selected');
                var availableQuantity = parseFloat(selectedOption.data('quantity')) || 0;
                updateStockInfo(availableQuantity);
                
                // Kiểm tra tồn kho với số lượng hiện tại
                checkStockAvailability();
                
                // Tính lại thành tiền
                calculateLineTotal();
            }, 100);
        }

        function addProductToContract() {
            var productId = $('#newProductId').val();
            var description = $('#newDescription').val();
            var quantity = $('#newQuantity').val();
            var unitPrice = $('#newUnitPrice').val().replace(/[.,\s]/g, ''); // Loại bỏ dấu phẩy, chấm và khoảng trắng
            var warrantyMonths = $('#newWarrantyMonths').val();
            var notes = $('#newNotes').val();
            var editingIndex = $('#editingProductIndex').val();

            if (!productId || !quantity || !unitPrice) {
                showAlert('Vui lòng chọn sản phẩm và nhập số lượng', 'warning');
                return;
            }

            // Kiểm tra tồn kho
            var selectedOption = $('#newProductId').find('option:selected');
            var availableQuantity = parseFloat(selectedOption.data('quantity')) || 0;
            var requestedQuantity = parseFloat(quantity);
            var editingIndexNum = editingIndex !== '' ? parseInt(editingIndex) : -1;
            
            // Tính tổng số lượng đã thêm vào hợp đồng (trừ sản phẩm đang sửa nếu có)
            var totalQuantityInContract = 0;
            contractProducts.forEach(function(p, index) {
                if (p.productId == productId && index !== editingIndexNum) {
                    totalQuantityInContract += parseFloat(p.quantity) || 0;
                }
            });
            
            // Tính số lượng khả dụng thực tế (tồn kho - số lượng đã thêm vào hợp đồng)
            var actuallyAvailable = availableQuantity - totalQuantityInContract;
            
            // Kiểm tra nếu số lượng yêu cầu vượt quá tồn kho khả dụng
            if (requestedQuantity > actuallyAvailable) {
                var productName = selectedOption.text().split(' - ')[1] || selectedOption.text();
                if (productName.indexOf('(') > 0) {
                    productName = productName.substring(0, productName.indexOf('(')).trim();
                }
                showAlert('Sản phẩm "' + productName + '" không đủ tồn kho. Tồn kho hiện có: ' + 
                         actuallyAvailable.toLocaleString() + ', bạn đã thêm: ' + 
                         totalQuantityInContract.toLocaleString() + ', yêu cầu: ' + 
                         requestedQuantity.toLocaleString(), 'danger');
                return;
            }

            var product = {
                productId: parseInt(productId),
                description: description,
                quantity: parseFloat(quantity),
                unitPrice: parseFloat(unitPrice),
                warrantyMonths: warrantyMonths ? parseInt(warrantyMonths) : null,
                notes: notes
            };

            if (editingIndex !== '') {
                // Sửa sản phẩm
                contractProducts[parseInt(editingIndex)] = product;
            } else {
                // Thêm sản phẩm mới
                contractProducts.push(product);
            }

            renderContractProducts();
            hideAddProductForm();
        }
        
        // Cập nhật thông tin tồn kho
        function updateStockInfo(availableQuantity) {
            var stockInfo = $('#stockInfo');
            if (availableQuantity > 0) {
                stockInfo.html('<i class="fa fa-check-circle text-success"></i> Tồn kho: <strong>' + 
                              availableQuantity.toLocaleString() + '</strong>');
                stockInfo.removeClass('text-danger').addClass('text-success');
            } else {
                stockInfo.html('<i class="fa fa-exclamation-circle text-danger"></i> <strong>Hết hàng</strong>');
                stockInfo.removeClass('text-success').addClass('text-danger');
            }
        }
        
        // Kiểm tra tồn kho khi nhập số lượng
        function checkStockAvailability() {
            var productId = $('#newProductId').val();
            var quantity = parseFloat($('#newQuantity').val()) || 0;
            
            if (!productId || quantity <= 0) {
                $('#stockInfo').html('');
                return;
            }
            
            var selectedOption = $('#newProductId').find('option:selected');
            var availableQuantity = parseFloat(selectedOption.data('quantity')) || 0;
            var editingIndex = $('#editingProductIndex').val();
            var editingIndexNum = editingIndex !== '' ? parseInt(editingIndex) : -1;
            
            // Tính tổng số lượng đã thêm vào hợp đồng (trừ sản phẩm đang sửa nếu có)
            var totalQuantityInContract = 0;
            contractProducts.forEach(function(p, index) {
                if (p.productId == productId && index !== editingIndexNum) {
                    totalQuantityInContract += parseFloat(p.quantity) || 0;
                }
            });
            
            // Tính số lượng khả dụng thực tế
            var actuallyAvailable = availableQuantity - totalQuantityInContract;
            
            var stockInfo = $('#stockInfo');
            if (quantity > actuallyAvailable) {
                stockInfo.html('<i class="fa fa-exclamation-triangle text-danger"></i> ' +
                              'Tồn kho không đủ! Khả dụng: <strong>' + actuallyAvailable.toLocaleString() + 
                              '</strong>, đã thêm: ' + totalQuantityInContract.toLocaleString() + 
                              ', yêu cầu: ' + quantity.toLocaleString());
                stockInfo.removeClass('text-success').addClass('text-danger');
            } else {
                stockInfo.html('<i class="fa fa-check-circle text-success"></i> ' +
                              'Tồn kho: <strong>' + availableQuantity.toLocaleString() + 
                              '</strong>, khả dụng: <strong>' + actuallyAvailable.toLocaleString() + 
                              '</strong>, đã thêm: ' + totalQuantityInContract.toLocaleString());
                stockInfo.removeClass('text-danger').addClass('text-success');
            }
        }

        function removeProductFromContract(index) {
            if (confirm('Bạn có chắc chắn muốn xóa sản phẩm này?')) {
                contractProducts.splice(index, 1);
                renderContractProducts();
            }
        }
        
        // Format tiền đẹp hơn
        function formatCurrency(amount) {
            if (!amount || amount === 0) return '0';
            return parseFloat(amount).toLocaleString('vi-VN', {
                minimumFractionDigits: 0,
                maximumFractionDigits: 0
            });
        }
        
        // Format tiền với đơn vị VNĐ
        function formatCurrencyWithUnit(amount) {
            return formatCurrency(amount) + ' <span class="text-muted">VNĐ</span>';
        }
        
        // Cập nhật tổng giá trị
        function updateTotalValue(total) {
            total = total || 0;
            $('#totalContractValue').html('<span class="text-primary" style="font-size: 16px;">' + formatCurrencyWithUnit(total) + '</span>');
            
            // CHỈ tự động cập nhật giá trị hợp đồng khi THÊM MỚI (không phải chỉnh sửa)
            // Khi chỉnh sửa, giữ nguyên giá trị hợp đồng đã nhập (có thể đã giảm giá)
            if (!isEditingMode) {
                // Chỉ cập nhật khi thêm mới và chưa có giá trị hoặc giá trị = 0
                var currentValueStr = $('#contractValue').val() || '';
                var currentValue = parseFloat(currentValueStr.toString().replace(/[^\d]/g, '')) || 0;
                if (currentValue === 0) {
                    $('#contractValue').val(formatCurrency(total));
                    previousTotalValue = total;
                }
            }
            
            // Kiểm tra và hiển thị cảnh báo nếu giá trị không khớp
            checkContractValueMatch();
        }
        
        // Biến lưu tổng giá trị trước đó để so sánh
        var previousTotalValue = 0;
        
        // Kiểm tra giá trị hợp đồng có khớp với tổng sản phẩm không
        function checkContractValueMatch() {
            // Parse giá trị hợp đồng (bỏ dấu phẩy)
            var contractValueStr = $('#contractValue').val() || '';
            var contractValue = parseFloat(contractValueStr.toString().replace(/[^\d]/g, '')) || 0;
            var totalProducts = 0;
            contractProducts.forEach(function(product) {
                totalProducts += (parseFloat(product.quantity) || 0) * (parseFloat(product.unitPrice) || 0);
            });
            
            var warningDiv = $('#contractValueWarning');
            var diffDiv = $('#contractValueDiff');
            
            // Nếu có sản phẩm và giá trị không khớp
            if (contractProducts.length > 0 && Math.abs(contractValue - totalProducts) > 0.01) {
                var diff = contractValue - totalProducts;
                    var diffText = '';
                if (diff > 0) {
                    diffText = ' (Chênh lệch: <span class="text-success">+' + formatCurrency(Math.abs(diff)) + ' VNĐ</span> - có thể do phí vận chuyển, chiết khấu âm, v.v.)';
                } else {
                    diffText = ' (Chênh lệch: <span class="text-danger">-' + formatCurrency(Math.abs(diff)) + ' VNĐ</span> - có thể do chiết khấu, giảm giá, v.v.)';
                }
                diffDiv.html(diffText);
                warningDiv.show();
            } else {
                warningDiv.hide();
            }
        }

        function saveContract() {
            // Clear previous errors
            clearValidationErrors();
            
            var data = {
                action: currentEditingId ? 'update' : 'add',
                id: $('#contractId').val(),
                contractNumber: $('#contractNumber').val(),
                customerId: $('#customerId').val(),
                contractType: 'Bán hàng', // Luôn là 'Bán hàng'
                title: $('#title').val(),
                endDate: $('#endDate').val(),
                signedDate: $('#signedDate').val(),
                // Parse giá trị hợp đồng (bỏ dấu phẩy) trước khi gửi
                contractValue: $('#contractValue').val() ? parseFloat($('#contractValue').val().toString().replace(/[^\d]/g, '')) || 0 : '',
                status: $('#status').val(),
                terms: $('#terms').val(),
                products: contractProducts // Gửi kèm danh sách sản phẩm
            };

            // Validation
            var isValid = true;
            
            // Kiểm tra trường bắt buộc
            if (!data.contractNumber || data.contractNumber.trim() === '') {
                showFieldError('contractNumber', 'Số hợp đồng không được để trống');
                isValid = false;
            }
            
            if (!data.customerId || data.customerId === '') {
                showFieldError('customerId', 'Vui lòng chọn khách hàng');
                isValid = false;
            }
            
            // Kiểm tra ngày ký (chỉ bắt buộc khi status != "draft")
            if (data.status !== 'draft') {
                if (!data.signedDate || data.signedDate.trim() === '') {
                    showFieldError('signedDate', 'Ngày ký không được để trống khi hợp đồng không phải "Nháp"');
                    isValid = false;
                }
            }
            
            // Kiểm tra ngày chấm dứt (bắt buộc khi status = "terminated")
            if (data.status === 'terminated') {
                if (!data.endDate || data.endDate.trim() === '') {
                    showFieldError('endDate', 'Ngày chấm dứt không được để trống khi trạng thái là "Chấm Dứt"');
                    isValid = false;
                } else {
                    // Validate endDate >= signedDate (chỉ khi có signedDate)
                    if (data.signedDate && data.signedDate.trim() !== '') {
                        var signedDate = new Date(data.signedDate);
                        var endDate = new Date(data.endDate);
                        if (endDate < signedDate) {
                            showFieldError('endDate', 'Ngày chấm dứt không được trước ngày ký');
                            isValid = false;
                        }
                    }
                }
            } else {
                // Các trạng thái khác: clear endDate nếu có
                if (data.endDate) {
                    data.endDate = '';
                }
            }
            
            // Kiểm tra validation cho trạng thái "hiệu lực" (active)
            if (data.status === 'active') {
                // Tiêu đề bắt buộc
                if (!data.title || data.title.trim() === '') {
                    showFieldError('title', 'Tiêu đề không được để trống khi trạng thái là "Hiệu Lực"');
                    isValid = false;
                }
                
                // Điều khoản bắt buộc
                if (!data.terms || data.terms.trim() === '') {
                    showFieldError('terms', 'Điều khoản không được để trống khi trạng thái là "Hiệu Lực"');
                    isValid = false;
                }
                
                // Phải có ít nhất 1 sản phẩm
                if (!contractProducts || contractProducts.length === 0) {
                    showModalAlert('Hợp đồng ở trạng thái "Hiệu Lực" phải có ít nhất 1 sản phẩm', 'danger');
                    isValid = false;
                }
            }
            
            // Kiểm tra giá trị hợp đồng
            if (data.contractValue && data.contractValue !== '') {
                var value = parseFloat(data.contractValue);
                if (isNaN(value) || value < 0) {
                    showFieldError('contractValue', 'Giá trị hợp đồng phải là số dương');
                    isValid = false;
                }
            }
            
            if (!isValid) {
                showModalAlert('Vui lòng kiểm tra lại các thông tin đã nhập', 'warning');
                return;
            }
            
            // Hàm tiếp tục lưu hợp đồng sau khi xác nhận
            function continueSaveContract() {
                // Backend expects products as JSON string
                data.products = JSON.stringify(contractProducts);
                $.post('api/contracts', data, function(resp) {
                    if (resp.success) {
                        showModalAlert(resp.message, 'success');
                        // Đợi 3 giây để người dùng kịp đọc thông báo thành công
                        setTimeout(function() {
                            $('#contractModal').modal('hide');
                            contractProducts = []; // Reset danh sách sản phẩm
                            location.reload();
                        }, 3000);
                    } else {
                        // Hiển thị lỗi cụ thể từ server
                        if (resp.message && (resp.message.includes('trùng') || resp.message.includes('tồn tại'))) {
                            showFieldError('contractNumber', resp.message);
                            showModalAlert(resp.message, 'danger');
                        } else {
                            showModalAlert(resp.message, 'danger');
                        }
                    }
                }, 'json');
            }
            
            // Tiếp tục lưu hợp đồng (không kiểm tra chênh lệch giá)
            continueSaveContract();
        }
        
        function clearValidationErrors() {
            $('.help-block.text-danger').hide();
            $('.form-control').removeClass('has-error');
            hideModalAlert(); // Ẩn thông báo modal
        }
        
        function showFieldError(fieldId, message) {
            $('#' + fieldId + 'Error').text(message).show();
            $('#' + fieldId).addClass('has-error');
        }

        function deleteContract(id) {
            // Kiểm tra xem có đang xem hợp đồng đã bị xóa không
            var currentStatus = '<%= request.getParameter("status") %>';
            if (currentStatus === 'deleted') {
                showAlert('Hợp đồng này đã bị xóa. Sử dụng nút "Xóa vĩnh viễn" để xóa hoàn toàn.', 'warning');
                return;
            }
            
            if (!confirm('Bạn có chắc chắn muốn chuyển hợp đồng này vào thùng rác?')) return;
            $.post('api/contracts', { action: 'delete', id: id }, function(resp) {
                if (resp.success) {
                    showAlert(resp.message, 'success', 8000); // Hiển thị 8 giây cho thông báo xóa
                    setTimeout(function() {
                        location.reload();
                    }, 2000); // Đợi 2 giây để user đọc thông báo trước khi reload
                } else {
                    showAlert(resp.message, 'danger', 8000);
                }
            }, 'json');
        }

        function showDeletedContracts() {
            console.log('Opening deleted contracts modal');
            $('#deletedContractsModal').modal('show');
            
            // Test trực tiếp với AJAX đơn giản
            $.ajax({
                url: 'api/contracts',
                type: 'GET',
                data: { action: 'deleted', page: 1, pageSize: 10 },
                dataType: 'json',
                success: function(resp) {
                    console.log('Direct AJAX test - Response:', resp);
                    console.log('Direct test - Response keys:', Object.keys(resp));
                    console.log('Direct test - Response.data:', resp.data);
                    console.log('Direct test - Response.data type:', typeof resp.data);
                    
                    // Kiểm tra cấu trúc response
                    var dataArray = resp.data;
                    if (dataArray && dataArray.data && Array.isArray(dataArray.data)) {
                        dataArray = dataArray.data;
                        console.log('Direct test - Using nested data, found ' + dataArray.length + ' contracts');
                    } else if (Array.isArray(dataArray)) {
                        console.log('Direct test - Using direct data, found ' + dataArray.length + ' contracts');
                    } else {
                        console.log('Direct test - no data or error');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Direct AJAX test failed:', status, error);
                    console.error('Response text:', xhr.responseText);
                }
            });
            
            loadDeletedContracts();
        }

        // Biến toàn cục cho phân trang thùng rác
        var deletedContractsCurrentPage = 1;
        var deletedContractsTotalPages = 1;
        var deletedContractsTotalRecords = 0;

        function loadDeletedContracts(page) {
            if (page) deletedContractsCurrentPage = page;
            
            var search = $('#deletedSearch').val();
            var sortBy = $('#deletedSortBy').val();
            var sortDir = $('#deletedSortDir').val();
            var pageSize = $('#deletedPageSize').val();
            
            var params = {
                action: 'deleted',
                page: deletedContractsCurrentPage,
                pageSize: pageSize,
                search: search,
                sortBy: sortBy,
                sortDir: sortDir
            };
            
            console.log('Loading deleted contracts with params:', params);
            
            $.get('api/contracts', params, function(resp) {
                console.log('Response from server:', resp);
                console.log('Response type:', typeof resp);
                console.log('Response success:', resp.success);
                console.log('Response data:', resp.data);
                console.log('Response data length:', resp.data ? resp.data.length : 'undefined');
                
                // Debug: Kiểm tra tất cả các thuộc tính của response
                console.log('All response keys:', Object.keys(resp));
                console.log('Response.data type:', typeof resp.data);
                console.log('Response.data value:', resp.data);
                
                // Test: Kiểm tra xem có phải là string không
                if (typeof resp === 'string') {
                    console.log('Response is string, trying to parse JSON');
                    try {
                        resp = JSON.parse(resp);
                        console.log('Parsed response:', resp);
                    } catch (e) {
                        console.error('Failed to parse JSON:', e);
                    }
                }
                
                if (resp && resp.success) {
                    var tbody = $('#deletedContractsTableBody');
                    
                    // Kiểm tra cấu trúc response - có thể data nằm trong resp.data.data
                    var dataArray = resp.data;
                    if (dataArray && dataArray.data && Array.isArray(dataArray.data)) {
                        // Trường hợp: resp.data.data là mảng
                        dataArray = dataArray.data;
                        console.log('Using nested data array, found ' + dataArray.length + ' contracts');
                    } else if (Array.isArray(dataArray)) {
                        // Trường hợp: resp.data là mảng trực tiếp
                        console.log('Using direct data array, found ' + dataArray.length + ' contracts');
                    }
                    
                    if (Array.isArray(dataArray) && dataArray.length > 0) {
                        console.log('Found ' + dataArray.length + ' deleted contracts');
                        var rows = '';
                        dataArray.forEach(function(contract) {
                            console.log('Processing contract:', contract);
                            var deletedAt = contract.deletedAt || contract.updatedAt || '-';
                            var deletedByName = contract.deletedByName || 'Không xác định';
                            
                            // Format thời gian xóa theo múi giờ Việt Nam
                            var formattedDeletedAt = formatVietnamTime(deletedAt);
                            // Escape và tạo tooltip cho tiêu đề dài
                            var rawTitle = contract.title || '-';
                            var safeTitle = $('<div/>').text(rawTitle).html();
                            var titleCell = '<div class="truncate" title="' + safeTitle + '">' + safeTitle + '</div>';
                            
                            rows += '<tr>' +
                                '<td>' + contract.id + '</td>' +
                                '<td>' + contract.customerId + '</td>' +
                                '<td>' + contract.contractNumber + '</td>' +
                                '<td>' + (contract.customerName || '-') + '</td>' +
                                '<td>' + titleCell + '</td>' +
                                '<td>' + deletedByName + '</td>' +
                                '<td>' + formattedDeletedAt + '</td>' +
                                '<td>' +
                                    '<button class="btn btn-success btn-xs" onclick="restoreContract(' + contract.id + ')" title="Khôi phục">' +
                                    '<i class="fa fa-undo"></i> Khôi phục</button> ' +
                                    '<button class="btn btn-danger btn-xs" onclick="permanentlyDeleteContract(' + contract.id + ')" title="Xóa vĩnh viễn">' +
                                    '<i class="fa fa-trash"></i> Xóa vĩnh viễn</button>' +
                                '</td>' +
                            '</tr>';
                        });
                        tbody.html(rows);
                        
                        // Cập nhật thông tin phân trang
                        deletedContractsTotalPages = resp.data.totalPages || resp.totalPages || 1;
                        deletedContractsTotalRecords = resp.data.totalRecords || resp.totalRecords || 0;
                        updateDeletedPaginationInfo();
                        renderDeletedPagination();
                    } else {
                        console.log('No deleted contracts found - data is empty or not an array');
                        console.log('Data type:', typeof dataArray);
                        console.log('Data value:', dataArray);
                        tbody.html('<tr><td colspan="8" class="text-center text-muted"><i class="fa fa-info-circle"></i> Thùng rác trống</td></tr>');
                        deletedContractsTotalPages = 1;
                        deletedContractsTotalRecords = 0;
                        updateDeletedPaginationInfo();
                        renderDeletedPagination();
                    }
                } else {
                    console.error('Server error:', resp);
                    $('#deletedContractsTableBody').html('<tr><td colspan="8" class="text-center text-danger">Lỗi: ' + (resp.message || 'Không thể tải dữ liệu') + '</td></tr>');
                }
            }, 'json')
            .fail(function(xhr, status, error) {
                console.error('AJAX error:', status, error);
                console.error('XHR response:', xhr.responseText);
                $('#deletedContractsTableBody').html('<tr><td colspan="8" class="text-center text-danger">Lỗi kết nối: ' + error + '</td></tr>');
            });
        }

        function updateDeletedPaginationInfo() {
            var pageSize = parseInt($('#deletedPageSize').val());
            var start = (deletedContractsCurrentPage - 1) * pageSize + 1;
            var end = Math.min(deletedContractsCurrentPage * pageSize, deletedContractsTotalRecords);
            
            if (deletedContractsTotalRecords === 0) {
                start = 0;
                end = 0;
            }
            
            $('#deletedPaginationInfo').text('Hiển thị ' + start + ' - ' + end + ' của ' + deletedContractsTotalRecords + ' bản ghi');
        }

        function renderDeletedPagination() {
            var pagination = $('#deletedPagination');
            pagination.empty();
            
            // Luôn hiển thị nút Previous
            var prevDisabled = deletedContractsCurrentPage <= 1 ? 'disabled' : '';
            pagination.append('<li class="' + prevDisabled + '"><a href="#" onclick="loadDeletedContracts(' + (deletedContractsCurrentPage - 1) + '); return false;">&laquo;</a></li>');
            
            // Nếu chỉ có 1 trang, vẫn hiển thị nút trang đó
            if (deletedContractsTotalPages <= 1) {
                pagination.append('<li class="active"><a href="#" onclick="loadDeletedContracts(1); return false;">1</a></li>');
            } else {
                // Các nút trang
                var startPage = Math.max(1, deletedContractsCurrentPage - 2);
                var endPage = Math.min(deletedContractsTotalPages, deletedContractsCurrentPage + 2);
                
                if (startPage > 1) {
                    pagination.append('<li><a href="#" onclick="loadDeletedContracts(1); return false;">1</a></li>');
                    if (startPage > 2) {
                        pagination.append('<li class="disabled"><span>...</span></li>');
                    }
                }
                
                for (var i = startPage; i <= endPage; i++) {
                    var active = i === deletedContractsCurrentPage ? 'active' : '';
                    pagination.append('<li class="' + active + '"><a href="#" onclick="loadDeletedContracts(' + i + '); return false;">' + i + '</a></li>');
                }
                
                if (endPage < deletedContractsTotalPages) {
                    if (endPage < deletedContractsTotalPages - 1) {
                        pagination.append('<li class="disabled"><span>...</span></li>');
                    }
                    pagination.append('<li><a href="#" onclick="loadDeletedContracts(' + deletedContractsTotalPages + '); return false;">' + deletedContractsTotalPages + '</a></li>');
                }
            }
            
            // Luôn hiển thị nút Next
            var nextDisabled = deletedContractsCurrentPage >= deletedContractsTotalPages ? 'disabled' : '';
            pagination.append('<li class="' + nextDisabled + '"><a href="#" onclick="loadDeletedContracts(' + (deletedContractsCurrentPage + 1) + '); return false;">&raquo;</a></li>');
        }

        function restoreContract(id) {
            if (!confirm('Bạn có chắc chắn muốn khôi phục hợp đồng này? Hợp đồng sẽ được khôi phục về trạng thái "Bản nháp".')) {
                return;
            }
            
            $.post('api/contracts', { action: 'restore', id: id }, function(resp) {
                if (resp.success) {
                    showAlert(resp.message, 'success', 8000); // Hiển thị 8 giây cho thông báo khôi phục
                    loadDeletedContracts(); // Reload danh sách thùng rác
                    setTimeout(function() {
                        location.reload(); // Reload trang chính sau 2 giây để user kịp đọc thông báo
                    }, 2000);
                } else {
                    showAlert(resp.message, 'danger', 8000);
                }
            }, 'json');
        }

        function permanentlyDeleteContract(id) {
            if (!confirm('Bạn có chắc chắn muốn xóa vĩnh viễn hợp đồng này? Hành động này không thể hoàn tác!')) return;
            $.post('api/contracts', { action: 'permanent_delete', id: id }, function(resp) {
                if (resp.success) {
                    showAlert(resp.message, 'success', 8000); // Hiển thị 8 giây cho thông báo xóa vĩnh viễn
                    loadDeletedContracts(); // Reload danh sách thùng rác
                    // Reload trang chính sau khi xóa vĩnh viễn
                    setTimeout(function() {
                        location.reload();
                    }, 2000); // Đợi 2 giây để user đọc thông báo trước khi reload
                } else {
                    showAlert(resp.message, 'danger', 8000);
                }
            }, 'json');
        }


        function showAlert(message, type, timeout) {
            // Kiểm tra xem có đang trong modal không
            if ($('#contractModal').hasClass('in') || $('#contractModal').is(':visible')) {
                // Hiển thị trong modal
                showModalAlert(message, type, timeout);
            } else {
                // Hiển thị ở trang chính
                var alertClass = 'alert-' + type;
                var html = '<div class="alert ' + alertClass + ' alert-dismissible" role="alert">' +
                           '<button type="button" class="close" data-dismiss="alert" aria-label="Close">' +
                           '<span aria-hidden="true">&times;</span></button>' + message + '</div>';
                $('.content').prepend(html);
                // Mặc định  giây, nhưng có thể tùy chỉnh
                var delay = timeout || 3000;
                setTimeout(function(){ $('.alert').fadeOut(400, function(){ $(this).remove(); }); }, delay);
            }
        }
        
        function showModalAlert(message, type, timeout) {
            var alertClass = 'alert-' + type;
            var iconClass = type === 'success' ? 'fa-check-circle' : 
                           type === 'warning' ? 'fa-exclamation-triangle' : 
                           type === 'info' ? 'fa-info-circle' : 'fa-exclamation-triangle';
            
            $('#contractErrorAlert')
                .removeClass('alert-success alert-warning alert-info alert-danger')
                .addClass(alertClass)
                .show();
            
            $('#contractErrorText').html('<i class="fa ' + iconClass + '"></i> ' + message);
            
            // Mặc định: success 2 giây, các loại khác 3 giây. Có thể tùy chỉnh qua tham số timeout
            var hideDelay = timeout || (type === 'success' ? 2000 : 3000);
            setTimeout(function() {
                $('#contractErrorAlert').fadeOut(400);
            }, hideDelay);
        }
        
        function hideModalAlert() {
            $('#contractErrorAlert').hide();
        }
        
        // Hàm hiển thị confirm box đẹp
        function showConfirmModal(message, onConfirm, onCancel) {
            $('#confirmModalBody').html(message);
            $('#confirmModal').modal('show');
            
            // Xóa các event handler cũ
            $('#confirmModalOk').off('click');
            $('#confirmModalCancel').off('click');
            
            // Thêm event handler mới
            $('#confirmModalOk').on('click', function() {
                $('#confirmModal').modal('hide');
                if (onConfirm && typeof onConfirm === 'function') {
                    onConfirm();
                }
            });
            
            $('#confirmModalCancel').on('click', function() {
                $('#confirmModal').modal('hide');
                if (onCancel && typeof onCancel === 'function') {
                    onCancel();
                }
            });
            
            // Khi đóng modal bằng cách khác (ESC, click backdrop)
            $('#confirmModal').off('hidden.bs.modal');
            $('#confirmModal').on('hidden.bs.modal', function() {
                if (onCancel && typeof onCancel === 'function') {
                    onCancel();
                }
            });
        }

        function formatDateInput(value) {
            if (!value) return '';
            try {
                var d = new Date(value);
                if (isNaN(d.getTime())) return '';
                var m = (d.getMonth() + 1).toString().padStart(2, '0');
                var day = d.getDate().toString().padStart(2, '0');
                return d.getFullYear() + '-' + m + '-' + day;
            } catch (e) { return ''; }
        }

        // Hàm format thời gian theo múi giờ Việt Nam
        function formatVietnamTime(dateString) {
            if (!dateString || dateString === '-') return '-';
            try {
                var date = new Date(dateString);
                if (isNaN(date.getTime())) return dateString;
                
                // Database lưu theo UTC, cần trừ đi 7 tiếng để có múi giờ Việt Nam
                var vietnamTime = new Date(date.getTime() - (7 * 60 * 60 * 1000));
                return vietnamTime.toLocaleString('vi-VN', {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit'
                });
            } catch (e) {
                console.error('Error formatting Vietnam time:', e);
                return dateString;
            }
        }

        // Reset form when modal is closed
        $('#contractModal').on('hidden.bs.modal', function() {
            document.getElementById('contractForm').reset();
            $('#contractType').val('Bán hàng'); // Luôn set lại là 'Bán hàng'
            currentEditingId = null;
            contractProducts = []; // Reset danh sách sản phẩm
            isEditingMode = false; // Reset về chế độ thêm mới
            $('#contractModalLabel').text('Thêm hợp đồng mới');
            $('#contractProductsTableBody').html('');
            hideAddProductForm(); // Ẩn form sản phẩm
            clearValidationErrors(); // Clear validation errors
            // Reset endDate và ẩn đi
            $('#endDate').val('');
            $('#endDateGroup').hide();
            $('#endDate').prop('required', false);
            $('#contractDuration').val('Vô thời hạn');
            // Reset status về draft
            $('#status').val('draft');
            // Reset signedDate required (draft không bắt buộc)
            $('#signedDate').prop('required', false);
            $('#signedDateRequired').hide();
            // Reset giá trị hợp đồng và cảnh báo
            $('#contractValue').val('');
            $('#contractValueWarning').hide();
            previousTotalValue = 0;
        });
        
        // Ẩn form sản phẩm khi mở modal thêm mới
        $('#contractModal').on('show.bs.modal', function() {
            hideAddProductForm();
            isEditingMode = false; // Reset về chế độ thêm mới
            if (!currentEditingId) {
                // Nếu là thêm mới (không phải edit), set contractType = 'Bán hàng'
                $('#contractType').val('Bán hàng');
                // Tải lại danh sách khách hàng để đảm bảo có dữ liệu
                loadCustomers();
                // Sinh số hợp đồng tự động khi mở modal thêm mới
                $.get('api/contracts', { action: 'generate_number' }, function(resp) {
                    if (resp && resp.success && resp.data && resp.data.contractNumber) {
                        $('#contractNumber').val(resp.data.contractNumber);
                        $('#contractNumberError').hide();
                    }
                }, 'json');
            }
            loadProducts(); // Load danh sách sản phẩm khi mở modal
            clearValidationErrors(); // Clear validation errors
        });
        
        // Real-time validation
        $(document).on('blur', '#contractNumber', function() {
            var value = $(this).val().trim();
            if (value === '') {
                showFieldError('contractNumber', 'Số hợp đồng không được để trống');
            } else {
                // Kiểm tra trùng lặp số hợp đồng
                checkContractNumberExists(value);
            }
        });
        
        // Đếm ký tự tiêu đề/điều khoản và cập nhật realtime
        var TITLE_MAX = 150;
        var TERMS_MAX = 2000;
        function updateCounters() {
            var t = $('#title').val() || '';
            var tm = $('#terms').val() || '';
            if ($('#titleCount').length) { $('#titleCount').text(t.length); }
            if ($('#termsCount').length) { $('#termsCount').text(tm.length); }
        }
        $(document).on('input', '#title, #terms', function() {
            // maxlength đã chặn vượt ngưỡng ở HTML, chỉ cần cập nhật counter
            updateCounters();
        });
        // Tự động co giãn chiều cao textarea điều khoản theo nội dung
        function autosizeTerms() {
            var ta = document.getElementById('terms');
            if (!ta) return;
            ta.style.height = 'auto';
            ta.style.height = Math.min(ta.scrollHeight, 400) + 'px'; // giới hạn tối đa ~400px
        }
        $(document).on('input', '#terms', autosizeTerms);
        $('#contractModal').on('shown.bs.modal', function() { autosizeTerms(); });
        // Cập nhật counter khi mở modal (sau khi DOM trong modal sẵn sàng)
        $('#contractModal').on('shown.bs.modal', function() {
            updateCounters();
        });
        
        function checkContractNumberExists(contractNumber) {
            if (!contractNumber || contractNumber.trim() === '') return;
            
            $.get('api/contracts', { action: 'check_contract_number', contractNumber: contractNumber }, function(resp) {
                if (resp.exists) {
                    showFieldError('contractNumber', 'Số hợp đồng "' + contractNumber + '" đã tồn tại. Vui lòng chọn số khác.');
                } else if (resp.existsInTrash) {
                    showFieldError('contractNumber', 'Số hợp đồng "' + contractNumber + '" đã tồn tại trong thùng rác. Vui lòng chọn số khác hoặc khôi phục hợp đồng cũ.');
                } else {
                    $('#contractNumberError').hide();
                    $('#contractNumber').removeClass('has-error');
                }
            }, 'json').fail(function() {
                // Nếu không kiểm tra được, ẩn lỗi
                $('#contractNumberError').hide();
                $('#contractNumber').removeClass('has-error');
            });
        }
        
        $(document).on('change', '#customerId', function() {
            var value = $(this).val();
            if (value === '') {
                showFieldError('customerId', 'Vui lòng chọn khách hàng');
            } else {
                $('#customerIdError').hide();
                $(this).removeClass('has-error');
            }
        });
        
        // Fix dropdown bị che bởi modal backdrop
        // Với native select, dropdown options được render bởi browser ở một layer riêng
        // Cần làm backdrop trong suốt tạm thời khi mở dropdown
        var customerSelectTimeout;
        
        $(document).on('mousedown click', '#contractModal select#customerId', function(e) {
            // Thêm class để làm backdrop trong suốt
            $('body').addClass('selecting-customer');
            // Đảm bảo modal có z-index cao
            $('#contractModal').css('z-index', '1051');
            // Clear timeout cũ nếu có
            clearTimeout(customerSelectTimeout);
        });
        
        // Khôi phục backdrop khi select đóng (blur hoặc change)
        $(document).on('blur change', '#contractModal select#customerId', function() {
            // Đợi một chút để đảm bảo dropdown đã đóng hoàn toàn
            clearTimeout(customerSelectTimeout);
            customerSelectTimeout = setTimeout(function() {
                $('body').removeClass('selecting-customer');
            }, 200);
        });
        
        // Khôi phục backdrop khi click vào modal (nhưng không phải select)
        $(document).on('click', '#contractModal', function(e) {
            // Nếu click không phải vào select hoặc option
            if (!$(e.target).is('select#customerId') && !$(e.target).closest('select#customerId').length) {
                clearTimeout(customerSelectTimeout);
                customerSelectTimeout = setTimeout(function() {
                    $('body').removeClass('selecting-customer');
                }, 100);
            }
        });
        
        // Khôi phục backdrop khi modal đóng
        $('#contractModal').on('hidden.bs.modal', function() {
            $('body').removeClass('selecting-customer');
            clearTimeout(customerSelectTimeout);
        });
        
        // Format số khi focus (bỏ dấu phẩy để dễ nhập)
        $(document).on('focus', '#contractValue', function() {
            var value = $(this).val();
            if (value) {
                // Bỏ dấu phẩy và chỉ giữ số
                var numValue = value.toString().replace(/[^\d]/g, '');
                $(this).val(numValue);
            }
        });
        
        // Format số khi blur (thêm dấu phẩy ngăn cách hàng nghìn)
        $(document).on('blur', '#contractValue', function() {
            var value = $(this).val();
            if (value !== '') {
                // Bỏ tất cả ký tự không phải số
                var numValue = parseFloat(value.toString().replace(/[^\d]/g, '')) || 0;
                if (numValue < 0) {
                    showFieldError('contractValue', 'Giá trị hợp đồng phải là số dương');
                    $(this).val('');
                } else {
                    // Format số với dấu phẩy ngăn cách hàng nghìn (không có dấu thập phân)
                    $(this).val(formatCurrency(numValue));
                    $('#contractValueError').hide();
                    $(this).removeClass('has-error');
                    // Kiểm tra khớp với tổng sản phẩm
                    checkContractValueMatch();
                }
            }
        });
        
        // Kiểm tra khi user nhập giá trị hợp đồng (chỉ cho phép số)
        $(document).on('input', '#contractValue', function() {
            // Clear error khi user đang nhập
            $('#contractValueError').hide();
            $(this).removeClass('has-error');
        });
        
        $(document).on('change', '#signedDate, #endDate', function() {
            var signedDate = $('#signedDate').val();
            var endDate = $('#endDate').val();
            var status = $('#status').val();
            
            // Chỉ validate khi status = "terminated" và có cả 2 ngày
            if (status === 'terminated' && signedDate && endDate) {
                var signed = new Date(signedDate);
                var end = new Date(endDate);
                if (end < signed) {
                    showFieldError('endDate', 'Ngày chấm dứt không được trước ngày ký');
                } else {
                    $('#endDateError').hide();
                    $('#endDate').removeClass('has-error');
                }
            }
        });
        
        // Trigger change status khi mở modal để cập nhật required
        $('#contractModal').on('show.bs.modal', function() {
            // Đợi một chút để đảm bảo form đã load
            setTimeout(function() {
                $('#status').trigger('change');
            }, 100);
        });

        // Hiển thị/ẩn endDate và cập nhật thời hạn khi thay đổi trạng thái
        $(document).on('change', '#status', function() {
            var status = $(this).val();
            var endDateGroup = $('#endDateGroup');
            var endDateInput = $('#endDate');
            var contractDuration = $('#contractDuration');
            var signedDateInput = $('#signedDate');
            var signedDateRequired = $('#signedDateRequired');
            var titleInput = $('#title');
            var titleRequired = $('#titleRequired');
            var termsInput = $('#terms');
            var termsRequired = $('#termsRequired');
            
            // Cập nhật required và label cho signedDate
            if (status === 'draft') {
                // Nháp: không bắt buộc ngày ký
                signedDateInput.prop('required', false);
                signedDateRequired.hide();
            } else {
                // Các trạng thái khác: bắt buộc ngày ký
                signedDateInput.prop('required', true);
                signedDateRequired.show();
            }
            
            // Cập nhật required cho Tiêu đề và Điều khoản khi status = "active"
            if (status === 'active') {
                titleInput.prop('required', true);
                if (titleRequired.length > 0) {
                    titleRequired.show();
                }
                termsInput.prop('required', true);
                if (termsRequired.length > 0) {
                    termsRequired.show();
                }
            } else {
                titleInput.prop('required', false);
                if (titleRequired.length > 0) {
                    titleRequired.hide();
                }
                termsInput.prop('required', false);
                if (termsRequired.length > 0) {
                    termsRequired.hide();
                }
            }
            
            if (status === 'terminated') {
                // Hiển thị trường endDate
                endDateGroup.show();
                endDateInput.prop('required', true);
                
                // Nếu chưa có endDate, set hôm nay
                var currentEnd = endDateInput.val();
                if (!currentEnd) {
                    var today = new Date();
                    var m = (today.getMonth() + 1).toString().padStart(2, '0');
                    var d = today.getDate().toString().padStart(2, '0');
                    var iso = today.getFullYear() + '-' + m + '-' + d;
                    endDateInput.val(iso);
                }
                
                // Cập nhật label thời hạn
                contractDuration.val('Có thời hạn');
            } else {
                // Ẩn trường endDate
                endDateGroup.hide();
                endDateInput.prop('required', false);
                endDateInput.val('');
                $('#endDateError').hide();
                endDateInput.removeClass('has-error');
                
                // Cập nhật label thời hạn
                contractDuration.val('Vô thời hạn');
            }
        });
        
        // Khi mở modal, kiểm tra status hiện tại để hiển thị endDate và cập nhật required cho signedDate
        $('#contractModal').on('shown.bs.modal', function() {
            var status = $('#status').val();
            var signedDateInput = $('#signedDate');
            var signedDateRequired = $('#signedDateRequired');
            var titleInput = $('#title');
            var titleRequired = $('#titleRequired');
            var termsInput = $('#terms');
            var termsRequired = $('#termsRequired');
            
            // Cập nhật required cho signedDate
            if (status === 'draft') {
                signedDateInput.prop('required', false);
                signedDateRequired.hide();
            } else {
                signedDateInput.prop('required', true);
                signedDateRequired.show();
            }
            
            // Cập nhật required cho Tiêu đề và Điều khoản khi status = "active"
            if (status === 'active') {
                titleInput.prop('required', true);
                if (titleRequired.length > 0) {
                    titleRequired.show();
                }
                termsInput.prop('required', true);
                if (termsRequired.length > 0) {
                    termsRequired.show();
                }
            } else {
                titleInput.prop('required', false);
                if (titleRequired.length > 0) {
                    titleRequired.hide();
                }
                termsInput.prop('required', false);
                if (termsRequired.length > 0) {
                    termsRequired.hide();
                }
            }
            
            // Cập nhật endDate
            if (status === 'terminated') {
                $('#endDateGroup').show();
                $('#endDate').prop('required', true);
                $('#contractDuration').val('Có thời hạn');
            } else {
                $('#endDateGroup').hide();
                $('#endDate').prop('required', false);
                $('#contractDuration').val('Vô thời hạn');
            }
        });

        // Event handler cho dropdown sản phẩm
        $(document).on('change', '#newProductId', function() {
            var selectedOption = $(this).find('option:selected');
            var description = selectedOption.data('description') || '';
            var unitPrice = selectedOption.data('unitprice') || 0;
            var warranty = selectedOption.data('warranty');
            var availableQuantity = parseFloat(selectedOption.data('quantity')) || 0;

            $('#newDescription').val(description);
            $('#newUnitPrice').val(formatCurrency(unitPrice));
            if (warranty !== undefined && warranty !== null && warranty !== '') {
                $('#newWarrantyMonths').val(warranty);
            } else {
                $('#newWarrantyMonths').val('');
            }

            // Hiển thị thông tin tồn kho
            updateStockInfo(availableQuantity);

            // Tính thành tiền
            calculateLineTotal();
        });

        // Event handler cho số lượng
        $(document).on('input', '#newQuantity', function() {
            calculateLineTotal();
            // Kiểm tra tồn kho khi nhập số lượng
            checkStockAvailability();
        });

        // Tính thành tiền
        function calculateLineTotal() {
            var quantity = parseFloat($('#newQuantity').val()) || 0;
            var unitPrice = parseFloat($('#newUnitPrice').val().replace(/[.,\s]/g, '')) || 0;
            var lineTotal = quantity * unitPrice;
            $('#newLineTotal').val(formatCurrency(lineTotal));
        }

        // Cập nhật giá trị hợp đồng từ tổng sản phẩm
        function updateContractValueFromProducts() {
            var total = 0;
            contractProducts.forEach(function(product) {
                total += (parseFloat(product.quantity) || 0) * (parseFloat(product.unitPrice) || 0);
            });
            $('#contractValue').val(formatCurrency(total));
            previousTotalValue = total; // Lưu lại để so sánh
            checkContractValueMatch(); // Ẩn cảnh báo vì đã khớp
            showModalAlert('Đã cập nhật giá trị hợp đồng: ' + formatCurrency(total) + ' VNĐ', 'success');
        }

        // Event handlers cho modal thùng rác
        $(document).on('change', '#deletedPageSize', function() {
            deletedContractsCurrentPage = 1;
            loadDeletedContracts();
        });

        $(document).on('change', '#deletedSortBy, #deletedSortDir', function() {
            deletedContractsCurrentPage = 1;
            loadDeletedContracts();
        });

        $(document).on('keypress', '#deletedSearch', function(e) {
            if (e.which === 13) { // Enter key
                deletedContractsCurrentPage = 1;
                loadDeletedContracts();
            }
        });
    </script>
</body>
</html>


