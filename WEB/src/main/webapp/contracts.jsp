<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Kiểm tra đăng nhập
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    String userRole = (String) session.getAttribute("userRole");
    String currentStatus = request.getParameter("status");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Kiểm tra quyền truy cập - admin, customer_support, customer có thể xem hợp đồng
    boolean canViewContracts = "admin".equals(userRole) || "customer_support".equals(userRole) || "customer".equals(userRole);
    if (!canViewContracts) {
        response.sendRedirect(request.getContextPath() + "/403.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng điều khiển | Quản lý hợp đồng</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <link href="css/datatables/dataTables.bootstrap.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css" rel="stylesheet" type="text/css" />
    <link href='http://fonts.googleapis.com/css?family=Lato' rel='stylesheet' type='text/css'>
    <style>
        .has-error {
            border-color: #a94442 !important;
            box-shadow: inset 0 1px 1px rgba(0,0,0,.075), 0 0 6px #ce8483 !important;
        }
        .help-block.text-danger {
            margin-top: 5px;
            font-size: 12px;
        }
        .text-danger {
            color: #a94442 !important;
        }
        .form-group label .text-danger {
            font-weight: bold;
        }
        
        /* Style cho thông báo trong modal */
        #contractErrorAlert {
            border-radius: 6px;
            font-weight: 500;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        #contractErrorAlert.alert-success {
            background-color: #d4edda;
            border-color: #c3e6cb;
            color: #155724;
        }
        #contractErrorAlert.alert-danger {
            background-color: #f8d7da;
            border-color: #f5c6cb;
            color: #721c24;
        }
        #contractErrorAlert.alert-warning {
            background-color: #fff3cd;
            border-color: #ffeaa7;
            color: #856404;
        }
        #contractErrorAlert.alert-info {
            background-color: #d1ecf1;
            border-color: #bee5eb;
            color: #0c5460;
        }
    </style>
</head>
<body class="skin-black">
    <header class="header">
        <a href="customersupport.jsp" class="logo">
            Hỗ Trợ Khách Hàng
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
                            <span><%= (session.getAttribute("fullName") != null && !((String)session.getAttribute("fullName")).isEmpty()) ? (String)session.getAttribute("fullName") : username %> <i class="caret"></i></span>
                        </a>
                        <ul class="dropdown-menu dropdown-custom dropdown-menu-right">
                            <li class="dropdown-header text-center">Tài khoản</li>
                            <li>
                                <a href="profile.jsp"><i class="fa fa-user fa-fw pull-right"></i> Hồ sơ</a>
                                <a href="settings.jsp"><i class="fa fa-cog fa-fw pull-right"></i> Cài đặt</a>
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
        <aside class="left-side sidebar-offcanvas">
            <section class="sidebar">
                <div class="user-panel">
                    <div class="pull-left image">
                        <img src="img/26115.jpg" class="img-circle" alt="User Image" />
                    </div>
                    <div class="pull-left info">
                        <p>Xin chào, Admin</p>
                        <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
                    </div>
                </div>
                <ul class="sidebar-menu">
                    <li>
                        <a href="customersupport.jsp"><i class="fa fa-dashboard"></i> <span>Bảng điều khiển khách hàng</span></a>
                    </li>
                    <li class="active">
                        <a href="contracts.jsp"><i class="fa fa-file-text"></i> <span>Quản lý hợp đồng</span></a>
                    </li>
                    <li>
                        <a href="support-management"><i class="fa fa-life-ring"></i> <span>Quản lý yêu cầu hỗ trợ</span></a>
                    </li>
                </ul>
            </section>
        </aside>

        <aside class="right-side">
            <section class="content">
                <div class="row">
                    <div class="col-xs-12">
                        <div class="panel">
                            <header class="panel-heading">
                                <h3>Quản lý hợp đồng</h3>
                                <div class="panel-tools">
                                    <% if (!"deleted".equals(currentStatus)) { %>
                                    <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#contractModal">
                                        <i class="fa fa-plus"></i> Thêm hợp đồng mới
                                    </button>
                                    <% } %>
                                    <button class="btn btn-warning btn-sm" onclick="showDeletedContracts()" style="margin-left: 5px;">
                                        <i class="fa fa-trash"></i> Thùng rác
                                    </button>
                                    <% if ("deleted".equals(currentStatus)) { %>
                                    <a href="contracts.jsp" class="btn btn-success btn-sm" style="margin-left: 5px;">
                                        <i class="fa fa-arrow-left"></i> Quay lại danh sách chính
                                    </a>
                                    <% } %>
                                </div>
                            </header>
                            <div class="panel-body table-responsive">
                                <%
                                    if ("deleted".equals(currentStatus)) {
                                %>
                                <div class="alert alert-warning" style="margin-bottom: 15px;">
                                    <i class="fa fa-exclamation-triangle"></i> 
                                    <strong>Đang xem hợp đồng đã bị xóa</strong> - Các hợp đồng này đã được chuyển vào thùng rác. 
                                    Bạn có thể khôi phục hoặc xóa vĩnh viễn chúng.
                                </div>
                                <% } %>
                                <form class="form-inline" method="get" action="contracts.jsp" style="margin-bottom: 15px;">
                                    <div class="form-group" style="margin-right: 10px;">
                                        <label for="statusFilter">Trạng thái:&nbsp;</label>
                                        <select class="form-control" id="statusFilter" name="status">
                                            <option value="">Tất cả</option>
                                            <option value="draft">Bản nháp</option>
                                            <option value="active">Hiệu lực</option>
                                            <option value="completed">Hoàn thành</option>
                                            <option value="terminated">Chấm dứt</option>
                                            <option value="expired">Hết hạn</option>
                                            <option value="deleted">Đã xóa</option>
                                        </select>
                                    </div>
                                    <div class="form-group" style="margin-right: 10px;">
                                        <label for="typeFilter">Loại:&nbsp;</label>
                                        <input type="text" class="form-control" id="typeFilter" name="contractType" placeholder="VD: Service">
                                    </div>
                                    <div class="form-group" style="margin-right: 10px;">
                                        <label for="search">Tìm kiếm:&nbsp;</label>
                                        <input type="text" class="form-control" id="search" name="q" placeholder="ID, số HĐ, tên KH">
                                    </div>
                                    <div class="form-group" style="margin-right: 10px;">
                                        <label>Bắt đầu:&nbsp;</label>
                                        <input type="date" class="form-control" name="startFrom">
                                    </div>
                                    <div class="form-group" style="margin-right: 10px;">
                                        <label>Đến:&nbsp;</label>
                                        <input type="date" class="form-control" name="startTo">
                                    </div>
                                    <div class="form-group" style="margin-right: 10px;">
                                        <label>Kết thúc từ:&nbsp;</label>
                                        <input type="date" class="form-control" name="endFrom">
                                    </div>
                                    <div class="form-group" style="margin-right: 10px;">
                                        <label>Đến:&nbsp;</label>
                                        <input type="date" class="form-control" name="endTo">
                                    </div>
                                    <div class="form-group" style="margin-right: 10px;">
                                        <label for="sortBy">Sắp xếp:&nbsp;</label>
                                        <select class="form-control" id="sortBy" name="sortBy">
                                            <option value="id">ID hợp đồng</option>
                                            <option value="customerName">Tên khách hàng</option>
                                            <option value="startDate">Ngày bắt đầu</option>
                                            <option value="endDate">Ngày kết thúc</option>
                                            <option value="status">Trạng thái</option>
                                        </select>
                                    </div>
                                    <div class="form-group" style="margin-right: 10px;">
                                        <select class="form-control" name="sortDir">
                                            <option value="desc">Giảm dần</option>
                                            <option value="asc">Tăng dần</option>
                                        </select>
                                    </div>
                                    <input type="hidden" name="size" value="<%= request.getParameter("size") != null ? request.getParameter("size") : "10" %>">
                                    <button type="submit" class="btn btn-default"><i class="fa fa-filter"></i> Lọc</button>
                                    <a href="contracts.jsp" class="btn btn-link">Xóa lọc</a>
                                </form>
                                <table class="table table-hover" id="contractsTable">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Số hợp đồng</th>
                                            <th>Khách hàng (ID)</th>
                                            <th>Loại</th>
                                            <th>Tiêu đề</th>
                                            <th>Bắt đầu</th>
                                            <th>Kết thúc</th>
                                            <th>Giá trị</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="contractsTableBody">
                                        <%
                                            com.hlgenerator.dao.ContractDAO dao = new com.hlgenerator.dao.ContractDAO();
                                            String pageParam = request.getParameter("page");
                                            String sizeParam = request.getParameter("size");
                                            int currentPage = 1;
                                            int pageSize = 10;
                                            try { if (pageParam != null) currentPage = Integer.parseInt(pageParam); } catch (Exception ignored) {}
                                            try { if (sizeParam != null) pageSize = Integer.parseInt(sizeParam); } catch (Exception ignored) {}
                                            if (currentPage < 1) currentPage = 1;
                                            if (pageSize < 1) pageSize = 10;
                                            String status = request.getParameter("status");
                                            String contractType = request.getParameter("contractType");
                                            String search = request.getParameter("q");
                                            java.sql.Date startFrom = null, startTo = null, endFrom = null, endTo = null;
                                            try { String v = request.getParameter("startFrom"); if (v != null && !v.isEmpty()) startFrom = java.sql.Date.valueOf(v); } catch (Exception ignored) {}
                                            try { String v = request.getParameter("startTo"); if (v != null && !v.isEmpty()) startTo = java.sql.Date.valueOf(v); } catch (Exception ignored) {}
                                            try { String v = request.getParameter("endFrom"); if (v != null && !v.isEmpty()) endFrom = java.sql.Date.valueOf(v); } catch (Exception ignored) {}
                                            try { String v = request.getParameter("endTo"); if (v != null && !v.isEmpty()) endTo = java.sql.Date.valueOf(v); } catch (Exception ignored) {}
                                            String sortBy = request.getParameter("sortBy");
                                            String sortDir = request.getParameter("sortDir");
                                            int total = dao.countContractsFiltered(status, contractType, search, startFrom, startTo, endFrom, endTo);
                                            int totalPages = (int) Math.ceil(total / (double) pageSize);
                                            if (totalPages == 0) totalPages = 1;
                                            if (currentPage > totalPages) currentPage = totalPages;
                                            java.util.List<com.hlgenerator.model.Contract> contracts = dao.getContractsPageFiltered(currentPage, pageSize, status, contractType, search, startFrom, startTo, endFrom, endTo, sortBy, sortDir);
                                            for (com.hlgenerator.model.Contract c : contracts) {
                                        %>
                                        <tr>
                                            <td><%= c.getId() %></td>
                                            <td><%= c.getContractNumber() %></td>
                                            <td><%= c.getCustomerId() %></td>
                                            <td><%= c.getContractType() != null ? c.getContractType() : "-" %></td>
                                            <td><%= c.getTitle() != null ? c.getTitle() : "-" %></td>
                                            <td><%= c.getStartDate() != null ? c.getStartDate() : "-" %></td>
                                            <td><%= c.getEndDate() != null ? c.getEndDate() : "-" %></td>
                                            <td><%= c.getContractValue() != null ? c.getContractValue() : "-" %></td>
                                            <td><%= c.getStatus() %></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="viewContract('<%= c.getId() %>')"><i class="fa fa-eye"></i> Xem</button>
                                                <% if (!"deleted".equals(c.getStatus())) { %>
                                                    <button class="btn btn-warning btn-xs" onclick="editContract('<%= c.getId() %>')"><i class="fa fa-edit"></i> Sửa</button>
                                                    <button class="btn btn-danger btn-xs" onclick="deleteContract('<%= c.getId() %>')"><i class="fa fa-trash"></i> Xóa</button>
                                                <% } else { %>
                                                    <button class="btn btn-success btn-xs" onclick="restoreContract('<%= c.getId() %>')"><i class="fa fa-undo"></i> Khôi phục</button>
                                                    <button class="btn btn-danger btn-xs" onclick="permanentlyDeleteContract('<%= c.getId() %>')"><i class="fa fa-trash"></i> Xóa vĩnh viễn</button>
                                                <% } %>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                                
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </aside>
    </div>


    <!-- Modal thêm/sửa hợp đồng -->
    <div class="modal fade" id="contractModal" tabindex="-1" role="dialog" aria-labelledby="contractModalLabel">
        <div class="modal-dialog modal-lg" role="document" style="width: 95%; max-width: 1400px;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="contractModalLabel">Thêm hợp đồng mới</h4>
                </div>
                <div class="modal-body">
                    <!-- Vùng hiển thị thông báo lỗi -->
                    <div id="contractErrorAlert" class="alert alert-danger alert-dismissible" style="display: none; margin-bottom: 20px;">
                        <button type="button" class="close" onclick="hideModalAlert()" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <span id="contractErrorText"></span>
                    </div>
                    
                    <form id="contractForm">
                        <input type="hidden" id="contractId">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="contractNumber">Số hợp đồng <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="contractNumber" required>
                                    <div class="help-block text-danger" id="contractNumberError" style="display: none;"></div>
                                    <small class="text-muted">Số hợp đồng phải duy nhất và không được trống</small>
                                </div>
                                <div class="form-group">
                                    <label for="customerId">Khách hàng <span class="text-danger">*</span></label>
                                    <select class="form-control" id="customerId" required>
                                        <option value="">Chọn khách hàng...</option>
                                    </select>
                                    <div class="help-block text-danger" id="customerIdError" style="display: none;"></div>
                                </div>
                                <div class="form-group">
                                    <label for="contractType">Loại hợp đồng</label>
                                    <input type="text" class="form-control" id="contractType" placeholder="VD: Service, Maintenance, Supply">
                                </div>
                                <div class="form-group">
                                    <label for="title">Tiêu đề</label>
                                    <input type="text" class="form-control" id="title" placeholder="Nhập tiêu đề hợp đồng">
                                </div>
                                <div class="form-group">
                                    <label for="terms">Điều khoản</label>
                                    <textarea class="form-control" id="terms" rows="4" placeholder="Nhập các điều khoản của hợp đồng"></textarea>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="startDate">Ngày bắt đầu</label>
                                    <input type="date" class="form-control" id="startDate">
                                    <div class="help-block text-danger" id="startDateError" style="display: none;"></div>
                                </div>
                                <div class="form-group">
                                    <label for="endDate">Ngày kết thúc</label>
                                    <input type="date" class="form-control" id="endDate">
                                    <div class="help-block text-danger" id="endDateError" style="display: none;"></div>
                                </div>
                                <div class="form-group">
                                    <label for="signedDate">Ngày ký</label>
                                    <input type="date" class="form-control" id="signedDate">
                                </div>
                                <div class="form-group">
                                    <label for="contractValue">Giá trị hợp đồng (VNĐ)</label>
                                    <div class="input-group">
                                        <input type="number" class="form-control" id="contractValue" step="0.01" min="0" placeholder="0">
                                        <span class="input-group-btn">
                                            <button class="btn btn-info" type="button" onclick="updateContractValueFromProducts()" title="Tự động cập nhật từ tổng sản phẩm">
                                                <i class="fa fa-calculator"></i> Tự động
                                            </button>
                                        </span>
                                    </div>
                                    <div class="help-block text-danger" id="contractValueError" style="display: none;"></div>
                                    <small class="text-muted">Nhấn "Tự động" để cập nhật từ tổng giá trị sản phẩm</small>
                                </div>
                                <div class="form-group">
                                    <label for="status">Trạng thái</label>
                                    <select id="status" class="form-control">
                                        <option value="draft">Bản nháp</option>
                                        <option value="active">Hiệu lực</option>
                                        <option value="completed">Hoàn thành</option>
                                        <option value="terminated">Chấm dứt</option>
                                        <option value="expired">Hết hạn</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Phần quản lý sản phẩm trong hợp đồng -->
                        <hr>
                        <div class="row">
                            <div class="col-md-8">
                                <h5><i class="fa fa-list"></i> Sản phẩm trong hợp đồng</h5>
                            </div>
                            <div class="col-md-4 text-right">
                                <button class="btn btn-primary btn-sm" onclick="showAddProductForm()">
                                    <i class="fa fa-plus"></i> Thêm sản phẩm
                                </button>
                            </div>
                        </div>
                        
                        <!-- Bảng sản phẩm -->
                        <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
                            <table class="table table-striped table-hover" id="contractProductsTable">
                                <thead class="thead-dark" style="position: sticky; top: 0; z-index: 10;">
                                    <tr>
                                        <th width="8%">STT</th>
                                        <th width="12%">Product ID</th>
                                        <th width="20%">Mô tả</th>
                                        <th width="10%">Số lượng</th>
                                        <th width="12%">Đơn giá</th>
                                        <th width="12%">Thành tiền</th>
                                        <th width="8%">Bảo hành</th>
                                        <th width="10%">Ghi chú</th>
                                        <th width="8%">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody id="contractProductsTableBody">
                                    <tr id="noProductsRow">
                                        <td colspan="9" class="text-center text-muted">
                                            <i class="fa fa-info-circle"></i> Chưa có sản phẩm nào. Nhấn "Thêm sản phẩm" để bắt đầu.
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- Tổng tiền -->
                        <div class="row" style="margin-top: 15px;">
                            <div class="col-md-8"></div>
                            <div class="col-md-4">
                                <div class="alert alert-info" style="margin-bottom: 0;">
                                    <strong>Tổng giá trị hợp đồng: <span id="totalContractValue">0 VNĐ</span></strong>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Form thêm/sửa sản phẩm (ẩn mặc định) -->
                        <div id="productFormContainer" style="display: none; margin-top: 20px;">
                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h5 class="panel-title">
                                        <i class="fa fa-edit"></i> 
                                        <span id="productFormTitle">Thêm sản phẩm mới</span>
                                        <button type="button" class="close pull-right" onclick="hideAddProductForm()" style="margin-top: -5px; color: white;">
                                            <span style="font-size: 18px;">&times;</span>
                                        </button>
                                    </h5>
                                </div>
                                <div class="panel-body" style="padding: 20px;">
                                    <form id="productForm">
                                        <input type="hidden" id="editingProductIndex" value="">
                                        
                                        <!-- Dòng 1: Chọn sản phẩm -->
                                        <div class="row">
                                            <div class="col-md-6">
                                                <label><strong>Sản phẩm <span class="text-danger">*</span></strong></label>
                                                <select class="form-control" id="newProductId" required style="height: 40px; font-size: 14px;">
                                                    <option value="">Chọn sản phẩm...</option>
                                                </select>
                                                <small class="text-muted">Tìm kiếm theo tên hoặc mã sản phẩm</small>
                                            </div>
                                            <div class="col-md-3">
                                                <label><strong>Số lượng <span class="text-danger">*</span></strong></label>
                                                <input type="number" step="0.01" min="0" class="form-control" id="newQuantity" placeholder="Nhập số lượng" required style="height: 40px; font-size: 14px;">
                                            </div>
                                            <div class="col-md-3">
                                                <label><strong>Bảo hành (tháng)</strong></label>
                                                <input type="number" min="0" class="form-control" id="newWarrantyMonths" placeholder="12" readonly style="height: 40px; font-size: 14px; background-color: #f5f5f5;">
                                            </div>
                                        </div>
                                        <div class="row" style="margin-top: 8px;">
                                            <div class="col-md-6">
                                                <small id="stockInfo" class="text-muted"></small>
                                            </div>
                                        </div>
                                        
                                        <!-- Dòng 2: Thông tin sản phẩm (tự động điền) -->
                                        <div class="row" style="margin-top: 15px;">
                                            <div class="col-md-6">
                                                <label><strong>Mô tả sản phẩm</strong></label>
                                                <textarea class="form-control" id="newDescription" rows="2" placeholder="Mô tả sẽ tự động điền khi chọn sản phẩm" readonly style="font-size: 14px;"></textarea>
                                            </div>
                                            <div class="col-md-3">
                                                <label><strong>Đơn giá (VNĐ)</strong></label>
                                                <input type="text" class="form-control" id="newUnitPrice" placeholder="Giá sẽ tự động điền" readonly style="height: 40px; font-size: 14px; background-color: #f5f5f5;">
                                            </div>
                                            <div class="col-md-3">
                                                <label><strong>Thành tiền (VNĐ)</strong></label>
                                                <input type="text" class="form-control" id="newLineTotal" placeholder="Tự động tính" readonly style="height: 40px; font-size: 14px; background-color: #e8f5e8; font-weight: bold;">
                                            </div>
                                        </div>
                                        
                                        <!-- Dòng 3: Ghi chú và nút -->
                                        <div class="row" style="margin-top: 15px;">
                                            <div class="col-md-8">
                                                <label><strong>Ghi chú</strong></label>
                                                <input type="text" class="form-control" id="newNotes" placeholder="Ghi chú thêm về sản phẩm này..." style="height: 40px; font-size: 14px;">
                                            </div>
                                            <div class="col-md-4">
                                                <label>&nbsp;</label>
                                                <div style="margin-top: 5px;">
                                                    <button type="button" class="btn btn-success btn-lg" onclick="addProductToContract()" style="margin-right: 10px;">
                                                        <i class="fa fa-save"></i> Lưu sản phẩm
                                                    </button>
                                                    <button type="button" class="btn btn-default btn-lg" onclick="hideAddProductForm()">
                                                        <i class="fa fa-times"></i> Hủy
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="saveContract()">Lưu</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal xem chi tiết -->
    <div class="modal fade" id="contractDetailModal" tabindex="-1" role="dialog" aria-labelledby="contractDetailModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="contractDetailModalLabel">Chi tiết hợp đồng</h4>
                </div>
                <div class="modal-body" id="contractDetail"></div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal thùng rác -->
    <div class="modal fade" id="deletedContractsModal" tabindex="-1" role="dialog" aria-labelledby="deletedContractsModalLabel">
        <div class="modal-dialog modal-xl" role="document" style="width: 95%; max-width: 1400px;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="deletedContractsModalLabel">Thùng rác - Hợp đồng đã xóa</h4>
                </div>
                <div class="modal-body">
                    <!-- Form tìm kiếm và sắp xếp -->
                    <div class="row" style="margin-bottom: 15px;">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label for="deletedSearch">Tìm kiếm:</label>
                                <input type="text" class="form-control" id="deletedSearch" placeholder="ID, số HĐ, tiêu đề...">
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group">
                                <label for="deletedSortBy">Sắp xếp theo:</label>
                                <select class="form-control" id="deletedSortBy">
                                    <option value="deleted_at">Ngày xóa</option>
                                    <option value="id">ID hợp đồng</option>
                                    <option value="contract_number">Số hợp đồng</option>
                                    <option value="title">Tiêu đề</option>
                                    <option value="deleted_by_name">Người xóa</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <label for="deletedSortDir">Thứ tự:</label>
                                <select class="form-control" id="deletedSortDir">
                                    <option value="desc">Mới nhất</option>
                                    <option value="asc">Cũ nhất</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <label for="deletedPageSize">Số dòng:</label>
                                <select class="form-control" id="deletedPageSize">
                                    <option value="10">10</option>
                                    <option value="25">25</option>
                                    <option value="50">50</option>
                                    <option value="100">100</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-1">
                            <div class="form-group">
                                <label>&nbsp;</label>
                                <button class="btn btn-primary form-control" onclick="loadDeletedContracts()">
                                    <i class="fa fa-search"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Bảng dữ liệu -->
                    <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                        <table class="table table-hover" id="deletedContractsTable">
                            <thead class="thead-dark" style="position: sticky; top: 0; z-index: 10;">
                                <tr>
                                    <th width="8%">ID</th>
                                    <th width="15%">Số hợp đồng</th>
                                    <th width="10%">Khách hàng</th>
                                    <th width="20%">Tiêu đề</th>
                                    <th width="15%">Người xóa</th>
                                    <th width="12%">Ngày xóa</th>
                                    <th width="20%">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody id="deletedContractsTableBody">
                                <tr>
                                    <td colspan="7" class="text-center text-muted">
                                        <i class="fa fa-spinner fa-spin"></i> Đang tải...
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Phân trang -->
                    <div class="row" style="margin-top: 15px;">
                        <div class="col-md-12">
                            <div class="row">
                                <div class="col-md-6">
                                    <div id="deletedPaginationInfo" class="text-muted" style="line-height: 34px;">
                                        Hiển thị 0 - 0 của 0 bản ghi
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <nav aria-label="Phân trang thùng rác" class="pull-right">
                                        <ul class="pagination pagination-sm" id="deletedPagination" style="margin: 0;">
                                            <!-- Sẽ được tạo động bằng JavaScript -->
                                        </ul>
                                    </nav>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal chọn trạng thái khi khôi phục -->
    <div class="modal fade" id="restoreStatusModal" tabindex="-1" role="dialog" aria-labelledby="restoreStatusModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="restoreStatusModalLabel">Chọn trạng thái khôi phục</h4>
                </div>
                <div class="modal-body">
                    <p>Chọn trạng thái cho hợp đồng khi khôi phục:</p>
                    <div class="form-group">
                        <label for="restoreStatus">Trạng thái:</label>
                        <select class="form-control" id="restoreStatus">
                            <option value="draft">Bản nháp</option>
                            <option value="active">Hiệu lực</option>
                            <option value="completed">Hoàn thành</option>
                            <option value="terminated">Chấm dứt</option>
                            <option value="expired">Hết hạn</option>
                        </select>
                    </div>
                    <input type="hidden" id="restoreContractId">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-success" onclick="confirmRestore()">Khôi phục</button>
                </div>
            </div>
        </div>
    </div>

    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
    <script src="js/jquery.min.js" type="text/javascript"></script>
    <script src="js/jquery-ui-1.10.3.min.js" type="text/javascript"></script>
    <script src="js/bootstrap.min.js" type="text/javascript"></script>
    <script src="js/plugins/datatables/jquery.dataTables.js" type="text/javascript"></script>
    <script src="js/plugins/datatables/dataTables.bootstrap.js" type="text/javascript"></script>
    <script src="js/Director/app.js" type="text/javascript"></script>

    <script type="text/javascript">
        var contractsTable;
        var currentEditingId = null;
        var isEditingMode = false; // Biến để kiểm tra đang sửa hay thêm mới

        var contractProducts = []; // Mảng lưu sản phẩm tạm thời

        $(document).ready(function() {
            contractsTable = $('#contractsTable').DataTable({
                "language": { "url": "//cdn.datatables.net/plug-ins/1.10.25/i18n/Vietnamese.json" },
                "processing": false,
                "serverSide": false,
                "paging": false,
                "searching": false,
                "dom": 'lrt',
                "ordering": true,
                "info": false,
                "autoWidth": false,
                "responsive": true,
                "order": [[0, "desc"]],
                "columnDefs": [{ "targets": [9], "orderable": false, "searchable": false }]
            });
            // Safety: remove filter container if any existed from previous inits
            $('#contractsTable_filter').remove();
            
            // Load danh sách khách hàng
            loadCustomers();

        });

        function loadCustomers() {
            console.log('Loading customers...');
            $.get('api/contracts', { action: 'customers' }, function(resp) {
                console.log('Customers response:', resp);
                if (resp.success) {
                    var options = '<option value="">Chọn khách hàng...</option>';
                    if (resp.data && resp.data.length > 0) {
                        resp.data.forEach(function(customer) {
                            options += '<option value="' + customer.id + '">' + 
                                      customer.customerCode + ' - ' + customer.companyName + 
                                      ' (' + customer.contactPerson + ')</option>';
                        });
                    } else {
                        options += '<option value="" disabled>Không có khách hàng nào</option>';
                    }
                    $('#customerId').html(options);
                    console.log('Customers loaded successfully');
                } else {
                    console.error('Error loading customers:', resp.message);
                    $('#customerId').html('<option value="" disabled>Lỗi tải khách hàng: ' + (resp.message || 'Unknown error') + '</option>');
                }
            }, 'json').fail(function(xhr, status, error) {
                console.error('AJAX error loading customers:', status, error);
                $('#customerId').html('<option value="" disabled>Lỗi kết nối: ' + error + '</option>');
            });
        }

        function loadProducts() {
            console.log('Loading products...');
            $.get('api/contracts', { action: 'products' }, function(resp) {
                console.log('Products response:', resp);
                if (resp.success) {
                    var options = '<option value="">Chọn sản phẩm...</option>';
                    if (resp.data && resp.data.length > 0) {
                        resp.data.forEach(function(product) {
                            options += '<option value="' + product.id + '" data-description="' + (product.description || '') + '" data-unitprice="' + product.unitPrice + '" data-warranty="' + (product.warrantyMonths != null ? product.warrantyMonths : '') + '" data-quantity="' + (product.quantity != null ? product.quantity : 0) + '">' + 
                                      product.productCode + ' - ' + product.productName + 
                                      ' (' + parseFloat(product.unitPrice).toLocaleString() + ' VNĐ, tồn: ' + (product.quantity != null ? product.quantity : 0) + ')</option>';
                        });
                    } else {
                        options += '<option value="" disabled>Không có sản phẩm nào</option>';
                    }
                    $('#newProductId').html(options);
                    console.log('Products loaded successfully');
                } else {
                    console.error('Error loading products:', resp.message);
                    $('#newProductId').html('<option value="" disabled>Lỗi tải sản phẩm: ' + (resp.message || 'Unknown error') + '</option>');
                }
            }, 'json').fail(function(xhr, status, error) {
                console.error('AJAX error loading products:', status, error);
                $('#newProductId').html('<option value="" disabled>Lỗi kết nối: ' + error + '</option>');
            });
        }

        function viewContract(id) {
            $.get('api/contracts', { action: 'get', id: id }, function(resp) {
                if (resp.success) {
                    var c = resp.data;
                    var html = '' +
                        '<p><strong>ID:</strong> ' + c.id + '</p>' +
                        '<p><strong>Số hợp đồng:</strong> ' + c.contractNumber + '</p>' +
                        '<p><strong>Khách hàng (ID):</strong> ' + c.customerId + '</p>' +
                        '<p><strong>Loại:</strong> ' + (c.contractType || '-') + '</p>' +
                        '<p><strong>Tiêu đề:</strong> ' + (c.title || '-') + '</p>' +
                        '<p><strong>Ngày bắt đầu:</strong> ' + (c.startDate || '-') + '</p>' +
                        '<p><strong>Ngày kết thúc:</strong> ' + (c.endDate || '-') + '</p>' +
                        '<p><strong>Giá trị:</strong> ' + (c.contractValue || '-') + '</p>' +
                        '<p><strong>Trạng thái:</strong> ' + (c.status || '-') + '</p>' +
                        '<p><strong>Ngày ký:</strong> ' + (c.signedDate || '-') + '</p>' +
                        '<p><strong>Điều khoản:</strong><br>' + (c.terms || '-') + '</p>' +
                        '<hr>' +
                        '<h5><i class="fa fa-list"></i> Sản phẩm gắn với hợp đồng</h5>' +
                        '<div class="table-responsive">' +
                        '  <table class="table table-striped table-hover">' +
                        '    <thead>' +
                        '      <tr>' +
                        '        <th width="10%">STT</th>' +
                        '        <th width="15%">Product ID</th>' +
                        '        <th width="30%">Mô tả</th>' +
                        '        <th width="15%">Số lượng</th>' +
                        '        <th width="15%">Đơn giá</th>' +
                        '        <th width="15%">Thành tiền</th>' +
                        '      </tr>' +
                        '    </thead>' +
                        '    <tbody id="contractDetailProductsBody">' +
                        '      <tr><td colspan="6" class="text-center text-muted"><i class="fa fa-spinner fa-spin"></i> Đang tải sản phẩm...</td></tr>' +
                        '    </tbody>' +
                        '  </table>' +
                        '</div>';
                    $('#contractDetail').html(html);

                    // Load products for this contract and render into the details modal
                    $.get('api/contract-items', { contractId: id }, function(itemsResp) {
                        var tbody = $('#contractDetailProductsBody');
                        if (itemsResp && itemsResp.success) {
                            var items = itemsResp.data || [];
                            if (items.length === 0) {
                                tbody.html('<tr><td colspan="6" class="text-center text-muted"><i class="fa fa-info-circle"></i> Hợp đồng chưa có sản phẩm</td></tr>');
                                return;
                            }
                            var rows = '';
                            var idx = 1;
                            items.forEach(function(p) {
                                var qty = p.quantity ? parseFloat(p.quantity).toLocaleString() : '0';
                                var price = p.unitPrice ? parseFloat(p.unitPrice).toLocaleString() + ' VNĐ' : '0 VNĐ';
                                var line = (p.quantity && p.unitPrice) ? (parseFloat(p.quantity) * parseFloat(p.unitPrice)) : 0;
                                rows += '<tr>' +
                                    '<td class="text-center">' + (idx++) + '</td>' +
                                    '<td class="text-center">' + p.productId + '</td>' +
                                    '<td>' + (p.description || '<span class="text-muted">-</span>') + '</td>' +
                                    '<td class="text-right">' + qty + '</td>' +
                                    '<td class="text-right">' + price + '</td>' +
                                    '<td class="text-right"><strong>' + line.toLocaleString() + ' VNĐ</strong></td>' +
                                '</tr>';
                            });
                            tbody.html(rows);
                        } else {
                            tbody.html('<tr><td colspan="6" class="text-center text-danger">Không tải được danh sách sản phẩm</td></tr>');
                        }
                    }, 'json').fail(function() {
                        $('#contractDetailProductsBody').html('<tr><td colspan="6" class="text-center text-danger">Lỗi kết nối khi tải sản phẩm</td></tr>');
                    });

                    $('#contractDetailModal').modal('show');
                } else {
                    showAlert(resp.message, 'danger');
                }
            }, 'json');
        }

        function editContract(id) {
            // Kiểm tra xem có đang xem hợp đồng đã bị xóa không
            var currentStatus = '<%= request.getParameter("status") %>';
            if (currentStatus === 'deleted') {
                showAlert('Không thể chỉnh sửa hợp đồng đã bị xóa. Vui lòng khôi phục trước.', 'warning');
                return;
            }
            
            $.get('api/contracts', { action: 'get', id: id }, function(resp) {
                if (resp.success) {
                    var c = resp.data;
                    currentEditingId = c.id;
                    $('#contractId').val(c.id);
                    $('#contractNumber').val(c.contractNumber);
                    $('#customerId').val(c.customerId);
                    $('#contractType').val(c.contractType || '');
                    $('#title').val(c.title || '');
                    $('#startDate').val(formatDateInput(c.startDate));
                    $('#endDate').val(formatDateInput(c.endDate));
                    $('#signedDate').val(formatDateInput(c.signedDate));
                    $('#contractValue').val(c.contractValue || '');
                    $('#status').val(c.status || 'draft');
                    $('#terms').val(c.terms || '');
                    $('#contractModalLabel').text('Chỉnh sửa hợp đồng');
                    
                    // Load sản phẩm của hợp đồng
                    loadContractProducts(id);
                    
                    // Ẩn form sản phẩm khi mở modal
                    hideAddProductForm();
                    
                    // Không tự động cập nhật giá trị hợp đồng khi đang sửa
                    isEditingMode = true;
                    
                    $('#contractModal').modal('show');
                } else {
                    showAlert(resp.message, 'danger');
                }
            }, 'json');
        }

        function loadContractProducts(contractId) {
            $.get('api/contract-items', { contractId: contractId }, function(resp) {
                if (resp.success) {
                    contractProducts = resp.data || [];
                    renderContractProducts();
                }
            }, 'json');
        }

        function renderContractProducts() {
            var tbody = $('#contractProductsTableBody');
            var noProductsRow = $('#noProductsRow');
            
            if (contractProducts.length === 0) {
                tbody.html('<tr id="noProductsRow"><td colspan="9" class="text-center text-muted"><i class="fa fa-info-circle"></i> Chưa có sản phẩm nào. Nhấn "Thêm sản phẩm" để bắt đầu.</td></tr>');
                updateTotalValue();
                return;
            }
            
            var rows = '';
            var totalValue = 0;
            
            contractProducts.forEach(function(product, index) {
                var lineTotal = product.quantity && product.unitPrice ? 
                    (parseFloat(product.quantity) * parseFloat(product.unitPrice)) : 0;
                totalValue += lineTotal;
                
                rows += '<tr>' +
                    '<td class="text-center">' + (index + 1) + '</td>' +
                    '<td class="text-center">' + product.productId + '</td>' +
                    '<td>' + (product.description || '<span class="text-muted">-</span>') + '</td>' +
                    '<td class="text-right">' + (product.quantity ? parseFloat(product.quantity).toLocaleString() : '0') + '</td>' +
                    '<td class="text-right">' + (product.unitPrice ? parseFloat(product.unitPrice).toLocaleString() + ' VNĐ' : '0 VNĐ') + '</td>' +
                    '<td class="text-right"><strong>' + lineTotal.toLocaleString() + ' VNĐ</strong></td>' +
                    '<td class="text-center">' + (product.warrantyMonths ? product.warrantyMonths + ' tháng' : '<span class="text-muted">-</span>') + '</td>' +
                    '<td>' + (product.notes || '<span class="text-muted">-</span>') + '</td>' +
                    '<td class="text-center">' +
                        '<button class="btn btn-warning btn-xs" onclick="editProductFromContract(' + index + ')" title="Sửa">' +
                        '<i class="fa fa-edit"></i></button> ' +
                        '<button class="btn btn-danger btn-xs" onclick="removeProductFromContract(' + index + ')" title="Xóa">' +
                        '<i class="fa fa-trash"></i></button>' +
                    '</td>' +
                '</tr>';
            });
            
            tbody.html(rows);
            updateTotalValue(totalValue);
        }

        // Hiển thị form thêm sản phẩm
        function showAddProductForm() {
            $('#productFormContainer').show();
            $('#productFormTitle').text('Thêm sản phẩm mới');
            $('#editingProductIndex').val('');
            clearProductForm();
            loadProducts(); // Load danh sách sản phẩm
        }
        
        // Ẩn form thêm sản phẩm
        function hideAddProductForm() {
            $('#productFormContainer').hide();
            clearProductForm();
        }
        
        // Xóa form sản phẩm
        function clearProductForm() {
            $('#newProductId').val('');
            $('#newDescription').val('');
            $('#newQuantity').val('');
            $('#newUnitPrice').val('');
            $('#newWarrantyMonths').val('');
            $('#newNotes').val('');
            $('#newLineTotal').val('');
        }
        
        // Sửa sản phẩm
        function editProductFromContract(index) {
            var product = contractProducts[index];
            
            // Load danh sách sản phẩm trước
            loadProducts();
            
            // Sau khi load xong, set giá trị
            setTimeout(function() {
                $('#newProductId').val(product.productId);
                $('#newDescription').val(product.description || '');
                $('#newQuantity').val(product.quantity);
                $('#newUnitPrice').val(parseFloat(product.unitPrice).toLocaleString());
                $('#newWarrantyMonths').val(product.warrantyMonths || '');
                $('#newNotes').val(product.notes || '');
                $('#editingProductIndex').val(index);
                $('#productFormTitle').text('Sửa sản phẩm');
                $('#productFormContainer').show();
                
                // Tính lại thành tiền
                calculateLineTotal();
            }, 100);
        }

        function addProductToContract() {
            var productId = $('#newProductId').val();
            var description = $('#newDescription').val();
            var quantity = $('#newQuantity').val();
            var unitPrice = $('#newUnitPrice').val().replace(/,/g, ''); // Loại bỏ dấu phẩy
            var warrantyMonths = $('#newWarrantyMonths').val();
            var notes = $('#newNotes').val();
            var editingIndex = $('#editingProductIndex').val();

            if (!productId || !quantity || !unitPrice) {
                showAlert('Vui lòng chọn sản phẩm và nhập số lượng', 'warning');
                return;
            }

            // Kiểm tra tồn kho trước khi thêm vào danh sách tạm
            var selectedOption = $('#newProductId').find('option:selected');
            var stock = parseFloat(selectedOption.data('quantity')) || 0;
            if (stock <= 0) {
                showAlert('Sản phẩm đã hết hàng. Không thể thêm.', 'danger');
                return;
            }
            if (parseFloat(quantity) > stock) {
                showAlert('Số lượng vượt quá tồn kho (' + stock + ').', 'danger');
                return;
            }

            var product = {
                productId: parseInt(productId),
                description: description,
                quantity: parseFloat(quantity),
                unitPrice: parseFloat(unitPrice),
                warrantyMonths: warrantyMonths ? parseInt(warrantyMonths) : null,
                notes: notes
            };

            if (editingIndex !== '') {
                // Sửa sản phẩm
                contractProducts[parseInt(editingIndex)] = product;
            } else {
                // Thêm sản phẩm mới
                contractProducts.push(product);
            }

            renderContractProducts();
            hideAddProductForm();
        }

        function removeProductFromContract(index) {
            if (confirm('Bạn có chắc chắn muốn xóa sản phẩm này?')) {
                contractProducts.splice(index, 1);
                renderContractProducts();
            }
        }
        
        // Cập nhật tổng giá trị
        function updateTotalValue(total) {
            total = total || 0;
            $('#totalContractValue').text(total.toLocaleString() + ' VNĐ');
            
            // Tự động cập nhật giá trị hợp đồng chỉ khi thêm mới
            if (!isEditingMode) {
                $('#contractValue').val(total);
            }
        }

        function saveContract() {
            // Clear previous errors
            clearValidationErrors();
            
            var data = {
                action: currentEditingId ? 'update' : 'add',
                id: $('#contractId').val(),
                contractNumber: $('#contractNumber').val(),
                customerId: $('#customerId').val(),
                contractType: $('#contractType').val(),
                title: $('#title').val(),
                startDate: $('#startDate').val(),
                endDate: $('#endDate').val(),
                contractValue: $('#contractValue').val(),
                status: $('#status').val(),
                terms: $('#terms').val(),
                products: contractProducts // Gửi kèm danh sách sản phẩm
            };

            // Validation
            var isValid = true;
            
            // Kiểm tra trường bắt buộc
            if (!data.contractNumber || data.contractNumber.trim() === '') {
                showFieldError('contractNumber', 'Số hợp đồng không được để trống');
                isValid = false;
            }
            
            if (!data.customerId || data.customerId === '') {
                showFieldError('customerId', 'Vui lòng chọn khách hàng');
                isValid = false;
            }
            
            // Kiểm tra ngày
            if (data.startDate && data.endDate) {
                var startDate = new Date(data.startDate);
                var endDate = new Date(data.endDate);
                if (endDate <= startDate) {
                    showFieldError('endDate', 'Ngày kết thúc phải sau ngày bắt đầu');
                    isValid = false;
                }
            }
            
            // Kiểm tra giá trị hợp đồng
            if (data.contractValue && data.contractValue !== '') {
                var value = parseFloat(data.contractValue);
                if (isNaN(value) || value < 0) {
                    showFieldError('contractValue', 'Giá trị hợp đồng phải là số dương');
                    isValid = false;
                }
            }
            
            if (!isValid) {
                showModalAlert('Vui lòng kiểm tra lại các thông tin đã nhập', 'warning');
                return;
            }

            // Backend expects products as JSON string
            data.products = JSON.stringify(contractProducts);
            $.post('api/contracts', data, function(resp) {
                if (resp.success) {
                    showModalAlert(resp.message, 'success');
                    // Đợi 1 giây để người dùng thấy thông báo thành công
                    setTimeout(function() {
                        $('#contractModal').modal('hide');
                        contractProducts = []; // Reset danh sách sản phẩm
                        location.reload();
                    }, 1000);
                } else {
                    // Hiển thị lỗi cụ thể từ server
                    if (resp.message && (resp.message.includes('trùng') || resp.message.includes('tồn tại'))) {
                        showFieldError('contractNumber', resp.message);
                        showModalAlert(resp.message, 'danger');
                    } else {
                        showModalAlert(resp.message, 'danger');
                    }
                }
            }, 'json');
        }
        
        function clearValidationErrors() {
            $('.help-block.text-danger').hide();
            $('.form-control').removeClass('has-error');
            hideModalAlert(); // Ẩn thông báo modal
        }
        
        function showFieldError(fieldId, message) {
            $('#' + fieldId + 'Error').text(message).show();
            $('#' + fieldId).addClass('has-error');
        }

        function deleteContract(id) {
            // Kiểm tra xem có đang xem hợp đồng đã bị xóa không
            var currentStatus = '<%= request.getParameter("status") %>';
            if (currentStatus === 'deleted') {
                showAlert('Hợp đồng này đã bị xóa. Sử dụng nút "Xóa vĩnh viễn" để xóa hoàn toàn.', 'warning');
                return;
            }
            
            if (!confirm('Bạn có chắc chắn muốn chuyển hợp đồng này vào thùng rác?')) return;
            $.post('api/contracts', { action: 'delete', id: id }, function(resp) {
                if (resp.success) {
                    showAlert(resp.message, 'success');
                    location.reload();
                } else {
                    showAlert(resp.message, 'danger');
                }
            }, 'json');
        }

        function showDeletedContracts() {
            console.log('Opening deleted contracts modal');
            $('#deletedContractsModal').modal('show');
            
            // Test trực tiếp với AJAX đơn giản
            $.ajax({
                url: 'api/contracts',
                type: 'GET',
                data: { action: 'deleted', page: 1, pageSize: 10 },
                dataType: 'json',
                success: function(resp) {
                    console.log('Direct AJAX test - Response:', resp);
                    console.log('Direct test - Response keys:', Object.keys(resp));
                    console.log('Direct test - Response.data:', resp.data);
                    console.log('Direct test - Response.data type:', typeof resp.data);
                    
                    // Kiểm tra cấu trúc response
                    var dataArray = resp.data;
                    if (dataArray && dataArray.data && Array.isArray(dataArray.data)) {
                        dataArray = dataArray.data;
                        console.log('Direct test - Using nested data, found ' + dataArray.length + ' contracts');
                    } else if (Array.isArray(dataArray)) {
                        console.log('Direct test - Using direct data, found ' + dataArray.length + ' contracts');
                    } else {
                        console.log('Direct test - no data or error');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Direct AJAX test failed:', status, error);
                    console.error('Response text:', xhr.responseText);
                }
            });
            
            loadDeletedContracts();
        }

        // Biến toàn cục cho phân trang thùng rác
        var deletedContractsCurrentPage = 1;
        var deletedContractsTotalPages = 1;
        var deletedContractsTotalRecords = 0;

        function loadDeletedContracts(page) {
            if (page) deletedContractsCurrentPage = page;
            
            var search = $('#deletedSearch').val();
            var sortBy = $('#deletedSortBy').val();
            var sortDir = $('#deletedSortDir').val();
            var pageSize = $('#deletedPageSize').val();
            
            var params = {
                action: 'deleted',
                page: deletedContractsCurrentPage,
                pageSize: pageSize,
                search: search,
                sortBy: sortBy,
                sortDir: sortDir
            };
            
            console.log('Loading deleted contracts with params:', params);
            
            $.get('api/contracts', params, function(resp) {
                console.log('Response from server:', resp);
                console.log('Response type:', typeof resp);
                console.log('Response success:', resp.success);
                console.log('Response data:', resp.data);
                console.log('Response data length:', resp.data ? resp.data.length : 'undefined');
                
                // Debug: Kiểm tra tất cả các thuộc tính của response
                console.log('All response keys:', Object.keys(resp));
                console.log('Response.data type:', typeof resp.data);
                console.log('Response.data value:', resp.data);
                
                // Test: Kiểm tra xem có phải là string không
                if (typeof resp === 'string') {
                    console.log('Response is string, trying to parse JSON');
                    try {
                        resp = JSON.parse(resp);
                        console.log('Parsed response:', resp);
                    } catch (e) {
                        console.error('Failed to parse JSON:', e);
                    }
                }
                
                if (resp && resp.success) {
                    var tbody = $('#deletedContractsTableBody');
                    
                    // Kiểm tra cấu trúc response - có thể data nằm trong resp.data.data
                    var dataArray = resp.data;
                    if (dataArray && dataArray.data && Array.isArray(dataArray.data)) {
                        // Trường hợp: resp.data.data là mảng
                        dataArray = dataArray.data;
                        console.log('Using nested data array, found ' + dataArray.length + ' contracts');
                    } else if (Array.isArray(dataArray)) {
                        // Trường hợp: resp.data là mảng trực tiếp
                        console.log('Using direct data array, found ' + dataArray.length + ' contracts');
                    }
                    
                    if (Array.isArray(dataArray) && dataArray.length > 0) {
                        console.log('Found ' + dataArray.length + ' deleted contracts');
                        var rows = '';
                        dataArray.forEach(function(contract) {
                            console.log('Processing contract:', contract);
                            var deletedAt = contract.deletedAt || contract.updatedAt || '-';
                            var deletedByName = contract.deletedByName || 'Không xác định';
                            
                            // Format thời gian xóa theo múi giờ Việt Nam
                            var formattedDeletedAt = formatVietnamTime(deletedAt);
                            
                            rows += '<tr>' +
                                '<td>' + contract.id + '</td>' +
                                '<td>' + contract.contractNumber + '</td>' +
                                '<td>' + contract.customerId + '</td>' +
                                '<td>' + (contract.title || '-') + '</td>' +
                                '<td>' + deletedByName + '</td>' +
                                '<td>' + formattedDeletedAt + '</td>' +
                                '<td>' +
                                    '<button class="btn btn-success btn-xs" onclick="restoreContract(' + contract.id + ')" title="Khôi phục">' +
                                    '<i class="fa fa-undo"></i> Khôi phục</button> ' +
                                    '<button class="btn btn-danger btn-xs" onclick="permanentlyDeleteContract(' + contract.id + ')" title="Xóa vĩnh viễn">' +
                                    '<i class="fa fa-trash"></i> Xóa vĩnh viễn</button>' +
                                '</td>' +
                            '</tr>';
                        });
                        tbody.html(rows);
                        
                        // Cập nhật thông tin phân trang
                        deletedContractsTotalPages = resp.data.totalPages || resp.totalPages || 1;
                        deletedContractsTotalRecords = resp.data.totalRecords || resp.totalRecords || 0;
                        updateDeletedPaginationInfo();
                        renderDeletedPagination();
                    } else {
                        console.log('No deleted contracts found - data is empty or not an array');
                        console.log('Data type:', typeof dataArray);
                        console.log('Data value:', dataArray);
                        tbody.html('<tr><td colspan="7" class="text-center text-muted"><i class="fa fa-info-circle"></i> Thùng rác trống</td></tr>');
                        deletedContractsTotalPages = 1;
                        deletedContractsTotalRecords = 0;
                        updateDeletedPaginationInfo();
                        renderDeletedPagination();
                    }
                } else {
                    console.error('Server error:', resp);
                    $('#deletedContractsTableBody').html('<tr><td colspan="7" class="text-center text-danger">Lỗi: ' + (resp.message || 'Không thể tải dữ liệu') + '</td></tr>');
                }
            }, 'json')
            .fail(function(xhr, status, error) {
                console.error('AJAX error:', status, error);
                console.error('XHR response:', xhr.responseText);
                $('#deletedContractsTableBody').html('<tr><td colspan="7" class="text-center text-danger">Lỗi kết nối: ' + error + '</td></tr>');
            });
        }

        function updateDeletedPaginationInfo() {
            var pageSize = parseInt($('#deletedPageSize').val());
            var start = (deletedContractsCurrentPage - 1) * pageSize + 1;
            var end = Math.min(deletedContractsCurrentPage * pageSize, deletedContractsTotalRecords);
            
            if (deletedContractsTotalRecords === 0) {
                start = 0;
                end = 0;
            }
            
            $('#deletedPaginationInfo').text('Hiển thị ' + start + ' - ' + end + ' của ' + deletedContractsTotalRecords + ' bản ghi');
        }

        function renderDeletedPagination() {
            var pagination = $('#deletedPagination');
            pagination.empty();
            
            // Luôn hiển thị nút Previous
            var prevDisabled = deletedContractsCurrentPage <= 1 ? 'disabled' : '';
            pagination.append('<li class="' + prevDisabled + '"><a href="#" onclick="loadDeletedContracts(' + (deletedContractsCurrentPage - 1) + '); return false;">&laquo;</a></li>');
            
            // Nếu chỉ có 1 trang, vẫn hiển thị nút trang đó
            if (deletedContractsTotalPages <= 1) {
                pagination.append('<li class="active"><a href="#" onclick="loadDeletedContracts(1); return false;">1</a></li>');
            } else {
                // Các nút trang
                var startPage = Math.max(1, deletedContractsCurrentPage - 2);
                var endPage = Math.min(deletedContractsTotalPages, deletedContractsCurrentPage + 2);
                
                if (startPage > 1) {
                    pagination.append('<li><a href="#" onclick="loadDeletedContracts(1); return false;">1</a></li>');
                    if (startPage > 2) {
                        pagination.append('<li class="disabled"><span>...</span></li>');
                    }
                }
                
                for (var i = startPage; i <= endPage; i++) {
                    var active = i === deletedContractsCurrentPage ? 'active' : '';
                    pagination.append('<li class="' + active + '"><a href="#" onclick="loadDeletedContracts(' + i + '); return false;">' + i + '</a></li>');
                }
                
                if (endPage < deletedContractsTotalPages) {
                    if (endPage < deletedContractsTotalPages - 1) {
                        pagination.append('<li class="disabled"><span>...</span></li>');
                    }
                    pagination.append('<li><a href="#" onclick="loadDeletedContracts(' + deletedContractsTotalPages + '); return false;">' + deletedContractsTotalPages + '</a></li>');
                }
            }
            
            // Luôn hiển thị nút Next
            var nextDisabled = deletedContractsCurrentPage >= deletedContractsTotalPages ? 'disabled' : '';
            pagination.append('<li class="' + nextDisabled + '"><a href="#" onclick="loadDeletedContracts(' + (deletedContractsCurrentPage + 1) + '); return false;">&raquo;</a></li>');
        }

        function restoreContract(id) {
            $('#restoreContractId').val(id);
            $('#restoreStatusModal').modal('show');
        }

        function confirmRestore() {
            var id = $('#restoreContractId').val();
            var status = $('#restoreStatus').val();
            
            $.post('api/contracts', { action: 'restore', id: id, status: status }, function(resp) {
                if (resp.success) {
                    showAlert(resp.message, 'success');
                    $('#restoreStatusModal').modal('hide');
                    loadDeletedContracts(); // Reload danh sách thùng rác
                    location.reload(); // Reload trang chính để hiển thị hợp đồng đã khôi phục
                } else {
                    showAlert(resp.message, 'danger');
                }
            }, 'json');
        }

        function permanentlyDeleteContract(id) {
            if (!confirm('Bạn có chắc chắn muốn xóa vĩnh viễn hợp đồng này? Hành động này không thể hoàn tác!')) return;
            $.post('api/contracts', { action: 'permanent_delete', id: id }, function(resp) {
                if (resp.success) {
                    showAlert(resp.message, 'success');
                    loadDeletedContracts(); // Reload danh sách thùng rác
                    // Reload trang chính sau khi xóa vĩnh viễn
                    setTimeout(function() {
                        location.reload();
                    }, 1000);
                } else {
                    showAlert(resp.message, 'danger');
                }
            }, 'json');
        }


        function showAlert(message, type) {
            // Kiểm tra xem có đang trong modal không
            if ($('#contractModal').hasClass('in') || $('#contractModal').is(':visible')) {
                // Hiển thị trong modal
                showModalAlert(message, type);
            } else {
                // Hiển thị ở trang chính
                var alertClass = 'alert-' + type;
                var html = '<div class="alert ' + alertClass + ' alert-dismissible" role="alert">' +
                           '<button type="button" class="close" data-dismiss="alert" aria-label="Close">' +
                           '<span aria-hidden="true">&times;</span></button>' + message + '</div>';
                $('.content').prepend(html);
                setTimeout(function(){ $('.alert').fadeOut(400, function(){ $(this).remove(); }); }, 4000);
            }
        }
        
        function showModalAlert(message, type) {
            var alertClass = 'alert-' + type;
            var iconClass = type === 'success' ? 'fa-check-circle' : 
                           type === 'warning' ? 'fa-exclamation-triangle' : 
                           type === 'info' ? 'fa-info-circle' : 'fa-exclamation-triangle';
            
            $('#contractErrorAlert')
                .removeClass('alert-success alert-warning alert-info alert-danger')
                .addClass(alertClass)
                .show();
            
            $('#contractErrorText').html('<i class="fa ' + iconClass + '"></i> ' + message);
            
            // Tự động ẩn sau 5 giây (trừ khi là success thì ẩn sau 2 giây)
            var hideDelay = type === 'success' ? 2000 : 5000;
            setTimeout(function() {
                $('#contractErrorAlert').fadeOut(400);
            }, hideDelay);
        }
        
        function hideModalAlert() {
            $('#contractErrorAlert').hide();
        }

        function formatDateInput(value) {
            if (!value) return '';
            try {
                var d = new Date(value);
                if (isNaN(d.getTime())) return '';
                var m = (d.getMonth() + 1).toString().padStart(2, '0');
                var day = d.getDate().toString().padStart(2, '0');
                return d.getFullYear() + '-' + m + '-' + day;
            } catch (e) { return ''; }
        }

        // Hàm format thời gian theo múi giờ Việt Nam
        function formatVietnamTime(dateString) {
            if (!dateString || dateString === '-') return '-';
            try {
                var date = new Date(dateString);
                if (isNaN(date.getTime())) return dateString;
                
                // Database lưu theo UTC, cần trừ đi 7 tiếng để có múi giờ Việt Nam
                var vietnamTime = new Date(date.getTime() - (7 * 60 * 60 * 1000));
                return vietnamTime.toLocaleString('vi-VN', {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit'
                });
            } catch (e) {
                console.error('Error formatting Vietnam time:', e);
                return dateString;
            }
        }

        // Reset form when modal is closed
        $('#contractModal').on('hidden.bs.modal', function() {
            document.getElementById('contractForm').reset();
            currentEditingId = null;
            contractProducts = []; // Reset danh sách sản phẩm
            isEditingMode = false; // Reset về chế độ thêm mới
            $('#contractModalLabel').text('Thêm hợp đồng mới');
            $('#contractProductsTableBody').html('');
            hideAddProductForm(); // Ẩn form sản phẩm
            clearValidationErrors(); // Clear validation errors
        });
        
        // Ẩn form sản phẩm khi mở modal thêm mới
        $('#contractModal').on('show.bs.modal', function() {
            hideAddProductForm();
            isEditingMode = false; // Reset về chế độ thêm mới
            loadProducts(); // Load danh sách sản phẩm khi mở modal
            clearValidationErrors(); // Clear validation errors
        });
        
        // Real-time validation
        $(document).on('blur', '#contractNumber', function() {
            var value = $(this).val().trim();
            if (value === '') {
                showFieldError('contractNumber', 'Số hợp đồng không được để trống');
            } else {
                // Kiểm tra trùng lặp số hợp đồng
                checkContractNumberExists(value);
            }
        });
        
        function checkContractNumberExists(contractNumber) {
            if (!contractNumber || contractNumber.trim() === '') return;
            
            $.get('api/contracts', { action: 'check_contract_number', contractNumber: contractNumber }, function(resp) {
                if (resp.exists) {
                    showFieldError('contractNumber', 'Số hợp đồng "' + contractNumber + '" đã tồn tại. Vui lòng chọn số khác.');
                } else if (resp.existsInTrash) {
                    showFieldError('contractNumber', 'Số hợp đồng "' + contractNumber + '" đã tồn tại trong thùng rác. Vui lòng chọn số khác hoặc khôi phục hợp đồng cũ.');
                } else {
                    $('#contractNumberError').hide();
                    $('#contractNumber').removeClass('has-error');
                }
            }, 'json').fail(function() {
                // Nếu không kiểm tra được, ẩn lỗi
                $('#contractNumberError').hide();
                $('#contractNumber').removeClass('has-error');
            });
        }
        
        $(document).on('change', '#customerId', function() {
            var value = $(this).val();
            if (value === '') {
                showFieldError('customerId', 'Vui lòng chọn khách hàng');
            } else {
                $('#customerIdError').hide();
                $(this).removeClass('has-error');
            }
        });
        
        $(document).on('blur', '#contractValue', function() {
            var value = $(this).val();
            if (value !== '') {
                var numValue = parseFloat(value);
                if (isNaN(numValue) || numValue < 0) {
                    showFieldError('contractValue', 'Giá trị hợp đồng phải là số dương');
                } else {
                    $('#contractValueError').hide();
                    $(this).removeClass('has-error');
                }
            }
        });
        
        $(document).on('change', '#startDate, #endDate', function() {
            var startDate = $('#startDate').val();
            var endDate = $('#endDate').val();
            
            if (startDate && endDate) {
                var start = new Date(startDate);
                var end = new Date(endDate);
                if (end <= start) {
                    showFieldError('endDate', 'Ngày kết thúc phải sau ngày bắt đầu');
                } else {
                    $('#endDateError').hide();
                    $('#endDate').removeClass('has-error');
                }
            }
        });

        // Event handler cho dropdown sản phẩm
        $(document).on('change', '#newProductId', function() {
            var selectedOption = $(this).find('option:selected');
            var description = selectedOption.data('description') || '';
            var unitPrice = selectedOption.data('unitprice') || 0;
            var warranty = selectedOption.data('warranty');
            var stock = parseFloat(selectedOption.data('quantity')) || 0;

            $('#newDescription').val(description);
            $('#newUnitPrice').val(parseFloat(unitPrice).toLocaleString());
            if (warranty !== undefined && warranty !== null && warranty !== '') {
                $('#newWarrantyMonths').val(warranty);
            } else {
                $('#newWarrantyMonths').val('');
            }
            $('#stockInfo').text('Tồn kho hiện tại: ' + stock);

            // Reset quantity if it exceeds stock
            var currentQty = parseFloat($('#newQuantity').val());
            if (!isNaN(currentQty) && currentQty > stock) {
                $('#newQuantity').val(stock);
            }

            // Tính thành tiền
            calculateLineTotal();
        });

        // Event handler cho số lượng
        $(document).on('input', '#newQuantity', function() {
            var selectedOption = $('#newProductId').find('option:selected');
            var stock = parseFloat(selectedOption.data('quantity')) || 0;
            var qty = parseFloat($(this).val()) || 0;
            if (qty > stock) {
                $(this).val(stock);
                showAlert('Số lượng vượt quá tồn kho (' + stock + '). Đã điều chỉnh về mức tối đa.', 'warning');
            }
            if (stock <= 0) {
                $(this).val('');
                showAlert('Sản phẩm đã hết hàng. Không thể thêm.', 'danger');
            }
            calculateLineTotal();
        });

        // Tính thành tiền
        function calculateLineTotal() {
            var quantity = parseFloat($('#newQuantity').val()) || 0;
            var unitPrice = parseFloat($('#newUnitPrice').val().replace(/,/g, '')) || 0;
            var lineTotal = quantity * unitPrice;
            $('#newLineTotal').val(lineTotal.toLocaleString());
        }

        // Cập nhật giá trị hợp đồng từ tổng sản phẩm
        function updateContractValueFromProducts() {
            var total = 0;
            contractProducts.forEach(function(product) {
                total += (product.quantity * product.unitPrice);
            });
            $('#contractValue').val(total);
            showAlert('Đã cập nhật giá trị hợp đồng: ' + total.toLocaleString() + ' VNĐ', 'success');
        }

        // Event handlers cho modal thùng rác
        $(document).on('change', '#deletedPageSize', function() {
            deletedContractsCurrentPage = 1;
            loadDeletedContracts();
        });

        $(document).on('change', '#deletedSortBy, #deletedSortDir', function() {
            deletedContractsCurrentPage = 1;
            loadDeletedContracts();
        });

        $(document).on('keypress', '#deletedSearch', function(e) {
            if (e.which === 13) { // Enter key
                deletedContractsCurrentPage = 1;
                loadDeletedContracts();
            }
        });
    </script>
</body>
</html>


