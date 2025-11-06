<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%
    // Kiểm tra đăng nhập
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Kiểm tra quyền customer_support hoặc admin
    if (!"customer_support".equals(userRole) && !"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Feedback | Bảng Điều Khiển</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <!-- bootstrap 3.0.2 -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- font Awesome -->
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Ionicons -->
    <link href="css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <!-- DataTables -->
    <link href="css/datatables/dataTables.bootstrap.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="css/style.css" rel="stylesheet" type="text/css" />

    <style>
        .filter-section {
            background: #f9f9f9;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .rating-stars {
            font-size: 18px;
            color: #ffc107;
        }
        .feedback-image {
            max-width: 300px;
            max-height: 300px;
            border-radius: 5px;
            border: 1px solid #ddd;
            margin-top: 10px;
            cursor: pointer;
        }
        .detail-section {
            margin-bottom: 20px;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .detail-section h4 {
            margin-top: 0;
            color: #3c8dbc;
            border-bottom: 2px solid #3c8dbc;
            padding-bottom: 10px;
        }
        /* Ẩn phần "records per page" của DataTables */
        .dataTables_length {
            display: none !important;
        }
        
        /* Đảm bảo phân trang hiển thị đầy đủ - LUÔN hiển thị */
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
            display: inline-block;
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
        
        .dataTables_wrapper .dataTables_paginate .paginate_button.disabled:hover {
            background: #f5f5f5 !important;
            color: #333 !important;
        }
        
        .dataTables_wrapper .dataTables_info {
            margin-top: 15px;
            padding-top: 8px;
            float: left;
        }
        
        /* Đảm bảo wrapper hiển thị đúng */
        .dataTables_wrapper::after {
            content: "";
            display: table;
            clear: both;
        }
        
        /* Đảm bảo phân trang luôn hiển thị, kể cả khi chỉ có ít bản ghi */
        .dataTables_wrapper .dataTables_paginate {
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button {
            display: inline-block !important;
            visibility: visible !important;
        }
        
        /* Hiển thị phân trang ngay cả khi chỉ có 1 trang */
        .dataTables_wrapper .dataTables_paginate.paging_full_numbers {
            display: block !important;
            visibility: visible !important;
        }
        
        /* Đảm bảo không có CSS nào ẩn phân trang */
        .dataTables_wrapper .dataTables_paginate[style*="display: none"] {
            display: block !important;
        }
    </style>
</head>
<body class="skin-black">
    <!-- header logo: style can be found in header.less -->
    <header class="header">
        <a href="feedback_management.jsp" class="logo">
            Quản Lý Feedback Khách Hàng
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
                                    Cài đặt cá nhân
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
        <!-- Left side column. contains the logo and sidebar -->
        <aside class="left-side sidebar-offcanvas">
            <!-- sidebar: style can be found in sidebar.less -->
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
                <!-- sidebar menu: : style can be found in sidebar.less -->
                <ul class="sidebar-menu">
                    <li>
                        <a href="customersupport.jsp">
                            <i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
                        </a>
                    </li>
                    <li>
                        <a href="support-management">
                            <i class="fa fa-ticket"></i> <span>Quản lý yêu cầu hỗ trợ</span>
                        </a>
                    </li>
                    <li>
                        <a href="feedback_management.jsp">
                            <i class="fa fa-star"></i> <span>Quản lý Feedback</span>
                        </a>
                    </li>
                    <li>
                        <a href="contracts.jsp">
                            <i class="fa fa-file-text"></i> <span>Hợp đồng khách hàng</span>
                        </a>
                    </li>
                    <li class="active">
                        <a href="contact-management">
                            <i class="fa fa-envelope"></i> <span>Quản lý liên hệ</span>
                            <small class="badge pull-right bg-blue" id="unreadContacts">${unreadCount}</small>
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
                        <div class="box">
                            <div class="box-header">
                                <h3 class="box-title">
                                    <i class="fa fa-star"></i> Danh sách Feedback từ Khách Hàng
                                </h3>
                            </div>
                            <!-- /.box-header -->
                            <div class="box-body">
                                <!-- Filter Section -->
                                <div class="filter-section">
                                    <div class="row">
                                        <div class="col-md-3">
                                            <label>Tên khách hàng:</label>
                                            <input type="text" id="filterCustomerName" class="form-control" placeholder="Nhập tên khách hàng...">
                                        </div>
                                        <div class="col-md-3">
                                            <label>Mã Ticket:</label>
                                            <input type="text" id="filterTicketNumber" class="form-control" placeholder="Nhập mã ticket...">
                                        </div>
                                        <div class="col-md-3">
                                            <label>Đánh giá:</label>
                                            <select id="filterRating" class="form-control">
                                                <option value="">Tất cả</option>
                                                <option value="5">5 sao - Rất hài lòng</option>
                                                <option value="4">4 sao - Hài lòng</option>
                                                <option value="3">3 sao - Bình thường</option>
                                                <option value="2">2 sao - Không hài lòng</option>
                                                <option value="1">1 sao - Rất không hài lòng</option>
                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label>Danh mục ticket:</label>
                                            <select id="filterCategory" class="form-control">
                                                <option value="">Tất cả</option>
                                                <option value="technical">Kỹ thuật</option>
                                                <option value="billing">Thanh toán</option>
                                                <option value="general">Chung</option>
                                                <option value="complaint">Khiếu nại</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row" style="margin-top: 10px;">
                                        <div class="col-md-12 text-right">
                                            <button type="button" class="btn btn-primary" id="filterBtn" onclick="applyFilters()">
                                                <i class="fa fa-filter"></i> Lọc
                                            </button>
                                            <button type="button" class="btn btn-default" id="resetFilterBtn" onclick="resetFilters()">
                                                <i class="fa fa-refresh"></i> Xóa bộ lọc
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Feedback Table -->
                                <div class="table-responsive">
                                    <table id="feedbacksTable" class="table table-striped table-bordered table-hover">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Mã Ticket</th>
                                                <th>Khách hàng</th>
                                                <th>Danh mục</th>
                                                <th>Sao</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody id="feedbacksTableBody">
                                            <tr>
                                                <td colspan="6" class="text-center">
                                                    <i class="fa fa-spinner fa-spin"></i> Đang tải dữ liệu...
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <!-- /.box-body -->
                        </div>
                        <!-- /.box -->
                    </div>
                    <!-- /.col -->
                </div>
                <!-- /.row -->
            </section>
            <!-- /.content -->
        </aside>
        <!-- /.right-side -->
    </div>
    <!-- ./wrapper -->

    <!-- Modal Xem Chi Tiết Feedback -->
    <div class="modal fade" id="viewFeedbackModal" tabindex="-1" role="dialog" aria-labelledby="viewFeedbackModalLabel">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header" style="background-color: #3c8dbc; color: white;">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="color: white; opacity: 0.8;">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="viewFeedbackModalLabel">
                        <i class="fa fa-star"></i> Chi Tiết Feedback
                    </h4>
                </div>
                <div class="modal-body" id="feedbackDetailContent">
                    <div class="text-center">
                        <i class="fa fa-spinner fa-spin fa-3x"></i>
                        <p>Đang tải dữ liệu...</p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">
                        <i class="fa fa-times"></i> Đóng
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Xem Ảnh -->
    <div class="modal fade" id="imageModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Ảnh Feedback</h4>
                </div>
                <div class="modal-body text-center">
                    <img id="modalImage" src="" style="max-width: 100%; height: auto;">
                </div>
            </div>
        </div>
    </div>

    <!-- jQuery 2.0.2 -->
    <script src="js/jquery.min.js"></script>
    <!-- Bootstrap -->
    <script src="js/bootstrap.min.js" type="text/javascript"></script>
    <!-- DataTables -->
    <script src="js/plugins/datatables/jquery.dataTables.js" type="text/javascript"></script>
    <script src="js/plugins/datatables/dataTables.bootstrap.js" type="text/javascript"></script>
    <!-- AdminLTE App -->
    <script src="js/AdminLTE/app.js" type="text/javascript"></script>

    <script>
        var allFeedbacks = [];
        var dataTable;
        var ctx = '<%= request.getContextPath() %>';
        
        // Helper function to check if DataTables is available
        function isDataTableAvailable() {
            return typeof $.fn.dataTable !== 'undefined' && 
                   typeof $.fn.dataTable.isDataTable === 'function';
        }
        
        // Helper function to check if table is initialized
        function isTableInitialized() {
            if (!isDataTableAvailable()) {
                return false;
            }
            try {
                return $.fn.dataTable.isDataTable('#feedbacksTable');
            } catch(e) {
                return false;
            }
        }
        
        // Load feedbacks on page load
        $(document).ready(function() {
            loadFeedbacks();
            
            // Allow Enter key to trigger filter
            $('#filterCustomerName, #filterTicketNumber').on('keypress', function(e) {
                if (e.which === 13) { // Enter key
                    applyFilters();
                }
            });
        });
        
        function loadFeedbacks() {
            loadFeedbacksWithFilters();
        }
        
        function loadFeedbacksWithFilters() {
            // Build URL with filter parameters
            var url = ctx + '/api/feedback?action=list';
            var params = [];
            
            var customerName = $('#filterCustomerName').val().trim();
            var ticketNumber = $('#filterTicketNumber').val().trim();
            var rating = $('#filterRating').val();
            var category = $('#filterCategory').val();
            
            if (customerName) {
                params.push('customerName=' + encodeURIComponent(customerName));
            }
            if (ticketNumber) {
                params.push('ticketNumber=' + encodeURIComponent(ticketNumber));
            }
            if (rating) {
                params.push('rating=' + encodeURIComponent(rating));
            }
            if (category) {
                params.push('category=' + encodeURIComponent(category));
            }
            
            if (params.length > 0) {
                url += '&' + params.join('&');
            }
            
            $.ajax({
                url: url,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    console.log('Feedback response:', response);
                    if (response && response.success) {
                        if (response.data && Array.isArray(response.data)) {
                            allFeedbacks = response.data;
                            console.log('Loaded feedbacks:', allFeedbacks.length);
                            renderFeedbacks();
                        } else {
                            allFeedbacks = [];
                            console.log('No feedback data');
                            $('#feedbacksTableBody').html('<tr><td colspan="6" class="text-center"><i class="fa fa-info-circle"></i> Không có feedback nào</td></tr>');
                            renderFeedbacks();
                        }
                    } else {
                        allFeedbacks = [];
                        console.error('Response error:', response);
                        $('#feedbacksTableBody').html('<tr><td colspan="6" class="text-center text-danger"><i class="fa fa-times-circle"></i> ' + (response && response.message ? response.message : 'Lỗi khi tải dữ liệu') + '</td></tr>');
                        renderFeedbacks();
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error loading feedbacks:', error);
                    console.error('XHR:', xhr);
                    console.error('Status:', status);
                    allFeedbacks = [];
                    $('#feedbacksTableBody').html('<tr><td colspan="6" class="text-center text-danger"><i class="fa fa-times-circle"></i> Lỗi khi tải dữ liệu: ' + error + '</td></tr>');
                    renderFeedbacks();
                }
            });
        }
        
        function applyFilters() {
            loadFeedbacksWithFilters();
        }
        
        function resetFilters() {
            $('#filterCustomerName').val('');
            $('#filterTicketNumber').val('');
            $('#filterRating').val('');
            $('#filterCategory').val('');
            loadFeedbacksWithFilters();
        }
        
        function renderFeedbacks() {
            // Data is already filtered from backend, just render it
            var html = '';
            
            if (allFeedbacks.length === 0) {
                // Empty state - show message
                html = '<tr><td colspan="6" class="text-center"><i class="fa fa-info-circle"></i> Không có feedback nào</td></tr>';
            } else {
                allFeedbacks.forEach(function(fb, index) {
                    html += '<tr>';
                    // Hiển thị số thứ tự bắt đầu từ 1
                    html += '<td>' + (index + 1) + '</td>';
                    html += '<td><strong>#' + escapeHtml(fb.ticketNumber || 'N/A') + '</strong></td>';
                    html += '<td>' + escapeHtml(fb.customerName || 'N/A') + '</td>';
                    // Danh mục với badge
                    html += '<td>' + getCategoryBadge(fb.ticketCategory) + '</td>';
                    html += '<td><span class="rating-stars">' + escapeHtml(fb.ratingStars || '') + '</span></td>';
                    html += '<td>';
                    html += '<button class="btn btn-info btn-xs view-feedback-btn" data-feedback-id="' + fb.id + '" title="Xem chi tiết">';
                    html += '<i class="fa fa-eye"></i> Xem';
                    html += '</button>';
                    html += '</td>';
                    html += '</tr>';
                });
            }
            
            $('#feedbacksTableBody').html(html);
            
            // Destroy DataTable if it exists
            if (isTableInitialized()) {
                try {
                    $('#feedbacksTable').DataTable().destroy();
                } catch(e) {
                    console.log('Error destroying DataTable:', e);
                }
            }
            dataTable = null;
            
            // Only initialize DataTable if we have data rows (not empty state)
            if (allFeedbacks.length > 0) {
                // Small delay to ensure DOM is updated and DataTables is loaded
                setTimeout(function() {
                    // Check if DataTables is available
                    if (!isDataTableAvailable()) {
                        console.error('DataTables library is not loaded');
                        return;
                    }
                    
                    // Check again to make sure it's not already initialized
                    if (!isTableInitialized()) {
                        try {
                            dataTable = $('#feedbacksTable').DataTable({
                                "language": {
                                    "url": "//cdn.datatables.net/plug-ins/1.10.24/i18n/Vietnamese.json"
                                },
                                "pageLength": 10, // Hiển thị 10 bản ghi mỗi trang
                                "lengthChange": false, // Ẩn dropdown "records per page"
                                "paging": true, // Bật phân trang
                                "pagingType": "full_numbers", // Hiển thị số trang đầy đủ (Previous, 1, 2, 3, ..., Next)
                                "info": true, // Hiển thị thông tin "Showing X to Y of Z entries"
                                "order": [[0, "desc"]], // Sắp xếp theo ID giảm dần
                                "dom": '<"top"lf>rt<"bottom"ip><"clear">', // Cấu trúc DOM để hiển thị phân trang
                                "columnDefs": [
                                    { 
                                        "targets": 0, // Cột ID (cột đầu tiên)
                                        "render": function (data, type, row, meta) {
                                            // Hiển thị số thứ tự bắt đầu từ 1, tính cả pagination
                                            return meta.settings._iDisplayStart + meta.row + 1;
                                        }
                                    },
                                    { "orderable": false, "targets": 5 } // Không sort cột Thao tác (cột cuối cùng)
                                ],
                                "destroy": true,
                                "drawCallback": function(settings) {
                                    // Đảm bảo phân trang luôn hiển thị
                                    var api = this.api();
                                    var pageInfo = api.page.info();
                                    var wrapper = $(this).closest('.dataTables_wrapper');
                                    var paginate = wrapper.find('.dataTables_paginate');
                                    
                                    // Luôn hiển thị phân trang, kể cả khi chỉ có 1 trang
                                    if (paginate.length) {
                                        paginate.css({
                                            'display': 'block !important',
                                            'visibility': 'visible !important'
                                        }).show();
                                        
                                        // Nếu chỉ có 1 trang, vẫn hiển thị nút phân trang
                                        if (pageInfo.pages <= 1) {
                                            paginate.find('.paginate_button').show();
                                        }
                                    }
                                    
                                    // Đảm bảo info cũng hiển thị
                                    var info = wrapper.find('.dataTables_info');
                                    if (info.length) {
                                        info.show();
                                    }
                                },
                                "initComplete": function(settings, json) {
                                    // Sau khi khởi tạo xong, đảm bảo phân trang hiển thị
                                    var wrapper = $(this).closest('.dataTables_wrapper');
                                    var paginate = wrapper.find('.dataTables_paginate');
                                    if (paginate.length) {
                                        // Xóa bất kỳ style inline nào có thể ẩn phân trang
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
                                    
                                    // Đảm bảo info cũng hiển thị
                                    var info = wrapper.find('.dataTables_info');
                                    if (info.length) {
                                        info.show();
                                    }
                                }
                            });
                            console.log('DataTable initialized successfully');
                        } catch(e) {
                            console.error('Error initializing DataTable:', e);
                        }
                    } else {
                        // If already initialized, just get the instance
                        try {
                            dataTable = $('#feedbacksTable').DataTable();
                        } catch(e) {
                            console.error('Error getting DataTable instance:', e);
                        }
                    }
                }, 100);
            } else {
                console.log('No feedbacks to display, skipping DataTable initialization');
            }
            
            // Attach event handlers - always attach, regardless of DataTables status
            $(document).off('click', '.view-feedback-btn').on('click', '.view-feedback-btn', function(e) {
                e.preventDefault();
                e.stopPropagation();
                var feedbackId = $(this).data('feedback-id');
                console.log('View feedback clicked, ID:', feedbackId);
                if (feedbackId) {
                    viewFeedbackDetail(feedbackId);
                } else {
                    console.error('No feedback ID found');
                    alert('Không tìm thấy ID feedback');
                }
            });
        }
        
        
        function viewFeedbackDetail(feedbackId) {
            console.log('viewFeedbackDetail called with ID:', feedbackId);
            console.log('All feedbacks:', allFeedbacks);
            
            // Find feedback in array - try both string and number comparison
            var feedback = allFeedbacks.find(function(fb) {
                return fb.id == feedbackId || fb.id == parseInt(feedbackId);
            });
            
            if (!feedback) {
                console.error('Feedback not found. ID:', feedbackId, 'Available IDs:', allFeedbacks.map(f => f.id));
                alert('Không tìm thấy feedback với ID: ' + feedbackId);
                return;
            }
            
            console.log('Found feedback:', feedback);
            
            // Build detail HTML
            var html = '';
            
            // Feedback Information
            html += '<div class="detail-section">';
            html += '<h4><i class="fa fa-star"></i> Thông tin Feedback</h4>';
            html += '<div class="row">';
            html += '<div class="col-md-6">';
            html += '<p><strong>ID Feedback:</strong> ' + escapeHtml(feedback.id || 'N/A') + '</p>';
            html += '<p><strong>Đánh giá:</strong> <span class="rating-stars">' + escapeHtml(feedback.ratingStars || '') + '</span> ' + escapeHtml(feedback.ratingDisplay || '') + '</p>';
            html += '<p><strong>Ngày feedback:</strong> ' + formatDate(feedback.createdAt) + '</p>';
            html += '</div>';
            html += '<div class="col-md-6">';
            if (feedback.updatedAt && feedback.updatedAt !== feedback.createdAt) {
                html += '<p><strong>Ngày cập nhật:</strong> ' + formatDate(feedback.updatedAt) + '</p>';
            }
            html += '</div>';
            html += '</div>';
            if (feedback.comment) {
                html += '<div style="margin-top: 15px;">';
                html += '<strong>Nhận xét:</strong>';
                html += '<p style="white-space: pre-wrap; word-wrap: break-word; background: #f9f9f9; padding: 10px; border-radius: 3px; margin-top: 5px;">';
                html += escapeHtml(feedback.comment);
                html += '</p>';
                html += '</div>';
            }
            if (feedback.imagePath) {
                html += '<div style="margin-top: 15px;">';
                html += '<strong>Ảnh minh chứng:</strong><br>';
                html += '<img src="' + ctx + '/' + escapeHtml(feedback.imagePath) + '" class="feedback-image" alt="Feedback image" onclick="showImageModal(\'' + ctx + '/' + escapeHtml(feedback.imagePath) + '\')">';
                html += '</div>';
            }
            html += '</div>';
            
            // Ticket Information
            html += '<div class="detail-section">';
            html += '<h4><i class="fa fa-ticket"></i> Thông tin Ticket</h4>';
            html += '<div class="row">';
            html += '<div class="col-md-6">';
            html += '<p><strong>Mã ticket:</strong> ' + escapeHtml(feedback.ticketNumber || 'N/A') + '</p>';
            html += '<p><strong>Tiêu đề:</strong> ' + escapeHtml(feedback.ticketSubject || 'N/A') + '</p>';
            html += '<p><strong>Danh mục:</strong> ' + getCategoryBadge(feedback.ticketCategory) + '</p>';
            html += '</div>';
            html += '<div class="col-md-6">';
            html += '<p><strong>Trạng thái:</strong> ' + getStatusBadge(feedback.ticketStatus) + '</p>';
            if (feedback.ticketPriority) {
                html += '<p><strong>Độ ưu tiên:</strong> ' + getPriorityBadge(feedback.ticketPriority) + '</p>';
            }
            if (feedback.ticketCreatedAt) {
                html += '<p><strong>Ngày tạo ticket:</strong> ' + formatDate(feedback.ticketCreatedAt) + '</p>';
            }
            html += '</div>';
            html += '</div>';
            if (feedback.ticketDescription) {
                html += '<div style="margin-top: 15px;">';
                html += '<strong>Mô tả:</strong>';
                html += '<p style="white-space: pre-wrap; word-wrap: break-word; background: #f9f9f9; padding: 10px; border-radius: 3px; margin-top: 5px;">';
                html += escapeHtml(feedback.ticketDescription);
                html += '</p>';
                html += '</div>';
            }
            html += '</div>';
            
            // Customer Information
            html += '<div class="detail-section">';
            html += '<h4><i class="fa fa-user"></i> Thông tin Khách Hàng</h4>';
            html += '<div class="row">';
            html += '<div class="col-md-6">';
            html += '<p><strong>Tên:</strong> ' + escapeHtml(feedback.customerName || 'N/A') + '</p>';
            if (feedback.customerCompany) {
                html += '<p><strong>Công ty:</strong> ' + escapeHtml(feedback.customerCompany) + '</p>';
            }
            html += '<p><strong>Email:</strong> ' + escapeHtml(feedback.customerEmail || 'N/A') + '</p>';
            html += '</div>';
            html += '<div class="col-md-6">';
            if (feedback.customerPhone) {
                html += '<p><strong>Điện thoại:</strong> ' + escapeHtml(feedback.customerPhone) + '</p>';
            }
            if (feedback.customerAddress) {
                html += '<p><strong>Địa chỉ:</strong> ' + escapeHtml(feedback.customerAddress) + '</p>';
            }
            html += '</div>';
            html += '</div>';
            html += '</div>';
            
            $('#feedbackDetailContent').html(html);
            $('#viewFeedbackModal').modal('show');
        }
        
        function showImageModal(imageSrc) {
            $('#modalImage').attr('src', imageSrc);
            $('#imageModal').modal('show');
        }
        
        function formatDate(dateStr) {
            if (!dateStr) return 'N/A';
            try {
                var date = new Date(dateStr);
                return date.toLocaleDateString('vi-VN') + ' ' + date.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
            } catch(e) {
                return dateStr;
            }
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
        
        function getCategoryBadge(category) {
            var badges = {
                'technical': '<span class="label label-info">Kỹ thuật</span>',
                'billing': '<span class="label label-success">Thanh toán</span>',
                'general': '<span class="label label-default">Chung</span>',
                'complaint': '<span class="label label-danger">Khiếu nại</span>'
            };
            return badges[category] || '<span class="label label-default">' + (category || 'N/A') + '</span>';
        }
        
        function getStatusBadge(status) {
            var badges = {
                'open': '<span class="label label-primary">Đang chờ</span>',
                'pending': '<span class="label label-primary">Đang chờ</span>',
                'in_progress': '<span class="label label-warning">Đang xử lý</span>',
                'resolved': '<span class="label label-success">Hoàn thành</span>',
                'closed': '<span class="label label-default">Đã đóng</span>',
                'cancelled': '<span class="label label-danger">Đã hủy</span>'
            };
            return badges[status] || '<span class="label label-default">' + (status || 'N/A') + '</span>';
        }
        
        function getPriorityBadge(priority) {
            var badges = {
                'urgent': '<span class="label label-danger">Khẩn cấp</span>',
                'high': '<span class="label label-danger">Cao</span>',
                'medium': '<span class="label label-warning">Trung bình</span>',
                'low': '<span class="label label-info">Thấp</span>'
            };
            return badges[priority] || '<span class="label label-default">' + (priority || 'N/A') + '</span>';
        }
    </script>
</body>
</html>
