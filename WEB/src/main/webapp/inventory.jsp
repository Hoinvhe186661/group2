<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Kiểm tra quyền truy cập - chỉ admin và storekeeper được vào
    boolean canManage = "admin".equals(userRole) || "storekeeper".equals(userRole);
    if (!canManage) {
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
                <ul class="sidebar-menu">
                    <li>
                        <a href="<%=request.getContextPath()%>/admin.jsp">
                            <i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/product.jsp">
                            <i class="fa fa-shopping-cart"></i> <span>Quản lý sản phẩm</span>
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/supplier">
                            <i class="fa fa-industry"></i> <span>Nhà cung cấp</span>
                        </a>
                    </li>
                    <li class="active">
                        <a href="<%=request.getContextPath()%>/inventory.jsp">
                            <i class="fa fa-archive"></i> <span>Quản lý kho</span>
                        </a>
                    </li>
                </ul>
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
                                <h3>Quản lý tồn kho</h3>
                                <div class="panel-tools">
                                    <button class="btn btn-success btn-sm" data-toggle="modal" data-target="#stockInModal">
                                        <i class="fa fa-arrow-down"></i> Nhập kho
                                    </button>
                                    <button class="btn btn-warning btn-sm" data-toggle="modal" data-target="#stockOutModal">
                                        <i class="fa fa-arrow-up"></i> Xuất kho
                                    </button>
                                    <button class="btn btn-info btn-sm" data-toggle="modal" data-target="#stockHistoryModal">
                                        <i class="fa fa-history"></i> Lịch sử
                                    </button>
                                </div>
                            </header>
                            
                            <!-- Phần lọc -->
                            <div class="panel-body filter-panel">
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="row">
                                            <!-- Lọc theo danh mục -->
                                            <div class="col-md-3">
                                                <div class="form-group">
                                                    <label for="filterCategory">Danh mục:</label>
                                                    <select class="form-control" id="filterCategory">
                                                        <option value="">Tất cả danh mục</option>
                                                    </select>
                                                </div>
                                            </div>
                                            
                                            <!-- Lọc theo vị trí kho -->
                                            <div class="col-md-3">
                                                <div class="form-group">
                                                    <label for="filterWarehouse">Vị trí kho:</label>
                                                    <select class="form-control" id="filterWarehouse">
                                                        <option value="">Tất cả kho</option>
                                                        <option value="Main Warehouse">Kho chính</option>
                                                    </select>
                                                </div>
                                            </div>
                                            
                                            <!-- Lọc theo trạng thái tồn -->
                                            <div class="col-md-2">
                                                <div class="form-group">
                                                    <label for="filterStockStatus">Trạng thái:</label>
                                                    <select class="form-control" id="filterStockStatus">
                                                        <option value="">Tất cả</option>
                                                        <option value="normal">Bình thường</option>
                                                        <option value="low">Sắp hết</option>
                                                        <option value="out">Hết hàng</option>
                                                    </select>
                                                </div>
                                            </div>
                                            
                                            <!-- Tìm kiếm -->
                                            <div class="col-md-2">
                                                <div class="form-group">
                                                    <label for="searchInventory">Tìm kiếm:</label>
                                                    <input type="text" class="form-control" id="searchInventory" 
                                                           placeholder="Tên sản phẩm..." 
                                                           onkeypress="if(event.key==='Enter') filterInventory()">
                                                </div>
                                            </div>
                                            
                                            <!-- Nút lọc -->
                                            <div class="col-md-1">
                                                <div class="form-group">
                                                    <label style="color: transparent;">Lọc</label>
                                                    <button type="button" class="btn btn-primary btn-sm" 
                                                            style="width: 100%;" onclick="filterInventory()" 
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
                                <table class="table table-hover" id="inventoryTable">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Mã sản phẩm</th>
                                            <th>Tên sản phẩm</th>
                                            <th>Danh mục</th>
                                            <th>Vị trí kho</th>
                                            <th>Tồn hiện tại</th>
                                            <th>Tồn tối thiểu</th>
                                            <th>Tồn tối đa</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td colspan="10" class="text-center">
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
                                            trong tổng số <span id="totalRecords">0</span> sản phẩm
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

    <!-- Modal Nhập kho -->
    <div class="modal fade" id="stockInModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title"><i class="fa fa-arrow-down"></i> Phiếu Nhập Kho</h4>
                </div>
                <div class="modal-body">
                    <form id="stockInForm">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Loại nhập kho <span class="text-danger">*</span></label>
                                    <select name="reference_type" class="form-control" required>
                                        <option value="purchase_order">Nhập từ nhà cung cấp</option>
                                        <option value="return">Nhập trả lại từ khách hàng</option>
                                        <option value="adjustment">Điều chỉnh kiểm kê</option>
                                        <option value="other">Khác</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Số tham chiếu (PO, Invoice...)</label>
                                    <input type="text" name="reference_id" class="form-control" 
                                           placeholder="Ví dụ: PO-2024-001">
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>Danh sách sản phẩm nhập <span class="text-danger">*</span></label>
                            <button type="button" class="btn btn-sm btn-primary" onclick="addProductRowStockIn()">
                                <i class="fa fa-plus"></i> Thêm sản phẩm
                            </button>
                            <table class="table table-bordered" style="margin-top: 10px;">
                                <thead>
                                    <tr>
                                        <th width="35%">Sản phẩm</th>
                                        <th width="15%">Số lượng</th>
                                        <th width="20%">Đơn giá nhập</th>
                                        <th width="20%">Vị trí kho</th>
                                        <th width="10%"></th>
                                    </tr>
                                </thead>
                                <tbody id="productRowsStockIn">
                                    <!-- Rows will be added by JavaScript -->
                                </tbody>
                            </table>
                        </div>
                        
                        <div class="form-group">
                            <label>Ghi chú</label>
                            <textarea name="notes" class="form-control" rows="3" 
                                      placeholder="Ghi chú về phiếu nhập..."></textarea>
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
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title"><i class="fa fa-arrow-up"></i> Phiếu Xuất Kho</h4>
                </div>
                <div class="modal-body">
                    <form id="stockOutForm">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Lý do xuất kho <span class="text-danger">*</span></label>
                                    <select name="reference_type" class="form-control" required>
                                        <option value="sales">Bán hàng</option>
                                        <option value="installation">Lắp đặt</option>
                                        <option value="warranty">Bảo hành</option>
                                        <option value="damaged">Hư hỏng</option>
                                        <option value="other">Khác</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Số tham chiếu</label>
                                    <input type="text" name="reference_id" class="form-control" 
                                           placeholder="Số đơn hàng, hợp đồng...">
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>Danh sách sản phẩm xuất <span class="text-danger">*</span></label>
                            <button type="button" class="btn btn-sm btn-warning" onclick="addProductRowStockOut()">
                                <i class="fa fa-plus"></i> Thêm sản phẩm
                            </button>
                            <table class="table table-bordered" style="margin-top: 10px;">
                                <thead>
                                    <tr>
                                        <th width="40%">Sản phẩm</th>
                                        <th width="15%">Số lượng</th>
                                        <th width="15%">Tồn hiện tại</th>
                                        <th width="20%">Vị trí kho</th>
                                        <th width="10%"></th>
                                    </tr>
                                </thead>
                                <tbody id="productRowsStockOut">
                                    <!-- Rows will be added by JavaScript -->
                                </tbody>
                            </table>
                        </div>
                        
                        <div class="form-group">
                            <label>Ghi chú</label>
                            <textarea name="notes" class="form-control" rows="3" 
                                      placeholder="Ghi chú về phiếu xuất..."></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button class="btn btn-warning" onclick="submitStockOut()">
                        <i class="fa fa-save"></i> Xuất kho
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Lịch sử xuất nhập -->
    <div class="modal fade" id="stockHistoryModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title"><i class="fa fa-history"></i> Lịch sử xuất nhập kho</h4>
                </div>
                <div class="modal-body">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Thời gian</th>
                                    <th>Sản phẩm</th>
                                    <th>Loại</th>
                                    <th>Số lượng</th>
                                    <th>Tham chiếu</th>
                                    <th>Người thực hiện</th>
                                </tr>
                            </thead>
                            <tbody id="historyTableBody">
                                <tr>
                                    <td colspan="6" class="text-center">
                                        <i class="fa fa-spinner fa-spin"></i> Đang tải...
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-default" data-dismiss="modal">Đóng</button>
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
        
        // Load dữ liệu khi trang được tải
        $(document).ready(function() {
            loadInventoryData();
            loadProductsForDropdown();
        });
        
        // Hàm load dữ liệu tồn kho
        function loadInventoryData() {
            // TODO: Gọi API để lấy dữ liệu từ server
            // Tạm thời dùng dữ liệu mẫu
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
        
        // Cập nhật bảng tồn kho
        function updateInventoryTable(data) {
            var tbody = $('#inventoryTable tbody');
            tbody.empty();
            
            if (data.length === 0) {
                tbody.append('<tr><td colspan="10" class="text-center">Không có dữ liệu</td></tr>');
                return;
            }
            
            data.forEach(function(item) {
                var status = getStockStatus(item.currentStock, item.minStock);
                var statusClass = status.class;
                var statusText = status.text;
                
                var row = '<tr>' +
                    '<td>' + item.id + '</td>' +
                    '<td>' + item.productCode + '</td>' +
                    '<td>' + item.productName + '</td>' +
                    '<td>' + item.category + '</td>' +
                    '<td>' + item.warehouse + '</td>' +
                    '<td class="' + statusClass + '">' + item.currentStock + '</td>' +
                    '<td>' + item.minStock + '</td>' +
                    '<td>' + item.maxStock + '</td>' +
                    '<td><span class="label ' + (statusClass === 'stock-out' ? 'label-danger' : (statusClass === 'stock-low' ? 'label-warning' : 'label-success')) + '">' + statusText + '</span></td>' +
                    '<td>' +
                        '<button class="btn btn-success btn-xs" onclick="quickStockIn(' + item.id + ')" title="Nhập nhanh">' +
                            '<i class="fa fa-arrow-down"></i>' +
                        '</button> ' +
                        '<button class="btn btn-warning btn-xs" onclick="quickStockOut(' + item.id + ')" title="Xuất nhanh">' +
                            '<i class="fa fa-arrow-up"></i>' +
                        '</button> ' +
                        '<button class="btn btn-info btn-xs" onclick="viewHistory(' + item.id + ')" title="Xem lịch sử">' +
                            '<i class="fa fa-history"></i>' +
                        '</button>' +
                    '</td>' +
                '</tr>';
                tbody.append(row);
            });
            
            // Cập nhật thông tin phân trang
            updatePagination(data.length);
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
        
        // Cập nhật dashboard
        function updateDashboard(data) {
            var totalProducts = data.length;
            var totalStock = 0;
            var lowStockCount = 0;
            var outOfStockCount = 0;
            
            data.forEach(function(item) {
                totalStock += item.currentStock;
                if (item.currentStock === 0) {
                    outOfStockCount++;
                } else if (item.currentStock <= item.minStock) {
                    lowStockCount++;
                }
            });
            
            $('#totalProducts').text(totalProducts);
            $('#totalStock').text(totalStock);
            $('#lowStockCount').text(lowStockCount);
            $('#outOfStockCount').text(outOfStockCount);
        }
        
        // Cập nhật phân trang
        function updatePagination(totalItems) {
            $('#showingStart').text(totalItems > 0 ? 1 : 0);
            $('#showingEnd').text(Math.min(itemsPerPage, totalItems));
            $('#totalRecords').text(totalItems);
        }
        
        // Load sản phẩm cho dropdown
        function loadProductsForDropdown() {
            // TODO: Gọi API để lấy danh sách sản phẩm
        }
        
        // Thêm dòng sản phẩm cho form nhập kho
        function addProductRowStockIn() {
            var row = '<tr>' +
                '<td><select class="form-control product-select" required>' +
                    '<option value="">-- Chọn sản phẩm --</option>' +
                    '<option value="1">GEN-001 - Máy phát điện 10KVA</option>' +
                    '<option value="2">GEN-002 - Máy phát điện 20KVA</option>' +
                '</select></td>' +
                '<td><input type="number" class="form-control" min="1" required></td>' +
                '<td><input type="number" class="form-control" min="0" step="1000" placeholder="VNĐ"></td>' +
                '<td><select class="form-control" required>' +
                    '<option value="Main Warehouse">Kho chính</option>' +
                '</select></td>' +
                '<td><button type="button" class="btn btn-danger btn-xs" onclick="$(this).closest(\'tr\').remove()"><i class="fa fa-trash"></i></button></td>' +
            '</tr>';
            $('#productRowsStockIn').append(row);
        }
        
        // Thêm dòng sản phẩm cho form xuất kho
        function addProductRowStockOut() {
            var row = '<tr>' +
                '<td><select class="form-control product-select" required>' +
                    '<option value="">-- Chọn sản phẩm --</option>' +
                    '<option value="1">GEN-001 - Máy phát điện 10KVA</option>' +
                    '<option value="2">GEN-002 - Máy phát điện 20KVA</option>' +
                '</select></td>' +
                '<td><input type="number" class="form-control" min="1" required></td>' +
                '<td class="current-stock">--</td>' +
                '<td><select class="form-control" required>' +
                    '<option value="Main Warehouse">Kho chính</option>' +
                '</select></td>' +
                '<td><button type="button" class="btn btn-danger btn-xs" onclick="$(this).closest(\'tr\').remove()"><i class="fa fa-trash"></i></button></td>' +
            '</tr>';
            $('#productRowsStockOut').append(row);
        }
        
        // Submit form nhập kho
        function submitStockIn() {
            var products = [];
            $('#productRowsStockIn tr').each(function() {
                var row = $(this);
                var productId = row.find('.product-select').val();
                var quantity = row.find('input[type="number"]').eq(0).val();
                var unitCost = row.find('input[type="number"]').eq(1).val();
                var warehouse = row.find('select').eq(1).val();
                
                if (productId && quantity) {
                    products.push({
                        productId: productId,
                        quantity: quantity,
                        unitCost: unitCost || 0,
                        warehouse: warehouse
                    });
                }
            });
            
            if (products.length === 0) {
                alert('Vui lòng thêm ít nhất một sản phẩm!');
                return;
            }
            
            // TODO: Gửi dữ liệu lên server
            console.log('Stock In:', products);
            alert('Nhập kho thành công! (Chức năng đang phát triển)');
            $('#stockInModal').modal('hide');
            loadInventoryData();
        }
        
        // Submit form xuất kho
        function submitStockOut() {
            var products = [];
            $('#productRowsStockOut tr').each(function() {
                var row = $(this);
                var productId = row.find('.product-select').val();
                var quantity = row.find('input[type="number"]').val();
                var warehouse = row.find('select').eq(1).val();
                
                if (productId && quantity) {
                    products.push({
                        productId: productId,
                        quantity: quantity,
                        warehouse: warehouse
                    });
                }
            });
            
            if (products.length === 0) {
                alert('Vui lòng thêm ít nhất một sản phẩm!');
                return;
            }
            
            // TODO: Gửi dữ liệu lên server
            console.log('Stock Out:', products);
            alert('Xuất kho thành công! (Chức năng đang phát triển)');
            $('#stockOutModal').modal('hide');
            loadInventoryData();
        }
        
        // Nhập kho nhanh
        function quickStockIn(productId) {
            $('#stockInModal').modal('show');
            // TODO: Pre-fill product
        }
        
        // Xuất kho nhanh
        function quickStockOut(productId) {
            $('#stockOutModal').modal('show');
            // TODO: Pre-fill product
        }
        
        // Xem lịch sử
        function viewHistory(productId) {
            $('#stockHistoryModal').modal('show');
            // TODO: Load history data
        }
        
        // Lọc tồn kho
        function filterInventory() {
            var category = $('#filterCategory').val();
            var warehouse = $('#filterWarehouse').val();
            var status = $('#filterStockStatus').val();
            var search = $('#searchInventory').val().toLowerCase();
            
            var filtered = allProducts.filter(function(item) {
                var matchCategory = !category || item.category === category;
                var matchWarehouse = !warehouse || item.warehouse === warehouse;
                var matchSearch = !search || item.productName.toLowerCase().indexOf(search) >= 0 || 
                                            item.productCode.toLowerCase().indexOf(search) >= 0;
                
                var stockStatus = getStockStatus(item.currentStock, item.minStock).class;
                var matchStatus = !status || 
                    (status === 'normal' && stockStatus === 'stock-normal') ||
                    (status === 'low' && stockStatus === 'stock-low') ||
                    (status === 'out' && stockStatus === 'stock-out');
                
                return matchCategory && matchWarehouse && matchSearch && matchStatus;
            });
            
            updateInventoryTable(filtered);
            updateDashboard(filtered);
        }
        
        // Reset bộ lọc
        function resetFilters() {
            $('#filterCategory').val('');
            $('#filterWarehouse').val('');
            $('#filterStockStatus').val('');
            $('#searchInventory').val('');
            updateInventoryTable(allProducts);
            updateDashboard(allProducts);
        }
        
        // Reset form khi đóng modal
        $('#stockInModal').on('hidden.bs.modal', function() {
            $('#stockInForm')[0].reset();
            $('#productRowsStockIn').empty();
        });
        
        $('#stockOutModal').on('hidden.bs.modal', function() {
            $('#stockOutForm')[0].reset();
            $('#productRowsStockOut').empty();
        });
    </script>
</body>
</html>

