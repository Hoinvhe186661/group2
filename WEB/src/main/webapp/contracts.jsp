<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
</head>
<body class="skin-black">
    <header class="header">
        <a href="admin.jsp" class="logo">
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
                            <span>Admin <i class="caret"></i></span>
                        </a>
                        <ul class="dropdown-menu dropdown-custom dropdown-menu-right">
                            <li class="dropdown-header text-center">Tài khoản</li>
                            <li>
                                <a href="#"><i class="fa fa-user fa-fw pull-right"></i> Hồ sơ</a>
                                <a data-toggle="modal" href="#modal-user-settings"><i class="fa fa-cog fa-fw pull-right"></i> Cài đặt</a>
                            </li>
                            <li class="divider"></li>
                            <li>
                                <a href="../index.jsp"><i class="fa fa-ban fa-fw pull-right"></i> Đăng xuất</a>
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
                        <a href="admin.jsp"><i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span></a>
                    </li>
                    <li>
                        <a href="product"><i class="fa fa-shopping-cart"></i> <span>Quản lý sản phẩm</span></a>
                    </li>
                    <li>
                        <a href="orders.jsp"><i class="fa fa-file-text-o"></i> <span>Quản lý đơn hàng</span></a>
                    </li>
                    <li class="active">
                        <a href="contracts.jsp"><i class="fa fa-file-text"></i> <span>Quản lý hợp đồng</span></a>
                    </li>
                    <li>
                        <a href="customers.jsp"><i class="fa fa-users"></i> <span>Quản lý khách hàng</span></a>
                    </li>
                    <li>
                        <a href="users.jsp"><i class="fa fa-user-secret"></i> <span>Quản lý người dùng</span></a>
                    </li>
                    <li>
                        <a href="reports.jsp"><i class="fa fa-bar-chart"></i> <span>Báo cáo</span></a>
                    </li>
                    <li>
                        <a href="settings.jsp"><i class="fa fa-cog"></i> <span>Cài đặt</span></a>
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
                                    <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#contractModal">
                                        <i class="fa fa-plus"></i> Thêm hợp đồng mới
                                    </button>
                                </div>
                            </header>
                            <div class="panel-body table-responsive">
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
                                            java.util.List<com.hlgenerator.model.Contract> contracts = dao.getAllContracts();
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
                                                <button class="btn btn-warning btn-xs" onclick="editContract('<%= c.getId() %>')"><i class="fa fa-edit"></i> Sửa</button>
                                                <button class="btn btn-danger btn-xs" onclick="deleteContract('<%= c.getId() %>')"><i class="fa fa-trash"></i> Xóa</button>
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
                    <form id="contractForm">
                        <input type="hidden" id="contractId">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="contractNumber">Số hợp đồng</label>
                                    <input type="text" class="form-control" id="contractNumber" required>
                                </div>
                                <div class="form-group">
                                    <label for="customerId">Khách hàng</label>
                                    <select class="form-control" id="customerId" required>
                                        <option value="">Chọn khách hàng...</option>
                                    </select>
                                    <small class="text-muted">Hoặc tìm kiếm: <input type="text" class="form-control" id="customerSearch" placeholder="Tìm theo tên công ty, mã khách hàng..." style="margin-top:5px;"></small>
                                </div>
                                <div class="form-group">
                                    <label for="contractType">Loại hợp đồng</label>
                                    <input type="text" class="form-control" id="contractType">
                                </div>
                                <div class="form-group">
                                    <label for="title">Tiêu đề</label>
                                    <input type="text" class="form-control" id="title">
                                </div>
                                <div class="form-group">
                                    <label for="terms">Điều khoản</label>
                                    <textarea class="form-control" id="terms" rows="4"></textarea>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="startDate">Ngày bắt đầu</label>
                                    <input type="date" class="form-control" id="startDate">
                                </div>
                                <div class="form-group">
                                    <label for="endDate">Ngày kết thúc</label>
                                    <input type="date" class="form-control" id="endDate">
                                </div>
                                <div class="form-group">
                                    <label for="signedDate">Ngày ký</label>
                                    <input type="date" class="form-control" id="signedDate">
                                </div>
                                <div class="form-group">
                                    <label for="contractValue">Giá trị hợp đồng</label>
                                    <div class="input-group">
                                        <input type="number" class="form-control" id="contractValue" step="0.01" min="0">
                                        <span class="input-group-btn">
                                            <button class="btn btn-info" type="button" onclick="updateContractValueFromProducts()" title="Tự động cập nhật từ tổng sản phẩm">
                                                <i class="fa fa-calculator"></i> Tự động
                                            </button>
                                        </span>
                                    </div>
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
                                                <input type="number" min="0" class="form-control" id="newWarrantyMonths" placeholder="12" style="height: 40px; font-size: 14px;">
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
                "paging": true,
                "pageLength": 10,
                "searching": true,
                "ordering": true,
                "info": true,
                "autoWidth": false,
                "responsive": true,
                "order": [[0, "desc"]],
                "columnDefs": [{ "targets": [9], "orderable": false, "searchable": false }]
            });
            
            // Load danh sách khách hàng
            loadCustomers();
            
            // Tìm kiếm khách hàng
            $('#customerSearch').on('input', function() {
                var searchTerm = $(this).val().toLowerCase();
                console.log('Searching for:', searchTerm);
                
                $('#customerId option').each(function() {
                    var $option = $(this);
                    var text = $option.text().toLowerCase();
                    
                    if (searchTerm === '' || text.includes(searchTerm)) {
                        $option.show();
                    } else {
                        $option.hide();
                    }
                });
                
                // Nếu có kết quả tìm kiếm, chọn option đầu tiên
                var visibleOptions = $('#customerId option:visible:not([disabled])');
                if (visibleOptions.length > 1 && searchTerm !== '') {
                    // Không tự động chọn, chỉ hiển thị
                }
            });
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
                            options += '<option value="' + product.id + '" data-description="' + (product.description || '') + '" data-unitprice="' + product.unitPrice + '">' + 
                                      product.productCode + ' - ' + product.productName + 
                                      ' (' + parseFloat(product.unitPrice).toLocaleString() + ' VNĐ)</option>';
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
                        '<p><strong>Điều khoản:</strong><br>' + (c.terms || '-') + '</p>';
                    $('#contractDetail').html(html);
                    $('#contractDetailModal').modal('show');
                } else {
                    showAlert(resp.message, 'danger');
                }
            }, 'json');
        }

        function editContract(id) {
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

            if (!data.contractNumber || !data.customerId) {
                showAlert('Vui lòng nhập Số hợp đồng và chọn Khách hàng', 'warning');
                return;
            }

            $.post('api/contracts', data, function(resp) {
                if (resp.success) {
                    showAlert(resp.message, 'success');
                    $('#contractModal').modal('hide');
                    contractProducts = []; // Reset danh sách sản phẩm
                    location.reload();
                } else {
                    showAlert(resp.message, 'danger');
                }
            }, 'json');
        }

        function deleteContract(id) {
            if (!confirm('Bạn có chắc chắn muốn xóa hợp đồng này?')) return;
            $.post('api/contracts', { action: 'delete', id: id }, function(resp) {
                if (resp.success) {
                    showAlert('Đã xóa hợp đồng', 'success');
                    location.reload();
                } else {
                    showAlert(resp.message, 'danger');
                }
            }, 'json');
        }


        function showAlert(message, type) {
            var alertClass = 'alert-' + type;
            var html = '<div class="alert ' + alertClass + ' alert-dismissible" role="alert">' +
                       '<button type="button" class="close" data-dismiss="alert" aria-label="Close">' +
                       '<span aria-hidden="true">&times;</span></button>' + message + '</div>';
            $('.content').prepend(html);
            setTimeout(function(){ $('.alert').fadeOut(400, function(){ $(this).remove(); }); }, 4000);
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

        // Reset form when modal is closed
        $('#contractModal').on('hidden.bs.modal', function() {
            document.getElementById('contractForm').reset();
            currentEditingId = null;
            contractProducts = []; // Reset danh sách sản phẩm
            isEditingMode = false; // Reset về chế độ thêm mới
            $('#contractModalLabel').text('Thêm hợp đồng mới');
            $('#contractProductsTableBody').html('');
            hideAddProductForm(); // Ẩn form sản phẩm
        });
        
        // Ẩn form sản phẩm khi mở modal thêm mới
        $('#contractModal').on('show.bs.modal', function() {
            hideAddProductForm();
            isEditingMode = false; // Reset về chế độ thêm mới
            loadProducts(); // Load danh sách sản phẩm khi mở modal
        });

        // Event handler cho dropdown sản phẩm
        $(document).on('change', '#newProductId', function() {
            var selectedOption = $(this).find('option:selected');
            var description = selectedOption.data('description') || '';
            var unitPrice = selectedOption.data('unitprice') || 0;
            
            $('#newDescription').val(description);
            $('#newUnitPrice').val(parseFloat(unitPrice).toLocaleString());
            
            // Tính thành tiền
            calculateLineTotal();
        });

        // Event handler cho số lượng
        $(document).on('input', '#newQuantity', function() {
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
    </script>
</body>
</html>


