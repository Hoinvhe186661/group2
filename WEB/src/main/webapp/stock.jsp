<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% 
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
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
    <title>Tồn kho | Bảng điều khiển quản trị</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <meta name="description" content="Admin Panel for Web Application">
    <meta name="keywords" content="Admin, Bootstrap 3, Template, Theme, Responsive">
    
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
        
        /* Responsive cho filter panel */
        @media (max-width: 768px) {
            .filter-panel .col-md-3,
            .filter-panel .col-md-4,
            .filter-panel .col-md-1 {
                margin-bottom: 10px;
            }
        }
        
        @media (max-width: 992px) {
            .filter-panel .col-md-3,
            .filter-panel .col-md-4 {
                margin-bottom: 10px;
            }
        }
        
        body {
            background: #f5f6f8;
        }
        #stockTable img {
            object-fit: cover;
        }
    </style>
    
    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
</head>
<body class="skin-black">
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
		<jsp:include page="partials/sidebar.jsp"/>
        <aside class="right-side">
            <!-- Main content -->
            <section class="content">
                <div class="row">
                    <div class="col-xs-12">
                        <div class="panel">
                            <header class="panel-heading">
                                <h3 style="display: inline-block; margin: 0;"><i class="fa fa-cubes"></i> Tồn kho</h3>
                                <div class="panel-tools" style="float: right;">
                                    <a class="btn btn-default btn-sm" href="<%=request.getContextPath()%>/inventory.jsp">
                                        <i class="fa fa-arrow-left"></i> Quay lại
                                    </a>
                                </div>
                            </header>
                            <!-- Phần lọc tồn kho -->
                            <div class="panel-body filter-panel">
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="row">
                                            <!-- Lọc theo danh mục -->
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label for="filterCategory" style="font-weight: bold; margin-bottom: 5px;">Danh mục:</label>
                                                    <select class="form-control" id="filterCategory">
                                                        <option value="">Tất cả danh mục</option>
                                                        <option value="Máy phát điện">Máy phát điện</option>
                                                        <option value="Máy bơm nước">Máy bơm nước</option>
                                                        <option value="Máy tiện">Máy tiện</option>
                                                    </select>
                                                </div>
                                            </div>
                                            
                                            <!-- Lọc theo trạng thái tồn kho -->
                                            <div class="col-md-3">
                                                <div class="form-group">
                                                    <label for="filterStatus" style="font-weight: bold; margin-bottom: 5px;">Trạng thái:</label>
                                                    <select class="form-control" id="filterStatus">
                                                        <option value="">Tất cả trạng thái</option>
                                                        <option value="normal">Bình thường</option>
                                                        <option value="low">Sắp hết</option>
                                                        <option value="out">Hết hàng</option>
                                                    </select>
                                                </div>
                                            </div>
                                            
                                            <!-- Tìm kiếm tổng quát -->
                                            <div class="col-md-3">
                                                <div class="form-group">
                                                    <label for="searchKeyword" style="font-weight: bold; margin-bottom: 5px;">Tìm kiếm:</label>
                                                    <input type="text" class="form-control" id="searchKeyword" placeholder="Tìm theo tên, mã sản phẩm..." onkeypress="if(event.key==='Enter') loadStockData()">
                                                </div>
                                            </div>
                                            
                                            <!-- Nút lọc -->
                                            <div class="col-md-1">
                                                <div class="form-group">
                                                    <label style="color: transparent; margin-bottom: 5px;">Lọc</label>
                                                    <button type="button" class="btn btn-primary btn-sm" style="width: 100%;" onclick="loadStockData()" title="Áp dụng bộ lọc">
                                                        <i class="fa fa-search"></i>
                                                    </button>
                                                </div>
                                            </div>
                                            
                                            <!-- Nút reset -->
                                            <div class="col-md-1">
                                                <div class="form-group">
                                                    <label style="color: transparent; margin-bottom: 5px;">Reset</label>
                                                    <button type="button" class="btn btn-warning btn-sm" style="width: 100%;" onclick="resetFilters()" title="Xóa tất cả bộ lọc">
                                                        <i class="fa fa-refresh"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="panel-body table-responsive">
                                <table class="table table-hover" id="stockTable">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Hình ảnh</th>
                                            <th>Mã sản phẩm</th>
                                            <th>Tên sản phẩm</th>
                                            <th>Danh mục</th>
                                            <th>Đơn vị</th>
                                            <th>Tổng tồn kho</th>
                                            <th>Giá bán</th>
                                            <th>Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td colspan="9" class="text-center">
                                                <i class="fa fa-spinner fa-spin"></i> Đang tải dữ liệu...
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                                
                                <!-- Phân trang -->
                                <div class="row" style="margin-top: 20px;">
                                    <div class="col-md-8">
                                        <div class="dataTables_info" id="stockInfo" role="status" aria-live="polite">
                                            Hiển thị <span id="showingStart">0</span> đến <span id="showingEnd">0</span> 
                                            trong tổng số <span id="totalRecords">0</span> sản phẩm
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="dataTables_paginate paging_simple_numbers" style="text-align: right;">
                                            <ul class="pagination" id="stockPagination" style="margin:0;">
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
        var pageSize = 10;
        var totalItems = 0;

        $(document).ready(function() {
            loadStockData();
            
            $('#searchKeyword').on('keypress', function(e) {
                if (e.which === 13) {
                    loadStockData();
                }
            });
        });

        function loadStockData() {
            var keyword = $('#searchKeyword').val() || '';
            var category = $('#filterCategory').val() || '';
            var status = $('#filterStatus').val() || '';
            
            // Hiển thị loading - filter được xử lý hoàn toàn bằng query ở backend
            $('#stockTable tbody').html('<tr><td colspan="9" class="text-center"><i class="fa fa-spinner fa-spin"></i> Đang tải dữ liệu...</td></tr>');
            
            $.ajax({
                url: '<%=request.getContextPath()%>/inventory',
                type: 'GET',
                data: {
                    action: 'getStockList',
                    page: currentPage,
                    pageSize: pageSize,
                    keyword: keyword,
                    category: category,
                    status: status
                },
                dataType: 'json',
                beforeSend: function(xhr) {
                    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
                },
                success: function(response) {
                    if (response && response.success) {
                        displayStockData(response.data || []);
                        updatePagination(response.pagination || {});
                    } else {
                        $('#stockTable tbody').html('<tr><td colspan="9" class="text-center"><div class="alert alert-warning">Không có dữ liệu tồn kho</div></td></tr>');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error loading stock data:', error);
                    $('#stockTable tbody').html('<tr><td colspan="9" class="text-center"><div class="alert alert-danger">Lỗi khi tải dữ liệu: ' + error + '</div></td></tr>');
                }
            });
        }

        function displayStockData(data) {
            var tbody = $('#stockTable tbody');
            tbody.empty();
            
            if (!data || data.length === 0) {
                tbody.html('<tr><td colspan="9" class="text-center"><div class="alert alert-info">Không có dữ liệu tồn kho</div></td></tr>');
                return;
            }

            data.forEach(function(item) {
                var statusLabel = getStatusLabel(item.totalStock, item.minStock);
                var statusText = getStatusText(item.totalStock, item.minStock);
                
                var row = '<tr>';
                row += '<td>' + item.productId + '</td>';
                row += '<td>';
                if (item.imageUrl) {
                    var imgUrl = escapeHtml(item.imageUrl);
                    if (!imgUrl.startsWith('http') && !imgUrl.startsWith('/')) {
                        imgUrl = '<%=request.getContextPath()%>/' + imgUrl;
                    } else if (imgUrl.startsWith('/') && !imgUrl.startsWith('<%=request.getContextPath()%>')) {
                        imgUrl = '<%=request.getContextPath()%>' + imgUrl;
                    }
                    row += '<img src="' + imgUrl + '" style="width: 40px; height: 40px; object-fit: cover; border-radius: 4px;" alt="' + escapeHtml(item.productName || '') + '" />';
                } else {
                    row += '<img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHJlY3Qgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgZmlsbD0iI2RkZCIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iMTIiIGZpbGw9IiM5OTkiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGR5PSIuM2VtIj5JbWFnZTwvdGV4dD48L3N2Zz4=" style="width: 40px; height: 40px; object-fit: cover; border-radius: 4px;" alt="Default Image" />';
                }
                row += '</td>';
                row += '<td><strong>' + escapeHtml(item.productCode || 'N/A') + '</strong></td>';
                row += '<td>' + escapeHtml(item.productName || 'N/A') + '</td>';
                row += '<td>' + escapeHtml(item.category || 'N/A') + '</td>';
                row += '<td>' + escapeHtml(item.unit || 'N/A') + '</td>';
                row += '<td><strong>' + (item.totalStock || 0) + '</strong></td>';
                row += '<td>' + (item.unitPrice ? new Intl.NumberFormat('vi-VN').format(item.unitPrice) + ' VNĐ' : '-') + '</td>';
                row += '<td><span class="label ' + statusLabel + '">' + statusText + '</span></td>';
                row += '</tr>';
                
                tbody.append(row);
            });
        }

        function getStatusLabel(totalStock, minStock) {
            if (totalStock === 0) return 'label-danger';
            if (minStock && totalStock <= minStock) return 'label-warning';
            return 'label-success';
        }

        function getStatusText(totalStock, minStock) {
            if (totalStock === 0) return 'Hết hàng';
            if (minStock && totalStock <= minStock) return 'Sắp hết';
            return 'Bình thường';
        }

        function updatePagination(pagination) {
            var totalPages = pagination.totalPages || 1;
            var total = pagination.total || 0;
            var from = pagination.from || 0;
            var to = pagination.to || 0;
            
            // Update info
            $('#showingStart').text(from);
            $('#showingEnd').text(to);
            $('#totalRecords').text(total);
            
            // Update pagination buttons
            var paginationHtml = '';
            
            // Previous button
            if (currentPage > 1) {
                paginationHtml += '<li class="paginate_button previous"><a href="#" id="prevBtn" onclick="changePage(' + (currentPage - 1) + '); return false;">Trước</a></li>';
            } else {
                paginationHtml += '<li class="paginate_button previous disabled"><a href="#" id="prevBtn">Trước</a></li>';
            }

            // Page numbers (show max 5 pages)
            var startPage = Math.max(1, currentPage - 2);
            var endPage = Math.min(totalPages, currentPage + 2);
            
            if (startPage > 1) {
                paginationHtml += '<li class="paginate_button"><a href="#" class="page-link" onclick="changePage(1); return false;">1</a></li>';
                if (startPage > 2) {
                    paginationHtml += '<li class="paginate_button disabled"><a href="#">...</a></li>';
                }
            }
            
            for (var i = startPage; i <= endPage; i++) {
                if (i === currentPage) {
                    paginationHtml += '<li class="paginate_button active"><a href="#" class="page-link">' + i + '</a></li>';
                } else {
                    paginationHtml += '<li class="paginate_button"><a href="#" class="page-link" onclick="changePage(' + i + '); return false;">' + i + '</a></li>';
                }
            }
            
            if (endPage < totalPages) {
                if (endPage < totalPages - 1) {
                    paginationHtml += '<li class="paginate_button disabled"><a href="#">...</a></li>';
                }
                paginationHtml += '<li class="paginate_button"><a href="#" class="page-link" onclick="changePage(' + totalPages + '); return false;">' + totalPages + '</a></li>';
            }

            // Next button
            if (currentPage < totalPages) {
                paginationHtml += '<li class="paginate_button next"><a href="#" id="nextBtn" onclick="changePage(' + (currentPage + 1) + '); return false;">Tiếp</a></li>';
            } else {
                paginationHtml += '<li class="paginate_button next disabled"><a href="#" id="nextBtn">Tiếp</a></li>';
            }

            $('#stockPagination').html(paginationHtml);
        }

        function changePage(page) {
            currentPage = page;
            loadStockData();
        }

        function resetFilters() {
            $('#searchKeyword').val('');
            $('#filterCategory').val('');
            $('#filterStatus').val('');
            currentPage = 1;
            loadStockData();
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
            return text.toString().replace(/[&<>"']/g, function(m) { return map[m]; });
        }

    </script>
</body>
</html>

