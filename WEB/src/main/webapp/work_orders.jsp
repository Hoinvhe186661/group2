<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Set" %>
<%
    // Kiểm tra đăng nhập
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Kiểm tra quyền: chỉ người có quyền manage_work_orders mới truy cập được
    @SuppressWarnings("unchecked")
    Set<String> userPermissions = (Set<String>) session.getAttribute("userPermissions");
    if (userPermissions == null || !userPermissions.contains("manage_work_orders")) {
        response.sendRedirect(request.getContextPath() + "/error/403.jsp");
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
        .badge-rejected,
        .badge-danger { 
            background: linear-gradient(135deg, #d9534f 0%, #c9302c 100%) !important;
            box-shadow: 0 2px 8px rgba(217, 83, 79, 0.3);
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
        /* Modal adjustments for wide tables */
        #assignTaskModal .modal-dialog {
            width: 95%;
            max-width: 1400px;
        }
        
        @media (max-width: 768px) {
            #assignTaskModal .modal-dialog {
                width: 98%;
                margin: 10px auto;
            }
        }
        
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
        
        /* Phân trang DataTables */
        .dataTables_length {
            display: none !important;
        }
        
        .dataTables_wrapper .dataTables_paginate {
            margin-top: 15px;
            text-align: center;
            float: none !important;
            display: block !important;
            visibility: visible !important;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button {
            padding: 6px 12px;
            margin: 0 2px;
            border: 1px solid #ddd;
            border-radius: 4px;
            background: #fff;
            color: #333 !important;
            cursor: pointer;
            display: inline-block !important;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
            background: #f5f5f5;
            border-color: #999;
            color: #333 !important;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button.current {
            background: #3c8dbc !important;
            color: #fff !important;
            border-color: #3c8dbc !important;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button.current:hover {
            background: #357abd !important;
            color: #fff !important;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button.disabled {
            opacity: 0.5;
            cursor: not-allowed;
            background: #f5f5f5 !important;
        }
        
        .dataTables_wrapper .dataTables_info {
            margin-top: 15px;
            padding-top: 8px;
            float: left;
        }
        
        .dataTables_wrapper::after {
            content: "";
            display: table;
            clear: both;
        }
        
        /* Đảm bảo phân trang luôn hiển thị, kể cả khi chỉ có 1 trang */
        .dataTables_wrapper .dataTables_paginate.paging_full_numbers {
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
        
        /* Đảm bảo không có CSS nào ẩn phân trang */
        .dataTables_wrapper .dataTables_paginate[style*="display: none"] {
            display: block !important;
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
        
        /* Image Gallery */
        .attachment-thumbnail {
            transition: transform 0.2s;
            border: 1px solid #ddd;
            border-radius: 4px;
            overflow: hidden;
        }
        .attachment-thumbnail:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        .attachment-thumbnail img {
            cursor: pointer;
        }
        
        /* Text Overflow Handling */
        .text-truncate {
            max-width: 200px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            display: inline-block;
        }
        
        /* Table cell text wrapping */
        #workOrdersTable td:nth-child(2),
        #workOrdersTable td:nth-child(3) {
            max-width: 200px;
            word-wrap: break-word;
            word-break: break-word;
            overflow-wrap: break-word;
            white-space: normal;
        }
        
        /* Tasks table - Description column */
        #tasksTable td:nth-child(2) {
            max-width: 200px;
            min-width: 150px;
            word-wrap: break-word;
            word-break: break-word;
            white-space: normal;
            overflow-wrap: break-word;
        }
        
        /* Tasks table - Rejection reason column (now 9th column after adding 2 date columns) */
        #tasksTable td:nth-child(9) {
            max-width: 150px;
            min-width: 150px;
            word-wrap: break-word;
            word-break: break-word;
            white-space: normal;
            overflow-wrap: break-word;
        }
        
        /* Tasks table - Date columns */
        #tasksTable td:nth-child(5),
        #tasksTable td:nth-child(6) {
            white-space: nowrap;
            font-size: 12px;
        }
        
        /* Tasks table - Action column */
        #tasksTable td:last-child {
            white-space: nowrap;
        }
        
        /* Tasks table - Compact buttons */
        #tasksTable .btn-xs {
            padding: 1px 5px;
            font-size: 11px;
            margin: 1px;
        }
        
        /* Make table more compact */
        #tasksTable th,
        #tasksTable td {
            padding: 6px 8px;
            font-size: 12px;
        }
        
        /* Table responsive wrapper */
        .table-responsive {
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        
        /* Readonly textarea */
        textarea[readonly] {
            word-wrap: break-word;
            word-break: break-word;
            resize: vertical;
            overflow-wrap: break-word;
            max-width: 100%;
            box-sizing: border-box;
        }
        
        /* Customer name and title in table */
        .work-order-title,
        .work-order-customer {
            max-width: 200px;
            display: inline-block;
            word-wrap: break-word;
            word-break: break-word;
            white-space: normal;
            overflow-wrap: break-word;
        }
        
        /* Task description text */
        .task-description-text {
            display: inline-block;
            max-width: 100%;
            word-wrap: break-word;
            word-break: break-word;
            white-space: normal;
            overflow-wrap: break-word;
        }
        
        /* Modal description textarea - Improved */
        #detail_description {
            word-wrap: break-word;
            word-break: break-word;
            overflow-wrap: break-word;
            max-width: 100%;
            box-sizing: border-box;
            white-space: pre-wrap;
            overflow-y: auto;
            resize: vertical;
        }
        
        /* Modal assigned to textarea */
        #detail_assigned_to {
            word-wrap: break-word;
            word-break: break-word;
            overflow-wrap: break-word;
            max-width: 100%;
            box-sizing: border-box;
            white-space: pre-wrap;
            overflow-y: auto;
        }
        
        /* Task description in assign modal */
        #assign_task_description {
            word-wrap: break-word;
            word-break: break-word;
            white-space: normal;
            max-height: 100px;
            overflow-y: auto;
            overflow-wrap: break-word;
            max-width: 100%;
            box-sizing: border-box;
            padding: 8px;
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        
        /* Table cells - ensure no overflow */
        #workOrdersTable td,
        #tasksTable td {
            overflow: hidden;
            word-wrap: break-word;
            word-break: break-word;
            overflow-wrap: break-word;
        }
        
        /* Ensure table responsiveness */
        .table-responsive {
            overflow-x: auto;
        }
        
        /* Modal body - prevent overflow */
        .modal-body {
            overflow-x: hidden;
            word-wrap: break-word;
        }
        
        /* Task description counter */
        #taskDescriptionCounter {
            font-weight: bold;
        }
        
        #taskDescriptionCounter.text-danger {
            color: #d9534f !important;
        }
        
        #taskDescriptionCounter.text-warning {
            color: #f0ad4e !important;
        }
        
        #taskDescriptionError {
            margin-top: 5px;
            font-size: 12px;
        }
        
        /* User task count info */
        #userTaskCountInfo {
            padding: 8px;
            background-color: #f9f9f9;
            border-left: 3px solid #5bc0de;
            border-radius: 3px;
        }
        
        #userTaskCountInfo.text-info {
            border-left-color: #5bc0de;
            background-color: #e7f3ff;
        }
        
        #userTaskCountInfo.text-success {
            border-left-color: #5cb85c;
            background-color: #e8f5e9;
        }
        
        #userTaskCountInfo.text-warning {
            border-left-color: #f0ad4e;
            background-color: #fff9e6;
        }
        
        #userTaskCountInfo.text-danger {
            border-left-color: #d9534f;
            background-color: #ffe6e6;
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
		<jsp:include page="partials/sidebar.jsp"/>

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
                            </div>
                            <div class="box-body table-responsive">
                                <table id="workOrdersTable" class="table table-bordered table-striped table-hover">
                                    <thead>
                                        <tr>
                                            <th style="width: 100px;">Mã đơn hàng</th>
                                            <th>Khách hàng</th>
                                            <th>Tiêu đề</th>
                                            <th style="width: 80px;">Giờ ước tính</th>
                                            <th style="width: 100px;">Ngày tạo</th>
                                            <th style="width: 150px;">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="workOrdersTableBody">
                                        <tr>
                                            <td colspan="6" class="text-center">Đang tải dữ liệu...</td>
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
                                <select class="form-control" id="detail_priority" disabled>
                                    <option value="urgent">Khẩn cấp</option>
                                    <option value="high">Cao</option>
                                    <option value="medium">Trung bình</option>
                                    <option value="low">Thấp</option>
                                </select>
                            </div>
                            
                            <label class="col-sm-3 control-label">Trạng thái:</label>
                            <div class="col-sm-3">
                                <select class="form-control" id="detail_status" disabled>
                                    <option value="pending">Chờ xử lý</option>
                                    <option value="in_progress">Đang thực hiện</option>
                                    <option value="completed">Hoàn thành</option>
                                    <option value="cancelled">Đã hủy</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Phân công cho:</label>
                            <div class="col-sm-9">
                                <textarea class="form-control" id="detail_assigned_to" rows="3" readonly style="resize: none;"></textarea>
                                <small class="help-block">Danh sách nhân viên đã được phân công từ các công việc</small>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Ngày tạo:</label>
                            <div class="col-sm-3">
                                <p class="form-control-static" id="detail_created"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Giờ ước tính:</label>
                            <div class="col-sm-3">
                                <input type="number" class="form-control" id="detail_estimated_hours" step="0.1" min="0.1" max="100" readonly>
                                <small class="help-block">Tối thiểu: 0.1h, Tối đa: 100h (Không thể chỉnh sửa)</small>
                            </div>
                            
                            <label class="col-sm-3 control-label">Giờ thực tế:</label>
                            <div class="col-sm-3">
                                <input type="number" class="form-control" id="detail_actual_hours" step="0.1" min="0" readonly>
                                <small class="help-block">Tự động tính từ tổng giờ thực tế của các task</small>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Ngày lên lịch:</label>
                            <div class="col-sm-3">
                                <input type="date" class="form-control" id="detail_scheduled_date" readonly>
                                <small class="help-block">Trùng với ngày tạo (Không thể chỉnh sửa)</small>
                            </div>
                            
                            <label class="col-sm-3 control-label">Ngày hoàn thành:</label>
                            <div class="col-sm-3">
                                <input type="date" class="form-control" id="detail_completion_date">
                                <small class="help-block text-muted" id="completionDateHelp"></small>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Ngày hoàn thành mong muốn của khách hàng:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="detail_customer_deadline" style="color: #d9534f; font-weight: bold;">
                                    <i class="fa fa-calendar"></i> <span id="detail_customer_deadline_text">Đang tải...</span>
                                </p>
                                <small class="help-block text-muted">Ngày deadline từ yêu cầu hỗ trợ của khách hàng</small>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Giải pháp kỹ thuật:</label>
                            <div class="col-sm-9">
                                <textarea class="form-control" id="detail_technical_solution" rows="5" placeholder="Nhập giải pháp kỹ thuật..." maxlength="1000"></textarea>
                                <small class="help-block text-muted">
                                    Mô tả giải pháp kỹ thuật để xử lý yêu cầu
                                    <span class="text-info" style="margin-left: 10px;">
                                        <span id="technical_solution_char_count">0</span>/1000 ký tự
                                    </span>
                                </small>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-success" id="btnFinishWorkOrder" style="display: none;">
                        <i class="fa fa-check"></i> Hoàn thành đơn hàng
                    </button>
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
                    
                    <!-- Alert thông báo khi work order đã hoàn thành -->
                    <div id="workOrderClosedAlert" class="alert alert-warning alert-dismissible" style="display: none;">
                        <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                        <h4><i class="fa fa-exclamation-triangle"></i> Cảnh báo!</h4>
                        <p id="workOrderClosedMessage">
                            <strong>Đơn hàng này đã hoàn thành hoặc đã hủy.</strong><br>
                            Không thể tạo thêm công việc mới cho đơn hàng đã đóng.
                        </p>
                    </div>
                    
                    <!-- Form thêm task mới -->
                    <div class="box box-success">
                        <div class="box-header">
                            <h3 class="box-title">Thêm công việc mới</h3>
                        </div>
                        <div class="box-body">
                            <form id="addTaskForm">
                                <div class="form-group">
                                    <label>Mô tả công việc: <span class="text-danger">*</span> <small class="text-muted">(Tối đa 150 ký tự)</small></label>
                                    <textarea class="form-control" id="taskDescription" rows="3" placeholder="Nhập mô tả công việc..." required maxlength="150"></textarea>
                                    <small class="help-block">
                                        <span id="taskDescriptionCounter">0</span>/150 ký tự
                                    </small>
                                    <div id="taskDescriptionError" class="text-danger" style="display: none;"></div>
                                </div>
                                <div class="form-group">
                                    <label>Ngày mong muốn hoàn thành của khách hàng:</label>
                                    <p class="form-control-static" id="customer_deadline_display" style="color: #d9534f; font-weight: bold;">
                                        <i class="fa fa-calendar"></i> <span id="customer_deadline_text">Đang tải...</span>
                                    </p>
                                    <small class="help-block text-muted">Ngày deadline từ yêu cầu hỗ trợ của khách hàng</small>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
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
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Giờ ước tính:</label>
                                            <input type="number" class="form-control" id="taskEstimatedHours" step="0.1" min="0.1" max="100" placeholder="VD: 2.5">
                                            <small class="help-block">Tối thiểu: 0.1h, Tối đa: 100h</small>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Ngày thực hiện:</label>
                                            <input type="date" class="form-control" id="taskStartDate" min="">
                                            <small class="help-block">Ngày bắt đầu thực hiện công việc (không được chọn ngày quá khứ)</small>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Deadline:</label>
                                            <input type="date" class="form-control" id="taskDeadline" min="">
                                            <small class="help-block">Ngày deadline hoàn thành công việc (không được chọn ngày quá khứ)</small>
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
                            <div class="box-tools pull-right">
                                <button type="button" class="btn btn-sm btn-default" id="btnResetTaskFilter" title="Đặt lại bộ lọc">
                                    <i class="fa fa-refresh"></i>
                                </button>
                            </div>
                        </div>
                        <div class="box-body">
                            <!-- Bộ lọc -->
                            <div class="row" style="margin-bottom: 15px;">
                                <div class="col-md-5">
                                    <div class="form-group">
                                        <label>Lọc theo độ ưu tiên:</label>
                                        <select class="form-control input-sm" id="filterTaskPriority">
                                            <option value="">Tất cả</option>
                                            <option value="urgent">Khẩn cấp</option>
                                            <option value="high">Cao</option>
                                            <option value="medium">Trung bình</option>
                                            <option value="low">Thấp</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-5">
                                    <div class="form-group">
                                        <label>Lọc theo trạng thái:</label>
                                        <select class="form-control input-sm" id="filterTaskStatus">
                                            <option value="">Tất cả</option>
                                            <option value="pending">Chờ xử lý</option>
                                            <option value="in_progress">Đang thực hiện</option>
                                            <option value="completed">Hoàn thành</option>
                                            <option value="rejected">Đã từ chối</option>
                                            <option value="cancelled">Đã hủy</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <div class="form-group">
                                        <label>&nbsp;</label>
                                        <div>
                                            <button type="button" class="btn btn-primary btn-sm btn-block" id="btnApplyTaskFilter">
                                                <i class="fa fa-filter"></i> Lọc
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Table wrapper with horizontal scroll -->
                            <div class="table-responsive" style="max-height: 600px; overflow-y: auto;">
                                <table class="table table-bordered table-hover table-condensed" id="tasksTable" style="margin-bottom: 0;">
                                    <thead>
                                        <tr>
                                        <th style="width: 70px; min-width: 70px;">Mã</th>
                                        <th style="min-width: 150px; max-width: 200px;">Mô tả</th>
                                        <th style="width: 90px; min-width: 90px;">Độ ưu tiên</th>
                                        <th style="width: 90px; min-width: 90px;">Giờ ước tính</th>
                                        <th style="width: 110px; min-width: 110px;">Ngày giao việc</th>
                                        <th style="width: 110px; min-width: 110px;">Deadline</th>
                                        <th style="width: 120px; min-width: 120px;">Ngày hoàn thành</th>
                                        <th style="width: 90px; min-width: 90px;">Trạng thái</th>
                                        <th style="width: 100px; min-width: 100px;">Phân công</th>
                                        <th style="width: 150px; min-width: 150px;">Lý do từ chối</th>
                                        <th style="width: 110px; min-width: 110px;">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tasksTableBody">
                                        <tr>
                                            <td colspan="11" class="text-center">Đang tải...</td>
                                        </tr>
                                    </tbody>
                                </table>
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
                        <label>Phân công cho nhân viên: <span class="text-danger">*</span></label>
                        <select class="form-control" id="assign_user_id" required>
                            <option value="">Chọn nhân viên...</option>
                        </select>
                        <div id="userTaskCountInfo" class="help-block" style="margin-top: 8px; display: none;">
                            <i class="fa fa-info-circle"></i> <span id="userTaskCountText"></span>
                            <div id="userActiveTasksList" style="margin-top: 8px; display: none;">
                                <ul id="userActiveTasksItems" style="margin: 0; padding-left: 20px; list-style-type: disc;"></ul>
                            </div>
                        </div>
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

    <!-- Modal Báo cáo -->
    <div class="modal fade" id="reportModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Báo cáo công việc kỹ thuật</h4>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="report_work_order_id">
                    
                    <!-- Bộ lọc ngày -->
                    <div class="box box-primary">
                        <div class="box-header">
                            <h3 class="box-title">Bộ lọc theo ngày</h3>
                        </div>
                        <div class="box-body">
                            <form class="form-horizontal" id="reportFilterForm">
                                <div class="row">
                                    <div class="col-md-5">
                                        <div class="form-group">
                                            <label class="control-label">Ngày bắt đầu:</label>
                                            <input type="date" class="form-control" id="report_filter_start_date">
                                            <small class="help-block">Lọc theo ngày bắt đầu của nhiệm vụ</small>
                                        </div>
                                    </div>
                                    <div class="col-md-5">
                                        <div class="form-group">
                                            <label class="control-label">Ngày hoàn thành:</label>
                                            <input type="date" class="form-control" id="report_filter_completion_date">
                                            <small class="help-block">Lọc theo ngày hoàn thành của nhiệm vụ</small>
                                        </div>
                                    </div>
                                    <div class="col-md-2">
                                        <div class="form-group">
                                            <label class="control-label">&nbsp;</label>
                                            <div>
                                                <button type="button" class="btn btn-primary btn-block" id="btnApplyReportFilter">
                                                    <i class="fa fa-filter"></i> Lọc
                                                </button>
                                                <button type="button" class="btn btn-default btn-block" id="btnResetReportFilter" style="margin-top: 5px;">
                                                    <i class="fa fa-refresh"></i> Đặt lại
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                    
                    <div id="reportContent">
                        <div class="text-center">
                            <i class="fa fa-spinner fa-spin fa-2x"></i>
                            <p>Đang tải báo cáo...</p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
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
        var workOrderAssignedUsers = {}; // Map workOrderId -> [assigned user names]
        
        $(document).ready(function() {
            loadTechnicalStaff();
            loadWorkOrders();
            
            // Real-time validation for estimated hours (work order)
            $('#detail_estimated_hours').on('input', function() {
                var value = $(this).val();
                if (value && value.trim() !== '') {
                    var numValue = parseFloat(value);
                    if (!isNaN(numValue)) {
                        if (numValue <= 0) {
                            $(this).css('border-color', '#d9534f');
                        } else if (numValue > 100) {
                            $(this).css('border-color', '#d9534f');
                        } else {
                            $(this).css('border-color', '');
                        }
                    }
                } else {
                    $(this).css('border-color', '');
                }
            });
            
            // Real-time validation for estimated hours (task)
            // Validate estimated hours against total tasks estimated hours
            $(document).on('input blur', '#taskEstimatedHours', function() {
                var workOrderId = $('#assign_work_order_id').val();
                var estimatedHours = $(this).val();
                
                if (!estimatedHours || estimatedHours.trim() === '') {
                    return;
                }
                
                var hoursValue = parseFloat(estimatedHours);
                if (isNaN(hoursValue) || hoursValue <= 0) {
                    return;
                }
                
                // Check total estimated hours
                var workOrder = allWorkOrders.find(function(w) { return w.id == workOrderId; });
                if (workOrder && workOrder.estimatedHours) {
                    var workOrderHours = parseFloat(workOrder.estimatedHours);
                    if (!isNaN(workOrderHours) && workOrderHours > 0) {
                        // Load current tasks to calculate total
                        $.ajax({
                            url: ctx + '/api/work-order-tasks?action=list&workOrderId=' + workOrderId,
                            type: 'GET',
                            dataType: 'json',
                            success: function(response) {
                                if (response && response.success && response.data) {
                                    var tasks = response.data;
                                    var totalEstimatedHours = 0;
                                    tasks.forEach(function(task) {
                                        // Không tính các task có status = 'rejected' vào tổng giờ ước tính
                                        if (task.status !== 'rejected' && task.estimatedHours && !isNaN(parseFloat(task.estimatedHours))) {
                                            totalEstimatedHours += parseFloat(task.estimatedHours);
                                        }
                                    });
                                    
                                    // Add new task estimated hours
                                    var newTotal = totalEstimatedHours + hoursValue;
                                    var remaining = workOrderHours - totalEstimatedHours;
                                    
                                    // Show warning if exceeds
                                    var helpBlock = $('#taskEstimatedHours').next('.help-block');
                                    if (newTotal > workOrderHours) {
                                        if (remaining <= 0) {
                                            var warningMsg = '<span class="text-danger"><i class="fa fa-warning"></i> Tổng giờ ước tính của các công việc hiện tại (' + 
                                                totalEstimatedHours.toFixed(1) + 'h) đã đạt giờ ước tính của đơn hàng (' + workOrderHours.toFixed(1) + 'h).</span>';
                                            if (helpBlock.length) {
                                                helpBlock.html(warningMsg);
                                            } else {
                                                $('#taskEstimatedHours').after('<small class="help-block">' + warningMsg + '</small>');
                                            }
                                        } else {
                                            var warningMsg = '<span class="text-danger"><i class="fa fa-warning"></i> Nếu tạo công việc này, tổng sẽ là ' + 
                                                newTotal.toFixed(1) + 'h, vượt quá giờ ước tính của đơn hàng (' + workOrderHours.toFixed(1) + 'h). Còn lại: ' + 
                                                remaining.toFixed(1) + 'h.</span>';
                                            if (helpBlock.length) {
                                                helpBlock.html(warningMsg);
                                            } else {
                                                $('#taskEstimatedHours').after('<small class="help-block">' + warningMsg + '</small>');
                                            }
                                        }
                                    } else {
                                        // Update help text with remaining hours
                                        var helpText = 'Tối thiểu: 0.1h, Tối đa: ' + workOrderHours.toFixed(1) + 'h (giờ ước tính của đơn hàng). ';
                                        helpText += 'Đã sử dụng: ' + totalEstimatedHours.toFixed(1) + 'h, Còn lại: ' + (workOrderHours - totalEstimatedHours).toFixed(1) + 'h';
                                        if (helpBlock.length) {
                                            helpBlock.html(helpText);
                                        }
                                    }
                                }
                            },
                            error: function() {
                                // Ignore error, just use basic validation
                            }
                        });
                    }
                }
            });
            
            $(document).on('input', '#taskEstimatedHours', function() {
                var value = $(this).val();
                if (value && value.trim() !== '') {
                    var numValue = parseFloat(value);
                    if (!isNaN(numValue)) {
                        var workOrderId = $('#assign_work_order_id').val();
                        var workOrder = allWorkOrders.find(function(w) { return w.id == workOrderId; });
                        var maxHours = 100; // Default max
                        
                        if (workOrder && workOrder.estimatedHours) {
                            var workOrderHours = parseFloat(workOrder.estimatedHours);
                            if (!isNaN(workOrderHours) && workOrderHours > 0) {
                                maxHours = workOrderHours;
                            }
                        }
                        
                        if (numValue <= 0) {
                            $(this).css('border-color', '#d9534f');
                        } else if (numValue > maxHours) {
                            $(this).css('border-color', '#d9534f');
                        } else {
                            $(this).css('border-color', '');
                        }
                    }
                } else {
                    $(this).css('border-color', '');
                }
            });
            
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
            
            // Word count validation for technical solution
            $('#detail_technical_solution').on('input', function() {
                updateTechnicalSolutionCharCount();
            });
            
            // Validate character count on paste
            $('#detail_technical_solution').on('paste', function() {
                var self = this;
                setTimeout(function() {
                    var text = $(self).val() || '';
                    var charCount = text.length;
                    
                    // If exceeds limit, trim to 1000 characters
                    if (charCount > 1000) {
                        var trimmedText = text.substring(0, 1000);
                        $(self).val(trimmedText);
                        // Show warning
                        if (!$('#technical_solution_warning').length) {
                            $(self).after('<div id="technical_solution_warning" class="alert alert-warning" style="margin-top: 5px; padding: 5px 10px; font-size: 12px;"><i class="fa fa-exclamation-triangle"></i> Nội dung đã được tự động cắt xuống 1000 ký tự.</div>');
                            setTimeout(function() {
                                $('#technical_solution_warning').fadeOut(function() {
                                    $(this).remove();
                                });
                            }, 3000);
                        }
                    }
                    
                    updateTechnicalSolutionCharCount();
                }, 10);
            });
            
            // Finish work order
            $('#btnFinishWorkOrder').click(function() {
                finishWorkOrder();
            });
            
            // Enter to search
            $('#filterSearch').keypress(function(e) {
                if(e.which == 13) {
                    $('#btnFilter').click();
                }
            });
            
            // Reload assigned users when assign task modal is closed
            $('#assignTaskModal').on('hidden.bs.modal', function() {
                var workOrderId = $('#assign_work_order_id').val();
                if(workOrderId) {
                    // Reload assigned users to update the display
                    reloadAssignedUsersForWorkOrder(workOrderId);
                }
            });
            
            // Apply report filter
            $('#btnApplyReportFilter').click(function() {
                var workOrderId = $('#report_work_order_id').val();
                if(workOrderId) {
                    loadReportData(workOrderId);
                }
            });
            
            // Reset report filter
            $('#btnResetReportFilter').click(function() {
                $('#report_filter_start_date').val('');
                $('#report_filter_completion_date').val('');
                var workOrderId = $('#report_work_order_id').val();
                if(workOrderId) {
                    loadReportData(workOrderId);
                }
            });
            
            // Allow Enter key to trigger filter
            $('#report_filter_start_date, #report_filter_completion_date').keypress(function(e) {
                if(e.which == 13) {
                    $('#btnApplyReportFilter').click();
                }
            });
            
            $(document).on('change', '#assign_user_id', function() {
                var userId = $(this).val();
                if(userId && userId !== '') {
                    loadUserActiveTaskCount(userId);
                } else {
                    $('#userTaskCountInfo').hide();
                }
            });
            
            // Hide task count info when modal is closed
            $('#assignTaskUserModal').on('hidden.bs.modal', function() {
                $('#userTaskCountInfo').hide();
                $('#userActiveTasksList').hide();
                $('#userActiveTasksItems').empty();
                $('#assign_user_id').val('');
            });
            
            // Apply task filter when button is clicked
            $(document).on('click', '#btnApplyTaskFilter', function() {
                var workOrderId = $('#assign_work_order_id').val();
                if(workOrderId) {
                    loadTasks(workOrderId);
                }
            });
            
            // Also allow Enter key to trigger filter
            $(document).on('keypress', '#filterTaskPriority, #filterTaskStatus', function(e) {
                if(e.which == 13) {
                    $('#btnApplyTaskFilter').click();
                }
            });
            
            // Reset task filter
            $(document).on('click', '#btnResetTaskFilter', function() {
                $('#filterTaskPriority').val('');
                $('#filterTaskStatus').val('');
                var workOrderId = $('#assign_work_order_id').val();
                if(workOrderId) {
                    loadTasks(workOrderId);
                }
            });
        });
        
        function loadUserActiveTaskCount(userId) {
            $.ajax({
                url: ctx + '/api/work-order-tasks?action=activeTasks&userId=' + userId,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        var count = response.count || 0;
                        var tasks = response.tasks || [];
                        var userName = $('#assign_user_id option:selected').text();
                        
                        if(count > 0) {
                            var countText = 'Nhân viên <strong>' + userName + '</strong> đang thực hiện <strong>' + count + '</strong> công việc:';
                            $('#userTaskCountText').html(countText);
                            
                            // Hiển thị danh sách công việc
                            var tasksList = $('#userActiveTasksItems');
                            tasksList.empty();
                            tasks.forEach(function(task) {
                                var priorityBadge = '';
                                if(task.priority === 'high') {
                                    priorityBadge = '<span class="label label-danger">Cao</span>';
                                } else if(task.priority === 'medium') {
                                    priorityBadge = '<span class="label label-warning">Trung bình</span>';
                                } else {
                                    priorityBadge = '<span class="label label-info">Thấp</span>';
                                }
                                
                                var taskItem = '<li style="margin-bottom: 5px;">' +
                                    '<strong>' + (task.taskNumber || 'N/A') + '</strong> - ' +
                                    (task.taskDescription || 'Không có mô tả') +
                                    ' <small>(' + (task.workOrderNumber || 'N/A') + ': ' + (task.workOrderTitle || 'N/A') + ')</small> ' +
                                    priorityBadge +
                                    '</li>';
                                tasksList.append(taskItem);
                            });
                            
                            $('#userActiveTasksList').show();
                            $('#userTaskCountInfo').removeClass('text-danger text-warning text-success').addClass('text-info').show();
                        } else {
                            var countText = 'Nhân viên <strong>' + userName + '</strong> chưa có công việc nào đang thực hiện';
                            $('#userTaskCountText').html(countText);
                            $('#userActiveTasksList').hide();
                            $('#userTaskCountInfo').removeClass('text-danger text-warning text-info').addClass('text-success').show();
                        }
                    } else {
                        $('#userTaskCountInfo').hide();
                    }
                },
                error: function() {
                    console.log('Không thể tải danh sách công việc của nhân viên');
                    $('#userTaskCountInfo').hide();
                }
            });
        }
        
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
                timeout: 10000,
                success: function(response) {
                    console.log('Work orders response:', response);
                    if(response && response.success) {
                        allWorkOrders = response.data || [];
                        filteredWorkOrders = allWorkOrders;
                        console.log('Loaded ' + allWorkOrders.length + ' work orders');
                        // Load assigned users for all work orders (will call renderTable when done)
                        loadAllAssignedUsers();
                    } else {
                        console.error('Failed to load work orders:', response);
                        showError('Không thể tải dữ liệu: ' + (response ? response.message : 'Unknown error'));
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error loading work orders:', status, error, xhr);
                    showError('Lỗi kết nối máy chủ: ' + error);
                }
            });
        }
        
        function loadAllAssignedUsers() {
            // Reset map
            workOrderAssignedUsers = {};
            
            if(allWorkOrders.length === 0) {
                renderTable();
                return;
            }
            
            // Initialize all work orders with empty array first
            allWorkOrders.forEach(function(workOrder) {
                workOrderAssignedUsers[workOrder.id] = [];
            });
            
            // Render table immediately with empty assigned users
            renderTable();
            
            // Load tasks for all work orders
            var promises = allWorkOrders.map(function(workOrder) {
                return $.ajax({
                    url: ctx + '/api/work-order-tasks?action=list&workOrderId=' + workOrder.id,
                    type: 'GET',
                    dataType: 'json',
                    timeout: 5000
                }).then(function(response) {
                    if(response && response.success && response.data) {
                        var assignedUsers = new Set();
                        response.data.forEach(function(task) {
                            if(task.assignedToName && task.assignedToName.trim() !== '') {
                                assignedUsers.add(task.assignedToName);
                            }
                        });
                        workOrderAssignedUsers[workOrder.id] = Array.from(assignedUsers).sort();
                    } else {
                        workOrderAssignedUsers[workOrder.id] = [];
                    }
                }).catch(function(error) {
                    console.log('Error loading tasks for work order ' + workOrder.id + ':', error);
                    workOrderAssignedUsers[workOrder.id] = [];
                });
            });
            
            // Wait for all requests to complete, then render table again with updated data
            $.when.apply($, promises).always(function() {
                renderTable();
            });
        }
        
        function reloadAssignedUsersForWorkOrder(workOrderId) {
            // Reload assigned users for a specific work order
            $.ajax({
                url: ctx + '/api/work-order-tasks?action=list&workOrderId=' + workOrderId,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if(response && response.success && response.data) {
                        var assignedUsers = new Set();
                        response.data.forEach(function(task) {
                            if(task.assignedToName && task.assignedToName.trim() !== '') {
                                assignedUsers.add(task.assignedToName);
                            }
                        });
                        workOrderAssignedUsers[workOrderId] = Array.from(assignedUsers).sort();
                    } else {
                        workOrderAssignedUsers[workOrderId] = [];
                    }
                    // Re-render table to update the display
                    renderTable();
                },
                error: function() {
                    workOrderAssignedUsers[workOrderId] = [];
                    renderTable();
                }
            });
        }
        
        function applyFilters() {
            var search = $('#filterSearch').val().toLowerCase();
            
            filteredWorkOrders = allWorkOrders.filter(function(workOrder) {
                var matchSearch = !search || 
                    (workOrder.workOrderNumber && workOrder.workOrderNumber.toLowerCase().includes(search)) ||
                    (workOrder.title && workOrder.title.toLowerCase().includes(search)) ||
                    (workOrder.description && workOrder.description.toLowerCase().includes(search)) ||
                    (workOrder.customerName && workOrder.customerName.toLowerCase().includes(search));
                
                return matchSearch;
            });
            
            renderTable();
        }
        
        function renderTable() {
            var tbody = $('#workOrdersTableBody');
            tbody.empty();
            
            if(!filteredWorkOrders || filteredWorkOrders.length === 0) {
                tbody.append('<tr><td colspan="6" class="text-center">Không có dữ liệu</td></tr>');
                return;
            }
            
            filteredWorkOrders.forEach(function(workOrder) {
                var customerName = workOrder.customerName || 'N/A';
                var title = workOrder.title || '';
                var estimatedHours = workOrder.estimatedHours ? workOrder.estimatedHours + 'h' : '-';
                
                // Escape HTML for tooltip
                var escapedCustomerName = customerName.replace(/"/g, '&quot;').replace(/'/g, '&#39;');
                var escapedTitle = title.replace(/"/g, '&quot;').replace(/'/g, '&#39;');
                
                // Kiểm tra nếu work order đã completed/cancelled/rejected hoặc đã hoàn thành thì ẩn nút Chia việc
                var isFinished = workOrder.completionDate && workOrder.status === 'in_progress';
                var isWorkOrderClosed = workOrder.status === 'completed' || workOrder.status === 'cancelled' || workOrder.status === 'rejected' || isFinished;
                var assignTaskButton = '';
                if (!isWorkOrderClosed) {
                    assignTaskButton = '<button class="btn btn-success btn-assign-task" data-id="' + workOrder.id + '" title="Chia việc">' +
                        '<i class="fa fa-tasks"></i>' +
                    '</button>';
                } else {
                    var disabledTitle = 'Không thể chia việc cho đơn hàng đã đóng';
                    if (isFinished) {
                        disabledTitle = 'Không thể chia việc cho đơn hàng đã hoàn thành';
                    }
                    assignTaskButton = '<button class="btn btn-success btn-assign-task" disabled data-id="' + workOrder.id + '" title="' + disabledTitle + '">' +
                        '<i class="fa fa-tasks"></i>' +
                    '</button>';
                }
                
                var row = '<tr>' +
                    '<td><strong>' + (workOrder.workOrderNumber || '#' + workOrder.id) + '</strong></td>' +
                    '<td><span class="work-order-customer" title="' + escapedCustomerName + '" data-toggle="tooltip">' + customerName + '</span></td>' +
                    '<td><span class="work-order-title" title="' + escapedTitle + '" data-toggle="tooltip">' + title + '</span></td>' +
                    '<td class="text-center">' + estimatedHours + '</td>' +
                    '<td>' + formatDate(workOrder.createdAt) + '</td>' +
                    '<td class="work-order-actions">' +
                        '<button class="btn btn-info btn-view" data-id="' + workOrder.id + '" title="Xem chi tiết">' +
                            '<i class="fa fa-eye"></i>' +
                        '</button>' +
                        assignTaskButton +
                        '<button class="btn btn-warning btn-report" data-id="' + workOrder.id + '" title="Báo cáo">' +
                            '<i class="fa fa-file-text-o"></i>' +
                        '</button>' +
                    '</td>' +
                '</tr>';
                tbody.append(row);
            });
            
            // Initialize tooltips for work orders table
            $('[data-toggle="tooltip"]').tooltip();
            
            // Bind view button
            $('.btn-view').click(function() {
                var id = $(this).data('id');
                viewWorkOrderDetail(id);
            });
            
            // Bind assign task button
            $('.btn-assign-task').click(function() {
                var id = $(this).data('id');
                var workOrder = allWorkOrders.find(function(w) { return w.id == id; });
                var isFinished = workOrder && workOrder.completionDate && workOrder.status === 'in_progress';
                if (workOrder && (workOrder.status === 'completed' || workOrder.status === 'cancelled' || workOrder.status === 'rejected' || isFinished)) {
                    if (isFinished) {
                        alert('Không thể chia việc cho đơn hàng đã hoàn thành!');
                    } else {
                        alert('Không thể chia việc cho đơn hàng đã đóng!');
                    }
                    return;
                }
                openAssignTaskModal(id);
            });
            
            // Bind report button
            $('.btn-report').click(function() {
                var id = $(this).data('id');
                openReportModal(id);
            });
            
            // Khởi tạo DataTable với phân trang
            initializeDataTable();
        }
        
        var workOrdersDataTable = null;
        
        function initializeDataTable() {
            // Kiểm tra xem DataTables đã được load chưa
            if (typeof $.fn.DataTable === 'undefined') {
                console.error('DataTables library is not loaded');
                return;
            }
            
            // Kiểm tra và destroy DataTable nếu đã tồn tại
            if ($.fn.DataTable.isDataTable('#workOrdersTable')) {
                try {
                    $('#workOrdersTable').DataTable().destroy();
                    workOrdersDataTable = null;
                } catch(e) {
                    console.log('Error destroying DataTable:', e);
                }
            }
            
            // Nếu biến workOrdersDataTable vẫn còn, reset nó
            if (workOrdersDataTable) {
                workOrdersDataTable = null;
            }
            
            // Khởi tạo DataTable
            try {
                workOrdersDataTable = $('#workOrdersTable').DataTable({
                    "language": {
                        "url": "//cdn.datatables.net/plug-ins/1.10.24/i18n/Vietnamese.json"
                    },
                    "pageLength": 8, // Hiển thị 8 bản ghi mỗi trang
                    "lengthChange": false, // Ẩn dropdown "records per page"
                    "paging": true, // Bật phân trang
                    "pagingType": "full_numbers", // Hiển thị số trang đầy đủ (Previous, 1, 2, 3, ..., Next)
                    "info": true, // Hiển thị thông tin "Showing X to Y of Z entries"
                    "dom": '<"top"lf>rt<"bottom"ip><"clear">', // Cấu trúc DOM: top (length, filter), table, bottom (info, pagination)
                    "order": [[4, "desc"]], // Sắp xếp theo Ngày tạo (column 4) giảm dần
                    "columnDefs": [
                        { "orderable": false, "targets": 5 } // Không sort cột Thao tác (cột cuối cùng)
                    ],
                    "drawCallback": function(settings) {
                        // Đảm bảo phân trang luôn hiển thị
                        var wrapper = $(this).closest('.dataTables_wrapper');
                        var paginate = wrapper.find('.dataTables_paginate');
                        if (paginate.length) {
                            paginate.css({
                                'display': 'block',
                                'visibility': 'visible',
                                'opacity': '1'
                            }).show();
                            
                            // Đảm bảo tất cả các nút phân trang đều hiển thị
                            paginate.find('.paginate_button').each(function() {
                                $(this).css({
                                    'display': 'inline-block',
                                    'visibility': 'visible'
                                }).show();
                            });
                        }
                    },
                    "initComplete": function(settings, json) {
                        // Sau khi khởi tạo xong, đảm bảo phân trang hiển thị
                        var wrapper = $(this).closest('.dataTables_wrapper');
                        var paginate = wrapper.find('.dataTables_paginate');
                        if (paginate.length) {
                            paginate.removeAttr('style');
                            paginate.css({
                                'display': 'block',
                                'visibility': 'visible',
                                'opacity': '1'
                            }).show();
                            
                            // Đảm bảo tất cả các nút phân trang đều hiển thị
                            paginate.find('.paginate_button').each(function() {
                                $(this).css({
                                    'display': 'inline-block',
                                    'visibility': 'visible'
                                }).show();
                            });
                        }
                        
                        // Force show pagination after a short delay
                        setTimeout(function() {
                            var paginate = wrapper.find('.dataTables_paginate');
                            if (paginate.length) {
                                paginate.css({
                                    'display': 'block !important',
                                    'visibility': 'visible !important',
                                    'opacity': '1 !important'
                                }).show();
                                
                                // Force show all pagination buttons
                                paginate.find('.paginate_button').each(function() {
                                    $(this).css({
                                        'display': 'inline-block',
                                        'visibility': 'visible'
                                    }).show();
                                });
                            }
                        }, 200);
                    }
                });
                console.log('DataTable initialized successfully');
            } catch(e) {
                console.error('Error initializing DataTable:', e);
            }
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
                'cancelled': 'Đã hủy',
                'rejected': 'Đã từ chối'
            };
            var badge = status ? 'badge-' + status : '';
            // Nếu là rejected, dùng màu đỏ (có thể dùng badge-danger)
            if(status === 'rejected') {
                badge = 'badge-danger';
            }
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
        
        // Function to count characters in text (for technical solution)
        function countCharacters(text) {
            if (!text) {
                return 0;
            }
            return text.length;
        }
        
        // Function to update character count display for technical solution
        function updateTechnicalSolutionCharCount() {
            var textarea = $('#detail_technical_solution');
            var text = textarea.val() || '';
            var charCount = text.length;
            var maxChars = 1000;
            
            $('#technical_solution_char_count').text(charCount);
            
            // Change color based on character count
            if (charCount > maxChars) {
                $('#technical_solution_char_count').removeClass('text-info text-warning').addClass('text-danger');
            } else if (charCount > maxChars * 0.9) {
                $('#technical_solution_char_count').removeClass('text-info text-danger').addClass('text-warning');
            } else {
                $('#technical_solution_char_count').removeClass('text-warning text-danger').addClass('text-info');
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
            $('#detail_created').text(formatDate(workOrder.createdAt));
            $('#detail_estimated_hours').val(workOrder.estimatedHours || '');
            var technicalSolutionValue = workOrder.technicalSolution || '';
            $('#detail_technical_solution').val(technicalSolutionValue);
            
            // Update character count for technical solution - use setTimeout to ensure textarea value is set
            setTimeout(function() {
                updateTechnicalSolutionCharCount();
            }, 100);
            
            // Tính actualHours từ tổng actualHours của các tasks
            calculateAndUpdateActualHours(id);
            
            // Set scheduledDate từ createdAt nếu chưa có
            if (workOrder.scheduledDate) {
                $('#detail_scheduled_date').val(workOrder.scheduledDate);
            } else if (workOrder.createdAt) {
                // Format createdAt thành date string (YYYY-MM-DD)
                var createdDate = new Date(workOrder.createdAt);
                var year = createdDate.getFullYear();
                var month = String(createdDate.getMonth() + 1).padStart(2, '0');
                var day = String(createdDate.getDate()).padStart(2, '0');
                $('#detail_scheduled_date').val(year + '-' + month + '-' + day);
            } else {
                $('#detail_scheduled_date').val('');
            }
            
            // Set completion date vào input field (format YYYY-MM-DD cho input type="date")
            if (workOrder.completionDate) {
                try {
                    var completionDate = new Date(workOrder.completionDate);
                    var year = completionDate.getFullYear();
                    var month = String(completionDate.getMonth() + 1).padStart(2, '0');
                    var day = String(completionDate.getDate()).padStart(2, '0');
                    var dateString = year + '-' + month + '-' + day;
                    $('#detail_completion_date').val(dateString);
                } catch(e) {
                    // Nếu completionDate là string format YYYY-MM-DD, dùng trực tiếp
                    if (workOrder.completionDate.includes('T')) {
                        var datePart = workOrder.completionDate.split('T')[0];
                        $('#detail_completion_date').val(datePart);
                    } else {
                        $('#detail_completion_date').val(workOrder.completionDate);
                    }
                }
            } else {
                $('#detail_completion_date').val('');
            }
            
            // Set min date cho completion_date = scheduled_date (không cho chọn trước ngày lên lịch)
            var scheduledDate = $('#detail_scheduled_date').val();
            if (scheduledDate) {
                $('#detail_completion_date').attr('min', scheduledDate);
                
                // Format scheduledDate để hiển thị trong help text
                var scheduledDateObj = new Date(scheduledDate);
                var day = String(scheduledDateObj.getDate()).padStart(2, '0');
                var month = String(scheduledDateObj.getMonth() + 1).padStart(2, '0');
                var year = scheduledDateObj.getFullYear();
                var scheduledDateStr = day + '/' + month + '/' + year;
                $('#completionDateHelp').text('Ngày hoàn thành phải từ ngày ' + scheduledDateStr + ' trở đi');
            } else {
                $('#detail_completion_date').removeAttr('min');
                $('#completionDateHelp').text('');
            }
            
            // Validate khi user thay đổi completion date
            $('#detail_completion_date').off('change.completionDateValidation').on('change.completionDateValidation', function() {
                var completionDate = $(this).val();
                var scheduledDate = $('#detail_scheduled_date').val();
                
                if (completionDate && scheduledDate) {
                    var completionDateObj = new Date(completionDate);
                    var scheduledDateObj = new Date(scheduledDate);
                    
                    completionDateObj.setHours(0, 0, 0, 0);
                    scheduledDateObj.setHours(0, 0, 0, 0);
                    
                    if (completionDateObj < scheduledDateObj) {
                        var compDay = String(completionDateObj.getDate()).padStart(2, '0');
                        var compMonth = String(completionDateObj.getMonth() + 1).padStart(2, '0');
                        var compYear = completionDateObj.getFullYear();
                        var schedDay = String(scheduledDateObj.getDate()).padStart(2, '0');
                        var schedMonth = String(scheduledDateObj.getMonth() + 1).padStart(2, '0');
                        var schedYear = scheduledDateObj.getFullYear();
                        
                        alert('✗ Lỗi: Ngày hoàn thành (' + compDay + '/' + compMonth + '/' + compYear + ') ' +
                            'không được trước ngày lên lịch (' + schedDay + '/' + schedMonth + '/' + schedYear + ').\n\n' +
                            'Vui lòng chọn ngày hoàn thành từ ngày lên lịch trở đi.');
                        
                        // Reset về giá trị hợp lệ hoặc rỗng
                        $(this).val('');
                        return;
                    }
                }
            });
            
            // Load danh sách người đã được phân công từ các task
            loadAssignedUsers(id);
            
            // Kiểm tra nếu work order đã hoàn thành (có completion_date nhưng status là in_progress)
            var isFinished = workOrder.completionDate && workOrder.status === 'in_progress';
            
            // Hiển thị/ẩn nút "Hoàn thành đơn hàng"
            if (workOrder.status === 'completed' || workOrder.status === 'cancelled' || workOrder.status === 'rejected' || isFinished) {
                $('#btnFinishWorkOrder').hide();
            } else {
                $('#btnFinishWorkOrder').show();
            }
            
            // Disable form fields và nút lưu nếu work order đã đóng hoặc đã hoàn thành
            var workOrderStatus = workOrder.status;
            if (workOrderStatus === 'completed' || workOrderStatus === 'cancelled' || workOrderStatus === 'rejected' || isFinished) {
                // Disable tất cả input fields trong modal (trừ các field đã readonly)
                $('#workOrderDetailModal').find('input:not([readonly]), textarea:not([readonly]), select:not([disabled])').prop('readonly', true);
                
                // Ẩn nút "Lưu thay đổi"
                $('#btnSaveWorkOrder').hide();
                
                // Hiển thị thông báo
                var statusText = '';
                if (workOrderStatus === 'completed') {
                    statusText = 'Đã hoàn thành';
                } else if (workOrderStatus === 'cancelled') {
                    statusText = 'Đã hủy';
                } else if (workOrderStatus === 'rejected') {
                    statusText = 'Đã từ chối';
                } else if (isFinished) {
                    statusText = 'Đã hoàn thành';
                }
                
                // Xóa alert cũ nếu có và thêm alert mới
                $('#workOrderDetailLockedAlert').remove();
                $('#workOrderDetailModal .modal-body').first().prepend(
                    '<div class="alert alert-warning" id="workOrderDetailLockedAlert" style="margin-bottom: 15px;">' +
                    '<i class="fa fa-lock"></i> <strong>Đơn hàng ' + statusText + '.</strong> ' +
                    'Không thể chỉnh sửa thông tin đơn hàng này.' +
                    '</div>'
                );
            } else {
                // Enable tất cả input fields
                $('#workOrderDetailModal').find('input[readonly], textarea[readonly]').not('#detail_scheduled_date, #detail_estimated_hours, #detail_actual_hours, #detail_assigned_to').prop('readonly', false);
                
                // Hiển thị nút "Lưu thay đổi"
                $('#btnSaveWorkOrder').show();
                
                // Ẩn alert nếu có
                $('#workOrderDetailLockedAlert').remove();
            }
            
            // Load customer deadline
            loadCustomerDeadlineForWorkOrderDetail(workOrder);
            
            // Update word count for technical solution
            updateTechnicalSolutionCharCount();
            
            $('#workOrderDetailModal').modal('show');
        }
        
        // Function to calculate actualHours from tasks
        function calculateAndUpdateActualHours(workOrderId) {
            $.ajax({
                url: ctx + '/api/work-order-tasks?action=list&workOrderId=' + workOrderId,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success && response.data) {
                        var tasks = response.data;
                        var totalActualHours = 0;
                        
                        tasks.forEach(function(task) {
                            if (task.actualHours && !isNaN(parseFloat(task.actualHours))) {
                                totalActualHours += parseFloat(task.actualHours);
                            }
                        });
                        
                        // Update actualHours field
                        if (totalActualHours > 0) {
                            $('#detail_actual_hours').val(totalActualHours.toFixed(2));
                        } else {
                            $('#detail_actual_hours').val('');
                        }
                    }
                },
                error: function(xhr, status, error) {
                    console.log('Error calculating actual hours:', error);
                }
            });
        }
        
        function loadAssignedUsers(workOrderId) {
            $.ajax({
                url: ctx + '/api/work-order-tasks?action=list&workOrderId=' + workOrderId,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if(response && response.success && response.data) {
                        var assignedUsers = new Set();
                        response.data.forEach(function(task) {
                            if(task.assignedToName && task.assignedToName.trim() !== '') {
                                assignedUsers.add(task.assignedToName);
                            }
                        });
                        
                        var assignedList = Array.from(assignedUsers).sort();
                        if(assignedList.length > 0) {
                            $('#detail_assigned_to').val(assignedList.join('\n'));
                        } else {
                            $('#detail_assigned_to').val('Chưa có nhân viên nào được phân công');
                        }
                    } else {
                        $('#detail_assigned_to').val('Chưa có nhân viên nào được phân công');
                    }
                },
                error: function() {
                    $('#detail_assigned_to').val('Không thể tải danh sách phân công');
                }
            });
        }
        
        function saveWorkOrderChanges() {
            var id = $('#detail_work_order_id').val();
            
            // Validate technical solution character count
            var technicalSolution = $('#detail_technical_solution').val() || '';
            var charCount = technicalSolution.length;
            if (charCount > 1000) {
                alert('Giải pháp kỹ thuật không được vượt quá 1000 ký tự. Hiện tại bạn đã nhập ' + charCount + ' ký tự. Vui lòng rút gọn nội dung.');
                return;
            }
            
            // Kiểm tra nếu work order đã đóng (completed, cancelled, rejected) thì không cho phép lưu thay đổi
            var workOrder = allWorkOrders.find(function(w) { return w.id == id; });
            if (workOrder) {
                var status = workOrder.status;
                if (status === 'completed' || status === 'cancelled' || status === 'rejected') {
                    var statusText = '';
                    if (status === 'completed') {
                        statusText = 'hoàn thành';
                    } else if (status === 'cancelled') {
                        statusText = 'hủy';
                    } else if (status === 'rejected') {
                        statusText = 'từ chối';
                    }
                    alert('✗ Không thể lưu thay đổi!\n\n' +
                        'Đơn hàng này đã ' + statusText + ' và không thể chỉnh sửa nữa.\n\n' +
                        'Vui lòng kiểm tra lại trạng thái đơn hàng.');
                    return;
                }
            }
            
            // Validate completion date không được trước scheduled date
            var completionDate = $('#detail_completion_date').val();
            var scheduledDate = $('#detail_scheduled_date').val();
            
            if (completionDate && scheduledDate) {
                var completionDateObj = new Date(completionDate);
                var scheduledDateObj = new Date(scheduledDate);
                
                // Reset time to compare dates only
                completionDateObj.setHours(0, 0, 0, 0);
                scheduledDateObj.setHours(0, 0, 0, 0);
                
                if (completionDateObj < scheduledDateObj) {
                    // Format dates for display
                    var compDay = String(completionDateObj.getDate()).padStart(2, '0');
                    var compMonth = String(completionDateObj.getMonth() + 1).padStart(2, '0');
                    var compYear = completionDateObj.getFullYear();
                    var schedDay = String(scheduledDateObj.getDate()).padStart(2, '0');
                    var schedMonth = String(scheduledDateObj.getMonth() + 1).padStart(2, '0');
                    var schedYear = scheduledDateObj.getFullYear();
                    
                    alert('✗ Lỗi: Ngày hoàn thành (' + compDay + '/' + compMonth + '/' + compYear + ') ' +
                        'không được trước ngày lên lịch (' + schedDay + '/' + schedMonth + '/' + schedYear + ').\n\n' +
                        'Vui lòng chọn ngày hoàn thành từ ngày lên lịch trở đi.');
                    $('#detail_completion_date').focus();
                    return;
                }
            }
            
            // Không cần validate estimatedHours vì không cho phép sửa
            // Không cần gửi estimatedHours, actualHours, scheduledDate vì:
            // - estimatedHours: không cho phép sửa
            // - actualHours: tự động tính từ tasks ở server
            // - scheduledDate: không cho phép sửa (trùng với createdAt)
            
            var technicalSolutionValue = $('#detail_technical_solution').val();
            console.log('=== SAVING WORK ORDER ===');
            console.log('Work Order ID:', id);
            console.log('Technical Solution value:', technicalSolutionValue ? (technicalSolutionValue.substring(0, 100) + (technicalSolutionValue.length > 100 ? '...' : '')) : '(empty)');
            console.log('Technical Solution length:', technicalSolutionValue ? technicalSolutionValue.length : 0);
            
            var data = {
                action: 'update',
                id: id,
                completionDate: $('#detail_completion_date').val(),
                technicalSolution: technicalSolutionValue
            };
            
            console.log('Sending data to server:', {
                action: data.action,
                id: data.id,
                completionDate: data.completionDate,
                technicalSolution: data.technicalSolution ? (data.technicalSolution.substring(0, 50) + '...') : '(empty)'
            });
            
            $.ajax({
                url: ctx + '/api/work-orders',
                type: 'POST',
                data: data,
                dataType: 'json',
                success: function(response) {
                    console.log('Server response:', response);
                    if(response && response.success) {
                        alert('Cập nhật thành công!');
                        $('#workOrderDetailModal').modal('hide');
                        loadWorkOrders();
                    } else {
                        var errorMsg = response.message || 'Không thể cập nhật';
                        console.error('Update failed:', errorMsg);
                        alert('Lỗi: ' + errorMsg);
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX error:', status, error);
                    console.error('Response text:', xhr.responseText);
                    alert('Lỗi kết nối máy chủ: ' + error);
                }
            });
        }
        
        function finishWorkOrder() {
            var id = $('#detail_work_order_id').val();
            
            // Validate completion date không được trước scheduled date
            var completionDate = $('#detail_completion_date').val();
            var scheduledDate = $('#detail_scheduled_date').val();
            
            if (completionDate && scheduledDate) {
                var completionDateObj = new Date(completionDate);
                var scheduledDateObj = new Date(scheduledDate);
                
                // Reset time to compare dates only
                completionDateObj.setHours(0, 0, 0, 0);
                scheduledDateObj.setHours(0, 0, 0, 0);
                
                if (completionDateObj < scheduledDateObj) {
                    // Format dates for display
                    var compDay = String(completionDateObj.getDate()).padStart(2, '0');
                    var compMonth = String(completionDateObj.getMonth() + 1).padStart(2, '0');
                    var compYear = completionDateObj.getFullYear();
                    var schedDay = String(scheduledDateObj.getDate()).padStart(2, '0');
                    var schedMonth = String(scheduledDateObj.getMonth() + 1).padStart(2, '0');
                    var schedYear = scheduledDateObj.getFullYear();
                    
                    alert('✗ Lỗi: Ngày hoàn thành (' + compDay + '/' + compMonth + '/' + compYear + ') ' +
                        'không được trước ngày lên lịch (' + schedDay + '/' + schedMonth + '/' + schedYear + ').\n\n' +
                        'Vui lòng chọn ngày hoàn thành từ ngày lên lịch trở đi.');
                    $('#detail_completion_date').focus();
                    return;
                }
            }
            
            // Kiểm tra tasks chưa hoàn thành trước
            $.ajax({
                url: ctx + '/api/work-order-tasks',
                type: 'GET',
                data: {
                    action: 'getIncompleteTaskCounts',
                    workOrderId: id
                },
                dataType: 'json',
                success: function(response) {
                    if (response && response.success) {
                        var pendingCount = response.pendingCount || 0;
                        var inProgressCount = response.inProgressCount || 0;
                        var totalCount = response.totalCount || 0;
                        
                        if (totalCount > 0) {
                            var errorMessage = '✗ Lỗi: Không thể hoàn thành đơn hàng!\n\n';
                            errorMessage += 'Vẫn còn ' + totalCount + ' nhiệm vụ chưa hoàn thành:\n';
                            if (pendingCount > 0) {
                                errorMessage += '• ' + pendingCount + ' nhiệm vụ đang chờ xử lý (pending)\n';
                            }
                            if (inProgressCount > 0) {
                                errorMessage += '• ' + inProgressCount + ' nhiệm vụ đang thực hiện (in_progress)\n';
                            }
                            errorMessage += '\nVui lòng hoàn thành tất cả nhiệm vụ trước khi hoàn thành đơn hàng.';
                            alert(errorMessage);
                            console.log('Cannot finish work order - incomplete tasks:', {
                                pending: pendingCount,
                                inProgress: inProgressCount,
                                total: totalCount
                            });
                            return;
                        }
                        
                        // Nếu không có tasks chưa hoàn thành, tiếp tục với confirm và finish
                        proceedWithFinishWorkOrder(id);
                    } else {
                        // Nếu không lấy được thông tin tasks, vẫn tiếp tục (fallback)
                        console.warn('Could not check incomplete tasks, proceeding anyway');
                        proceedWithFinishWorkOrder(id);
                    }
                },
                error: function() {
                    // Nếu có lỗi khi kiểm tra, vẫn tiếp tục (fallback)
                    console.warn('Error checking incomplete tasks, proceeding anyway');
                    proceedWithFinishWorkOrder(id);
                }
            });
        }
        
        function proceedWithFinishWorkOrder(id) {
            // Confirm before finishing
            if(!confirm('Bạn có chắc chắn muốn hoàn thành đơn hàng này?')) {
                return;
            }
            
            // Send completion date from input (if set)
            var completionDateValue = $('#detail_completion_date').val();
            
            $.ajax({
                url: ctx + '/api/work-orders',
                type: 'POST',
                data: {
                    action: 'finish',
                    id: id,
                    completionDate: completionDateValue || ''
                },
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        alert('✓ Hoàn thành đơn hàng thành công!');
                        
                        // Update completion date in modal (if not already set)
                        if (completionDateValue) {
                            $('#detail_completion_date').val(completionDateValue);
                        }
                        
                        // Update work order in local array
                        var workOrder = allWorkOrders.find(function(w) { return w.id == id; });
                        if (workOrder) {
                            workOrder.completionDate = completionDateValue || new Date().toISOString().split('T')[0];
                        }
                        
                        // Disable form và ẩn nút lưu và nút hoàn thành
                        $('#workOrderDetailModal').find('input:not([readonly]), textarea:not([readonly]), select:not([disabled])').prop('readonly', true);
                        $('#btnSaveWorkOrder').hide();
                        $('#btnFinishWorkOrder').hide();
                        
                        // Remove alert if exists
                        $('#workOrderDetailLockedAlert').remove();
                        
                        // Reload work orders list
                        loadWorkOrders();
                    } else {
                        var errorMsg = response.message || 'Không thể hoàn thành đơn hàng';
                        alert('✗ Lỗi: ' + errorMsg);
                    }
                },
                error: function() {
                    alert('✗ Lỗi kết nối máy chủ');
                }
            });
        }
        
        function showError(msg) {
            $('#workOrdersTableBody').html('<tr><td colspan="6" class="text-center text-danger">' + msg + '</td></tr>');
        }
        
        // Functions for task management
        
        /**
         * Load available users for task assignment (exclude users đã từ chối task)
         */
        function loadAvailableUsersForTaskAssignment(taskId) {
            var url = ctx + '/api/work-order-tasks?action=getAvailableUsers';
            if (taskId && taskId > 0) {
                url += '&taskId=' + taskId;
            }
            
            $.ajax({
                url: url,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response && response.success && response.data) {
                        var select = $('#assign_user_id');
                        select.empty();
                        select.append('<option value="">Chọn nhân viên...</option>');
                        
                        response.data.forEach(function(user) {
                            select.append('<option value="' + user.id + '">' + user.fullName + '</option>');
                        });
                        
                        if (response.excludedCount && response.excludedCount > 0) {
                            console.log('Đã loại bỏ ' + response.excludedCount + ' nhân viên đã từ chối task này');
                        }
                    } else {
                        // Fallback: load all technical staff nếu API fail
                        console.warn('Không thể load available users, sử dụng danh sách tất cả technical staff');
                        var select = $('#assign_user_id');
                        select.empty();
                        select.append('<option value="">Chọn nhân viên...</option>');
                        if (typeof technicalStaff !== 'undefined' && technicalStaff.length > 0) {
                            technicalStaff.forEach(function(staff) {
                                select.append('<option value="' + staff.id + '">' + staff.fullName + '</option>');
                            });
                        }
                    }
                },
                error: function() {
                    // Fallback: load all technical staff nếu API fail
                    console.warn('Error loading available users, sử dụng danh sách tất cả technical staff');
                    var select = $('#assign_user_id');
                    select.empty();
                    select.append('<option value="">Chọn nhân viên...</option>');
                    if (typeof technicalStaff !== 'undefined' && technicalStaff.length > 0) {
                        technicalStaff.forEach(function(staff) {
                            select.append('<option value="' + staff.id + '">' + staff.fullName + '</option>');
                        });
                    }
                }
            });
        }
        
        function openAssignTaskModal(workOrderId) {
            // Kiểm tra work order status trước khi mở modal
            var workOrder = allWorkOrders.find(function(w) { return w.id == workOrderId; });
            var isFinished = workOrder && workOrder.completionDate && workOrder.status === 'in_progress';
            if (workOrder && (workOrder.status === 'completed' || workOrder.status === 'cancelled' || workOrder.status === 'rejected' || isFinished)) {
                if (isFinished) {
                    alert('Không thể chia việc cho đơn hàng đã hoàn thành!');
                } else {
                    alert('Không thể chia việc cho đơn hàng đã đóng!');
                }
                return;
            }
            
            $('#assign_work_order_id').val(workOrderId);
            // Reset filters when opening modal
            $('#filterTaskPriority').val('');
            $('#filterTaskStatus').val('');
            
            // Check work order status and disable form if completed/cancelled
            if (workOrder) {
                var status = workOrder.status;
                
                // Lấy giờ ước tính của work order và cập nhật max cho input taskEstimatedHours
                var workOrderEstimatedHours = workOrder.estimatedHours;
                if (workOrderEstimatedHours && parseFloat(workOrderEstimatedHours) > 0) {
                    // Cập nhật max attribute của input field
                    $('#taskEstimatedHours').attr('max', workOrderEstimatedHours);
                    // Cập nhật help text
                    var helpText = 'Tối thiểu: 0.1h, Tối đa: ' + parseFloat(workOrderEstimatedHours).toFixed(1) + 'h (giờ ước tính của đơn hàng)';
                    var helpBlock = $('#taskEstimatedHours').next('.help-block');
                    if (helpBlock.length) {
                        helpBlock.text(helpText);
                    } else {
                        $('#taskEstimatedHours').after('<small class="help-block">' + helpText + '</small>');
                    }
                } else {
                    // Nếu work order không có giờ ước tính, giữ max = 100
                    $('#taskEstimatedHours').attr('max', '100');
                    var helpBlock = $('#taskEstimatedHours').next('.help-block');
                    if (helpBlock.length) {
                        helpBlock.text('Tối thiểu: 0.1h, Tối đa: 100h');
                    }
                }
                
                if (status === 'completed' || status === 'cancelled' || status === 'rejected') {
                    // Show alert and disable form
                    var statusText = '';
                    var statusLabel = '';
                    if (status === 'completed') {
                        statusText = 'hoàn thành';
                        statusLabel = 'Đã hoàn thành';
                    } else if (status === 'cancelled') {
                        statusText = 'hủy';
                        statusLabel = 'Đã hủy';
                    } else if (status === 'rejected') {
                        statusText = 'từ chối';
                        statusLabel = 'Đã từ chối';
                    }
                    
                    $('#workOrderClosedAlert').show();
                    $('#workOrderClosedMessage').html(
                        '<strong>Đơn hàng này đã ' + statusText + '.</strong><br>' +
                        'Không thể tạo thêm công việc mới cho đơn hàng đã ' + statusText + '.<br>' +
                        '<small class="text-muted">Trạng thái: <span class="label label-warning">' + statusLabel + '</span></small>'
                    );
                    
                    // Disable form and change box style
                    $('#addTaskForm').find('input, textarea, select, button').prop('disabled', true);
                    $('#addTaskForm').closest('.box').removeClass('box-success').addClass('box-warning');
                    $('#addTaskForm').closest('.box').find('.box-title').html(
                        '<i class="fa fa-lock"></i> Thêm công việc mới <span class="label label-warning">Đã khóa</span>'
                    );
                } else {
                    // Hide alert and enable form
                    $('#workOrderClosedAlert').hide();
                    $('#addTaskForm').find('input, textarea, select, button').prop('disabled', false);
                    $('#addTaskForm').closest('.box').removeClass('box-warning').addClass('box-success');
                    $('#addTaskForm').closest('.box').find('.box-title').html('Thêm công việc mới');
                }
            } else {
                // Work order not found, hide alert and enable form
                $('#workOrderClosedAlert').hide();
                $('#addTaskForm').find('input, textarea, select, button').prop('disabled', false);
                $('#addTaskForm').closest('.box').removeClass('box-warning').addClass('box-success');
            }
            
            // Set minimum date for date fields
            setMinDateForTaskCreateDates();
            
            // Load deadline from support request
            loadWorkOrderDeadline(workOrderId);
            
            // Load customer deadline for display
            loadCustomerDeadlineForAssignment(workOrderId);
            
            $('#assignTaskModal').modal('show');
            loadTasks(workOrderId);
            // Note: Users are loaded when opening assignTaskUserModal via loadAvailableUsersForTaskAssignment
        }
        
        // Load deadline from support request for work order
        function loadWorkOrderDeadline(workOrderId) {
            var workOrder = allWorkOrders.find(function(w) { return w.id == workOrderId; });
            if (!workOrder) {
                // Clear deadline if work order not found
                $('#taskStartDate').removeData('workOrderDeadline');
                $('#taskDeadline').removeData('workOrderDeadline');
                return;
            }
            
            // Try to get deadline from support request
            // First, try with ticketId if available
            if (workOrder.supportRequestId) {
                $.ajax({
                    url: ctx + '/support-detail',
                    type: 'GET',
                    data: {
                        id: workOrder.supportRequestId
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response && response.success && response.data && response.data.deadline) {
                            var deadlineStr = response.data.deadline;
                            parseAndStoreDeadline(deadlineStr);
                        } else {
                            // Try fallback: find by customerId and title
                            findDeadlineByCustomerAndTitle(workOrder.customerId, workOrder.title);
                        }
                    },
                    error: function() {
                        // Try fallback: find by customerId and title
                        findDeadlineByCustomerAndTitle(workOrder.customerId, workOrder.title);
                    }
                });
            } else {
                // No ticketId, try to find by customerId and title
                findDeadlineByCustomerAndTitle(workOrder.customerId, workOrder.title);
            }
        }
        
        // Helper function to find deadline by customerId and title
        function findDeadlineByCustomerAndTitle(customerId, title) {
            if (!customerId || !title) {
                $('#taskStartDate').removeData('workOrderDeadline');
                $('#taskDeadline').removeData('workOrderDeadline');
                return;
            }
            
            // Use getSupportRequestBySubjectAndCustomer via a workaround
            // Since there's no direct API, we'll try to get deadline from work order's ticket ID first
            // If that fails, we'll show "Chưa có deadline"
            console.warn('Cannot load deadline by customer and title - no direct API available');
            $('#taskStartDate').removeData('workOrderDeadline');
            $('#taskDeadline').removeData('workOrderDeadline');
        }
        
        // Helper function to parse and store deadline
        function parseAndStoreDeadline(deadlineStr) {
            if (deadlineStr && deadlineStr !== '' && deadlineStr !== 'null') {
                try {
                    var deadlineDate = null;
                    // If deadline is in dd/MM/yyyy format
                    if (deadlineStr.match(/^\d{2}\/\d{2}\/\d{4}$/)) {
                        var parts = deadlineStr.split('/');
                        deadlineDate = parts[2] + '-' + parts[1] + '-' + parts[0];
                    } else if (deadlineStr.match(/^\d{4}-\d{2}-\d{2}$/)) {
                        // Already in yyyy-MM-dd format
                        deadlineDate = deadlineStr;
                    } else {
                        // Try to parse as Date and convert to yyyy-MM-dd
                        var date = new Date(deadlineStr);
                        if (!isNaN(date.getTime())) {
                            var year = date.getFullYear();
                            var month = String(date.getMonth() + 1).padStart(2, '0');
                            var day = String(date.getDate()).padStart(2, '0');
                            deadlineDate = year + '-' + month + '-' + day;
                        }
                    }
                    
                    if (deadlineDate) {
                        // Store deadline in data attribute
                        $('#taskStartDate').data('workOrderDeadline', deadlineDate);
                        $('#taskDeadline').data('workOrderDeadline', deadlineDate);
                        console.log('✓ Deadline loaded and stored:', deadlineDate);
                        // Update max attribute for date inputs
                        $('#taskStartDate').attr('max', deadlineDate);
                        $('#taskDeadline').attr('max', deadlineDate);
                    } else {
                        console.warn('⚠ Could not parse deadline:', deadlineStr);
                    }
                } catch (e) {
                    console.warn('Error parsing deadline:', e);
                    $('#taskStartDate').removeData('workOrderDeadline');
                    $('#taskDeadline').removeData('workOrderDeadline');
                }
            } else {
                $('#taskStartDate').removeData('workOrderDeadline');
                $('#taskDeadline').removeData('workOrderDeadline');
            }
        }
        
        function loadTasks(workOrderId) {
            // Tính lại actualHours khi load tasks (nếu đang xem chi tiết work order)
            if ($('#detail_work_order_id').val() == workOrderId) {
                calculateAndUpdateActualHours(workOrderId);
            }
            
            var priority = $('#filterTaskPriority').val() || '';
            var status = $('#filterTaskStatus').val() || '';
            
            var url = ctx + '/api/work-order-tasks?action=list&workOrderId=' + workOrderId;
            if(priority) {
                url += '&priority=' + encodeURIComponent(priority);
            }
            if(status) {
                url += '&status=' + encodeURIComponent(status);
            }
            
            $.ajax({
                url: url,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        renderTasksTable(response.data);
                    } else {
                        $('#tasksTableBody').html('<tr><td colspan="11" class="text-center">Không có công việc nào</td></tr>');
                    }
                },
                error: function() {
                    $('#tasksTableBody').html('<tr><td colspan="11" class="text-center text-danger">Lỗi tải dữ liệu</td></tr>');
                }
            });
        }
        
        function renderTasksTable(tasks) {
            console.log('Rendering tasks:', tasks);
            var tbody = $('#tasksTableBody');
            tbody.empty();
            
            if(!tasks || tasks.length === 0) {
                tbody.append('<tr><td colspan="11" class="text-center">Chưa có công việc nào</td></tr>');
                return;
            }
            
            tasks.forEach(function(task) {
                console.log('Task:', task, 'assignedToName:', task.assignedToName);
                var assignedName = task.assignedToName || 'Chưa phân công';
                var assignedBadge = task.assignedToName ? 
                    '<span class="label label-success">' + assignedName + '</span>' : 
                    '<span class="label label-info">' + assignedName + '</span>';
                
                // Kiểm tra nếu task đã hoàn thành
                var isCompleted = task.status === 'completed';
                var assignButton = '';
                if(isCompleted) {
                    // Nếu đã hoàn thành, hiển thị thông báo thay vì nút phân công
                    assignButton = '<span class="text-muted" style="font-size: 11px;"><i class="fa fa-info-circle"></i> Đã hoàn thành</span>';
                } else {
                    // Nếu chưa hoàn thành, hiển thị nút phân công
                    assignButton = '<button class="btn btn-xs btn-primary btn-assign-to-user" data-task-id="' + task.id + '" data-task-desc="' + (task.taskDescription || '') + '" data-task-status="' + (task.status || '') + '">' +
                        '<i class="fa fa-user"></i> Phân công' +
                    '</button>';
                }
                
                // Hiển thị lý do từ chối/hủy
                var rejectionReasonCell = '';
                if((task.status === 'rejected' || task.status === 'cancelled') && task.rejectionReason && task.rejectionReason.trim() !== '') {
                    // Hiển thị lý do từ chối trong cột riêng
                    var reasonText = task.rejectionReason;
                    // Nếu lý do dài, chỉ hiển thị một phần và có tooltip
                    if(reasonText.length > 40) {
                        var shortReason = reasonText.substring(0, 40) + '...';
                        var escapedReason = task.rejectionReason
                            .replace(/&/g, '&amp;')
                            .replace(/</g, '&lt;')
                            .replace(/>/g, '&gt;')
                            .replace(/"/g, '&quot;')
                            .replace(/'/g, '&#39;');
                        rejectionReasonCell = '<span title="' + escapedReason + '" data-toggle="tooltip" data-placement="top" style="color: #d9534f; cursor: help; font-size: 11px;">' + shortReason + '</span>';
                    } else {
                        rejectionReasonCell = '<span style="color: #d9534f; font-size: 11px;">' + reasonText + '</span>';
                    }
                } else {
                    rejectionReasonCell = '<span class="text-muted">-</span>';
                }
                
                var statusCell = getStatusBadge(task.status);
                
                // Xử lý mô tả công việc với tooltip
                var taskDescription = task.taskDescription || '';
                var escapedTaskDesc = taskDescription
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;')
                    .replace(/'/g, '&#39;');
                
                // Nếu mô tả dài hơn 60 ký tự, hiển thị rút gọn với tooltip
                var taskDescDisplay = taskDescription;
                if(taskDescription.length > 60) {
                    taskDescDisplay = taskDescription.substring(0, 60) + '...';
                }
                
                // Nút xóa - chỉ hiển thị nếu task chưa hoàn thành
                var deleteButton = '';
                if(task.status === 'completed') {
                    // Task đã hoàn thành - không cho phép xóa
                    deleteButton = '<button class="btn btn-xs btn-default" disabled title="Không thể xóa nhiệm vụ đã hoàn thành" style="margin-left: 5px;">' +
                        '<i class="fa fa-ban"></i> Không thể xóa' +
                    '</button>';
                } else {
                    // Task chưa hoàn thành - cho phép xóa
                    deleteButton = '<button class="btn btn-xs btn-danger btn-delete-task" data-task-id="' + task.id + '" data-task-status="' + (task.status || '') + '" style="margin-left: 5px;">' +
                        '<i class="fa fa-trash"></i> Xóa' +
                    '</button>';
                }
                
                // Format giờ ước tính
                var estimatedHoursDisplay = '-';
                if (task.estimatedHours && parseFloat(task.estimatedHours) > 0) {
                    estimatedHoursDisplay = '<strong>' + parseFloat(task.estimatedHours).toFixed(1) + 'h</strong>';
                }
                
                // Format ngày giao việc (start_date)
                var startDateDisplay = '-';
                if (task.startDate) {
                    try {
                        var startDate = new Date(task.startDate);
                        var day = String(startDate.getDate()).padStart(2, '0');
                        var month = String(startDate.getMonth() + 1).padStart(2, '0');
                        var year = startDate.getFullYear();
                        startDateDisplay = day + '/' + month + '/' + year;
                    } catch(e) {
                        startDateDisplay = '-';
                    }
                }
                
                // Format deadline
                var deadlineDisplay = '-';
                if (task.deadline) {
                    try {
                        var deadline = new Date(task.deadline);
                        var day = String(deadline.getDate()).padStart(2, '0');
                        var month = String(deadline.getMonth() + 1).padStart(2, '0');
                        var year = deadline.getFullYear();
                        deadlineDisplay = day + '/' + month + '/' + year;
                        
                        // Kiểm tra nếu deadline đã qua (màu đỏ nếu quá hạn)
                        var today = new Date();
                        today.setHours(0, 0, 0, 0);
                        deadline.setHours(0, 0, 0, 0);
                        if (deadline < today && task.status !== 'completed') {
                            deadlineDisplay = '<span class="text-danger" style="font-weight: bold;" title="Đã quá hạn">' + deadlineDisplay + ' ⚠</span>';
                        }
                    } catch(e) {
                        deadlineDisplay = '-';
                    }
                }
                
                // Format ngày hoàn thành
                var completionDateDisplay = '-';
                if (task.completionDate) {
                    try {
                        var completionDate = new Date(task.completionDate);
                        var day = String(completionDate.getDate()).padStart(2, '0');
                        var month = String(completionDate.getMonth() + 1).padStart(2, '0');
                        var year = completionDate.getFullYear();
                        completionDateDisplay = day + '/' + month + '/' + year;
                        
                        // Nếu task đã hoàn thành, hiển thị màu xanh với icon
                        if (task.status === 'completed') {
                            completionDateDisplay = '<span class="text-success" style="font-weight: bold;" title="Đã hoàn thành"><i class="fa fa-check-circle"></i> ' + completionDateDisplay + '</span>';
                        }
                    } catch(e) {
                        completionDateDisplay = '-';
                    }
                }
                
                var row = '<tr>' +
                    '<td><strong>' + (task.taskNumber || 'N/A') + '</strong></td>' +
                    '<td><span class="task-description-text" title="' + escapedTaskDesc + '" data-toggle="tooltip">' + taskDescDisplay + '</span></td>' +
                    '<td>' + getPriorityBadge(task.priority) + '</td>' +
                    '<td class="text-center">' + estimatedHoursDisplay + '</td>' +
                    '<td class="text-center">' + startDateDisplay + '</td>' +
                    '<td class="text-center">' + deadlineDisplay + '</td>' +
                    '<td class="text-center">' + completionDateDisplay + '</td>' +
                    '<td>' + statusCell + '</td>' +
                    '<td>' + assignedBadge + '</td>' +
                    '<td>' + rejectionReasonCell + '</td>' +
                    '<td>' +
                        assignButton +
                        deleteButton +
                    '</td>' +
                '</tr>';
                tbody.append(row);
            });
            
            // Bind assign button
            $('.btn-assign-to-user').click(function() {
                var taskId = $(this).data('task-id');
                var taskDesc = $(this).data('task-desc');
                var taskStatus = $(this).data('task-status');
                
                // Kiểm tra lại status trước khi mở modal
                if(taskStatus === 'completed') {
                    alert('Công việc đã hoàn thành không thể giao cho người khác');
                    return;
                }
                
                // Kiểm tra work order status
                var workOrderId = $('#assign_work_order_id').val();
                var workOrder = null;
                if (workOrderId) {
                    workOrder = allWorkOrders.find(function(w) { return w.id == parseInt(workOrderId); });
                }
                if (!workOrder) {
                    var detailWorkOrderId = $('#detail_work_order_id').val();
                    if (detailWorkOrderId) {
                        workOrder = allWorkOrders.find(function(w) { return w.id == parseInt(detailWorkOrderId); });
                    }
                }
                if (workOrder && (workOrder.status === 'completed' || workOrder.status === 'cancelled' || workOrder.status === 'rejected')) {
                    alert('Không thể phân công công việc cho đơn hàng đã đóng!');
                    return;
                }
                
                openAssignUserModal(taskId, taskDesc);
            });
            
            // Bind delete button
            $('.btn-delete-task').click(function() {
                var taskId = $(this).data('task-id');
                var taskStatus = $(this).data('task-status');
                
                // Kiểm tra lại status trước khi xóa
                if(taskStatus === 'completed') {
                    alert('Không thể xóa nhiệm vụ đã hoàn thành!');
                    return;
                }
                
                deleteTask(taskId);
            });
            
            // Initialize tooltips for rejection reason
            $('[data-toggle="tooltip"]').tooltip();
        }
        
        function openAssignUserModal(taskId, taskDescription) {
            // Kiểm tra lại status của task trước khi mở modal
            // Tìm task trong danh sách tasks hiện tại
            var workOrderId = $('#assign_work_order_id').val();
            if(!workOrderId) {
                alert('Không tìm thấy đơn hàng công việc');
                return;
            }
            
            // Kiểm tra work order status trước
            var workOrder = allWorkOrders.find(function(w) { return w.id == parseInt(workOrderId); });
            if (workOrder && (workOrder.status === 'completed' || workOrder.status === 'cancelled' || workOrder.status === 'rejected')) {
                alert('Không thể phân công công việc cho đơn hàng đã đóng!');
                return;
            }
            
            // Load lại task để kiểm tra status
            $.ajax({
                url: ctx + '/api/work-order-tasks?action=list&workOrderId=' + workOrderId,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if(response && response.success && response.data) {
                        var task = response.data.find(function(t) { return t.id == taskId; });
                        if(!task) {
                            alert('Không tìm thấy công việc');
                            return;
                        }
                        
                        // Kiểm tra work order status một lần nữa sau khi load
                        var workOrder = allWorkOrders.find(function(w) { return w.id == parseInt(workOrderId); });
                        if (workOrder && (workOrder.status === 'completed' || workOrder.status === 'cancelled' || workOrder.status === 'rejected')) {
                            alert('Không thể phân công công việc cho đơn hàng đã đóng!');
                            // Reload lại danh sách tasks để cập nhật UI
                            loadTasks(workOrderId);
                            return;
                        }
                        
                        // Kiểm tra status
                        if(task.status === 'completed') {
                            alert('Công việc đã hoàn thành không thể giao cho người khác');
                            // Reload lại danh sách tasks để cập nhật UI
                            loadTasks(workOrderId);
                            return;
                        }
                        
                        // Nếu chưa hoàn thành, mở modal phân công
                        $('#assign_task_id').val(taskId);
                        $('#assign_task_description').text(taskDescription);
                        $('#assign_user_id').val('');
                        
                        // Load available users (exclude users đã từ chối task này)
                        loadAvailableUsersForTaskAssignment(taskId);
                        
                        // Hide task count info when modal opens
                        $('#userTaskCountInfo').hide();
                        
                        $('#assignTaskUserModal').modal('show');
                    } else {
                        alert('Không thể tải thông tin công việc');
                    }
                },
                error: function() {
                    alert('Lỗi kết nối máy chủ');
                }
            });
        }
        
        // Load customer deadline for assignment modal (Chia việc cho nhân viên)
        function loadCustomerDeadlineForAssignment(workOrderId) {
            console.log('DEBUG: loadCustomerDeadlineForAssignment called with workOrderId:', workOrderId);
            var workOrder = allWorkOrders.find(function(w) { return w.id == parseInt(workOrderId); });
            console.log('DEBUG: Found workOrder:', workOrder);
            
            if (!workOrder) {
                $('#customer_deadline_text').text('Không tìm thấy đơn hàng công việc');
                return;
            }
            
            // Set default text
            $('#customer_deadline_text').text('Đang tải...');
            
            // Try to get deadline from support request
            // Method 1: Extract ticket ID from description if available
            var ticketId = null;
            if (workOrder.description && workOrder.description.indexOf('[TICKET_ID:') !== -1) {
                try {
                    var desc = workOrder.description;
                    var startIdx = desc.indexOf('[TICKET_ID:') + 11;
                    var endIdx = desc.indexOf(']', startIdx);
                    if (endIdx > startIdx) {
                        var ticketIdStr = desc.substring(startIdx, endIdx).trim();
                        ticketId = parseInt(ticketIdStr);
                        console.log('DEBUG: Extracted ticketId from description:', ticketId);
                    }
                } catch (e) {
                    console.error('DEBUG: Error extracting ticket ID from description:', e);
                }
            }
            
            // Method 2: Use supportRequestId if available
            if (!ticketId && workOrder.supportRequestId) {
                ticketId = workOrder.supportRequestId;
                console.log('DEBUG: Using supportRequestId:', ticketId);
            }
            
            if (ticketId) {
                // Use WorkOrderServlet endpoint to get deadline (no permission check needed)
                $.ajax({
                    url: ctx + '/api/work-orders',
                    type: 'GET',
                    data: {
                        action: 'getTicketDeadline',
                        ticketId: ticketId
                    },
                    dataType: 'json',
                    success: function(response) {
                        console.log('DEBUG: getTicketDeadline response:', response);
                        
                        if (response && response.success && response.deadline) {
                            var deadlineStr = response.deadline;
                            console.log('DEBUG: Found deadline from getTicketDeadline:', deadlineStr);
                            
                            if (deadlineStr && deadlineStr !== '' && deadlineStr !== 'null' && deadlineStr !== null) {
                                formatAndDisplayDeadline(deadlineStr);
                                return; // Success, don't try fallback
                            }
                        }
                        
                        // If we get here, deadline not found, try fallback
                        console.log('DEBUG: No deadline found in getTicketDeadline, trying fallback');
                        findDeadlineByCustomerAndTitleForAssignment(workOrder.customerId, workOrder.title);
                    },
                    error: function(xhr, status, error) {
                        console.error('DEBUG: Error loading getTicketDeadline:', status, error, xhr);
                        // Try fallback: find by customerId and title
                        findDeadlineByCustomerAndTitleForAssignment(workOrder.customerId, workOrder.title);
                    }
                });
            } else {
                console.log('DEBUG: No ticketId found, trying fallback with customerId:', workOrder.customerId, 'title:', workOrder.title);
                // No ticketId, try to find by customerId and title
                findDeadlineByCustomerAndTitleForAssignment(workOrder.customerId, workOrder.title);
            }
        }
        
        // Helper function to find deadline by customerId and title for assignment modal
        function findDeadlineByCustomerAndTitleForAssignment(customerId, title) {
            console.log('DEBUG: findDeadlineByCustomerAndTitleForAssignment called with customerId:', customerId, 'title:', title);
            
            if (!customerId || !title) {
                console.log('DEBUG: Missing customerId or title');
                $('#customer_deadline_text').text('Không có thông tin');
                return;
            }
            
            // Use WorkOrderServlet endpoint to get deadline by customerId and title
            $.ajax({
                url: ctx + '/api/work-orders',
                type: 'GET',
                data: {
                    action: 'getTicketDeadlineByCustomerAndTitle',
                    customerId: customerId,
                    title: title
                },
                dataType: 'json',
                success: function(response) {
                    console.log('DEBUG: getTicketDeadlineByCustomerAndTitle response:', response);
                    
                    if (response && response.success && response.deadline) {
                        var deadlineStr = response.deadline;
                        console.log('DEBUG: Found deadline from getTicketDeadlineByCustomerAndTitle:', deadlineStr);
                        
                        if (deadlineStr && deadlineStr !== '' && deadlineStr !== 'null' && deadlineStr !== null) {
                            formatAndDisplayDeadline(deadlineStr);
                        } else {
                            console.log('DEBUG: Deadline is empty/null');
                            $('#customer_deadline_text').text('Chưa có deadline');
                        }
                    } else {
                        console.log('DEBUG: No deadline found or invalid response');
                        $('#customer_deadline_text').text('Chưa có deadline');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('DEBUG: Error loading getTicketDeadlineByCustomerAndTitle:', status, error);
                    $('#customer_deadline_text').text('Không thể tải deadline');
                }
            });
        }
        
        // Load customer deadline for tasks table
        function loadCustomerDeadlineForTasksTable(workOrder, workOrderId) {
            console.log('DEBUG: loadCustomerDeadlineForTasksTable called with workOrderId:', workOrderId);
            
            if (!workOrder) {
                updateCustomerDeadlineCells(workOrderId, 'Không có thông tin');
                return;
            }
            
            // Try to get deadline from support request
            var ticketId = null;
            if (workOrder.description && workOrder.description.indexOf('[TICKET_ID:') !== -1) {
                try {
                    var desc = workOrder.description;
                    var startIdx = desc.indexOf('[TICKET_ID:') + 11;
                    var endIdx = desc.indexOf(']', startIdx);
                    if (endIdx > startIdx) {
                        var ticketIdStr = desc.substring(startIdx, endIdx).trim();
                        ticketId = parseInt(ticketIdStr);
                        console.log('DEBUG: Extracted ticketId from description:', ticketId);
                    }
                } catch (e) {
                    console.error('DEBUG: Error extracting ticket ID from description:', e);
                }
            }
            
            // Use supportRequestId if available
            if (!ticketId && workOrder.supportRequestId) {
                ticketId = workOrder.supportRequestId;
                console.log('DEBUG: Using supportRequestId:', ticketId);
            }
            
            if (ticketId) {
                // Use WorkOrderServlet endpoint to get deadline
                $.ajax({
                    url: ctx + '/api/work-orders',
                    type: 'GET',
                    data: {
                        action: 'getTicketDeadline',
                        ticketId: ticketId
                    },
                    dataType: 'json',
                    success: function(response) {
                        console.log('DEBUG: getTicketDeadline response for tasks table:', response);
                        
                        if (response && response.success && response.deadline) {
                            var deadlineStr = response.deadline;
                            var formattedDeadline = formatDeadlineForDisplay(deadlineStr);
                            updateCustomerDeadlineCells(workOrderId, formattedDeadline);
                            return;
                        }
                        
                        // Fallback: try by customerId and title
                        findDeadlineByCustomerAndTitleForTasksTable(workOrder.customerId, workOrder.title, workOrderId);
                    },
                    error: function(xhr, status, error) {
                        console.error('DEBUG: Error loading getTicketDeadline for tasks table:', status, error);
                        // Fallback: try by customerId and title
                        findDeadlineByCustomerAndTitleForTasksTable(workOrder.customerId, workOrder.title, workOrderId);
                    }
                });
            } else {
                // No ticketId, try to find by customerId and title
                findDeadlineByCustomerAndTitleForTasksTable(workOrder.customerId, workOrder.title, workOrderId);
            }
        }
        
        // Helper function to find deadline by customerId and title for tasks table
        function findDeadlineByCustomerAndTitleForTasksTable(customerId, title, workOrderId) {
            console.log('DEBUG: findDeadlineByCustomerAndTitleForTasksTable called with customerId:', customerId, 'title:', title);
            
            if (!customerId || !title) {
                console.log('DEBUG: Missing customerId or title');
                updateCustomerDeadlineCells(workOrderId, 'Không có thông tin');
                return;
            }
            
            $.ajax({
                url: ctx + '/api/work-orders',
                type: 'GET',
                data: {
                    action: 'getTicketDeadlineByCustomerAndTitle',
                    customerId: customerId,
                    title: title
                },
                dataType: 'json',
                success: function(response) {
                    console.log('DEBUG: getTicketDeadlineByCustomerAndTitle response for tasks table:', response);
                    
                    if (response && response.success && response.deadline) {
                        var deadlineStr = response.deadline;
                        var formattedDeadline = formatDeadlineForDisplay(deadlineStr);
                        updateCustomerDeadlineCells(workOrderId, formattedDeadline);
                    } else {
                        updateCustomerDeadlineCells(workOrderId, 'Chưa có deadline');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('DEBUG: Error loading getTicketDeadlineByCustomerAndTitle for tasks table:', status, error);
                    updateCustomerDeadlineCells(workOrderId, 'Không thể tải deadline');
                }
            });
        }
        
        // Load customer deadline for work order detail modal
        function loadCustomerDeadlineForWorkOrderDetail(workOrder) {
            console.log('DEBUG: loadCustomerDeadlineForWorkOrderDetail called with workOrder:', workOrder);
            
            // Set default text
            $('#detail_customer_deadline_text').text('Đang tải...');
            
            if (!workOrder) {
                $('#detail_customer_deadline_text').text('Không có thông tin');
                return;
            }
            
            // Try to get deadline from support request
            var ticketId = null;
            if (workOrder.description && workOrder.description.indexOf('[TICKET_ID:') !== -1) {
                try {
                    var desc = workOrder.description;
                    var startIdx = desc.indexOf('[TICKET_ID:') + 11;
                    var endIdx = desc.indexOf(']', startIdx);
                    if (endIdx > startIdx) {
                        var ticketIdStr = desc.substring(startIdx, endIdx).trim();
                        ticketId = parseInt(ticketIdStr);
                        console.log('DEBUG: Extracted ticketId from description:', ticketId);
                    }
                } catch (e) {
                    console.error('DEBUG: Error extracting ticket ID from description:', e);
                }
            }
            
            // Use supportRequestId if available
            if (!ticketId && workOrder.supportRequestId) {
                ticketId = workOrder.supportRequestId;
                console.log('DEBUG: Using supportRequestId:', ticketId);
            }
            
            if (ticketId) {
                // Use WorkOrderServlet endpoint to get deadline
                $.ajax({
                    url: ctx + '/api/work-orders',
                    type: 'GET',
                    data: {
                        action: 'getTicketDeadline',
                        ticketId: ticketId
                    },
                    dataType: 'json',
                    success: function(response) {
                        console.log('DEBUG: getTicketDeadline response for work order detail:', response);
                        
                        if (response && response.success && response.deadline) {
                            var deadlineStr = response.deadline;
                            var formattedDeadline = formatDeadlineForDisplay(deadlineStr);
                            $('#detail_customer_deadline_text').text(formattedDeadline);
                            return;
                        }
                        
                        // Fallback: try by customerId and title
                        findDeadlineByCustomerAndTitleForWorkOrderDetail(workOrder.customerId, workOrder.title);
                    },
                    error: function(xhr, status, error) {
                        console.error('DEBUG: Error loading getTicketDeadline for work order detail:', status, error);
                        // Fallback: try by customerId and title
                        findDeadlineByCustomerAndTitleForWorkOrderDetail(workOrder.customerId, workOrder.title);
                    }
                });
            } else {
                // No ticketId, try to find by customerId and title
                findDeadlineByCustomerAndTitleForWorkOrderDetail(workOrder.customerId, workOrder.title);
            }
        }
        
        // Helper function to find deadline by customerId and title for work order detail
        function findDeadlineByCustomerAndTitleForWorkOrderDetail(customerId, title) {
            console.log('DEBUG: findDeadlineByCustomerAndTitleForWorkOrderDetail called with customerId:', customerId, 'title:', title);
            
            if (!customerId || !title) {
                console.log('DEBUG: Missing customerId or title');
                $('#detail_customer_deadline_text').text('Không có thông tin');
                return;
            }
            
            $.ajax({
                url: ctx + '/api/work-orders',
                type: 'GET',
                data: {
                    action: 'getTicketDeadlineByCustomerAndTitle',
                    customerId: customerId,
                    title: title
                },
                dataType: 'json',
                success: function(response) {
                    console.log('DEBUG: getTicketDeadlineByCustomerAndTitle response for work order detail:', response);
                    
                    if (response && response.success && response.deadline) {
                        var deadlineStr = response.deadline;
                        var formattedDeadline = formatDeadlineForDisplay(deadlineStr);
                        $('#detail_customer_deadline_text').text(formattedDeadline);
                    } else {
                        $('#detail_customer_deadline_text').text('Chưa có deadline');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('DEBUG: Error loading getTicketDeadlineByCustomerAndTitle for work order detail:', status, error);
                    $('#detail_customer_deadline_text').text('Không thể tải deadline');
                }
            });
        }
        
        // Helper function to format deadline for display
        function formatDeadlineForDisplay(deadlineStr) {
            if (!deadlineStr || deadlineStr === '' || deadlineStr === 'null' || deadlineStr === null) {
                return 'Chưa có deadline';
            }
            
            try {
                deadlineStr = String(deadlineStr).trim();
                
                // If deadline is in dd/MM/yyyy format
                if (deadlineStr.match(/^\d{2}\/\d{2}\/\d{4}$/)) {
                    return deadlineStr;
                } else if (deadlineStr.match(/^\d{4}-\d{2}-\d{2}$/)) {
                    // yyyy-MM-dd format
                    var parts = deadlineStr.split('-');
                    return parts[2] + '/' + parts[1] + '/' + parts[0];
                } else if (deadlineStr.match(/^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}/)) {
                    // yyyy-MM-dd HH:mm:ss format
                    var datePart = deadlineStr.split(' ')[0];
                    var parts = datePart.split('-');
                    return parts[2] + '/' + parts[1] + '/' + parts[0];
                } else {
                    // Try to parse as Date
                    var deadlineDate = new Date(deadlineStr);
                    if (!isNaN(deadlineDate.getTime())) {
                        var day = String(deadlineDate.getDate()).padStart(2, '0');
                        var month = String(deadlineDate.getMonth() + 1).padStart(2, '0');
                        var year = deadlineDate.getFullYear();
                        return day + '/' + month + '/' + year;
                    }
                }
            } catch (e) {
                console.error('DEBUG: Error formatting deadline:', e);
            }
            
            return 'Không hợp lệ';
        }
        
        // Helper function to update all customer deadline cells in tasks table
        function updateCustomerDeadlineCells(workOrderId, deadlineText) {
            $('.customer-deadline-cell[data-work-order-id="' + workOrderId + '"]').each(function() {
                // Highlight in red if deadline is important
                if (deadlineText && deadlineText !== 'Chưa có deadline' && deadlineText !== 'Không có thông tin' && deadlineText !== 'Không thể tải deadline' && deadlineText !== 'Không hợp lệ') {
                    $(this).html('<span class="text-danger" style="font-weight: bold;"><i class="fa fa-calendar"></i> ' + deadlineText + '</span>');
                } else {
                    $(this).html('<span class="text-muted">' + deadlineText + '</span>');
                }
            });
        }
        
        // Helper function to format and display deadline
        function formatAndDisplayDeadline(deadlineStr) {
            console.log('DEBUG: formatAndDisplayDeadline called with:', deadlineStr);
            
            if (!deadlineStr || deadlineStr === '' || deadlineStr === 'null' || deadlineStr === null) {
                console.log('DEBUG: deadlineStr is empty/null');
                $('#customer_deadline_text').text('Chưa có deadline');
                return;
            }
            
            try {
                var displayDate = '';
                
                // Trim whitespace
                deadlineStr = String(deadlineStr).trim();
                console.log('DEBUG: deadlineStr after trim:', deadlineStr);
                
                // If deadline is in dd/MM/yyyy format (from SupportDetailServlet)
                if (deadlineStr.match(/^\d{2}\/\d{2}\/\d{4}$/)) {
                    console.log('DEBUG: Matched dd/MM/yyyy format');
                    displayDate = deadlineStr; // Keep original format
                } else if (deadlineStr.match(/^\d{4}-\d{2}-\d{2}$/)) {
                    // Already in yyyy-MM-dd format
                    console.log('DEBUG: Matched yyyy-MM-dd format');
                    var parts = deadlineStr.split('-');
                    displayDate = parts[2] + '/' + parts[1] + '/' + parts[0]; // Convert to dd/MM/yyyy
                } else if (deadlineStr.match(/^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}/)) {
                    // Format: yyyy-MM-dd HH:mm:ss
                    console.log('DEBUG: Matched yyyy-MM-dd HH:mm:ss format');
                    var datePart = deadlineStr.split(' ')[0];
                    var parts = datePart.split('-');
                    displayDate = parts[2] + '/' + parts[1] + '/' + parts[0];
                } else {
                    // Try to parse as Date
                    console.log('DEBUG: Trying to parse as Date object');
                    var deadlineDate = new Date(deadlineStr);
                    if (!isNaN(deadlineDate.getTime())) {
                        var day = String(deadlineDate.getDate()).padStart(2, '0');
                        var month = String(deadlineDate.getMonth() + 1).padStart(2, '0');
                        var year = deadlineDate.getFullYear();
                        displayDate = day + '/' + month + '/' + year;
                        console.log('DEBUG: Parsed date:', displayDate);
                    } else {
                        console.log('DEBUG: Failed to parse as Date');
                    }
                }
                
                if (displayDate) {
                    console.log('DEBUG: Setting displayDate to:', displayDate);
                    $('#customer_deadline_text').text(displayDate);
                } else {
                    console.log('DEBUG: displayDate is empty, showing error');
                    $('#customer_deadline_text').text('Định dạng không hợp lệ: ' + deadlineStr);
                }
            } catch (e) {
                console.error('DEBUG: Exception in formatAndDisplayDeadline:', e);
                $('#customer_deadline_text').text('Lỗi định dạng ngày: ' + e.message);
            }
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
                        alert('✓ Xóa công việc thành công!');
                        var workOrderId = $('#assign_work_order_id').val();
                        loadTasks(workOrderId);
                        // Reload assigned users and update table
                        reloadAssignedUsersForWorkOrder(workOrderId);
                    } else {
                        var errorMsg = response.message || 'Không thể xóa công việc';
                        if(errorMsg.includes('đã hoàn thành')) {
                            alert('✗ ' + errorMsg + '\n\nNhiệm vụ đã hoàn thành không thể xóa.');
                            // Reload tasks to update UI
                            var workOrderId = $('#assign_work_order_id').val();
                            loadTasks(workOrderId);
                        } else {
                            alert('✗ Lỗi: ' + errorMsg);
                        }
                    }
                },
                error: function() {
                    alert('✗ Lỗi kết nối máy chủ');
                }
            });
        }
        
        // Character counter for task description
        $(document).on('input', '#taskDescription', function() {
            var length = $(this).val().length;
            var maxLength = 150;
            $('#taskDescriptionCounter').text(length);
            
            // Update counter color based on length
            if(length >= maxLength) {
                $('#taskDescriptionCounter').removeClass('text-warning').addClass('text-danger');
                $('#taskDescriptionError').text('Đã đạt giới hạn tối đa 150 ký tự').show();
            } else if(length > maxLength * 0.9) {
                $('#taskDescriptionCounter').removeClass('text-danger').addClass('text-warning');
                $('#taskDescriptionError').hide();
            } else {
                $('#taskDescriptionCounter').removeClass('text-danger text-warning');
                $('#taskDescriptionError').hide();
            }
        });
        
        // Initialize counter on page load or modal open
        $(document).on('shown.bs.modal', '#assignTaskModal', function() {
            // Set minimum date for date fields
            setMinDateForTaskCreateDates();
            var length = $('#taskDescription').val().length;
            $('#taskDescriptionCounter').text(length);
            
            // Ensure deadline is loaded - reload if needed
            var workOrderId = $('#assign_work_order_id').val();
            if (workOrderId) {
                var workOrderDeadline = $('#taskStartDate').data('workOrderDeadline');
                if (!workOrderDeadline) {
                    // Reload deadline if not available
                    loadWorkOrderDeadline(workOrderId);
                }
            }
        });
        
        // Form submit handler for adding new task
        $(document).on('submit', '#addTaskForm', function(e) {
            e.preventDefault();
            
            var workOrderId = $('#assign_work_order_id').val();
            
            // Check work order status before creating task
            var workOrder = allWorkOrders.find(function(w) { return w.id == workOrderId; });
            if (workOrder) {
                var status = workOrder.status;
                if (status === 'completed' || status === 'cancelled' || status === 'rejected') {
                    var statusText = '';
                    if (status === 'completed') {
                        statusText = 'hoàn thành';
                    } else if (status === 'cancelled') {
                        statusText = 'hủy';
                    } else if (status === 'rejected') {
                        statusText = 'từ chối';
                    }
                    alert('Không thể tạo công việc mới cho đơn hàng đã ' + statusText + '.\n\n' +
                        'Vui lòng kiểm tra lại trạng thái đơn hàng.');
                    return;
                }
            }
            
            var description = $('#taskDescription').val().trim();
            var priority = $('#taskPriority').val();
            var estimatedHours = $('#taskEstimatedHours').val();
            var startDate = $('#taskStartDate').val();
            var deadline = $('#taskDeadline').val();
            
            // Validate description
            if(!description || description === '') {
                $('#taskDescriptionError').text('Vui lòng nhập mô tả công việc').show();
                $('#taskDescription').focus();
                return;
            }
            
            if(description.length > 150) {
                $('#taskDescriptionError').text('Mô tả công việc không được vượt quá 150 ký tự. Hiện tại: ' + description.length + ' ký tự').show();
                $('#taskDescription').focus();
                return;
            }
            
            // Validate dates - MUST validate before proceeding
            // First, check if deadline is loaded
            var workOrderDeadline = $('#taskStartDate').data('workOrderDeadline');
            if (!workOrderDeadline) {
                // Try to reload deadline synchronously if not available
                var workOrder = allWorkOrders.find(function(w) { return w.id == workOrderId; });
                if (workOrder) {
                    console.warn('⚠ Deadline not loaded, attempting to reload...');
                    // Try to get deadline directly from work order or ticket
                    if (workOrder.supportRequestId) {
                        // Try synchronous call to get deadline
                        var deadlineLoaded = false;
                        $.ajax({
                            url: ctx + '/support-detail',
                            type: 'GET',
                            data: { id: workOrder.supportRequestId },
                            dataType: 'json',
                            async: false, // Synchronous to ensure deadline is loaded before validation
                            success: function(response) {
                                if (response && response.success && response.data && response.data.deadline) {
                                    parseAndStoreDeadline(response.data.deadline);
                                    deadlineLoaded = true;
                                }
                            }
                        });
                        if (!deadlineLoaded) {
                            console.warn('⚠ Could not load deadline from support request');
                        }
                    }
                }
            }
            
            // Now validate dates
            var validationResult = validateTaskCreateDates();
            if (!validationResult) {
                // Validation failed, stop submission
                console.error('✗ Validation failed - blocking task creation');
                return;
            }
            
            // Final check: ensure deadline is still valid after all validations
            workOrderDeadline = $('#taskStartDate').data('workOrderDeadline');
            if (workOrderDeadline && (startDate || deadline)) {
                var workOrderDeadlineDate = new Date(workOrderDeadline);
                workOrderDeadlineDate.setHours(0, 0, 0, 0);
                
                if (startDate) {
                    var start = new Date(startDate);
                    start.setHours(0, 0, 0, 0);
                    if (start > workOrderDeadlineDate) {
                        var deadlineParts = workOrderDeadline.split('-');
                        var deadlineDisplay = deadlineParts[2] + '/' + deadlineParts[1] + '/' + deadlineParts[0];
                        var startParts = startDate.split('-');
                        var startDisplay = startParts[2] + '/' + startParts[1] + '/' + startParts[0];
                        alert('⚠ Lỗi: Ngày thực hiện (' + startDisplay + ') không được lớn hơn ngày mong muốn hoàn thành (' + deadlineDisplay + ').\n\nVui lòng chọn ngày nhỏ hơn hoặc bằng ngày mong muốn hoàn thành.');
                        $('#taskStartDate').val('');
                        $('#taskStartDate').focus();
                        return;
                    }
                }
                
                if (deadline) {
                    var end = new Date(deadline);
                    end.setHours(0, 0, 0, 0);
                    if (end > workOrderDeadlineDate) {
                        var deadlineParts = workOrderDeadline.split('-');
                        var deadlineDisplay = deadlineParts[2] + '/' + deadlineParts[1] + '/' + deadlineParts[0];
                        var deadlineParts2 = deadline.split('-');
                        var deadlineDisplay2 = deadlineParts2[2] + '/' + deadlineParts2[1] + '/' + deadlineParts2[0];
                        alert('⚠ Lỗi: Deadline (' + deadlineDisplay2 + ') không được lớn hơn ngày mong muốn hoàn thành (' + deadlineDisplay + ').\n\nVui lòng chọn ngày nhỏ hơn hoặc bằng ngày mong muốn hoàn thành.');
                        $('#taskDeadline').val('');
                        $('#taskDeadline').focus();
                        return;
                    }
                }
            }
            
            // Additional validation: deadline must be after or equal to start date (already checked in validateTaskCreateDates, but keep for safety)
            if (startDate && deadline) {
                var start = new Date(startDate);
                var end = new Date(deadline);
                if (end < start) {
                    alert('⚠ Lỗi: Deadline phải sau hoặc bằng ngày thực hiện!');
                    $('#taskDeadline').focus();
                    return;
                }
            }
            
            // Additional validation: check against ngày mong muốn hoàn thành (deadline từ ticket) - double check để đảm bảo
            var workOrderDeadline = $('#taskStartDate').data('workOrderDeadline');
            if (workOrderDeadline) {
                try {
                    var workOrderDeadlineDate = new Date(workOrderDeadline);
                    workOrderDeadlineDate.setHours(0, 0, 0, 0);
                    
                    if (startDate) {
                        var start = new Date(startDate);
                        start.setHours(0, 0, 0, 0);
                        if (start > workOrderDeadlineDate) {
                            var deadlineParts = workOrderDeadline.split('-');
                            var deadlineDisplay = deadlineParts[2] + '/' + deadlineParts[1] + '/' + deadlineParts[0];
                            alert('⚠ Lỗi: Ngày thực hiện không được lớn hơn ngày mong muốn hoàn thành (' + deadlineDisplay + ').\n\nVui lòng chọn ngày nhỏ hơn hoặc bằng ngày mong muốn hoàn thành.');
                            $('#taskStartDate').val('');
                            $('#taskStartDate').focus();
                            return;
                        }
                    }
                    
                    if (deadline) {
                        var end = new Date(deadline);
                        end.setHours(0, 0, 0, 0);
                        if (end > workOrderDeadlineDate) {
                            var deadlineParts = workOrderDeadline.split('-');
                            var deadlineDisplay = deadlineParts[2] + '/' + deadlineParts[1] + '/' + deadlineParts[0];
                            alert('⚠ Lỗi: Deadline không được lớn hơn ngày mong muốn hoàn thành (' + deadlineDisplay + ').\n\nVui lòng chọn ngày nhỏ hơn hoặc bằng ngày mong muốn hoàn thành.');
                            $('#taskDeadline').val('');
                            $('#taskDeadline').focus();
                            return;
                        }
                    }
                } catch (e) {
                    console.warn('Error validating against work order deadline on submit:', e);
                }
            }
            
            // Validate estimated hours
            if (estimatedHours && estimatedHours.trim() !== '') {
                var hoursValue = parseFloat(estimatedHours);
                if (isNaN(hoursValue)) {
                    alert('Lỗi: Giờ ước tính không hợp lệ. Vui lòng nhập số.');
                    $('#taskEstimatedHours').focus();
                    return;
                }
                if (hoursValue <= 0) {
                    alert('Lỗi: Giờ ước tính phải lớn hơn 0. Vui lòng nhập giá trị hợp lệ.');
                    $('#taskEstimatedHours').focus();
                    return;
                }
                
                // Kiểm tra tổng giờ ước tính của tất cả tasks (bao gồm task mới) không được vượt quá giờ ước tính của work order
                var workOrder = allWorkOrders.find(function(w) { return w.id == workOrderId; });
                if (workOrder && workOrder.estimatedHours) {
                    var workOrderHours = parseFloat(workOrder.estimatedHours);
                    if (!isNaN(workOrderHours) && workOrderHours > 0) {
                        // Load current tasks to calculate total (synchronous call before submit)
                        var totalEstimatedHours = 0;
                        var tasksLoaded = false;
                        
                        $.ajax({
                            url: ctx + '/api/work-order-tasks?action=list&workOrderId=' + workOrderId,
                            type: 'GET',
                            dataType: 'json',
                            async: false, // Synchronous to validate before submit
                            success: function(response) {
                                if (response && response.success && response.data) {
                                    var tasks = response.data;
                                    tasks.forEach(function(task) {
                                        // Không tính các task có status = 'rejected' vào tổng giờ ước tính
                                        if (task.status !== 'rejected' && task.estimatedHours && !isNaN(parseFloat(task.estimatedHours))) {
                                            totalEstimatedHours += parseFloat(task.estimatedHours);
                                        }
                                    });
                                    tasksLoaded = true;
                                }
                            }
                        });
                        
                        if (tasksLoaded) {
                            // Calculate new total with new task
                            var newTotal = totalEstimatedHours + hoursValue;
                            var remaining = workOrderHours - totalEstimatedHours;
                            
                            if (newTotal > workOrderHours) {
                                if (remaining <= 0) {
                                    alert('Lỗi: Không thể tạo công việc mới.\n\n' +
                                        'Tổng giờ ước tính của các công việc hiện tại (' + totalEstimatedHours.toFixed(1) + 
                                        'h) đã đạt hoặc vượt quá giờ ước tính của đơn hàng (' + workOrderHours.toFixed(1) + 'h).');
                                } else {
                                    alert('Lỗi: Không thể tạo công việc mới.\n\n' +
                                        'Nếu tạo công việc này (' + hoursValue.toFixed(1) + 'h), tổng giờ ước tính sẽ là ' + 
                                        newTotal.toFixed(1) + 'h, vượt quá giờ ước tính của đơn hàng (' + workOrderHours.toFixed(1) + 'h).\n\n' +
                                        'Còn lại: ' + remaining.toFixed(1) + 'h.');
                                }
                                $('#taskEstimatedHours').focus();
                                return;
                            }
                        } else {
                            // Fallback: Check if single task exceeds work order hours
                            if (hoursValue > workOrderHours) {
                                alert('Lỗi: Giờ ước tính của công việc (' + hoursValue.toFixed(1) + 'h) không được vượt quá giờ ước tính của đơn hàng (' + workOrderHours.toFixed(1) + 'h).');
                                $('#taskEstimatedHours').focus();
                                return;
                            }
                        }
                    } else {
                        // Nếu work order không có giờ ước tính, kiểm tra max 100
                        if (hoursValue > 100) {
                            alert('Lỗi: Giờ ước tính không được vượt quá 100 giờ. Vui lòng nhập giá trị nhỏ hơn.');
                            $('#taskEstimatedHours').focus();
                            return;
                        }
                    }
                } else {
                    // Nếu không tìm thấy work order hoặc không có giờ ước tính, kiểm tra max 100
                    if (hoursValue > 100) {
                        alert('Lỗi: Giờ ước tính không được vượt quá 100 giờ. Vui lòng nhập giá trị nhỏ hơn.');
                        $('#taskEstimatedHours').focus();
                        return;
                    }
                }
            }
            
            // Hide error message
            $('#taskDescriptionError').hide();
            
            $.ajax({
                url: ctx + '/api/work-order-tasks?action=create',
                type: 'POST',
                data: {
                    workOrderId: workOrderId,
                    taskDescription: description,
                    priority: priority,
                    estimatedHours: estimatedHours,
                    startDate: startDate || null,
                    deadline: deadline || null
                },
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        var message = response.message || 'Thêm công việc thành công!';
                        alert(message);
                        $('#addTaskForm')[0].reset();
                        $('#taskDescriptionCounter').text('0');
                        $('#taskDescriptionError').hide();
                        // Reset date fields and set min date
                        setMinDateForTaskCreateDates();
                        loadTasks(workOrderId);
                    } else {
                        var errorMsg = response.message || 'Không thể thêm công việc';
                        if(errorMsg.includes('150') || errorMsg.includes('đang chờ xác nhận') || errorMsg.includes('đã tồn tại')) {
                            $('#taskDescriptionError').text(errorMsg).show();
                            $('#taskDescription').focus();
                        } else if(errorMsg.includes('đã đóng') || errorMsg.includes('đã hủy') || errorMsg.includes('Đã hoàn thành') || errorMsg.includes('Đã hủy')) {
                            // Work order is closed - show alert and disable form
                            alert('✗ ' + errorMsg);
                            
                            // Show alert box
                            $('#workOrderClosedAlert').show();
                            $('#workOrderClosedMessage').html(
                                '<strong>Đơn hàng này đã hoàn thành hoặc đã hủy.</strong><br>' +
                                errorMsg + '<br>' +
                                '<small class="text-muted">Không thể tạo thêm công việc mới cho đơn hàng đã đóng.</small>'
                            );
                            
                            // Disable form and change box style
                            $('#addTaskForm').find('input, textarea, select, button').prop('disabled', true);
                            $('#addTaskForm').closest('.box').removeClass('box-success').addClass('box-warning');
                            $('#addTaskForm').closest('.box').find('.box-title').html(
                                '<i class="fa fa-lock"></i> Thêm công việc mới <span class="label label-warning">Đã khóa</span>'
                            );
                            
                            // Reload work orders to update status
                            loadWorkOrders();
                        } else {
                            alert('Lỗi: ' + errorMsg);
                        }
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
            var workOrderId = $('#assign_work_order_id').val();
            
            if(!userId) {
                alert('Vui lòng chọn nhân viên');
                return;
            }
            
            // Kiểm tra work order status trước khi phân công
            var workOrder = allWorkOrders.find(function(w) { return w.id == parseInt(workOrderId); });
            if (workOrder && (workOrder.status === 'completed' || workOrder.status === 'cancelled' || workOrder.status === 'rejected')) {
                alert('Không thể phân công công việc cho đơn hàng đã đóng!');
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
                        var message = response.message || 'Phân công công việc thành công!';
                        if(response.newTaskId) {
                            // Task mới đã được tạo (cho task in_progress)
                            message = 'Đã tạo công việc mới với trạng thái "Chờ xử lý" và phân công cho nhân viên!';
                        }
                        alert(message);
                        // Reload tasks before closing modal
                        var workOrderId = $('#assign_work_order_id').val();
                        loadTasks(workOrderId);
                        // Reload assigned users and update table
                        reloadAssignedUsersForWorkOrder(workOrderId);
                        $('#assignTaskUserModal').modal('hide');
                    } else {
                        // Hiển thị thông báo lỗi từ server (có thể là "Công việc đã hoàn thành không thể giao cho người khác")
                        alert(response.message || 'Không thể phân công');
                        // Nếu là lỗi do công việc đã hoàn thành, reload lại danh sách tasks
                        if(response.message && response.message.includes('đã hoàn thành')) {
                            var workOrderId = $('#assign_work_order_id').val();
                            loadTasks(workOrderId);
                        }
                    }
                },
                error: function() {
                    alert('Lỗi kết nối máy chủ');
                }
            });
        });
        
        // Function to open report modal
        function openReportModal(workOrderId) {
            $('#report_work_order_id').val(workOrderId);
            // Reset filters
            $('#report_filter_start_date').val('');
            $('#report_filter_completion_date').val('');
            $('#reportModal').modal('show');
            loadReportData(workOrderId);
        }
        
        // Function to load and display report data
        function loadReportData(workOrderId) {
            var workOrder = allWorkOrders.find(function(w) { return w.id == workOrderId; });
            if(!workOrder) {
                $('#reportContent').html('<div class="alert alert-danger">Không tìm thấy đơn hàng công việc</div>');
                return;
            }
            
            // Load tasks for this work order
            $.ajax({
                url: ctx + '/api/work-order-tasks?action=list&workOrderId=' + workOrderId,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if(response && response.success && response.data && response.data.length > 0) {
                        // Apply date filters
                        var filteredTasks = applyDateFilters(response.data);
                        renderReportContent(workOrder, filteredTasks);
                    } else {
                        $('#reportContent').html('<div class="alert alert-info">Chưa có công việc nào được tạo cho đơn hàng này</div>');
                    }
                },
                error: function() {
                    $('#reportContent').html('<div class="alert alert-danger">Không thể tải dữ liệu báo cáo</div>');
                }
            });
        }
        
        // Function to apply date filters
        function applyDateFilters(tasks) {
            var startDate = $('#report_filter_start_date').val();
            var completionDate = $('#report_filter_completion_date').val();
            
            if(!startDate && !completionDate) {
                return tasks; // No filters, return all tasks
            }
            
            return tasks.filter(function(task) {
                var matchStartDate = true;
                var matchCompletionDate = true;
                
                // Filter by start date
                if(startDate) {
                    if(task.startDate) {
                        var taskStartDate = new Date(task.startDate);
                        var filterStartDate = new Date(startDate);
                        // Set time to beginning of day for comparison
                        taskStartDate.setHours(0, 0, 0, 0);
                        filterStartDate.setHours(0, 0, 0, 0);
                        matchStartDate = taskStartDate >= filterStartDate;
                    } else {
                        matchStartDate = false; // Task has no start date, doesn't match
                    }
                }
                
                // Filter by completion date
                if(completionDate) {
                    if(task.completionDate) {
                        var taskCompletionDate = new Date(task.completionDate);
                        var filterCompletionDate = new Date(completionDate);
                        // Set time to beginning of day for comparison
                        taskCompletionDate.setHours(0, 0, 0, 0);
                        filterCompletionDate.setHours(0, 0, 0, 0);
                        matchCompletionDate = taskCompletionDate <= filterCompletionDate;
                    } else {
                        matchCompletionDate = false; // Task has no completion date, doesn't match
                    }
                }
                
                return matchStartDate && matchCompletionDate;
            });
        }
        
        // Function to render report content
        function renderReportContent(workOrder, tasks) {
            var html = '<div class="box box-primary">';
            html += '<div class="box-header"><h3 class="box-title">Đơn hàng: ' + (workOrder.workOrderNumber || '#' + workOrder.id) + '</h3></div>';
            html += '<div class="box-body">';
            html += '<p><strong>Khách hàng:</strong> ' + (workOrder.customerName || 'N/A') + '</p>';
            html += '<p><strong>Tiêu đề:</strong> ' + (workOrder.title || '') + '</p>';
            html += '</div></div>';
            
            html += '<div class="box box-info">';
            html += '<div class="box-header"><h3 class="box-title">Báo cáo công việc';
            if(tasks.length > 0) {
                html += ' (' + tasks.length + ' nhiệm vụ)';
            }
            html += '</h3></div>';
            html += '<div class="box-body">';
            
            if(tasks.length === 0) {
                html += '<div class="alert alert-info">Không có nhiệm vụ nào khớp với bộ lọc ngày đã chọn.</div>';
            } else {
                tasks.forEach(function(task, index) {
                    html += '<div class="panel panel-default" style="margin-bottom: 15px;">';
                    html += '<div class="panel-heading">';
                    html += '<h4 class="panel-title">';
                    html += '<strong>' + (task.taskNumber || 'Task #' + (index + 1)) + '</strong> - ' + (task.taskDescription || '');
                    html += '</h4>';
                    html += '</div>';
                    html += '<div class="panel-body">';
                    
                    // Thời gian
                    html += '<div class="row">';
                    if(task.estimatedHours) {
                        html += '<div class="col-md-6"><p><strong>Giờ ước tính:</strong> ' + task.estimatedHours + 'h</p></div>';
                    }
                    if(task.actualHours) {
                        html += '<div class="col-md-6"><p><strong>Giờ thực tế:</strong> ' + task.actualHours + 'h</p></div>';
                    }
                    html += '</div>';
                    
                    // Ngày bắt đầu và hoàn thành
                    if(task.startDate) {
                        html += '<p><strong>Ngày bắt đầu:</strong> ' + formatDateTime(task.startDate) + '</p>';
                    }
                    if(task.completionDate) {
                        html += '<p><strong>Ngày hoàn thành:</strong> ' + formatDateTime(task.completionDate) + '</p>';
                    }
                    
                    // Trạng thái task
                    if(task.status) {
                        var statusLabels = {
                            'pending': 'Đang chờ xử lý',
                            'in_progress': 'Đang thực hiện',
                            'completed': 'Hoàn thành',
                            'cancelled': 'Đã hủy',
                            'rejected': 'Đã từ chối'
                        };
                        var statusBadgeClass = 'badge-' + task.status;
                        if(task.status === 'rejected') {
                            statusBadgeClass = 'badge-danger';
                        }
                        var statusLabel = statusLabels[task.status] || task.status;
                        html += '<p><strong>Trạng thái:</strong> <span class="badge ' + statusBadgeClass + '">' + statusLabel + '</span></p>';
                    }
                    
                    // Phần trăm hoàn thành - Luôn hiển thị 0% trong báo cáo
                    var percentage = 0;
                    var progressBarClass = 'progress-bar-warning'; // Màu vàng cho 0%
                    
                    // Hiển thị progress bar nếu có percentage
                    if(percentage !== null) {
                        html += '<p><strong>Phần trăm hoàn thành:</strong> ';
                        html += '<div class="progress" style="margin-top: 5px;">';
                        html += '<div class="progress-bar ' + progressBarClass + '" role="progressbar" style="width: ' + percentage + '%">';
                        html += percentage + '%';
                        html += '</div></div></p>';
                    }
                    
                    // Mô tả công việc đã thực hiện
                    if(task.workDescription && task.workDescription.trim() !== '') {
                        html += '<div style="margin-top: 15px;">';
                        html += '<strong>Mô tả công việc đã thực hiện:</strong>';
                        html += '<div class="well" style="margin-top: 5px; white-space: pre-wrap;">' + task.workDescription + '</div>';
                        html += '</div>';
                    }
                    
                    // Vấn đề phát sinh
                    if(task.issuesFound && task.issuesFound.trim() !== '') {
                        html += '<div style="margin-top: 15px;">';
                        html += '<strong>Vấn đề phát sinh:</strong>';
                        html += '<div class="well well-sm" style="margin-top: 5px; background-color: #fff3cd; white-space: pre-wrap;">' + task.issuesFound + '</div>';
                        html += '</div>';
                    }
                    
                    // Lý do hủy/từ chối (nếu status là rejected hoặc cancelled)
                    if((task.status === 'rejected' || task.status === 'cancelled') && task.rejectionReason && task.rejectionReason.trim() !== '') {
                        html += '<div style="margin-top: 15px;">';
                        html += '<strong>Lý do hủy/từ chối:</strong>';
                        html += '<div class="well well-sm" style="margin-top: 5px; background-color: #f8d7da; border-color: #f5c6cb; white-space: pre-wrap;">' + task.rejectionReason + '</div>';
                        html += '</div>';
                    }
                    
                    // Ghi chú
                    if(task.notes && task.notes.trim() !== '') {
                        html += '<div style="margin-top: 15px;">';
                        html += '<strong>Ghi chú:</strong>';
                        html += '<div class="well well-sm" style="margin-top: 5px; white-space: pre-wrap;">' + task.notes + '</div>';
                        html += '</div>';
                    }
                    
                    // File đính kèm (Ảnh)
                    if(task.attachments && task.attachments.trim() !== '') {
                        try {
                            var attachments = JSON.parse(task.attachments);
                            if(Array.isArray(attachments) && attachments.length > 0) {
                                html += '<div style="margin-top: 15px;">';
                                html += '<strong>Ảnh đính kèm:</strong>';
                                html += '<div class="row" style="margin-top: 10px;">';
                                attachments.forEach(function(attachment) {
                                    var filePath = typeof attachment === 'string' ? attachment : (attachment.path || attachment.name || attachment);
                                    var fileName = typeof attachment === 'string' ? filePath.split('/').pop() : (attachment.name || filePath.split('/').pop());
                                    
                                    // Kiểm tra nếu là file ảnh
                                    var imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
                                    var ext = fileName.toLowerCase().split('.').pop();
                                    
                                    if(imageExtensions.indexOf(ext) !== -1) {
                                        // Hiển thị ảnh có thể click để xem to
                                        var fullPath = ctx + '/' + filePath;
                                        html += '<div class="col-xs-6 col-sm-4 col-md-3" style="margin-bottom: 15px;">';
                                        html += '<div class="attachment-thumbnail">';
                                        html += '<a href="' + fullPath + '" target="_blank" title="Click để xem ảnh lớn" style="text-decoration: none; display: block;">';
                                        html += '<img src="' + fullPath + '" alt="' + fileName + '" style="width: 100%; height: 150px; object-fit: cover; display: block;" onerror="this.onerror=null; this.src=\'' + ctx + '/img/no-image.png\'; this.style.height=\'150px\'; this.style.width=\'100%\'; this.style.objectFit=\'cover\';">';
                                        html += '<div style="padding: 8px; font-size: 11px; text-align: center; color: #333; background-color: #f9f9f9;">' + fileName + '</div>';
                                        html += '</a>';
                                        html += '</div>';
                                        html += '</div>';
                                    } else {
                                        // Hiển thị file không phải ảnh
                                        html += '<div class="col-xs-12" style="margin-bottom: 5px;">';
                                        html += '<a href="' + ctx + '/' + filePath + '" target="_blank" class="btn btn-sm btn-default">';
                                        html += '<i class="fa fa-file"></i> ' + fileName;
                                        html += '</a>';
                                        html += '</div>';
                                    }
                                });
                                html += '</div></div>';
                            }
                        } catch(e) {
                            console.error('Error parsing attachments:', e);
                            // Invalid JSON, try to display as plain text
                            if(task.attachments && task.attachments.trim() !== '') {
                                html += '<div style="margin-top: 15px;">';
                                html += '<strong>File đính kèm:</strong>';
                                html += '<p class="text-muted">' + task.attachments + '</p>';
                                html += '</div>';
                            }
                        }
                    }
                    
                    html += '</div></div>';
                });
            }
            
            html += '</div></div>';
            
            $('#reportContent').html(html);
        }
        
        // Set minimum date for task create dates (form thêm task mới)
        function setMinDateForTaskCreateDates() {
            // Set max date based on desired completion date (deadline from ticket)
            var workOrderDeadline = $('#taskStartDate').data('workOrderDeadline');
            if (workOrderDeadline) {
                // Set max attribute for both start date and deadline
                $('#taskStartDate').attr('max', workOrderDeadline);
                $('#taskDeadline').attr('max', workOrderDeadline);
            } else {
                // Remove max if no deadline
                $('#taskStartDate').removeAttr('max');
                $('#taskDeadline').removeAttr('max');
            }
            
            // Set minimum date to today (YYYY-MM-DD format)
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0');
            var yyyy = today.getFullYear();
            var todayStr = yyyy + '-' + mm + '-' + dd;
            $('#taskStartDate').attr('min', todayStr);
            $('#taskDeadline').attr('min', todayStr);
        }
        
        // Validate task create dates
        function validateTaskCreateDates() {
            var startDate = $('#taskStartDate').val();
            var deadline = $('#taskDeadline').val();
            var today = new Date();
            today.setHours(0, 0, 0, 0);
            
            // Get work order deadline from data attribute (ngày mong muốn hoàn thành từ ticket)
            var workOrderDeadline = $('#taskStartDate').data('workOrderDeadline');
            
            // Debug: log deadline for troubleshooting
            if (!workOrderDeadline) {
                console.warn('Warning: Desired completion date (workOrderDeadline) not found in data attribute');
            } else {
                console.log('Desired completion date loaded:', workOrderDeadline);
            }
            
            // Validate start date
            if (startDate) {
                var start = new Date(startDate);
                start.setHours(0, 0, 0, 0);
                if (start < today) {
                    alert('⚠ Lỗi: Ngày thực hiện không được là ngày quá khứ!');
                    $('#taskStartDate').val('');
                    $('#taskStartDate').focus();
                    return false;
                }
                
                // Validate start date <= ngày mong muốn hoàn thành (deadline từ ticket)
                if (workOrderDeadline) {
                    try {
                        var workOrderDeadlineDate = new Date(workOrderDeadline);
                        workOrderDeadlineDate.setHours(0, 0, 0, 0);
                        if (start > workOrderDeadlineDate) {
                            var deadlineParts = workOrderDeadline.split('-');
                            var deadlineDisplay = deadlineParts[2] + '/' + deadlineParts[1] + '/' + deadlineParts[0];
                            alert('⚠ Lỗi: Ngày thực hiện không được lớn hơn ngày mong muốn hoàn thành (' + deadlineDisplay + ').\n\nVui lòng chọn ngày nhỏ hơn hoặc bằng ngày mong muốn hoàn thành.');
                            $('#taskStartDate').val('');
                            $('#taskStartDate').focus();
                            return false;
                        }
                    } catch (e) {
                        console.warn('Error validating start date against desired completion date:', e);
                    }
                }
            }
            
            // Validate deadline
            if (deadline) {
                var end = new Date(deadline);
                end.setHours(0, 0, 0, 0);
                if (end < today) {
                    alert('⚠ Lỗi: Deadline không được là ngày quá khứ!');
                    $('#taskDeadline').val('');
                    $('#taskDeadline').focus();
                    return false;
                }
                
                // Validate deadline must be after or equal to start date
                if (startDate) {
                    var start = new Date(startDate);
                    start.setHours(0, 0, 0, 0);
                    if (end < start) {
                        alert('⚠ Lỗi: Deadline phải sau hoặc bằng ngày thực hiện!');
                        $('#taskDeadline').val('');
                        $('#taskDeadline').focus();
                        return false;
                    }
                }
                
                // Validate deadline <= ngày mong muốn hoàn thành (deadline từ ticket)
                if (workOrderDeadline) {
                    try {
                        var workOrderDeadlineDate = new Date(workOrderDeadline);
                        workOrderDeadlineDate.setHours(0, 0, 0, 0);
                        if (end > workOrderDeadlineDate) {
                            var deadlineParts = workOrderDeadline.split('-');
                            var deadlineDisplay = deadlineParts[2] + '/' + deadlineParts[1] + '/' + deadlineParts[0];
                            // Format deadline for display
                            var deadlineParts2 = deadline.split('-');
                            var deadlineDisplay2 = deadlineParts2[2] + '/' + deadlineParts2[1] + '/' + deadlineParts2[0];
                            alert('⚠ Lỗi: Deadline (' + deadlineDisplay2 + ') không được lớn hơn ngày mong muốn hoàn thành (' + deadlineDisplay + ').\n\nVui lòng chọn ngày nhỏ hơn hoặc bằng ngày mong muốn hoàn thành.');
                            $('#taskDeadline').val('');
                            $('#taskDeadline').focus();
                            return false;
                        }
                    } catch (e) {
                        console.warn('Error validating deadline against desired completion date:', e);
                        return false; // Fail validation if error parsing
                    }
                } else {
                    // If no deadline is set, we should still allow but log warning
                    console.warn('Warning: No desired completion date found. Cannot validate deadline against desired completion date.');
                }
            }
            
            return true;
        }
        
        // Update deadline min date when start date changes (form thêm task)
        $(document).on('change', '#taskStartDate', function() {
            var startDate = $(this).val();
            if (startDate) {
                $('#taskDeadline').attr('min', startDate);
                // If deadline is set and is before start date, clear it
                var deadline = $('#taskDeadline').val();
                if (deadline && deadline < startDate) {
                    $('#taskDeadline').val('');
                }
                
                // Ensure max date (desired completion date) is still applied
                var workOrderDeadline = $('#taskStartDate').data('workOrderDeadline');
                if (workOrderDeadline) {
                    $('#taskDeadline').attr('max', workOrderDeadline);
                }
            } else {
                // Reset to today if start date is cleared
                setMinDateForTaskCreateDates();
            }
        });
        
        // Validate dates on change (form thêm task)
        $(document).on('change', '#taskStartDate, #taskDeadline', function() {
            validateTaskCreateDates();
        });
        
        // Set minimum date when modal is shown (form thêm task)
        $(document).on('shown.bs.modal', '#assignTaskModal', function() {
            setMinDateForTaskCreateDates();
        });
        
        // Reset form when modal is closed
        $(document).on('hidden.bs.modal', '#assignTaskUserModal', function() {
            $('#userTaskCountInfo').hide();
        });
        
        // Reset deadline when assignTaskModal is closed
        $(document).on('hidden.bs.modal', '#assignTaskModal', function() {
            $('#customer_deadline_text').text('Đang tải...');
        });
        
        // Ensure deadline is loaded when assignTaskModal is shown
        $(document).on('shown.bs.modal', '#assignTaskModal', function() {
            var workOrderId = $('#assign_work_order_id').val();
            if (workOrderId) {
                // Reload deadline if modal is reopened
                loadCustomerDeadlineForAssignment(workOrderId);
            }
        });
        
        // Function to format datetime
        function formatDateTime(dateStr) {
            if(!dateStr) return '';
            try {
                var date = new Date(dateStr);
                var day = date.getDate().toString().padStart(2, '0');
                var month = (date.getMonth() + 1).toString().padStart(2, '0');
                var year = date.getFullYear();
                var hours = date.getHours().toString().padStart(2, '0');
                var minutes = date.getMinutes().toString().padStart(2, '0');
                return day + '/' + month + '/' + year + ' ' + hours + ':' + minutes;
            } catch(e) {
                return dateStr;
            }
        }
    </script>
</body>
</html>

