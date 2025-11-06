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
    <title>Quản Lý Liên Hệ | Bảng Điều Khiển</title>
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
        .message-status-new { border-left: 4px solid #d9534f; }
        .message-status-replied { border-left: 4px solid #5cb85c; }
        .message-status-read { border-left: 4px solid #5bc0de; }
        
        .message-detail {
            white-space: pre-wrap;
            word-wrap: break-word;
            font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
            line-height: 1.6;
        }
    </style>
</head>
<body class="skin-black">
    <!-- header logo: style can be found in header.less -->
    <header class="header">
        <a href="contact-management" class="logo">
            Quản Lý Liên Hệ
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
                <!-- Filter Section -->
                <div class="filter-section">
                    <form method="GET" action="contact-management">
                        <div class="row">
                            <div class="col-md-2">
                                <label>Trạng thái:</label>
                                <select name="status" class="form-control">
                                    <option value="">Tất cả</option>
                                    <option value="new" ${param.status == 'new' ? 'selected' : ''}>Mới</option>
                                    <option value="read" ${param.status == 'read' ? 'selected' : ''}>Đã đọc</option>
                                    <option value="replied" ${param.status == 'replied' ? 'selected' : ''}>Đã phản hồi</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label>Từ ngày:</label>
                                <input type="date" name="startDate" class="form-control" value="${param.startDate}">
                            </div>
                            <div class="col-md-2">
                                <label>Đến ngày:</label>
                                <input type="date" name="endDate" class="form-control" value="${param.endDate}">
                            </div>
                            <div class="col-md-3">
                                <label>&nbsp;</label><br>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa fa-filter"></i> Lọc
                                </button>
                                <a href="contact-management" class="btn btn-default">
                                    <i class="fa fa-refresh"></i> Xóa bộ lọc
                                </a>
                            </div>
                            <div class="col-md-3 text-right">
                                <label>&nbsp;</label><br>
                                <span class="text-muted">Tổng số: <strong>${totalMessages}</strong> tin nhắn</span>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Messages Table -->
                <div class="row">
                    <div class="col-md-12">
                        <section class="panel">
                            <header class="panel-heading">
                                <h3>Danh sách tin nhắn liên hệ</h3>
                            </header>
                            <div class="panel-body">
                                <div class="table-responsive">
                                    <table id="messagesTable" class="table table-striped table-bordered table-hover">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Họ tên</th>
                                                <th>Email</th>
                                                <th>Số điện thoại</th>
                                                <th>Tin nhắn</th>
                                                <th>Trạng thái</th>
                                                <th>Ngày gửi</th>
                                                <th>Ngày phản hồi</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${not empty messages}">
                                                    <c:forEach var="message" items="${messages}">
                                                        <tr class="message-status-${message.status}">
                                                            <td>${message.id}</td>
                                                            <td><strong>${message.fullName}</strong></td>
                                                            <td>${message.email}</td>
                                                            <td>${message.phone}</td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${fn:length(message.message) > 50}">
                                                                        ${fn:substring(message.message, 0, 50)}...
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        ${message.message}
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${message.status == 'new'}">
                                                                        <span class="label label-danger">Mới</span>
                                                                    </c:when>
                                                                    <c:when test="${message.status == 'read'}">
                                                                        <span class="label label-info">Đã đọc</span>
                                                                    </c:when>
                                                                    <c:when test="${message.status == 'replied'}">
                                                                        <span class="label label-success">Đã phản hồi</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="label label-default">${message.status}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <fmt:formatDate value="${message.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty message.repliedAt}">
                                                                        <fmt:formatDate value="${message.repliedAt}" pattern="dd/MM/yyyy HH:mm" />
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="text-muted">-</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <button class="btn btn-info btn-xs view-message-btn" data-message-id="${message.id}" title="Xem chi tiết">
                                                                    <i class="fa fa-eye"></i> Xem
                                                                </button>
                                                                <c:if test="${message.status == 'new'}">
                                                                    <button class="btn btn-success btn-xs mark-read-btn" data-message-id="${message.id}" title="Đánh dấu đã đọc">
                                                                        <i class="fa fa-check"></i> Đã đọc
                                                                    </button>
                                                                </c:if>
                                                                <button class="btn btn-primary btn-xs mark-replied-btn" data-message-id="${message.id}" title="Đánh dấu đã phản hồi">
                                                                    <i class="fa fa-reply"></i> Đã phản hồi
                                                                </button>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <tr>
                                                        <td colspan="9" class="text-center">
                                                            <p class="text-muted">Không có tin nhắn nào.</p>
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
            <div class="footer-main">
                Copyright &copy Hệ thống hỗ trợ khách hàng - HL Generator, 2025
            </div>
        </aside><!-- /.right-side -->
    </div><!-- ./wrapper -->

    <!-- Modal xem chi tiết tin nhắn -->
    <div class="modal fade" id="viewMessageModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title">Chi tiết tin nhắn liên hệ</h4>
                </div>
                <div class="modal-body" id="messageDetailContent">
                    <!-- Nội dung sẽ được load bằng JavaScript -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                    <button type="button" class="btn btn-primary" id="btnMarkAsReplied">Đánh dấu đã phản hồi</button>
                </div>
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
        var currentMessageId = null;
        
        // Khởi tạo DataTable
        $(document).ready(function() {
            $('#messagesTable').DataTable({
                "language": {
                    "lengthMenu": "Hiển thị _MENU_ bản ghi mỗi trang",
                    "zeroRecords": "Không tìm thấy dữ liệu",
                    "info": "Trang _PAGE_ / _PAGES_",
                    "infoEmpty": "Không có dữ liệu",
                    "infoFiltered": "(lọc từ _MAX_ tổng số bản ghi)",
                    "search": "Tìm kiếm:",
                    "paginate": {
                        "first": "Đầu",
                        "last": "Cuối",
                        "next": "Tiếp",
                        "previous": "Trước"
                    }
                },
                "order": [[0, "desc"]],
                "pageLength": 25
            });
        });
        
        // Xử lý click button xem chi tiết
        $(document).on('click', '.view-message-btn', function() {
            var messageId = $(this).data('message-id');
            viewMessage(messageId);
        });
        
        // Xử lý click button đánh dấu đã đọc
        $(document).on('click', '.mark-read-btn', function() {
            var messageId = $(this).data('message-id');
            updateStatus(messageId, 'read');
        });
        
        // Xử lý click button đánh dấu đã phản hồi
        $(document).on('click', '.mark-replied-btn', function() {
            var messageId = $(this).data('message-id');
            updateStatus(messageId, 'replied');
        });
        
        // Xem chi tiết tin nhắn
        function viewMessage(messageId) {
            currentMessageId = messageId;
            
            // Tìm dòng trong bảng
            var row = $('#messagesTable tbody tr').filter(function() {
                return $(this).find('td:first').text() == messageId;
            });
            
            if (row.length === 0) {
                alert('Không tìm thấy tin nhắn');
                return;
            }
            
            // Lấy thông tin từ bảng
            var fullName = row.find('td:eq(1)').text().trim();
            var email = row.find('td:eq(2)').text().trim();
            var phone = row.find('td:eq(3)').text().trim();
            var message = row.find('td:eq(4)').text().trim();
            var status = row.find('td:eq(5) span').text().trim();
            var createdAt = row.find('td:eq(6)').text().trim();
            var repliedAt = row.find('td:eq(7)').text().trim();
            
            // Lấy toàn bộ nội dung tin nhắn (có thể cần gọi API)
            // Tạm thời dùng nội dung từ bảng
            var html = '<div class="row">';
            html += '<div class="col-md-12">';
            html += '<div class="form-group">';
            html += '<label>Họ tên:</label>';
            html += '<p class="form-control-static"><strong>' + escapeHtml(fullName) + '</strong></p>';
            html += '</div>';
            html += '<div class="form-group">';
            html += '<label>Email:</label>';
            html += '<p class="form-control-static"><a href="mailto:' + escapeHtml(email) + '">' + escapeHtml(email) + '</a></p>';
            html += '</div>';
            html += '<div class="form-group">';
            html += '<label>Số điện thoại:</label>';
            html += '<p class="form-control-static"><a href="tel:' + escapeHtml(phone) + '">' + escapeHtml(phone) + '</a></p>';
            html += '</div>';
            html += '<div class="form-group">';
            html += '<label>Trạng thái:</label>';
            html += '<p class="form-control-static"><span class="label label-' + (status === 'Mới' ? 'danger' : status === 'Đã phản hồi' ? 'success' : 'info') + '">' + escapeHtml(status) + '</span></p>';
            html += '</div>';
            html += '<div class="form-group">';
            html += '<label>Ngày gửi:</label>';
            html += '<p class="form-control-static">' + escapeHtml(createdAt) + '</p>';
            html += '</div>';
            if (repliedAt && repliedAt !== '-') {
                html += '<div class="form-group">';
                html += '<label>Ngày phản hồi:</label>';
                html += '<p class="form-control-static">' + escapeHtml(repliedAt) + '</p>';
                html += '</div>';
            }
            html += '<div class="form-group">';
            html += '<label>Nội dung tin nhắn:</label>';
            html += '<div class="message-detail" style="background: #f9f9f9; padding: 15px; border-radius: 5px; border: 1px solid #ddd;">';
            html += escapeHtml(message);
            html += '</div>';
            html += '</div>';
            html += '</div>';
            html += '</div>';
            
            $('#messageDetailContent').html(html);
            $('#viewMessageModal').modal('show');
            
            // Nếu chưa đọc, tự động đánh dấu đã đọc
            if (status === 'Mới') {
                updateStatus(messageId, 'read', false);
            }
        }
        
        // Cập nhật trạng thái
        function updateStatus(messageId, status, showAlert) {
            if (showAlert === undefined) showAlert = true;
            
            if (showAlert && !confirm('Bạn có chắc muốn cập nhật trạng thái?')) {
                return;
            }
            
            $.ajax({
                url: 'contact-management',
                type: 'POST',
                data: {
                    action: 'updateStatus',
                    id: messageId,
                    status: status
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        if (showAlert) {
                            alert('✓ ' + response.message);
                        }
                        location.reload();
                    } else {
                        alert('✗ ' + response.message);
                    }
                },
                error: function() {
                    alert('✗ Không thể cập nhật. Vui lòng thử lại!');
                }
            });
        }
        
        // Đánh dấu đã phản hồi từ modal
        $('#btnMarkAsReplied').click(function() {
            if (currentMessageId) {
                updateStatus(currentMessageId, 'replied');
                $('#viewMessageModal').modal('hide');
            }
        });
        
        // Hàm escape HTML
        function escapeHtml(text) {
            var map = {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#039;'
            };
            return text.replace(/[&<>"']/g, function(m) { return map[m]; });
        }
    </script>
</body>
</html>

