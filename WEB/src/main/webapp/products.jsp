<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý sản phẩm | Bảng điều khiển quản trị</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <link href="<%=request.getContextPath()%>/admin/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="<%=request.getContextPath()%>/admin/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="<%=request.getContextPath()%>/admin/css/style.css" rel="stylesheet" type="text/css" />
    <link href="<%=request.getContextPath()%>/css/products.css" rel="stylesheet" type="text/css" />
    
</head>
<body class="skin-black products-page">
    <header class="header">
        <a href="<%=request.getContextPath()%>/admin/admin.jsp" class="logo">
            Bảng điều khiển quản trị
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
                            <span><%= username %> <i class="caret"></i></span>
                        </a>
                        <ul class="dropdown-menu dropdown-custom dropdown-menu-right">
                            <li class="dropdown-header text-center">Tài khoản</li>
                            <li>
                                <a href="#"><i class="fa fa-user fa-fw pull-right"></i> Hồ sơ</a>
                                <a href="#"><i class="fa fa-cog fa-fw pull-right"></i> Cài đặt</a>
                            </li>
                            <li class="divider"></li>
                            <li>
                                <a href="<%=request.getContextPath()%>/admin/logout"><i class="fa fa-ban fa-fw pull-right"></i> Đăng xuất</a>
                            </li>
                        </ul>
                    </li>
                </ul>
            </div>
        </nav>
    </header>
    <div class="wrapper row-offcanvas row-offcanvas-left">
        <aside class="left-side sidebar-offcanvas">
            <section class="sidebar">
                <div class="user-panel">
                    <div class="pull-left image">
                        <img src="<%=request.getContextPath()%>/admin/img/26115.jpg" class="img-circle" alt="User Image" />
                    </div>
                    <div class="pull-left info">
                        <p>Xin chào, <%= username %></p>
                        <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
                    </div>
                </div>
                <form action="#" method="get" class="sidebar-form">
                    <div class="input-group">
                        <input type="text" name="q" class="form-control" placeholder="Tìm kiếm..."/>
                        <span class="input-group-btn">
                            <button type='submit' name='seach' id='search-btn' class="btn btn-flat"><i class="fa fa-search"></i></button>
                        </span>
                    </div>
                </form>
                <ul class="sidebar-menu">
                    <li class="active">
                        <a href="<%=request.getContextPath()%>/products.jsp">
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
                </ul>
            </section>
        </aside>
        <aside class="right-side">
            <section class="content">
                <div class="container-fluid">
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
                        <div class="col-md-8">
                            <h2 class="page-title">Quản lý sản phẩm</h2>
                        </div>
                        <div class="col-md-4 text-right">
                            <button class="btn btn-primary btn-lg" data-toggle="modal" data-target="#addProductModal" style="margin-top:10px;">
                                <i class="fa fa-plus"></i> Thêm sản phẩm mới
                            </button>
                        </div>
                    </div>
                    <%
                        // Lấy tất cả thống kê từ database trong một lần query (tối ưu hiệu suất)
                        com.hlgenerator.dao.ProductDAO statsDAO = new com.hlgenerator.dao.ProductDAO();
                        java.util.Map<String, Integer> stats = statsDAO.getAllStatistics();
                        int totalProducts = stats.get("totalProducts");
                        int totalCategories = stats.get("totalCategories");
                        int activeProducts = stats.get("activeProducts");
                        int lowStockProducts = stats.get("lowStockProducts");
                    %>
                    <div class="row" style="margin-bottom:15px;">
                        <div class="col-md-3">
                            <div class="sm-st clearfix">
                                <span class="sm-st-icon st-red"><i class="fa fa-cubes"></i></span>
                                <div class="sm-st-info">
                                    <span><%= totalProducts %></span>
                                    Tổng sản phẩm
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="sm-st clearfix">
                                <span class="sm-st-icon st-blue"><i class="fa fa-tags"></i></span>
                                <div class="sm-st-info">
                                    <span><%= totalCategories %></span>
                                    Danh mục
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="sm-st clearfix">
                                <span class="sm-st-icon st-green"><i class="fa fa-check"></i></span>
                                <div class="sm-st-info">
                                    <span><%= activeProducts %></span>
                                    Còn hàng
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="sm-st clearfix">
                                <span class="sm-st-icon st-violet"><i class="fa fa-exclamation-triangle"></i></span>
                                <div class="sm-st-info">
                                    <span><%= lowStockProducts %></span>
                                    Sắp hết hàng
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Phần lọc sản phẩm -->
                    <div class="row" style="margin-bottom:15px; padding:15px; background-color:#f8f9fa; border-radius:5px;">
                        <div class="col-md-4">
                            <label for="filterCategory">Lọc theo danh mục:</label>
                            <select class="form-control" id="filterCategory" onchange="filterProducts()">
                                <option value="">Tất cả danh mục</option>
                                <%
                                    java.util.List<String> categories = statsDAO.getAllCategories();
                                    for (String category : categories) {
                                %>
                                <option value="<%= category %>"><%= category %></option>
                                <%
                                    }
                                %>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label for="filterStatus">Lọc theo trạng thái:</label>
                            <select class="form-control" id="filterStatus" onchange="filterProducts()">
                                <option value="">Tất cả trạng thái</option>
                                <option value="active">Đang bán</option>
                                <option value="discontinued">Ngừng bán</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label for="searchProduct">Tìm kiếm sản phẩm:</label>
                            <input type="text" class="form-control" id="searchProduct" placeholder="Nhập tên hoặc mã sản phẩm..." oninput="filterProducts()">
                        </div>
                        <div class="col-md-1">
                            <label>&nbsp;</label>
                            <button type="button" class="btn btn-secondary form-control" onclick="resetFilters()" title="Xóa bộ lọc">
                                <i class="fa fa-refresh"></i>
                            </button>
                        </div>
                    </div>
                    
                    <div class="product-list">
                        <%
                            com.hlgenerator.dao.ProductDAO productDAO = new com.hlgenerator.dao.ProductDAO();
                            java.util.List<com.hlgenerator.model.Product> products = productDAO.getAllProducts();
                            for (com.hlgenerator.model.Product product : products) {
                        %>
                        <div class="product-item">
                            <div class="product-card" data-status="<%= product.getStatus() %>" data-category="<%= product.getCategory() %>">
                                <%
                                    String imgUrl;
                                    if (product.getImageUrl() != null && !product.getImageUrl().trim().isEmpty() && !product.getImageUrl().equals("null")) {
                                        // Nếu có URL ảnh từ database
                                        imgUrl = product.getImageUrl();
                                        // Đảm bảo URL có context path nếu cần
                                        if (!imgUrl.startsWith("http") && !imgUrl.startsWith("/")) {
                                            imgUrl = request.getContextPath() + "/" + imgUrl;
                                        } else if (imgUrl.startsWith("/") && !imgUrl.startsWith(request.getContextPath())) {
                                            imgUrl = request.getContextPath() + imgUrl;
                                        }
                                        
                                        // Kiểm tra xem có phải ảnh mặc định không
                                        if (imgUrl.contains("sanpham1.jpg")) {
                                            // Nếu là ảnh mặc định, hiển thị placeholder
                                            imgUrl = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZGRkIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNCIgZmlsbD0iIzk5OSIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPk5vIEltYWdlPC90ZXh0Pjwvc3ZnPg==";
                                        }
                                    } else {
                                        // Không có ảnh - hiển thị placeholder
                                        imgUrl = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZGRkIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNCIgZmlsbD0iIzk5OSIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPk5vIEltYWdlPC90ZXh0Pjwvc3ZnPg==";
                                    }
                                %>
                                <img src="<%= imgUrl %>" class="product-img" alt="<%= product.getProductName() %>">
                                <div class="product-info">
                                    <h4 class="product-name"><%= product.getProductName() %></h4>
                                    <p class="product-price"><%= String.format("%,.0f", product.getUnitPrice()) %> VNĐ</p>
                                    <p class="product-category">Danh mục: <%= product.getCategory() != null ? product.getCategory() : "Chưa phân loại" %></p>
                                    <div class="product-actions">
                                        <button class="btn btn-info" data-product-id="<%= product.getId() %>" onclick="viewProduct(this)">Xem</button>
                                        <button class="btn btn-warning" data-product-id="<%= product.getId() %>" onclick="editProduct(this)" style="margin-left:8px;">Sửa</button>
                                        <button class="btn btn-danger" data-product-id="<%= product.getId() %>" onclick="deleteProduct(this)" style="margin-left:8px;">Xóa</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <%
                            }
                        %>
                    </div>
                </div>
                
            </section>
        </aside>
    </div>

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
                    <form id="editProductForm" action="<%=request.getContextPath()%>/api/products" method="post">
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
                    
                    <form id="addProductForm" action="<%=request.getContextPath()%>/addProduct" method="post">
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
                    <button type="submit" class="btn btn-primary" form="addProductForm">Lưu sản phẩm</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts giống admin để hỗ trợ header/sidebar -->
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/admin/js/jquery.min.js" type="text/javascript"></script>
    <script src="<%=request.getContextPath()%>/admin/js/jquery-ui-1.10.3.min.js" type="text/javascript"></script>
    <script src="<%=request.getContextPath()%>/admin/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="<%=request.getContextPath()%>/admin/js/Director/app.js" type="text/javascript"></script>

    <script>

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
                url: '<%=request.getContextPath()%>/api/products?action=view&id=' + id,
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
                url: '<%=request.getContextPath()%>/api/products?action=view&id=' + id,
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
                url: '<%=request.getContextPath()%>/api/products',
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

        function deleteProduct(element) {
            var id = $(element).data('product-id');
            if (!id || id <= 0) {
                alert('ID sản phẩm không hợp lệ');
                return;
            }
            if (confirm('Bạn có chắc chắn muốn xóa sản phẩm này?')) {
                $.ajax({
                    url: '<%=request.getContextPath()%>/api/products',
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
        
        // Function lọc sản phẩm
        function filterProducts() {
            var categoryFilter = document.getElementById('filterCategory').value.toLowerCase();
            var statusFilter = document.getElementById('filterStatus').value.toLowerCase();
            var searchFilter = document.getElementById('searchProduct').value.toLowerCase();
            
            var productItems = document.querySelectorAll('.product-item');
            
            productItems.forEach(function(item) {
                var productCard = item.querySelector('.product-card');
                var productName = productCard.querySelector('.product-name').textContent.toLowerCase();
                var productCategory = productCard.querySelector('.product-category').textContent.toLowerCase();
                
                // Lấy thông tin status và category từ data attributes
                var productStatus = productCard.getAttribute('data-status') ? productCard.getAttribute('data-status').toLowerCase() : 'active';
                var productCategoryData = productCard.getAttribute('data-category') ? productCard.getAttribute('data-category').toLowerCase() : '';
                
                // Kiểm tra điều kiện lọc
                var matchCategory = !categoryFilter || productCategory.includes(categoryFilter) || productCategoryData.includes(categoryFilter);
                var matchStatus = !statusFilter || productStatus === statusFilter;
                var matchSearch = !searchFilter || productName.includes(searchFilter) || 
                                productCard.textContent.toLowerCase().includes(searchFilter);
                
                // Hiển thị hoặc ẩn sản phẩm
                if (matchCategory && matchStatus && matchSearch) {
                    item.style.display = 'block';
                } else {
                    item.style.display = 'none';
                }
            });
            
            // Cập nhật số lượng sản phẩm hiển thị
            updateProductCount();
        }
        
        // Function cập nhật số lượng sản phẩm hiển thị
        function updateProductCount() {
            var visibleProducts = document.querySelectorAll('.product-item[style*="block"], .product-item:not([style*="none"])').length;
            var totalProducts = document.querySelectorAll('.product-item').length;
            
            // Có thể thêm hiển thị số lượng ở đâu đó nếu cần
            console.log('Hiển thị ' + visibleProducts + '/' + totalProducts + ' sản phẩm');
        }
        
        // Reset filter
        function resetFilters() {
            document.getElementById('filterCategory').value = '';
            document.getElementById('filterStatus').value = '';
            document.getElementById('searchProduct').value = '';
            filterProducts();
        }
    </script>
</body>
</html>
