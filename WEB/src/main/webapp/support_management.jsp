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
         
         /* Styling cho button chuyển tiếp */
         .btn-success.btn-xs {
             background-color: #5cb85c;
             border-color: #4cae4c;
         }
         
         .btn-success.btn-xs:hover {
             background-color: #449d44;
             border-color: #398439;
         }
         
         /* Modal chuyển tiếp */
         #forwardModal .modal-header {
             background-color: #5cb85c;
             color: white;
         }
         
         #forwardModal .modal-header .close {
             color: white;
             opacity: 0.8;
         }
         
         #forwardModal .modal-header .close:hover {
             opacity: 1;
        }
    </style>
</head>
<body class="skin-black">
    <!-- header logo: style can be found in header.less -->
    <header class="header">
        <a href="support_management.jsp" class="logo">
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
                    <li class="active">
                        <a href="support_management.jsp">
                            <i class="fa fa-life-ring"></i> <span>Quản lý yêu cầu hỗ trợ</span>
                        </a>
                    </li>
                    <li>
                        <a href="contracts.jsp">
                            <i class="fa fa-file-text"></i> <span>Quản lý hợp đồng</span>
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
                <div class="row">
                        <div class="col-md-3">
                            <label>Trạng thái:</label>
                            <select id="statusFilter" class="form-control">
                                            <option value="">Tất cả</option>
                                <option value="open">Đang chờ</option>
                                            <option value="in_progress">Đang xử lý</option>
                                <option value="resolved">Hoàn thành</option>
                                            <option value="closed">Đã đóng</option>
                                        </select>
                                    </div>
                        <div class="col-md-3">
                            <label>Độ ưu tiên:</label>
                            <select id="priorityFilter" class="form-control">
                                            <option value="">Tất cả</option>
                                            <option value="urgent">Khẩn cấp</option>
                                            <option value="high">Cao</option>
                                            <option value="medium">Trung bình</option>
                                            <option value="low">Thấp</option>
                                        </select>
                                    </div>
                        <div class="col-md-3">
                            <label>Danh mục:</label>
                            <select id="categoryFilter" class="form-control">
                                <option value="">Tất cả</option>
                                <option value="technical">Kỹ thuật</option>
                                <option value="billing">Thanh toán</option>
                                <option value="general">Chung</option>
                                <option value="complaint">Khiếu nại</option>
                            </select>
                                    </div>
                        <div class="col-md-3">
                            <label>&nbsp;</label><br>
                            <button type="button" class="btn btn-primary" onclick="applyFilters()">
                                        <i class="fa fa-filter"></i> Lọc
                                    </button>
                             <button type="button" class="btn btn-default" onclick="clearFilters()">
                                 <i class="fa fa-refresh"></i> Xóa bộ lọc
                                     </button>
                             <button type="button" class="btn btn-info" onclick="window.location.href='tech_support_management.jsp'">
                                 <i class="fa fa-wrench"></i> Xem ticket kỹ thuật
                                     </button>
                        </div>
                    </div>
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
                                    <tbody id="ticketsTableBody">
                                        <tr>
                                                <td colspan="9" class="text-center">
                                                    <i class="fa fa-spinner fa-spin"></i> Đang tải dữ liệu...
                                                </td>
                                        </tr>
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
        var ticketsData = [];
        var dataTable;
        
        $(document).ready(function() {
            loadTickets();
        });
        
        function loadTickets() {
            $.ajax({
                url: 'api/support-stats?action=list',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        ticketsData = response.data;
                        renderTicketsTable();
                        console.log('Đã tải ' + ticketsData.length + ' ticket');
                    } else {
                        console.error('Lỗi tải danh sách ticket:', response.message);
                        showError('Không thể tải danh sách yêu cầu hỗ trợ');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Không thể tải danh sách ticket:', error);
                    showError('Lỗi kết nối server');
                }
            });
        }

        function renderTicketsTable() {
            var tbody = $('#ticketsTableBody');
            tbody.empty();
            
            if (ticketsData.length === 0) {
                tbody.append('<tr><td colspan="9" class="text-center">Chưa có yêu cầu hỗ trợ nào</td></tr>');
                return;
            }
            
            ticketsData.forEach(function(ticket) {
                var row = createTicketRow(ticket);
                tbody.append(row);
            });
            
            // Initialize DataTable if not already initialized
            if (!dataTable) {
                dataTable = $('#ticketsTable').DataTable({
                    "language": {
                        "url": "//cdn.datatables.net/plug-ins/1.10.24/i18n/Vietnamese.json"
                    },
                    "pageLength": 25,
                    "order": [[7, "desc"]] // Sort by created date desc
                });
            }
        }

        function createTicketRow(ticket) {
            var categoryLabel = getCategoryLabel(ticket.category);
            var priorityLabel = getPriorityLabel(ticket.priority);
            var statusLabel = getStatusLabel(ticket.status);
            var createdDate = formatDate(ticket.createdAt);
            var priorityClass = 'ticket-priority-' + ticket.priority;

            return '<tr class="' + priorityClass + '">' +
                '<td>' + ticket.id + '</td>' +
                '<td><strong>#' + ticket.ticketNumber + '</strong></td>' +
                '<td>' + (ticket.customerName || 'N/A') + '</td>' +
                '<td>' + ticket.subject + '</td>' +
                '<td>' + categoryLabel + '</td>' +
                '<td>' + priorityLabel + '</td>' +
                '<td>' + statusLabel + '</td>' +
                '<td>' + createdDate + '</td>' +
                 '<td>' +
                     '<button class="btn btn-info btn-xs" onclick="viewTicket(' + ticket.id + ')" title="Xem chi tiết">' +
                         '<i class="fa fa-eye"></i> Xem' +
                     '</button> ' +
                     '<button class="btn btn-warning btn-xs" onclick="editTicket(' + ticket.id + ')" title="Chỉnh sửa">' +
                         '<i class="fa fa-edit"></i> Sửa' +
                     '</button> ' +
                     '<button class="btn btn-success btn-xs" onclick="forwardTicket(' + ticket.id + ')" title="Chuyển tiếp">' +
                         '<i class="fa fa-forward"></i> Chuyển tiếp' +
                     '</button> ' +
                     '<button class="btn btn-danger btn-xs" onclick="deleteTicket(' + ticket.id + ')" title="Xóa">' +
                         '<i class="fa fa-trash"></i> Xóa' +
                     '</button>' +
                 '</td>' +
            '</tr>';
        }

        function getCategoryLabel(category) {
            var labels = {
                'technical': '<span class="label label-info">Kỹ thuật</span>',
                'billing': '<span class="label label-success">Thanh toán</span>',
                'general': '<span class="label label-default">Chung</span>',
                'complaint': '<span class="label label-danger">Khiếu nại</span>'
            };
            return labels[category] || '<span class="label label-default">' + category + '</span>';
        }

        function getPriorityLabel(priority) {
            var labels = {
                'low': '<span class="label label-info">Thấp</span>',
                'medium': '<span class="label label-warning">Trung bình</span>',
                'high': '<span class="label label-danger">Cao</span>',
                'urgent': '<span class="label label-danger">Khẩn cấp</span>'
            };
            return labels[priority] || '<span class="label label-default">' + priority + '</span>';
        }

        function getStatusLabel(status) {
            var labels = {
                'open': '<span class="label label-primary">Đang chờ</span>',
                'in_progress': '<span class="label label-warning">Đang xử lý</span>',
                'resolved': '<span class="label label-success">Hoàn thành</span>',
                'closed': '<span class="label label-default">Đã đóng</span>'
            };
            return labels[status] || '<span class="label label-default">' + status + '</span>';
        }

        function formatDate(dateString) {
            if (!dateString) return 'N/A';
            var date = new Date(dateString);
            return date.toLocaleDateString('vi-VN') + ' ' + date.toLocaleTimeString('vi-VN', {hour: '2-digit', minute: '2-digit'});
        }

        function applyFilters() {
            var status = $('#statusFilter').val();
            var priority = $('#priorityFilter').val();
            var category = $('#categoryFilter').val();

            var filteredData = ticketsData.filter(function(ticket) {
                return (!status || ticket.status === status) &&
                       (!priority || ticket.priority === priority) &&
                       (!category || ticket.category === category);
            });

            // Re-render table with filtered data
            var originalData = ticketsData;
            ticketsData = filteredData;
            renderTicketsTable();
            ticketsData = originalData; // Restore original data
        }

        function clearFilters() {
            $('#statusFilter').val('');
            $('#priorityFilter').val('');
            $('#categoryFilter').val('');
            renderTicketsTable();
        }

        function viewTicket(ticketId) {
            // Tìm ticket trong danh sách
            var ticket = ticketsData.find(function(t) { return t.id == ticketId; });
            if (!ticket) {
                alert('Không tìm thấy ticket');
                return;
            }
            
            // Hiển thị modal chi tiết
            showTicketDetailModal(ticket);
        }

        function editTicket(ticketId) {
            // Tìm ticket trong danh sách
            var ticket = ticketsData.find(function(t) { return t.id == ticketId; });
            if (!ticket) {
                alert('Không tìm thấy ticket');
                return;
            }
            
            // Hiển thị modal chỉnh sửa
            showTicketDetailModal(ticket, true);
        }

        function showTicketDetailModal(ticket, isEditMode) {
            // Tạo modal HTML bằng cách nối chuỗi thay vì template literal
            var modalHtml = '<div class="modal fade" id="ticketDetailModal" tabindex="-1" role="dialog">' +
                '<div class="modal-dialog modal-lg" role="document">' +
                    '<div class="modal-content">' +
                        '<div class="modal-header">' +
                            '<h4 class="modal-title">Chi tiết yêu cầu hỗ trợ</h4>' +
                            '<button type="button" class="close" data-dismiss="modal">&times;</button>' +
                        '</div>' +
                        '<div class="modal-body">' +
                            '<form id="ticketDetailForm">' +
                                '<div class="row">' +
                                    '<div class="col-md-6">' +
                                        '<div class="form-group">' +
                                            '<label>Mã Ticket:</label>' +
                                            '<input type="text" class="form-control" value="' + (ticket.ticketNumber || '') + '" readonly>' +
                                        '</div>' +
                                    '</div>' +
                                    '<div class="col-md-6">' +
                                        '<div class="form-group">' +
                                            '<label>Khách hàng:</label>' +
                                            '<input type="text" class="form-control" value="' + (ticket.customerName || '') + '" readonly>' +
                                        '</div>' +
                                    '</div>' +
                                '</div>' +
                                '<div class="row">' +
                                    '<div class="col-md-6">' +
                                        '<div class="form-group">' +
                                            '<label>Email:</label>' +
                                            '<input type="email" class="form-control" value="' + (ticket.customerEmail || '') + '" readonly>' +
                                        '</div>' +
                                    '</div>' +
                                    '<div class="col-md-6">' +
                                        '<div class="form-group">' +
                                            '<label>Ngày tạo:</label>' +
                                            '<input type="text" class="form-control" id="detailCreatedAt" readonly>' +
                                        '</div>' +
                                    '</div>' +
                                '</div>' +
                                 '<div class="form-group">' +
                                     '<label>Tiêu đề:</label>' +
                                     '<input type="text" class="form-control" id="detailSubject" value="' + (ticket.subject || '') + '" readonly>' +
                                 '</div>' +
                                 '<div class="form-group">' +
                                     '<label>Mô tả vấn đề:</label>' +
                                     '<textarea class="form-control" id="detailDescription" rows="4" lang="vi" inputmode="text" placeholder="Nhập mô tả vấn đề bằng tiếng Việt..." readonly>' + (ticket.description || '') + '</textarea>' +
                                 '</div>' +
                                '<div class="row">' +
                                     '<div class="col-md-4">' +
                                         '<div class="form-group">' +
                                             '<label>Danh mục:</label>' +
                                             '<select class="form-control" id="detailCategory" disabled>' +
                                                 '<option value="technical"' + (ticket.category === 'technical' ? ' selected' : '') + '>Kỹ thuật</option>' +
                                                 '<option value="billing"' + (ticket.category === 'billing' ? ' selected' : '') + '>Thanh toán</option>' +
                                                 '<option value="general"' + (ticket.category === 'general' ? ' selected' : '') + '>Chung</option>' +
                                                 '<option value="complaint"' + (ticket.category === 'complaint' ? ' selected' : '') + '>Khiếu nại</option>' +
                                             '</select>' +
                                         '</div>' +
                                     '</div>' +
                                     '<div class="col-md-4">' +
                                         '<div class="form-group">' +
                                             '<label>Độ ưu tiên:</label>' +
                                             '<select class="form-control" id="detailPriority" ' + (isEditMode ? '' : 'disabled') + '>' +
                                                 '<option value="low"' + (ticket.priority === 'low' ? ' selected' : '') + '>Thấp</option>' +
                                                 '<option value="medium"' + (ticket.priority === 'medium' ? ' selected' : '') + '>Trung bình</option>' +
                                                 '<option value="high"' + (ticket.priority === 'high' ? ' selected' : '') + '>Cao</option>' +
                                                 '<option value="urgent"' + (ticket.priority === 'urgent' ? ' selected' : '') + '>Khẩn cấp</option>' +
                                             '</select>' +
                                         '</div>' +
                                     '</div>' +
                                     '<div class="col-md-4">' +
                                         '<div class="form-group">' +
                                             '<label>Trạng thái:</label>' +
                                             '<select class="form-control" id="detailStatus" ' + (isEditMode ? '' : 'disabled') + '>' +
                                                 '<option value="open"' + (ticket.status === 'open' ? ' selected' : '') + '>Đang chờ</option>' +
                                                 '<option value="in_progress"' + (ticket.status === 'in_progress' ? ' selected' : '') + '>Đang xử lý</option>' +
                                                 '<option value="resolved"' + (ticket.status === 'resolved' ? ' selected' : '') + '>Đã giải quyết</option>' +
                                                 '<option value="closed"' + (ticket.status === 'closed' ? ' selected' : '') + '>Đã đóng</option>' +
                                             '</select>' +
                                         '</div>' +
                                     '</div>' +
                                '</div>' +
                                '<div class="form-group">' +
                                    '<label>Giải pháp:</label>' +
                                    '<textarea class="form-control" id="detailResolution" rows="3" ' + (isEditMode ? '' : 'readonly') + '>' + (ticket.resolution || '') + '</textarea>' +
                                '</div>' +
                                '<div class="form-group">' +
                                    '<label>Ghi chú nội bộ:</label>' +
                                    '<textarea class="form-control" id="detailInternalNotes" rows="2" ' + (isEditMode ? '' : 'readonly') + ' placeholder="Ghi chú cho nhân viên">' + (ticket.internalNotes || '') + '</textarea>' +
                                '</div>' +
                            '</form>' +
                        '</div>' +
                        '<div class="modal-footer">' +
                            (isEditMode ? 
                                '<button type="button" class="btn btn-primary" onclick="saveTicketChanges(' + ticket.id + ')">Lưu thay đổi</button>' : 
                                '<button type="button" class="btn btn-warning" onclick="editTicket(' + ticket.id + ')">Chỉnh sửa</button>'
                            ) +
                            '<button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
            '</div>';
            
            // Xóa modal cũ nếu có
            $('#ticketDetailModal').remove();
            
            // Thêm modal mới vào body
            $('body').append(modalHtml);
            
             // Hiển thị modal
             $('#ticketDetailModal').modal('show');
             
             // Set giá trị ngày tạo sau khi modal hiển thị
             setTimeout(function() {
                 $('#detailCreatedAt').val(formatDate(ticket.createdAt));
                 setupVietnameseInput();
             }, 300);
         }
         
         function setupVietnameseInput() {
             var descriptionField = $('#detailDescription');
             if (descriptionField.length > 0) {
                 // Thêm event listener để kiểm tra input
                 descriptionField.on('input', function() {
                     var value = $(this).val();
                     // Cho phép tiếng Việt, số, dấu câu và khoảng trắng
                     var vietnameseRegex = /^[a-zA-ZàáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđĐ0-9\s.,!?;:'"()-]+$/;
                     
                     if (value && !vietnameseRegex.test(value)) {
                         // Thông báo lỗi nếu có ký tự không hợp lệ
                         $(this).addClass('error');
                         if (!$(this).next('.error-message').length) {
                             $(this).after('<div class="error-message text-danger" style="font-size: 12px; margin-top: 5px;">Chỉ được nhập tiếng Việt, số và dấu câu cơ bản</div>');
                         }
                     } else {
                         $(this).removeClass('error');
                         $(this).next('.error-message').remove();
                     }
                 });
                 
                 // Thêm CSS cho trạng thái lỗi
                 if (!$('#vietnamese-input-styles').length) {
                     $('head').append('<style id="vietnamese-input-styles">' +
                         '#detailDescription.error { border-color: #d9534f; box-shadow: 0 0 5px rgba(217, 83, 79, 0.3); }' +
                         '</style>');
                 }
             }
         }
        
         function saveTicketChanges(ticketId) {
             // Chỉ lấy các trường được phép chỉnh sửa
             var formData = {
                action: 'update',
                 id: ticketId,
                 priority: $('#detailPriority').val(),
                 status: $('#detailStatus').val(),
                 resolution: $('#detailResolution').val(),
                 internalNotes: $('#detailInternalNotes').val()
            };
            
            $.ajax({
                url: 'api/support-stats',
                type: 'POST',
                data: formData,
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        alert('Cập nhật ticket thành công!');
                        $('#ticketDetailModal').modal('hide');
                        loadTickets(); // Reload danh sách
                    } else {
                        alert('Lỗi: ' + response.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert('Lỗi kết nối server: ' + error);
                }
            });
        }
        
         function forwardTicket(ticketId) {
             // Tìm ticket trong danh sách
             var ticket = ticketsData.find(function(t) { return t.id == ticketId; });
             if (!ticket) {
                 alert('Không tìm thấy ticket');
                 return;
             }
             
             // Hiển thị modal chuyển tiếp
             showForwardModal(ticket);
         }
         
         function showForwardModal(ticket) {
             var modalHtml = '<div class="modal fade" id="forwardModal" tabindex="-1" role="dialog">' +
                 '<div class="modal-dialog" role="document">' +
                     '<div class="modal-content">' +
                         '<div class="modal-header">' +
                             '<h4 class="modal-title">Chuyển tiếp yêu cầu hỗ trợ</h4>' +
                             '<button type="button" class="close" data-dismiss="modal">&times;</button>' +
                         '</div>' +
                         '<div class="modal-body">' +
                             '<form id="forwardForm">' +
                                 '<div class="form-group">' +
                                     '<label>Ticket #' + ticket.ticketNumber + '</label>' +
                                     '<p class="form-control-static">' + ticket.subject + '</p>' +
                                 '</div>' +
                                 '<div class="form-group">' +
                                     '<label>Chuyển đến bộ phận:</label>' +
                                     '<select class="form-control" id="forwardDepartment" required>' +
                                         '<option value="">-- Chọn bộ phận --</option>' +
                                         '<option value="head_technical">Trưởng phòng Kỹ thuật</option>' +
                                     '</select>' +
                                 '</div>' +
                                 '<div class="form-group">' +
                                     '<label>Ghi chú chuyển tiếp:</label>' +
                                     '<textarea class="form-control" id="forwardNote" rows="3" placeholder="Lý do chuyển tiếp và hướng dẫn xử lý..."></textarea>' +
                                 '</div>' +
                                 '<div class="form-group">' +
                                     '<label>Độ ưu tiên mới:</label>' +
                                     '<select class="form-control" id="forwardPriority">' +
                                         '<option value="' + ticket.priority + '">Giữ nguyên (' + getPriorityLabel(ticket.priority) + ')</option>' +
                                         '<option value="low">Thấp</option>' +
                                         '<option value="medium">Trung bình</option>' +
                                         '<option value="high">Cao</option>' +
                                         '<option value="urgent">Khẩn cấp</option>' +
                                     '</select>' +
                                 '</div>' +
                             '</form>' +
                         '</div>' +
                         '<div class="modal-footer">' +
                             '<button type="button" class="btn btn-primary" onclick="confirmForward(' + ticket.id + ')">Chuyển tiếp</button>' +
                             '<button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>' +
                         '</div>' +
                     '</div>' +
                 '</div>' +
             '</div>';
             
             // Xóa modal cũ nếu có
             $('#forwardModal').remove();
             
             // Thêm modal mới vào body
             $('body').append(modalHtml);
             
             // Hiển thị modal
             $('#forwardModal').modal('show');
         }
         
         function confirmForward(ticketId) {
             var department = $('#forwardDepartment').val();
             var forwardNote = $('#forwardNote').val();
             var forwardPriority = $('#forwardPriority').val();
             
             if (!department) {
                 alert('Vui lòng chọn bộ phận chuyển tiếp!');
                return;
            }
            
             if (confirm('Bạn có chắc chắn muốn chuyển tiếp ticket này?')) {
                 // Gửi request chuyển tiếp
                 $.ajax({
                     url: 'api/support-stats',
                     type: 'POST',
                     data: {
                         action: 'forward',
                         id: ticketId,
                         department: department,
                         forwardNote: forwardNote,
                         forwardPriority: forwardPriority
                     },
                     dataType: 'json',
                     success: function(response) {
                         if (response.success) {
                             alert('Chuyển tiếp ticket thành công! Ticket đã được chuyển đến Trưởng phòng Kỹ thuật.');
                             $('#forwardModal').modal('hide');
                             loadTickets(); // Reload danh sách
                             
                             // Redirect đến trang tech_support_management.jsp sau 2 giây
                             setTimeout(function() {
                                 window.location.href = 'tech_support_management.jsp';
                             }, 2000);
            } else {
                             alert('Lỗi: ' + response.message);
                         }
                     },
                     error: function(xhr, status, error) {
                         alert('Lỗi kết nối server: ' + error);
                     }
                 });
             }
         }
         
         function deleteTicket(ticketId) {
             if (confirm('Bạn có chắc chắn muốn xóa ticket #' + ticketId + '?')) {
                 // TODO: Implement delete functionality
                 alert('Xóa ticket #' + ticketId);
             }
         }

        function showError(message) {
            $('#ticketsTableBody').html('<tr><td colspan="9" class="text-center text-danger">' + message + '</td></tr>');
        }
    </script>
</body>
</html>