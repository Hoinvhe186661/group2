<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Nhà cung cấp | Bảng điều khiển</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <link href="<%=request.getContextPath()%>/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="<%=request.getContextPath()%>/css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet" type="text/css" />
</head>
<body class="skin-black">
    <header class="header">
        <a href="<%=request.getContextPath()%>/admin.jsp" class="logo">
            Bảng điều khiển 
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
                    <!-- User Account: style can be found in dropdown.less -->
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
                                <a href="<%=request.getContextPath()%>/logout"><i class="fa fa-ban fa-fw pull-right"></i> Đăng xuất</a>
                            </li>
                        </ul>
                    </li>
                </ul>
            </div>
        </nav>
    </header>
    <div class="wrapper row-offcanvas row-offcanvas-left">
        <!-- Left side column. contains the logo and sidebar -->
        <aside class="left-side sidebar-offcanvas">
            <!-- sidebar: style can be found in sidebar.less -->
            <section class="sidebar">
                <!-- Sidebar user panel -->
                <div class="user-panel">
                    <div class="pull-left image">
                        <img src="<%=request.getContextPath()%>/img/26115.jpg" class="img-circle" alt="User Image" />
                    </div>
                    <div class="pull-left info">
                        <p>Xin chào, <%= username %></p>
                        <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
                    </div>
                </div>
                <!-- search form -->
                <form action="#" method="get" class="sidebar-form">
                    <div class="input-group">
                        <input type="text" name="q" class="form-control" placeholder="Tìm kiếm..."/>
                        <span class="input-group-btn">
                            <button type='submit' name='seach' id='search-btn' class="btn btn-flat"><i class="fa fa-search"></i></button>
                        </span>
                    </div>
                </form>
                <!-- /.search form -->
                <!-- sidebar menu: : style can be found in sidebar.less -->
                <ul class="sidebar-menu">
                    <li>
                        <a href="<%=request.getContextPath()%>/admin.jsp">
                            <i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/product">
                            <i class="fa fa-shopping-cart"></i> <span>Quản lý sản phẩm</span>
                        </a>
                    </li>
                    <li class="active">
                        <a href="<%=request.getContextPath()%>/supplier">
                            <i class="fa fa-industry"></i> <span>Nhà cung cấp</span>
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/inventory.jsp">
                            <i class="fa fa-archive"></i> <span>Quản lý kho</span>
                        </a>
                    </li>
                    
                </ul>
            </section>
            <!-- /.sidebar -->
        </aside>
        <aside class="right-side">
            <section class="content">
                <%
                    String message = request.getParameter("message");
                    String error = request.getParameter("error");
                    String validationError = request.getParameter("validation_error");
                    String databaseError = request.getParameter("database_error");
                    String systemError = request.getParameter("system_error");
                    
                    if ("success".equals(message)) {
                %>
                    <div class="alert alert-success alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-check-circle"></i> <strong>Thành công!</strong> Thêm nhà cung cấp thành công.
                    </div>
                <%
                    } else if ("update_success".equals(message)) {
                %>
                    <div class="alert alert-success alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-check-circle"></i> <strong>Thành công!</strong> Cập nhật nhà cung cấp thành công.
                    </div>
                <%
                    } else if ("delete_success".equals(message)) {
                %>
                    <div class="alert alert-success alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-check-circle"></i> <strong>Thành công!</strong> Xóa nhà cung cấp thành công.
                    </div>
                <%
                    } else if ("validation_error".equals(message)) {
                %>
                    <div class="alert alert-warning alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-exclamation-triangle"></i> <strong>Lỗi xác thực dữ liệu:</strong><br>
                        <%= error != null ? error : "Dữ liệu không hợp lệ" %>
                    </div>
                <%
                    } else if ("database_error".equals(message)) {
                %>
                    <div class="alert alert-danger alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-database"></i> <strong>Lỗi cơ sở dữ liệu:</strong><br>
                        <%= error != null ? error : "Lỗi không xác định" %>
                    </div>
                <%
                    } else if ("system_error".equals(message)) {
                %>
                    <div class="alert alert-danger alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-exclamation-circle"></i> <strong>Lỗi hệ thống:</strong><br>
                        <%= error != null ? error : "Lỗi không xác định" %>
                    </div>
                <%
                    } else if (error != null && !error.trim().isEmpty()) {
                %>
                    <div class="alert alert-danger alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-times-circle"></i> <strong>Lỗi:</strong> <%= error %>
                    </div>
                <%
                    }
                %>
                
                <div class="panel">
                    <header class="panel-heading">
                        <h3>Danh sách nhà cung cấp</h3>
                    </header>
                    <div class="panel-body table-responsive">
                        <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addSupplierModal" style="margin-bottom:12px;">
                            <i class="fa fa-plus"></i> Thêm nhà cung cấp
                        </button>
                        
                        <!-- Bộ lọc và tìm kiếm -->
                        <form action="<%=request.getContextPath()%>/supplier" method="get" id="filterForm">
                            <input type="hidden" name="action" value="page">
                            <div class="row" style="margin-bottom: 15px; padding: 15px; background-color: #f9f9f9; border-radius: 5px;">
                                <div class="col-md-12">
                                    <div class="row">
                                        <!-- Lọc theo tên công ty -->
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="companyFilter" style="font-weight: bold; margin-bottom: 5px;">Tên công ty:</label>
                                                <select id="companyFilter" name="companyFilter" class="form-control">
                                                    <option value="">Tất cả công ty</option>
                                                    <c:if test="${not empty allSuppliers}">
                                                        <c:set var="companies" value="${java.util.LinkedHashSet()}" />
                                                        <c:forEach var="s" items="${allSuppliers}">
                                                            <c:if test="${not empty s.companyName}">
                                                                ${companies.add(s.companyName)}
                                                            </c:if>
                                                        </c:forEach>
                                                        <c:forEach var="company" items="${companies}">
                                                            <option value="${company}" ${companyFilter eq company ? 'selected' : ''}>${company}</option>
                                                        </c:forEach>
                                                    </c:if>
                                                </select>
                                            </div>
                                        </div>
                                        
                                        <!-- Lọc theo người liên hệ -->
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="contactFilter" style="font-weight: bold; margin-bottom: 5px;">Người liên hệ:</label>
                                                <select id="contactFilter" name="contactFilter" class="form-control">
                                                    <option value="">Tất cả người liên hệ</option>
                                                    <c:if test="${not empty allSuppliers}">
                                                        <c:set var="contacts" value="${java.util.LinkedHashSet()}" />
                                                        <c:forEach var="s" items="${allSuppliers}">
                                                            <c:if test="${not empty s.contactPerson}">
                                                                ${contacts.add(s.contactPerson)}
                                                            </c:if>
                                                        </c:forEach>
                                                        <c:forEach var="contact" items="${contacts}">
                                                            <option value="${contact}" ${contactFilter eq contact ? 'selected' : ''}>${contact}</option>
                                                        </c:forEach>
                                                    </c:if>
                                                </select>
                                            </div>
                                        </div>
                                        
                                        <!-- Lọc theo trạng thái -->
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="statusFilter" style="font-weight: bold; margin-bottom: 5px;">Trạng thái:</label>
                                                <select id="statusFilter" name="statusFilter" class="form-control">
                                                    <option value="">Tất cả trạng thái</option>
                                                    <option value="active" ${statusFilter eq 'active' ? 'selected' : ''}>Hoạt động</option>
                                                    <option value="inactive" ${statusFilter eq 'inactive' ? 'selected' : ''}>Không hoạt động</option>
                                                </select>
                                            </div>
                                        </div>
                                        
                                        <!-- Tìm kiếm tổng quát -->
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="searchInput" style="font-weight: bold; margin-bottom: 5px;">Tìm kiếm:</label>
                                                <input type="text" id="searchInput" name="searchInput" class="form-control" placeholder="Nhập từ khóa tìm kiếm..." value="${searchInput}">
                                            </div>
                                        </div>
                                        
                                        <!-- Nút lọc và reset -->
                                        <div class="col-md-1">
                                            <div class="form-group">
                                                <label style="color: transparent; margin-bottom: 5px;">Action</label>
                                                <div>
                                                    <button type="submit" class="btn btn-primary btn-sm" title="Lọc" style="margin-right: 2px;">
                                                        <i class="fa fa-filter"></i>
                                                    </button>
                                                    <a href="<%=request.getContextPath()%>/supplier" class="btn btn-warning btn-sm" title="Xóa tất cả bộ lọc">
                                                        <i class="fa fa-refresh"></i>
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>
                        
                        <table class="table table-hover" id="suppliersTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Mã NCC</th>
                                    <th>Tên công ty</th>
                                    <th>Liên hệ</th>
                                    <th>Email</th>
                                    <th>Điện thoại</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty suppliers}">
                                        <c:forEach var="supplier" items="${suppliers}">
                                            <tr>
                                                <td>${supplier.id}</td>
                                                <td>${supplier.supplierCode}</td>
                                                <td>${supplier.companyName}</td>
                                                <td>${supplier.contactPerson}</td>
                                                <td>${supplier.email}</td>
                                                <td>${supplier.phone}</td>
                                                <td>
                                                    <span class="label ${supplier.status == 'active' ? 'label-success' : 'label-default'}">
                                                        ${supplier.status}
                                                    </span>
                                                </td>
                                                <td>
                                                    <button class="btn btn-info btn-xs" data-supplier-id="${supplier.id}" onclick="viewSupplier(this)">Xem</button>
                                                    <button class="btn btn-warning btn-xs" data-supplier-id="${supplier.id}" onclick="editSupplier(this)">Sửa</button>
                                                    <button class="btn btn-danger btn-xs" data-supplier-id="${supplier.id}" onclick="deleteSupplier(this)">Xóa</button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="8" class="text-center">Không có dữ liệu nhà cung cấp</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                        
                        <!-- Phân trang -->
                        <div class="row" style="margin-top: 20px;">
                            <div class="col-md-8">
                                <div class="dataTables_info" id="suppliersTable_info" role="status" aria-live="polite">
                                    Hiển thị <span id="showingStart">1</span> đến <span id="showingEnd">10</span> 
                                    trong tổng số <span id="totalRecords">0</span> bản ghi
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="dataTables_paginate paging_simple_numbers" id="suppliersTable_paginate" style="text-align: right;">
                                    <ul class="pagination" id="pagination">
                                        <!-- Nút Previous -->
                                        <li class="paginate_button previous disabled" id="suppliersTable_previous">
                                            <a href="#" aria-controls="suppliersTable" data-dt-idx="0" tabindex="0" id="prevBtn">Trước</a>
                                        </li>
                                        
                                        <!-- Các nút số trang sẽ được tạo bằng JavaScript -->
                                        <li class="paginate_button active">
                                            <a href="#" aria-controls="suppliersTable" data-dt-idx="1" tabindex="0" class="page-link" data-page="1">1</a>
                                        </li>
                                        
                                        <!-- Nút Next -->
                                        <li class="paginate_button next" id="suppliersTable_next">
                                            <a href="#" aria-controls="suppliersTable" data-dt-idx="2" tabindex="0" id="nextBtn">Tiếp</a>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section><!-- /.content -->
            
        </aside><!-- /.right-side -->
    </div><!-- ./wrapper -->
    <!-- Modal thêm nhà cung cấp -->
    <div class="modal fade" id="addSupplierModal" tabindex="-1" role="dialog" aria-labelledby="addSupplierModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="addSupplierModalLabel">Thêm nhà cung cấp</h4>
                </div>
                <div class="modal-body">
                    <form id="addSupplierForm" action="<%=request.getContextPath()%>/supplier" method="post">
                        <input type="hidden" name="action" value="add">
                        <div class="form-group"><label>Mã NCC</label><input name="supplier_code" class="form-control" required></div>
                        <div class="form-group"><label>Tên công ty</label><input name="company_name" class="form-control" required></div>
                        <div class="form-group"><label>Người liên hệ</label><input name="contact_person" class="form-control"></div>
                        <div class="form-group"><label>Email</label><input type="email" name="email" class="form-control"></div>
                        <div class="form-group"><label>Điện thoại</label><input name="phone" class="form-control"></div>
                        <div class="form-group"><label>Địa chỉ</label><textarea name="address" class="form-control" rows="2"></textarea></div>
                        <div class="form-group">
                            <label>Thông tin ngân hàng</label>
                            <div class="row">
                                <div class="col-md-6">
                                    <input name="bank_name" id="add_bank_name" class="form-control" placeholder="Tên ngân hàng">
                                </div>
                                <div class="col-md-6">
                                    <input name="account_number" id="add_account_number" class="form-control" placeholder="Số tài khoản">
                                </div>
                            </div>
                            <input type="hidden" name="bank_info" id="add_bank_info">
                        </div>
                        <div class="form-group"><label>Trạng thái</label>
                            <select class="form-control" name="status">
                                <option value="active" selected>active</option>
                                <option value="inactive">inactive</option>
                            </select>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary" form="addSupplierForm">Lưu</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal xem/sửa nhà cung cấp -->
    <div class="modal fade" id="editSupplierModal" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Sửa nhà cung cấp</h4>
                </div>
                <div class="modal-body">
                    <form id="editSupplierForm" action="<%=request.getContextPath()%>/supplier" method="post">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="id" id="edit_supplier_id">
                        <div class="form-group"><label>Mã NCC</label><input name="supplier_code" id="edit_supplier_code" class="form-control" required></div>
                        <div class="form-group"><label>Tên công ty</label><input name="company_name" id="edit_company_name" class="form-control" required></div>
                        <div class="form-group"><label>Người liên hệ</label><input name="contact_person" id="edit_contact_person" class="form-control"></div>
                        <div class="form-group"><label>Email</label><input type="email" name="email" id="edit_email" class="form-control"></div>
                        <div class="form-group"><label>Điện thoại</label><input name="phone" id="edit_phone" class="form-control"></div>
                        <div class="form-group"><label>Địa chỉ</label><textarea name="address" id="edit_address" class="form-control" rows="2"></textarea></div>
                        <div class="form-group">
                            <label>Thông tin ngân hàng</label>
                            <div class="row">
                                <div class="col-md-6">
                                    <input name="bank_name" id="edit_bank_name" class="form-control" placeholder="Tên ngân hàng">
                                </div>
                                <div class="col-md-6">
                                    <input name="account_number" id="edit_account_number" class="form-control" placeholder="Số tài khoản">
                                </div>
                            </div>
                            <input type="hidden" name="bank_info" id="edit_bank_info">
                        </div>
                        <div class="form-group"><label>Trạng thái</label>
                            <select class="form-control" name="status" id="edit_status">
                                <option value="active">active</option>
                                <option value="inactive">inactive</option>
                            </select>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-primary" form="editSupplierForm">Lưu</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal xem chi tiết nhà cung cấp -->
    <div class="modal fade" id="viewSupplierModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Chi tiết nhà cung cấp</h4>
                </div>
                <div class="modal-body" id="viewSupplierContent">
                    <!-- Nội dung sẽ được load bằng JavaScript -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js" type="text/javascript"></script>
    <script>
        // Hàm tạo JSON từ 2 trường bank_name và account_number
        function createBankInfoJson(bankName, accountNumber) {
            var bankNameEscaped = (bankName || '').replace(/\\/g, '\\\\').replace(/"/g, '\\"');
            var accountNumberEscaped = (accountNumber || '').replace(/\\/g, '\\\\').replace(/"/g, '\\"');
            return '{"bank_name":"' + bankNameEscaped + '","account_number":"' + accountNumberEscaped + '"}';
        }
        
        // Hàm parse JSON để lấy bank_name và account_number
        function parseBankInfo(bankInfoJson) {
            try {
                var bankInfo = JSON.parse(bankInfoJson || '{}');
                return {
                    bankName: bankInfo.bank_name || '',
                    accountNumber: bankInfo.account_number || ''
                };
            } catch (e) {
                return { bankName: '', accountNumber: '' };
            }
        }
        
        // Xử lý form submit để ghép JSON
        $(document).ready(function() {
            // Form thêm mới
            $('#addSupplierForm').on('submit', function(e) {
                // Validation
                var supplierCode = $('input[name="supplier_code"]', this).val().trim();
                var companyName = $('input[name="company_name"]', this).val().trim();
                
                if (!supplierCode) {
                    e.preventDefault();
                    alert('Mã nhà cung cấp không được để trống!');
                    $('input[name="supplier_code"]', this).focus();
                    return false;
                }
                
                if (!companyName) {
                    e.preventDefault();
                    alert('Tên công ty không được để trống!');
                    $('input[name="company_name"]', this).focus();
                    return false;
                }
                
                var bankName = $('#add_bank_name').val();
                var accountNumber = $('#add_account_number').val();
                $('#add_bank_info').val(createBankInfoJson(bankName, accountNumber));
                return true;
            });
            
            // Form sửa
            $('#editSupplierForm').on('submit', function(e) {
                // Validation
                var supplierCode = $('#edit_supplier_code').val().trim();
                var companyName = $('#edit_company_name').val().trim();
                
                if (!supplierCode) {
                    e.preventDefault();
                    alert('Mã nhà cung cấp không được để trống!');
                    $('#edit_supplier_code').focus();
                    return false;
                }
                
                if (!companyName) {
                    e.preventDefault();
                    alert('Tên công ty không được để trống!');
                    $('#edit_company_name').focus();
                    return false;
                }
                
                var bankName = $('#edit_bank_name').val();
                var accountNumber = $('#edit_account_number').val();
                $('#edit_bank_info').val(createBankInfoJson(bankName, accountNumber));
                return true;
            });
        });
        
        function viewSupplier(element) {
            var id = $(element).data('supplier-id');
            if (!id || id <= 0) {
                alert('ID nhà cung cấp không hợp lệ');
                return;
            }
            
            $.ajax({
                url: '<%=request.getContextPath()%>/supplier?action=view&id=' + id,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        var supplier = response.data;
                        var bankInfo = parseBankInfo(supplier.bankInfo);
                        
                        var content = '<div class="row">' +
                            '<div class="col-md-6">' +
                                '<h5>Thông tin cơ bản</h5>' +
                                '<p><strong>Mã NCC:</strong> ' + (supplier.supplierCode || '') + '</p>' +
                                '<p><strong>Tên công ty:</strong> ' + (supplier.companyName || '') + '</p>' +
                                '<p><strong>Người liên hệ:</strong> ' + (supplier.contactPerson || 'Chưa có') + '</p>' +
                                '<p><strong>Email:</strong> ' + (supplier.email || 'Chưa có') + '</p>' +
                                '<p><strong>Điện thoại:</strong> ' + (supplier.phone || 'Chưa có') + '</p>' +
                            '</div>' +
                            '<div class="col-md-6">' +
                                '<h5>Thông tin bổ sung</h5>' +
                                '<p><strong>Địa chỉ:</strong> ' + (supplier.address || 'Chưa có') + '</p>' +
                                '<p><strong>Tên ngân hàng:</strong> ' + (bankInfo.bankName || 'Chưa có') + '</p>' +
                                '<p><strong>Số tài khoản:</strong> ' + (bankInfo.accountNumber || 'Chưa có') + '</p>' +
                                '<p><strong>Trạng thái:</strong> <span class="label ' + (supplier.status === 'active' ? 'label-success' : 'label-default') + '">' + 
                                    (supplier.status === 'active' ? 'Hoạt động' : 'Không hoạt động') + '</span></p>' +
                            '</div>' +
                        '</div>';
                        $('#viewSupplierContent').html(content);
                        $('#viewSupplierModal').modal('show');
                    } else {
                        alert('Không thể tải thông tin nhà cung cấp: ' + (response.message || 'Lỗi không xác định'));
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', error);
                    alert('Lỗi kết nối đến server: ' + error);
                }
            });
        }
        function editSupplier(element) {
            var id = $(element).data('supplier-id');
            if (!id || id <= 0) {
                alert('ID nhà cung cấp không hợp lệ');
                return;
            }
            
            $.ajax({
                url: '<%=request.getContextPath()%>/supplier?action=view&id=' + id,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        var d = response.data;
                        $('#edit_supplier_id').val(d.id);
                        $('#edit_supplier_code').val(d.supplierCode);
                        $('#edit_company_name').val(d.companyName);
                        $('#edit_contact_person').val(d.contactPerson);
                        $('#edit_email').val(d.email);
                        $('#edit_phone').val(d.phone);
                        $('#edit_address').val(d.address);
                        
                        // Parse bank_info JSON và điền vào 2 trường riêng biệt
                        var bankInfo = parseBankInfo(d.bankInfo);
                        $('#edit_bank_name').val(bankInfo.bankName);
                        $('#edit_account_number').val(bankInfo.accountNumber);
                        $('#edit_bank_info').val(d.bankInfo); // Giữ nguyên JSON gốc
                        
                        $('#edit_status').val(d.status);
                        $('#editSupplierModal').modal('show');
                    } else {
                        alert('Không thể tải thông tin nhà cung cấp: ' + (response.message || 'Lỗi không xác định'));
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', error);
                    alert('Lỗi kết nối đến server: ' + error);
                }
            });
        }
        function deleteSupplier(element) {
            var id = $(element).data('supplier-id');
            if (!id || id <= 0) {
                alert('ID nhà cung cấp không hợp lệ');
                return;
            }
            
            if (confirm('Bạn có chắc chắn muốn xóa nhà cung cấp này?')) {
                // Sử dụng form submit thay vì AJAX để đảm bảo redirect hoạt động
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = '<%=request.getContextPath()%>/supplier';
                
                var actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete';
                form.appendChild(actionInput);
                
                var idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'id';
                idInput.value = id;
                form.appendChild(idInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        $(document).ready(function() {
            // Không cần JavaScript lọc phức tạp nữa vì đã xử lý ở backend
        });
    </script>
</body>
</html>


