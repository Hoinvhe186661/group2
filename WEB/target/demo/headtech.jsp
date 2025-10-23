<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Kiểm tra đăng nhập
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Kiểm tra quyền head_technician hoặc admin
    if (!"head_technician".equals(userRole) && !"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Kỹ Thuật | HL Generator</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <!-- bootstrap 3.0.2 -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- font Awesome -->
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Ionicons -->
    <link href="css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <!-- DATA TABLES -->
    <link href="css/datatables/dataTables.bootstrap.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="css/style.css" rel="stylesheet" type="text/css" />

    <style>
        .work-order-filters {
            background: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .filter-group {
            margin-bottom: 10px;
        }
        .badge-urgent { background-color: #d9534f !important; }
        .badge-high { background-color: #f0ad4e !important; }
        .badge-medium { background-color: #5bc0de !important; }
        .badge-low { background-color: #5cb85c !important; }
        
        .badge-pending { background-color: #f0ad4e !important; }
        .badge-in_progress { background-color: #5bc0de !important; }
        .badge-completed { background-color: #5cb85c !important; }
        .badge-cancelled { background-color: #777 !important; }
        
        .work-order-actions {
            white-space: nowrap;
        }
        .work-order-actions .btn {
            padding: 2px 8px;
            font-size: 12px;
            margin-right: 3px;
        }
        .modal-lg {
            width: 900px;
        }
        .task-item {
            border-left: 3px solid #3c8dbc;
            padding-left: 10px;
            margin-bottom: 10px;
        }
        .form-horizontal .control-label {
            text-align: left;
        }
        .stats-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        .stats-card h3 {
            margin: 0;
            font-size: 2.5em;
            font-weight: bold;
        }
        .stats-card p {
            margin: 5px 0 0 0;
            opacity: 0.9;
        }
    </style>
</head>
<body class="skin-black">
    <!-- header logo -->
    <header class="header">
        <a href="admin.jsp" class="logo">
            Quản Lý Kỹ Thuật
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
                                <a href="logout"><i class="fa fa-ban fa-fw pull-right"></i> Đăng xuất</a>
                            </li>
                        </ul>
                    </li>
                </ul>
            </div>
        </nav>
    </header>
    
    <div class="wrapper row-offcanvas row-offcanvas-left">
        <!-- Left side column -->
        <aside class="left-side sidebar-offcanvas">
            <section class="sidebar">
                <!-- Sidebar user panel -->
                <div class="user-panel">
                    <div class="pull-left image">
                        <img src="img/26115.jpg" class="img-circle" alt="User Image" />
                    </div>
                    <div class="pull-left info">
                        <p>Xin chào, <%= username %></p>
                        <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
                    </div>
                </div>
                
                <!-- sidebar menu -->
                <ul class="sidebar-menu">
                    <li>
                        <a href="admin.jsp">
                            <i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
                        </a>
                    </li>
                    <li class="active">
                        <a href="headtech.jsp">
                            <i class="fa fa-wrench"></i> <span>Quản lý kỹ thuật</span>
                        </a>
                    </li>
                    <li>
                        <a href="tech_support_management.jsp">
                            <i class="fa fa-ticket"></i> <span>Yêu cầu hỗ trợ kỹ thuật</span>
                        </a>
                    </li>
                    <li>
                        <a href="work_orders.jsp">
                            <i class="fa fa-file-text-o"></i> <span>Đơn hàng công việc</span>
                        </a>
                    </li>
                    <li>
                        <a href="product">
                            <i class="fa fa-shopping-cart"></i> <span>Danh sách sản phẩm</span>
                        </a>
                    </li>
                    <li>
                        <a href="customers">
                            <i class="fa fa-users"></i> <span>Danh sách khách hàng</span>
                        </a>
                    </li>
                    <li>
                        <a href="reports.jsp">
                            <i class="fa fa-bar-chart"></i> <span>Báo cáo kỹ thuật</span>
                        </a>
                    </li>
                </ul>
            </section>
        </aside>

        <aside class="right-side">
            <section class="content-header">
                <h1>
                    Quản Lý Kỹ Thuật
                    <small>Quản lý đơn hàng công việc và nhiệm vụ</small>
                </h1>
                <ol class="breadcrumb">
                    <li><a href="admin.jsp"><i class="fa fa-dashboard"></i> Trang chủ</a></li>
                    <li class="active">Quản lý kỹ thuật</li>
                </ol>
            </section>

            <!-- Main content -->
            <section class="content">
                <!-- Statistics Cards -->
                <div class="row">
                    <div class="col-md-3">
                        <div class="stats-card">
                            <h3 id="totalWorkOrders">0</h3>
                            <p>Tổng đơn hàng</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stats-card">
                            <h3 id="pendingWorkOrders">0</h3>
                            <p>Chờ xử lý</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stats-card">
                            <h3 id="inProgressWorkOrders">0</h3>
                            <p>Đang thực hiện</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stats-card">
                            <h3 id="completedWorkOrders">0</h3>
                            <p>Hoàn thành</p>
                        </div>
                    </div>
                </div>

                <!-- Filters -->
                <div class="row">
                    <div class="col-xs-12">
                        <div class="box">
                            <div class="box-header">
                                <h3 class="box-title">Bộ lọc</h3>
                            </div>
                            <div class="box-body">
                                <form class="form-inline" id="filterForm">
                                    <div class="form-group">
                                        <label>Trạng thái: </label>
                                        <select class="form-control input-sm" id="filterStatus" style="width: 150px;">
                                            <option value="">Tất cả</option>
                                            <option value="pending">Chờ xử lý</option>
                                            <option value="in_progress">Đang thực hiện</option>
                                            <option value="completed">Hoàn thành</option>
                                            <option value="cancelled">Đã hủy</option>
                                        </select>
                                    </div>
                                    
                                    <div class="form-group" style="margin-left: 10px;">
                                        <label>Độ ưu tiên: </label>
                                        <select class="form-control input-sm" id="filterPriority" style="width: 150px;">
                                            <option value="">Tất cả</option>
                                            <option value="urgent">Khẩn cấp</option>
                                            <option value="high">Cao</option>
                                            <option value="medium">Trung bình</option>
                                            <option value="low">Thấp</option>
                                        </select>
                                    </div>
                                    
                                    <div class="form-group" style="margin-left: 10px;">
                                        <label>Nhân viên: </label>
                                        <select class="form-control input-sm" id="filterAssignedTo" style="width: 150px;">
                                            <option value="">Tất cả</option>
                                            <option value="unassigned">Chưa phân công</option>
                                        </select>
                                    </div>
                                    
                                    <div class="form-group" style="margin-left: 10px;">
                                        <label>Tìm kiếm: </label>
                                        <input type="text" class="form-control input-sm" id="filterSearch" placeholder="Mã đơn hàng, tiêu đề..." style="width: 200px;">
                                    </div>
                                    
                                    <button type="button" class="btn btn-primary btn-sm" id="btnFilter" style="margin-left: 10px;">
                                        <i class="fa fa-filter"></i> Lọc
                                    </button>
                                    <button type="button" class="btn btn-default btn-sm" id="btnReset">
                                        <i class="fa fa-refresh"></i> Đặt lại
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Work Orders Table -->
                <div class="row">
                    <div class="col-xs-12">
                        <div class="box">
                            <div class="box-header">
                                <h3 class="box-title">Danh sách đơn hàng công việc</h3>
                                <div class="box-tools">
                                    <button type="button" class="btn btn-success btn-sm" onclick="location.reload()">
                                        <i class="fa fa-refresh"></i> Tải lại
                                    </button>
                                </div>
                            </div>
                            <div class="box-body table-responsive">
                                <table id="workOrdersTable" class="table table-bordered table-striped table-hover">
                                    <thead>
                                        <tr>
                                            <th style="width: 100px;">Mã đơn hàng</th>
                                            <th>Khách hàng</th>
                                            <th>Tiêu đề</th>
                                            <th style="width: 100px;">Độ ưu tiên</th>
                                            <th style="width: 100px;">Trạng thái</th>
                                            <th style="width: 100px;">Phân công</th>
                                            <th style="width: 120px;">Ngày tạo</th>
                                            <th style="width: 150px;">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="workOrdersTableBody">
                                        <tr>
                                            <td colspan="8" class="text-center">Đang tải dữ liệu...</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <div class="footer-main">
                Copyright &copy Hệ thống quản lý kỹ thuật - HL Generator, 2025
            </div>
        </aside>
    </div>

    <!-- Modal Chi tiết Work Order -->
    <div class="modal fade" id="workOrderDetailModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Chi tiết đơn hàng công việc</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" id="workOrderDetailForm">
                        <input type="hidden" id="detail_work_order_id">
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Mã đơn hàng:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="detail_work_order_number"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Khách hàng:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="detail_customer"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Tiêu đề:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="detail_title"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Mô tả:</label>
                            <div class="col-sm-9">
                                <textarea class="form-control" id="detail_description" rows="4" readonly></textarea>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Độ ưu tiên:</label>
                            <div class="col-sm-3">
                                <select class="form-control" id="detail_priority">
                                    <option value="urgent">Khẩn cấp</option>
                                    <option value="high">Cao</option>
                                    <option value="medium">Trung bình</option>
                                    <option value="low">Thấp</option>
                                </select>
                            </div>
                            
                            <label class="col-sm-3 control-label">Trạng thái:</label>
                            <div class="col-sm-3">
                                <select class="form-control" id="detail_status">
                                    <option value="pending">Chờ xử lý</option>
                                    <option value="in_progress">Đang thực hiện</option>
                                    <option value="completed">Hoàn thành</option>
                                    <option value="cancelled">Đã hủy</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Phân công cho:</label>
                            <div class="col-sm-3">
                                <select class="form-control" id="detail_assigned_to">
                                    <option value="">Chưa phân công</option>
                                </select>
                            </div>
                            
                            <label class="col-sm-3 control-label">Ngày tạo:</label>
                            <div class="col-sm-3">
                                <p class="form-control-static" id="detail_created"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Giờ ước tính:</label>
                            <div class="col-sm-3">
                                <input type="number" class="form-control" id="detail_estimated_hours" step="0.5" min="0">
                            </div>
                            
                            <label class="col-sm-3 control-label">Giờ thực tế:</label>
                            <div class="col-sm-3">
                                <input type="number" class="form-control" id="detail_actual_hours" step="0.5" min="0">
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Ngày lên lịch:</label>
                            <div class="col-sm-3">
                                <input type="date" class="form-control" id="detail_scheduled_date">
                            </div>
                            
                            <label class="col-sm-3 control-label">Ngày hoàn thành:</label>
                            <div class="col-sm-3">
                                <input type="date" class="form-control" id="detail_completion_date">
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Ghi chú:</label>
                            <div class="col-sm-9">
                                <textarea class="form-control" id="detail_notes" rows="3" placeholder="Ghi chú kỹ thuật..."></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" id="btnSaveWorkOrder">
                        <i class="fa fa-save"></i> Lưu thay đổi
                    </button>
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- jQuery 2.0.2 -->
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
    <script src="js/jquery.min.js" type="text/javascript"></script>
    <!-- Bootstrap -->
    <script src="js/bootstrap.min.js" type="text/javascript"></script>
    <!-- DATA TABES SCRIPT -->
    <script src="js/plugins/datatables/jquery.dataTables.js" type="text/javascript"></script>
    <script src="js/plugins/datatables/dataTables.bootstrap.js" type="text/javascript"></script>
    <!-- Director App -->
    <script src="js/Director/app.js" type="text/javascript"></script>

    <script>
        var ctx = '<%= request.getContextPath() %>';
        var allWorkOrders = [];
        var filteredWorkOrders = [];
        var technicalStaff = [];
        
        $(document).ready(function() {
            loadTechnicalStaff();
            loadWorkOrders();
            
            // Filter button
            $('#btnFilter').click(function() {
                applyFilters();
            });
            
            // Reset button
            $('#btnReset').click(function() {
                $('#filterForm')[0].reset();
                filteredWorkOrders = allWorkOrders;
                renderTable();
            });
            
            // Save work order changes
            $('#btnSaveWorkOrder').click(function() {
                saveWorkOrderChanges();
            });
            
            // Enter to search
            $('#filterSearch').keypress(function(e) {
                if(e.which == 13) {
                    $('#btnFilter').click();
                }
            });
        });
        
        function loadTechnicalStaff() {
            $.ajax({
                url: ctx + '/api/users?action=getTechnicalStaff',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        technicalStaff = response.data || [];
                        populateStaffDropdown();
                    }
                },
                error: function() {
                    console.log('Không thể tải danh sách nhân viên kỹ thuật');
                }
            });
        }
        
        function populateStaffDropdown() {
            var select = $('#detail_assigned_to');
            select.empty();
            select.append('<option value="">Chưa phân công</option>');
            
            technicalStaff.forEach(function(staff) {
                select.append('<option value="' + staff.id + '">' + staff.fullName + '</option>');
            });
        }
        
        function loadWorkOrders() {
            $.ajax({
                url: ctx + '/api/work-orders?action=list',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        allWorkOrders = response.data || [];
                        filteredWorkOrders = allWorkOrders;
                        renderTable();
                        updateStatistics();
                    } else {
                        showError('Không thể tải dữ liệu');
                    }
                },
                error: function() {
                    showError('Lỗi kết nối máy chủ');
                }
            });
        }
        
        function updateStatistics() {
            var total = allWorkOrders.length;
            var pending = allWorkOrders.filter(w => w.status === 'pending').length;
            var inProgress = allWorkOrders.filter(w => w.status === 'in_progress').length;
            var completed = allWorkOrders.filter(w => w.status === 'completed').length;
            
            $('#totalWorkOrders').text(total);
            $('#pendingWorkOrders').text(pending);
            $('#inProgressWorkOrders').text(inProgress);
            $('#completedWorkOrders').text(completed);
        }
        
        function applyFilters() {
            var status = $('#filterStatus').val();
            var priority = $('#filterPriority').val();
            var assignedTo = $('#filterAssignedTo').val();
            var search = $('#filterSearch').val().toLowerCase();
            
            filteredWorkOrders = allWorkOrders.filter(function(workOrder) {
                var matchStatus = !status || workOrder.status === status;
                var matchPriority = !priority || workOrder.priority === priority;
                var matchAssigned = !assignedTo || 
                    (assignedTo === 'unassigned' && !workOrder.assignedTo) ||
                    (assignedTo !== 'unassigned' && workOrder.assignedTo == assignedTo);
                var matchSearch = !search || 
                    (workOrder.workOrderNumber && workOrder.workOrderNumber.toLowerCase().includes(search)) ||
                    (workOrder.title && workOrder.title.toLowerCase().includes(search)) ||
                    (workOrder.description && workOrder.description.toLowerCase().includes(search));
                
                return matchStatus && matchPriority && matchAssigned && matchSearch;
            });
            
            renderTable();
        }
        
        function renderTable() {
            var tbody = $('#workOrdersTableBody');
            tbody.empty();
            
            if(!filteredWorkOrders || filteredWorkOrders.length === 0) {
                tbody.append('<tr><td colspan="8" class="text-center">Không có dữ liệu</td></tr>');
                return;
            }
            
            filteredWorkOrders.forEach(function(workOrder) {
                var assignedName = workOrder.assignedToName || 'Chưa phân công';
                var row = '<tr>' +
                    '<td>' + (workOrder.workOrderNumber || '#' + workOrder.id) + '</td>' +
                    '<td>' + (workOrder.customerName || 'N/A') + '</td>' +
                    '<td>' + (workOrder.title || '') + '</td>' +
                    '<td>' + getPriorityBadge(workOrder.priority) + '</td>' +
                    '<td>' + getStatusBadge(workOrder.status) + '</td>' +
                    '<td>' + assignedName + '</td>' +
                    '<td>' + formatDate(workOrder.createdAt) + '</td>' +
                    '<td class="work-order-actions">' +
                        '<button class="btn btn-info btn-view" data-id="' + workOrder.id + '"><i class="fa fa-eye"></i> Xem</button>' +
                    '</td>' +
                '</tr>';
                tbody.append(row);
            });
            
            // Bind view button
            $('.btn-view').click(function() {
                var id = $(this).data('id');
                viewWorkOrderDetail(id);
            });
        }
        
        function getPriorityBadge(priority) {
            var labels = {
                'urgent': 'Khẩn cấp',
                'high': 'Cao',
                'medium': 'Trung bình',
                'low': 'Thấp'
            };
            var badge = priority ? 'badge-' + priority : '';
            return '<span class="badge ' + badge + '">' + (labels[priority] || 'N/A') + '</span>';
        }
        
        function getStatusBadge(status) {
            var labels = {
                'pending': 'Chờ xử lý',
                'in_progress': 'Đang thực hiện',
                'completed': 'Hoàn thành',
                'cancelled': 'Đã hủy'
            };
            var badge = status ? 'badge-' + status : '';
            return '<span class="badge ' + badge + '">' + (labels[status] || 'N/A') + '</span>';
        }
        
        function formatDate(dateStr) {
            if(!dateStr) return '';
            try {
                var date = new Date(dateStr);
                return date.toLocaleDateString('vi-VN') + ' ' + date.toLocaleTimeString('vi-VN');
            } catch(e) {
                return dateStr;
            }
        }
        
        function viewWorkOrderDetail(id) {
            var workOrder = allWorkOrders.find(function(w) { return w.id == id; });
            if(!workOrder) return;
            
            $('#detail_work_order_id').val(workOrder.id);
            $('#detail_work_order_number').text(workOrder.workOrderNumber || '#' + workOrder.id);
            $('#detail_customer').text(workOrder.customerName || 'N/A');
            $('#detail_title').text(workOrder.title || '');
            $('#detail_description').val(workOrder.description || '');
            $('#detail_priority').val(workOrder.priority || 'medium');
            $('#detail_status').val(workOrder.status || 'pending');
            $('#detail_assigned_to').val(workOrder.assignedTo || '');
            $('#detail_created').text(formatDate(workOrder.createdAt));
            $('#detail_estimated_hours').val(workOrder.estimatedHours || '');
            $('#detail_actual_hours').val(workOrder.actualHours || '');
            $('#detail_scheduled_date').val(workOrder.scheduledDate || '');
            $('#detail_completion_date').val(workOrder.completionDate || '');
            $('#detail_notes').val(workOrder.notes || '');
            
            $('#workOrderDetailModal').modal('show');
        }
        
        function saveWorkOrderChanges() {
            var id = $('#detail_work_order_id').val();
            var data = {
                action: 'update',
                id: id,
                priority: $('#detail_priority').val(),
                status: $('#detail_status').val(),
                assignedTo: $('#detail_assigned_to').val(),
                estimatedHours: $('#detail_estimated_hours').val(),
                actualHours: $('#detail_actual_hours').val(),
                scheduledDate: $('#detail_scheduled_date').val(),
                completionDate: $('#detail_completion_date').val(),
                notes: $('#detail_notes').val()
            };
            
            $.ajax({
                url: ctx + '/api/work-orders',
                type: 'POST',
                data: data,
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        alert('Cập nhật thành công!');
                        $('#workOrderDetailModal').modal('hide');
                        loadWorkOrders();
                    } else {
                        alert('Lỗi: ' + (response.message || 'Không thể cập nhật'));
                    }
                },
                error: function() {
                    alert('Lỗi kết nối máy chủ');
                }
            });
        }
        
        function showError(msg) {
            $('#workOrdersTableBody').html('<tr><td colspan="8" class="text-center text-danger">' + msg + '</td></tr>');
        }
    </script>
</body>
</html>
