<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Set, com.hlgenerator.model.Customer, com.hlgenerator.servlet.CustomerManagementServlet.CustomerHelper" %>
<%
    // Kiểm tra đăng nhập
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Kiểm tra quyền: chỉ người có quyền manage_customers mới truy cập được
    @SuppressWarnings("unchecked")
    Set<String> userPermissions = (Set<String>) session.getAttribute("userPermissions");
    if (userPermissions == null || !userPermissions.contains("manage_customers")) {
        response.sendRedirect(request.getContextPath() + "/error/403.jsp");
        return;
    }
    
    // Lấy dữ liệu từ request attributes (đã được set bởi servlet)
    @SuppressWarnings("unchecked")
    List<Customer> filteredCustomers = (List<Customer>) request.getAttribute("filteredCustomers");
    @SuppressWarnings("unchecked")
    Set<String> customerTypes = (Set<String>) request.getAttribute("customerTypes");
    @SuppressWarnings("unchecked")
    Set<String> statuses = (Set<String>) request.getAttribute("statuses");
    String pCode = (String) request.getAttribute("filterCode");
    String pType = (String) request.getAttribute("filterType");
    String pStatus = (String) request.getAttribute("filterStatus");
    String pContact = (String) request.getAttribute("filterContact");
    String pAddress = (String) request.getAttribute("filterAddress");
%>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Quản lý khách hàng</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <!-- CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="css/datatables/dataTables.bootstrap.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css" rel="stylesheet" type="text/css" />
    
    <style>
        .filter-section {
            background: #f9f9f9;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        
        :root {
            --btn-padding: 4px 12px;
            --btn-radius: 4px;
            --btn-transition: all 0.15s ease;
            --shadow-light: 0 2px 4px;
            --shadow-hover: 0 4px 8px;
        }
        
        /* Alert Styles */
        .alert {
            margin-bottom: 15px;
            border: none;
            border-radius: 4px;
            padding: 15px 35px 15px 15px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .alert-success {
            background-color: #dff0d8;
            color: #3c763d;
            border-left: 4px solid #3c763d;
        }
        
        .alert-danger {
            background-color: #f2dede;
            color: #a94442;
            border-left: 4px solid #a94442;
        }
        
        .alert-warning {
            background-color: #fcf8e3;
            color: #8a6d3b;
            border-left: 4px solid #8a6d3b;
        }
        
        .alert-info {
            background-color: #d9edf7;
            color: #31708f;
            border-left: 4px solid #31708f;
        }
        
        .alert .close {
            position: relative;
            top: -2px;
            right: -25px;
            color: inherit;
        }
        
        .action-buttons {
            white-space: nowrap;
            min-width: 200px;
            max-width: 250px;
        }
        
        .action-buttons .btn-group {
            display: flex;
            gap: 4px;
            width: 100%;
        }
        
        .action-buttons .btn {
            padding: var(--btn-padding);
            font-size: 11px;
            font-weight: 500;
            border-radius: var(--btn-radius);
            border: none;
            transition: var(--btn-transition);
            text-transform: none;
            letter-spacing: 0.3px;
            flex: 1;
            min-width: 60px;
            text-align: center;
        }
        
        .action-buttons .dropdown-menu {
            min-width: 180px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            border: none;
            border-radius: 6px;
            padding: 5px 0;
        }
        
        .action-buttons .dropdown-menu li a {
            padding: 8px 15px;
            font-size: 12px;
            color: #333;
            transition: var(--btn-transition);
        }
        
        .action-buttons .dropdown-menu li a:hover {
            background-color: #f8f9fa;
            color: #000;
        }
        
        .action-buttons .dropdown-menu .divider {
            margin: 5px 0;
            background-color: #e9ecef;
        }
        
        .action-buttons .btn i {
            margin-right: 4px;
            font-size: 10px;
        }
        
        /* Button colors */
        .action-buttons .btn-info { background: linear-gradient(135deg, #3498db, #2980b9); color: white; box-shadow: var(--shadow-light) rgba(52, 152, 219, 0.3); }
        .action-buttons .btn-info:hover { background: linear-gradient(135deg, #2980b9, #21618c); transform: translateY(-1px); box-shadow: var(--shadow-hover) rgba(52, 152, 219, 0.4); }
        .action-buttons .btn-warning { background: linear-gradient(135deg, #f39c12, #e67e22); color: white; box-shadow: var(--shadow-light) rgba(243, 156, 18, 0.3); }
        .action-buttons .btn-warning:hover { background: linear-gradient(135deg, #e67e22, #d35400); transform: translateY(-1px); box-shadow: var(--shadow-hover) rgba(243, 156, 18, 0.4); }
        .action-buttons .btn-primary { background: linear-gradient(135deg, #9b59b6, #8e44ad); color: white; box-shadow: var(--shadow-light) rgba(155, 89, 182, 0.3); }
        .action-buttons .btn-primary:hover { background: linear-gradient(135deg, #8e44ad, #7d3c98); transform: translateY(-1px); box-shadow: var(--shadow-hover) rgba(155, 89, 182, 0.4); }
        .action-buttons .btn-success { background: linear-gradient(135deg, #27ae60, #229954); color: white; box-shadow: var(--shadow-light) rgba(39, 174, 96, 0.3); }
        .action-buttons .btn-success:hover { background: linear-gradient(135deg, #229954, #1e8449); transform: translateY(-1px); box-shadow: var(--shadow-hover) rgba(39, 174, 96, 0.4); }
        .action-buttons .btn-danger { background: linear-gradient(135deg, #e74c3c, #c0392b); color: white; box-shadow: var(--shadow-light) rgba(231, 76, 60, 0.3); }
        .action-buttons .btn-danger:hover { background: linear-gradient(135deg, #c0392b, #a93226); transform: translateY(-1px); box-shadow: var(--shadow-hover) rgba(231, 76, 60, 0.4); }
        
        .action-buttons .btn:focus { outline: none; box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25); }
        .action-buttons .btn:active { transform: translateY(0); box-shadow: 0 1px 2px rgba(0,0,0,0.2); }
        
        @media (max-width: 768px) {
            .action-buttons { min-width: 160px; max-width: 180px; }
            .action-buttons .btn { padding: 3px 6px; font-size: 10px; }
        }
        
        /* Readonly field styling */
        .bg-gray-light {
            background-color: #f4f4f4 !important;
            cursor: not-allowed !important;
            border-color: #ddd !important;
        }
        
        input[readonly].bg-gray-light {
            opacity: 0.8;
        }
        
        /* Style cho modal khách hàng chờ */
        #waitingCustomersModal .modal-dialog {
            width: 95%;
            max-width: 1400px;
        }
        
        #waitingCustomersModal .table {
            margin-bottom: 0;
        }
        
        #waitingCustomersModal .table thead th {
            background-color: #f5f5f5;
            color: #333;
            font-weight: 600;
            border-bottom: 2px solid #ddd;
            padding: 12px 8px;
            text-align: left;
            white-space: nowrap;
        }
        
        #waitingCustomersModal .table tbody tr {
            transition: background-color 0.2s;
        }
        
        #waitingCustomersModal .table tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        
        #waitingCustomersModal .table tbody tr:nth-child(odd) {
            background-color: #ffffff;
        }
        
        #waitingCustomersModal .table tbody tr:hover {
            background-color: #e8f4f8;
        }
        
        #waitingCustomersModal .table td {
            padding: 10px 8px;
            vertical-align: middle;
            border-bottom: 1px solid #e0e0e0;
        }
        
        #waitingCustomersModal .table td a {
            color: #337ab7;
            text-decoration: none;
        }
        
        #waitingCustomersModal .table td a:hover {
            color: #23527c;
            text-decoration: underline;
        }
        
        #waitingCustomersModal .label {
            padding: 4px 8px;
            font-size: 11px;
            font-weight: 500;
        }
        
        #waitingCustomersModal .action-buttons .btn {
            margin: 0 2px;
            padding: 4px 10px;
            font-size: 11px;
            min-width: 80px;
        }
        
        #waitingCustomersModal .action-buttons .btn-success {
            background-color: #5cb85c;
            border-color: #4cae4c;
        }
        
        #waitingCustomersModal .action-buttons .btn-success:hover {
            background-color: #449d44;
            border-color: #398439;
        }
        
        #waitingCustomersModal .action-buttons .btn-danger {
            background-color: #d9534f;
            border-color: #d43f3a;
        }
        
        #waitingCustomersModal .action-buttons .btn-danger:hover {
            background-color: #c9302c;
            border-color: #ac2925;
        }
        
        #waitingCustomersModal .alert-info {
            background-color: #d9edf7;
            border-color: #bce8f1;
            color: #31708f;
            padding: 10px 15px;
            margin-top: 15px;
            border-radius: 4px;
        }
        
        #waitingCustomersModal .table-responsive {
            max-height: 600px;
            overflow-y: auto;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        
        #waitingCustomersModal .table td[style*="word-wrap"] {
            max-width: 300px;
            word-wrap: break-word;
            word-break: break-word;
            white-space: normal;
        }
    </style>
</head>

<body class="skin-black">
    <!-- Header -->
    <header class="header">
        <a href="customers" class="logo">Quản lý khách hàng</a>
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
                                    Cài đặt cá nhân
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
        <!-- Left side column. contains the logo and sidebar -->
		<jsp:include page="partials/sidebar.jsp"/>

        <!-- Main Content -->
        <aside class="right-side">
            <section class="content">
                <div class="row">
                    <div class="col-xs-12">
                        <div class="panel">
                            <header class="panel-heading">
                                <h3>Quản lý khách hàng</h3>
                                <div class="panel-tools">
                                    <button class="btn btn-warning btn-sm" onclick="showWaitingCustomers()" style="margin-right: 5px;">
                                        <i class="fa fa-clock-o"></i> Khách hàng chờ
                                    </button>
                                    <button class="btn btn-primary btn-sm" data-toggle="modal"
                                            data-target="#addCustomerModal">
                                        <i class="fa fa-plus"></i> Thêm khách hàng mới
                                    </button>
                                </div>
                            </header>
                            
                            <div class="panel-body table-responsive">
                                
                                <!-- Filter Section -->
                                <div class="filter-section" style="background: #f9f9f9; padding: 15px; margin-bottom: 20px; border-radius: 5px;">
                                    <form method="GET" action="customers" accept-charset="UTF-8">
                                        <div class="row">
                                            <div class="col-md-2">
                                                <label>Loại khách hàng:</label>
                                                <select name="customerType" class="form-control">
                                                    <option value="">Tất cả</option>
                                                    <% 
                                                    if (customerTypes != null) {
                                                        for (String raw : customerTypes) { 
                                                            String label = CustomerHelper.typeLabel(raw);
                                                    %>
                                                    <option value="<%= raw %>" <%= (pType != null && pType.equalsIgnoreCase(raw)) ? "selected" : "" %>>
                                                        <%= label %>
                                                    </option>
                                                    <% 
                                                        } 
                                                    }
                                                    %>
                                                </select>
                                            </div>
                                            <div class="col-md-2">
                                                <label>Trạng thái:</label>
                                                <select name="status" class="form-control">
                                                    <option value="">Tất cả</option>
                                                    <% 
                                                    if (statuses != null) {
                                                        for (String raw : statuses) { 
                                                            String label = CustomerHelper.statusLabel(raw);
                                                    %>
                                                    <option value="<%= raw %>" <%= (pStatus != null && pStatus.equalsIgnoreCase(raw)) ? "selected" : "" %>>
                                                        <%= label %>
                                                    </option>
                                                    <% 
                                                        } 
                                                    }
                                                    %>
                                                </select>
                                            </div>
                                            <div class="col-md-4">
                                                <label>Tìm kiếm:</label>
                                                <input type="text" class="form-control" name="q" placeholder="ID, mã KH, tên công ty, email, SĐT, địa chỉ" value="<%= request.getAttribute("search") != null && !((String)request.getAttribute("search")).isEmpty() ? (String)request.getAttribute("search") : "" %>">
                                            </div>
                                            <div class="col-md-1">
                                                <label>Hiển thị:</label>
                                                <%
                                                    int _sz = 10;
                                                    try { 
                                                        String sp = request.getParameter("size"); 
                                                        if (sp != null) _sz = Integer.parseInt(sp); 
                                                    } catch (Exception ignored) {}
                                                %>
                                                <select name="size" class="form-control" onchange="this.form.submit()">
                                                    <option value="5" <%= _sz == 5 ? "selected" : "" %>>5</option>
                                                    <option value="10" <%= _sz == 10 ? "selected" : "" %>>10</option>
                                                    <option value="25" <%= _sz == 25 ? "selected" : "" %>>25</option>
                                                    <option value="50" <%= _sz == 50 ? "selected" : "" %>>50</option>
                                                    <option value="100" <%= _sz == 100 ? "selected" : "" %>>100</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row" style="margin-top: 10px;">
                                            <div class="col-md-12">
                                                <button type="submit" class="btn btn-primary">
                                                    <i class="fa fa-filter"></i> Lọc
                                                </button>
                                                <a href="customers" class="btn btn-default">
                                                    <i class="fa fa-refresh"></i> Xóa bộ lọc
                                                </a>
                                            </div>
                                        </div>
                                        <div class="row" style="margin-top: 5px;">
                                            <div class="col-md-12 text-right">
                                                <span class="text-muted">Tổng số: <strong>${totalCustomers}</strong> khách hàng</span>
                                            </div>
                                        </div>
                                        <input type="hidden" name="page" value="1">
                                    </form>
                                </div>
                                
                                <div class="table-responsive">
                                    <table class="table table-striped table-bordered table-hover" id="customersTable">
                                        <thead>
                                            <tr>
                                                <th class="sortable" data-sort="id" style="cursor: pointer;">
                                                    ID <i class="fa fa-sort sort-icon" style="color: #ccc; margin-left: 5px;"></i>
                                                </th>
                                                <th class="sortable" data-sort="customer_code" style="cursor: pointer;">
                                                    Mã khách hàng <i class="fa fa-sort sort-icon" style="color: #ccc; margin-left: 5px;"></i>
                                                </th>
                                                <th class="sortable" data-sort="company_name" style="cursor: pointer;">
                                                    Tên công ty <i class="fa fa-sort sort-icon" style="color: #ccc; margin-left: 5px;"></i>
                                                </th>
                                                <th class="sortable" data-sort="contact_person" style="cursor: pointer;">
                                                    Người liên hệ <i class="fa fa-sort sort-icon" style="color: #ccc; margin-left: 5px;"></i>
                                                </th>
                                                <th class="sortable" data-sort="email" style="cursor: pointer;">
                                                    Email <i class="fa fa-sort sort-icon" style="color: #ccc; margin-left: 5px;"></i>
                                                </th>
                                                <th class="sortable" data-sort="phone" style="cursor: pointer;">
                                                    Số điện thoại <i class="fa fa-sort sort-icon" style="color: #ccc; margin-left: 5px;"></i>
                                                </th>
                                                <th class="sortable" data-sort="address" style="cursor: pointer;">
                                                    Địa chỉ <i class="fa fa-sort sort-icon" style="color: #ccc; margin-left: 5px;"></i>
                                                </th>
                                                <th class="sortable" data-sort="tax_code" style="cursor: pointer;">
                                                    Mã số thuế <i class="fa fa-sort sort-icon" style="color: #ccc; margin-left: 5px;"></i>
                                                </th>
                                                <th class="sortable" data-sort="customer_type" style="cursor: pointer;">
                                                    Loại khách hàng <i class="fa fa-sort sort-icon" style="color: #ccc; margin-left: 5px;"></i>
                                                </th>
                                                <th class="sortable" data-sort="status" style="cursor: pointer;">
                                                    Trạng thái <i class="fa fa-sort sort-icon" style="color: #ccc; margin-left: 5px;"></i>
                                                </th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody id="customersTableBody">
                                            <% 
                                            if (filteredCustomers != null && !filteredCustomers.isEmpty()) {
                                                for (Customer customer : filteredCustomers) { 
                                                    if (customer == null) continue;
                                            %>
                                            <tr data-customer-id="<%= customer.getId() %>">
                                                <td><%= customer.getId() %></td>
                                                <td><%= customer.getCustomerCode() != null ? customer.getCustomerCode() : "" %></td>
                                                <td><%= customer.getCompanyName() != null ? customer.getCompanyName() : "" %></td>
                                                <td><%= customer.getContactPerson() != null ? customer.getContactPerson() : "" %></td>
                                                <td><%= customer.getEmail() != null ? customer.getEmail() : "" %></td>
                                                <td><%= customer.getPhone() != null ? customer.getPhone() : "" %></td>
                                                <td><%= customer.getAddress() != null ? customer.getAddress() : "" %></td>
                                                <td><%= customer.getTaxCode() != null ? customer.getTaxCode() : "" %></td>
                                                <td><%= CustomerHelper.typeLabel(customer.getCustomerType()) %></td>
                                                <td><%= CustomerHelper.statusLabel(customer.getStatus()) %></td>
                                                <td>
                                                    <div class="action-buttons">
                                                        <div class="btn-group">
                                                            <!-- Nút Xem -->
                                                            <button class="btn btn-info btn-xs" onclick="viewCustomer('<%= customer.getId() %>')" title="Xem chi tiết">
                                                                <i class="fa fa-eye"></i> Xem
                                                            </button>
                                                            <!-- Nút Sửa với dropdown -->
                                                            <div class="btn-group">
                                                                <button class="btn btn-warning btn-xs dropdown-toggle" data-toggle="dropdown" title="Chỉnh sửa">
                                                                    <i class="fa fa-edit"></i> Sửa <span class="caret"></span>
                                                                </button>
                                                                <ul class="dropdown-menu">
                                                                    <li><a href="#" onclick="editCustomer('<%= customer.getId() %>')"><i class="fa fa-edit"></i> Chỉnh sửa thông tin</a></li>
                                                                    <li class="divider"></li>
                                                                    <% if ("active".equals(customer.getStatus())) { %>
                                                                        <li><a href="#" onclick="deactivateCustomer('<%= customer.getId() %>')" style="color: #f39c12;"><i class="fa fa-lock"></i> Tạm khóa</a></li>
                                                                    <% } else { %>
                                                                        <li><a href="#" onclick="activateCustomer('<%= customer.getId() %>')" style="color: #27ae60;"><i class="fa fa-unlock"></i> Kích hoạt</a></li>
                                                                    <% } %>
                                                                    <li><a href="#" onclick="hardDeleteCustomer('<%= customer.getId() %>')" style="color: #e74c3c;"><i class="fa fa-trash"></i> Xóa vĩnh viễn</a></li>
                                                                </ul>
                                                            </div>
                                                            <!-- Nút Xóa -->
                                                            <button class="btn btn-danger btn-xs" onclick="deleteCustomer('<%= customer.getId() %>')" title="Xóa tạm thời">
                                                                <i class="fa fa-trash-o"></i> Xóa
                                                            </button>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <% 
                                                }
                                            } else {
                                            %>
                                            <tr>
                                                <td colspan="11" class="text-center">
                                                    <p class="text-muted">Không có khách hàng nào.</p>
                                                </td>
                                            </tr>
                                            <% 
                                            }
                                            %>
                                        </tbody>
                                    </table>
                                </div>
                                
                                <!-- Phân trang -->
                                <div class="row" style="margin-top: 10px;">
                                    <div class="col-md-6">
                                        <div class="text-muted" style="line-height: 34px;">
                                            <%
                                                int _currentPage = (Integer) request.getAttribute("currentPage");
                                                int _pageSize = (Integer) request.getAttribute("pageSize");
                                                int _total = (Integer) request.getAttribute("totalCustomers");
                                                int _startIdx = (_currentPage - 1) * _pageSize + 1;
                                                int _endIdx = Math.min(_currentPage * _pageSize, _total);
                                                if (_total == 0) { 
                                                    _startIdx = 0; 
                                                    _endIdx = 0; 
                                                }
                                            %>
                                            Hiển thị <%= _startIdx %> - <%= _endIdx %> của <%= _total %> khách hàng
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <nav aria-label="Phân trang khách hàng" class="pull-right">
                                            <ul class="pagination pagination-sm" style="margin: 0;">
                                                <%
                                                    // Xây base query giữ nguyên filter
                                                    java.util.List<String> _p = new java.util.ArrayList<String>();
                                                    try { 
                                                        String v = request.getParameter("customerType"); 
                                                        if (v != null && !v.isEmpty()) 
                                                            _p.add("customerType=" + java.net.URLEncoder.encode(v, "UTF-8")); 
                                                    } catch (Exception ignored) {}
                                                    try { 
                                                        String v = request.getParameter("status"); 
                                                        if (v != null && !v.isEmpty()) 
                                                            _p.add("status=" + java.net.URLEncoder.encode(v, "UTF-8")); 
                                                    } catch (Exception ignored) {}
                                                    try { 
                                                        String v = request.getParameter("q"); 
                                                        if (v != null && !v.isEmpty()) 
                                                            _p.add("q=" + java.net.URLEncoder.encode(v, "UTF-8")); 
                                                    } catch (Exception ignored) {}
                                                    _p.add("size=" + _pageSize);
                                                    String _base = "customers" + (_p.isEmpty() ? "" : ("?" + String.join("&", _p)));
                                                    
                                                    int _totalPages = (Integer) request.getAttribute("totalPages");
                                                    
                                                    // Nút prev
                                                    int _prev = Math.max(1, _currentPage - 1);
                                                %>
                                                <li class="<%= _currentPage == 1 ? "disabled" : "" %>">
                                                    <a href="<%= _base + "&page=" + _prev %>">&laquo;</a>
                                                </li>
                                                <%
                                                    int _s = Math.max(1, _currentPage - 2);
                                                    int _e = Math.min(_totalPages, _currentPage + 2);
                                                    if (_s > 1) {
                                                %>
                                                <li><a href="<%= _base + "&page=1" %>">1</a></li>
                                                <%= (_s > 2) ? "<li class=\"disabled\"><span>...</span></li>" : "" %>
                                                <%
                                                    }
                                                    for (int i = _s; i <= _e; i++) {
                                                %>
                                                <li class="<%= i == _currentPage ? "active" : "" %>">
                                                    <a href="<%= _base + "&page=" + i %>"><%= i %></a>
                                                </li>
                                                <%
                                                    }
                                                    if (_e < _totalPages) {
                                                %>
                                                <%= (_e < _totalPages - 1) ? "<li class=\"disabled\"><span>...</span></li>" : "" %>
                                                <li><a href="<%= _base + "&page=" + _totalPages %>"><%= _totalPages %></a></li>
                                                <%
                                                    }
                                                    int _next = Math.min(_totalPages, _currentPage + 1);
                                                %>
                                                <li class="<%= _currentPage == _totalPages ? "disabled" : "" %>">
                                                    <a href="<%= _base + "&page=" + _next %>">&raquo;</a>
                                                </li>
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

    <!-- Modal thêm/sửa khách hàng -->
    <div class="modal fade" id="addCustomerModal" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Thêm khách hàng mới</h4>
                </div>
                <div class="modal-body">
                    <form id="addCustomerForm">
                        <div class="form-group">
                            <label>Mã khách hàng:</label>
                            <input type="text" class="form-control" id="customerCode" maxlength="50" required readonly style="background-color: #f5f5f5; cursor: not-allowed;">
                            <small class="text-muted">Mã khách hàng sẽ được hệ thống sinh tự động</small>
                        </div>
                        <div class="form-group">
                            <button type="button" class="btn btn-warning btn-sm" onclick="showSelectWaitingCustomer()" style="width: 100%;">
                                <i class="fa fa-clock-o"></i> Chọn từ khách hàng chờ
                            </button>
                        </div>
                        <div class="form-group">
                            <label>Tên công ty:</label>
                            <input type="text" class="form-control" id="companyName" maxlength="50">
                        </div>
                        <div class="form-group">
                            <label>Người liên hệ:</label>
                            <input type="text" class="form-control" id="userContract" maxlength="50" required>
                        </div>
                        <div class="form-group">
                            <label>Email: <small class="text-muted"></small></label>
                            <input type="email" class="form-control" id="customerEmail" placeholder="" required>
                        </div>
                        <div class="form-group">
                            <label>Số điện thoại:</label>
                            <input type="tel" class="form-control" id="customerPhone" required>
                        </div>
                        <div class="form-group">
                            <label>Địa chỉ:</label>
                            <textarea class="form-control" id="customerAddress" rows="3" maxlength="100" required></textarea>
                        </div>
                        <div class="form-group">
                            <label>Mã số thuế:</label>
                            <input type="text" class="form-control" id="taxCode" maxlength="100">
                        </div>
                        <div class="form-group">
                            <label>Loại khách hàng:</label>
                            <select class="form-control" id="customerType" required>
                                <option value="">Chọn loại khách hàng</option>
                                <option value="individual">Cá nhân</option>
                                <option value="company">Doanh nghiệp</option>
                            </select>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="saveCustomer()">Lưu khách hàng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal xem chi tiết khách hàng -->
    <div class="modal fade" id="customerDetailModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Chi tiết khách hàng</h4>
                </div>
                <div class="modal-body" id="customerDetailContent">
                    <!-- Nội dung sẽ được load bằng JavaScript -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal danh sách khách hàng chờ -->
    <div class="modal fade" id="waitingCustomersModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Danh sách khách hàng chờ</h4>
                </div>
                <div class="modal-body">
                    <div id="waitingCustomersContent">
                        <p class="text-center"><i class="fa fa-spinner fa-spin"></i> Đang tải...</p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal chọn khách hàng chờ để thêm -->
    <div class="modal fade" id="selectWaitingCustomerModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document" style="width: 95%; max-width: 1400px;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Chọn khách hàng từ danh sách chờ</h4>
                </div>
                <div class="modal-body">
                    <div id="selectWaitingCustomerContent">
                        <p class="text-center"><i class="fa fa-spinner fa-spin"></i> Đang tải...</p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="js/jquery.min.js" type="text/javascript"></script>
    <script src="js/bootstrap.min.js" type="text/javascript"></script>

    <script type="text/javascript">
        var currentEditingCustomer = null;
        var selectedContactId = null; // Lưu contactId khi chọn từ khách hàng chờ
        var currentSortColumn = null;
        var currentSortOrder = 'asc'; // 'asc' hoặc 'desc'

        $(document).ready(function() {
            // Không còn sử dụng DataTables, phân trang được xử lý ở server-side
            
            // Xử lý sắp xếp tĩnh
            $('.sortable').on('click', function() {
                var column = $(this).data('sort');
                var $icon = $(this).find('.sort-icon');
                
                // Nếu click vào cùng cột, đảo ngược thứ tự
                if (currentSortColumn === column) {
                    currentSortOrder = currentSortOrder === 'asc' ? 'desc' : 'asc';
                } else {
                    currentSortColumn = column;
                    currentSortOrder = 'asc';
                }
                
                // Cập nhật icon cho tất cả các cột
                $('.sortable .sort-icon').removeClass('fa-sort-asc fa-sort-desc').addClass('fa-sort').css('color', '#ccc');
                
                // Cập nhật icon cho cột hiện tại
                if (currentSortOrder === 'asc') {
                    $icon.removeClass('fa-sort fa-sort-desc').addClass('fa-sort-asc').css('color', '#3498db');
                } else {
                    $icon.removeClass('fa-sort fa-sort-asc').addClass('fa-sort-desc').css('color', '#3498db');
                }
                
                // Sắp xếp bảng
                sortTable(column, currentSortOrder);
            });
        });
        
        function sortTable(column, order) {
            var columnMap = { 'id': 0, 'customer_code': 1, 'company_name': 2, 'contact_person': 3, 'email': 4, 'phone': 5, 'address': 6, 'tax_code': 7, 'customer_type': 8, 'status': 9 };
            var colIdx = columnMap[column];
            if (colIdx === undefined) return;
            
            var $rows = $('#customersTable tbody tr').toArray();
            $rows.sort(function(a, b) {
                var aVal = $(a).find('td').eq(colIdx).text().trim();
                var bVal = $(b).find('td').eq(colIdx).text().trim();
                
                if (column === 'id') {
                    return order === 'asc' ? (parseInt(aVal) || 0) - (parseInt(bVal) || 0) : (parseInt(bVal) || 0) - (parseInt(aVal) || 0);
                }
                if (column === 'phone') {
                    var aNum = aVal.replace(/\D/g, ''), bNum = bVal.replace(/\D/g, '');
                    if (aNum && bNum) return order === 'asc' ? aNum.localeCompare(bNum) : bNum.localeCompare(aNum);
                }
                var cmp = aVal.localeCompare(bVal, 'vi', { sensitivity: 'base' });
                return order === 'asc' ? cmp : -cmp;
            });
            $('#customersTable tbody').empty().append($rows);
        }

        function viewCustomer(id) {
            $.ajax({
                url: 'api/customers?action=get&id=' + id,
                type: 'GET',
                dataType: 'json',
                    success: function (response) {
                    if (response.success) {
                        var customer = response.data;
                        var content = '<div class="row">' +
                            '<div class="col-md-6"><h5>Thông tin cơ bản</h5>' +
                            '<p><strong>ID:</strong> ' + customer.id + '</p>' +
                            '<p><strong>Mã khách hàng:</strong> ' + customer.customerCode + '</p>' +
                            '<p><strong>Tên công ty:</strong> ' + customer.companyName + '</p>' +
                            '<p><strong>Người liên hệ:</strong> ' + customer.contactPerson + '</p>' +
                            '<p><strong>Email:</strong> ' + customer.email + '</p>' +
                            '<p><strong>Số điện thoại:</strong> ' + customer.phone + '</p>' +
                            '<p><strong>Địa chỉ:</strong> ' + customer.address + '</p>' +
                            '</div>' +
                            '<div class="col-md-6"><h5>Thông tin bổ sung</h5>' +
                            '<p><strong>Mã số thuế:</strong> ' + (customer.taxCode || '-') + '</p>' +
                            '<p><strong>Loại khách hàng:</strong> ' + (customer.customerType === 'company' ? 'Doanh nghiệp' : 'Cá nhân') + '</p>' +
                            '<p><strong>Trạng thái:</strong> ' + (customer.status === 'active' ? 'Hoạt động' : 'Tạm khóa') + '</p>' +
                            '</div></div>';
                        $('#customerDetailContent').html(content);
                        $('#customerDetailModal').modal('show');
                    } else {
                        alert('Không thể tải thông tin khách hàng: ' + response.message);
                    }
                },
                    error: function () {
                    alert('Lỗi kết nối đến server');
                }
            });
        }

        function editCustomer(id) {
            $.ajax({
                url: 'api/customers?action=get&id=' + id,
                type: 'GET',
                dataType: 'json',
                    success: function (response) {
                    if (response.success) {
                        var customer = response.data;
                        $('#customerCode').val(customer.customerCode);
                        // Đảm bảo trường mã khách hàng luôn readonly khi edit
                        $('#customerCode').prop('readonly', true);
                        $('#customerCode').css({'background-color': '#f5f5f5', 'cursor': 'not-allowed'});
                        $('#companyName').val(customer.companyName);
                        $('#userContract').val(customer.contactPerson);
                        $('#customerEmail').val(customer.email);
                        $('#customerPhone').val(customer.phone);
                        $('#customerAddress').val(customer.address);
                        $('#taxCode').val(customer.taxCode || '');
                        $('#customerType').val(customer.customerType);
                        currentEditingCustomer = customer;
                        $('#addCustomerModal .modal-title').text('Chỉnh sửa khách hàng');
                        // Show permanent delete button when editing
                        $('.btn-danger', '#addCustomerModal').show();
                        $('#addCustomerModal').modal('show');
                    } else {
                        alert('Không thể tải thông tin khách hàng: ' + response.message);
                    }
                },
                    error: function () {
                    alert('Lỗi kết nối đến server');
                }
            });
        }

        function deleteCustomer(id) {
            if (confirm('Bạn có chắc chắn muốn xóa tạm thời khách hàng này?')) {
                $.ajax({
                    url: 'api/customers',
                    type: 'POST',
                    data: { action: 'delete', id: id },
                    dataType: 'json',
                        success: function (response) {
                        if (response.success) {
                            alert('Đã xóa tạm thời khách hàng thành công');
                            location.reload();
                        } else {
                            alert('Lỗi khi xóa khách hàng: ' + response.message);
                        }
                    },
                        error: function () {
                        alert('Lỗi kết nối đến server');
                    }
                });
            }
        }

        function activateCustomer(id) {
            if (confirm('Bạn có chắc chắn muốn kích hoạt khách hàng này?')) {
                $.ajax({
                    url: 'api/customers',
                    type: 'POST',
                    data: { action: 'activate', id: id },
                    dataType: 'json',
                        success: function (response) {
                        if (response.success) {
                            alert('Đã kích hoạt khách hàng thành công');
                            location.reload();
                        } else {
                            alert('Lỗi khi kích hoạt khách hàng: ' + response.message);
                        }
                    },
                        error: function () {
                        alert('Lỗi kết nối đến server');
                    }
                });
            }
        }

        function deactivateCustomer(id) {
            if (confirm('Bạn có chắc chắn muốn tạm khóa khách hàng này?')) {
                $.ajax({
                    url: 'api/customers',
                    type: 'POST',
                    data: { action: 'deactivate', id: id },
                    dataType: 'json',
                        success: function (response) {
                        if (response.success) {
                            alert('Đã tạm khóa khách hàng thành công');
                            location.reload();
                        } else {
                            alert('Lỗi khi tạm khóa khách hàng: ' + response.message);
                        }
                    },
                        error: function () {
                        alert('Lỗi kết nối đến server');
                    }
                });
            }
        }

        function hardDeleteCustomer(id) {
            if (confirm('⚠️ CẢNH BÁO: Bạn có chắc chắn muốn XÓA VĨNH VIỄN khách hàng này?\n\n' +
                       'Hành động này KHÔNG THỂ HOÀN TÁC!\n' +
                       'Tất cả dữ liệu liên quan đến khách hàng này sẽ bị xóa vĩnh viễn.\n\n' +
                       'Nhập "XÓA" để xác nhận:')) {
                
                var confirmation = prompt('Nhập "XÓA" để xác nhận xóa vĩnh viễn:');
                if (confirmation === 'XÓA') {
                    $.ajax({
                        url: 'api/customers',
                        type: 'POST',
                        data: {
                            action: 'hardDelete',
                            id: id
                        },
                        dataType: 'json',
                        success: function(response) {
                            if (response.success) {
                                showAlert('Đã xóa vĩnh viễn khách hàng thành công', 'success');
                                location.reload();
                            } else {
                                showAlert('Lỗi khi xóa vĩnh viễn khách hàng: ' + response.message, 'danger');
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error('AJAX Error:', xhr.responseText);
                            showAlert('Lỗi kết nối đến server: ' + error, 'danger');
                        }
                    });
                } else {
                    showAlert('Hủy bỏ xóa vĩnh viễn', 'info');
                }
            }
        }
        
        // Global showAlert/toast is provided by js/notify.js (loaded via header.jsp)

        function saveCustomer() {
            var formData = {
                customerCode: $('#customerCode').val(),
                companyName: $('#companyName').val(),
                userContract: $('#userContract').val(),
                customerEmail: $('#customerEmail').val(),
                customerPhone: $('#customerPhone').val(),
                customerAddress: $('#customerAddress').val(),
                taxCode: $('#taxCode').val(),
                customerType: $('#customerType').val()
            };

            // Kiểm tra các trường bắt buộc cơ bản
            if (!formData.customerCode || !formData.userContract || 
                !formData.customerEmail || !formData.customerPhone || !formData.customerAddress || !formData.customerType) {
                alert('Vui lòng điền đầy đủ thông tin bắt buộc');
                return;
            }

                // Ràng buộc: Mã khách hàng phải có cả chữ và số, chỉ cho phép ký tự chữ và số
                var code = (formData.customerCode || '').trim();
                var codeRegex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z0-9]+$/;
                if (!codeRegex.test(code)) {
                    alert('Mã khách hàng phải bao gồm cả chữ và số, và chỉ chứa ký tự chữ/số.');
                    $('#customerCode').focus();
                    return;
                }

                // Ràng buộc: Email phải là @gmail.com hoặc @fpt.edu.vn
                var email = (formData.customerEmail || '').trim();
                var emailRegex = /^[A-Za-z0-9._%+-]+@(gmail\.com|fpt\.edu\.vn)$/i;
                if (!emailRegex.test(email)) {
                    alert('Email phải có định dạng @gmail.com hoặc @fpt.edu.vn');
                    $('#customerEmail').focus();
                    return;
                }

                // Ràng buộc: Số điện thoại 10 hoặc 11 chữ số
                var phone = (formData.customerPhone || '').trim();
                var phoneRegex = /^\d{10,11}$/;
                if (!phoneRegex.test(phone)) {
                    alert('Số điện thoại phải gồm 10 hoặc 11 chữ số.');
                    $('#customerPhone').focus();
                    return;
                }

            // Kiểm tra tên công ty chỉ bắt buộc khi loại khách hàng là doanh nghiệp
            if (formData.customerType === 'company' && (!formData.companyName || formData.companyName.trim() === '')) {
                alert('Vui lòng nhập tên công ty cho khách hàng doanh nghiệp');
                return;
            }

            var action = currentEditingCustomer ? 'update' : 'add';
            formData.action = action;
            if (currentEditingCustomer) {
                formData.id = currentEditingCustomer.id;
            }
            
            // Gửi contactId nếu có (khi chọn từ khách hàng chờ)
            if (selectedContactId) {
                formData.contactId = selectedContactId;
            }

            $.ajax({
                url: 'api/customers',
                type: 'POST',
                data: formData,
                dataType: 'json',
                    success: function (response) {
                    if (response.success) {
                        alert(response.message);
                        $('#addCustomerModal').modal('hide');
                        $('#addCustomerForm')[0].reset();
                        currentEditingCustomer = null;
                        selectedContactId = null; // Reset contactId
                        $('#addCustomerModal .modal-title').text('Thêm khách hàng mới');
                        // Reload trang để hiển thị khách hàng mới (xóa tất cả filter)
                        window.location.href = window.location.pathname;
                    } else {
                        alert('Lỗi: ' + response.message);
                    }
                },
                    error: function () {
                    alert('Lỗi kết nối đến server');
                }
            });
        }

        function permanentDeleteCustomer() {
            if (!currentEditingCustomer) {
                alert('Không tìm thấy thông tin khách hàng');
                return;
            }

            if (confirm('CẢNH BÁO: Bạn có chắc chắn muốn xóa vĩnh viễn khách hàng này? Hành động này không thể hoàn tác!')) {
                $.ajax({
                    url: 'api/customers',
                    type: 'POST',
                    data: { 
                        action: 'permanentDelete', 
                        id: currentEditingCustomer.id 
                    },
                    dataType: 'json',
                    success: function (response) {
                        if (response.success) {
                            alert('Đã xóa vĩnh viễn khách hàng thành công');
                            $('#addCustomerModal').modal('hide');
                            location.reload();
                        } else {
                            alert('Lỗi khi xóa vĩnh viễn khách hàng: ' + response.message);
                        }
                    },
                    error: function () {
                        alert('Lỗi kết nối đến server');
                    }
                });
            }
        }

        // Reset form when modal is closed
            $('#addCustomerModal').on('hidden.bs.modal', function () {
            $('#addCustomerForm')[0].reset();
            currentEditingCustomer = null;
            selectedContactId = null; // Reset contactId khi đóng modal
            $('#addCustomerModal .modal-title').text('Thêm khách hàng mới');
            // Reset label về mặc định
            $('label[for="companyName"]').text('Tên công ty:');
            // Hide permanent delete button
            $('.btn-danger', '#addCustomerModal').hide();
            // Đảm bảo trường mã khách hàng luôn readonly
            $('#customerCode').prop('readonly', true);
            $('#customerCode').css({'background-color': '#f5f5f5', 'cursor': 'not-allowed'});
        });
        
        // Tự động sinh mã khách hàng khi mở modal thêm mới
        $('#addCustomerModal').on('show.bs.modal', function() {
            // Chỉ sinh mã khi thêm mới (không phải edit)
            if (!currentEditingCustomer) {
                $.get('customers', { action: 'generateCustomerCode' }, function(resp) {
                    try {
                        var data = typeof resp === 'string' ? JSON.parse(resp) : resp;
                        if (data && data.success && data.data && data.data.customerCode) {
                            $('#customerCode').val(data.data.customerCode);
                        } else if (data && data.data && data.data.customerCode) {
                            // Nếu response không có success field
                            $('#customerCode').val(data.data.customerCode);
                        } else if (data && data.customerCode) {
                            // Nếu response trực tiếp có customerCode
                            $('#customerCode').val(data.customerCode);
                        }
                    } catch (e) {
                        console.error('Error parsing response:', e);
                    }
                }, 'json').fail(function() {
                    console.error('Failed to generate customer code');
                });
            }
        });

        // Cập nhật label khi thay đổi loại khách hàng
            $('#customerType').on('change', function () {
            var customerType = $(this).val();
            var label = $('label[for="companyName"]');
            
            if (customerType === 'individual') {
                label.text('Tên công ty: (Tùy chọn)');
            } else if (customerType === 'company') {
                label.text('Tên công ty: *');
            } else {
                label.text('Tên công ty:');
            }
        });

        // Hiển thị danh sách khách hàng chờ
        function showWaitingCustomers() {
            $('#waitingCustomersModal').modal('show');
            $('#waitingCustomersContent').html('<p class="text-center"><i class="fa fa-spinner fa-spin"></i> Đang tải...</p>');
            
            $.ajax({
                url: 'customers?action=getWaitingCustomers',
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    console.log('Response from getWaitingCustomers:', data);
                    
                    // Kiểm tra nếu response là error object
                    if (data && data.error) {
                        $('#waitingCustomersContent').html('<div class="alert alert-danger text-center">' + escapeHtml(data.error) + '</div>');
                        return;
                    }
                    
                    // Kiểm tra nếu data không phải là array
                    if (!data) {
                        $('#waitingCustomersContent').html('<div class="alert alert-danger text-center">Không nhận được dữ liệu từ server.</div>');
                        return;
                    }
                    
                    if (Array.isArray(data) && data.length > 0) {
                        var html = '<div class="table-responsive">';
                        html += '<table class="table table-striped table-bordered table-hover">';
                        html += '<thead>';
                        html += '<tr>';
                        html += '<th style="width: 60px; text-align: center;">ID</th>';
                        html += '<th style="width: 150px;">Họ tên</th>';
                        html += '<th style="width: 180px;">Email</th>';
                        html += '<th style="width: 120px;">Số điện thoại</th>';
                        html += '<th style="width: 150px;">Địa chỉ</th>';
                        html += '<th style="width: 120px;">Loại KH</th>';
                        html += '<th style="width: 150px;">Tên công ty</th>';
                        html += '<th style="width: 120px;">Mã số thuế</th>';
                        html += '<th style="width: 140px;">Phương thức liên hệ</th>';
                        html += '<th style="width: 140px;">Ngày gửi</th>';
                        html += '<th style="width: 140px;">Ngày liên hệ</th>';
                        html += '<th style="min-width: 200px;">Nội dung tin nhắn</th>';
                        html += '<th style="min-width: 200px;">Nội dung liên hệ</th>';
                        html += '</tr>';
                        html += '</thead>';
                        html += '<tbody>';
                        
                        for (var i = 0; i < data.length; i++) {
                            var c = data[i];
                            var contactMethod = String(c.contactMethod || '');
                            var createdDate = formatDateTime(c.createdAt || c.created_at || '');
                            var repliedDate = formatDateTime(c.repliedAt || c.replied_at || c.contactedAt || c.contacted_at || '');
                            
                            html += '<tr>';
                            html += '<td style="text-align: center; font-weight: 600;">' + c.id + '</td>';
                            html += '<td><strong style="color: #333;">' + escapeHtml(c.fullName || c.full_name || '') + '</strong></td>';
                            html += '<td><a href="mailto:' + escapeHtml(c.email) + '" style="color: #337ab7; text-decoration: none;">' + escapeHtml(c.email) + '</a></td>';
                            html += '<td><a href="tel:' + escapeHtml(c.phone) + '" style="color: #337ab7; text-decoration: none;">' + escapeHtml(c.phone) + '</a></td>';
                            html += '<td style="word-wrap: break-word; max-width: 150px;">' + formatField(c.address) + '</td>';
                            html += '<td style="text-align: center;">' + getCustomerTypeLabel(c.customerType) + '</td>';
                            html += '<td>' + formatField(c.companyName, true) + '</td>';
                            html += '<td>' + formatField(c.taxCode) + '</td>';
                            html += '<td>' + (contactMethod.trim() ? '<span class="label label-info" style="display: inline-block; padding: 4px 10px;">' + escapeHtml(contactMethod) + '</span>' : '<span style="color: #999;">-</span>') + '</td>';
                            html += '<td style="font-size: 12px; color: #666;">' + createdDate + '</td>';
                            html += '<td style="font-size: 12px; color: #666;">' + repliedDate + '</td>';
                            html += '<td style="word-wrap: break-word; word-break: break-word; max-width: 300px; white-space: normal; line-height: 1.5;">' + escapeHtml(c.message || '') + '</td>';
                            html += '<td style="word-wrap: break-word; word-break: break-word; max-width: 300px; white-space: normal; line-height: 1.5;">' + formatField(c.contactContent) + '</td>';
                            html += '</tr>';
                        }
                        
                        html += '</tbody>';
                        html += '</table>';
                        html += '</div>';
                        html += '<div class="alert alert-info" style="margin-top: 15px; margin-bottom: 0;">';
                        html += '<i class="fa fa-info-circle"></i> <strong>Tổng số:</strong> ' + data.length + ' khách hàng đã liên hệ';
                        html += '</div>';
                        
                        $('#waitingCustomersContent').html(html);
                    } else {
                        $('#waitingCustomersContent').html('<div class="alert alert-info text-center">Không có khách hàng nào đã liên hệ.</div>');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error loading waiting customers:', xhr, status, error);
                    var errorMsg = handleAjaxError(xhr, status, error, 'Lỗi khi tải danh sách khách hàng chờ.');
                    $('#waitingCustomersContent').html('<div class="alert alert-danger text-center">' + escapeHtml(errorMsg) + '</div>');
                }
            });
        }

        // Xác nhận khách hàng chờ
        function confirmWaitingCustomer(contactId) {
            if (confirm('Bạn có chắc chắn muốn xác nhận khách hàng này?')) {
                $.ajax({
                    url: 'customers',
                    type: 'POST',
                    data: { action: 'confirmWaitingCustomer', contactId: contactId },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            alert('✓ ' + response.message);
                            // Reload danh sách
                            showWaitingCustomers();
                        } else {
                            alert('✗ ' + (response.message || 'Lỗi khi xác nhận'));
                        }
                    },
                    error: function(xhr, status, error) {
                        var errorMsg = 'Lỗi khi xác nhận khách hàng.';
                        if (xhr.responseJSON && xhr.responseJSON.error) {
                            errorMsg = xhr.responseJSON.error;
                        }
                        alert('✗ ' + errorMsg);
                    }
                });
            }
        }

        // Hủy bỏ khách hàng chờ
        function cancelWaitingCustomer(contactId) {
            if (confirm('Bạn có chắc chắn muốn hủy bỏ khách hàng này?')) {
                $.ajax({
                    url: 'customers',
                    type: 'POST',
                    data: { action: 'cancelWaitingCustomer', contactId: contactId },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            alert('✓ ' + response.message);
                            // Reload danh sách
                            showWaitingCustomers();
                        } else {
                            alert('✗ ' + (response.message || 'Lỗi khi hủy bỏ'));
                        }
                    },
                    error: function(xhr, status, error) {
                        var errorMsg = 'Lỗi khi hủy bỏ khách hàng.';
                        if (xhr.responseJSON && xhr.responseJSON.error) {
                            errorMsg = xhr.responseJSON.error;
                        }
                        alert('✗ ' + errorMsg);
                    }
                });
            }
        }

        // Helper functions
        function formatDateTime(dateString) {
            if (!dateString) return '-';
            try {
                var date = new Date(dateString);
                var day = String(date.getDate()).padStart(2, '0');
                var month = String(date.getMonth() + 1).padStart(2, '0');
                var year = date.getFullYear();
                var hours = String(date.getHours()).padStart(2, '0');
                var minutes = String(date.getMinutes()).padStart(2, '0');
                var seconds = String(date.getSeconds()).padStart(2, '0');
                return hours + ':' + minutes + ':' + seconds + ' ' + day + '/' + month + '/' + year;
            } catch (e) {
                return dateString;
            }
        }
        
        function getCustomerTypeLabel(customerType) {
            if (!customerType || !customerType.trim()) return '<span style="color: #999;">-</span>';
            return customerType === 'company' 
                ? '<span class="label label-primary">Doanh nghiệp</span>' 
                : '<span class="label label-default">Cá nhân</span>';
        }
        
        function formatField(value, isStrong) {
            if (!value || !value.trim()) return '<span style="color: #999;">-</span>';
            return isStrong ? '<strong>' + escapeHtml(value) + '</strong>' : escapeHtml(value);
        }
        
        function handleAjaxError(xhr, status, error, defaultMsg) {
            var errorMsg = defaultMsg || 'Đã xảy ra lỗi.';
            try {
                if (xhr.responseText) {
                    var responseText = xhr.responseText.trim();
                    if (responseText.startsWith('{')) {
                        var errorObj = JSON.parse(responseText);
                        if (errorObj.error) errorMsg = errorObj.error;
                    } else if (responseText) {
                        errorMsg = responseText;
                    }
                }
            } catch (e) {
                console.error('Error parsing error response:', e);
            }
            if (xhr.responseJSON && xhr.responseJSON.error) errorMsg = xhr.responseJSON.error;
            else if (xhr.status === 401) errorMsg = 'Bạn cần đăng nhập.';
            else if (xhr.status === 403) errorMsg = 'Bạn không có quyền truy cập.';
            else if (xhr.status === 500) errorMsg = 'Lỗi server. Vui lòng thử lại sau.';
            return errorMsg;
        }

        // Khởi tạo danh sách khách hàng đã chọn (lưu trong sessionStorage để giữ khi reload)
        if (!window.selectedWaitingCustomers) {
            var stored = sessionStorage.getItem('selectedWaitingCustomers');
            window.selectedWaitingCustomers = stored ? JSON.parse(stored) : [];
        }

        // Hiển thị modal chọn khách hàng chờ để thêm
        function showSelectWaitingCustomer() {
            $('#selectWaitingCustomerModal').modal('show');
            $('#selectWaitingCustomerContent').html('<p class="text-center"><i class="fa fa-spinner fa-spin"></i> Đang tải...</p>');
            
            $.ajax({
                url: 'customers?action=getWaitingCustomers',
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    if (data && data.error) {
                        $('#selectWaitingCustomerContent').html('<div class="alert alert-danger text-center">' + escapeHtml(data.error) + '</div>');
                        return;
                    }
                    
                    if (data && Array.isArray(data) && data.length > 0) {
                        var html = '<div class="table-responsive" style="max-height: 600px; overflow-y: auto;">';
                        html += '<table class="table table-striped table-bordered table-hover" style="margin-bottom: 0;">';
                        html += '<thead style="position: sticky; top: 0; background-color: #f5f5f5; z-index: 10;">';
                        html += '<tr>';
                        html += '<th style="width: 50px; text-align: center; min-width: 50px;">ID</th>';
                        html += '<th style="width: 140px; min-width: 140px;">Họ tên</th>';
                        html += '<th style="width: 160px; min-width: 160px;">Email</th>';
                        html += '<th style="width: 110px; min-width: 110px;">Số điện thoại</th>';
                        html += '<th style="width: 130px; min-width: 130px;">Địa chỉ</th>';
                        html += '<th style="width: 100px; text-align: center; min-width: 100px;">Loại KH</th>';
                        html += '<th style="width: 140px; min-width: 140px;">Tên công ty</th>';
                        html += '<th style="width: 110px; min-width: 110px;">Mã số thuế</th>';
                        html += '<th style="width: 100px; text-align: center; min-width: 100px;">Thao tác</th>';
                        html += '</tr>';
                        html += '</thead>';
                        html += '<tbody>';
                        
                        for (var i = 0; i < data.length; i++) {
                            var c = data[i];
                            var isSelected = window.selectedWaitingCustomers.indexOf(c.id) !== -1;
                            var btnClass = isSelected ? 'btn-success' : 'btn-primary';
                            var btnText = isSelected ? '<i class="fa fa-check"></i> Đã chọn' : '<i class="fa fa-check-circle"></i> Chọn';
                            var btnAttrs = isSelected ? 'disabled title="Đã chọn" style="padding: 4px 10px; font-size: 11px; border-radius: 3px; white-space: nowrap; cursor: not-allowed;"' 
                                : 'onclick="selectWaitingCustomer(' + i + ')" title="Chọn khách hàng này" style="padding: 4px 10px; font-size: 11px; border-radius: 3px; white-space: nowrap;"';
                            
                            html += '<tr>';
                            html += '<td style="text-align: center; font-weight: 600; vertical-align: middle;">' + c.id + '</td>';
                            html += '<td style="vertical-align: middle;"><strong style="color: #333;">' + escapeHtml(c.fullName || c.full_name || '') + '</strong></td>';
                            html += '<td style="vertical-align: middle;"><a href="mailto:' + escapeHtml(c.email) + '" style="color: #337ab7; text-decoration: none; word-break: break-all;">' + escapeHtml(c.email) + '</a></td>';
                            html += '<td style="vertical-align: middle;"><a href="tel:' + escapeHtml(c.phone) + '" style="color: #337ab7; text-decoration: none;">' + escapeHtml(c.phone) + '</a></td>';
                            html += '<td style="word-wrap: break-word; word-break: break-word; vertical-align: middle; font-size: 12px;">' + formatField(c.address) + '</td>';
                            html += '<td style="text-align: center; vertical-align: middle;">' + getCustomerTypeLabel(c.customerType) + '</td>';
                            html += '<td style="vertical-align: middle; font-size: 12px;">' + formatField(c.companyName, true) + '</td>';
                            html += '<td style="vertical-align: middle; font-size: 12px;">' + formatField(c.taxCode) + '</td>';
                            html += '<td style="text-align: center; vertical-align: middle;">';
                            html += '<button class="btn ' + btnClass + ' btn-xs" ' + btnAttrs + '>' + btnText + '</button>';
                            html += '</td></tr>';
                        }
                        
                        html += '</tbody>';
                        html += '</table>';
                        html += '</div>';
                        html += '<div class="alert alert-info" style="margin-top: 10px; margin-bottom: 0;">';
                        html += '<i class="fa fa-info-circle"></i> <strong>Tổng số:</strong> ' + data.length + ' khách hàng đã liên hệ';
                        html += '</div>';
                        
                        // Lưu dữ liệu vào biến global để sử dụng khi chọn
                        window.waitingCustomersData = data;
                        
                        $('#selectWaitingCustomerContent').html(html);
                    } else {
                        $('#selectWaitingCustomerContent').html('<div class="alert alert-info text-center">Không có khách hàng nào đã liên hệ.</div>');
                    }
                },
                error: function(xhr, status, error) {
                    var errorMsg = handleAjaxError(xhr, status, error, 'Lỗi khi tải danh sách khách hàng chờ.');
                    $('#selectWaitingCustomerContent').html('<div class="alert alert-danger text-center">' + escapeHtml(errorMsg) + '</div>');
                }
            });
        }
        
        // Chọn khách hàng từ danh sách chờ và điền vào form
        function selectWaitingCustomer(index) {
            if (!window.waitingCustomersData || !window.waitingCustomersData[index]) {
                alert('Không tìm thấy thông tin khách hàng');
                return;
            }
            
            var customer = window.waitingCustomersData[index];
            
            // Kiểm tra xem khách hàng đã được chọn chưa
            if (window.selectedWaitingCustomers.indexOf(customer.id) !== -1) {
                alert('Khách hàng này đã được chọn rồi!');
                return;
            }
            
            // Lưu contactId (customer.id là ID của contact request)
            selectedContactId = customer.id;
            
            // Điền thông tin vào form
            $('#userContract').val(customer.fullName || '');
            $('#customerEmail').val(customer.email || '');
            $('#customerPhone').val(customer.phone || '');
            $('#customerAddress').val(customer.address || '');
            $('#taxCode').val(customer.taxCode || '');
            $('#companyName').val(customer.companyName || '');
            
            // Điền loại khách hàng
            if (customer.customerType) {
                $('#customerType').val(customer.customerType);
                // Trigger change để hiển thị/ẩn các trường liên quan
                $('#customerType').trigger('change');
            }
            
            // Tự động tạo mã khách hàng
            generateCustomerCode();
            
            // Đánh dấu khách hàng đã được chọn
            window.selectedWaitingCustomers.push(customer.id);
            sessionStorage.setItem('selectedWaitingCustomers', JSON.stringify(window.selectedWaitingCustomers));
            
            // Cập nhật nút trong bảng
            var button = $('#selectWaitingCustomerContent').find('button[onclick="selectWaitingCustomer(' + index + ')"]');
            if (button.length > 0) {
                button.removeClass('btn-primary').addClass('btn-success').prop('disabled', true);
                button.attr('title', 'Đã chọn');
                button.html('<i class="fa fa-check"></i> Đã chọn');
                button.removeAttr('onclick');
            }
            
            // Đóng modal chọn khách hàng
            $('#selectWaitingCustomerModal').modal('hide');
            
            // Focus vào form thêm khách hàng
            $('#addCustomerModal').modal('show');
        }
        

        function escapeHtml(text) {
            if (!text) return '';
            var map = {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#039;'
            };
            return String(text).replace(/[&<>"']/g, function(m) { return map[m]; });
        }
    </script>
</body>

</html>