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
    <title>Đơn Hàng Công Việc | HL Generator</title>
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
        /* Stats Cards - Same as tech_support_management */
        .stats-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }
        
        .stats-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
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
        
        /* Badge Styling */
        .badge {
            padding: 5px 12px;
            font-size: 12px;
            font-weight: 600;
            border-radius: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .badge-urgent { 
            background: linear-gradient(135deg, #f85032 0%, #e73827 100%) !important;
            box-shadow: 0 2px 8px rgba(248, 80, 50, 0.3);
        }
        .badge-high { 
            background: linear-gradient(135deg, #fa8231 0%, #f0ad4e 100%) !important;
            box-shadow: 0 2px 8px rgba(240, 173, 78, 0.3);
        }
        .badge-medium { 
            background: linear-gradient(135deg, #5bc0de 0%, #46b8da 100%) !important;
            box-shadow: 0 2px 8px rgba(91, 192, 222, 0.3);
        }
        .badge-low { 
            background: linear-gradient(135deg, #5cb85c 0%, #4cae4c 100%) !important;
            box-shadow: 0 2px 8px rgba(92, 184, 92, 0.3);
        }
        
        .badge-pending { 
            background: linear-gradient(135deg, #f0ad4e 0%, #ec971f 100%) !important;
            box-shadow: 0 2px 8px rgba(240, 173, 78, 0.3);
        }
        .badge-in_progress { 
            background: linear-gradient(135deg, #5bc0de 0%, #31b0d5 100%) !important;
            box-shadow: 0 2px 8px rgba(91, 192, 222, 0.3);
        }
        .badge-completed { 
            background: linear-gradient(135deg, #5cb85c 0%, #449d44 100%) !important;
            box-shadow: 0 2px 8px rgba(92, 184, 92, 0.3);
        }
        .badge-cancelled { 
            background: linear-gradient(135deg, #777 0%, #555 100%) !important;
            box-shadow: 0 2px 8px rgba(119, 119, 119, 0.3);
        }
        
        /* Box Styling - Same as tech_support_management */
        .box {
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .box-header {
            padding: 10px;
            background-color: #f5f5f5;
        }
        
        .box-title {
            font-weight: 600;
            font-size: 14px;
        }
        
        /* Action Buttons */
        .work-order-actions {
            white-space: nowrap;
        }
        
        .work-order-actions .btn {
            padding: 2px 8px;
            font-size: 12px;
            margin-right: 3px;
        }
        
        /* Modal */
        .modal-lg {
            width: 900px;
        }
        
        .history-item {
            border-left: 3px solid #3c8dbc;
            padding-left: 10px;
            margin-bottom: 10px;
        }
        
        .form-horizontal .control-label {
            text-align: left;
        }
        
        /* Filter Section */
        .filter-group {
            margin-bottom: 10px;
        }
        
        /* Ticket/Work Order Actions */
        .ticket-actions {
            white-space: nowrap;
        }
        .ticket-actions .btn {
            padding: 2px 8px;
            font-size: 12px;
            margin-right: 3px;
        }
    </style>
</head>
<body class="skin-black">
    <!-- header logo -->
    <header class="header">
        <a href="headtech.jsp" class="logo">
            Đơn Hàng Công Việc
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
                <!-- sidebar menu -->
                <ul class="sidebar-menu">
                    <li>
                        <a href="headtech.jsp">
                            <i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
                        </a>
                    </li>
                    <li>
                        <a href="tech_support_management.jsp">
                            <i class="fa fa-wrench"></i> <span>Yêu cầu hỗ trợ kỹ thuật</span>
                        </a>
                    </li>
                    <li class="active">
                        <a href="work_orders.jsp">
                            <i class="fa fa-file-text-o"></i> <span>Đơn hàng công việc</span>
                        </a>
                    </li>
                </ul>
            </section>
        </aside>

        <aside class="right-side">
            <section class="content-header">
                <h1>
                    Đơn Hàng Công Việc
                    <small>Quản lý và theo dõi công việc kỹ thuật</small>
                </h1>
                <ol class="breadcrumb">
                    <li><a href="headtech.jsp"><i class="fa fa-dashboard"></i> Trang chủ</a></li>
                    <li class="active">Đơn hàng công việc</li>
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
                                        <label>Phân công: </label>
                                        <select class="form-control input-sm" id="filterAssignedTo" style="width: 150px;">
                                            <option value="">Tất cả</option>
                                            <option value="unassigned">Chưa phân công</option>
                                        </select>
                                    </div>
                                    
                                    <div class="form-group" style="margin-left: 10px;">
                                        <label>Tìm kiếm: </label>
                                        <input type="text" class="form-control input-sm" id="filterSearch" placeholder="Mã đơn, tiêu đề..." style="width: 200px;">
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
                                <div class="box-tools pull-right">
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
                                            <th style="width: 120px;">Phân công</th>
                                            <th style="width: 80px;">Giờ ước tính</th>
                                            <th style="width: 100px;">Ngày tạo</th>
                                            <th style="width: 150px;">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="workOrdersTableBody">
                                        <tr>
                                            <td colspan="9" class="text-center">Đang tải dữ liệu...</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <div class="footer-main">
                Copyright &copy Hệ thống quản lý công việc kỹ thuật - HL Generator, 2025
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
                                <input type="text" class="form-control" id="detail_title" readonly>
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

    <!-- Modal Chia Việc -->
    <div class="modal fade" id="assignTaskModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Chia việc cho nhân viên</h4>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="assign_work_order_id">
                    
                    <!-- Form thêm task mới -->
                    <div class="box box-success">
                        <div class="box-header">
                            <h3 class="box-title">Thêm công việc mới</h3>
                        </div>
                        <div class="box-body">
                            <form id="addTaskForm">
                                <div class="form-group">
                                    <label>Mô tả công việc:</label>
                                    <textarea class="form-control" id="taskDescription" rows="3" placeholder="Nhập mô tả công việc..." required></textarea>
                                </div>
                                <div class="row">
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>Độ ưu tiên:</label>
                                            <select class="form-control" id="taskPriority">
                                                <option value="low">Thấp</option>
                                                <option value="medium" selected>Trung bình</option>
                                                <option value="high">Cao</option>
                                                <option value="urgent">Khẩn cấp</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>Giờ ước tính:</label>
                                            <input type="number" class="form-control" id="taskEstimatedHours" step="0.5" min="0" placeholder="VD: 2.5">
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>Ghi chú:</label>
                                            <input type="text" class="form-control" id="taskNotes" placeholder="Ghi chú (tùy chọn)">
                                        </div>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa fa-plus"></i> Thêm công việc
                                </button>
                            </form>
                        </div>
                    </div>
                    
                    <!-- Danh sách công việc -->
                    <div class="box box-primary">
                        <div class="box-header">
                            <h3 class="box-title">Danh sách công việc</h3>
                        </div>
                        <div class="box-body">
                            <table class="table table-bordered table-hover" id="tasksTable">
                                <thead>
                                    <tr>
                                        <th style="width: 80px;">Mã</th>
                                        <th>Mô tả</th>
                                        <th style="width: 100px;">Độ ưu tiên</th>
                                        <th style="width: 100px;">Trạng thái</th>
                                        <th style="width: 100px;">Phân công</th>
                                        <th style="width: 120px;">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody id="tasksTableBody">
                                    <tr>
                                        <td colspan="6" class="text-center">Đang tải...</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Phân công công việc -->
    <div class="modal fade" id="assignTaskUserModal" tabindex="-1" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Phân công công việc</h4>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="assign_task_id">
                    <div class="form-group">
                        <label>Mô tả công việc:</label>
                        <p class="form-control-static" id="assign_task_description"></p>
                    </div>
                    <div class="form-group">
                        <label>Phân công cho nhân viên:</label>
                        <select class="form-control" id="assign_user_id">
                            <option value="">Chọn nhân viên...</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" id="btnConfirmAssign">
                        <i class="fa fa-check"></i> Phân công
                    </button>
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
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
                url: ctx + '/api/users?role=technical_staff',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        technicalStaff = response.data || [];
                        populateStaffDropdown();
                        // Also populate filter dropdown
                        var filterSelect = $('#filterAssignedTo');
                        technicalStaff.forEach(function(staff) {
                            filterSelect.append('<option value="' + staff.id + '">' + staff.fullName + '</option>');
                        });
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
                        showError('Không thể tải dữ liệu: ' + (response.message || 'Unknown error'));
                    }
                },
                error: function(xhr, status, error) {
                    showError('Lỗi kết nối máy chủ: ' + error);
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
                    (workOrder.description && workOrder.description.toLowerCase().includes(search)) ||
                    (workOrder.customerName && workOrder.customerName.toLowerCase().includes(search));
                
                return matchStatus && matchPriority && matchAssigned && matchSearch;
            });
            
            renderTable();
        }
        
        function renderTable() {
            var tbody = $('#workOrdersTableBody');
            tbody.empty();
            
            if(!filteredWorkOrders || filteredWorkOrders.length === 0) {
                tbody.append('<tr><td colspan="9" class="text-center">Không có dữ liệu</td></tr>');
                return;
            }
            
            filteredWorkOrders.forEach(function(workOrder) {
                var assignedName = workOrder.assignedToName || 'Chưa phân công';
                var customerName = workOrder.customerName || 'N/A';
                var estimatedHours = workOrder.estimatedHours ? workOrder.estimatedHours + 'h' : '-';
                var row = '<tr>' +
                    '<td><strong>' + (workOrder.workOrderNumber || '#' + workOrder.id) + '</strong></td>' +
                    '<td>' + customerName + '</td>' +
                    '<td>' + (workOrder.title || '') + '</td>' +
                    '<td>' + getPriorityBadge(workOrder.priority) + '</td>' +
                    '<td>' + getStatusBadge(workOrder.status) + '</td>' +
                    '<td>' + assignedName + '</td>' +
                    '<td class="text-center">' + estimatedHours + '</td>' +
                    '<td>' + formatDate(workOrder.createdAt) + '</td>' +
                    '<td class="work-order-actions">' +
                        '<button class="btn btn-info btn-view" data-id="' + workOrder.id + '" title="Xem chi tiết">' +
                            '<i class="fa fa-eye"></i>' +
                        '</button>' +
                        '<button class="btn btn-success btn-assign-task" data-id="' + workOrder.id + '" title="Chia việc">' +
                            '<i class="fa fa-tasks"></i>' +
                        '</button>' +
                    '</td>' +
                '</tr>';
                tbody.append(row);
            });
            
            // Bind view button
            $('.btn-view').click(function() {
                var id = $(this).data('id');
                viewWorkOrderDetail(id);
            });
            
            // Bind assign task button
            $('.btn-assign-task').click(function() {
                var id = $(this).data('id');
                openAssignTaskModal(id);
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
                var day = date.getDate().toString().padStart(2, '0');
                var month = (date.getMonth() + 1).toString().padStart(2, '0');
                var year = date.getFullYear();
                return day + '/' + month + '/' + year;
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
            $('#detail_title').val(workOrder.title || '');
            $('#detail_description').val(workOrder.description || '');
            $('#detail_priority').val(workOrder.priority || 'medium');
            $('#detail_status').val(workOrder.status || 'pending');
            $('#detail_assigned_to').val(workOrder.assignedTo || '');
            $('#detail_created').text(formatDate(workOrder.createdAt));
            $('#detail_estimated_hours').val(workOrder.estimatedHours || '');
            $('#detail_actual_hours').val(workOrder.actualHours || '');
            $('#detail_scheduled_date').val(workOrder.scheduledDate || '');
            $('#detail_completion_date').val(workOrder.completionDate || '');
            
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
                completionDate: $('#detail_completion_date').val()
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
            $('#workOrdersTableBody').html('<tr><td colspan="9" class="text-center text-danger">' + msg + '</td></tr>');
        }
        
        // Functions for task management
        function openAssignTaskModal(workOrderId) {
            $('#assign_work_order_id').val(workOrderId);
            $('#assignTaskModal').modal('show');
            loadTasks(workOrderId);
        }
        
        function loadTasks(workOrderId) {
            $.ajax({
                url: ctx + '/api/work-order-tasks?action=list&workOrderId=' + workOrderId,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        renderTasksTable(response.data);
                    } else {
                        $('#tasksTableBody').html('<tr><td colspan="6" class="text-center">Không có công việc nào</td></tr>');
                    }
                },
                error: function() {
                    $('#tasksTableBody').html('<tr><td colspan="6" class="text-center text-danger">Lỗi tải dữ liệu</td></tr>');
                }
            });
        }
        
        function renderTasksTable(tasks) {
            console.log('Rendering tasks:', tasks);
            var tbody = $('#tasksTableBody');
            tbody.empty();
            
            if(!tasks || tasks.length === 0) {
                tbody.append('<tr><td colspan="6" class="text-center">Chưa có công việc nào</td></tr>');
                return;
            }
            
            tasks.forEach(function(task) {
                console.log('Task:', task, 'assignedToName:', task.assignedToName);
                var assignedName = task.assignedToName || 'Chưa phân công';
                var assignedBadge = task.assignedToName ? 
                    '<span class="label label-success">' + assignedName + '</span>' : 
                    '<span class="label label-info">' + assignedName + '</span>';
                
                var row = '<tr>' +
                    '<td><strong>' + (task.taskNumber || 'N/A') + '</strong></td>' +
                    '<td>' + (task.taskDescription || '') + '</td>' +
                    '<td>' + getPriorityBadge(task.priority) + '</td>' +
                    '<td>' + getStatusBadge(task.status) + '</td>' +
                    '<td>' + assignedBadge + '</td>' +
                    '<td>' +
                        '<button class="btn btn-xs btn-primary btn-assign-to-user" data-task-id="' + task.id + '" data-task-desc="' + (task.taskDescription || '') + '">' +
                            '<i class="fa fa-user"></i> Phân công' +
                        '</button>' +
                        '<button class="btn btn-xs btn-danger btn-delete-task" data-task-id="' + task.id + '" style="margin-left: 5px;">' +
                            '<i class="fa fa-trash"></i> Xóa' +
                        '</button>' +
                    '</td>' +
                '</tr>';
                tbody.append(row);
            });
            
            // Bind assign button
            $('.btn-assign-to-user').click(function() {
                var taskId = $(this).data('task-id');
                var taskDesc = $(this).data('task-desc');
                openAssignUserModal(taskId, taskDesc);
            });
            
            // Bind delete button
            $('.btn-delete-task').click(function() {
                var taskId = $(this).data('task-id');
                deleteTask(taskId);
            });
        }
        
        function openAssignUserModal(taskId, taskDescription) {
            $('#assign_task_id').val(taskId);
            $('#assign_task_description').text(taskDescription);
            $('#assign_user_id').val('');
            
            var select = $('#assign_user_id');
            select.empty();
            select.append('<option value="">Chọn nhân viên...</option>');
            
            technicalStaff.forEach(function(staff) {
                select.append('<option value="' + staff.id + '">' + staff.fullName + '</option>');
            });
            
            $('#assignTaskUserModal').modal('show');
        }
        
        function deleteTask(taskId) {
            if(!confirm('Bạn có chắc chắn muốn xóa công việc này?')) {
                return;
            }
            
            $.ajax({
                url: ctx + '/api/work-order-tasks?action=delete',
                type: 'POST',
                data: {id: taskId},
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        alert('Xóa công việc thành công!');
                        var workOrderId = $('#assign_work_order_id').val();
                        loadTasks(workOrderId);
                    } else {
                        alert('Lỗi: ' + (response.message || 'Không thể xóa công việc'));
                    }
                },
                error: function() {
                    alert('Lỗi kết nối máy chủ');
                }
            });
        }
        
        // Form submit handler for adding new task
        $(document).on('submit', '#addTaskForm', function(e) {
            e.preventDefault();
            
            var workOrderId = $('#assign_work_order_id').val();
            var description = $('#taskDescription').val();
            var priority = $('#taskPriority').val();
            var estimatedHours = $('#taskEstimatedHours').val();
            var notes = $('#taskNotes').val();
            
            if(!description || description.trim() === '') {
                alert('Vui lòng nhập mô tả công việc');
                return;
            }

            $.ajax({
                url: ctx + '/api/work-order-tasks?action=create',
                type: 'POST',
                data: {
                    workOrderId: workOrderId,
                    taskDescription: description,
                    priority: priority,
                    estimatedHours: estimatedHours,
                    notes: notes
                },
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        alert('Thêm công việc thành công!');
                        $('#addTaskForm')[0].reset();
                        loadTasks(workOrderId);
                    } else {
                        alert('Lỗi: ' + (response.message || 'Không thể thêm công việc'));
                    }
                },
                error: function() {
                    alert('Lỗi kết nối máy chủ');
                }
            });
        });
        
        // Button confirm assign
        $('#btnConfirmAssign').click(function() {
            var taskId = $('#assign_task_id').val();
            var userId = $('#assign_user_id').val();
            
            if(!userId) {
                alert('Vui lòng chọn nhân viên');
                return;
            }
            
            $.ajax({
                url: ctx + '/api/work-order-tasks?action=assign',
                type: 'POST',
                data: {
                    taskId: taskId,
                    userId: userId,
                    role: 'assignee'
                },
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        alert('Phân công công việc thành công!');
                        // Reload tasks before closing modal
                        var workOrderId = $('#assign_work_order_id').val();
                        loadTasks(workOrderId);
                        $('#assignTaskUserModal').modal('hide');
                    } else {
                        alert('Lỗi: ' + (response.message || 'Không thể phân công'));
                    }
                },
                error: function() {
                    alert('Lỗi kết nối máy chủ');
                }
            });
        });
    </script>
</body>
</html>

