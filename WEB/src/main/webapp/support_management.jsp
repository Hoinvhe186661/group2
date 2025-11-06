<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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
    <title>Quản Lý Yêu Cầu Hỗ Trợ | Bảng Điều Khiển</title>
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
         .ticket-priority-urgent { border-left: 4px solid #d9534f; }
         .ticket-priority-high { border-left: 4px solid #f0ad4e; }
         .ticket-priority-medium { border-left: 4px solid #5bc0de; }
         .ticket-priority-low { border-left: 4px solid #5cb85c; }
         
         /* Tối ưu cho tiếng Việt */
         #detailDescription {
             font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
             line-height: 1.5;
             direction: ltr;
             unicode-bidi: embed;
         }
         
         /* Placeholder styling cho tiếng Việt */
         #detailDescription::placeholder {
             color: #999;
             font-style: italic;
         }
         
         /* Styling cho các trường bị khóa */
         input[readonly], textarea[readonly], select[disabled] {
             background-color: #f5f5f5;
             color: #666;
             cursor: not-allowed;
         }
         
         /* Styling cho các trường được phép chỉnh sửa */
         input:not([readonly]), textarea:not([readonly]), select:not([disabled]) {
             background-color: #fff;
             border-color: #5bc0de;
         }
         
         /* Label styling để phân biệt */
         .form-group label {
             font-weight: bold;
         }
         
         .form-group label:after {
             content: " *";
             color: #5bc0de;
             font-weight: normal;
         }
         
         /* Loại bỏ dấu * cho các trường readonly */
         input[readonly] + label:after,
         textarea[readonly] + label:after,
         select[disabled] + label:after {
             display: none;
         }
         
         /* Ẩn phần "records per page" của DataTables */
         .dataTables_length {
             display: none !important;
         }
         
    </style>
</head>
<body class="skin-black">
    <!-- header logo: style can be found in header.less -->
    <header class="header">
        <a href="support-management" class="logo">
            Quản Lý Yêu Cầu Hỗ Trợ
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
                            <span>${sessionScope.username} <i class="caret"></i></span>
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
                    <li class="active">
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
                </ul>
            </section>
            <!-- /.sidebar -->
        </aside>

        <aside class="right-side">
            <!-- Main content -->
            <section class="content">
                <!-- Filter Section -->
                <div class="filter-section">
                    <form method="GET" action="support-management">
                <div class="row">
                        <div class="col-md-3">
                            <label>Trạng thái:</label>
                                <select name="status" class="form-control">
                                            <option value="">Tất cả</option>
                                    <option value="open" ${param.status == 'open' ? 'selected' : ''}>Đang chờ</option>
                                    <option value="in_progress" ${param.status == 'in_progress' ? 'selected' : ''}>Đang xử lý</option>
                                    <option value="resolved" ${param.status == 'resolved' ? 'selected' : ''}>Hoàn thành</option>
                                    <option value="closed" ${param.status == 'closed' ? 'selected' : ''}>Đã đóng</option>
                                        </select>
                                    </div>
                        <div class="col-md-3">
                            <label>Độ ưu tiên:</label>
                                <select name="priority" class="form-control">
                                            <option value="">Tất cả</option>
                                    <option value="urgent" ${param.priority == 'urgent' ? 'selected' : ''}>Khẩn cấp</option>
                                    <option value="high" ${param.priority == 'high' ? 'selected' : ''}>Cao</option>
                                    <option value="medium" ${param.priority == 'medium' ? 'selected' : ''}>Trung bình</option>
                                    <option value="low" ${param.priority == 'low' ? 'selected' : ''}>Thấp</option>
                                        </select>
                                    </div>
                        <div class="col-md-3">
                            <label>Danh mục:</label>
                                <select name="category" class="form-control">
                                <option value="">Tất cả</option>
                                    <option value="technical" ${param.category == 'technical' ? 'selected' : ''}>Kỹ thuật</option>
                                    <option value="billing" ${param.category == 'billing' ? 'selected' : ''}>Thanh toán</option>
                                    <option value="general" ${param.category == 'general' ? 'selected' : ''}>Chung</option>
                                    <option value="complaint" ${param.category == 'complaint' ? 'selected' : ''}>Khiếu nại</option>
                            </select>
                                    </div>
                        <div class="col-md-3">
                            <label>&nbsp;</label><br>
                                <button type="submit" class="btn btn-primary">
                                        <i class="fa fa-filter"></i> Lọc
                                    </button>
                                <a href="support-management" class="btn btn-default">
                                 <i class="fa fa-refresh"></i> Xóa bộ lọc
                                </a>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Tickets Table -->
                <div class="row">
                    <div class="col-md-12">
                        <section class="panel">
                            <header class="panel-heading">
                                <h3>Danh sách yêu cầu hỗ trợ</h3>
                            </header>
                            <div class="panel-body">
                                <div class="table-responsive">
                                    <table id="ticketsTable" class="table table-striped table-bordered table-hover">
                                    <thead>
                                        <tr>
                                                <th>ID</th>
                                                <th>Mã Ticket</th>
                                            <th>Khách hàng</th>
                                            <th>Tiêu đề</th>
                                                <th>Danh mục</th>
                                                <th>Độ ưu tiên</th>
                                                <th>Trạng thái</th>
                                                <th>Ngày tạo</th>
                                                <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty tickets}">
                                                <c:forEach var="ticket" items="${tickets}">
                                                <tr class="ticket-priority-${ticket.priority}">
                                                    <td>${ticket.id}</td>
                                                    <td><strong>#${ticket.ticketNumber}</strong></td>
                                                    <td>${not empty ticket.customerName ? ticket.customerName : 'N/A'}</td>
                                                    <td>${ticket.subject}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${ticket.category == 'technical'}">
                                                                <span class='label label-info'>Kỹ thuật</span>
                                                            </c:when>
                                                            <c:when test="${ticket.category == 'billing'}">
                                                                <span class='label label-success'>Thanh toán</span>
                                                            </c:when>
                                                            <c:when test="${ticket.category == 'general'}">
                                                                <span class='label label-default'>Chung</span>
                                                            </c:when>
                                                            <c:when test="${ticket.category == 'complaint'}">
                                                                <span class='label label-danger'>Khiếu nại</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class='label label-default'>${ticket.category}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${ticket.priority == 'low'}">
                                                                <span class='label label-info'>Thấp</span>
                                                            </c:when>
                                                            <c:when test="${ticket.priority == 'medium'}">
                                                                <span class='label label-warning'>Trung bình</span>
                                                            </c:when>
                                                            <c:when test="${ticket.priority == 'high'}">
                                                                <span class='label label-danger'>Cao</span>
                                                            </c:when>
                                                            <c:when test="${ticket.priority == 'urgent'}">
                                                                <span class='label label-danger'>Khẩn cấp</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class='label label-default'>${ticket.priority}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${ticket.status == 'open'}">
                                                                <span class='label label-primary'>Đang chờ</span>
                                                            </c:when>
                                                            <c:when test="${ticket.status == 'in_progress'}">
                                                                <span class='label label-warning'>Đang xử lý</span>
                                                            </c:when>
                                                            <c:when test="${ticket.status == 'resolved'}">
                                                                <span class='label label-success'>Hoàn thành</span>
                                                            </c:when>
                                                            <c:when test="${ticket.status == 'closed'}">
                                                                <span class='label label-default'>Đã đóng</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class='label label-default'>${ticket.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                    </td>
                                                    <td>
                                                        <button class="btn btn-info btn-xs view-ticket-btn" data-ticket-id="${ticket.id}" title="Xem chi tiết">
                                                            <i class="fa fa-eye"></i> Xem
                                                        </button>
                                                        <button class="btn btn-warning btn-xs edit-ticket-btn" data-ticket-id="${ticket.id}" title="Chỉnh sửa">
                                                            <i class="fa fa-edit"></i> Sửa
                                                        </button>
                                                        <button class="btn btn-success btn-xs forward-ticket-btn" data-ticket-id="${ticket.id}" title="Chuyển tiếp cho trưởng phòng kỹ thuật">
                                                            <i class="fa fa-share"></i> Chuyển tiếp
                                                        </button>
                                                    </td>
                                                </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="9" class="text-center">
                                                        <i class="fa fa-info-circle"></i> 
                                                        <c:choose>
                                                            <c:when test="${not empty param.status or not empty param.priority or not empty param.category}">
                                                                Không tìm thấy yêu cầu hỗ trợ phù hợp với bộ lọc
                                                            </c:when>
                                                            <c:otherwise>
                                                                Chưa có yêu cầu hỗ trợ nào
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                    </div>
                </div>
            </section>
                            </div>
                        </div>
            </section><!-- /.content -->
        </aside><!-- /.right-side -->
    </div><!-- ./wrapper -->

    <!-- Modal Xem Chi Tiết Ticket -->
    <div class="modal fade" id="viewTicketModal" tabindex="-1" role="dialog" aria-labelledby="viewTicketModalLabel">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header" style="background-color: #3c8dbc; color: white;">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="color: white; opacity: 0.8;">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="viewTicketModalLabel">
                        <i class="fa fa-ticket"></i> Chi Tiết Yêu Cầu Hỗ Trợ
                    </h4>
                </div>
                <div class="modal-body" id="ticketDetailContent">
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

    <!-- Modal Sửa Ticket -->
    <div class="modal fade" id="editTicketModal" tabindex="-1" role="dialog" aria-labelledby="editTicketModalLabel">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header" style="background-color: #f39c12; color: white;">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="color: white; opacity: 0.8;">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="editTicketModalLabel">
                        <i class="fa fa-edit"></i> Cập Nhật Yêu Cầu Hỗ Trợ
                    </h4>
                </div>
                <form id="editTicketForm">
                    <div class="modal-body" id="editTicketContent">
                        <div class="text-center">
                            <i class="fa fa-spinner fa-spin fa-3x"></i>
                            <p>Đang tải dữ liệu...</p>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">
                            <i class="fa fa-times"></i> Hủy
                        </button>
                        <button type="submit" class="btn btn-warning" id="btnSaveTicket">
                            <i class="fa fa-save"></i> Lưu thay đổi
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal Chuyển tiếp Ticket -->
    <div class="modal fade" id="forwardTicketModal" tabindex="-1" role="dialog" aria-labelledby="forwardTicketModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header" style="background-color: #5cb85c; color: white;">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="color: white; opacity: 0.8;">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="forwardTicketModalLabel">
                        <i class="fa fa-share"></i> Chuyển tiếp Ticket cho Trưởng phòng Kỹ thuật
                    </h4>
                </div>
                <form id="forwardTicketForm">
                    <div class="modal-body">
                        <div class="form-group">
                            <label>Mã Ticket:</label>
                            <input type="text" class="form-control" id="forward_ticketNumber" readonly>
                            <input type="hidden" id="forward_ticketId">
                        </div>
                        <div class="form-group">
                            <label>Tiêu đề:</label>
                            <input type="text" class="form-control" id="forward_subject" readonly>
                        </div>
                        <div class="form-group">
                            <label>Trưởng phòng Kỹ thuật nhận: <span class="text-danger">*</span></label>
                            <select class="form-control" id="forward_assignedTo" required>
                                <option value="">-- Chọn trưởng phòng kỹ thuật --</option>
                            </select>
                            <small class="text-muted">Mỗi ticket sẽ được gửi riêng biệt cho từng trưởng phòng kỹ thuật</small>
                        </div>
                        <div class="form-group">
                            <label>Độ ưu tiên: <span class="text-danger">*</span></label>
                            <select class="form-control" id="forward_priority" required>
                                <option value="urgent">Khẩn cấp</option>
                                <option value="high">Cao</option>
                                <option value="medium" selected>Trung bình</option>
                                <option value="low">Thấp</option>
                            </select>
                            <small class="text-muted">Bạn có thể thay đổi độ ưu tiên khi chuyển tiếp</small>
                        </div>
                        <div class="alert alert-info">
                            <i class="fa fa-info-circle"></i> 
                            <strong>Lưu ý:</strong> Sau khi chuyển tiếp thành công, trạng thái ticket sẽ tự động chuyển sang <strong>"Đang xử lý"</strong>.
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">
                            <i class="fa fa-times"></i> Hủy
                        </button>
                        <button type="submit" class="btn btn-success" id="btnForwardTicket">
                            <i class="fa fa-share"></i> Chuyển tiếp
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>


    <!-- jQuery 2.0.2 -->
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
    <script src="js/jquery.min.js" type="text/javascript"></script>
    <!-- jQuery UI 1.10.3 -->
    <script src="js/jquery-ui-1.10.3.min.js" type="text/javascript"></script>
    <!-- Bootstrap -->
    <script src="js/bootstrap.min.js" type="text/javascript"></script>
    <!-- DataTables -->
    <script src="js/plugins/datatables/jquery.dataTables.js" type="text/javascript"></script>
    <script src="js/plugins/datatables/dataTables.bootstrap.js" type="text/javascript"></script>
    <!-- Director App -->
    <script src="js/Director/app.js" type="text/javascript"></script>

    <script>
        // Lấy context path để dùng trong AJAX calls
        var ctx = '<%=request.getContextPath()%>';
        // Đảm bảo context path không có dấu slash thừa
        if (ctx && ctx.endsWith('/')) {
            ctx = ctx.substring(0, ctx.length - 1);
        }
        
        $(document).ready(function() {
            // Khởi tạo DataTable với dữ liệu đã có sẵn trong HTML
            $('#ticketsTable').DataTable({
                    "language": {
                        "url": "//cdn.datatables.net/plug-ins/1.10.24/i18n/Vietnamese.json"
                },
                "pageLength": 10,
                "lengthChange": false, // Ẩn dropdown "records per page"
                "order": [[7, "desc"]], // Sort by Ngày tạo (column 7) giảm dần
                "columnDefs": [
                    { 
                        "targets": 0, // Cột ID (cột đầu tiên)
                        "render": function (data, type, row, meta) {
                            // Hiển thị số thứ tự bắt đầu từ 1, tính cả pagination
                            return meta.settings._iDisplayStart + meta.row + 1;
                        }
                    },
                    { "orderable": false, "targets": 8 } // Không sort cột Thao tác
                ]
            });

            // Xử lý click nút Xem
            $(document).on('click', '.view-ticket-btn', function() {
                var ticketId = $(this).data('ticket-id');
                loadTicketDetail(ticketId);
            });

            // Xử lý click nút Sửa
            $(document).on('click', '.edit-ticket-btn', function() {
                var ticketId = $(this).data('ticket-id');
                loadTicketForEdit(ticketId);
            });

            // Xử lý click nút Chuyển tiếp
            $(document).on('click', '.forward-ticket-btn', function() {
                var ticketId = $(this).data('ticket-id');
                loadTicketForForward(ticketId);
            });

            // Xử lý submit form sửa
            $('#editTicketForm').on('submit', function(e) {
                e.preventDefault();
                saveTicketChanges();
            });

            // Xử lý submit form chuyển tiếp
            $('#forwardTicketForm').on('submit', function(e) {
                e.preventDefault();
                forwardTicket();
            });
        });

        function loadTicketDetail(ticketId) {
            // Hiển thị modal
            $('#viewTicketModal').modal('show');
            
            // Reset nội dung
            $('#ticketDetailContent').html('<div class="text-center"><i class="fa fa-spinner fa-spin fa-3x"></i><p>Đang tải dữ liệu...</p></div>');
            
            // Gọi AJAX
            $.ajax({
                url: 'support-detail',
                type: 'GET',
                data: { id: ticketId },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        displayTicketDetail(response.data);
                    } else {
                        $('#ticketDetailContent').html('<div class="alert alert-danger"><i class="fa fa-exclamation-triangle"></i> ' + response.message + '</div>');
                    }
                },
                error: function() {
                    $('#ticketDetailContent').html('<div class="alert alert-danger"><i class="fa fa-exclamation-triangle"></i> Không thể tải dữ liệu. Vui lòng thử lại!</div>');
                }
            });
        }

        function displayTicketDetail(ticket) {
            // Định dạng category
            var categoryBadge = '';
            switch(ticket.category) {
                case 'technical': categoryBadge = '<span class="label label-info">Kỹ thuật</span>'; break;
                case 'billing': categoryBadge = '<span class="label label-success">Thanh toán</span>'; break;
                case 'general': categoryBadge = '<span class="label label-default">Chung</span>'; break;
                case 'complaint': categoryBadge = '<span class="label label-danger">Khiếu nại</span>'; break;
                default: categoryBadge = '<span class="label label-default">' + ticket.category + '</span>';
            }

            // Định dạng priority
            var priorityBadge = '';
            switch(ticket.priority) {
                case 'low': priorityBadge = '<span class="label label-info">Thấp</span>'; break;
                case 'medium': priorityBadge = '<span class="label label-warning">Trung bình</span>'; break;
                case 'high': priorityBadge = '<span class="label label-danger">Cao</span>'; break;
                case 'urgent': priorityBadge = '<span class="label label-danger">Khẩn cấp</span>'; break;
                default: priorityBadge = '<span class="label label-default">' + ticket.priority + '</span>';
            }

            // Định dạng status
            var statusBadge = '';
            switch(ticket.status) {
                case 'open': statusBadge = '<span class="label label-primary">Đang chờ</span>'; break;
                case 'in_progress': statusBadge = '<span class="label label-warning">Đang xử lý</span>'; break;
                case 'resolved': statusBadge = '<span class="label label-success">Hoàn thành</span>'; break;
                case 'closed': statusBadge = '<span class="label label-default">Đã đóng</span>'; break;
                default: statusBadge = '<span class="label label-default">' + ticket.status + '</span>';
            }

            var html = '<div class="ticket-detail-view">';
            
            // Header
            html += '<div style="background: #f9f9f9; padding: 15px; margin-bottom: 20px; border-radius: 5px; border-left: 5px solid #3c8dbc;">';
            html += '<h4 style="margin-top: 0;"><strong>#' + escapeHtml(ticket.ticketNumber) + '</strong></h4>';
            html += '<h5>' + escapeHtml(ticket.subject) + '</h5>';
            html += '<div style="margin-top: 10px;">';
            html += 'Trạng thái: ' + statusBadge + ' &nbsp; ';
            html += 'Độ ưu tiên: ' + priorityBadge + ' &nbsp; ';
            html += 'Danh mục: ' + categoryBadge;
            html += '</div></div>';

            // Row 2 cột
            html += '<div class="row">';
            
            // Cột trái - Chi tiết
            html += '<div class="col-md-8">';
            
            // Mô tả
            html += '<div style="margin-bottom: 20px;">';
            html += '<h5><i class="fa fa-info-circle"></i> <strong>Mô tả chi tiết</strong></h5>';
            html += '<div style="background: #f9f9f9; padding: 10px; border-radius: 3px; white-space: pre-wrap; word-wrap: break-word;">';
            html += escapeHtml(ticket.description);
            html += '</div></div>';

            // Giải pháp
            if (ticket.resolution) {
                html += '<div style="margin-bottom: 20px;">';
                html += '<h5><i class="fa fa-check-circle"></i> <strong>Giải pháp / Kết quả xử lý</strong></h5>';
                html += '<div style="background: #d4edda; padding: 10px; border-radius: 3px; white-space: pre-wrap; word-wrap: break-word;">';
                html += escapeHtml(ticket.resolution);
                html += '</div></div>';
            }

            // Lịch sử
            if (ticket.history) {
                html += '<div style="margin-bottom: 20px;">';
                html += '<h5><i class="fa fa-history"></i> <strong>Lịch sử xử lý</strong></h5>';
                html += '<div style="background: #fff3cd; padding: 10px; border-radius: 3px; white-space: pre-wrap; word-wrap: break-word;">';
                html += escapeHtml(ticket.history);
                html += '</div></div>';
            }

            html += '</div>';

            // Cột phải - Thông tin
            html += '<div class="col-md-4">';
            
            // Thông tin khách hàng
            html += '<div style="background: #f9f9f9; padding: 15px; margin-bottom: 15px; border-radius: 5px;">';
            html += '<h5 style="margin-top: 0;"><i class="fa fa-user"></i> <strong>Thông tin khách hàng</strong></h5>';
            html += '<p><strong>Công ty:</strong><br>' + escapeHtml(ticket.customerName) + '</p>';
            html += '<p><strong>Người liên hệ:</strong><br>' + escapeHtml(ticket.customerContact) + '</p>';
            if (ticket.customerEmail) {
                html += '<p><strong>Email:</strong><br><a href="mailto:' + escapeHtml(ticket.customerEmail) + '">' + escapeHtml(ticket.customerEmail) + '</a></p>';
            }
            if (ticket.customerPhone) {
                html += '<p><strong>Số điện thoại:</strong><br><a href="tel:' + escapeHtml(ticket.customerPhone) + '">' + escapeHtml(ticket.customerPhone) + '</a></p>';
            }
            if (ticket.customerAddress) {
                html += '<p><strong>Địa chỉ:</strong><br>' + escapeHtml(ticket.customerAddress) + '</p>';
            }
            html += '</div>';

            // Thông tin ticket
            html += '<div style="background: #f9f9f9; padding: 15px; border-radius: 5px;">';
            html += '<h5 style="margin-top: 0;"><i class="fa fa-info"></i> <strong>Thông tin ticket</strong></h5>';
            if (ticket.createdAt) {
                html += '<p><strong>Ngày tạo:</strong><br>' + ticket.createdAt + '</p>';
            }
            if (ticket.resolvedAt) {
                html += '<p><strong>Ngày giải quyết:</strong><br>' + ticket.resolvedAt + '</p>';
            }
            if (ticket.assignedToName) {
                html += '<p><strong>Người xử lý:</strong><br>' + escapeHtml(ticket.assignedToName);
                if (ticket.assignedToEmail) {
                    html += '<br><small><a href="mailto:' + escapeHtml(ticket.assignedToEmail) + '">' + escapeHtml(ticket.assignedToEmail) + '</a></small>';
                }
                html += '</p>';
            }
            html += '</div>';

            html += '</div>';
            html += '</div>';
            html += '</div>';

            $('#ticketDetailContent').html(html);
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

        // Load ticket để edit
        var currentEditTicketId = null;
        
        function loadTicketForEdit(ticketId) {
            currentEditTicketId = ticketId;
            
            // Hiển thị modal
            $('#editTicketModal').modal('show');
            
            // Reset nội dung
            $('#editTicketContent').html('<div class="text-center"><i class="fa fa-spinner fa-spin fa-3x"></i><p>Đang tải dữ liệu...</p></div>');
            
            // Gọi AJAX
            $.ajax({
                url: 'support-detail',
                type: 'GET',
                data: { id: ticketId },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        displayEditForm(response.data);
                    } else {
                        $('#editTicketContent').html('<div class="alert alert-danger"><i class="fa fa-exclamation-triangle"></i> ' + response.message + '</div>');
                    }
                },
                error: function() {
                    $('#editTicketContent').html('<div class="alert alert-danger"><i class="fa fa-exclamation-triangle"></i> Không thể tải dữ liệu. Vui lòng thử lại!</div>');
                }
            });
        }

        function displayEditForm(ticket) {
            var html = '<div class="row">';
            
            html += '<div class="col-md-6">';
            html += '<div class="form-group">';
            html += '<label>Mã Ticket:</label>';
            html += '<input type="text" class="form-control" value="' + escapeHtml(ticket.ticketNumber) + '" readonly>';
            html += '</div></div>';
            
            html += '<div class="col-md-6">';
            html += '<div class="form-group">';
            html += '<label>Khách hàng:</label>';
            html += '<input type="text" class="form-control" value="' + escapeHtml(ticket.customerName) + '" readonly>';
            html += '</div></div>';
            
            html += '</div>'; // end row
            
            html += '<div class="form-group">';
            html += '<label>Tiêu đề:</label>';
            html += '<input type="text" class="form-control" value="' + escapeHtml(ticket.subject) + '" readonly>';
            html += '</div>';
            
            html += '<div class="form-group">';
            html += '<label>Mô tả:</label>';
            html += '<textarea class="form-control" rows="4" readonly>' + escapeHtml(ticket.description) + '</textarea>';
            html += '</div>';
            
            html += '<hr>';
            html += '<h5><i class="fa fa-edit"></i> <strong>Thông tin có thể cập nhật:</strong></h5>';
            
            html += '<div class="row">';
            
            html += '<div class="col-md-4">';
            html += '<div class="form-group">';
            html += '<label>Danh mục:</label>';
            html += '<select class="form-control" id="edit_category" disabled>';
            html += '<option value="technical"' + (ticket.category === 'technical' ? ' selected' : '') + '>Kỹ thuật</option>';
            html += '<option value="billing"' + (ticket.category === 'billing' ? ' selected' : '') + '>Thanh toán</option>';
            html += '<option value="general"' + (ticket.category === 'general' ? ' selected' : '') + '>Chung</option>';
            html += '<option value="complaint"' + (ticket.category === 'complaint' ? ' selected' : '') + '>Khiếu nại</option>';
            html += '</select>';
            html += '<small class="text-muted">Danh mục không thể thay đổi</small>';
            html += '</div></div>';
            
            html += '<div class="col-md-4">';
            html += '<div class="form-group">';
            html += '<label>Độ ưu tiên: <span class="text-danger">*</span></label>';
            html += '<select class="form-control" id="edit_priority" required>';
            html += '<option value="urgent"' + (ticket.priority === 'urgent' ? ' selected' : '') + '>Khẩn cấp</option>';
            html += '<option value="high"' + (ticket.priority === 'high' ? ' selected' : '') + '>Cao</option>';
            html += '<option value="medium"' + (ticket.priority === 'medium' ? ' selected' : '') + '>Trung bình</option>';
            html += '<option value="low"' + (ticket.priority === 'low' ? ' selected' : '') + '>Thấp</option>';
            html += '</select>';
            html += '</div></div>';
            
            html += '<div class="col-md-4">';
            html += '<div class="form-group">';
            html += '<label>Trạng thái: <span class="text-danger">*</span></label>';
            html += '<select class="form-control" id="edit_status" required>';
            html += '<option value="open"' + (ticket.status === 'open' ? ' selected' : '') + '>Đang chờ</option>';
            html += '<option value="in_progress"' + (ticket.status === 'in_progress' ? ' selected' : '') + '>Đang xử lý</option>';
            html += '<option value="resolved"' + (ticket.status === 'resolved' ? ' selected' : '') + '>Hoàn thành</option>';
            html += '<option value="closed"' + (ticket.status === 'closed' ? ' selected' : '') + '>Đã đóng</option>';
            html += '</select>';
            html += '</div></div>';
            
            html += '</div>'; // end row
            
            html += '<div class="form-group">';
            html += '<label>Người nhận (Người xử lý):</label>';
            html += '<select class="form-control" id="edit_assignedTo">';
            html += '<option value="">-- Chưa phân công --</option>';
            html += '</select>';
            html += '<small class="text-muted">Có thể chọn trưởng phòng kỹ thuật hoặc nhân viên khác</small>';
            html += '</div>';
            
            // Load danh sách head technicians vào dropdown
            loadHeadTechniciansForEdit(ticket.assignedTo);
            
            html += '<div class="form-group">';
            html += '<label>Giải pháp / Kết quả xử lý:</label>';
            html += '<textarea class="form-control" rows="5" id="edit_resolution" placeholder="Nhập giải pháp hoặc kết quả xử lý...">' + (ticket.resolution ? escapeHtml(ticket.resolution) : '') + '</textarea>';
            html += '</div>';
            
            $('#editTicketContent').html(html);
        }

        function saveTicketChanges() {
            if (!currentEditTicketId) {
                alert('Lỗi: Không tìm thấy ID ticket');
                return;
            }
            
            // Disable button
            $('#btnSaveTicket').prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Đang lưu...');
            
            // Lấy dữ liệu (không gửi category vì đã bị disable)
            var data = {
                id: currentEditTicketId,
                priority: $('#edit_priority').val(),
                status: $('#edit_status').val(),
                resolution: $('#edit_resolution').val()
            };
            
            // Nếu có assigned_to trong form edit
            if ($('#edit_assignedTo').length && $('#edit_assignedTo').val()) {
                data.assignedTo = $('#edit_assignedTo').val();
            }
            
            // Submit AJAX với UTF-8
            $.ajax({
                url: 'support-update',
                type: 'POST',
                data: $.param(data), // Encode data properly
                contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        alert('✓ ' + response.message);
                        $('#editTicketModal').modal('hide');
                        // Reload trang để cập nhật danh sách
                        location.reload();
                    } else {
                        alert('✗ ' + response.message);
                    }
                },
                error: function() {
                    alert('✗ Không thể lưu. Vui lòng thử lại!');
                },
                complete: function() {
                    // Enable button
                    $('#btnSaveTicket').prop('disabled', false).html('<i class="fa fa-save"></i> Lưu thay đổi');
                }
            });
        }

        // Load ticket để chuyển tiếp
        var currentForwardTicketId = null;
        
        function loadTicketForForward(ticketId) {
            currentForwardTicketId = ticketId;
            
            // Hiển thị modal
            $('#forwardTicketModal').modal('show');
            
            // Reset form
            $('#forward_ticketNumber').val('');
            $('#forward_subject').val('');
            $('#forward_ticketId').val('');
            $('#forward_assignedTo').html('<option value="">-- Chọn trưởng phòng kỹ thuật --</option>');
            $('#forward_priority').val('medium');
            
            // Load danh sách head technicians
            loadHeadTechnicians();
            
            // Load thông tin ticket
            $.ajax({
                url: 'support-detail',
                type: 'GET',
                data: { id: ticketId },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        var ticket = response.data;
                        $('#forward_ticketNumber').val(ticket.ticketNumber);
                        $('#forward_subject').val(ticket.subject);
                        $('#forward_ticketId').val(ticket.id);
                        
                        // Set priority hiện tại nếu có
                        if (ticket.priority) {
                            $('#forward_priority').val(ticket.priority);
                        }
                    } else {
                        alert('✗ Không thể tải thông tin ticket: ' + response.message);
                        $('#forwardTicketModal').modal('hide');
                    }
                },
                error: function() {
                    alert('✗ Không thể tải thông tin ticket. Vui lòng thử lại!');
                    $('#forwardTicketModal').modal('hide');
                }
            });
        }

        function loadHeadTechnicians() {
            // Thử dùng URL tương đối trước (giống các API khác)
            var url1 = 'api/support-stats';
            // Fallback: dùng context path nếu cần
            var url2 = ctx + '/api/support-stats';
            
            function tryLoad(url, isFallback) {
                $.ajax({
                    url: url,
                    type: 'GET',
                    data: { action: 'getTechnicalStaff' },
                    dataType: 'json',
                    success: function(response) {
                        if (response && response.success && response.data) {
                            var select = $('#forward_assignedTo');
                            select.html('<option value="">-- Chọn trưởng phòng kỹ thuật --</option>');
                            
                            response.data.forEach(function(tech) {
                                select.append('<option value="' + tech.id + '">' + escapeHtml(tech.name) + ' (' + escapeHtml(tech.email) + ')</option>');
                            });
                        } else {
                            var errorMsg = (response && response.message) ? response.message : 'Không thể tải danh sách trưởng phòng kỹ thuật';
                            if (!isFallback) {
                                // Thử fallback nếu chưa thử
                                tryLoad(url2, true);
                            } else {
                                alert('✗ ' + errorMsg);
                                console.error('Error loading head technicians:', response);
                            }
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('AJAX Error loading head technicians from ' + url + ':', {
                            status: status,
                            error: error,
                            responseText: xhr.responseText,
                            statusCode: xhr.status
                        });
                        if (!isFallback && url !== url2) {
                            // Thử fallback URL
                            console.log('Trying fallback URL:', url2);
                            tryLoad(url2, true);
                        } else {
                            // Fallback: thử dùng support-management
                            console.log('Trying support-management as last resort');
                            $.ajax({
                                url: 'support-management',
                                type: 'GET',
                                data: { action: 'getHeadTechnicians' },
                                dataType: 'json',
                                success: function(response) {
                                    if (response && response.success && response.data) {
                                        var select = $('#forward_assignedTo');
                                        select.html('<option value="">-- Chọn trưởng phòng kỹ thuật --</option>');
                                        response.data.forEach(function(tech) {
                                            select.append('<option value="' + tech.id + '">' + escapeHtml(tech.name) + ' (' + escapeHtml(tech.email) + ')</option>');
                                        });
                                    } else {
                                        alert('✗ Không thể tải danh sách trưởng phòng kỹ thuật. Vui lòng thử lại!');
                                    }
                                },
                                error: function() {
                                    alert('✗ Không thể tải danh sách trưởng phòng kỹ thuật. Vui lòng thử lại! (Status: ' + xhr.status + ')');
                                }
                            });
                        }
                    }
                });
            }
            
            // Bắt đầu với URL tương đối
            tryLoad(url1, false);
        }

        function forwardTicket() {
            var ticketId = $('#forward_ticketId').val();
            var assignedToId = $('#forward_assignedTo').val();
            var priority = $('#forward_priority').val();
            
            if (!ticketId || !assignedToId) {
                alert('✗ Vui lòng chọn trưởng phòng kỹ thuật');
                return;
            }
            
            // Disable button
            $('#btnForwardTicket').prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Đang chuyển tiếp...');
            
            // Submit AJAX - gọi SupportStatsServlet
            $.ajax({
                url: 'api/support-stats',  // Dùng URL tương đối
                type: 'POST',
                data: {
                    action: 'forward',
                    id: ticketId,  // SupportStatsServlet dùng 'id' thay vì 'ticketId'
                    assignedTo: assignedToId,  // SupportStatsServlet dùng 'assignedTo' thay vì 'assignedToId'
                    forwardPriority: priority,  // SupportStatsServlet dùng 'forwardPriority' thay vì 'priority'
                    forwardNote: ''  // Có thể thêm ghi chú nếu cần
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        alert('✓ ' + response.message);
                        $('#forwardTicketModal').modal('hide');
                        // Reload trang để cập nhật danh sách
                        location.reload();
                    } else {
                        alert('✗ ' + response.message);
                    }
                },
                error: function() {
                    alert('✗ Không thể chuyển tiếp ticket. Vui lòng thử lại!');
                },
                complete: function() {
                    // Enable button
                    $('#btnForwardTicket').prop('disabled', false).html('<i class="fa fa-share"></i> Chuyển tiếp');
                }
            });
        }

        function loadHeadTechniciansForEdit(currentAssignedTo) {
            // Thử dùng support-management vì getHeadTechnicians vẫn còn trong handleApiRequest
            $.ajax({
                url: 'support-management',
                type: 'GET',
                data: { action: 'getHeadTechnicians' },
                dataType: 'json',
                success: function(response) {
                    if (response && response.success && response.data) {
                        var select = $('#edit_assignedTo');
                        select.html('<option value="">-- Chưa phân công --</option>');
                        
                        response.data.forEach(function(tech) {
                            var selected = (currentAssignedTo && currentAssignedTo == tech.id) ? ' selected' : '';
                            select.append('<option value="' + tech.id + '"' + selected + '>' + escapeHtml(tech.name) + ' (' + escapeHtml(tech.email) + ')</option>');
                        });
                    } else {
                        // Fallback: thử api/support-stats
                        $.ajax({
                            url: 'api/support-stats',
                            type: 'GET',
                            data: { action: 'getTechnicalStaff' },
                            dataType: 'json',
                            success: function(response2) {
                                if (response2 && response2.success && response2.data) {
                                    var select = $('#edit_assignedTo');
                                    select.html('<option value="">-- Chưa phân công --</option>');
                                    response2.data.forEach(function(tech) {
                                        var selected = (currentAssignedTo && currentAssignedTo == tech.id) ? ' selected' : '';
                                        select.append('<option value="' + tech.id + '"' + selected + '>' + escapeHtml(tech.name) + ' (' + escapeHtml(tech.email) + ')</option>');
                                    });
                                }
                            },
                            error: function() {
                                console.error('Error loading head technicians for edit');
                            }
                        });
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error loading head technicians for edit:', {
                        status: status,
                        error: error,
                        responseText: xhr.responseText,
                        statusCode: xhr.status
                    });
                }
            });
        }

    </script>
</body>
</html>