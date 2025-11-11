<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hlgenerator.util.AuthorizationUtil, com.hlgenerator.util.Permission" %>
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
    
    // Kiểm tra quyền truy cập - sử dụng permission
    // Cần có quyền quản lý hoặc xem sản phẩm
    boolean canManage = AuthorizationUtil.hasPermission(request, Permission.MANAGE_PRODUCTS);
    boolean canView = AuthorizationUtil.hasPermission(request, Permission.VIEW_PRODUCTS);
    if (!canManage && !canView) {
        response.sendRedirect(request.getContextPath() + "/403.jsp");
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
        <!-- Theme style -->
        <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet" type="text/css" />
        <link href='http://fonts.googleapis.com/css?family=Lato' rel='stylesheet' type='text/css'>
    
    <style>
        /* CSS cho phần lọc sản phẩm - giống với trang nhà cung cấp */
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
                <%@ include file="includes/sidebar-menu.jsp" %>
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
                                    <div class="col-md-12">
                                        <div class="row">
                                            <!-- Lọc theo danh mục -->
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label for="filterCategory" style="font-weight: bold; margin-bottom: 5px;">Danh mục:</label>
                                                    <select class="form-control" id="filterCategory">
                                                        <option value="">Tất cả danh mục</option>
                                                        <c:forEach var="category" items="${categories}">
                                                            <option value="${category}">${category}</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                            </div>
                                            
                                            <!-- Lọc theo trạng thái -->
                                            <div class="col-md-3">
                                                <div class="form-group">
                                                    <label for="filterStatus" style="font-weight: bold; margin-bottom: 5px;">Trạng thái:</label>
                                                    <select class="form-control" id="filterStatus">
                                                        <option value="">Tất cả trạng thái</option>
                                                        <option value="active">Đang bán</option>
                                                        <option value="discontinued">Tạm ẩn</option>
                                                    </select>
                                                </div>
                                            </div>
                                            
                                            <!-- Tìm kiếm tổng quát -->
                                            <div class="col-md-3">
                                                <div class="form-group">
                                                    <label for="searchProduct" style="font-weight: bold; margin-bottom: 5px;">Tìm kiếm:</label>
                                                    <input type="text" class="form-control" id="searchProduct" placeholder="Tìm theo tên, giá, nhà cung cấp, danh mục..." onkeypress="if(event.key==='Enter') filterProducts()">
                                                </div>
                                            </div>
                                            
                                            <!-- Nút lọc -->
                                            <div class="col-md-1">
                                                <div class="form-group">
                                                    <label style="color: transparent; margin-bottom: 5px;">Lọc</label>
                                                    <button type="button" class="btn btn-primary btn-sm" style="width: 100%;" onclick="filterProducts()" title="Áp dụng bộ lọc">
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
                                <table class="table table-hover" id="productsTable">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Hình ảnh</th>
                                            <th>Tên sản phẩm</th>
                                            <th>Giá</th>
                                            <th>Nhà cung cấp</th>
                                            <th>Danh mục</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty products}">
                                                <c:forEach var="product" items="${products}">
                                        <tr>
                                            <td>${product.id}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty product.imageUrl and product.imageUrl != 'null'}">
                                                        <c:set var="imgUrl" value="${product.imageUrl}" />
                                                        <c:if test="${not fn:startsWith(imgUrl, 'http') and not fn:startsWith(imgUrl, '/')}">
                                                            <c:set var="imgUrl" value="${pageContext.request.contextPath}/${imgUrl}" />
                                                        </c:if>
                                                        <c:if test="${fn:startsWith(imgUrl, '/') and not fn:startsWith(imgUrl, pageContext.request.contextPath)}">
                                                            <c:set var="imgUrl" value="${pageContext.request.contextPath}${imgUrl}" />
                                                        </c:if>
                                                        <c:if test="${fn:contains(imgUrl, 'sanpham1.jpg')}">
                                                            <c:set var="imgUrl" value="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHJlY3Qgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgZmlsbD0iI2RkZCIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iMTIiIGZpbGw9IiM5OTkiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGR5PSIuM2VtIj5JbWFnZTwvdGV4dD48L3N2Zz4=" />
                                                        </c:if>
                                                        <img src="${imgUrl}" alt="${product.productName}" style="width: 40px; height: 40px; object-fit: cover; border-radius: 4px;">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHJlY3Qgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgZmlsbD0iI2RkZCIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iMTIiIGZpbGw9IiM5OTkiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGR5PSIuM2VtIj5JbWFnZTwvdGV4dD48L3N2Zz4=" alt="${product.productName}" style="width: 40px; height: 40px; object-fit: cover; border-radius: 4px;">
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${product.productName}</td>
                                            <td><fmt:formatNumber value="${product.unitPrice}" type="number" maxFractionDigits="0"/> VNĐ</td>
                                            <td data-supplier-id="${product.supplierId}">
                                                ${not empty product.supplierName ? product.supplierName : 'Chưa có thông tin'}
                                            </td>
                                            <td>${not empty product.category ? product.category : 'Chưa phân loại'}</td>
                                            <td>
                                                <span class="label ${product.status == 'active' ? 'label-success' : (product.status == 'discontinued' ? 'label-warning' : 'label-default')}">
                                                    ${product.status == 'active' ? 'Đang bán' : (product.status == 'discontinued' ? 'Tạm ẩn' : 'Ngừng bán')}
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${product.status == 'active'}">
                                                        <button class="btn btn-info btn-xs" data-product-id="${product.id}" onclick="viewProduct(this)">
                                                            <i class="fa fa-eye"></i> Xem
                                                        </button>
                                                        <button class="btn btn-warning btn-xs" data-product-id="${product.id}" onclick="editProduct(this)">
                                                            <i class="fa fa-edit"></i> Sửa
                                                        </button>
                                                        <button class="btn btn-default btn-xs" data-product-id="${product.id}" onclick="hideProduct(this)">
                                                            <i class="fa fa-eye-slash"></i> Ẩn
                                                        </button>
                                                        <button class="btn btn-danger btn-xs" data-product-id="${product.id}" onclick="deleteProduct(this)">
                                                            <i class="fa fa-trash"></i> Xóa
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="btn btn-success btn-xs" data-product-id="${product.id}" onclick="showProduct(this)">
                                                            <i class="fa fa-eye"></i> Hiện
                                                        </button>
                                                        <button class="btn btn-danger btn-xs" data-product-id="${product.id}" onclick="deleteProduct(this)">
                                                            <i class="fa fa-trash"></i> Xóa
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="8" class="text-center">Không có sản phẩm nào</td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                                
                                <!-- Phân trang -->
                                <div class="row" style="margin-top: 20px;">
                                    <div class="col-md-8">
                                        <div class="dataTables_info" id="paginationInfo" role="status" aria-live="polite">
                                            Hiển thị <span id="showingStart">1</span> đến <span id="showingEnd">10</span> trong tổng số <span id="totalRecords">0</span> sản phẩm
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="dataTables_paginate paging_simple_numbers" id="productsTable_paginate" style="text-align: right;">
                                            <ul class="pagination" id="pagination">
                                                <!-- Nút Previous -->
                                                <li class="paginate_button previous disabled" id="productsTable_previous">
                                                    <a href="#" aria-controls="productsTable" data-dt-idx="0" tabindex="0" id="prevBtn">Trước</a>
                                                </li>
                                                
                                                <!-- Các nút số trang sẽ được tạo bằng JavaScript -->
                                                <li class="paginate_button active">
                                                    <a href="#" aria-controls="productsTable" data-dt-idx="1" tabindex="0" class="page-link" data-page="1">1</a>
                                                </li>
                                                
                                                <!-- Nút Next -->
                                                <li class="paginate_button next" id="productsTable_next">
                                                    <a href="#" aria-controls="productsTable" data-dt-idx="2" tabindex="0" id="nextBtn">Tiếp</a>
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
                    <form id="editProductForm" action="<%=request.getContextPath()%>/product" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="id" id="edit_product_id">
                        <div class="form-group">
                            <label for="edit_product_code">Mã sản phẩm</label>
                            <input type="text" class="form-control" id="edit_product_code" name="product_code" required readonly style="background-color: #f5f5f5;">
                            <small class="form-text text-muted">Mã sản phẩm không thể thay đổi</small>
                        </div>
                        <div class="form-group">
                            <label for="edit_product_name">Tên sản phẩm</label>
                            <input type="text" class="form-control" id="edit_product_name" name="product_name" required>
                        </div>
                        <div class="form-group">
                            <label for="edit_category">Danh mục</label>
                            <input type="text" class="form-control" id="edit_category" name="category" readonly style="background-color: #f5f5f5;">
                            <small class="form-text text-muted">Danh mục không thể thay đổi</small>
                        </div>
                        <div class="form-group">
                            <label for="edit_description">Mô tả</label>
                            <textarea class="form-control" id="edit_description" name="description" rows="2" onkeyup="validateWordCount('edit_description', 'edit_description_count')"></textarea>
                            <small class="form-text text-muted">
                                <span id="edit_description_count">0</span> / 150 từ
                            </small>
                        </div>
                        <div class="form-group">
                            <label for="edit_unit">Đơn vị tính</label>
                            <select class="form-control" id="edit_unit" name="unit" required>
                                <option value="">-- Chọn đơn vị tính --</option>
                                <option value="cái">Cái</option>
                                <option value="bộ">Bộ</option>
                                <option value="công hàng">Công hàng</option>
                            </select>
                        </div>
                        <div class="form-group">
                    <label for="edit_unit_price">Giá bán (VNĐ)</label>
                            <input type="number" class="form-control" id="edit_unit_price" name="unit_price" step="1000" placeholder="Giá được cập nhật từ nhập kho" readonly disabled>
                            <small class="form-text text-muted">Giá bán không thể thay đổi.</small>
                        </div>
                        <div class="form-group">
                            <label for="edit_supplier_id">Nhà cung cấp</label>
                            <select class="form-control" id="edit_supplier_id" name="supplier_id">
                                <option value="">-- Chọn nhà cung cấp --</option>
                                <c:choose>
                                    <c:when test="${not empty suppliers}">
                                        <c:forEach var="supplier" items="${suppliers}">
                                            <c:if test="${supplier.status == 'active'}">
                                                <option value="${supplier.id}">${supplier.companyName} (${supplier.supplierCode})</option>
                                            </c:if>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="" disabled>Không có nhà cung cấp nào</option>
                                    </c:otherwise>
                                </c:choose>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="edit_specifications">Thông số kỹ thuật</label>
                            <textarea class="form-control" id="edit_specifications" name="specifications" rows="2" onkeyup="validateWordCount('edit_specifications', 'edit_specifications_count')"></textarea>
                            <small class="form-text text-muted">
                                <span id="edit_specifications_count">0</span> / 150 từ
                            </small>
                        </div>
                        <div class="form-group">
                            <label for="edit_product_image">Ảnh sản phẩm</label>
                            <input type="file" class="form-control" id="edit_product_image" name="product_image" accept="image/*" onchange="previewEditImageFile(this)">
                            <small class="form-text text-muted">Chọn file ảnh từ máy tính để thay thế ảnh hiện tại. Hỗ trợ định dạng: JPG, PNG, GIF. Kích thước tối đa: 5MB.</small>
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
                    
                    <form id="addProductForm" action="<%=request.getContextPath()%>/product" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="add">
                        <div class="form-group">
                            <label for="product_code">Mã sản phẩm <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="product_code" name="product_code" required readonly style="background-color: #f5f5f5;">
                            <small class="form-text text-muted" id="product_code_feedback">Mã sản phẩm sẽ được tạo tự động</small>
                        </div>
                        <div class="form-group">
                            <label for="product_name">Tên sản phẩm <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="product_name" name="product_name" required>
                        </div>
                        <div class="form-group">
                            <label for="category">Danh mục <span class="text-danger">*</span></label>
                            <select class="form-control" id="category" name="category" required>
                                <option value="">-- Chọn danh mục --</option>
                                <option value="Máy phát điện">Máy phát điện</option>
                                <option value="Máy bơm nước">Máy bơm nước</option>
                                <option value="Máy tiện">Máy tiện</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="description">Mô tả</label>
                            <textarea class="form-control" id="description" name="description" rows="2" onkeyup="validateWordCount('description', 'description_count')"></textarea>
                            <small class="form-text text-muted">
                                <span id="description_count">0</span> / 150 từ
                            </small>
                        </div>
                        <div class="form-group">
                            <label for="unit">Đơn vị tính <span class="text-danger">*</span></label>
                            <select class="form-control" id="unit" name="unit" required>
                                <option value="">-- Chọn đơn vị tính --</option>
                                <option value="cái" selected>cái</option>
                                <option value="bộ">bộ</option>
                                <option value="công hàng">công hàng</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="unit_price">Giá bán (VNĐ)</label>
                            <input type="number" class="form-control" id="unit_price" name="unit_price" step="1000" placeholder="Để trống, hệ thống tự đặt sau nhập kho">
                            <small class="form-text text-muted">Có thể để trống. Nếu nhập, giá phải > 0.</small>
                        </div>
                        <div class="form-group">
                            <label for="supplier_id">Nhà cung cấp <span class="text-danger">*</span></label>
                            <select class="form-control" id="supplier_id" name="supplier_id" required>
                                <option value="">-- Chọn nhà cung cấp --</option>
                                <c:choose>
                                    <c:when test="${not empty suppliers}">
                                        <c:forEach var="supplier" items="${suppliers}">
                                            <c:if test="${supplier.status == 'active'}">
                                                <option value="${supplier.id}">${supplier.companyName} (${supplier.supplierCode})</option>
                                            </c:if>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="" disabled>Không có nhà cung cấp nào</option>
                                    </c:otherwise>
                                </c:choose>
                            </select>
                            <small class="form-text text-muted">Chọn nhà cung cấp từ danh sách có sẵn. Nếu không có nhà cung cấp nào, vui lòng thêm nhà cung cấp trước.</small>
                        </div>
                        <div class="form-group">
                            <label for="specifications">Thông số kỹ thuật</label>
                            <textarea class="form-control" id="specifications" name="specifications" rows="2" onkeyup="validateWordCount('specifications', 'specifications_count')"></textarea>
                            <small class="form-text text-muted">
                                <span id="specifications_count">0</span> / 150 từ
                            </small>
                        </div>
                        <div class="form-group">
                            <label for="product_image">Ảnh sản phẩm</label>
                            <input type="file" class="form-control" id="product_image" name="product_image" accept="image/*" onchange="previewAddImageFile(this)">
                            <small class="form-text text-muted">Chọn file ảnh từ máy tính. Hỗ trợ định dạng: JPG, PNG, GIF. Kích thước tối đa: 5MB.</small>
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
    <!-- Director App -->
    <script src="<%=request.getContextPath()%>/js/Director/app.js" type="text/javascript"></script>

    <script type="text/javascript">
        // Không cần kiểm tra quyền vì đã đăng nhập với quyền quản lý kho
        
        /**
         * Đếm số từ trong một chuỗi văn bản
         * Tác giả: Sơn Lê
         * @param {string} text - Chuỗi văn bản cần đếm
         * @returns {number} - Số từ trong chuỗi
         */
        function countWords(text) {
            if (!text || text.trim() === '') {
                return 0;
            }
            // Loại bỏ khoảng trắng thừa và đếm số từ
            var trimmed = text.trim().replace(/\s+/g, ' ');
            var words = trimmed.split(' ');
            // Lọc bỏ các phần tử rỗng
            return words.filter(function(word) {
                return word.length > 0;
            }).length;
        }
        
        /**
         * Tạo mã sản phẩm tự động
         */
        function generateProductCode() {
            $.ajax({
                url: '<%=request.getContextPath()%>/product',
                type: 'GET',
                data: {
                    action: 'generateCode'
                },
                dataType: 'json',
                success: function(response) {
                    if (response && response.success && response.productCode) {
                        $('#product_code').val(response.productCode);
                        $('#product_code_feedback').text('Mã sản phẩm đã được tạo tự động').removeClass('text-danger').addClass('text-success');
                        $('#product_code').removeClass('is-invalid').addClass('is-valid');
                    } else {
                        var errorMsg = (response && response.message) ? response.message : 'Không thể tạo mã sản phẩm';
                        $('#product_code_feedback').text(errorMsg).removeClass('text-success').addClass('text-danger');
                        $('#product_code').removeClass('is-valid').addClass('is-invalid');
                        console.error('Error generating product code:', response);
                    }
                },
                error: function(xhr, status, error) {
                    $('#product_code_feedback').text('Lỗi khi tạo mã sản phẩm: ' + error).removeClass('text-success').addClass('text-danger');
                    $('#product_code').removeClass('is-valid').addClass('is-invalid');
                    console.error('AJAX error:', status, error, xhr.responseText);
                }
            });
        }
        
        /**
         * Kiểm tra và hiển thị số từ trong textarea
         * Tác giả: Sơn Lê
         * @param {string} textareaId - ID của textarea cần kiểm tra
         * @param {string} countSpanId - ID của span hiển thị số từ
         */
        function validateWordCount(textareaId, countSpanId) {
            var textarea = document.getElementById(textareaId);
            var countSpan = document.getElementById(countSpanId);
            
            if (!textarea || !countSpan) {
                return;
            }
            
            var text = textarea.value;
            var wordCount = countWords(text);
            var maxWords = 150;
            
            // Cập nhật số từ
            countSpan.textContent = wordCount;
            
            // Thay đổi màu sắc nếu vượt quá giới hạn
            if (wordCount > maxWords) {
                countSpan.style.color = '#d9534f';
                countSpan.style.fontWeight = 'bold';
                textarea.style.borderColor = '#d9534f';
            } else {
                countSpan.style.color = '#5cb85c';
                countSpan.style.fontWeight = 'normal';
                textarea.style.borderColor = '';
            }
        }
        
        // Hàm preview ảnh từ file upload (sửa sản phẩm)
        function previewEditImageFile(input) {
            var wrap = document.getElementById('editImagePreview');
            var img = document.getElementById('editPreviewImg');
            
            if (input.files && input.files[0]) {
                var file = input.files[0];
                
                // Kiểm tra kích thước file (5MB)
                if (file.size > 5 * 1024 * 1024) {
                    alert('Kích thước file quá lớn. Vui lòng chọn file nhỏ hơn 5MB.');
                    input.value = '';
                    wrap.style.display = 'none';
                    return;
                }
                
                // Kiểm tra định dạng file
                var allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
                if (!allowedTypes.includes(file.type)) {
                    alert('Định dạng file không được hỗ trợ. Vui lòng chọn file JPG, PNG hoặc GIF.');
                    input.value = '';
                    wrap.style.display = 'none';
                    return;
                }
                
                var reader = new FileReader();
                reader.onload = function(e) {
                    img.src = e.target.result;
                    wrap.style.display = 'block';
                };
                reader.readAsDataURL(file);
            } else {
                wrap.style.display = 'none';
            }
        }

        
        // Hàm preview ảnh từ file upload (thêm sản phẩm)
        function previewAddImageFile(input) {
            var wrap = document.getElementById('addImagePreview');
            var img = document.getElementById('addPreviewImg');
            
            if (input.files && input.files[0]) {
                var file = input.files[0];
                
                // Kiểm tra kích thước file (5MB)
                if (file.size > 5 * 1024 * 1024) {
                    alert('Kích thước file quá lớn. Vui lòng chọn file nhỏ hơn 5MB.');
                    input.value = '';
                    wrap.style.display = 'none';
                    return;
                }
                
                // Kiểm tra định dạng file
                var allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
                if (!allowedTypes.includes(file.type)) {
                    alert('Định dạng file không được hỗ trợ. Vui lòng chọn file JPG, PNG hoặc GIF.');
                    input.value = '';
                    wrap.style.display = 'none';
                    return;
                }
                
                var reader = new FileReader();
                reader.onload = function(e) {
                    img.src = e.target.result;
                    wrap.style.display = 'block';
                };
                reader.readAsDataURL(file);
            } else {
                wrap.style.display = 'none';
            }
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
            
            // Tự động tạo mã khi mở modal thêm mới
            $('#addProductModal').on('shown.bs.modal', function () {
                generateProductCode();
            });
            
            // Ẩn thông báo lỗi khi đóng modal
            $('#addProductModal').on('hidden.bs.modal', function () {
                errorDiv.hide();
                // Reset form
                document.getElementById('addProductForm').reset();
                document.getElementById('addImagePreview').style.display = 'none';
                // Reset số từ
                validateWordCount('description', 'description_count');
                validateWordCount('specifications', 'specifications_count');
                // Reset feedback mã sản phẩm
                $('#product_code_feedback').text('Mã sản phẩm sẽ được tạo tự động').removeClass('text-danger text-success');
                $('#product_code').removeClass('is-invalid is-valid').val('');
                // Xóa error parameters khỏi URL
                if (urlParams.has('validation_error') || urlParams.has('database_error') || urlParams.has('system_error')) {
                    window.history.replaceState({}, document.title, window.location.pathname);
                }
            });
            
            // Reset số từ khi đóng modal sửa
            $('#editProductModal').on('hidden.bs.modal', function () {
                validateWordCount('edit_description', 'edit_description_count');
                validateWordCount('edit_specifications', 'edit_specifications_count');
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
                        $('#edit_warranty_months').val(product.warrantyMonths || '');
                        $('#edit_status').val(product.status || 'active');
                        
                        // Cập nhật số từ cho mô tả và thông số kỹ thuật
                        validateWordCount('edit_description', 'edit_description_count');
                        validateWordCount('edit_specifications', 'edit_specifications_count');
                        
                        // Hiển thị ảnh hiện tại nếu có
                        if (product.imageUrl && product.imageUrl.trim() !== '') {
                            var img = document.getElementById('editPreviewImg');
                            var wrap = document.getElementById('editImagePreview');
                            img.src = product.imageUrl;
                            wrap.style.display = 'block';
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
            // Kiểm tra validation trước khi gửi
            var productCode = $('#edit_product_code').val().trim();
            var productName = $('#edit_product_name').val().trim();
            var category = $('#edit_category').val().trim();
            var unit = $('#edit_unit').val().trim();
            var unitPrice = $('#edit_unit_price').val();
            var supplierId = $('#edit_supplier_id').val();
            var description = $('#edit_description').val().trim();
            var specifications = $('#edit_specifications').val().trim();
            
            if (!productCode) {
                alert('Mã sản phẩm không được để trống!');
                $('#edit_product_code').focus();
                return;
            }
            
            if (!productName) {
                alert('Tên sản phẩm không được để trống!');
                $('#edit_product_name').focus();
                return;
            }
            
            if (!category) {
                alert('Danh mục không được để trống!');
                $('#edit_category').focus();
                return;
            }
            
            if (!unit) {
                alert('Đơn vị tính không được để trống!');
                $('#edit_unit').focus();
                return;
            }
            
            // Cho phép để trống; nếu nhập phải > 0
            if (unitPrice && unitPrice <= 0) {
                alert('Giá bán phải lớn hơn 0!');
                $('#edit_unit_price').focus();
                return;
            }
            
            if (unitPrice > 500000000) {
                alert('Giá bán không được vượt quá 500,000,000 VNĐ!');
                $('#edit_unit_price').focus();
                return;
            }
            
            if (!supplierId || supplierId === '') {
                alert('Vui lòng chọn nhà cung cấp!');
                $('#edit_supplier_id').focus();
                return;
            }
            
            // Kiểm tra số từ của mô tả
            var descriptionWordCount = countWords(description);
            if (descriptionWordCount > 150) {
                alert('Mô tả không được vượt quá 150 từ! Hiện tại bạn đã nhập ' + descriptionWordCount + ' từ.');
                $('#edit_description').focus();
                return;
            }
            
            // Kiểm tra số từ của thông số kỹ thuật
            var specificationsWordCount = countWords(specifications);
            if (specificationsWordCount > 150) {
                alert('Thông số kỹ thuật không được vượt quá 150 từ! Hiện tại bạn đã nhập ' + specificationsWordCount + ' từ.');
                $('#edit_specifications').focus();
                return;
            }
            
            // Sử dụng FormData để xử lý file upload và form data
            var form = document.getElementById('editProductForm');
            var formData = new FormData(form);
            
            $.ajax({
                url: '<%=request.getContextPath()%>/product',
                type: 'POST',
                data: formData,
                processData: false, // Không xử lý dữ liệu
                contentType: false, // Không set content type
                dataType: 'json',
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
            // Kiểm tra validation trước khi gửi
            var productCode = $('#product_code').val().trim();
            var productName = $('#product_name').val().trim();
            var category = $('#category').val().trim();
            var unit = $('#unit').val().trim();
            var unitPrice = $('#unit_price').val();
            var supplierId = $('#supplier_id').val();
            var description = $('#description').val().trim();
            var specifications = $('#specifications').val().trim();
            
            if (!productCode) {
                alert('Mã sản phẩm không được để trống!');
                $('#product_code').focus();
                return;
            }
            
            if (!productName) {
                alert('Tên sản phẩm không được để trống!');
                $('#product_name').focus();
                return;
            }
            
            if (!category) {
                alert('Danh mục không được để trống!');
                $('#category').focus();
                return;
            }
            
            if (!unit) {
                alert('Đơn vị tính không được để trống!');
                $('#unit').focus();
                return;
            }
            
            // Cho phép để trống; nếu nhập phải > 0
            if (unitPrice && unitPrice <= 0) {
                alert('Giá bán phải lớn hơn 0!');
                $('#unit_price').focus();
                return;
            }
            
            if (unitPrice > 5000000000) {
                alert('Giá bán không được vượt quá 5000000000 VNĐ!');
                $('#unit_price').focus();
                return;
            }
            
            if (!supplierId || supplierId === '') {
                alert('Vui lòng chọn nhà cung cấp!');
                $('#supplier_id').focus();
                return;
            }
            
            // Mã sản phẩm sẽ được tự động tạo nếu để trống (xử lý ở backend)
            
            // Kiểm tra số từ của mô tả
            var descriptionWordCount = countWords(description);
            if (descriptionWordCount > 150) {
                alert('Mô tả không được vượt quá 150 từ! Hiện tại bạn đã nhập ' + descriptionWordCount + ' từ.');
                $('#description').focus();
                return;
            }
            
            // Kiểm tra số từ của thông số kỹ thuật
            var specificationsWordCount = countWords(specifications);
            if (specificationsWordCount > 150) {
                alert('Thông số kỹ thuật không được vượt quá 150 từ! Hiện tại bạn đã nhập ' + specificationsWordCount + ' từ.');
                $('#specifications').focus();
                return;
            }
            
            // Sử dụng FormData để xử lý file upload và form data
            var form = document.getElementById('addProductForm');
            var formData = new FormData(form);
            
            $.ajax({
                url: '<%=request.getContextPath()%>/product',
                type: 'POST',
                data: formData,
                processData: false, // Không xử lý dữ liệu
                contentType: false, // Không set content type
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
                    console.error('AJAX Error:', xhr.responseText);
                    console.error('Status:', status);
                    console.error('Error:', error);
                    
                    var errorMsg = 'Lỗi kết nối: ';
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
        
        function hideProduct(element) {
            var id = $(element).data('product-id');
            if (!id || id <= 0) {
                alert('ID sản phẩm không hợp lệ');
                return;
            }
            if (confirm('Bạn có chắc chắn muốn ẩn sản phẩm này?')) {
                $.ajax({
                    url: '<%=request.getContextPath()%>/product',
                    type: 'POST',
                    data: {
                        action: 'hide',
                        id: id
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            window.location.reload();
                        } else {
                            alert('Lỗi: ' + response.message);
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('AJAX Error:', error);
                        alert('Lỗi khi ẩn sản phẩm: ' + error);
                    }
                });
            }
        }
        
        function showProduct(element) {
            var id = $(element).data('product-id');
            if (!id || id <= 0) {
                alert('ID sản phẩm không hợp lệ');
                return;
            }
            if (confirm('Bạn có chắc chắn muốn hiện lại sản phẩm này?')) {
                $.ajax({
                    url: '<%=request.getContextPath()%>/product',
                    type: 'POST',
                    data: {
                        action: 'show',
                        id: id
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            window.location.reload();
                        } else {
                            alert('Lỗi: ' + response.message);
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('AJAX Error:', error);
                        alert('Lỗi khi hiện sản phẩm: ' + error);
                    }
                });
            }
        }
        
        // Biến phân trang cho products
        var currentPageProducts = 1;
        var itemsPerPageProducts = 10;
        var totalItemsProducts = 0;
        var filteredItemsProducts = [];
        var allItemsProducts = [];
        
        // Hàm khởi tạo phân trang cho products
        function initializePaginationProducts() {
            // Lấy tất cả dữ liệu từ bảng
            var table = document.getElementById('productsTable');
            var rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
            
            // Lưu tất cả dữ liệu
            allItemsProducts = [];
            for (var i = 0; i < rows.length; i++) {
                allItemsProducts.push(rows[i].cloneNode(true));
            }
            
            totalItemsProducts = allItemsProducts.length;
            filteredItemsProducts = allItemsProducts.slice(); // Copy tất cả items
            updatePaginationProducts();
        }
        
        // Hàm cập nhật phân trang cho products
        function updatePaginationProducts() {
            var totalPages = Math.ceil(filteredItemsProducts.length / itemsPerPageProducts);
            var startIndex = (currentPageProducts - 1) * itemsPerPageProducts;
            var endIndex = Math.min(startIndex + itemsPerPageProducts, filteredItemsProducts.length);
            
            // Cập nhật thông tin hiển thị
            document.getElementById('showingStart').textContent = filteredItemsProducts.length > 0 ? startIndex + 1 : 0;
            document.getElementById('showingEnd').textContent = endIndex;
            document.getElementById('totalRecords').textContent = filteredItemsProducts.length;
            
            updateTableProducts();
            
            // Cập nhật nút phân trang
            updatePaginationButtonsProducts(totalPages);
        }
        
        // Hàm cập nhật bảng products
        function updateTableProducts() {
            var table = document.getElementById('productsTable');
            var tbody = table.getElementsByTagName('tbody')[0];
            
            // Xóa tất cả hàng hiện tại
            tbody.innerHTML = '';
            
            // Thêm hàng cho trang hiện tại
            var startIndex = (currentPageProducts - 1) * itemsPerPageProducts;
            var endIndex = Math.min(startIndex + itemsPerPageProducts, filteredItemsProducts.length);
            
            for (var i = startIndex; i < endIndex; i++) {
                tbody.appendChild(filteredItemsProducts[i].cloneNode(true));
            }
        }
        
        // Hàm cập nhật nút phân trang cho products
        function updatePaginationButtonsProducts(totalPages) {
            var pagination = document.getElementById('pagination');
            var prevBtn = document.getElementById('prevBtn');
            var nextBtn = document.getElementById('nextBtn');
            
            // Cập nhật nút Previous
            if (currentPageProducts <= 1) {
                prevBtn.parentElement.classList.add('disabled');
            } else {
                prevBtn.parentElement.classList.remove('disabled');
            }
            
            // Cập nhật nút Next
            if (currentPageProducts >= totalPages) {
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
            var startPage = Math.max(1, currentPageProducts - Math.floor(maxVisiblePages / 2));
            var endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);
            
            if (endPage - startPage + 1 < maxVisiblePages) {
                startPage = Math.max(1, endPage - maxVisiblePages + 1);
            }
            
            // Thêm nút số trang
            for (var i = startPage; i <= endPage; i++) {
                var li = document.createElement('li');
                li.className = 'paginate_button';
                if (i === currentPageProducts) {
                    li.classList.add('active');
                }
                
                var a = document.createElement('a');
                a.href = '#';
                a.textContent = i;
                a.className = 'page-link';
                a.setAttribute('data-page', i);
                a.addEventListener('click', function(e) {
                    e.preventDefault();
                    goToPageProducts(parseInt(this.getAttribute('data-page')));
                });
                
                li.appendChild(a);
                
                // Chèn trước nút Next
                nextBtn.parentElement.parentElement.insertBefore(li, nextBtn.parentElement);
            }
        }
        
        // Hàm chuyển đến trang cho products
        function goToPageProducts(page) {
            currentPageProducts = page;
            filterProductsWithPagination();
        }
        
        // Hàm lọc sản phẩm sử dụng AJAX (backend processing)
        function filterProductsWithPagination() {
            var categoryFilter = document.getElementById('filterCategory').value;
            var statusFilter = document.getElementById('filterStatus').value;
            var searchFilter = document.getElementById('searchProduct').value;
            
            console.log('Filtering with:', {
                category: categoryFilter,
                status: statusFilter,
                search: searchFilter,
                page: currentPageProducts
            });
            
            // Hiển thị loading
            showLoading();
            
            // Gọi AJAX để lọc sản phẩm từ backend với UTF-8 encoding
            $.ajax({
                url: '<%=request.getContextPath()%>/product',
                type: 'GET',
                data: {
                    action: 'filter',
                    category: categoryFilter,
                    status: statusFilter,
                    search: searchFilter,
                    page: currentPageProducts,
                    pageSize: itemsPerPageProducts
                },
                dataType: 'json',
                beforeSend: function(xhr) {
                    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
                },
                success: function(response) {
                    console.log('AJAX Response:', response);
                    if (response.success) {
                        // Cập nhật dữ liệu sản phẩm
                        updateProductsTable(response.products);
                        
                        // Cập nhật thông tin phân trang
                        updatePaginationInfo(response);
                        
                        // Cập nhật dropdown danh mục
                        updateFilterDropdowns(response.suppliers, response.categories);
                    } else {
                        alert('Lỗi khi lọc sản phẩm: ' + (response.message || 'Lỗi không xác định'));
                    }
                    hideLoading();
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', error);
                    alert('Lỗi kết nối đến server: ' + error);
                    hideLoading();
                }
            });
        }
        
         // Hàm reset tất cả bộ lọc với phân trang cho products
         function resetFiltersWithPagination() {
             document.getElementById('filterCategory').value = '';
             document.getElementById('filterStatus').value = '';
             document.getElementById('searchProduct').value = '';
             currentPageProducts = 1;
             // Reload trang để trở về trạng thái ban đầu thay vì gọi AJAX
             window.location.reload();
         }
        
        // Hàm cập nhật bảng sản phẩm từ dữ liệu AJAX
        function updateProductsTable(products) {
            var table = document.getElementById('productsTable');
            var tbody = table.getElementsByTagName('tbody')[0];
            tbody.innerHTML = '';
            
            console.log('Updating table with products:', products);
            
            if (products && products.length > 0) {
                products.forEach(function(product) {
                    var row = createProductRow(product);
                    tbody.appendChild(row);
                });
                        } else {
                var row = document.createElement('tr');
                row.innerHTML = '<td colspan="8" class="text-center">Không tìm thấy sản phẩm nào</td>';
                tbody.appendChild(row);
            }
        }
        
        // Hàm tạo một dòng sản phẩm từ dữ liệu JSON
        function createProductRow(product) {
            console.log('Creating row for product:', product);
            var row = document.createElement('tr');
            
            // Tạo HTML cho hình ảnh
            var imageHtml = '';
            if (product.imageUrl && product.imageUrl.trim() !== '') {
                var imgUrl = product.imageUrl;
                if (!imgUrl.startsWith('http') && !imgUrl.startsWith('/')) {
                    imgUrl = '<%=request.getContextPath()%>/' + imgUrl;
                } else if (imgUrl.startsWith('/') && !imgUrl.startsWith('<%=request.getContextPath()%>')) {
                    imgUrl = '<%=request.getContextPath()%>' + imgUrl;
                }
                imageHtml = '<img src="' + imgUrl + '" style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;" alt="Product Image">';
            } else {
                imageHtml = '<img src="<%=request.getContextPath()%>/images/sanpham1.jpg" style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;" alt="Default Image">';
            }
            
            // Tạo HTML cho trạng thái
            var statusHtml = '';
            if (product.status === 'active') {
                statusHtml = '<span class="label label-success">Đang bán</span>';
            } else if (product.status === 'discontinued') {
                statusHtml = '<span class="label label-warning">Tạm ẩn</span>';
            } else {
                statusHtml = '<span class="label label-default">Ngừng bán</span>';
            }
            
            // Tạo HTML cho các nút action dựa vào status
            var actionHtml = '';
            if (product.status === 'active') {
                // Sản phẩm active: Hiển thị đầy đủ các nút
                actionHtml = '<button class="btn btn-info btn-xs" onclick="viewProduct(this)" data-product-id="' + product.id + '">' +
                            '<i class="fa fa-eye"></i> Xem</button> ' +
                            '<button class="btn btn-warning btn-xs" onclick="editProduct(this)" data-product-id="' + product.id + '">' +
                            '<i class="fa fa-edit"></i> Sửa</button> ' +
                            '<button class="btn btn-default btn-xs" onclick="hideProduct(this)" data-product-id="' + product.id + '">' +
                            '<i class="fa fa-eye-slash"></i> Ẩn</button> ' +
                            '<button class="btn btn-danger btn-xs" onclick="deleteProduct(this)" data-product-id="' + product.id + '">' +
                            '<i class="fa fa-trash"></i> Xóa</button>';
            } else {
                // Sản phẩm đã ẩn: Chỉ hiển thị nút Hiện và Xóa
                actionHtml = '<button class="btn btn-success btn-xs" onclick="showProduct(this)" data-product-id="' + product.id + '">' +
                            '<i class="fa fa-eye"></i> Hiện</button> ' +
                            '<button class="btn btn-danger btn-xs" onclick="deleteProduct(this)" data-product-id="' + product.id + '">' +
                            '<i class="fa fa-trash"></i> Xóa</button>';
            }
            
            row.innerHTML = 
                '<td>' + (product.id || '') + '</td>' +
                '<td>' + imageHtml + '</td>' +
                '<td>' + (product.productName || '') + '</td>' +
                '<td>' + new Intl.NumberFormat('vi-VN').format(product.unitPrice || 0) + ' VNĐ</td>' +
                '<td data-supplier-id="' + (product.supplierId || '') + '">' + (product.supplierName || '') + '</td>' +
                '<td>' + (product.category || 'Chưa phân loại') + '</td>' +
                '<td>' + statusHtml + '</td>' +
                '<td>' + actionHtml + '</td>';
            return row;
        }
        
        // Hàm cập nhật thông tin phân trang
        function updatePaginationInfo(response) {
            currentPageProducts = response.currentPage;
            var totalPages = response.totalPages;
            var totalProducts = response.totalProducts;
            
            // Cập nhật thông tin hiển thị
            var startItem = (currentPageProducts - 1) * itemsPerPageProducts + 1;
            var endItem = Math.min(currentPageProducts * itemsPerPageProducts, totalProducts);
            
            document.getElementById('paginationInfo').innerHTML = 
                'Hiển thị ' + startItem + ' đến ' + endItem + ' trong tổng số ' + totalProducts + ' sản phẩm';
            
            // Cập nhật nút phân trang
            updatePaginationButtons(totalPages);
        }
        
        /**
         * Cập nhật dropdown danh mục (chỉ hiển thị 3 danh mục cố định)
         * Tác giả: Sơn Lê
         * @param {Array} suppliers - Danh sách nhà cung cấp (không sử dụng)
         * @param {Array} categories - Danh sách danh mục từ server (không sử dụng, chỉ để giữ tương thích)
         */
        function updateFilterDropdowns(suppliers, categories) {
            // Chỉ hiển thị 3 danh mục cố định
            var categorySelect = document.getElementById('filterCategory');
            var currentCategoryValue = categorySelect.value;
            categorySelect.innerHTML = '<option value="">Tất cả danh mục</option>' +
                                       '<option value="Máy phát điện">Máy phát điện</option>' +
                                       '<option value="Máy bơm nước">Máy bơm nước</option>' +
                                       '<option value="Máy tiện">Máy tiện</option>';
            
            // Khôi phục giá trị đã chọn nếu hợp lệ
            if (currentCategoryValue && 
                (currentCategoryValue === "Máy phát điện" || 
                 currentCategoryValue === "Máy bơm nước" || 
                 currentCategoryValue === "Máy tiện" || 
                 currentCategoryValue === "")) {
                categorySelect.value = currentCategoryValue;
            }
        }
        
        // Hàm hiển thị loading
        function showLoading() {
            var table = document.getElementById('productsTable');
            var tbody = table.getElementsByTagName('tbody')[0];
            tbody.innerHTML = '<tr><td colspan="8" class="text-center"><i class="fa fa-spinner fa-spin"></i> Đang tải...</td></tr>';
        }
        
        // Hàm ẩn loading
        function hideLoading() {
            // Loading sẽ được thay thế bởi dữ liệu thực
        }
        
        // Hàm cập nhật nút phân trang
        function updatePaginationButtons(totalPages) {
            var pagination = document.getElementById('pagination');
            var prevBtn = document.getElementById('prevBtn');
            var nextBtn = document.getElementById('nextBtn');
            
            // Cập nhật trạng thái nút Previous
            if (currentPageProducts <= 1) {
                prevBtn.parentElement.classList.add('disabled');
            } else {
                prevBtn.parentElement.classList.remove('disabled');
            }
            
            // Cập nhật trạng thái nút Next
            if (currentPageProducts >= totalPages) {
                nextBtn.parentElement.classList.add('disabled');
            } else {
                nextBtn.parentElement.classList.remove('disabled');
            }
            
            // Xóa các nút số trang cũ (giữ lại Previous và Next)
            var pageButtons = pagination.querySelectorAll('.page-link:not(#prevBtn):not(#nextBtn)');
            pageButtons.forEach(function(btn) {
                btn.parentElement.remove();
            });
            
            // Tạo nút số trang mới
            var startPage = Math.max(1, currentPageProducts - 2);
            var endPage = Math.min(totalPages, currentPageProducts + 2);
            
            for (var i = startPage; i <= endPage; i++) {
                var li = document.createElement('li');
                li.className = 'paginate_button';
                if (i === currentPageProducts) {
                    li.classList.add('active');
                }
                
                var a = document.createElement('a');
                a.href = '#';
                a.textContent = i;
                a.className = 'page-link';
                a.setAttribute('data-page', i);
                a.onclick = function(e) {
                    e.preventDefault();
                    goToPageProducts(parseInt(this.getAttribute('data-page')));
                };
                
                li.appendChild(a);
                
                // Chèn trước nút Next
                nextBtn.parentElement.parentElement.insertBefore(li, nextBtn.parentElement);
            }
        }
        
        // Hàm helper để lấy tên nhà cung cấp theo ID
        function getSupplierNameById(supplierId) {
            var supplierSelect = document.getElementById('filterSupplier');
            for (var i = 0; i < supplierSelect.options.length; i++) {
                if (supplierSelect.options[i].value === supplierId) {
                    return supplierSelect.options[i].text.split(' (')[0]; // Lấy tên trước dấu ngoặc
                }
            }
            return null;
        }
        
        // Cập nhật các hàm lọc hiện có để sử dụng phân trang
        function filterProducts() {
            filterProductsWithPagination();
        }
        
        function resetFilters() {
            resetFiltersWithPagination();
        }
        
        // Biến đã được khai báo ở trên
        
        // Khởi tạo phân trang khi trang load
        $(document).ready(function() {
            // Cập nhật thông tin phân trang cho dữ liệu ban đầu
            var table = document.getElementById('productsTable');
            var rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
            var totalRows = rows.length;
            
            // Cập nhật thông tin hiển thị
            document.getElementById('showingStart').textContent = '1';
            document.getElementById('showingEnd').textContent = totalRows;
            document.getElementById('totalRecords').textContent = totalRows;
            
            // Gắn sự kiện cho nút Previous/Next
            $('#prevBtn').on('click', function(e) {
                e.preventDefault();
                if (currentPageProducts > 1) {
                    currentPageProducts--;
                    filterProductsWithPagination();
                }
            });
            
            $('#nextBtn').on('click', function(e) {
                e.preventDefault();
                // Lấy tổng số trang từ response trước đó hoặc ước tính
                var totalPages = Math.ceil(document.getElementById('paginationInfo').textContent.match(/\d+/g)[2] / itemsPerPageProducts);
                if (currentPageProducts < totalPages) {
                    currentPageProducts++;
                    filterProductsWithPagination();
                }
            });
        });
        
    </script>
</body>
</html>




