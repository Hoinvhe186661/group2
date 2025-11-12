<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
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
    
    // Kiểm tra quyền truy cập - giống như role_permissions.jsp
    @SuppressWarnings("unchecked")
    Set<String> userPermissions = (Set<String>) session.getAttribute("userPermissions");
    if (userPermissions == null) {
        userPermissions = new HashSet<String>();
    }
    
    boolean canManage = userPermissions.contains("manage_inventory");
    boolean canView = userPermissions.contains("view_inventory");
    if (!canManage && !canView) {
        response.sendRedirect(request.getContextPath() + "/403.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý kho | Bảng điều khiển quản trị</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <meta name="description" content="Warehouse Management System">
    <meta name="keywords" content="Inventory, Stock, Warehouse">
    
    <!-- bootstrap 3.0.2 -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- font Awesome -->
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Ionicons -->
    <link href="<%=request.getContextPath()%>/css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet" type="text/css" />
    <link href='http://fonts.googleapis.com/css?family=Lato' rel='stylesheet' type='text/css'>
    
    <style>
        /* CSS cho phần lọc - giống với trang products */
        .filter-panel {
            background-color: #f9f9f9;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 15px;
        }
        
        .filter-panel .form-control {
            border-radius: 4px;
            border: 1px solid #ccc;
            transition: border-color 0.3s ease;
        }
        
        .filter-panel .btn {
            border-radius: 4px;
            transition: all 0.3s ease;
        }
        
        .filter-panel .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .filter-panel .form-control:focus {
            border-color: #3c8dbc;
            box-shadow: 0 0 5px rgba(60, 141, 188, 0.3);
        }
        
        .filter-panel label {
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
        }
        
        .filter-panel .btn-warning {
            background-color: #f0ad4e;
            border-color: #eea236;
            color: #fff;
        }
        
        .filter-panel .btn-warning:hover {
            background-color: #ec971f;
            border-color: #d58512;
        }
        
        /* Dashboard cards */
        .stat-card {
            background: #fff;
            border-radius: 5px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.12);
            border-left: 4px solid #3c8dbc;
        }
        
        .stat-card.warning {
            border-left-color: #f39c12;
        }
        
        .stat-card.danger {
            border-left-color: #dd4b39;
        }
        
        .stat-card.success {
            border-left-color: #00a65a;
        }
        
        .stat-card h3 {
            margin: 0 0 10px 0;
            font-size: 32px;
            font-weight: bold;
        }
        
        .stat-card p {
            margin: 0;
            color: #666;
            font-size: 14px;
        }
        
        /* Stock status badges */
        .stock-normal {
            color: #00a65a;
            font-weight: bold;
        }
        
        .stock-low {
            color: #f39c12;
            font-weight: bold;
        }
        
        .stock-out {
            color: #dd4b39;
            font-weight: bold;
        }
        
        /* Responsive cho filter panel */
        @media (max-width: 768px) {
            .filter-panel .col-md-3,
            .filter-panel .col-md-2 {
                margin-bottom: 10px;
            }
        }
        
        @media (max-width: 992px) {
            .filter-panel .col-md-3 {
                margin-bottom: 10px;
            }
        }
        
        /* Style cho modal form */
        #stockInModal .table td,
        #stockOutModal .table td {
            vertical-align: middle;
        }
        
        #stockInModal .table .btn,
        #stockOutModal .table .btn {
            white-space: nowrap;
        }
        
        /* Đảm bảo input trong table không bị quá lớn */
        #stockInModal .table .form-control,
        #stockOutModal .table .form-control {
            font-size: 13px;
        }
    </style>
    
    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
</head>
<body class="skin-black">
    <!-- header logo: style can be found in header.less -->
    <header class="header">
        <a href="<%=request.getContextPath()%>/admin.jsp" class="logo">
            Bảng điều khiển 
        </a>
        <!-- Header Navbar: style can be found in header.less -->
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
                <jsp:include page="partials/sidebar.jsp"/>
            </section>
            <!-- /.sidebar -->
        </aside>
        <aside class="right-side">
            <!-- Main content -->
            <section class="content">
                
                <div class="row">
                    <div class="col-xs-12">
                        <div class="panel">
                            <header class="panel-heading">
                                <h3>Danh sách hợp đồng</h3>
                                <div class="panel-tools">
                                    <button class="btn btn-success btn-sm" data-toggle="modal" data-target="#stockInModal">
                                        <i class="fa fa-arrow-down"></i> Nhập kho
                                    </button>
                                    <button class="btn btn-danger btn-sm" data-toggle="modal" data-target="#stockOutModal">
                                        <i class="fa fa-arrow-up"></i> Xuất kho
                                    </button>
                                    <a class="btn btn-warning btn-sm" href="<%=request.getContextPath()%>/stock.jsp">
                                        <i class="fa fa-cubes"></i> Tồn kho
                                    </a>
                                    <a class="btn btn-info btn-sm" href="<%=request.getContextPath()%>/stock_history.jsp">
                                        <i class="fa fa-history"></i> Lịch sử
                                    </a>
                                </div>
                            </header>
                            
                            <!-- Phần lọc -->
                            <div class="panel-body filter-panel">
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="row">
                                            <!-- Lọc theo trạng thái hợp đồng -->
                                            <div class="col-md-3">
                                                <div class="form-group">
                                                    <label for="filterContractStatus">Trạng thái:</label>
                                                    <select class="form-control" id="filterContractStatus">
                                                        <option value="">Tất cả trạng thái</option>
                                                        <option value="draft">Nháp</option>
                                                        <option value="active">Hiệu Lực</option>
                                                        <option value="terminated">Chấm Dứt</option>
                                                    </select>
                                                </div>
                                            </div>
                                            
                                            <!-- Tìm kiếm -->
                                            <div class="col-md-7">
                                                <div class="form-group">
                                                    <label for="searchContract">Tìm kiếm:</label>
                                                    <input type="text" class="form-control" id="searchContract" 
                                                           placeholder="Mã hợp đồng, tên khách hàng..." 
                                                           onkeypress="if(event.key==='Enter') filterContracts()">
                                                </div>
                                            </div>
                                            
                                            <!-- Nút lọc -->
                                            <div class="col-md-1">
                                                <div class="form-group">
                                                    <label style="color: transparent;">Lọc</label>
                                                    <button type="button" class="btn btn-primary btn-sm" 
                                                            style="width: 100%;" onclick="filterContracts()" 
                                                            title="Áp dụng bộ lọc">
                                                        <i class="fa fa-search"></i>
                                                    </button>
                                                </div>
                                            </div>
                                            
                                            <!-- Nút reset -->
                                            <div class="col-md-1">
                                                <div class="form-group">
                                                    <label style="color: transparent;">Reset</label>
                                                    <button type="button" class="btn btn-warning btn-sm" 
                                                            style="width: 100%;" onclick="resetFilters()" 
                                                            title="Xóa tất cả bộ lọc">
                                                        <i class="fa fa-refresh"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="panel-body table-responsive">
                                <table class="table table-hover" id="contractsTable">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Số hợp đồng</th>
                                            <th>Tên khách hàng</th>
                                            <th>Số điện thoại</th>
                                            <th>Loại</th>
                                            <th>Tiêu đề</th>
                                            <th>Ngày bắt đầu</th>
                                            <th>Giá trị</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td colspan="11" class="text-center">
                                                <i class="fa fa-spinner fa-spin"></i> Đang tải dữ liệu...
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                                
                                <!-- Phân trang -->
                                <div class="row" style="margin-top: 20px;">
                                    <div class="col-md-8">
                                        <div class="dataTables_info" id="paginationInfo" role="status" aria-live="polite">
                                            Hiển thị <span id="showingStart">0</span> đến <span id="showingEnd">0</span> 
                                            trong tổng số <span id="totalRecords">0</span> hợp đồng
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="dataTables_paginate paging_simple_numbers" style="text-align: right;">
                                            <ul class="pagination" id="pagination">
                                                <li class="paginate_button previous disabled">
                                                    <a href="#" id="prevBtn">Trước</a>
                                                </li>
                                                <li class="paginate_button active">
                                                    <a href="#" class="page-link" data-page="1">1</a>
                                                </li>
                                                <li class="paginate_button next">
                                                    <a href="#" id="nextBtn">Tiếp</a>
                                                </li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
            </section><!-- /.content -->
        </aside><!-- /.right-side -->
    </div><!-- ./wrapper -->

    <!-- Modal xem sản phẩm -->
    <div class="modal fade" id="invViewProductModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Chi tiết sản phẩm</h4>
                </div>
                <div class="modal-body" id="invViewProductContent">
                    <div class="text-center"><i class="fa fa-spinner fa-spin"></i> Đang tải...</div>
                </div>
                <div class="modal-footer">
                    <a class="btn btn-default" id="invViewHistoryBtn" href="#" target="_blank" style="display:none;">
                        <i class="fa fa-history"></i> Xem lịch sử
                    </a>
                    <button class="btn btn-primary" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal xem chi tiết hợp đồng -->
    <div class="modal fade" id="viewContractModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Chi tiết hợp đồng</h4>
                </div>
                <div class="modal-body" id="viewContractContent">
                    <div class="text-center"><i class="fa fa-spinner fa-spin"></i> Đang tải...</div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>


    <!-- Modal Nhập kho -->
    <div class="modal fade" id="stockInModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-xl" role="document" style="width: 95%; max-width: 1400px;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title"><i class="fa fa-arrow-down"></i> Phiếu Nhập Kho</h4>
                </div>
                <div class="modal-body" style="max-height: 80vh; overflow-y: auto;">
                    <form id="stockInForm">
                        <!-- Thông tin chung -->
                        <div class="row" style="margin-bottom: 20px;">
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Kho <span class="text-danger">*</span></label>
                                    <select id="stockInWarehouse" class="form-control" required>
                                        <option value="Main Warehouse">Kho Chính</option>
                                        <option value="Warehouse A">Kho A</option>
                                        <option value="Warehouse B">Kho B</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Nhà cung cấp <span class="text-danger">*</span></label>
                                    <select id="stockInSupplierId" class="form-control" required>
                                        <option value="">-- Chọn nhà cung cấp --</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Người liên hệ</label>
                                    <input type="text" id="stockInSupplierContact" class="form-control" readonly style="background-color: #f5f5f5;">
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Ngày nhập <span class="text-danger">*</span></label>
                                    <input type="date" id="stockInDate" class="form-control" required>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Bảng sản phẩm -->
                        <div class="form-group">
                            <div class="row" style="margin-bottom: 10px;">
                                <div class="col-md-12">
                                    <button type="button" class="btn btn-primary btn-sm" onclick="addStockInRow()">
                                        <i class="fa fa-plus"></i> Thêm sản phẩm
                                    </button>
                                </div>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-bordered table-hover" id="stockInProductsTable">
                                    <thead>
                                        <tr>
                                            <th style="width: 50px;">STT</th>
                                            <th style="width: 200px;">Sản phẩm <span class="text-danger">*</span></th>
                                            <th style="width: 200px;">Tên sản phẩm</th>
                                            <th style="width: 100px;">Đơn vị</th>
                                            <th style="width: 120px;">Số lượng <span class="text-danger">*</span></th>
                                            <th style="width: 150px;">Đơn giá nhập <span class="text-danger">*</span></th>
                                            <th style="width: 150px;">Tổng số tiền</th>
                                            <th style="width: 80px;">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="stockInProductsBody">
                                        <!-- Dòng sản phẩm sẽ được thêm bằng JavaScript -->
                                    </tbody>
                                    <tfoot>
                                        <tr>
                                            <td colspan="6" style="text-align: right; font-weight: bold;">Tổng cộng:</td>
                                            <td id="stockInTotalAmount" style="font-weight: bold; color: #d9534f; font-size: 16px;">0 VNĐ</td>
                                            <td></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        </div>
                        
                        <!-- Ghi chú -->
                        <div class="form-group">
                            <label>Ghi chú</label>
                            <textarea id="stockInNotes" class="form-control" rows="3" placeholder="Nhập ghi chú về giao dịch này..." oninput="updateWordCounter(this, 'stockInNotesCounter', 150)"></textarea>
                            <small class="form-text text-muted">
                                <span id="stockInNotesCounter" style="color:#5cb85c;">0</span> / 150 từ
                            </small>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button class="btn btn-success" onclick="submitStockIn()">
                        <i class="fa fa-save"></i> Nhập kho
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Xuất kho -->
    <div class="modal fade" id="stockOutModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-xl" role="document" style="width: 95%; max-width: 1400px;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title"><i class="fa fa-arrow-up"></i> Phiếu Xuất Kho</h4>
                </div>
                <div class="modal-body" style="max-height: 80vh; overflow-y: auto;">
                    <form id="stockOutForm">
                        <!-- Thông tin chung -->
                        <div class="row" style="margin-bottom: 20px;">
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Kho <span class="text-danger">*</span></label>
                                    <select id="stockOutWarehouse" class="form-control" required>
                                        <option value="Main Warehouse">Kho Chính</option>
                                        <option value="Warehouse A">Kho A</option>
                                        <option value="Warehouse B">Kho B</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Mã hợp đồng</label>
                                    <select id="stockOutContractId" class="form-control">
                                        <option value="">-- Chọn mã hợp đồng --</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Tên khách hàng</label>
                                    <input type="text" id="stockOutCustomerName" class="form-control" readonly style="background-color: #f5f5f5;">
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Lý do xuất kho <span class="text-danger">*</span></label>
                                    <select id="stockOutReason" class="form-control" required>
                                        <option value="">-- Chọn lý do --</option>
                                        <option value="Bán hàng">Bán hàng</option>
                                        <option value="Bảo hành">Bảo hành</option>
                                        <option value="Điều chuyển">Điều chuyển</option>
                                        <option value="Hỏng hóc">Hỏng hóc</option>
                                        <option value="Khác">Khác</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="row" style="margin-bottom: 20px;">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>Ngày xuất <span class="text-danger">*</span></label>
                                    <input type="date" id="stockOutDate" class="form-control" required>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Bảng sản phẩm -->
                        <div class="form-group">
                            <div class="row" style="margin-bottom: 10px;">
                                <div class="col-md-12">
                                    <button type="button" class="btn btn-primary btn-sm" onclick="addStockOutRow()">
                                        <i class="fa fa-plus"></i> Thêm sản phẩm
                                    </button>
                                </div>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-bordered table-hover" id="stockOutProductsTable">
                                    <thead>
                                        <tr>
                                            <th style="width: 50px;">STT</th>
                                            <th style="width: 200px;">Sản phẩm <span class="text-danger">*</span></th>
                                            <th style="width: 200px;">Tên sản phẩm</th>
                                            <th style="width: 100px;">Đơn vị</th>
                                            <th style="width: 120px;">Tồn khả dụng</th>
                                            <th style="width: 120px;">Số lượng xuất <span class="text-danger">*</span></th>
                                            <th style="width: 80px;">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="stockOutProductsBody">
                                        <!-- Dòng sản phẩm sẽ được thêm bằng JavaScript -->
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        
                        <!-- Ghi chú -->
                        <div class="form-group">
                            <label>Ghi chú</label>
                            <textarea id="stockOutNotes" class="form-control" rows="3" placeholder="Nhập ghi chú về giao dịch này..." oninput="updateWordCounter(this, 'stockOutNotesCounter', 150)"></textarea>
                            <small class="form-text text-muted">
                                <span id="stockOutNotesCounter" style="color:#5cb85c;">0</span> / 150 từ
                            </small>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button class="btn btn-danger" onclick="submitStockOut()">
                        <i class="fa fa-save"></i> Xuất kho
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- jQuery 2.0.2 -->
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/jquery.min.js" type="text/javascript"></script>
    <!-- jQuery UI 1.10.3 -->
    <script src="<%=request.getContextPath()%>/js/jquery-ui-1.10.3.min.js" type="text/javascript"></script>
    <!-- Bootstrap -->
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js" type="text/javascript"></script>
    <!-- Director App -->
    <script src="<%=request.getContextPath()%>/js/Director/app.js" type="text/javascript"></script>

    <script type="text/javascript">
        var currentPage = 1;
        var itemsPerPage = 10;
        var allProducts = [];
        
        // Khởi tạo window.productList và window.supplierList
        window.productList = [];
        window.supplierList = [];
        
        // Load dữ liệu khi trang được tải
        $(document).ready(function() {
            console.log('Page loaded, initializing...');
            loadProductsForDropdown();
            loadSuppliersForDropdown();
            loadContractsData();
        });
        
        /**
         * Hàm load dữ liệu hợp đồng
         */
        function loadContractsData() {
            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'GET',
                data: {
                    action: 'getContractsList',
                    status: $('#filterContractStatus').val(),
                    search: $('#searchContract').val(),
                    page: currentPage,
                    pageSize: itemsPerPage
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        console.log('Contracts loaded:', response.data);
                        console.log('Total contracts:', response.totalCount);
                        updateContractsTable(response.data);
                        updatePaginationInfo(response);
                    } else {
                        alert('Lỗi khi tải dữ liệu: ' + response.message);
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', error);
                    var tbody = $('#contractsTable tbody');
                    tbody.html('<tr><td colspan="11" class="text-center text-danger">Lỗi tải dữ liệu hợp đồng: ' + (error||'') + '</td></tr>');
                }
            });
        }
        
        /**
         * Cập nhật dropdown danh mục trong bộ lọc (chỉ 3 danh mục cố định)
         * @param {Array} categories - Danh sách danh mục từ server (không sử dụng, chỉ để giữ tương thích)
         */
        function updateCategoryFilter(categories) {
            var categorySelect = $('#filterCategory');
            var currentValue = categorySelect.val();
            
            // Chỉ hiển thị 3 danh mục cố định
            categorySelect.empty();
            categorySelect.append('<option value="">Tất cả danh mục</option>');
            categorySelect.append('<option value="Máy phát điện">Máy phát điện</option>');
            categorySelect.append('<option value="Máy bơm nước">Máy bơm nước</option>');
            categorySelect.append('<option value="Máy tiện">Máy tiện</option>');
            
            // Khôi phục giá trị đã chọn nếu có và hợp lệ
            if (currentValue && (currentValue === "Máy phát điện" || currentValue === "Máy bơm nước" || currentValue === "Máy tiện" || currentValue === "")) {
                categorySelect.val(currentValue);
            }
        }
        
        // Hàm load dữ liệu mẫu (fallback)
        function loadSampleData() {
            var sampleData = [
                {
                    id: 1,
                    productCode: 'GEN-001',
                    productName: 'Máy phát điện 10KVA',
                    category: 'Máy phát điện',
                    warehouse: 'Main Warehouse',
                    currentStock: 15,
                    minStock: 5,
                    maxStock: 50
                },
                {
                    id: 2,
                    productCode: 'GEN-002',
                    productName: 'Máy phát điện 20KVA',
                    category: 'Máy phát điện',
                    warehouse: 'Main Warehouse',
                    currentStock: 3,
                    minStock: 5,
                    maxStock: 30
                },
                {
                    id: 3,
                    productCode: 'PART-001',
                    productName: 'Bộ lọc dầu',
                    category: 'Phụ tùng',
                    warehouse: 'Main Warehouse',
                    currentStock: 0,
                    minStock: 10,
                    maxStock: 100
                }
            ];
            
            allProducts = sampleData;
            updateInventoryTable(sampleData);
            updateDashboard(sampleData);
        }
        
        // Cập nhật bảng hợp đồng
        function updateContractsTable(data) {
            var tbody = $('#contractsTable tbody');
            tbody.empty();
            
            if (data.length === 0) {
                tbody.append('<tr><td colspan="11" class="text-center text-muted">' +
                    '<i class="fa fa-info-circle"></i> Không có hợp đồng nào</td></tr>');
                return;
            }
            
            data.forEach(function(contract) {
                // Debug: log trạng thái của từng hợp đồng
                console.log('Contract ID:', contract.id, 'Status:', contract.status);
                
                var statusBadge = getStatusBadge(contract.status);
                var contractValue = contract.contractValue != null && contract.contractValue !== 'null' 
                    ? formatCurrencyVN(contract.contractValue) + ' VNĐ' 
                    : '--';
                
                // Tạo nút thao tác dựa vào trạng thái
                var actionButtons = '';
                var contractStatus = contract.status || '';
                
                // Hiển thị nút Xem cho tất cả hợp đồng
                actionButtons = '<button class="btn btn-info btn-xs" onclick="viewContract(' + contract.id + ')" title="Xem chi tiết">' +
                    '<i class="fa fa-eye"></i> Xem' +
                '</button>';
                
                // Hiển thị nút Xuất kho cho hợp đồng ở trạng thái draft hoặc active
                if (contractStatus === 'draft' || contractStatus === 'active') {
                    actionButtons += ' ' +
                        '<button class="btn btn-danger btn-xs" onclick="exportStockForContract(' + contract.id + ')" title="Xuất kho">' +
                        '<i class="fa fa-arrow-up"></i> Xuất kho' +
                    '</button>';
                }
                
                var row = '<tr>' +
                    '<td>' + contract.id + '</td>' +
                    '<td>' + escapeHtml(contract.contractNumber || '--') + '</td>' +
                    '<td>' + escapeHtml(contract.customerName || '--') + '</td>' +
                    '<td>' + escapeHtml(contract.customerPhone || '--') + '</td>' +
                    '<td>' + escapeHtml(contract.contractType || '--') + '</td>' +
                    '<td>' + escapeHtml(contract.title || '--') + '</td>' +
                    '<td>' + (contract.startDate || '--') + '</td>' +
                    '<td>' + contractValue + '</td>' +
                    '<td>' + statusBadge + '</td>' +
                    '<td>' + actionButtons + '</td>' +
                '</tr>';
                tbody.append(row);
            });
        }
        
        // Lấy badge trạng thái hợp đồng
        function getStatusBadge(status) {
            var badgeClass = 'label-default';
            var statusText = status;
            
            switch(status) {
                case 'draft':
                    badgeClass = 'label-default';
                    statusText = 'Nháp';
                    break;
                case 'active':
                    badgeClass = 'label-success';
                    statusText = 'Hiệu Lực';
                    break;
                case 'terminated':
                    badgeClass = 'label-danger';
                    statusText = 'Chấm Dứt';
                    break;
                case 'deleted':
                    badgeClass = 'label-default';
                    statusText = 'Đã xóa';
                    break;
                default:
                    badgeClass = 'label-default';
                    statusText = status || 'Không xác định';
                    break;
            }
            
            return '<span class="label ' + badgeClass + '">' + statusText + '</span>';
        }
        
        // Xem chi tiết hợp đồng - hiển thị modal với danh sách sản phẩm và kiểm tra kho
        function viewContract(contractId) {
            if (!contractId || contractId <= 0) {
                alert('ID hợp đồng không hợp lệ');
                return;
            }
            
            // Load chi tiết hợp đồng
            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'GET',
                data: { action: 'getContractDetails', contractId: contractId },
                dataType: 'json',
                success: function(response) {
                    if (response.success && response.data) {
                        var data = response.data;
                        var products = data.products || [];
                        
                        // Tạo HTML cho bảng sản phẩm
                        var productsHtml = '';
                        var insufficientProducts = [];
                        
                        if (products.length === 0) {
                            productsHtml = '<tr><td colspan="7" class="text-center text-muted">Hợp đồng chưa có sản phẩm</td></tr>';
                        } else {
                            products.forEach(function(product, index) {
                                var isAvailable = product.available === true;
                                var requiredQty = product.quantity || 0;
                                var totalQty = product.totalStock || 0;
                                var reservedQty = product.reservedStock || 0;
                                var availableQty = product.availableStock || 0;
                                var shortage = Math.max(requiredQty - availableQty, 0);
                                
                                // Lưu danh sách sản phẩm không đủ
                                if (!isAvailable) {
                                    insufficientProducts.push({
                                        name: product.productName || '',
                                        required: requiredQty,
                                        available: availableQty,
                                        total: totalQty,
                                        reserved: reservedQty,
                                        shortage: shortage
                                    });
                                }
                                
                                // Tạo badge và màu nền cho hàng
                                var availableBadge = isAvailable 
                                    ? '<span class="label label-success"><i class="fa fa-check"></i> Đủ</span>' 
                                    : '<span class="label label-danger"><i class="fa fa-times"></i> Thiếu</span>';
                                
                                // Màu nền cho hàng không đủ
                                var rowClass = isAvailable ? '' : 'danger';
                                var rowStyle = isAvailable ? '' : 'background-color: #f2dede;';
                                
                                var stockTitle = 'Tổng: ' + totalQty + ' | Giữ chỗ: ' + reservedQty + ' | Khả dụng: ' + availableQty;
                                
                                productsHtml += '<tr class="' + rowClass + '" style="' + rowStyle + '">' +
                                    '<td>' + (index + 1) + '</td>' +
                                    '<td><strong>' + escapeHtml(product.productCode || '') + '</strong></td>' +
                                    '<td><strong>' + escapeHtml(product.productName || '') + '</strong></td>' +
                                    '<td>' + escapeHtml(product.unit || '') + '</td>' +
                                    '<td style="text-align: right;"><strong>' + requiredQty + '</strong></td>' +
                                    '<td style="text-align: right;" title="' + stockTitle + '">' + availableQty + '</td>' +
                                    '<td style="text-align: center;">' + availableBadge;
                                
                                // Hiển thị số lượng thiếu nếu không đủ
                                if (!isAvailable) {
                                    productsHtml += '<br/><small class="text-danger">Thiếu: <strong>' + shortage + '</strong></small>';
                                }
                                
                                productsHtml += '</td></tr>';
                            });
                        }
                        
                        // Tạo nội dung modal
                        var modalContent = '<div class="row">' +
                            '<div class="col-md-12">' +
                                '<h4>Hợp đồng: ' + escapeHtml(data.contractNumber || '') + '</h4>' +
                                '<p><strong>Khách hàng:</strong> ' + escapeHtml(data.customerName || '') + '</p>' +
                                '<p><strong>Trạng thái:</strong> ' + getStatusBadge(data.status) + '</p>' +
                            '</div>' +
                        '</div>' +
                        '<hr/>' +
                        '<h5>Danh sách sản phẩm</h5>' +
                        '<div class="table-responsive">' +
                            '<table class="table table-bordered table-hover">' +
                                '<thead>' +
                                    '<tr>' +
                                        '<th style="width: 50px;">STT</th>' +
                                        '<th>Mã sản phẩm</th>' +
                                        '<th>Tên sản phẩm</th>' +
                                        '<th>Đơn vị</th>' +
                                        '<th style="text-align: right;">Số lượng cần</th>' +
                                        '<th style="text-align: right;">Tồn khả dụng</th>' +
                                        '<th style="text-align: center;">Trạng thái</th>' +
                                    '</tr>' +
                                '</thead>' +
                                '<tbody>' + productsHtml + '</tbody>' +
                            '</table>' +
                        '</div>';
                        
                        // Hiển thị thông báo validation
                        if (data.status === 'pending_approval') {
                            if (data.allProductsAvailable) {
                                // Tất cả sản phẩm đều đủ
                                modalContent += '<div class="alert alert-success" style="margin-top: 15px;">' +
                                    '<i class="fa fa-check-circle"></i> <strong>Thông báo</strong><br/>' +
                                    'Tất cả sản phẩm đều đủ trong kho. Bạn có thể duyệt hợp đồng.' +
                                '</div>';
                            } else {
                                // Có sản phẩm không đủ - hiển thị chi tiết
                                var insufficientList = '';
                                insufficientProducts.forEach(function(p) {
                                    insufficientList += '<li><strong>' + escapeHtml(p.name) + '</strong>: ' +
                                        'Cần <span class="text-danger"><strong>' + p.required + '</strong></span>, ' +
                                        'Có <span class="text-warning"><strong>' + p.available + '</strong></span> (Tổng: ' + p.total + ', Giữ chỗ: ' + p.reserved + '), ' +
                                        'Thiếu <span class="text-danger"><strong>' + p.shortage + '</strong></span></li>';
                                });
                                
                                modalContent += '<div class="alert alert-danger" style="margin-top: 15px;">' +
                                    '<i class="fa fa-exclamation-triangle"></i> <strong>Thiếu hàng!</strong><br/>' +
                                    '<strong>Không thể duyệt hợp đồng vì có sản phẩm không đủ trong kho:</strong>' +
                                    '<ul style="margin-top: 10px; margin-bottom: 0;">' + insufficientList + '</ul>' +
                                    '<p style="margin-top: 10px; margin-bottom: 0;"><strong>Vui lòng nhập thêm hàng vào kho trước khi duyệt hợp đồng.</strong></p>' +
                                '</div>';
                            }
                        }
                        
                        $('#viewContractContent').html(modalContent);
                        $('#viewContractModal').data('contract-id', contractId);
                        $('#viewContractModal').data('contract-status', data.status);
                        $('#viewContractModal').data('all-products-available', data.allProductsAvailable);
                        
                        
                        $('#viewContractModal').modal('show');
                    } else {
                        alert('Không thể tải thông tin hợp đồng: ' + (response.message || 'Lỗi không xác định'));
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', error);
                    alert('Lỗi kết nối đến server: ' + error);
                }
            });
        }
        
        // Biến flag để tránh reset form khi đang load từ exportStockForContract
        var isExportingFromContract = false;
        
        // Xuất kho cho hợp đồng đã duyệt
        // Tự động mở form xuất kho và load dữ liệu từ hợp đồng
        function exportStockForContract(contractId) {
            if (!contractId || contractId <= 0) {
                alert('ID hợp đồng không hợp lệ');
                return;
            }
            
            console.log('Export stock for contract ID:', contractId);
            
            // Set flag để tránh reset form
            isExportingFromContract = true;
            
            // Kiểm tra xem modal đã mở chưa
            var modal = $('#stockOutModal');
            var isModalVisible = modal.is(':visible') || modal.hasClass('in');
            
            if (isModalVisible) {
                // Nếu modal đã mở, load trực tiếp
                loadContractsForDropdown(function() {
                    setContractAndLoadInfo(contractId);
                });
            } else {
                // Mở modal xuất kho
                modal.modal('show');
                
                // Đợi modal mở xong rồi load dữ liệu hợp đồng
                modal.one('shown.bs.modal', function() {
                    // Load danh sách hợp đồng vào dropdown trước (luôn load để đảm bảo có đầy đủ options)
                    loadContractsForDropdown(function() {
                        setContractAndLoadInfo(contractId);
                    });
                });
            }
        }
        
        // Helper function để set contract và load info từ backend
        function setContractAndLoadInfo(contractId) {
            console.log('Setting contract ID and loading info from backend:', contractId);
            
            // Lấy warehouse được chọn (nếu có)
            var warehouse = $('#stockOutWarehouse').val() || 'Main Warehouse';
            
            // Gọi backend để lấy đầy đủ thông tin hợp đồng, sản phẩm và tồn kho
            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'GET',
                data: { 
                    action: 'getContractInfoForStockOut', 
                    contractId: contractId,
                    warehouse: warehouse
                },
                dataType: 'json',
                success: function(response) {
                    console.log('Contract info from backend:', response);
                    if (response.success && response.data) {
                        var data = response.data;
                        
                        // Set contract ID trong dropdown
                        var contractSelect = $('#stockOutContractId');
                        contractSelect.val(contractId);
                        
                        // Hiển thị tên khách hàng từ backend
                        $('#stockOutCustomerName').val(data.customerName || '');
                        
                        // Set ngày mặc định từ backend (hôm nay) và có thể chỉnh sửa
                        if (data.defaultDate) {
                            $('#stockOutDate').val(data.defaultDate);
                        }
                        
                        // Xóa tất cả sản phẩm hiện tại trong bảng
                        $('#stockOutProductsBody').empty();
                        stockOutRowCounter = 0;
                        
                        // Thêm sản phẩm từ backend vào bảng
                        if (data.products && data.products.length > 0) {
                            data.products.forEach(function(product) {
                                addProductRowFromBackend(product, warehouse);
                            });
                        }
                        
                        console.log('Successfully loaded contract info from backend');
                    } else {
                        console.error('Failed to load contract info:', response.message);
                        alert('Lỗi khi tải thông tin hợp đồng: ' + (response.message || 'Unknown error'));
                    }
                    
                    // Reset flag sau khi load xong
                    setTimeout(function() {
                        isExportingFromContract = false;
                    }, 500);
                },
                error: function(xhr, status, error) {
                    console.error('Error loading contract info from backend:', error);
                    alert('Lỗi khi tải thông tin hợp đồng: ' + error);
                    isExportingFromContract = false;
                }
            });
        }
        
        // Helper function để thêm dòng sản phẩm từ dữ liệu backend
        function addProductRowFromBackend(product, warehouse) {
            stockOutRowCounter++;
            var rowId = 'stockOutRow_' + stockOutRowCounter;
            var tbody = $('#stockOutProductsBody');
            
            // Tìm tồn kho tại warehouse được chọn
            var currentStock = 0;
            var totalStock = 0;
            var reservedStock = 0;
            if (product.stocks && product.stocks.length > 0) {
                var stockAtWarehouse = product.stocks.find(function(s) {
                    return s.warehouse === warehouse;
                });
                if (stockAtWarehouse) {
                    totalStock = stockAtWarehouse.stock || 0;
                    reservedStock = stockAtWarehouse.reserved || 0;
                    currentStock = stockAtWarehouse.available || Math.max(totalStock - reservedStock, 0);
                }
            }
            var stockTitle = 'Tổng: ' + totalStock + ' | Giữ chỗ: ' + reservedStock + ' | Khả dụng: ' + currentStock;
            
            var row = '<tr id="' + rowId + '">' +
                '<td style="text-align: center; vertical-align: middle;">' + stockOutRowCounter + '</td>' +
                '<td>' +
                    '<select class="form-control stockOutProductSelect" data-row-id="' + rowId + '" required>' +
                    '</select>' +
                '</td>' +
                '<td style="vertical-align: middle;">' +
                    '<input type="text" class="form-control stockOutProductName" readonly style="background-color: #f5f5f5;">' +
                '</td>' +
                '<td style="text-align: center; vertical-align: middle;">' +
                    '<input type="text" class="form-control stockOutProductUnit" readonly style="background-color: #f5f5f5; text-align: center;">' +
                '</td>' +
                '<td style="text-align: center; vertical-align: middle;">' +
                    '<span class="stockOutCurrentStock" style="font-weight: bold; color: #5cb85c;" title="' + stockTitle + '">' + currentStock + '</span>' +
                '</td>' +
                '<td>' +
                    '<input type="number" class="form-control stockOutQuantity" min="1" max="' + currentStock + '" value="' + (product.quantity && product.quantity > 0 ? product.quantity : '') + '" required placeholder="Nhập số lượng" style="text-align: right;">' +
                '</td>' +
                '<td style="text-align: center; vertical-align: middle;">' +
                    '<button type="button" class="btn btn-danger btn-xs" onclick="removeStockOutRow(\'' + rowId + '\')" title="Xóa dòng">' +
                        '<i class="fa fa-trash"></i> Xóa' +
                    '</button>' +
                '</td>' +
            '</tr>';
            
            tbody.append(row);
            
            // Render options cho dropdown sản phẩm
            var selectEl = $('#' + rowId + ' .stockOutProductSelect');
            renderStockOutProductOptions(selectEl);
            
            // Set sản phẩm được chọn và cập nhật thông tin
            setTimeout(function() {
                selectEl.val(product.productId);
                var selectedOption = selectEl.find('option:selected');
                if (selectedOption.length > 0) {
                    $('#' + rowId + ' .stockOutProductName').val(selectedOption.data('name') || product.productName || '');
                    $('#' + rowId + ' .stockOutProductUnit').val(selectedOption.data('unit') || product.unit || '');
                } else {
                    $('#' + rowId + ' .stockOutProductName').val(product.productName || '');
                    $('#' + rowId + ' .stockOutProductUnit').val(product.unit || '');
                }
                
                // Gán sự kiện change cho dropdown sản phẩm
                selectEl.off('change').on('change', function() {
                    var row = $(this).closest('tr');
                    var selectedOption = $(this).find('option:selected');
                    var productId = $(this).val();
                    var warehouse = $('#stockOutWarehouse').val();
                    
                    if (productId) {
                        row.find('.stockOutProductName').val(selectedOption.data('name') || '');
                        row.find('.stockOutProductUnit').val(selectedOption.data('unit') || '');
                        loadCurrentStock(productId, warehouse, row);
                    } else {
                        row.find('.stockOutProductName').val('');
                        row.find('.stockOutProductUnit').val('');
                        row.find('.stockOutCurrentStock').text('--').attr('title', '');
                    }
                });
                
                // Gán sự kiện input cho số lượng
                $('#' + rowId + ' .stockOutQuantity').off('input').on('input', function() {
                    var row = $(this).closest('tr');
                    var quantity = parseInt($(this).val()) || 0;
                    var currentStock = parseInt(row.find('.stockOutCurrentStock').text()) || 0;
                    
                    if (quantity > currentStock) {
                        $(this).val(currentStock);
                        alert('Số lượng xuất không được vượt quá tồn kho khả dụng (' + currentStock + ')');
                    }
                });
            }, 100);
        }
        
        // Xác định trạng thái tồn kho
        function getStockStatus(currentStock, minStock) {
            if (currentStock === 0) {
                return { class: 'stock-out', text: 'Hết hàng' };
            } else if (currentStock <= minStock) {
                return { class: 'stock-low', text: 'Sắp hết' };
            } else {
                return { class: 'stock-normal', text: 'Bình thường' };
            }
        }
        
        // (Đã loại bỏ các hàm tổng hợp client-side; phân trang/đếm hiển thị do backend cung cấp)
        
        // Cập nhật phân trang từ response
        function updatePaginationInfo(response) {
            var startItem = (response.currentPage - 1) * response.pageSize + 1;
            var endItem = Math.min(response.currentPage * response.pageSize, response.totalCount);
            
            $('#showingStart').text(response.totalCount > 0 ? startItem : 0);
            $('#showingEnd').text(endItem);
            $('#totalRecords').text(response.totalCount);
        }

        // Định dạng số tiền VNĐ (dùng cho cột giá)
        function formatCurrencyVN(n){
            try { return Number(n).toLocaleString('vi-VN'); } catch(e) { return n; }
        }

        // Cập nhật bộ đếm số từ + đổi màu khi vượt quá
        function updateWordCounter(textarea, counterId, limit){
            var text = textarea && textarea.value ? textarea.value : '';
            var words = text.trim().length ? text.trim().split(/\s+/).filter(function(w){ return w.length>0; }) : [];
            var count = words.length;
            var el = document.getElementById(counterId);
            if (el){
                el.textContent = count;
                if (count > limit){
                    el.style.color = '#d9534f';
                    textarea.style.borderColor = '#d9534f';
                } else {
                    el.style.color = '#5cb85c';
                    textarea.style.borderColor = '';
                }
            }
        }

        function buildHistoryUrl(productId){
            return '<%=request.getContextPath()%>/stock_history.jsp?productId=' + encodeURIComponent(productId);
        }


        // Xem chi tiết sản phẩm (modal)
        function invViewProduct(productId) {
            if (!productId) { alert('ID sản phẩm không hợp lệ'); return; }
            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'GET',
                data: { action: 'getInventoryDetail', productId: productId },
                dataType: 'json',
                success: function(res){
                    if (!res.success) { alert('Không thể tải thông tin sản phẩm'); return; }
                    var d = res.data || {};
                    var statusBadge = d.status === 'active' ? '<span class="label label-success">Đang bán</span>' : '<span class="label label-warning">Ngừng bán</span>';
                    var html = ''+
                        '<div class="row">'+
                          '<div class="col-sm-6">'+
                            '<h4 style="margin-top:0">'+escapeHtml(d.productName||'')+'</h4>'+statusBadge+
                            '<p><strong>Mã:</strong> '+escapeHtml(d.productCode||'')+'</p>'+
                            '<p><strong>Danh mục:</strong> '+escapeHtml(d.category||'')+'</p>'+
                            '<p><strong>Đơn vị:</strong> '+escapeHtml(d.unit||'')+'</p>'+
                            '<p><strong>Giá bán:</strong> '+(d.unitPrice!=null?formatCurrencyVN(d.unitPrice):'--')+' VNĐ</p>'+
                            '<p><strong>Giá nhập gần nhất:</strong> '+(d.unitCost!=null?formatCurrencyVN(d.unitCost):'--')+' VNĐ</p>'+
                            '<p><strong>Số lượng tồn:</strong> '+(d.totalStock!=null?d.totalStock:'--')+'</p>'+
                            '<p><strong>Số lượng đã bán:</strong> '+(d.quantitySold!=null?d.quantitySold:'--')+'</p>'+
                          '</div>'+
                          '<div class="col-sm-6">'+
                            (d.imageUrl?('<img src="'+d.imageUrl+'" style="max-width:100%;border:1px solid #eee;border-radius:6px">'):'')+
                          '</div>'+
                        '</div>'+
                        '<hr/>'+
                        '<p><strong>Mô tả:</strong><br>' + (escapeHtml(d.description||'Không có')) + '</p>'+
                        '<p><strong>Thông số kỹ thuật:</strong><br>' + (escapeHtml(d.specifications||'Không có')) + '</p>'+
                        '<h4>Vị trí kho</h4>'+
                        renderWarehouseTable(d.warehouses||[]);
                    $('#invViewProductContent').html(html);
                    $('#invViewProductModal').modal('show');
                },
                error: function(){ alert('Lỗi kết nối máy chủ'); }
            });
        }

        function escapeHtml(s){ if(!s) return ''; return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\"/g,'&quot;').replace(/'/g,'&#39;'); }

        function renderWarehouseTable(rows){
            if (!rows || rows.length === 0) return '<div class="muted">Không có dữ liệu vị trí kho</div>';
            var html = '<table class="table table-bordered"><thead><tr><th>Kho</th><th>Tồn</th></tr></thead><tbody>';
            rows.forEach(function(r){ html += '<tr><td>'+escapeHtml(r.warehouse||'')+'</td><td>'+ (r.stock!=null?r.stock:'--') +'</td></tr>'; });
            html += '</tbody></table>';
            return html;
        }
        
        // Load sản phẩm cho dropdown
        function loadProductsForDropdown() {
            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'GET',
                data: { action: 'getProducts' },
                dataType: 'json',
                success: function(response) {
                    console.log('Products loaded:', response);
                    if (response.success && response.data) {
                        window.productList = response.data;
                        console.log('Total products:', window.productList.length);
                    } else {
                        console.warn('No products found or response failed');
                        window.productList = [];
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error loading products:', error);
                    console.error('Response:', xhr.responseText);
                    window.productList = [];
                }
            });
        }
        
        // Load nhà cung cấp cho dropdown từ backend
        function loadSuppliersForDropdown() {
            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'GET',
                data: { action: 'getSuppliers' },
                dataType: 'json',
                success: function(response) {
                    console.log('Suppliers loaded:', response);
                    if (response.success && response.data) {
                        window.supplierList = response.data;
                        console.log('Total suppliers:', window.supplierList.length);
                        renderStockInSupplierOptions();
                    } else {
                        console.warn('No suppliers found or response failed');
                        window.supplierList = [];
                        renderStockInSupplierOptions();
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error loading suppliers:', error);
                    console.error('Response:', xhr.responseText);
                    window.supplierList = [];
                    renderStockInSupplierOptions();
                }
            });
        }
        
        // Render options cho dropdown nhà cung cấp
        function renderStockInSupplierOptions() {
            var selectEl = $('#stockInSupplierId');
            if (selectEl.length === 0) return;
            
            var options = '<option value="">-- Chọn nhà cung cấp --</option>';
            (window.supplierList || []).forEach(function(s) {
                options += '<option value="' + s.id + '" data-name="' + escapeHtml(s.companyName || '') + '" data-contact="' + escapeHtml(s.contactPerson || '') + '">' + 
                          escapeHtml(s.supplierCode || '') + ' - ' + escapeHtml(s.companyName || '') + '</option>';
            });
            selectEl.html(options);
            
            // Gán sự kiện change để hiển thị người liên hệ
            selectEl.off('change').on('change', function() {
                var selectedOption = $(this).find('option:selected');
                var contactPerson = selectedOption.data('contact') || '';
                $('#stockInSupplierContact').val(contactPerson);
            });
        }

        // Biến đếm số dòng sản phẩm
        var stockInRowCounter = 0;
        
        // Render options cho select sản phẩm (dùng chung cho tất cả dropdown)
        function renderStockInProductOptions(selectElement) {
            if (!selectElement || selectElement.length === 0) return;
            var options = '<option value="">-- Chọn sản phẩm --</option>';
            (window.productList || []).forEach(function(p) {
                options += '<option value="' + p.id + '" data-name="' + escapeHtml(p.productName || '') + '" data-unit="' + escapeHtml(p.unit || '') + '" data-supplier="' + escapeHtml(p.supplierName || '') + '">' + p.productCode + ' - ' + p.productName + '</option>';
            });
            selectElement.html(options);
        }
        
        // Thêm dòng sản phẩm mới vào bảng
        function addStockInRow() {
            stockInRowCounter++;
            var rowId = 'stockInRow_' + stockInRowCounter;
            var tbody = $('#stockInProductsBody');
            
            var row = '<tr id="' + rowId + '">' +
                '<td style="text-align: center; vertical-align: middle;">' + stockInRowCounter + '</td>' +
                '<td>' +
                    '<select class="form-control stockInProductSelect" data-row-id="' + rowId + '" required>' +
                    '</select>' +
                '</td>' +
                '<td style="vertical-align: middle;">' +
                    '<input type="text" class="form-control stockInProductName" readonly style="background-color: #f5f5f5;">' +
                '</td>' +
                '<td style="text-align: center; vertical-align: middle;">' +
                    '<input type="text" class="form-control stockInProductUnit" readonly style="background-color: #f5f5f5; text-align: center;">' +
                '</td>' +
                '<td>' +
                    '<input type="number" class="form-control stockInQuantity" min="1" value="" required placeholder="Nhập số lượng" style="text-align: right;">' +
                '</td>' +
                '<td>' +
                    '<input type="number" class="form-control stockInUnitCost" min="1" step="1000" value="" required placeholder="Nhập đơn giá" style="text-align: right;">' +
                '</td>' +
                '<td style="text-align: right; vertical-align: middle;">' +
                    '<span class="stockInRowTotal" style="font-weight: bold; color: #d9534f;">0 VNĐ</span>' +
                '</td>' +
                '<td style="text-align: center; vertical-align: middle;">' +
                    '<button type="button" class="btn btn-danger btn-xs" onclick="removeStockInRow(\'' + rowId + '\')" title="Xóa dòng">' +
                        '<i class="fa fa-trash"></i> Xóa' +
                    '</button>' +
                '</td>' +
            '</tr>';
            
            tbody.append(row);
            
            // Render options cho dropdown sản phẩm vừa thêm
            var selectEl = $('#' + rowId + ' .stockInProductSelect');
            renderStockInProductOptions(selectEl);
            
            // Gán sự kiện change cho dropdown sản phẩm
            selectEl.off('change').on('change', function() {
                var row = $(this).closest('tr');
                var selectedOption = $(this).find('option:selected');
                var productId = $(this).val();
                
                if (productId) {
                    // Cập nhật tên sản phẩm
                    row.find('.stockInProductName').val(selectedOption.data('name') || '');
                    // Cập nhật đơn vị
                    row.find('.stockInProductUnit').val(selectedOption.data('unit') || '');
                    // Cập nhật nhà cung cấp (nếu chưa có) - tìm supplierId từ product
                    var supplierName = selectedOption.data('supplier') || '';
                    if (supplierName && !$('#stockInSupplierId').val()) {
                        // Tìm supplierId từ supplierList dựa vào tên
                        var matchedSupplier = (window.supplierList || []).find(function(s) {
                            return s.companyName === supplierName;
                        });
                        if (matchedSupplier) {
                            $('#stockInSupplierId').val(matchedSupplier.id).trigger('change');
                        }
                    }
                } else {
                    row.find('.stockInProductName').val('');
                    row.find('.stockInProductUnit').val('');
                }
                
                // Tính lại tổng tiền của dòng
                calculateRowTotal(row);
            });
            
            // Gán sự kiện input cho số lượng và đơn giá
            $('#' + rowId + ' .stockInQuantity, #' + rowId + ' .stockInUnitCost').off('input').on('input', function() {
                calculateRowTotal($(this).closest('tr'));
            });
            
            // Cập nhật lại STT cho tất cả các dòng
            updateStockInRowNumbers();
        }
        
        // Xóa dòng sản phẩm
        function removeStockInRow(rowId) {
            $('#' + rowId).remove();
            updateStockInRowNumbers();
            calculateTotalAmount();
        }
        
        // Cập nhật lại số thứ tự các dòng
        function updateStockInRowNumbers() {
            $('#stockInProductsBody tr').each(function(index) {
                $(this).find('td:first').text(index + 1);
            });
        }
        
        // Tính tổng tiền của 1 dòng
        function calculateRowTotal(row) {
            var quantity = parseFloat(row.find('.stockInQuantity').val()) || 0;
            var unitCost = parseFloat(row.find('.stockInUnitCost').val()) || 0;
            var total = quantity * unitCost;
            row.find('.stockInRowTotal').text(formatCurrencyVN(total) + ' VNĐ');
            calculateTotalAmount();
        }
        
        // Tính tổng tiền tất cả các dòng
        function calculateTotalAmount() {
            var total = 0;
            $('#stockInProductsBody tr').each(function() {
                var quantity = parseFloat($(this).find('.stockInQuantity').val()) || 0;
                var unitCost = parseFloat($(this).find('.stockInUnitCost').val()) || 0;
                total += quantity * unitCost;
            });
            $('#stockInTotalAmount').text(formatCurrencyVN(total) + ' VNĐ');
        }
        
        // Submit form nhập kho (nhiều sản phẩm)
        function submitStockIn() {
            var warehouse = $('#stockInWarehouse').val();
            var notes = $('#stockInNotes').val();
            var supplierId = $('#stockInSupplierId').val();
            var receiptDate = $('#stockInDate').val();

            // Validate thông tin chung
            if (!warehouse) {
                alert('Vui lòng chọn kho!');
                return;
            }
            if (!supplierId || supplierId === '') {
                alert('Vui lòng chọn nhà cung cấp!');
                return;
            }
            if (!receiptDate) {
                alert('Vui lòng chọn ngày nhập!');
                return;
            }

            // Validate ngày nhập: không được là ngày quá khứ (hôm qua trở về trước)
            var today = new Date();
            today.setHours(0,0,0,0);
            var chosen = new Date(receiptDate);
            chosen.setHours(0,0,0,0);
            if (chosen < today) {
                alert('Ngày nhập không được nhỏ hơn ngày hôm nay.');
                return;
            }

            // Validate ghi chú tối đa 150 từ
            if (notes) {
                var wordCount = notes.trim().split(/\s+/).filter(function(w){ return w.length > 0; }).length;
                if (wordCount > 150) {
                    alert('Ghi chú không được vượt quá 150 từ (hiện tại: ' + wordCount + ').');
                    return;
                }
            }

            // Lấy tất cả sản phẩm từ bảng
            var products = [];
            var hasError = false;
            var errorMsg = '';

            $('#stockInProductsBody tr').each(function(index) {
                var row = $(this);
                var productId = row.find('.stockInProductSelect').val();
                var quantity = row.find('.stockInQuantity').val();
                var unitCost = row.find('.stockInUnitCost').val();
                var productName = row.find('.stockInProductName').val();

                // Validate từng dòng
                if (!productId) {
                    hasError = true;
                    errorMsg = 'Dòng ' + (index + 1) + ': Vui lòng chọn sản phẩm!';
                    return false; // break loop
                }
                if (!quantity || quantity <= 0 || !Number.isInteger(Number(quantity))) {
                    hasError = true;
                    errorMsg = 'Dòng ' + (index + 1) + ' (' + productName + '): Số lượng phải là số nguyên dương!';
                    return false;
                }
                if (!unitCost || unitCost <= 0) {
                    hasError = true;
                    errorMsg = 'Dòng ' + (index + 1) + ' (' + productName + '): Đơn giá nhập phải lớn hơn 0!';
                    return false;
                }

                products.push({
                    productId: parseInt(productId),
                    quantity: parseInt(quantity),
                    unitCost: parseFloat(unitCost),
                    warehouse: warehouse
                });
            });

            if (hasError) {
                alert(errorMsg);
                return;
            }

            if (products.length === 0) {
                alert('Vui lòng thêm ít nhất một sản phẩm!');
                return;
            }

            // Lấy tên nhà cung cấp từ dropdown
            var supplierName = '';
            if (supplierId) {
                var selectedSupplier = (window.supplierList || []).find(function(s) {
                    return String(s.id) === String(supplierId);
                });
                if (selectedSupplier) {
                    supplierName = selectedSupplier.companyName || '';
                }
            }

            var formData = {
                action: 'stockIn',
                notes: notes,
                supplierId: supplierId,
                supplierName: supplierName,
                receiptDate: receiptDate,
                products: JSON.stringify(products)
            };

            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'POST',
                data: formData,
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        alert('Nhập kho thành công!');
                        $('#stockInModal').modal('hide');
                        loadInventoryData();
                    } else {
                        alert('Lỗi: ' + response.message);
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', error);
                    alert('Lỗi kết nối server: ' + error);
                }
            });
        }
        
        // ========== XUẤT KHO ==========
        // Biến đếm số dòng sản phẩm xuất kho
        var stockOutRowCounter = 0;
        
        // Thêm dòng sản phẩm mới vào bảng xuất kho
        function addStockOutRow() {
            stockOutRowCounter++;
            var rowId = 'stockOutRow_' + stockOutRowCounter;
            var tbody = $('#stockOutProductsBody');
            
            var row = '<tr id="' + rowId + '">' +
                '<td style="text-align: center; vertical-align: middle;">' + stockOutRowCounter + '</td>' +
                '<td>' +
                    '<select class="form-control stockOutProductSelect" data-row-id="' + rowId + '" required>' +
                    '</select>' +
                '</td>' +
                '<td style="vertical-align: middle;">' +
                    '<input type="text" class="form-control stockOutProductName" readonly style="background-color: #f5f5f5;">' +
                '</td>' +
                '<td style="text-align: center; vertical-align: middle;">' +
                    '<input type="text" class="form-control stockOutProductUnit" readonly style="background-color: #f5f5f5; text-align: center;">' +
                '</td>' +
                '<td style="text-align: center; vertical-align: middle;">' +
                    '<span class="stockOutCurrentStock" style="font-weight: bold; color: #5cb85c;">--</span>' +
                '</td>' +
                '<td>' +
                    '<input type="number" class="form-control stockOutQuantity" min="1" value="" required placeholder="Nhập số lượng" style="text-align: right;">' +
                '</td>' +
                '<td style="text-align: center; vertical-align: middle;">' +
                    '<button type="button" class="btn btn-danger btn-xs" onclick="removeStockOutRow(\'' + rowId + '\')" title="Xóa dòng">' +
                        '<i class="fa fa-trash"></i> Xóa' +
                    '</button>' +
                '</td>' +
            '</tr>';
            
            tbody.append(row);
            
            // Render options cho dropdown sản phẩm vừa thêm
            var selectEl = $('#' + rowId + ' .stockOutProductSelect');
            renderStockOutProductOptions(selectEl);
            
            // Gán sự kiện change cho dropdown sản phẩm
            selectEl.off('change').on('change', function() {
                var row = $(this).closest('tr');
                var selectedOption = $(this).find('option:selected');
                var productId = $(this).val();
                var warehouse = $('#stockOutWarehouse').val();
                
                if (productId) {
                    // Cập nhật tên sản phẩm và đơn vị
                    row.find('.stockOutProductName').val(selectedOption.data('name') || '');
                    row.find('.stockOutProductUnit').val(selectedOption.data('unit') || '');
                    
                    // Load tồn khả dụng tại kho
                    loadCurrentStock(productId, warehouse, row);
                } else {
                    row.find('.stockOutProductName').val('');
                    row.find('.stockOutProductUnit').val('');
                    row.find('.stockOutCurrentStock').text('--').attr('title', '');
                }
            });
            
            // Gán sự kiện change cho kho để cập nhật tồn kho
            $('#stockOutWarehouse').off('change.stockOut').on('change.stockOut', function() {
                var warehouse = $(this).val();
                $('#stockOutProductsBody tr').each(function() {
                    var productId = $(this).find('.stockOutProductSelect').val();
                    if (productId) {
                        loadCurrentStock(productId, warehouse, $(this));
                    }
                });
            });
            
            // Validate số lượng xuất không vượt quá tồn kho
            $('#' + rowId + ' .stockOutQuantity').off('input').on('input', function() {
                var row = $(this).closest('tr');
                var quantity = parseInt($(this).val()) || 0;
                var currentStock = parseInt(row.find('.stockOutCurrentStock').text()) || 0;
                
                if (quantity > currentStock) {
                    $(this).css('border-color', '#d9534f');
                    alert('Số lượng xuất (' + quantity + ') không được vượt quá tồn kho khả dụng (' + currentStock + ')!');
                    $(this).val(currentStock);
                } else {
                    $(this).css('border-color', '');
                }
            });
            
            // Cập nhật lại STT cho tất cả các dòng
            updateStockOutRowNumbers();
        }
        
        // Render options cho select sản phẩm xuất kho
        function renderStockOutProductOptions(selectElement) {
            if (!selectElement || selectElement.length === 0) return;
            var options = '<option value="">-- Chọn sản phẩm --</option>';
            (window.productList || []).forEach(function(p) {
                options += '<option value="' + p.id + '" data-name="' + escapeHtml(p.productName || '') + '" data-unit="' + escapeHtml(p.unit || '') + '">' + p.productCode + ' - ' + p.productName + '</option>';
            });
            selectElement.html(options);
        }
        
        // Load tồn khả dụng của sản phẩm
        function loadCurrentStock(productId, warehouse, row) {
            if (!productId || !warehouse) {
                    row.find('.stockOutCurrentStock').text('--').attr('title', '');
                return;
            }
            
            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'GET',
                data: { action: 'getInventoryDetail', productId: productId },
                dataType: 'json',
                success: function(response) {
                    if (response.success && response.data && response.data.warehouses) {
                        var warehouses = response.data.warehouses;
                        var found = warehouses.find(function(w) {
                            return w.warehouse === warehouse;
                        });
                        var available = found ? (found.available || 0) : 0;
                        var total = found ? (found.stock || 0) : 0;
                        var reserved = found ? (found.reserved || 0) : 0;
                        var title = 'Tổng: ' + total + ' | Giữ chỗ: ' + reserved + ' | Khả dụng: ' + available;
                        row.find('.stockOutCurrentStock').text(available).attr('title', title);
                        
                        // Cập nhật max cho input số lượng
                        row.find('.stockOutQuantity').attr('max', available);
                    } else {
                        row.find('.stockOutCurrentStock').text('0').attr('title', '');
                        row.find('.stockOutQuantity').attr('max', 0);
                    }
                },
                error: function() {
                    row.find('.stockOutCurrentStock').text('--').attr('title', '');
                }
            });
        }
        
        // Xóa dòng sản phẩm xuất kho
        function removeStockOutRow(rowId) {
            $('#' + rowId).remove();
            updateStockOutRowNumbers();
        }
        
        // Cập nhật lại số thứ tự các dòng xuất kho
        function updateStockOutRowNumbers() {
            $('#stockOutProductsBody tr').each(function(index) {
                $(this).find('td:first').text(index + 1);
            });
        }
        
        // Submit form xuất kho - chỉ validate UI, xử lý chính ở backend
        function submitStockOut() {
            var warehouse = $('#stockOutWarehouse').val();
            var reason = $('#stockOutReason').val();
            var notes = $('#stockOutNotes').val();
            var outDate = $('#stockOutDate').val();

            // Validate thông tin chung (UI validation)
            if (!warehouse) {
                alert('Vui lòng chọn kho!');
                return;
            }
            if (!reason || reason === '') {
                alert('Vui lòng chọn lý do xuất kho!');
                return;
            }
            if (!outDate) {
                alert('Vui lòng chọn ngày xuất!');
                return;
            }

            // Validate ngày xuất: không được là ngày tương lai (UI validation)
            var today = new Date();
            today.setHours(23,59,59,999);
            var chosen = new Date(outDate);
            chosen.setHours(23,59,59,999);
            if (chosen > today) {
                alert('Ngày xuất không được lớn hơn ngày hôm nay.');
                return;
            }

            // Validate ghi chú tối đa 150 từ (UI validation)
            if (notes) {
                var wordCount = notes.trim().split(/\s+/).filter(function(w){ return w.length > 0; }).length;
                if (wordCount > 150) {
                    alert('Ghi chú không được vượt quá 150 từ (hiện tại: ' + wordCount + ').');
                    return;
                }
            }

            // Lấy tất cả sản phẩm từ bảng - chỉ validate cơ bản ở frontend
            var products = [];
            var hasError = false;
            var errorMsg = '';

            $('#stockOutProductsBody tr').each(function(index) {
                var row = $(this);
                var productId = row.find('.stockOutProductSelect').val();
                var quantity = row.find('.stockOutQuantity').val();
                var productName = row.find('.stockOutProductName').val();

                // Validate cơ bản ở frontend (UI/UX)
                if (!productId) {
                    hasError = true;
                    errorMsg = 'Dòng ' + (index + 1) + ': Vui lòng chọn sản phẩm!';
                    return false; // break loop
                }
                if (!quantity || quantity <= 0 || !Number.isInteger(Number(quantity))) {
                    hasError = true;
                    errorMsg = 'Dòng ' + (index + 1) + ' (' + productName + '): Số lượng phải là số nguyên dương!';
                    return false;
                }

                // Thêm vào mảng - validation tồn kho sẽ được xử lý ở backend
                products.push({
                    productId: parseInt(productId),
                    quantity: parseInt(quantity),
                    warehouse: warehouse
                });
            });

            if (hasError) {
                alert(errorMsg);
                return;
            }

            if (products.length === 0) {
                alert('Vui lòng thêm ít nhất một sản phẩm!');
                return;
            }

            // Lấy contractId từ form (nếu có)
            var contractId = $('#stockOutContractId').val();
            
            // Tạo notes với lý do xuất kho
            var fullNotes = 'Lý do: ' + reason;
            if (notes && notes.trim() !== '') {
                fullNotes += '\n' + notes;
            }
            
            // Nếu có contractId, thêm thông tin hợp đồng vào notes
            if (contractId && contractId !== '') {
                fullNotes = 'Xuất kho cho hợp đồng ID: ' + contractId + '\n' + fullNotes;
            }

            // Gửi dữ liệu lên backend - backend sẽ xử lý validation tồn kho và trừ kho
            var formData = {
                action: 'stockOut',
                notes: fullNotes,
                referenceType: reason,
                products: JSON.stringify(products)
            };
            
            // Thêm contractId nếu có (để cập nhật trạng thái sau khi xuất kho)
            if (contractId && contractId !== '') {
                formData.contractId = contractId;
            }

            // Hiển thị loading
            var submitBtn = $('button[onclick="submitStockOut()"]');
            var originalText = submitBtn.html();
            submitBtn.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Đang xuất kho...');

            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'POST',
                data: formData,
                dataType: 'json',
                success: function(response) {
                    submitBtn.prop('disabled', false).html(originalText);
                    
                    if (response.success) {
                        alert('✓ Xuất kho thành công!' + (response.message ? '\n' + response.message : ''));
                        $('#stockOutModal').modal('hide');
                        // Reload danh sách hợp đồng để cập nhật trạng thái
                        loadContractsData();
                    } else {
                        alert('✗ Lỗi: ' + (response.message || 'Không thể xuất kho'));
                    }
                },
                error: function(xhr, status, error) {
                    submitBtn.prop('disabled', false).html(originalText);
                    console.error('AJAX Error:', error);
                    console.error('Response:', xhr.responseText);
                    alert('✗ Lỗi kết nối server: ' + error);
                }
            });
        }
        
        // Nhập kho nhanh
        function quickStockIn(productId) {
            // Mở modal
            $('#stockInModal').modal('show');
            setTimeout(function() {
                // Reset và thêm dòng đầu tiên
                $('#stockInProductsBody').empty();
                stockInRowCounter = 0;
                addStockInRow();
                
                // Nếu có productId, chọn sản phẩm đó ở dòng đầu tiên
                if (productId) {
                    var firstRow = $('#stockInProductsBody tr:first');
                    firstRow.find('.stockInProductSelect').val(productId).trigger('change');
                }
            }, 100);
        }
        
        // (Đã loại bỏ quickStockOut vì không dùng)
        
        // Trang lịch sử được mở tại stock_history.jsp
        
        /**
         * Lọc hợp đồng với AJAX từ backend
         */
        function filterContracts() {
            currentPage = 1; // Reset về trang đầu khi lọc
            loadContractsData(); // Load lại dữ liệu với bộ lọc hiện tại
        }
        
        /**
         * Reset bộ lọc về trạng thái ban đầu
         */
        function resetFilters() {
            $('#filterContractStatus').val('');
            $('#searchContract').val('');
            currentPage = 1;
            loadContractsData(); // Load lại dữ liệu ban đầu
        }
        
        // Reset form khi đóng modal
        $('#stockInModal').on('hidden.bs.modal', function() {
            $('#stockInForm')[0].reset();
            $('#stockInProductsBody').empty();
            stockInRowCounter = 0;
            $('#stockInTotalAmount').text('0 VNĐ');
        });
        
        // Thiết lập mặc định khi mở modal nhập kho
        $('#stockInModal').on('shown.bs.modal', function() {
            // Set ngày hiện tại
            var today = new Date();
            var yyyy = today.getFullYear();
            var mm = ('0' + (today.getMonth() + 1)).slice(-2);
            var dd = ('0' + today.getDate()).slice(-2);
            $('#stockInDate').val(yyyy + '-' + mm + '-' + dd);
            
            // Load lại danh sách nhà cung cấp
            renderStockInSupplierOptions();
            
            // Reset bảng và thêm dòng đầu tiên
            $('#stockInProductsBody').empty();
            stockInRowCounter = 0;
            addStockInRow();
        });
        
        // Reset form khi đóng modal xuất kho
        $('#stockOutModal').on('hidden.bs.modal', function() {
            // Reset flag
            isExportingFromContract = false;
            
            $('#stockOutForm')[0].reset();
            $('#stockOutContractId').val('');
            $('#stockOutCustomerName').val('');
            $('#stockOutProductsBody').empty();
            stockOutRowCounter = 0;
        });
        
        // Load danh sách hợp đồng cho dropdown
        function loadContractsForDropdown(callback) {
            var selectEl = $('#stockOutContractId');
            if (selectEl.length === 0) {
                console.error('Element #stockOutContractId not found');
                if (callback) callback();
                return;
            }
            
            console.log('Loading contracts for dropdown...');
            
            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'GET',
                data: { action: 'getContracts' },
                dataType: 'json',
                success: function(response) {
                    console.log('Contracts loaded:', response);
                    if (response && response.success) {
                        selectEl.empty();
                        selectEl.append('<option value="">-- Chọn mã hợp đồng --</option>');
                        
                        if (response.data && response.data.length > 0) {
                            response.data.forEach(function(contract) {
                                if (contract && contract.id && contract.contractNumber) {
                                    var displayText = escapeHtml(contract.contractNumber || '');
                                    if (contract.customerName) {
                                        displayText += ' - ' + escapeHtml(contract.customerName);
                                    }
                                    var option = $('<option></option>')
                                        .attr('value', contract.id)
                                        .attr('data-customer-name', escapeHtml(contract.customerName || ''))
                                        .text(displayText);
                                    selectEl.append(option);
                                    console.log('Added contract option:', contract.id, contract.contractNumber);
                                }
                            });
                            console.log('Successfully loaded ' + response.data.length + ' contracts into dropdown');
                        } else {
                            console.warn('No contracts found in response data');
                            selectEl.append('<option value="" disabled>Không có hợp đồng nào</option>');
                        }
                    } else {
                        console.warn('Response failed:', response);
                        selectEl.empty();
                        selectEl.append('<option value="">-- Lỗi tải dữ liệu --</option>');
                    }
                    // Gọi callback sau khi hoàn thành
                    if (callback) {
                        console.log('Calling callback after loading contracts');
                        callback();
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error loading contracts:', error);
                    console.error('Status:', status);
                    console.error('Response:', xhr.responseText);
                    selectEl.empty();
                    selectEl.append('<option value="">-- Lỗi: ' + error + ' --</option>');
                    // Gọi callback ngay cả khi có lỗi
                    if (callback) callback();
                }
            });
        }
        
        // Load thông tin hợp đồng khi chọn
        function loadContractInfo(contractId) {
            if (!contractId || contractId === '') {
                $('#stockOutCustomerName').val('');
                // Xóa tất cả sản phẩm trong bảng
                $('#stockOutProductsBody').empty();
                stockOutRowCounter = 0;
                return;
            }
            
            console.log('Loading contract info for ID:', contractId);
            
            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'GET',
                data: { action: 'getContractInfo', contractId: contractId },
                dataType: 'json',
                success: function(response) {
                    console.log('Contract info response:', response);
                    if (response.success && response.data) {
                        var data = response.data;
                        
                        // Đảm bảo contract number được hiển thị trong dropdown
                        var contractSelect = $('#stockOutContractId');
                        if (contractSelect.val() != contractId) {
                            contractSelect.val(contractId);
                        }
                        
                        // Đảm bảo dropdown hiển thị đúng contract number
                        var selectedOption = contractSelect.find('option:selected');
                        if (selectedOption.length === 0 || selectedOption.val() != contractId) {
                            // Nếu không tìm thấy option, thử tìm lại
                            var option = contractSelect.find('option[value="' + contractId + '"]');
                            if (option.length > 0) {
                                contractSelect.val(contractId);
                                console.log('Contract number displayed:', option.text());
                            } else {
                                console.warn('Contract option not found in dropdown for ID:', contractId);
                            }
                        } else {
                            console.log('Contract number displayed:', selectedOption.text());
                        }
                        
                        // Hiển thị tên khách hàng
                        $('#stockOutCustomerName').val(data.customerName || '');
                        
                        // Xóa tất cả sản phẩm hiện tại trong bảng
                        $('#stockOutProductsBody').empty();
                        stockOutRowCounter = 0;
                        
                        // Tự động thêm sản phẩm từ hợp đồng vào bảng
                        if (data.products && data.products.length > 0) {
                            data.products.forEach(function(product) {
                                stockOutRowCounter++;
                                var rowId = 'stockOutRow_' + stockOutRowCounter;
                                var tbody = $('#stockOutProductsBody');
                                
                                var row = '<tr id="' + rowId + '">' +
                                    '<td style="text-align: center; vertical-align: middle;">' + stockOutRowCounter + '</td>' +
                                    '<td>' +
                                        '<select class="form-control stockOutProductSelect" data-row-id="' + rowId + '" required>' +
                                        '</select>' +
                                    '</td>' +
                                    '<td style="vertical-align: middle;">' +
                                        '<input type="text" class="form-control stockOutProductName" readonly style="background-color: #f5f5f5;">' +
                                    '</td>' +
                                    '<td style="text-align: center; vertical-align: middle;">' +
                                        '<input type="text" class="form-control stockOutProductUnit" readonly style="background-color: #f5f5f5; text-align: center;">' +
                                    '</td>' +
                                    '<td style="text-align: center; vertical-align: middle;">' +
                                        '<span class="stockOutCurrentStock" style="font-weight: bold; color: #5cb85c;">--</span>' +
                                    '</td>' +
                                    '<td>' +
                                        '<input type="number" class="form-control stockOutQuantity" min="1" value="' + (product.quantity && product.quantity > 0 ? product.quantity : '') + '" required placeholder="Nhập số lượng" style="text-align: right;">' +
                                    '</td>' +
                                    '<td style="text-align: center; vertical-align: middle;">' +
                                        '<button type="button" class="btn btn-danger btn-xs" onclick="removeStockOutRow(\'' + rowId + '\')" title="Xóa dòng">' +
                                            '<i class="fa fa-trash"></i> Xóa' +
                                        '</button>' +
                                    '</td>' +
                                '</tr>';
                                
                                tbody.append(row);
                                
                                // Render options cho dropdown sản phẩm
                                var selectEl = $('#' + rowId + ' .stockOutProductSelect');
                                renderStockOutProductOptions(selectEl);
                                
                                // Chọn sản phẩm từ hợp đồng và cập nhật thông tin
                                var rowEl = $('#' + rowId);
                                setTimeout(function() {
                                    selectEl.val(product.productId);
                                    var selectedOption = selectEl.find('option:selected');
                                    if (selectedOption.length > 0) {
                                        rowEl.find('.stockOutProductName').val(selectedOption.data('name') || product.productName || '');
                                        rowEl.find('.stockOutProductUnit').val(selectedOption.data('unit') || product.unit || '');
                                    } else {
                                        // Nếu không tìm thấy trong dropdown, dùng thông tin từ hợp đồng
                                        rowEl.find('.stockOutProductName').val(product.productName || '');
                                        rowEl.find('.stockOutProductUnit').val(product.unit || '');
                                    }
                                    
                                    // Load tồn khả dụng
                                    var warehouse = $('#stockOutWarehouse').val();
                                    loadCurrentStock(product.productId, warehouse, rowEl);
                                }, 100);
                                
                                // Gán sự kiện change cho dropdown sản phẩm
                                selectEl.off('change').on('change', function() {
                                    var row = $(this).closest('tr');
                                    var selectedOption = $(this).find('option:selected');
                                    var productId = $(this).val();
                                    var warehouse = $('#stockOutWarehouse').val();
                                    
                                    if (productId) {
                                        row.find('.stockOutProductName').val(selectedOption.data('name') || '');
                                        row.find('.stockOutProductUnit').val(selectedOption.data('unit') || '');
                                        loadCurrentStock(productId, warehouse, row);
                                    } else {
                                        row.find('.stockOutProductName').val('');
                                        row.find('.stockOutProductUnit').val('');
                                        row.find('.stockOutCurrentStock').text('--').attr('title', '');
                                    }
                                });
                                
                                // Validate số lượng xuất không vượt quá tồn kho
                                $('#' + rowId + ' .stockOutQuantity').off('input').on('input', function() {
                                    var row = $(this).closest('tr');
                                    var quantity = parseInt($(this).val()) || 0;
                                    var currentStock = parseInt(row.find('.stockOutCurrentStock').text()) || 0;
                                    
                                    if (quantity > currentStock) {
                                        $(this).css('border-color', '#d9534f');
                                        alert('Số lượng xuất (' + quantity + ') không được vượt quá tồn kho khả dụng (' + currentStock + ')!');
                                        $(this).val(currentStock);
                                    } else {
                                        $(this).css('border-color', '');
                                    }
                                });
                            });
                            
                            // Cập nhật lại STT cho tất cả các dòng
                            updateStockOutRowNumbers();
                        }
                    } else {
                        alert('Không thể tải thông tin hợp đồng: ' + (response.message || ''));
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error loading contract info:', error);
                    alert('Lỗi khi tải thông tin hợp đồng: ' + error);
                }
            });
        }
        
        // Thiết lập mặc định khi mở modal xuất kho
        $('#stockOutModal').on('shown.bs.modal', function() {
            // Nếu đang load từ exportStockForContract, không reset form
            if (isExportingFromContract) {
                console.log('Skipping form reset - loading from contract export');
                return;
            }
            
            // Lấy ngày hiện tại từ server (backend sẽ set mặc định)
            // Frontend chỉ set nếu chưa có giá trị
            if (!$('#stockOutDate').val()) {
                var today = new Date();
                var yyyy = today.getFullYear();
                var mm = ('0' + (today.getMonth() + 1)).slice(-2);
                var dd = ('0' + today.getDate()).slice(-2);
                $('#stockOutDate').val(yyyy + '-' + mm + '-' + dd);
            }
            
            // Load danh sách hợp đồng
            loadContractsForDropdown();
            
            // Reset các trường hợp đồng và khách hàng
            $('#stockOutContractId').val('');
            $('#stockOutCustomerName').val('');
            
            // Reset bảng và thêm dòng đầu tiên
            $('#stockOutProductsBody').empty();
            stockOutRowCounter = 0;
            addStockOutRow();
        });
        
        // Xử lý khi chọn hợp đồng - gọi backend để load thông tin
        $('#stockOutContractId').on('change', function() {
            var contractId = $(this).val();
            if (!contractId || contractId === '') {
                $('#stockOutCustomerName').val('');
                $('#stockOutProductsBody').empty();
                stockOutRowCounter = 0;
                return;
            }
            
            var selectedOption = $(this).find('option:selected');
            var customerName = selectedOption.data('customer-name') || '';
            
            // Cập nhật tên khách hàng tạm thời từ dropdown (sẽ được cập nhật từ backend)
            if (customerName) {
                $('#stockOutCustomerName').val(customerName);
            }
            
            // Gọi backend để load thông tin đầy đủ (sản phẩm, tồn kho, ngày mặc định)
            var warehouse = $('#stockOutWarehouse').val() || 'Main Warehouse';
            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'GET',
                data: { 
                    action: 'getContractInfoForStockOut', 
                    contractId: contractId,
                    warehouse: warehouse
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success && response.data) {
                        var data = response.data;
                        
                        // Cập nhật tên khách hàng từ backend
                        $('#stockOutCustomerName').val(data.customerName || '');
                        
                        // Set ngày mặc định từ backend (nếu chưa có giá trị)
                        if (data.defaultDate && !$('#stockOutDate').val()) {
                            $('#stockOutDate').val(data.defaultDate);
                        }
                        
                        // Xóa tất cả sản phẩm hiện tại
                        $('#stockOutProductsBody').empty();
                        stockOutRowCounter = 0;
                        
                        // Thêm sản phẩm từ backend
                        if (data.products && data.products.length > 0) {
                            data.products.forEach(function(product) {
                                addProductRowFromBackend(product, warehouse);
                            });
                        }
                    } else {
                        alert('Lỗi khi tải thông tin hợp đồng: ' + (response.message || 'Unknown error'));
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error loading contract info:', error);
                    alert('Lỗi khi tải thông tin hợp đồng: ' + error);
                }
            });
        });

        // Cập nhật nút phân trang (backend-driven)
        function updatePaginationButtons(totalPages) {
            var pagination = $('#pagination');
            pagination.empty();
            var prevLi = $('<li class="paginate_button ' + (currentPage <= 1 ? 'disabled' : '') + '"><a href="#">Trước</a></li>');
            prevLi.on('click', function(e){ e.preventDefault(); if (currentPage > 1) { currentPage--; loadContractsData(); } });
            pagination.append(prevLi);
            var maxVisible = 5;
            var start = Math.max(1, currentPage - Math.floor(maxVisible/2));
            var end = Math.min(totalPages, start + maxVisible - 1);
            if (end - start + 1 < maxVisible) start = Math.max(1, end - maxVisible + 1);
            for (var p = start; p <= end; p++) {
                (function(page){
                    var li = $('<li class="paginate_button ' + (page === currentPage ? 'active' : '') + '"><a href="#">' + page + '</a></li>');
                    li.on('click', function(e){ e.preventDefault(); currentPage = page; loadContractsData(); });
                    pagination.append(li);
                })(p);
            }
            var nextLi = $('<li class="paginate_button ' + (currentPage >= totalPages ? 'disabled' : '') + '"><a href="#">Tiếp</a></li>');
            nextLi.on('click', function(e){ e.preventDefault(); if (currentPage < totalPages) { currentPage++; loadContractsData(); } });
            pagination.append(nextLi);
        }
    </script>
</body>
</html>

