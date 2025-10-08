<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    <title>Quản lý sản phẩm | Bảng điều khiển quản trị</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <meta name="description" content="Admin Panel for Web Application">
    <meta name="keywords" content="Admin, Bootstrap 3, Template, Theme, Responsive">
    
    <!-- bootstrap 3.0.2 -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- font Awesome -->
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Ionicons -->
    <link href="<%=request.getContextPath()%>/css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <!-- DataTables -->
    <link href="<%=request.getContextPath()%>/css/datatables/dataTables.bootstrap.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet" type="text/css" />
    <link href='http://fonts.googleapis.com/css?family=Lato' rel='stylesheet' type='text/css'>
    
    <style>
        /* CSS cho phần lọc sản phẩm */
        .filter-panel {
            background-color: #f8f9fa;
            border-bottom: 1px solid #ddd;
            padding: 15px;
            margin-bottom: 0;
        }
        
        .filter-panel .form-control {
            border-radius: 4px;
            border: 1px solid #ccc;
            transition: border-color 0.3s ease;
        }
        
        .filter-panel .form-control:focus {
            border-color: #3c8dbc;
            box-shadow: 0 0 5px rgba(60, 141, 188, 0.3);
        }
        
        .filter-panel label {
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }
        
        .filter-panel .input-group-btn .btn {
            border-radius: 0 4px 4px 0;
            border-left: 0;
        }
        
        .filter-panel .input-group .form-control {
            border-radius: 4px 0 0 4px;
        }
        
        /* Responsive cho filter panel */
        @media (max-width: 768px) {
            .filter-panel .col-md-3 {
                margin-bottom: 10px;
            }
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
    <!-- header logo: style can be found in header.less -->
    <header class="header">
        <a href="<%=request.getContextPath()%>/admin.jsp" class="logo">
            Bảng điều khiển quản trị
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
                                <a href="#">
                                <i class="fa fa-user fa-fw pull-right"></i>
                                    Hồ sơ
                                </a>
                                <a data-toggle="modal" href="#modal-user-settings">
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
                    <li class="active">
                        <a href="<%=request.getContextPath()%>/products">
                            <i class="fa fa-shopping-cart"></i> <span>Quản lý sản phẩm</span>
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/suppliers.jsp">
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
            <!-- Main content -->
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
                        <i class="fa fa-check-circle"></i> <strong>Thành công!</strong> Thêm sản phẩm thành công.
                    </div>
                <%
                    } else if ("update_success".equals(message)) {
                %>
                    <div class="alert alert-success alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-check-circle"></i> <strong>Thành công!</strong> Cập nhật sản phẩm thành công.
                    </div>
                <%
                    } else if ("delete_success".equals(message)) {
                %>
                    <div class="alert alert-success alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <i class="fa fa-check-circle"></i> <strong>Thành công!</strong> Xóa sản phẩm thành công.
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
                
                <div class="row">
                    <div class="col-xs-12">
                        <div class="panel">
                            <header class="panel-heading">
                                <h3>Quản lý sản phẩm</h3>
                                <div class="panel-tools">
                                    <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addProductModal">
                                        <i class="fa fa-plus"></i> Thêm sản phẩm mới
                                    </button>
                                </div>
                            </header>
                            
                            <!-- Phần lọc sản phẩm -->
                            <div class="panel-body filter-panel">
                                <div class="row">
                                    <div class="col-md-3">
                                        <label for="filterCategory">Lọc theo danh mục:</label>
                                        <select class="form-control" id="filterCategory" onchange="filterProducts()">
                                            <option value="">Tất cả danh mục</option>
                                            <%
                                                com.hlgenerator.dao.ProductDAO statsDAO = new com.hlgenerator.dao.ProductDAO();
                                                java.util.List<String> categories = statsDAO.getAllCategories();
                                                for (String category : categories) {
                                            %>
                                            <option value="<%= category %>"><%= category %></option>
                                            <%
                                                }
                                            %>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label for="filterStatus">Lọc theo trạng thái:</label>
                                        <select class="form-control" id="filterStatus" onchange="filterProducts()">
                                            <option value="">Tất cả trạng thái</option>
                                            <option value="active">Đang bán</option>
                                            <option value="discontinued">Ngừng bán</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label for="searchProduct">Tìm kiếm sản phẩm:</label>
                                        <div class="input-group">
                                            <input type="text" class="form-control" id="searchProduct" placeholder="Nhập tên hoặc mã sản phẩm..." oninput="filterProducts()">
                                            <span class="input-group-btn">
                                                <button type="button" class="btn btn-default" onclick="resetFilters()" title="Xóa bộ lọc">
                                                    <i class="fa fa-refresh"></i>
                                                </button>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="panel-body table-responsive">
                                <table class="table table-hover" id="productsTable">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Hình ảnh</th>
                                            <th>Tên sản phẩm</th>
                                            <th>Giá</th>
                                            <th>Số lượng</th>
                                            <th>Danh mục</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            java.util.List<com.hlgenerator.model.Product> products = (java.util.List<com.hlgenerator.model.Product>) request.getAttribute("products");
                                            if (products != null) {
                                                for (com.hlgenerator.model.Product product : products) {
                                        %>
                                        <tr>
                                            <td><%= product.getId() %></td>
                                            <td>
                                                <%
                                                    String imgUrl;
                                                    if (product.getImageUrl() != null && !product.getImageUrl().trim().isEmpty() && !product.getImageUrl().equals("null")) {
                                                        imgUrl = product.getImageUrl();
                                                        if (!imgUrl.startsWith("http") && !imgUrl.startsWith("/")) {
                                                            imgUrl = request.getContextPath() + "/" + imgUrl;
                                                        } else if (imgUrl.startsWith("/") && !imgUrl.startsWith(request.getContextPath())) {
                                                            imgUrl = request.getContextPath() + imgUrl;
                                                        }
                                                        if (imgUrl.contains("sanpham1.jpg")) {
                                                            imgUrl = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHJlY3Qgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgZmlsbD0iI2RkZCIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iMTIiIGZpbGw9IiM5OTkiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGR5PSIuM2VtIj5JbWFnZTwvdGV4dD48L3N2Zz4=";
                                                        }
                                                    } else {
                                                        imgUrl = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHJlY3Qgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgZmlsbD0iI2RkZCIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iMTIiIGZpbGw9IiM5OTkiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGR5PSIuM2VtIj5JbWFnZTwvdGV4dD48L3N2Zz4=";
                                                    }
                                                %>
                                                <img src="<%= imgUrl %>" alt="<%= product.getProductName() %>" style="width: 40px; height: 40px; object-fit: cover; border-radius: 4px;">
                                            </td>
                                            <td><%= product.getProductName() %></td>
                                            <td><%= String.format("%,.0f", product.getUnitPrice()) %> VNĐ</td>
                                            <td><%= product.getQuantity() %></td>
                                            <td><%= product.getCategory() != null ? product.getCategory() : "Chưa phân loại" %></td>
                                            <td>
                                                <%
                                                    if ("active".equals(product.getStatus())) {
                                                %>
                                                <span class="label label-success">Đang bán</span>
                                                <%
                                                    } else {
                                                %>
                                                <span class="label label-warning">Ngừng bán</span>
                                                <%
                                                    }
                                                %>
                                            </td>
                                            <td>
                                                <button class="btn btn-info btn-xs" data-product-id="<%= product.getId() %>" onclick="viewProduct(this)">
                                                    <i class="fa fa-eye"></i> Xem
                                                </button>
                                                <button class="btn btn-warning btn-xs" data-product-id="<%= product.getId() %>" onclick="editProduct(this)">
                                                    <i class="fa fa-edit"></i> Sửa
                                                </button>
                                                <button class="btn btn-danger btn-xs" data-product-id="<%= product.getId() %>" onclick="deleteProduct(this)">
                                                    <i class="fa fa-trash"></i> Xóa
                                                </button>
                                            </td>
                                        </tr>
                                        <%
                                                }
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                
            </section><!-- /.content -->
            <div class="footer-main">
                Copyright &copy Bảng điều khiển quản trị, 2025
            </div>
        </aside><!-- /.right-side -->
    </div><!-- ./wrapper -->

    <!-- Modal xem sản phẩm -->
    <div class="modal fade" id="viewProductModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Chi tiết sản phẩm</h4>
                </div>
                <div class="modal-body" id="viewProductContent">
                    <!-- Nội dung sẽ được load bằng JavaScript -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal sửa sản phẩm -->
    <div class="modal fade" id="editProductModal" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Sửa sản phẩm</h4>
                </div>
                <div class="modal-body">
                    <form id="editProductForm" action="<%=request.getContextPath()%>/product" method="post">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="id" id="edit_product_id">
                        <div class="form-group">
                            <label for="edit_product_code">Mã sản phẩm</label>
                            <input type="text" class="form-control" id="edit_product_code" name="product_code" required>
                        </div>
                        <div class="form-group">
                            <label for="edit_product_name">Tên sản phẩm</label>
                            <input type="text" class="form-control" id="edit_product_name" name="product_name" required>
                        </div>
                        <div class="form-group">
                            <label for="edit_category">Danh mục</label>
                            <input type="text" class="form-control" id="edit_category" name="category">
                        </div>
                        <div class="form-group">
                            <label for="edit_description">Mô tả</label>
                            <textarea class="form-control" id="edit_description" name="description" rows="2"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="edit_unit">Đơn vị tính</label>
                            <input type="text" class="form-control" id="edit_unit" name="unit">
                        </div>
                        <div class="form-group">
                            <label for="edit_unit_price">Giá bán</label>
                            <input type="number" class="form-control" id="edit_unit_price" name="unit_price" min="0" step="0.01">
                        </div>
                        <div class="form-group">
                            <label for="edit_supplier_id">Nhà cung cấp (ID)</label>
                            <input type="number" class="form-control" id="edit_supplier_id" name="supplier_id" min="1">
                        </div>
                        <div class="form-group">
                            <label for="edit_specifications">Thông số kỹ thuật</label>
                            <textarea class="form-control" id="edit_specifications" name="specifications" rows="2"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="edit_image_url">URL ảnh sản phẩm</label>
                            <input type="url" class="form-control" id="edit_image_url" name="image_url" placeholder="https://example.com/image.jpg" oninput="previewEditImage(this.value)">
                            <small class="form-text text-muted">Nhập URL ảnh từ internet. Để trống sẽ sử dụng ảnh mặc định.</small>
                            <div id="editImagePreview" style="margin-top:10px; display:none;">
                                <img id="editPreviewImg" src="#" alt="Xem trước ảnh" style="max-width:200px; max-height:200px; border:1px solid #eee; border-radius:6px;"/>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="edit_warranty_months">Bảo hành (tháng)</label>
                            <input type="number" class="form-control" id="edit_warranty_months" name="warranty_months" min="0">
                        </div>
                        <div class="form-group">
                            <label for="edit_status">Trạng thái</label>
                            <select class="form-control" id="edit_status" name="status">
                                <option value="active">Đang bán</option>
                                <option value="discontinued">Ngừng bán</option>
                            </select>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="updateProduct()">Cập nhật</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal thêm sản phẩm -->
    <div class="modal fade" id="addProductModal" tabindex="-1" role="dialog" aria-labelledby="addProductModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="addProductModalLabel">Thêm sản phẩm mới</h4>
                </div>
                <div class="modal-body">
                    <!-- Hiển thị thông báo lỗi nếu có -->
                    <div id="addProductError" class="alert alert-danger" style="display: none;"></div>
                    
                    <form id="addProductForm" action="<%=request.getContextPath()%>/product" method="post">
                        <input type="hidden" name="action" value="add">
                        <div class="form-group">
                            <label for="product_code">Mã sản phẩm <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="product_code" name="product_code" required>
                        </div>
                        <div class="form-group">
                            <label for="product_name">Tên sản phẩm <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="product_name" name="product_name" required>
                        </div>
                        <div class="form-group">
                            <label for="category">Danh mục <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="category" name="category" required>
                        </div>
                        <div class="form-group">
                            <label for="description">Mô tả</label>
                            <textarea class="form-control" id="description" name="description" rows="2"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="unit">Đơn vị tính <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="unit" name="unit" value="pcs" required>
                        </div>
                        <div class="form-group">
                            <label for="unit_price">Giá bán (VNĐ) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" id="unit_price" name="unit_price" min="0" step="1000" required>
                        </div>
                        <div class="form-group">
                            <label for="supplier_id">Nhà cung cấp (ID) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" id="supplier_id" name="supplier_id" min="1" required>
                            <small class="form-text text-muted">Nhập ID của nhà cung cấp từ danh sách nhà cung cấp</small>
                        </div>
                        <div class="form-group">
                            <label for="specifications">Thông số kỹ thuật</label>
                            <textarea class="form-control" id="specifications" name="specifications" rows="2"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="image_url">URL ảnh sản phẩm</label>
                            <input type="url" class="form-control" id="image_url" name="image_url" placeholder="https://example.com/image.jpg" oninput="previewAddImageUrl(this.value)">
                            <small class="form-text text-muted">Nhập URL ảnh từ internet. Để trống sẽ sử dụng ảnh mặc định.</small>
                            <div id="addImagePreview" style="margin-top:10px; display:none;">
                                <img id="addPreviewImg" src="#" alt="Xem trước ảnh" style="max-width:200px; max-height:200px; border:1px solid #eee; border-radius:6px;"/>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="warranty_months">Bảo hành (tháng)</label>
                            <input type="number" class="form-control" id="warranty_months" name="warranty_months" min="0" value="12">
                        </div>
                        <div class="form-group">
                            <label for="status">Trạng thái</label>
                            <select class="form-control" id="status" name="status">
                                <option value="active" selected>Đang bán</option>
                                <option value="discontinued">Ngừng bán</option>
                            </select>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="submitAddProduct()">Lưu sản phẩm</button>
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
    <!-- DataTables -->
    <script src="<%=request.getContextPath()%>/js/plugins/datatables/jquery.dataTables.js" type="text/javascript"></script>
    <script src="<%=request.getContextPath()%>/js/plugins/datatables/dataTables.bootstrap.js" type="text/javascript"></script>
    <!-- Director App -->
    <script src="<%=request.getContextPath()%>/js/Director/app.js" type="text/javascript"></script>

    <script type="text/javascript">
        var productsTable;

        $(document).ready(function() {
            // Initialize DataTable
            productsTable = $('#productsTable').DataTable({
                "language": {
                    "url": "//cdn.datatables.net/plug-ins/1.10.25/i18n/Vietnamese.json"
                },
                "processing": true,
                "serverSide": false,
                "responsive": true,
                "pageLength": 10,
                "lengthMenu": [[10, 25, 50, 100], [10, 25, 50, 100]],
                "order": [[0, "desc"]],
                "columnDefs": [
                    { "orderable": false, "targets": [1, 7] } // Disable sorting for image and action columns
                ]
            });
        });

        // Function lọc sản phẩm
        function filterProducts() {
            var categoryFilter = document.getElementById('filterCategory').value.toLowerCase();
            var statusFilter = document.getElementById('filterStatus').value.toLowerCase();
            var searchFilter = document.getElementById('searchProduct').value.toLowerCase();
            
            // Tạo search string cho DataTables
            var searchString = '';
            
            if (searchFilter) {
                searchString += searchFilter + ' ';
            }
            if (categoryFilter) {
                searchString += categoryFilter + ' ';
            }
            if (statusFilter) {
                searchString += statusFilter + ' ';
            }
            if (stockFilter) {
                searchString += stockFilter + ' ';
            }
            
            // Áp dụng search cho DataTables
            productsTable.search(searchString.trim()).draw();
            
            // Áp dụng custom filter cho các cột cụ thể
            $.fn.dataTable.ext.search.push(function(settings, data, dataIndex) {
                var category = data[5] ? data[5].toLowerCase() : '';
                var status = data[6] ? data[6].toLowerCase() : '';
                var quantity = parseInt(data[4]) || 0;
                
                // Lọc theo danh mục
                if (categoryFilter && !category.includes(categoryFilter)) {
                    return false;
                }
                
                // Lọc theo trạng thái
                if (statusFilter) {
                    if (statusFilter === 'active' && !status.includes('đang bán')) {
                        return false;
                    }
                    if (statusFilter === 'discontinued' && !status.includes('ngừng bán')) {
                        return false;
                    }
                }
                
                
                return true;
            });
            
            // Redraw table với filters
            productsTable.draw();
            
            // Xóa custom search function sau khi áp dụng
            $.fn.dataTable.ext.search.pop();
        }
        
        // Reset filter
        function resetFilters() {
            document.getElementById('filterCategory').value = '';
            document.getElementById('filterStatus').value = '';
            document.getElementById('searchProduct').value = '';
            
            // Clear DataTables search
            productsTable.search('').draw();
        }

        function previewEditImage(url) {
            var wrap = document.getElementById('editImagePreview');
            var img = document.getElementById('editPreviewImg');
            
            if (!url || url.trim().length === 0) {
                wrap.style.display = 'none';
                return;
            }
            
            // Kiểm tra format URL cơ bản
            try {
                new URL(url);
            } catch (e) {
                wrap.style.display = 'none';
                return;
            }
            
            // Kiểm tra extension ảnh
            var lowerUrl = url.toLowerCase();
            var isImageUrl = lowerUrl.includes('.jpg') || lowerUrl.includes('.jpeg') || 
                           lowerUrl.includes('.png') || lowerUrl.includes('.gif') || 
                           lowerUrl.includes('.webp') || lowerUrl.includes('image') ||
                           lowerUrl.includes('photo') || lowerUrl.includes('picture');
            
            if (!isImageUrl) {
                wrap.style.display = 'none';
                return;
            }
            
            // Hiển thị preview
            img.src = url;
            img.onload = function() {
                wrap.style.display = 'block';
            };
            img.onerror = function() {
                wrap.style.display = 'none';
            };
        }

        
        function previewAddImageUrl(url) {
            var wrap = document.getElementById('addImagePreview');
            var img = document.getElementById('addPreviewImg');
            
            if (!url || url.trim().length === 0) {
                wrap.style.display = 'none';
                return;
            }
            
            // Kiểm tra format URL cơ bản
            try {
                new URL(url);
            } catch (e) {
                wrap.style.display = 'none';
                return;
            }
            
            // Kiểm tra extension ảnh
            var lowerUrl = url.toLowerCase();
            var isImageUrl = lowerUrl.includes('.jpg') || lowerUrl.includes('.jpeg') || 
                           lowerUrl.includes('.png') || lowerUrl.includes('.gif') || 
                           lowerUrl.includes('.webp') || lowerUrl.includes('image') ||
                           lowerUrl.includes('photo') || lowerUrl.includes('picture');
            
            if (!isImageUrl) {
                wrap.style.display = 'none';
                return;
            }
            
            // Hiển thị preview
            img.src = url;
            img.onload = function() {
                wrap.style.display = 'block';
            };
            img.onerror = function() {
                wrap.style.display = 'none';
            };
        }
        
        // Xử lý thông báo lỗi từ URL parameters
        $(document).ready(function() {
            var urlParams = new URLSearchParams(window.location.search);
            var errorDiv = $('#addProductError');
            
            if (urlParams.has('validation_error')) {
                errorDiv.text('Lỗi validation: ' + decodeURIComponent(urlParams.get('validation_error')));
                errorDiv.show();
                $('#addProductModal').modal('show');
            } else if (urlParams.has('database_error')) {
                errorDiv.text('Lỗi database: ' + decodeURIComponent(urlParams.get('database_error')));
                errorDiv.show();
                $('#addProductModal').modal('show');
            } else if (urlParams.has('system_error')) {
                errorDiv.text('Lỗi hệ thống: ' + decodeURIComponent(urlParams.get('system_error')));
                errorDiv.show();
                $('#addProductModal').modal('show');
            } else if (urlParams.has('message') && urlParams.get('message') === 'success') {
                alert('Thêm sản phẩm thành công!');
                // Xóa parameter khỏi URL
                window.history.replaceState({}, document.title, window.location.pathname);
            }
            
            // Ẩn thông báo lỗi khi đóng modal
            $('#addProductModal').on('hidden.bs.modal', function () {
                errorDiv.hide();
                // Reset form
                document.getElementById('addProductForm').reset();
                document.getElementById('addImagePreview').style.display = 'none';
                // Xóa error parameters khỏi URL
                if (urlParams.has('validation_error') || urlParams.has('database_error') || urlParams.has('system_error')) {
                    window.history.replaceState({}, document.title, window.location.pathname);
                }
            });
        });
        
        function viewProduct(element) {
            var id = $(element).data('product-id');
            if (!id || id <= 0) {
                alert('ID sản phẩm không hợp lệ');
                return;
            }
            $.ajax({
                url: '<%=request.getContextPath()%>/product?action=view&id=' + id,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        var product = response.product;
                        var content = '<div class="row">' +
                            '<div class="col-md-6">' +
                                '<h5>Thông tin cơ bản</h5>' +
                                '<p><strong>Mã sản phẩm:</strong> ' + (product.productCode || '') + '</p>' +
                                '<p><strong>Tên sản phẩm:</strong> ' + (product.productName || '') + '</p>' +
                                '<p><strong>Danh mục:</strong> ' + (product.category || 'Chưa phân loại') + '</p>' +
                                '<p><strong>Mô tả:</strong> ' + (product.description || 'Không có') + '</p>' +
                                '<p><strong>Đơn vị:</strong> ' + (product.unit || 'pcs') + '</p>' +
                                '<p><strong>Giá bán:</strong> ' + new Intl.NumberFormat('vi-VN').format(product.unitPrice || 0) + ' VNĐ</p>' +
                            '</div>' +
                            '<div class="col-md-6">' +
                                '<h5>Thông tin bổ sung</h5>' +
                                '<p><strong>Nhà cung cấp ID:</strong> ' + (product.supplierId || '') + '</p>' +
                                '<p><strong>Thông số kỹ thuật:</strong> ' + (product.specifications || 'Không có') + '</p>' +
                                '<p><strong>Bảo hành:</strong> ' + (product.warrantyMonths || 0) + ' tháng</p>' +
                                '<p><strong>Trạng thái:</strong> <span class="label ' + (product.status === 'active' ? 'label-success' : 'label-warning') + '">' + 
                                    (product.status === 'active' ? 'Đang bán' : 'Ngừng bán') + '</span></p>' +
                                (product.imageUrl && product.imageUrl.trim() !== '' ? '<p><strong>Ảnh:</strong><br><img src="' + product.imageUrl + '" style="max-width:200px;max-height:200px; border:1px solid #ddd; border-radius:4px;"></p>' : '') +
                            '</div>' +
                        '</div>';
                        $('#viewProductContent').html(content);
                        $('#viewProductModal').modal('show');
                    } else {
                        alert('Không thể tải thông tin sản phẩm: ' + (response.message || 'Lỗi không xác định'));
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', error);
                    alert('Lỗi kết nối đến server: ' + error);
                }
            });
        }

        function editProduct(element) {
            var id = $(element).data('product-id');
            if (!id || id <= 0) {
                alert('ID sản phẩm không hợp lệ');
                return;
            }
            $.ajax({
                url: '<%=request.getContextPath()%>/product?action=view&id=' + id,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        var product = response.product;
                        $('#edit_product_id').val(product.id || '');
                        $('#edit_product_code').val(product.productCode || '');
                        $('#edit_product_name').val(product.productName || '');
                        $('#edit_category').val(product.category || '');
                        $('#edit_description').val(product.description || '');
                        $('#edit_unit').val(product.unit || '');
                        $('#edit_unit_price').val(product.unitPrice || '');
                        $('#edit_supplier_id').val(product.supplierId || '');
                        $('#edit_specifications').val(product.specifications || '');
                        $('#edit_image_url').val(product.imageUrl || '');
                        $('#edit_warranty_months').val(product.warrantyMonths || '');
                        $('#edit_status').val(product.status || 'active');
                        
                        // Preview ảnh hiện tại nếu có
                        if (product.imageUrl && product.imageUrl.trim() !== '') {
                            previewEditImage(product.imageUrl);
                        }
                        
                        $('#editProductModal').modal('show');
                    } else {
                        alert('Không thể tải thông tin sản phẩm: ' + (response.message || 'Lỗi không xác định'));
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', error);
                    alert('Lỗi kết nối đến server: ' + error);
                }
            });
        }

        function updateProduct() {
            var form = document.getElementById('editProductForm');
            var formData = $(form).serialize();
            
            $.ajax({
                url: '<%=request.getContextPath()%>/product',
                type: 'POST',
                data: formData,
                success: function(response) {
                    console.log('Update response:', response);
                    if (typeof response === 'string') {
                        try {
                            response = JSON.parse(response);
                        } catch (e) {
                            console.error('Failed to parse response:', response);
                            alert('Lỗi: Phản hồi từ server không hợp lệ');
                            return;
                        }
                    }
                    
                    if (response.success) {
                        // Đóng modal
                        $('#editProductModal').modal('hide');
                        // Reload trang để cập nhật danh sách
                        window.location.reload();
                    } else {
                        alert('Lỗi cập nhật: ' + (response.message || 'Không xác định'));
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', xhr.responseText);
                    console.error('Status:', status);
                    console.error('Error:', error);
                    
                    var errorMsg = 'Lỗi khi cập nhật sản phẩm: ';
                    if (xhr.responseText) {
                        try {
                            var errorResponse = JSON.parse(xhr.responseText);
                            errorMsg += errorResponse.message || xhr.responseText;
                        } catch (e) {
                            errorMsg += xhr.responseText;
                        }
                    } else {
                        errorMsg += error;
                    }
                    alert(errorMsg);
                }
            });
        }

        function submitAddProduct() {
            var formData = {
                action: 'add',
                product_code: $('#product_code').val(),
                product_name: $('#product_name').val(),
                category: $('#category').val(),
                unit: $('#unit').val(),
                description: $('#description').val(),
                unit_price: $('#unit_price').val(),
                supplier_id: $('#supplier_id').val(),
                specifications: $('#specifications').val(),
                image_url: $('#image_url').val(),
                warranty_months: $('#warranty_months').val(),
                status: $('#status').val()
            };
            
            $.ajax({
                url: '<%=request.getContextPath()%>/product',
                type: 'POST',
                data: formData,
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        alert('Thêm sản phẩm thành công!');
                        $('#addProductModal').modal('hide');
                        location.reload(); // Reload trang để hiển thị sản phẩm mới
                    } else {
                        alert('Lỗi: ' + response.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert('Lỗi kết nối: ' + error);
                }
            });
        }

        function deleteProduct(element) {
            var id = $(element).data('product-id');
            if (!id || id <= 0) {
                alert('ID sản phẩm không hợp lệ');
                return;
            }
            if (confirm('Bạn có chắc chắn muốn xóa sản phẩm này?')) {
                $.ajax({
                    url: '<%=request.getContextPath()%>/product',
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
                        alert('Lỗi khi xóa sản phẩm: ' + error);
                    }
                });
            }
        }
        
    </script>
</body>
</html>
