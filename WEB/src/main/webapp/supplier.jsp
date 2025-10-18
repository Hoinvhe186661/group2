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
                        <a href="<%=request.getContextPath()%>/supplier.jsp">
                            <i class="fa fa-industry"></i> <span>Nhà cung cấp</span>
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/inventory.jsp">
                            <i class="fa fa-archive"></i> <span>Quản lý kho</span>
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/customers.jsp">
                            <i class="fa fa-users"></i> <span>Quản lý khách hàng</span>
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/reports.jsp">
                            <i class="fa fa-bar-chart"></i> <span>Báo cáo</span>
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/settings.jsp">
                            <i class="fa fa-cog"></i> <span>Cài đặt</span>
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
                    
                    if ("add_ok".equals(message)) {
                %>
                    <div class="alert alert-success alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-check-circle"></i> <strong>Thành công!</strong> Thêm nhà cung cấp thành công.
                    </div>
                <%
                    } else if ("upd_ok".equals(message)) {
                %>
                    <div class="alert alert-success alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-check-circle"></i> <strong>Thành công!</strong> Cập nhật nhà cung cấp thành công.
                    </div>
                <%
                    } else if ("del_ok".equals(message)) {
                %>
                    <div class="alert alert-success alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-check-circle"></i> <strong>Thành công!</strong> Xóa nhà cung cấp thành công.
                    </div>
                <%
                    } else if ("add_err".equals(message)) {
                %>
                    <div class="alert alert-danger alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-times-circle"></i> <strong>Lỗi!</strong> Không thể thêm nhà cung cấp. <%= error != null ? error : "" %>
                    </div>
                <%
                    } else if ("upd_err".equals(message)) {
                %>
                    <div class="alert alert-danger alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-times-circle"></i> <strong>Lỗi!</strong> Không thể cập nhật nhà cung cấp. <%= error != null ? error : "" %>
                    </div>
                <%
                    } else if ("del_err".equals(message)) {
                %>
                    <div class="alert alert-danger alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-times-circle"></i> <strong>Lỗi!</strong> Không thể xóa nhà cung cấp. <%= error != null ? error : "" %>
                    </div>
                <%
                    } else if (validationError != null && !validationError.trim().isEmpty()) {
                %>
                    <div class="alert alert-warning alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-exclamation-triangle"></i> <strong>Lỗi xác thực dữ liệu:</strong><br>
                        <%= validationError %>
                    </div>
                <%
                    } else if (databaseError != null && !databaseError.trim().isEmpty()) {
                %>
                    <div class="alert alert-danger alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-database"></i> <strong>Lỗi cơ sở dữ liệu:</strong><br>
                        <%= databaseError %>
                    </div>
                <%
                    } else if (systemError != null && !systemError.trim().isEmpty()) {
                %>
                    <div class="alert alert-danger alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-exclamation-circle"></i> <strong>Lỗi hệ thống:</strong><br>
                        <%= systemError %>
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
                        <div class="row" style="margin-bottom: 15px; padding: 15px; background-color: #f9f9f9; border-radius: 5px;">
                            <div class="col-md-12">
                                <div class="row">
                                    <!-- Lọc theo tên công ty -->
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label for="companyFilter" style="font-weight: bold; margin-bottom: 5px;">Tên công ty:</label>
                                            <select id="companyFilter" class="form-control">
                                                <option value="">Tất cả công ty</option>
                                                <!-- Các option sẽ được thêm bằng JavaScript -->
                                            </select>
                                        </div>
                                    </div>
                                    
                                    <!-- Lọc theo người liên hệ -->
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label for="contactFilter" style="font-weight: bold; margin-bottom: 5px;">Người liên hệ:</label>
                                            <select id="contactFilter" class="form-control">
                                                <option value="">Tất cả người liên hệ</option>
                                                <!-- Các option sẽ được thêm bằng JavaScript -->
                                            </select>
                                        </div>
                                    </div>
                                    
                                    <!-- Lọc theo trạng thái -->
                                    <div class="col-md-2">
                                        <div class="form-group">
                                            <label for="statusFilter" style="font-weight: bold; margin-bottom: 5px;">Trạng thái:</label>
                                            <select id="statusFilter" class="form-control">
                                                <option value="">Tất cả trạng thái</option>
                                                <option value="active">Hoạt động</option>
                                                <option value="inactive">Không hoạt động</option>
                                            </select>
                                        </div>
                                    </div>
                                    
                                    <!-- Tìm kiếm tổng quát -->
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label for="searchInput" style="font-weight: bold; margin-bottom: 5px;">Tìm kiếm:</label>
                                            <input type="text" id="searchInput" class="form-control" placeholder="Nhập từ khóa tìm kiếm...">
                                        </div>
                                    </div>
                                    
                                    <!-- Nút reset -->
                                    <div class="col-md-1">
                                        <div class="form-group">
                                            <label style="color: transparent; margin-bottom: 5px;">Reset</label>
                                            <button type="button" id="resetFilters" class="btn btn-warning btn-sm" style="width: 100%;" title="Xóa tất cả bộ lọc">
                                                <i class="fa fa-refresh"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
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
            $('#addSupplierForm').on('submit', function() {
                var bankName = $('#add_bank_name').val();
                var accountNumber = $('#add_account_number').val();
                $('#add_bank_info').val(createBankInfoJson(bankName, accountNumber));
            });
            
            // Form sửa
            $('#editSupplierForm').on('submit', function() {
                var bankName = $('#edit_bank_name').val();
                var accountNumber = $('#edit_account_number').val();
                $('#edit_bank_info').val(createBankInfoJson(bankName, accountNumber));
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
                $.ajax({
                    url: '<%=request.getContextPath()%>/supplier',
                    type: 'POST',
                    data: {
                        action: 'delete',
                        id: id
                    },
                    success: function(response) {
                        // Reload trang để cập nhật danh sách
                        window.location.reload();
                    },
                    error: function(xhr, status, error) {
                        console.error('AJAX Error:', error);
                        alert('Lỗi khi xóa nhà cung cấp: ' + error);
                    }
                });
            }
        }
        
        // Biến phân trang
        var currentPage = 1;
        var itemsPerPage = 10;
        var totalItems = 0;
        var filteredItems = [];
        var allItems = [];
        
        // Hàm khởi tạo phân trang
        function initializePagination() {
            // Lấy tất cả dữ liệu từ bảng
            var table = document.getElementById('suppliersTable');
            var rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
            
            // Lưu tất cả dữ liệu
            allItems = [];
            for (var i = 0; i < rows.length; i++) {
                allItems.push(rows[i].cloneNode(true));
            }
            
            totalItems = allItems.length;
            filteredItems = allItems.slice(); // Copy tất cả items
            
            // Khởi tạo dropdown lọc
            initializeFilterDropdowns();
            
            updatePagination();
        }
        
        // Hàm khởi tạo dropdown lọc
        function initializeFilterDropdowns() {
            var companySet = new Set();
            var contactSet = new Set();
            
            // Thu thập dữ liệu từ tất cả items
            for (var i = 0; i < allItems.length; i++) {
                var cells = allItems[i].getElementsByTagName('td');
                if (cells.length >= 7) {
                    var companyName = cells[2].textContent.trim();
                    var contactPerson = cells[3].textContent.trim();
                    
                    if (companyName && companyName !== '') {
                        companySet.add(companyName);
                    }
                    if (contactPerson && contactPerson !== '') {
                        contactSet.add(contactPerson);
                    }
                }
            }
            
            // Thêm options cho dropdown tên công ty
            var companyFilter = document.getElementById('companyFilter');
            companySet.forEach(function(company) {
                var option = document.createElement('option');
                option.value = company;
                option.textContent = company;
                companyFilter.appendChild(option);
            });
            
            // Thêm options cho dropdown người liên hệ
            var contactFilter = document.getElementById('contactFilter');
            contactSet.forEach(function(contact) {
                var option = document.createElement('option');
                option.value = contact;
                option.textContent = contact;
                contactFilter.appendChild(option);
            });
        }
        
        // Hàm cập nhật phân trang
        function updatePagination() {
            var totalPages = Math.ceil(filteredItems.length / itemsPerPage);
            var startIndex = (currentPage - 1) * itemsPerPage;
            var endIndex = Math.min(startIndex + itemsPerPage, filteredItems.length);
            
            // Cập nhật thông tin hiển thị
            document.getElementById('showingStart').textContent = filteredItems.length > 0 ? startIndex + 1 : 0;
            document.getElementById('showingEnd').textContent = endIndex;
            document.getElementById('totalRecords').textContent = filteredItems.length;
            
            // Cập nhật bảng
            updateTable();
            
            // Cập nhật nút phân trang
            updatePaginationButtons(totalPages);
        }
        
        // Hàm cập nhật bảng
        function updateTable() {
            var table = document.getElementById('suppliersTable');
            var tbody = table.getElementsByTagName('tbody')[0];
            
            // Xóa tất cả hàng hiện tại
            tbody.innerHTML = '';
            
            // Thêm hàng cho trang hiện tại
            var startIndex = (currentPage - 1) * itemsPerPage;
            var endIndex = Math.min(startIndex + itemsPerPage, filteredItems.length);
            
            for (var i = startIndex; i < endIndex; i++) {
                tbody.appendChild(filteredItems[i].cloneNode(true));
            }
        }
        
        // Hàm cập nhật nút phân trang
        function updatePaginationButtons(totalPages) {
            var pagination = document.getElementById('pagination');
            var prevBtn = document.getElementById('prevBtn');
            var nextBtn = document.getElementById('nextBtn');
            
            // Cập nhật nút Previous
            if (currentPage <= 1) {
                prevBtn.parentElement.classList.add('disabled');
            } else {
                prevBtn.parentElement.classList.remove('disabled');
            }
            
            // Cập nhật nút Next
            if (currentPage >= totalPages) {
                nextBtn.parentElement.classList.add('disabled');
            } else {
                nextBtn.parentElement.classList.remove('disabled');
            }
            
            // Xóa các nút số trang cũ (giữ lại Previous và Next)
            var pageButtons = pagination.querySelectorAll('.page-link');
            pageButtons.forEach(function(btn) {
                if (btn.id !== 'prevBtn' && btn.id !== 'nextBtn') {
                    btn.parentElement.remove();
                }
            });
            
            // Tạo nút số trang mới
            var maxVisiblePages = 5;
            var startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
            var endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);
            
            if (endPage - startPage + 1 < maxVisiblePages) {
                startPage = Math.max(1, endPage - maxVisiblePages + 1);
            }
            
            // Thêm nút số trang
            for (var i = startPage; i <= endPage; i++) {
                var li = document.createElement('li');
                li.className = 'paginate_button';
                if (i === currentPage) {
                    li.classList.add('active');
                }
                
                var a = document.createElement('a');
                a.href = '#';
                a.textContent = i;
                a.className = 'page-link';
                a.setAttribute('data-page', i);
                a.addEventListener('click', function(e) {
                    e.preventDefault();
                    goToPage(parseInt(this.getAttribute('data-page')));
                });
                
                li.appendChild(a);
                
                // Chèn trước nút Next
                nextBtn.parentElement.parentElement.insertBefore(li, nextBtn.parentElement);
            }
        }
        
        // Hàm chuyển đến trang
        function goToPage(page) {
            if (page < 1 || page > Math.ceil(filteredItems.length / itemsPerPage)) {
                return;
            }
            currentPage = page;
            updatePagination();
        }
        
        // Hàm lọc dữ liệu với phân trang
        function filterTableWithPagination() {
            var searchInput = document.getElementById('searchInput').value.toLowerCase();
            var companyFilter = document.getElementById('companyFilter').value;
            var contactFilter = document.getElementById('contactFilter').value;
            var statusFilter = document.getElementById('statusFilter').value;
            
            filteredItems = [];
            
            for (var i = 0; i < allItems.length; i++) {
                var row = allItems[i];
                var cells = row.getElementsByTagName('td');
                var shouldShow = true;
                
                if (cells.length >= 7) {
                    // Lấy dữ liệu từ các cột
                    var companyName = cells[2].textContent.trim();
                    var contactPerson = cells[3].textContent.trim();
                    var status = cells[6].textContent.trim().toLowerCase();
                    
                    // Kiểm tra tìm kiếm tổng quát
                    if (searchInput) {
                        var rowText = row.textContent.toLowerCase();
                        if (!rowText.includes(searchInput)) {
                            shouldShow = false;
                        }
                    }
                    
                    // Kiểm tra lọc theo tên công ty
                    if (companyFilter && companyName !== companyFilter) {
                        shouldShow = false;
                    }
                    
                    // Kiểm tra lọc theo người liên hệ
                    if (contactFilter && contactPerson !== contactFilter) {
                        shouldShow = false;
                    }
                    
                    // Kiểm tra lọc theo trạng thái
                    if (statusFilter) {
                        var statusText = status === 'active' ? 'active' : 'inactive';
                        if (statusText !== statusFilter) {
                            shouldShow = false;
                        }
                    }
                }
                
                if (shouldShow) {
                    filteredItems.push(row);
                }
            }
            
           
            currentPage = 1;
            updatePagination();
        }
        
        
        function resetAllFiltersWithPagination() {
            document.getElementById('searchInput').value = '';
            document.getElementById('companyFilter').value = '';
            document.getElementById('contactFilter').value = '';
            document.getElementById('statusFilter').value = '';
            filteredItems = allItems.slice();
            currentPage = 1;
            updatePagination();
        }
        
        
        $(document).ready(function() {
            
            initializePagination();
            
            // Gắn sự kiện cho các input lọc
            $('#searchInput').on('keyup', filterTableWithPagination);
            $('#companyFilter').on('change', filterTableWithPagination);
            $('#contactFilter').on('change', filterTableWithPagination);
            $('#statusFilter').on('change', filterTableWithPagination);
            $('#resetFilters').on('click', resetAllFiltersWithPagination);
            
            // Gắn sự kiện cho nút Previous/Next
            $('#prevBtn').on('click', function(e) {
                e.preventDefault();
                if (currentPage > 1) {
                    goToPage(currentPage - 1);
                }
            });
            
            $('#nextBtn').on('click', function(e) {
                e.preventDefault();
                var totalPages = Math.ceil(filteredItems.length / itemsPerPage);
                if (currentPage < totalPages) {
                    goToPage(currentPage + 1);
                }
            });
        });
    </script>
</body>
</html>


