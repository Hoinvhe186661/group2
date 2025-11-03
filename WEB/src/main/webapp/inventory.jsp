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
                    <li>
                        <a href="<%=request.getContextPath()%>/email-management">
                            <i class="fa fa-envelope"></i> <span>Quản lý Email</span>
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
                                            <!-- Lọc theo danh mục -->
                                            <div class="col-md-3">
                                                <div class="form-group">
                                                    <label for="filterCategory">Danh mục:</label>
                                                    <select class="form-control" id="filterCategory">
                                                        <option value="">Tất cả danh mục</option>
                                                        <option value="Máy phát điện">Máy phát điện</option>
                                                        <option value="Máy bơm nước">Máy bơm nước</option>
                                                        <option value="Máy tiện">Máy tiện</option>
                                                    </select>
                                                </div>
                                            </div>
                                            
                                            <!-- Lọc theo vị trí kho -->
                                            <div class="col-md-3">
                                                <div class="form-group">
                                                    <label for="filterWarehouse">Vị trí kho:</label>
                                                <select class="form-control" id="filterWarehouse">
                                                        <option value="">Tất cả kho</option>
                                                        <option value="Main Warehouse">Kho Chính</option>
                                                        <option value="Warehouse A">Kho A</option>
                                                        <option value="Warehouse B">Kho B</option>
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
                                            <th>Giá nhập</th>
                                            <th>Giá bán</th>
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
                                    <label>Sản phẩm <span class="text-danger">*</span></label>
                                    <select id="stockInProductId" class="form-control" required>
                                        <option value="">-- Chọn sản phẩm --</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Kho <span class="text-danger">*</span></label>
                                    <select id="stockInWarehouse" class="form-control" required>
                                        <option value="Main Warehouse">Kho Chính</option>
                                        <option value="Warehouse A">Kho A</option>
                                        <option value="Warehouse B">Kho B</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Số lượng <span class="text-danger">*</span></label>
                                    <input type="number" id="stockInQuantity" class="form-control" min="1" value="0" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Đơn giá nhập <span class="text-danger">*</span></label>
                                    <input type="number" id="stockInUnitCost" class="form-control" min="0" step="1000" value="0" required>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Nhà cung cấp</label>
                                    <input type="text" id="stockInSupplier" class="form-control" placeholder="Tên nhà cung cấp" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Ngày nhập</label>
                                    <input type="date" id="stockInDate" class="form-control" required>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Ghi chú</label>
                            <textarea id="stockInNotes" class="form-control" rows="3" placeholder="Nhập ghi chú về giao dịch này..."></textarea>
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
                                        <th width="30%">Sản phẩm</th>
                                        <th width="15%">Số lượng</th>
                                        <th width="15%">Tồn hiện tại</th>
                                        <th width="30%">Vị trí kho</th>
                                        <th width="10%" class="text-center">Xóa</th>
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
        
        // Khởi tạo window.productList
        window.productList = [];
        
        // Load dữ liệu khi trang được tải
        $(document).ready(function() {
            console.log('Page loaded, initializing...');
            loadProductsForDropdown();
            loadInventoryData();
        });
        
        /**
         * Hàm load dữ liệu tồn kho
         * Tác giả: Sơn Lê
         */
        function loadInventoryData() {
            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'GET',
                data: {
                    action: 'getInventory',
                    category: $('#filterCategory').val(),
                    warehouse: $('#filterWarehouse').val(),
                    stockStatus: $('#filterStockStatus').val(),
                    search: $('#searchInventory').val(),
                    page: currentPage,
                    pageSize: itemsPerPage
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        allProducts = response.data;
                        updateInventoryTable(response.data);
                        updatePaginationInfo(response);
                        
                        // Cập nhật dropdown danh mục
                        if (response.categories) {
                            updateCategoryFilter(response.categories);
                        }
                    } else {
                        alert('Lỗi khi tải dữ liệu: ' + response.message);
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', error);
                    // Fallback to sample data nếu có lỗi
                    loadSampleData();
                }
            });
        }
        
        /**
         * Cập nhật dropdown danh mục trong bộ lọc (chỉ 3 danh mục cố định)
         * Tác giả: Sơn Lê
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
                    '<td>' + (item.unitCost != null ? formatCurrencyVN(item.unitCost) + ' VNĐ' : '--') + '</td>' +
                    '<td>' + (item.unitPrice != null ? formatCurrencyVN(item.unitPrice) + ' VNĐ' : '--') + '</td>' +
                    '<td><span class="label ' + (statusClass === 'stock-out' ? 'label-danger' : (statusClass === 'stock-low' ? 'label-warning' : 'label-success')) + '">' + statusText + '</span></td>' +
                    '<td>' +
                        '<a class="btn btn-info btn-xs" href="' + buildHistoryUrl(item.productId || item.id) + '" title="Xem lịch sử">' +
                            '<i class="fa fa-eye"></i> Xem' +
                        '</a>' +
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

        function buildHistoryUrl(productId){
            return '<%=request.getContextPath()%>/stock_history.jsp?productId=' + encodeURIComponent(productId);
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
                        renderStockInProductOptions();
                    } else {
                        console.warn('No products found or response failed');
                        window.productList = [];
                        renderStockInProductOptions();
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error loading products:', error);
                    console.error('Response:', xhr.responseText);
                    window.productList = [];
                    renderStockInProductOptions();
                }
            });
        }

        // Render options cho select sản phẩm ở form nhập kho
        function renderStockInProductOptions() {
            var selectEl = $('#stockInProductId');
            if (selectEl.length === 0) return;
            var options = '<option value="">-- Chọn sản phẩm --</option>';
            (window.productList || []).forEach(function(p) {
                options += '<option value="' + p.id + '">' + p.productCode + ' - ' + p.productName + '</option>';
            });
            selectEl.html(options);
            // Gán sự kiện change để tự động cập nhật nhà cung cấp
            selectEl.off('change').on('change', function() {
                updateSupplierFromSelectedProduct();
            });
        }
        
        // Cập nhật trường Nhà cung cấp theo sản phẩm đã chọn
        function updateSupplierFromSelectedProduct() {
            var pid = $('#stockInProductId').val();
            var supplierInput = $('#stockInSupplier');
            if (!pid) {
                supplierInput.val('');
                return;
            }
            var p = (window.productList || []).find(function(x){ return String(x.id) === String(pid); });
            supplierInput.val(p && p.supplierName ? p.supplierName : '');
        }
        
        // Bỏ cơ chế thêm nhiều dòng sản phẩm cho nhập kho (đã thay bằng form đơn)
        
        // Thêm dòng sản phẩm cho form xuất kho
        function addProductRowStockOut() {
            // Nếu chưa có danh sách sản phẩm, load lại
            if (!window.productList || window.productList.length === 0) {
                console.log('Loading products for dropdown...');
                loadProductsForDropdown();
                // Chờ một chút để load xong
                setTimeout(function() {
                    addProductRowStockOut();
                }, 500);
                return;
            }
            
            var productOptions = '<option value="">-- Chọn sản phẩm --</option>';
            window.productList.forEach(function(p) {
                productOptions += '<option value="' + p.id + '">' + p.productCode + ' - ' + p.productName + '</option>';
            });
            
            var row = '<tr>' +
                '<td><select class="form-control product-select" required>' + productOptions + '</select></td>' +
                '<td><input type="number" class="form-control quantity-input" min="1" required placeholder="Số lượng" onkeypress="return event.charCode >= 48 && event.charCode <= 57"></td>' +
                '<td class="current-stock text-center">--</td>' +
                '<td><select class="form-control warehouse-select" required>' +
                    '<option value="Main Warehouse">Kho Chính</option>' +
                    '<option value="Warehouse A">Kho A</option>' +
                    '<option value="Warehouse B">Kho B</option>' +
                '</select></td>' +
                '<td class="text-center"><button type="button" class="btn btn-danger btn-sm" onclick="$(this).closest(\'tr\').remove()">Xóa</button></td>' +
            '</tr>';
            $('#productRowsStockOut').append(row);
        }
        
        // Submit form nhập kho (form đơn)
        function submitStockIn() {
            var productId = $('#stockInProductId').val();
            var quantity = $('#stockInQuantity').val();
            var unitCost = $('#stockInUnitCost').val();
            var warehouse = $('#stockInWarehouse').val();
            var notes = $('#stockInNotes').val();
            var supplier = $('#stockInSupplier').val();
            var receiptDate = $('#stockInDate').val();

            // Validate bắt buộc các trường
            if (!productId) {
                alert('Vui lòng chọn sản phẩm!');
                return;
            }
            if (!warehouse) {
                alert('Vui lòng chọn kho!');
                return;
            }
            if (!quantity || quantity <= 0 || !Number.isInteger(Number(quantity))) {
                alert('Số lượng phải là số nguyên dương!');
                return;
            }
            if (unitCost === '' || unitCost < 0) {
                alert('Đơn giá nhập không hợp lệ!');
                return;
            }
            if (!supplier || supplier.trim() === '') {
                alert('Nhà cung cấp không được để trống!');
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

            // Validate ghi chú tối đa 100 từ
            if (notes) {
                var wordCount = notes.trim().split(/\s+/).filter(function(w){ return w.length > 0; }).length;
                if (wordCount > 100) {
                    alert('Ghi chú không được vượt quá 100 từ (hiện tại: ' + wordCount + ').');
                    return;
                }
            }

            var products = [
                {
                    productId: parseInt(productId),
                    quantity: parseInt(quantity),
                    unitCost: parseFloat(unitCost) || 0,
                    warehouse: warehouse
                }
            ];

            var formData = {
                action: 'stockIn',
                notes: notes,
                supplierName: supplier,
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
        
        // Submit form xuất kho
        function submitStockOut() {
            var products = [];
            var hasError = false;
            
            $('#productRowsStockOut tr').each(function() {
                var row = $(this);
                var productId = row.find('.product-select').val();
                var quantity = row.find('.quantity-input').val();
                var warehouse = row.find('.warehouse-select').val();
                
                // Validation
                if (!productId) {
                    alert('Vui lòng chọn sản phẩm!');
                    hasError = true;
                    return false;
                }
                
                if (!quantity || quantity <= 0 || !Number.isInteger(Number(quantity))) {
                    alert('Số lượng phải là số nguyên dương!');
                    hasError = true;
                    return false;
                }
                
                if (productId && quantity) {
                    products.push({
                        productId: parseInt(productId),
                        quantity: parseInt(quantity),
                        warehouse: warehouse
                    });
                }
            });
            
            if (hasError) return;
            
            if (products.length === 0) {
                alert('Vui lòng thêm ít nhất một sản phẩm!');
                return;
            }
            
            // Gửi dữ liệu lên server
            var formData = {
                action: 'stockOut',
                referenceType: $('select[name="reference_type"]', '#stockOutForm').val(),
                referenceId: $('input[name="reference_id"]', '#stockOutForm').val(),
                notes: $('textarea[name="notes"]', '#stockOutForm').val(),
                products: JSON.stringify(products)
            };
            
            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'POST',
                data: formData,
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        alert('Xuất kho thành công!');
                        $('#stockOutModal').modal('hide');
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
        
        // Nhập kho nhanh
        function quickStockIn(productId) {
            // Reset form trước
            $('#stockInForm')[0].reset();
            
            // Mở modal
            $('#stockInModal').modal('show');
            setTimeout(function() {
                renderStockInProductOptions();
                if (productId) {
                    $('#stockInProductId').val(productId);
                }
                updateSupplierFromSelectedProduct();
            }, 100);
        }
        
        // Xuất kho nhanh
        function quickStockOut(productId) {
            // Reset form trước
            $('#stockOutForm')[0].reset();
            $('#productRowsStockOut').empty();
            
            // Mở modal
            $('#stockOutModal').modal('show');
            
            // Thêm dòng sản phẩm và pre-fill product ID
            setTimeout(function() {
                addProductRowStockOut();
                // Sau khi thêm row, chọn sản phẩm
                setTimeout(function() {
                    if (productId) {
                        $('#productRowsStockOut tr:first .product-select').val(productId);
                    }
                }, 100);
            }, 100);
        }
        
        // Trang lịch sử được mở tại stock_history.jsp
        
        /**
         * Lọc tồn kho với AJAX từ backend
         * Tác giả: Sơn Lê
         */
        function filterInventory() {
            currentPage = 1; // Reset về trang đầu khi lọc
            loadInventoryData(); // Load lại dữ liệu với bộ lọc hiện tại
        }
        
        /**
         * Reset bộ lọc về trạng thái ban đầu
         * Tác giả: Sơn Lê
         */
        function resetFilters() {
            $('#filterCategory').val('');
            $('#filterWarehouse').val('');
            $('#filterStockStatus').val('');
            $('#searchInventory').val('');
            currentPage = 1;
            loadInventoryData(); // Load lại dữ liệu ban đầu
        }
        
        // Reset form khi đóng modal
        $('#stockInModal').on('hidden.bs.modal', function() {
            $('#stockInForm')[0].reset();
        });
        
        $('#stockOutModal').on('hidden.bs.modal', function() {
            $('#stockOutForm')[0].reset();
            $('#productRowsStockOut').empty();
        });
        
        // Thiết lập mặc định khi mở modal nhập kho
        $('#stockInModal').on('shown.bs.modal', function() {
            // set ngày hiện tại
            var today = new Date();
            var yyyy = today.getFullYear();
            var mm = ('0' + (today.getMonth() + 1)).slice(-2);
            var dd = ('0' + today.getDate()).slice(-2);
            $('#stockInDate').val(yyyy + '-' + mm + '-' + dd);
            renderStockInProductOptions();
            updateSupplierFromSelectedProduct();
        });
        
        // Tự động thêm 1 dòng sản phẩm khi mở modal xuất kho
        $('#stockOutModal').on('shown.bs.modal', function() {
            if ($('#productRowsStockOut tr').length === 0) {
                addProductRowStockOut();
            }
        });
    </script>
</body>
</html>

