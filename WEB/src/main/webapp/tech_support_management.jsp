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
    
    // Kiểm tra quyền: chỉ người có quyền manage_tech_support_requests mới truy cập được
    @SuppressWarnings("unchecked")
    Set<String> userPermissions = (Set<String>) session.getAttribute("userPermissions");
    if (userPermissions == null || !userPermissions.contains("manage_tech_support_requests")) {
        response.sendRedirect(request.getContextPath() + "/error/403.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Yêu Cầu Hỗ Trợ Kỹ Thuật | HL Generator</title>
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
        .ticket-filters {
            background: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .filter-group {
            margin-bottom: 10px;
        }
        .badge-urgent { background-color: #d9534f !important; }
        .badge-high { background-color: #d9534f !important; }
        .badge-medium { background-color: #5bc0de !important; }
        .badge-low { background-color: #5cb85c !important; }
        
        .badge-open { background-color: #f0ad4e !important; }
        .badge-in_progress { background-color: #337ab7 !important; }
        .badge-resolved { background-color: #5cb85c !important; }
        .badge-closed { background-color: #5cb85c !important; }
        
        .ticket-actions {
            white-space: nowrap;
        }
        .ticket-actions .btn {
            padding: 2px 8px;
            font-size: 12px;
            margin-right: 3px;
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
    </style>
</head>
<body class="skin-black">
    <!-- header logo -->
    <header class="header">
        <a href="headtech.jsp" class="logo">
            Quản Lý Yêu Cầu Hỗ Trợ Kỹ Thuật
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
                    Quản Lý Yêu Cầu Hỗ Trợ Kỹ Thuật
                    <small>Xử lý yêu cầu hỗ trợ từ khách hàng</small>
                </h1>
                <ol class="breadcrumb">
                    <li><a href="headtech.jsp"><i class="fa fa-dashboard"></i> Trang chủ</a></li>
                    <li class="active">Yêu cầu hỗ trợ kỹ thuật</li>
                </ol>
            </section>

            <!-- Main content -->
            <section class="content">
                <!-- Alert for forwarded tickets -->
                <div id="forwardedAlert" class="alert alert-info" style="display: none;">
                    <i class="fa fa-info-circle"></i>
                    <strong>Thông báo:</strong> Có yêu cầu hỗ trợ mới được chuyển tiếp từ bộ phận khác.
                </div>

                <!-- Tickets Table -->
                <div class="row">
                    <div class="col-xs-12">
                        <div class="box">
                            <div class="box-header">
                                <h3 class="box-title">Danh sách yêu cầu hỗ trợ kỹ thuật</h3>
                            </div>
                            <div class="box-body table-responsive">
                                <table id="ticketsTable" class="table table-bordered table-striped table-hover">
                                    <thead>
                                        <tr>
                                            <th style="width: 80px;">Mã Ticket</th>
                                            <th>Khách hàng</th>
                                            <th>Tiêu đề</th>
                                            <th style="width: 100px;">Danh mục</th>
                                            <th style="width: 100px;">Độ ưu tiên</th>
                                            <th style="width: 100px;">Trạng thái</th>
                                            <th style="width: 120px;">Ngày tạo</th>
                                            <th style="width: 150px;">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="ticketsTableBody">
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

    <!-- Modal Chi tiết Ticket -->
    <div class="modal fade" id="ticketDetailModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Chi tiết yêu cầu hỗ trợ kỹ thuật</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" id="ticketDetailForm">
                        <input type="hidden" id="detail_ticket_id">
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Mã Ticket:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="detail_ticket_number"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Khách hàng:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="detail_customer"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Email:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="detail_email"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Tiêu đề:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="detail_subject"></p>
                            </div>
                        </div>
                        
                        <!-- Hợp đồng & Sản phẩm -->
                        <div class="form-group" id="detail_contract_product_group" style="display: none;">
                            <label class="col-sm-3 control-label">Hợp đồng & Sản phẩm:</label>
                            <div class="col-sm-9">
                                <div id="detail_contract_product" style="background: linear-gradient(135deg, #e7f3ff 0%, #d6e9f5 100%); padding: 15px; border-radius: 8px; border-left: 4px solid #3c8dbc; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"></div>
                            </div>
                        </div>
                        
                        <!-- Mô tả chi tiết vấn đề -->
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Mô tả chi tiết vấn đề:</label>
                            <div class="col-sm-9">
                                <textarea class="form-control" id="detail_description" rows="4" readonly style="background: #f9f9f9; border: 1px solid #e0e0e0; white-space: pre-wrap; word-wrap: break-word;"></textarea>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Danh mục:</label>
                            <div class="col-sm-3">
                                <p class="form-control-static" id="detail_category"></p>
                            </div>
                            
                            <label class="col-sm-3 control-label">Độ ưu tiên:</label>
                            <div class="col-sm-3">
                                <p class="form-control-static" id="detail_priority"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Trạng thái:</label>
                            <div class="col-sm-3">
                                <p class="form-control-static" id="detail_status"></p>
                            </div>
                            
                            <label class="col-sm-3 control-label">Ngày tạo:</label>
                            <div class="col-sm-3">
                                <p class="form-control-static" id="detail_created"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Ngày mong muốn hoàn thành:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="detail_deadline" style="color: #2c3e50; font-size: 14px;"></p>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Tạo Work Order -->
    <div class="modal fade" id="createWorkOrderModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Tạo đơn hàng công việc</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" id="createWorkOrderForm">
                        <input type="hidden" id="work_order_ticket_id">
                        <input type="hidden" id="work_order_customer_id">
                        
                        <!-- Thông tin từ Ticket -->
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Mã Ticket:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="work_order_ticket_number"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Khách hàng:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="work_order_customer_name"></p>
                            </div>
                        </div>
                        
                        <hr>
                        
                        <!-- Thông tin Work Order -->
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Tiêu đề:</label>
                            <div class="col-sm-9">
                                <input type="text" class="form-control" id="work_order_title" readonly>
                            </div>
                        </div>
                        
                        <!-- Hợp đồng & Sản phẩm -->
                        <div class="form-group" id="work_order_contract_product_group" style="display: none;">
                            <label class="col-sm-3 control-label">Hợp đồng & Sản phẩm:</label>
                            <div class="col-sm-9">
                                <div id="work_order_contract_product" style="background: linear-gradient(135deg, #e7f3ff 0%, #d6e9f5 100%); padding: 15px; border-radius: 8px; border-left: 4px solid #3c8dbc; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"></div>
                            </div>
                        </div>
                        
                        <!-- Mô tả chi tiết vấn đề -->
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Mô tả chi tiết vấn đề:</label>
                            <div class="col-sm-9">
                                <textarea class="form-control" id="work_order_description" rows="4" readonly style="background: #f9f9f9; border: 1px solid #e0e0e0; white-space: pre-wrap; word-wrap: break-word;"></textarea>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Ngày mong muốn hoàn thành:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="work_order_deadline" style="color: #2c3e50; font-size: 14px;"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Độ ưu tiên:</label>
                            <div class="col-sm-9">
                                <input type="text" class="form-control" id="work_order_priority_display" readonly>
                                <input type="hidden" id="work_order_priority">
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Trạng thái:</label>
                            <div class="col-sm-9">
                                <input type="text" class="form-control" id="work_order_status_display" value="Đang xử lý" readonly>
                                <input type="hidden" id="work_order_status" value="in_progress">
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Giờ ước tính:</label>
                            <div class="col-sm-9">
                                <input type="number" class="form-control" id="work_order_estimated_hours" step="0.1" min="0.1" max="100" placeholder="Số giờ ước tính (VD: 2.5)">
                                <small class="help-block">Thời gian dự kiến hoàn thành (giờ) - Tối thiểu: 0.1h, Tối đa: 100h</small>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Ngày thực hiện:</label>
                            <div class="col-sm-9">
                                <input type="date" class="form-control" id="work_order_scheduled_date" min="">
                                <small class="help-block">Ngày thực hiện công việc (không được chọn ngày quá khứ và phải nhỏ hơn hoặc bằng ngày mong muốn hoàn thành)</small>
                            </div>
                        </div>
                        
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-success" id="btnConfirmCreateWorkOrder">
                        <i class="fa fa-plus"></i> Tạo đơn hàng
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
        var allTickets = [];
        var filteredTickets = [];
        var autoRefreshInterval = null; // Store interval ID for auto-refresh
        
        $(document).ready(function() {
            loadTickets();
            
            // Set minimum date for scheduled date input (today)
            setMinDateForScheduledDate();
            
            // Sync ticket status for completed work orders on page load (one-time)
            syncTicketStatusForCompletedWorkOrders();
            
            // Auto-refresh tickets every 30 seconds to keep status updated
            autoRefreshInterval = setInterval(function() {
                console.log('Auto-refreshing tickets...');
                loadTickets(true); // Silent mode for auto-refresh
            }, 30000); // 30 seconds
            
            // Stop auto-refresh when page is hidden (tab is not active)
            $(document).on('visibilitychange', function() {
                if (document.hidden) {
                    if (autoRefreshInterval) {
                        clearInterval(autoRefreshInterval);
                        autoRefreshInterval = null;
                        console.log('Auto-refresh paused (tab hidden)');
                    }
                } else {
                    // Resume auto-refresh when tab becomes visible
                    if (!autoRefreshInterval) {
                        loadTickets(true); // Load immediately (silent mode)
                        autoRefreshInterval = setInterval(function() {
                            console.log('Auto-refreshing tickets...');
                            loadTickets(true); // Silent mode for auto-refresh
                        }, 30000);
                        console.log('Auto-refresh resumed (tab visible)');
                    }
                }
            });
            
            // Check if there's a forwarded ticket in localStorage
            var forwardedTicket = localStorage.getItem('forwardedTicket');
            if(forwardedTicket) {
                try {
                    var ticket = JSON.parse(forwardedTicket);
                    // Thêm ticket được chuyển tiếp vào danh sách
                    allTickets.push(ticket);
                    filteredTickets = allTickets;
                    renderTable();
                    // Xóa thông tin đã xử lý
                    localStorage.removeItem('forwardedTicket');
                    // Auto-open the ticket detail modal after data is loaded
                    setTimeout(function() {
                        viewTicketDetail(ticket.id);
                    }, 1000);
                } catch(e) {
                    console.log('Error parsing forwarded ticket:', e);
                }
            }
            
            // Confirm create work order
            $('#btnConfirmCreateWorkOrder').click(function() {
                confirmCreateWorkOrder();
            });
            
            // Real-time validation for estimated hours
            $('#work_order_estimated_hours').on('input', function() {
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
            
            // Validate scheduled date when modal is shown
            $('#createWorkOrderModal').on('shown.bs.modal', function() {
                setMinDateForScheduledDate();
            });
            
            // Validate scheduled date on change
            $('#work_order_scheduled_date').on('change', function() {
                validateScheduledDate();
            });
            
        });
        
        function setMinDateForScheduledDate() {
            // Set minimum date to today (YYYY-MM-DD format)
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0'); // January is 0!
            var yyyy = today.getFullYear();
            var todayStr = yyyy + '-' + mm + '-' + dd;
            $('#work_order_scheduled_date').attr('min', todayStr);
        }
        
        function validateScheduledDate() {
            var scheduledDate = $('#work_order_scheduled_date').val();
            if (scheduledDate) {
                var selectedDate = new Date(scheduledDate);
                var today = new Date();
                today.setHours(0, 0, 0, 0); // Reset time to 00:00:00
                selectedDate.setHours(0, 0, 0, 0);
                
                // Kiểm tra không được là ngày quá khứ
                if (selectedDate < today) {
                    alert('⚠ Lỗi: Ngày thực hiện không được là ngày quá khứ. Vui lòng chọn ngày hôm nay hoặc ngày trong tương lai.');
                    $('#work_order_scheduled_date').val('');
                    $('#work_order_scheduled_date').focus();
                    return false;
                }
                
                // Kiểm tra ngày thực hiện <= deadline
                var deadlineValue = $('#work_order_scheduled_date').data('deadline');
                if (deadlineValue) {
                    try {
                        // Deadline đã được lưu dạng yyyy-MM-dd
                        var deadlineDate = new Date(deadlineValue);
                        deadlineDate.setHours(0, 0, 0, 0);
                        
                        if (selectedDate > deadlineDate) {
                            // Format deadline để hiển thị trong thông báo
                            var deadlineParts = deadlineValue.split('-');
                            var deadlineDisplay = deadlineParts[2] + '/' + deadlineParts[1] + '/' + deadlineParts[0];
                            alert('⚠ Lỗi: Ngày thực hiện không được lớn hơn ngày mong muốn hoàn thành (' + deadlineDisplay + '). Vui lòng chọn ngày nhỏ hơn hoặc bằng ngày mong muốn hoàn thành.');
                            $('#work_order_scheduled_date').val('');
                            $('#work_order_scheduled_date').focus();
                            return false;
                        }
                    } catch (e) {
                        console.warn('Không thể parse deadline:', e);
                    }
                }
            }
            return true;
        }
        
        function loadTickets(silent) {
            // silent: if true, don't show console logs (for auto-refresh)
            // Gọi API mới để lấy danh sách ticket technical
            $.ajax({
                url: ctx + '/api/tech-support?action=list',
                type: 'GET',
                dataType: 'json',
                cache: false, // Prevent caching
                success: function(response) {
                    if (response.success) {
                        // Store previous ticket count for comparison
                        var previousCount = allTickets.length;
                        var previousResolvedCount = allTickets.filter(function(t) { return t.status === 'resolved' || t.status === 'closed'; }).length;
                        
                        // Tất cả ticket đã được lọc ở backend (chỉ technical)
                        var newTickets = response.data || [];
                        var newResolvedCount = newTickets.filter(function(t) { return t.status === 'resolved' || t.status === 'closed'; }).length;
                        
                        // Check if any ticket status changed
                        var statusChanged = false;
                        if (allTickets.length > 0) {
                            for (var i = 0; i < newTickets.length; i++) {
                                var newTicket = newTickets[i];
                                var oldTicket = allTickets.find(function(t) { return t.id == newTicket.id; });
                                if (oldTicket && oldTicket.status !== newTicket.status) {
                                    statusChanged = true;
                                    if (!silent) {
                                        console.log('Ticket #' + newTicket.id + ' status changed: ' + oldTicket.status + ' -> ' + newTicket.status);
                                    }
                                    break;
                                }
                            }
                        }
                        
                        allTickets = newTickets;
                        filteredTickets = allTickets;
                        renderTable();
                        
                        if (!silent) {
                            console.log('Đã tải ' + allTickets.length + ' ticket kỹ thuật');
                        }
                        
                        // Show notification if status changed or new resolved tickets
                        if (statusChanged || newResolvedCount > previousResolvedCount) {
                            if (!silent) {
                                // Show a subtle notification that data was updated
                                var notification = $('<div class="alert alert-info alert-dismissible" style="position: fixed; top: 60px; right: 20px; z-index: 9999; min-width: 300px; display: none;">' +
                                    '<button type="button" class="close" data-dismiss="alert">&times;</button>' +
                                    '<i class="fa fa-refresh"></i> <strong>Đã cập nhật:</strong> Trạng thái ticket đã thay đổi.' +
                                    '</div>');
                                $('body').append(notification);
                                notification.fadeIn();
                                setTimeout(function() {
                                    notification.fadeOut(function() {
                                        $(this).remove();
                                    });
                                }, 3000);
                            }
                        }
                        
                        // Debug: Kiểm tra customerId trong tickets
                        if (allTickets.length > 0 && !silent) {
                            console.log('Sample ticket có customerId:', allTickets[0].customerId);
                            console.log('Sample ticket object:', allTickets[0]);
                        }
                        
                        // Hiển thị thông báo nếu có ticket mới (only for initial load or manual refresh)
                        if (!silent) {
                            var openTickets = allTickets.filter(function(t) {
                                return t.status === 'open' || t.status === 'in_progress';
                            });
                            
                            if (openTickets.length > 0) {
                                $('#forwardedAlert').show();
                                $('#forwardedAlert').html('<i class="fa fa-info-circle"></i> <strong>Thông báo:</strong> Có ' + openTickets.length + ' yêu cầu hỗ trợ kỹ thuật cần xử lý.');
                                setTimeout(function() {
                                    $('#forwardedAlert').fadeOut();
                                }, 8000);
                            }
                        }
                    } else {
                        if (!silent) {
                            console.error('Lỗi tải danh sách ticket:', response.message);
                            showError('Không thể tải danh sách yêu cầu hỗ trợ: ' + response.message);
                        }
                    }
                },
                error: function(xhr, status, error) {
                    if (!silent) {
                        console.error('Không thể tải danh sách ticket:', error);
                        showError('Lỗi kết nối server');
                    }
                }
            });
        }
        
        
        function renderTable() {
            var tbody = $('#ticketsTableBody');
            tbody.empty();
            
            if(!filteredTickets || filteredTickets.length === 0) {
                tbody.append('<tr><td colspan="8" class="text-center">Không có dữ liệu</td></tr>');
                return;
            }
            
             filteredTickets.forEach(function(ticket) {
                 var userRole = '<%= userRole %>';
                 var actionButtons = '<button class="btn btn-info btn-view" data-id="' + ticket.id + '"><i class="fa fa-eye"></i> Xem</button>';
                 
                 // Chỉ hiển thị nút "Tạo WO" cho head_technician và admin
                 if (userRole === 'head_technician' || userRole === 'admin') {
                     // Check if ticket has work order (async check, will update button later)
                     var hasWorkOrder = false;
                     if (ticket.customerId && ticket.subject) {
                         // Will check async and disable button if work order exists
                         actionButtons += '<button class="btn btn-success btn-create-work-order" data-id="' + ticket.id + '" data-customer-id="' + (ticket.customerId || '') + '" data-subject="' + (ticket.subject || '').replace(/"/g, '&quot;') + '"><i class="fa fa-plus"></i> Tạo WO</button>';
                     } else {
                         actionButtons += '<button class="btn btn-success btn-create-work-order" data-id="' + ticket.id + '"><i class="fa fa-plus"></i> Tạo WO</button>';
                     }
                 }
                 
                 var row = '<tr>' +
                     '<td><strong>' + (ticket.ticketNumber || '#' + ticket.id) + '</strong></td>' +
                     '<td>' + (ticket.customerName || 'N/A') + '</td>' +
                     '<td>' + (ticket.subject || '') + '</td>' +
                     '<td>' + getCategoryBadge(ticket.category) + '</td>' +
                     '<td>' + getPriorityBadge(ticket.priority) + '</td>' +
                     '<td>' + getStatusBadge(ticket.status) + '</td>' +
                     '<td>' + formatDate(ticket.createdAt) + '</td>' +
                     '<td class="ticket-actions">' + actionButtons + '</td>' +
                 '</tr>';
                 tbody.append(row);
             });
             
             // Check work orders for tickets (async, after rendering)
             setTimeout(function() {
                 $('.btn-create-work-order').each(function() {
                     var $btn = $(this);
                     var ticketId = $btn.data('id');
                     var customerId = $btn.data('customer-id');
                     var subject = $btn.data('subject');
                     
                     if (customerId && subject) {
                         $.ajax({
                             url: ctx + '/api/work-orders?action=checkByTicket',
                             type: 'GET',
                             data: {
                                 ticketId: ticketId,
                                 title: subject,
                                 customerId: customerId
                             },
                             dataType: 'json',
                             success: function(response) {
                                 if (response && response.success && response.exists) {
                                     $btn.prop('disabled', true);
                                     $btn.html('<i class="fa fa-check"></i> Đã có WO');
                                     $btn.removeClass('btn-success').addClass('btn-default');
                                     $btn.attr('title', 'Ticket này đã có work order: ' + (response.workOrderNumber || 'N/A'));
                                 }
                             },
                             error: function() {
                                 // Silently fail, allow button to work
                             }
                         });
                     }
                 });
             }, 500);
            
            // Bind view button
            $('.btn-view').click(function() {
                var id = $(this).data('id');
                viewTicketDetail(id);
            });
            
            // Bind create work order button
            $('.btn-create-work-order').click(function() {
                var id = $(this).data('id');
                showCreateWorkOrderModal(id);
            });
            
            // Khởi tạo DataTable với phân trang
            initializeDataTable();
        }
        
        var ticketsDataTable = null;
        
        function initializeDataTable() {
            // Kiểm tra xem DataTables đã được load chưa
            if (typeof $.fn.DataTable === 'undefined') {
                console.error('DataTables library is not loaded');
                return;
            }
            
            // Kiểm tra và destroy DataTable nếu đã tồn tại
            if ($.fn.DataTable.isDataTable('#ticketsTable')) {
                try {
                    $('#ticketsTable').DataTable().destroy();
                    ticketsDataTable = null;
                } catch(e) {
                    console.log('Error destroying DataTable:', e);
                }
            }
            
            // Nếu biến ticketsDataTable vẫn còn, reset nó
            if (ticketsDataTable) {
                ticketsDataTable = null;
            }
            
            // Khởi tạo DataTable
            try {
                ticketsDataTable = $('#ticketsTable').DataTable({
                    "language": {
                        "url": "//cdn.datatables.net/plug-ins/1.10.24/i18n/Vietnamese.json"
                    },
                    "pageLength": 8, // Hiển thị 8 bản ghi mỗi trang
                    "lengthChange": false, // Ẩn dropdown "records per page"
                    "paging": true, // Bật phân trang
                    "pagingType": "full_numbers", // Hiển thị số trang đầy đủ (Previous, 1, 2, 3, ..., Next)
                    "info": true, // Hiển thị thông tin "Showing X to Y of Z entries"
                    "dom": '<"top"lf>rt<"bottom"ip><"clear">', // Cấu trúc DOM: top (length, filter), table, bottom (info, pagination)
                    "order": [[6, "desc"]], // Sắp xếp theo Ngày tạo (column 6) giảm dần
                    "columnDefs": [
                        { "orderable": false, "targets": 7 } // Không sort cột Thao tác (cột cuối cùng)
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
        
        function getCategoryBadge(category) {
            var labels = {
                'technical': 'Kỹ thuật',
                'billing': 'Thanh toán',
                'general': 'Chung',
                'complaint': 'Khiếu nại'
            };
            var colors = {
                'technical': 'info',
                'billing': 'success',
                'general': 'default',
                'complaint': 'danger'
            };
            return '<span class="label label-' + (colors[category] || 'default') + '">' + 
                   (labels[category] || category) + '</span>';
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
                'open': 'Chờ xử lý',
                'in_progress': 'Đang xử lý',
                'resolved': 'Đã giải quyết',
                'closed': 'Đã giải quyết'
            };
            // Nếu status là closed, hiển thị như resolved
            var displayStatus = (status === 'closed') ? 'resolved' : status;
            var badge = displayStatus ? 'badge-' + displayStatus : '';
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
        
        function viewTicketDetail(id) {
            // Load fresh data from server
            $.ajax({
                url: ctx + '/api/tech-support?action=get',
                type: 'GET',
                data: { id: id },
                dataType: 'json',
                success: function(response) {
                    if (response.success && response.data) {
                        displayTicketDetail(response.data);
                    } else {
                        // Fallback to cached data
                        var ticket = allTickets.find(function(t) { return t.id == id; });
                        if (ticket) {
                            displayTicketDetail(ticket);
                        } else {
                            alert('Không thể tải chi tiết ticket');
                        }
                    }
                },
                error: function() {
                    // Fallback to cached data
                    var ticket = allTickets.find(function(t) { return t.id == id; });
                    if (ticket) {
                        displayTicketDetail(ticket);
                    } else {
                        alert('Không thể tải chi tiết ticket');
                    }
                }
            });
        }
        
        function displayTicketDetail(ticket) {
            $('#detail_ticket_id').val(ticket.id);
            $('#detail_ticket_number').text(ticket.ticketNumber || '#' + ticket.id);
            $('#detail_customer').text(ticket.customerName || 'N/A');
            $('#detail_email').text(ticket.customerEmail || 'N/A');
            $('#detail_subject').text(ticket.subject || '');
            
            // Tách thông tin hợp đồng và sản phẩm từ description
            var description = ticket.description || '';
            var contractInfo = '';
            var productInfo = '';
            var cleanDescription = description;
            
            // Tìm thông tin hợp đồng: [Hợp đồng: ...]
            var contractMatch = description.match(/\[Hợp đồng:([^\]]+)\]/);
            if (contractMatch) {
                contractInfo = contractMatch[1].trim();
                cleanDescription = cleanDescription.replace(/\[Hợp đồng:[^\]]+\]\s*/g, '').trim();
            }
            
            // Tìm thông tin sản phẩm: [Sản phẩm: ...]
            var productMatch = description.match(/\[Sản phẩm:([^\]]+)\]/);
            if (productMatch) {
                productInfo = productMatch[1].trim();
                cleanDescription = cleanDescription.replace(/\[Sản phẩm:[^\]]+\]\s*/g, '').trim();
            }
            
            // Hiển thị hợp đồng & sản phẩm
            var contractProductHtml = '';
            if (contractInfo || productInfo) {
                $('#detail_contract_product_group').show();
                if (contractInfo) {
                    contractProductHtml += '<div style="margin-bottom: 12px; padding-bottom: 12px; border-bottom: 1px solid rgba(60, 141, 188, 0.2);">';
                    contractProductHtml += '<div style="display: flex; align-items: flex-start; gap: 10px;">';
                    contractProductHtml += '<div style="flex-shrink: 0; color: #3c8dbc; font-size: 18px; margin-top: 2px;"><i class="fa fa-file-text-o"></i></div>';
                    contractProductHtml += '<div style="flex: 1; min-width: 0;">';
                    contractProductHtml += '<strong style="display: block; margin-bottom: 5px; color: #2c3e50; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">HỢP ĐỒNG</strong>';
                    contractProductHtml += '<div style="word-wrap: break-word; word-break: break-word; overflow-wrap: break-word; white-space: normal; font-size: 14px; color: #34495e; line-height: 1.5; max-width: 100%;">' + escapeHtml(contractInfo) + '</div>';
                    contractProductHtml += '</div></div></div>';
                }
                
                if (productInfo) {
                    contractProductHtml += '<div style="padding-top: 0;">';
                    contractProductHtml += '<div style="display: flex; align-items: flex-start; gap: 10px;">';
                    contractProductHtml += '<div style="flex-shrink: 0; color: #27ae60; font-size: 18px; margin-top: 2px;"><i class="fa fa-cube"></i></div>';
                    contractProductHtml += '<div style="flex: 1; min-width: 0;">';
                    contractProductHtml += '<strong style="display: block; margin-bottom: 5px; color: #2c3e50; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">SẢN PHẨM</strong>';
                    contractProductHtml += '<div style="word-wrap: break-word; word-break: break-word; overflow-wrap: break-word; white-space: normal; font-size: 14px; color: #34495e; line-height: 1.5; max-width: 100%;">' + escapeHtml(productInfo) + '</div>';
                    contractProductHtml += '</div></div></div>';
                }
                $('#detail_contract_product').html(contractProductHtml);
            } else {
                $('#detail_contract_product_group').hide();
            }
            
            // Hiển thị mô tả chi tiết (đã loại bỏ hợp đồng/sản phẩm)
            $('#detail_description').val(cleanDescription || 'Không có mô tả');
            
            // Hiển thị text cho các trường category, priority, status
            var categoryLabels = {
                'technical': 'Kỹ thuật',
                'billing': 'Thanh toán',
                'general': 'Chung',
                'complaint': 'Khiếu nại'
            };
            var priorityLabels = {
                'urgent': 'Khẩn cấp',
                'high': 'Cao',
                'medium': 'Trung bình',
                'low': 'Thấp'
            };
            var statusLabels = {
                'open': 'Chờ xử lý',
                'in_progress': 'Đang xử lý',
                'resolved': 'Đã giải quyết',
                'closed': 'Đã giải quyết'
            };
            
            $('#detail_category').text(categoryLabels[ticket.category] || ticket.category || 'N/A');
            $('#detail_priority').text(priorityLabels[ticket.priority] || ticket.priority || 'N/A');
            $('#detail_status').text(statusLabels[ticket.status] || ticket.status || 'N/A');
            $('#detail_created').text(formatDate(ticket.createdAt));
            
            // Hiển thị deadline - format từ yyyy-MM-dd sang dd/MM/yyyy
            var deadlineDisplay = '';
            if (ticket.deadline && typeof ticket.deadline === 'string' && ticket.deadline.trim() !== '' && ticket.deadline !== 'null') {
                try {
                    // Deadline từ DB là yyyy-MM-dd, chuyển sang dd/MM/yyyy
                    var deadlineStr = ticket.deadline.trim();
                    if (deadlineStr.match(/^\d{4}-\d{2}-\d{2}$/)) {
                        var parts = deadlineStr.split('-');
                        deadlineDisplay = parts[2] + '/' + parts[1] + '/' + parts[0];
                    } else {
                        deadlineDisplay = deadlineStr;
                    }
                } catch (e) {
                    deadlineDisplay = ticket.deadline;
                }
            } else {
                deadlineDisplay = '<span style="color: #999; font-style: italic;">Chưa có</span>';
            }
            $('#detail_deadline').html(deadlineDisplay);
            
            $('#ticketDetailModal').modal('show');
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
        
        function showCreateWorkOrderModal(id) {
            var ticket = allTickets.find(function(t) { return t.id == id; });
            if(!ticket) {
                console.error('Không tìm thấy ticket với ID:', id);
                return;
            }
            
            // Debug: Log thông tin ticket
            console.log('Ticket object:', ticket);
            console.log('ticket.customerId:', ticket.customerId);
            console.log('ticket.customerId type:', typeof ticket.customerId);
            
            // Validate: Check if ticket already has a work order
            var customerIdValue = (ticket.customerId != null && ticket.customerId !== undefined && ticket.customerId !== 0) 
                ? ticket.customerId : '';
            
            if (customerIdValue && ticket.subject) {
                // Check if work order already exists
                $.ajax({
                    url: ctx + '/api/work-orders?action=checkByTicket',
                    type: 'GET',
                    data: {
                        ticketId: ticket.id,
                        title: ticket.subject,
                        customerId: customerIdValue
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response && response.success && response.exists) {
                            alert('Cảnh báo: Ticket này đã có work order!\n\n' +
                                  'Mã work order: ' + (response.workOrderNumber || 'N/A') + '\n\n' +
                                  'Mỗi ticket chỉ được tạo 1 work order. Vui lòng kiểm tra lại.');
                            return;
                        }
                        
                        // If no existing work order, proceed to open modal
                        openCreateWorkOrderModal(ticket, customerIdValue);
                    },
                    error: function() {
                        // If check fails, still allow to proceed (but backend will validate)
                        console.warn('Không thể kiểm tra work order, sẽ kiểm tra ở backend');
                        openCreateWorkOrderModal(ticket, customerIdValue);
                    }
                });
            } else {
                // If no customerId or subject, proceed directly (backend will validate)
                openCreateWorkOrderModal(ticket, customerIdValue);
            }
        }
        
        function openCreateWorkOrderModal(ticket, customerIdValue) {
            // Load fresh data from server để có đầy đủ thông tin deadline
            $.ajax({
                url: ctx + '/api/tech-support?action=get',
                type: 'GET',
                data: { id: ticket.id },
                dataType: 'json',
                success: function(response) {
                    if (response.success && response.data) {
                        // Sử dụng dữ liệu từ server
                        populateWorkOrderModal(response.data, customerIdValue);
                    } else {
                        // Fallback to cached data
                        populateWorkOrderModal(ticket, customerIdValue);
                    }
                },
                error: function() {
                    // Fallback to cached data
                    populateWorkOrderModal(ticket, customerIdValue);
                }
            });
        }
        
        function populateWorkOrderModal(ticket, customerIdValue) {
            // Điền thông tin từ ticket
            $('#work_order_ticket_id').val(ticket.id);
            $('#work_order_customer_id').val(customerIdValue);
            console.log('Đã set customerId vào input:', customerIdValue);
            console.log('Giá trị customerId từ input sau khi set:', $('#work_order_customer_id').val());
            
            $('#work_order_ticket_number').text(ticket.ticketNumber || '#' + ticket.id);
            $('#work_order_customer_name').text(ticket.customerName || 'N/A');
            
            // Điền thông tin work order (readonly fields)
            $('#work_order_title').val(ticket.subject || '');
            
            // Tách thông tin hợp đồng và sản phẩm từ description
            var description = ticket.description || '';
            var contractInfo = '';
            var productInfo = '';
            var cleanDescription = description;
            
            // Tìm thông tin hợp đồng: [Hợp đồng: ...]
            var contractMatch = description.match(/\[Hợp đồng:([^\]]+)\]/);
            if (contractMatch) {
                contractInfo = contractMatch[1].trim();
                cleanDescription = cleanDescription.replace(/\[Hợp đồng:[^\]]+\]\s*/g, '').trim();
            }
            
            // Tìm thông tin sản phẩm: [Sản phẩm: ...]
            var productMatch = description.match(/\[Sản phẩm:([^\]]+)\]/);
            if (productMatch) {
                productInfo = productMatch[1].trim();
                cleanDescription = cleanDescription.replace(/\[Sản phẩm:[^\]]+\]\s*/g, '').trim();
            }
            
            // Hiển thị hợp đồng & sản phẩm
            var contractProductHtml = '';
            if (contractInfo || productInfo) {
                $('#work_order_contract_product_group').show();
                if (contractInfo) {
                    contractProductHtml += '<div style="margin-bottom: 12px; padding-bottom: 12px; border-bottom: 1px solid rgba(60, 141, 188, 0.2);">';
                    contractProductHtml += '<div style="display: flex; align-items: flex-start; gap: 10px;">';
                    contractProductHtml += '<div style="flex-shrink: 0; color: #3c8dbc; font-size: 18px; margin-top: 2px;"><i class="fa fa-file-text-o"></i></div>';
                    contractProductHtml += '<div style="flex: 1; min-width: 0;">';
                    contractProductHtml += '<strong style="display: block; margin-bottom: 5px; color: #2c3e50; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">HỢP ĐỒNG</strong>';
                    contractProductHtml += '<div style="word-wrap: break-word; word-break: break-word; overflow-wrap: break-word; white-space: normal; font-size: 14px; color: #34495e; line-height: 1.5; max-width: 100%;">' + escapeHtml(contractInfo) + '</div>';
                    contractProductHtml += '</div></div></div>';
                }
                
                if (productInfo) {
                    contractProductHtml += '<div style="padding-top: 0;">';
                    contractProductHtml += '<div style="display: flex; align-items: flex-start; gap: 10px;">';
                    contractProductHtml += '<div style="flex-shrink: 0; color: #27ae60; font-size: 18px; margin-top: 2px;"><i class="fa fa-cube"></i></div>';
                    contractProductHtml += '<div style="flex: 1; min-width: 0;">';
                    contractProductHtml += '<strong style="display: block; margin-bottom: 5px; color: #2c3e50; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">SẢN PHẨM</strong>';
                    contractProductHtml += '<div style="word-wrap: break-word; word-break: break-word; overflow-wrap: break-word; white-space: normal; font-size: 14px; color: #34495e; line-height: 1.5; max-width: 100%;">' + escapeHtml(productInfo) + '</div>';
                    contractProductHtml += '</div></div></div>';
                }
                $('#work_order_contract_product').html(contractProductHtml);
            } else {
                $('#work_order_contract_product_group').hide();
            }
            
            // Hiển thị mô tả chi tiết (đã loại bỏ hợp đồng/sản phẩm)
            $('#work_order_description').val(cleanDescription || 'Không có mô tả');
            
            // Set độ ưu tiên
            var priority = ticket.priority || 'medium';
            var priorityLabels = {
                'urgent': 'Khẩn cấp',
                'high': 'Cao',
                'medium': 'Trung bình',
                'low': 'Thấp'
            };
            $('#work_order_priority').val(priority);
            $('#work_order_priority_display').val(priorityLabels[priority] || priority);
            
            // Set trạng thái mặc định là "in_progress"
            $('#work_order_status').val('in_progress');
            $('#work_order_status_display').val('Đang xử lý');
            
            // Hiển thị deadline - format từ yyyy-MM-dd sang dd/MM/yyyy
            var deadlineDisplay = '';
            var deadlineDateValue = null; // Lưu deadline dạng Date object để validate
            if (ticket.deadline && typeof ticket.deadline === 'string' && ticket.deadline.trim() !== '' && ticket.deadline !== 'null') {
                try {
                    // Deadline từ DB là yyyy-MM-dd, chuyển sang dd/MM/yyyy
                    var deadlineStr = ticket.deadline.trim();
                    if (deadlineStr.match(/^\d{4}-\d{2}-\d{2}$/)) {
                        var parts = deadlineStr.split('-');
                        deadlineDisplay = parts[2] + '/' + parts[1] + '/' + parts[0];
                        // Lưu deadline dạng yyyy-MM-dd vào data attribute để validate
                        deadlineDateValue = deadlineStr;
                    } else {
                        deadlineDisplay = deadlineStr;
                    }
                } catch (e) {
                    deadlineDisplay = ticket.deadline;
                }
            } else {
                deadlineDisplay = '<span style="color: #999; font-style: italic;">Chưa có</span>';
            }
            $('#work_order_deadline').html(deadlineDisplay);
            // Lưu deadline vào data attribute để validate
            if (deadlineDateValue) {
                $('#work_order_scheduled_date').data('deadline', deadlineDateValue);
            } else {
                $('#work_order_scheduled_date').removeData('deadline');
            }
            
            $('#work_order_estimated_hours').val('');
            $('#work_order_scheduled_date').val('');
            
            // Set minimum date when opening modal
            setMinDateForScheduledDate();
            
            $('#createWorkOrderModal').modal('show');
        }
        
        function confirmCreateWorkOrder() {
            // Validate required fields (từ ticket, không cần user nhập)
            var title = $('#work_order_title').val().trim();
            var description = $('#work_order_description').val().trim();
            
            if(!title) {
                alert('Lỗi: Không có tiêu đề từ ticket!');
                return;
            }
            
            if(!description) {
                alert('Lỗi: Không có mô tả từ ticket!');
                return;
            }
            
            // Validate scheduled date before submitting
            if (!validateScheduledDate()) {
                return;
            }
            
            var ticketId = $('#work_order_ticket_id').val();
            var customerId = $('#work_order_customer_id').val();
            
            // Debug: Kiểm tra customerId
            var ticket = allTickets.find(function(t) { return t.id == ticketId; });
            
            // Nếu customerId rỗng, thử lấy lại từ ticket object
            // Kiểm tra: rỗng, null, undefined, hoặc chuỗi 'null'/'undefined'
            if (!customerId || customerId === '' || customerId === 'null' || customerId === 'undefined' || customerId === '0') {
                if (ticket) {
                    // Thử lấy customerId từ ticket - kiểm tra cả null và 0
                    // ticket.customerId có thể là null, undefined, 0, hoặc số hợp lệ
                    if (ticket.customerId != null && ticket.customerId !== undefined && ticket.customerId !== 0) {
                        customerId = ticket.customerId;
                        $('#work_order_customer_id').val(customerId);
                        console.log('Đã lấy lại customerId từ ticket:', customerId);
                    } else {
                        // Ticket không có customerId hợp lệ (null, undefined, hoặc 0)
                        console.error('Ticket không có customerId hợp lệ trong object');
                        console.log('Ticket ID:', ticketId);
                        console.log('Ticket object:', ticket);
                        console.log('ticket.customerId value:', ticket.customerId);
                        console.log('ticket.customerId type:', typeof ticket.customerId);
                        alert('Lỗi: Ticket này không có thông tin khách hàng trong hệ thống.\n\n' +
                              'Nguyên nhân: customer_id trong database có thể là NULL hoặc 0.\n\n' +
                              'Giải pháp:\n' +
                              '1. Kiểm tra database: SELECT customer_id FROM support_requests WHERE id = ' + ticketId + ';\n' +
                              '2. Nếu customer_id là NULL, cần cập nhật:\n' +
                              '   UPDATE support_requests SET customer_id = [ID_KHÁCH_HÀNG] WHERE id = ' + ticketId + ';\n\n' +
                              'Vui lòng liên hệ quản trị viên để cập nhật thông tin khách hàng cho ticket.\n\n' +
                              'Ticket ID: ' + ticketId);
                        return;
                    }
                } else {
                    alert('Lỗi: Không tìm thấy ticket với ID: ' + ticketId);
                    return;
                }
            }
            
            // Validate: customerId bắt buộc phải có
            if (!customerId || customerId === '' || customerId === 'null' || customerId === 'undefined') {
                alert('Lỗi: Không tìm thấy thông tin khách hàng. Không thể tạo work order.\n\nVui lòng kiểm tra lại ticket hoặc liên hệ quản trị viên.');
                return;
            }
            
            // Validate estimated hours
            var estimatedHours = $('#work_order_estimated_hours').val();
            if (estimatedHours && estimatedHours.trim() !== '') {
                var hoursValue = parseFloat(estimatedHours);
                if (isNaN(hoursValue)) {
                    alert('Lỗi: Giờ ước tính không hợp lệ. Vui lòng nhập số.');
                    $('#work_order_estimated_hours').focus();
                    return;
                }
                if (hoursValue <= 0) {
                    alert('Lỗi: Giờ ước tính phải lớn hơn 0. Vui lòng nhập giá trị hợp lệ.');
                    $('#work_order_estimated_hours').focus();
                    return;
                }
                if (hoursValue > 100) {
                    alert('Lỗi: Giờ ước tính không được vượt quá 100 giờ. Vui lòng nhập giá trị nhỏ hơn.');
                    $('#work_order_estimated_hours').focus();
                    return;
                }
            }
            
            var data = {
                action: 'create',
                ticketId: ticketId,
                customerId: customerId,
                title: title,
                description: description,
                priority: $('#work_order_priority').val() || 'medium',
                status: $('#work_order_status').val() || 'in_progress',
                estimatedHours: estimatedHours && estimatedHours.trim() !== '' ? estimatedHours : null,
                scheduledDate: $('#work_order_scheduled_date').val() || null
            };
            
            console.log('Tạo work order với dữ liệu:', data);
            
            $.ajax({
                url: ctx + '/api/work-orders',
                type: 'POST',
                data: data,
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        alert('✓ Tạo đơn hàng công việc thành công!\n\nMã đơn hàng: ' + (response.workOrderNumber || ''));
                        $('#createWorkOrderModal').modal('hide');
                        
                        // Reset form
                        $('#createWorkOrderForm')[0].reset();
                        
                        // Reload tickets (not silent, show notifications if status changed)
                        loadTickets(false);
                    } else {
                        var errorMsg = response.message || 'Không thể tạo đơn hàng';
                        // Check if error is about existing work order
                        if (errorMsg.includes('đã có work order') || errorMsg.includes('existingWorkOrderNumber')) {
                            var existingWO = response.existingWorkOrderNumber || 'N/A';
                            alert('✗ Lỗi: Ticket này đã có work order!\n\n' +
                                  'Mã work order: ' + existingWO + '\n\n' +
                                  'Mỗi ticket chỉ được tạo 1 work order. Vui lòng kiểm tra lại.');
                        } else {
                            alert('✗ Lỗi: ' + errorMsg);
                        }
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error creating work order:', error);
                    alert('✗ Lỗi kết nối máy chủ: ' + error);
                }
            });
        }
        
        function showError(msg) {
            $('#ticketsTableBody').html('<tr><td colspan="8" class="text-center text-danger">' + msg + '</td></tr>');
        }
        
        /**
         * Sync ticket status for all completed work orders
         * This fixes tickets that weren't updated when work order was closed
         */
        function syncTicketStatusForCompletedWorkOrders() {
            $.ajax({
                url: ctx + '/api/work-orders?action=syncTicketStatus',
                type: 'GET',
                dataType: 'json',
                cache: false,
                success: function(response) {
                    if (response && response.success) {
                        var syncedCount = response.syncedCount || 0;
                        var alreadyResolved = response.alreadyResolvedCount || 0;
                        var failedCount = response.failedCount || 0;
                        
                        if (syncedCount > 0) {
                            console.log('✓ Đã đồng bộ ' + syncedCount + ' ticket(s) từ completed work orders');
                            // Reload tickets to show updated status
                            setTimeout(function() {
                                loadTickets(false);
                            }, 1000);
                        } else {
                            console.log('Không có ticket nào cần đồng bộ (đã resolved: ' + alreadyResolved + ', không tìm thấy: ' + failedCount + ')');
                        }
                    } else {
                        console.warn('Lỗi khi đồng bộ ticket status: ' + (response.message || 'Unknown error'));
                    }
                },
                error: function(xhr, status, error) {
                    console.warn('Không thể đồng bộ ticket status: ' + error);
                    // Don't show error to user, just log it
                }
            });
        }
    </script>
</body>
</html>
