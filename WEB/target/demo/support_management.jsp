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
    <title>Quản Lý Yêu Cầu Hỗ Trợ | HL Generator</title>
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
        .badge-high { background-color: #f0ad4e !important; }
        .badge-medium { background-color: #5bc0de !important; }
        .badge-low { background-color: #5cb85c !important; }
        
        .badge-open { background-color: #f0ad4e !important; }
        .badge-in_progress { background-color: #5bc0de !important; }
        .badge-resolved { background-color: #5cb85c !important; }
        .badge-closed { background-color: #777 !important; }
        
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
    </style>
</head>
<body class="skin-black">
    <!-- header logo -->
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
                        <a href="customersupport.jsp">
                            <i class="fa fa-dashboard"></i> <span>Bảng điều khiển khách hàng</span>
                        </a>
                    </li>
                    <li>
                        <a href="contracts.jsp">
                            <i class="fa fa-file-text"></i> <span>Quản lý hợp đồng</span>
                        </a>
                    </li>
                    <li class="active">
                        <a href="support_management.jsp">
                            <i class="fa fa-life-ring"></i> <span>Quản lý yêu cầu hỗ trợ</span>
                        </a>
                    </li>
                </ul>
            </section>
        </aside>

        <aside class="right-side">
            <section class="content-header">
                <h1>
                    Quản Lý Yêu Cầu Hỗ Trợ
                    <small>Danh sách tất cả yêu cầu</small>
                </h1>
                <ol class="breadcrumb">
                    <li><a href="customersupport.jsp"><i class="fa fa-dashboard"></i> Trang chủ</a></li>
                    <li class="active">Quản lý yêu cầu hỗ trợ</li>
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
                                        <label>Trạng thái: </label>
                                        <select class="form-control input-sm" id="filterStatus" style="width: 150px;">
                                            <option value="">Tất cả</option>
                                            <option value="open">Chờ xử lý</option>
                                            <option value="in_progress">Đang xử lý</option>
                                            <option value="resolved">Đã giải quyết</option>
                                            <option value="closed">Đã đóng</option>
                                        </select>
                                    </div>
                                    
                                    <div class="form-group" style="margin-left: 10px;">
                                        <label>Danh mục: </label>
                                        <select class="form-control input-sm" id="filterCategory" style="width: 150px;">
                                            <option value="">Tất cả</option>
                                            <option value="technical">Kỹ thuật</option>
                                            <option value="billing">Thanh toán</option>
                                            <option value="general">Chung</option>
                                            <option value="complaint">Khiếu nại</option>
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
                                        <label>Tìm kiếm: </label>
                                        <input type="text" class="form-control input-sm" id="filterSearch" placeholder="Mã ticket, khách hàng..." style="width: 200px;">
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

                <!-- Tickets Table -->
                <div class="row">
                    <div class="col-xs-12">
                        <div class="box">
                            <div class="box-header">
                                <h3 class="box-title">Danh sách yêu cầu hỗ trợ</h3>
                                <div class="box-tools">
                                    <button type="button" class="btn btn-success btn-sm" onclick="location.reload()">
                                        <i class="fa fa-refresh"></i> Tải lại
                                    </button>
                                </div>
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
                Copyright &copy Hệ thống hỗ trợ khách hàng - HL Generator, 2025
            </div>
        </aside>
    </div>

    <!-- Modal Chi tiết Ticket -->
    <div class="modal fade" id="ticketDetailModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Chi tiết yêu cầu hỗ trợ</h4>
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
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Mô tả vấn đề:</label>
                            <div class="col-sm-9">
                                <textarea class="form-control" id="detail_description" rows="4" readonly></textarea>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Danh mục:</label>
                            <div class="col-sm-3">
                                <select class="form-control" id="detail_category">
                                    <option value="technical">Kỹ thuật</option>
                                    <option value="billing">Thanh toán</option>
                                    <option value="general">Chung</option>
                                    <option value="complaint">Khiếu nại</option>
                                </select>
                            </div>
                            
                            <label class="col-sm-3 control-label">Độ ưu tiên:</label>
                            <div class="col-sm-3">
                                <select class="form-control" id="detail_priority">
                                    <option value="urgent">Khẩn cấp</option>
                                    <option value="high">Cao</option>
                                    <option value="medium">Trung bình</option>
                                    <option value="low">Thấp</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Trạng thái:</label>
                            <div class="col-sm-3">
                                <select class="form-control" id="detail_status">
                                    <option value="open">Chờ xử lý</option>
                                    <option value="in_progress">Đang xử lý</option>
                                    <option value="resolved">Đã giải quyết</option>
                                    <option value="closed">Đã đóng</option>
                                </select>
                            </div>
                            
                            <label class="col-sm-3 control-label">Ngày tạo:</label>
                            <div class="col-sm-3">
                                <p class="form-control-static" id="detail_created"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Giải pháp:</label>
                            <div class="col-sm-9">
                                <textarea class="form-control" id="detail_resolution" rows="3" placeholder="Nhập giải pháp xử lý..."></textarea>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Ghi chú nội bộ:</label>
                            <div class="col-sm-9">
                                <textarea class="form-control" id="detail_notes" rows="2" placeholder="Ghi chú cho nhân viên..."></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" id="btnSaveTicket">
                        <i class="fa fa-save"></i> Lưu thay đổi
                    </button>
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Chuyển tiếp Ticket -->
    <div class="modal fade" id="forwardTicketModal" tabindex="-1" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Chuyển tiếp yêu cầu hỗ trợ</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" id="forwardTicketForm">
                        <input type="hidden" id="forward_ticket_id">
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Mã Ticket:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="forward_ticket_number"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Tiêu đề:</label>
                            <div class="col-sm-9">
                                <p class="form-control-static" id="forward_subject"></p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-sm-3 control-label">Chuyển đến:</label>
                            <div class="col-sm-9">
                                <select class="form-control" id="forward_to_user" required>
                                    <option value="">-- Chọn --</option>
                                    <option value="head_technician">Trưởng phòng kỹ thuật</option>
                                </select>
                            </div>
                        </div>
                        
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-warning" id="btnConfirmForward">
                        <i class="fa fa-forward"></i> Chuyển tiếp
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
        
        $(document).ready(function() {
            loadTickets();
            
            // Filter button
            $('#btnFilter').click(function() {
                applyFilters();
            });
            
            // Reset button
            $('#btnReset').click(function() {
                $('#filterForm')[0].reset();
                filteredTickets = allTickets;
                renderTable();
            });
            
            // Save ticket changes
            $('#btnSaveTicket').click(function() {
                saveTicketChanges();
            });
            
            // Confirm forward ticket
            $('#btnConfirmForward').click(function() {
                confirmForwardTicket();
            });
            
            // Enter to search
            $('#filterSearch').keypress(function(e) {
                if(e.which == 13) {
                    $('#btnFilter').click();
                }
            });
        });
        
        function loadTickets() {
            // Dữ liệu mẫu thay vì gọi API
            allTickets = [
                {
                    id: 1,
                    ticketNumber: 'SR-1760274731922',
                    customerName: 'HieuND1',
                    customerEmail: 'hieu@example.com',
                    subject: 'lỗi thanh toán',
                    description: 'Khách hàng báo lỗi khi thanh toán online',
                    category: 'billing',
                    priority: 'urgent',
                    status: 'in_progress',
                    createdAt: '2025-10-13T03:12:11',
                    resolution: '',
                    assignedTo: 'head_technician'
                },
                {
                    id: 2,
                    ticketNumber: 'SR-1760274193047',
                    customerName: 'HieuND1',
                    customerEmail: 'hieu@example.com',
                    subject: 'hỏng hóc',
                    description: 'Sản phẩm bị hỏng sau 1 tuần sử dụng',
                    category: 'technical',
                    priority: 'high',
                    status: 'open',
                    createdAt: '2025-10-13T03:03:13',
                    resolution: '',
                    assignedTo: null
                },
                {
                    id: 3,
                    ticketNumber: 'SR-1760273535077',
                    customerName: 'HieuND1',
                    customerEmail: 'hieu@example.com',
                    subject: 'sửa chữa',
                    description: 'Cần sửa chữa thiết bị tại nhà khách hàng',
                    category: 'technical',
                    priority: 'medium',
                    status: 'open',
                    createdAt: '2025-10-13T02:52:15',
                    resolution: '',
                    assignedTo: null
                }
            ];
            
            filteredTickets = allTickets;
            renderTable();
        }
        
        function applyFilters() {
            var status = $('#filterStatus').val();
            var category = $('#filterCategory').val();
            var priority = $('#filterPriority').val();
            var search = $('#filterSearch').val().toLowerCase();
            
            filteredTickets = allTickets.filter(function(ticket) {
                var matchStatus = !status || ticket.status === status;
                var matchCategory = !category || ticket.category === category;
                var matchPriority = !priority || ticket.priority === priority;
                var matchSearch = !search || 
                    (ticket.ticketNumber && ticket.ticketNumber.toLowerCase().includes(search)) ||
                    (ticket.subject && ticket.subject.toLowerCase().includes(search)) ||
                    (ticket.description && ticket.description.toLowerCase().includes(search));
                
                return matchStatus && matchCategory && matchPriority && matchSearch;
            });
            
            renderTable();
        }
        
        function renderTable() {
            var tbody = $('#ticketsTableBody');
            tbody.empty();
            
            if(!filteredTickets || filteredTickets.length === 0) {
                tbody.append('<tr><td colspan="8" class="text-center">Không có dữ liệu</td></tr>');
                return;
            }
            
            filteredTickets.forEach(function(ticket) {
                var row = '<tr>' +
                    '<td>' + (ticket.ticketNumber || '#' + ticket.id) + '</td>' +
                    '<td>' + (ticket.customerName || 'N/A') + '</td>' +
                    '<td>' + (ticket.subject || '') + '</td>' +
                    '<td>' + getCategoryBadge(ticket.category) + '</td>' +
                    '<td>' + getPriorityBadge(ticket.priority) + '</td>' +
                    '<td>' + getStatusBadge(ticket.status) + '</td>' +
                    '<td>' + formatDate(ticket.createdAt) + '</td>' +
                    '<td class="ticket-actions">' +
                        '<button class="btn btn-info btn-view" data-id="' + ticket.id + '"><i class="fa fa-eye"></i> Xem</button>' +
                        '<button class="btn btn-warning btn-forward" data-id="' + ticket.id + '"><i class="fa fa-forward"></i> Chuyển tiếp</button>' +
                    '</td>' +
                '</tr>';
                tbody.append(row);
            });
            
            // Bind view button
            $('.btn-view').click(function() {
                var id = $(this).data('id');
                viewTicketDetail(id);
            });
            
            // Bind forward button
            $('.btn-forward').click(function() {
                var id = $(this).data('id');
                showForwardModal(id);
            });
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
                'closed': 'Đã đóng'
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
        
        function viewTicketDetail(id) {
            var ticket = allTickets.find(function(t) { return t.id == id; });
            if(!ticket) return;
            
            $('#detail_ticket_id').val(ticket.id);
            $('#detail_ticket_number').text(ticket.ticketNumber || '#' + ticket.id);
            $('#detail_customer').text(ticket.customerName || 'N/A');
            $('#detail_email').text(ticket.customerEmail || 'N/A');
            $('#detail_subject').text(ticket.subject || '');
            $('#detail_description').val(ticket.description || '');
            $('#detail_category').val(ticket.category || 'general');
            $('#detail_priority').val(ticket.priority || 'medium');
            $('#detail_status').val(ticket.status || 'open');
            $('#detail_created').text(formatDate(ticket.createdAt));
            $('#detail_resolution').val(ticket.resolution || '');
            $('#detail_notes').val('');
            
            $('#ticketDetailModal').modal('show');
        }
        
        function saveTicketChanges() {
            var id = $('#detail_ticket_id').val();
            var data = {
                action: 'update',
                id: id,
                category: $('#detail_category').val(),
                priority: $('#detail_priority').val(),
                status: $('#detail_status').val(),
                resolution: $('#detail_resolution').val()
            };
            
            $.ajax({
                url: ctx + '/api/support-requests',
                type: 'POST',
                data: data,
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        alert('Cập nhật thành công!');
                        $('#ticketDetailModal').modal('hide');
                        loadTickets();
                    } else {
                        alert('Lỗi: ' + (response.message || 'Không thể cập nhật'));
                    }
                },
                error: function() {
                    alert('Lỗi kết nối máy chủ');
                }
            });
        }
        
        function showForwardModal(id) {
            var ticket = allTickets.find(function(t) { return t.id == id; });
            if(!ticket) return;
            
            $('#forward_ticket_id').val(ticket.id);
            $('#forward_ticket_number').text(ticket.ticketNumber || '#' + ticket.id);
            $('#forward_subject').text(ticket.subject || '');
            $('#forward_to_user').val('');
            
            $('#forwardTicketModal').modal('show');
        }
        
        function confirmForwardTicket() {
            var id = $('#forward_ticket_id').val();
            var forwardTo = $('#forward_to_user').val();
            
            if(!forwardTo) {
                alert('Vui lòng chọn người nhận!');
                return;
            }
            
            // Cập nhật trạng thái ticket cụ thể trong dữ liệu mẫu
            var ticket = allTickets.find(function(t) { return t.id == id; });
            if(ticket) {
                ticket.status = 'in_progress';
                ticket.assignedTo = 'head_technician';
                alert('Đã chuyển tiếp ticket #' + ticket.ticketNumber + ' cho ' + forwardTo + ' xử lý!');
                
                // Lưu thông tin ticket được chuyển tiếp vào localStorage
                localStorage.setItem('forwardedTicket', JSON.stringify(ticket));
            } else {
                alert('Không tìm thấy ticket #' + id);
            }
            
            $('#forwardTicketModal').modal('hide');
            // Tải lại danh sách ticket để cập nhật trạng thái
            loadTickets();
        }
        
        function showError(msg) {
            $('#ticketsTableBody').html('<tr><td colspan="8" class="text-center text-danger">' + msg + '</td></tr>');
        }
    </script>
</body>
</html>

