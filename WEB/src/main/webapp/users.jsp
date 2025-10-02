<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng điều khiển | Quản lý người dùng</title>
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
    <link href='http://fonts.googleapis.com/css?family=Lato' rel='stylesheet' type='text/css'>
    
    <style>
        :root {
            --btn-padding: 4px 12px;
            --btn-radius: 4px;
            --btn-transition: all 0.15s ease;
            --shadow-light: 0 2px 4px;
            --shadow-hover: 0 4px 8px;
        }
        
        .action-buttons {
            white-space: nowrap;
            min-width: 200px;
            max-width: 250px;
        }
        
        .action-buttons .btn-group {
            display: flex;
            gap: 4px;
            width: 100%;
        }
        
        .action-buttons .btn {
            padding: var(--btn-padding);
            font-size: 11px;
            font-weight: 500;
            border-radius: var(--btn-radius);
            border: none;
            transition: var(--btn-transition);
            text-transform: none;
            letter-spacing: 0.3px;
            flex: 1;
            min-width: 60px;
            text-align: center;
        }
        
        .action-buttons .dropdown-menu {
            min-width: 180px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            border: none;
            border-radius: 6px;
            padding: 5px 0;
        }
        
        .action-buttons .dropdown-menu li a {
            padding: 8px 15px;
            font-size: 12px;
            color: #333;
            transition: var(--btn-transition);
        }
        
        .action-buttons .dropdown-menu li a:hover {
            background-color: #f8f9fa;
            color: #000;
        }
        
        .action-buttons .dropdown-menu .divider {
            margin: 5px 0;
            background-color: #e9ecef;
        }
        
        .action-buttons .btn i {
            margin-right: 4px;
            font-size: 10px;
        }
        
        /* Button colors */
        .action-buttons .btn-info { background: linear-gradient(135deg, #3498db, #2980b9); color: white; box-shadow: var(--shadow-light) rgba(52, 152, 219, 0.3); }
        .action-buttons .btn-info:hover { background: linear-gradient(135deg, #2980b9, #21618c); transform: translateY(-1px); box-shadow: var(--shadow-hover) rgba(52, 152, 219, 0.4); }
        .action-buttons .btn-warning { background: linear-gradient(135deg, #f39c12, #e67e22); color: white; box-shadow: var(--shadow-light) rgba(243, 156, 18, 0.3); }
        .action-buttons .btn-warning:hover { background: linear-gradient(135deg, #e67e22, #d35400); transform: translateY(-1px); box-shadow: var(--shadow-hover) rgba(243, 156, 18, 0.4); }
        .action-buttons .btn-primary { background: linear-gradient(135deg, #9b59b6, #8e44ad); color: white; box-shadow: var(--shadow-light) rgba(155, 89, 182, 0.3); }
        .action-buttons .btn-primary:hover { background: linear-gradient(135deg, #8e44ad, #7d3c98); transform: translateY(-1px); box-shadow: var(--shadow-hover) rgba(155, 89, 182, 0.4); }
        .action-buttons .btn-success { background: linear-gradient(135deg, #27ae60, #229954); color: white; box-shadow: var(--shadow-light) rgba(39, 174, 96, 0.3); }
        .action-buttons .btn-success:hover { background: linear-gradient(135deg, #229954, #1e8449); transform: translateY(-1px); box-shadow: var(--shadow-hover) rgba(39, 174, 96, 0.4); }
        .action-buttons .btn-danger { background: linear-gradient(135deg, #e74c3c, #c0392b); color: white; box-shadow: var(--shadow-light) rgba(231, 76, 60, 0.3); }
        .action-buttons .btn-danger:hover { background: linear-gradient(135deg, #c0392b, #a93226); transform: translateY(-1px); box-shadow: var(--shadow-hover) rgba(231, 76, 60, 0.4); }
        
        .action-buttons .btn:focus { outline: none; box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25); }
        .action-buttons .btn:active { transform: translateY(0); box-shadow: 0 1px 2px rgba(0,0,0,0.2); }
        
        @media (max-width: 768px) {
            .action-buttons { min-width: 160px; max-width: 180px; }
            .action-buttons .btn { padding: 3px 6px; font-size: 10px; }
        }
    </style>
</head>
<body class="skin-black">
    <!-- header logo: style can be found in header.less -->
    <header class="header">
        <a href="admin.jsp" class="logo">
            Bảng điều khiển quản trị
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
                            <span>Admin <i class="caret"></i></span>
                        </a>
                        <ul class="dropdown-menu dropdown-custom dropdown-menu-right">
                            <li class="dropdown-header text-center">Tài khoản</li>
                            <li>
                                <a href="#">
                                <i class="fa fa-user fa-fw pull-right"></i>
                                    Hồ sơ
                                </a>
                                <a data-toggle="modal" href="#modal-user-settings">
                                <i class="fa fa-cog fa-fw pull-right"></i>
                                    Cài đặt
                                </a>
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
                        <p>Xin chào, Admin</p>
                        <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
                    </div>
                </div>
                <!-- sidebar menu: : style can be found in sidebar.less -->
                <ul class="sidebar-menu">
                    <li>
                        <a href="admin.jsp">
                            <i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
                        </a>
                    </li>
                    <li>
                        <a href="products.jsp">
                            <i class="fa fa-shopping-cart"></i> <span>Quản lý sản phẩm</span>
                        </a>
                    </li>
                    <li>
                        <a href="orders.jsp">
                            <i class="fa fa-file-text-o"></i> <span>Quản lý đơn hàng</span>
                        </a>
                    </li>
                    <li>
                        <a href="contracts.jsp">
                            <i class="fa fa-file-text"></i> <span>Quản lý hợp đồng</span>
                        </a>
                    </li>
                    <li>
                        <a href="customers.jsp">
                            <i class="fa fa-users"></i> <span>Quản lý khách hàng</span>
                        </a>
                    </li>
                    <li class="active">
                        <a href="users.jsp">
                            <i class="fa fa-user-secret"></i> <span>Quản lý người dùng</span>
                        </a>
                    </li>
                    <li>
                        <a href="reports.jsp">
                            <i class="fa fa-bar-chart"></i> <span>Báo cáo</span>
                        </a>
                    </li>
                    <li>
                        <a href="settings.jsp">
                            <i class="fa fa-cog"></i> <span>Cài đặt</span>
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
                        <div class="panel">
                            <header class="panel-heading">
                                <h3>Quản lý người dùng</h3>
                                <div class="panel-tools">
                                    <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addUserModal">
                                        <i class="fa fa-plus"></i> Thêm người dùng mới
                                    </button>
                                </div>
                            </header>
                            <div class="panel-body table-responsive">
                                <table class="table table-hover" id="usersTable">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Tên đăng nhập</th>
                                            <th>Email</th>
                                            <th>Họ tên</th>
                                            <th>Số điện thoại</th>
                                            <th>Vai trò</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="usersTableBody">
                                        <%-- Lấy dữ liệu từ backend và render bằng JSP --%>
                                        <%
                                            com.hlgenerator.dao.UserDAO dao = new com.hlgenerator.dao.UserDAO();
                                            java.util.List<com.hlgenerator.model.User> users = dao.getAllUsers();
                                            for (com.hlgenerator.model.User user : users) {
                                        %>
                                        <tr>
                                            <td><%= user.getId() %></td>
                                            <td><%= user.getUsername() %></td>
                                            <td><%= user.getEmail() %></td>
                                            <td><%= user.getFullName() %></td>
                                            <td><%= user.getPhone() != null ? user.getPhone() : "-" %></td>
                                            <td><%= user.getRoleDisplayName() %></td>
                                            <td><%= user.getStatusDisplayName() %></td>
                                            <td>
                                                <div class="action-buttons">
                                                    <div class="btn-group">
                                                        <!-- Nút Xem -->
                                                        <button class="btn btn-info btn-xs" onclick="viewUser('<%= user.getId() %>')" title="Xem chi tiết">
                                                            <i class="fa fa-eye"></i> Xem
                                                        </button>
                                                        
                                                        <!-- Nút Sửa với dropdown -->
                                                        <div class="btn-group">
                                                            <button class="btn btn-warning btn-xs dropdown-toggle" data-toggle="dropdown" title="Chỉnh sửa">
                                                                <i class="fa fa-edit"></i> Sửa <span class="caret"></span>
                                                            </button>
                                                            <ul class="dropdown-menu">
                                                                <li><a href="#" onclick="editUser('<%= user.getId() %>')"><i class="fa fa-edit"></i> Chỉnh sửa thông tin</a></li>
                                                                <li><a href="#" onclick="changePasswordUser('<%= user.getId() %>')"><i class="fa fa-key"></i> Đổi mật khẩu</a></li>
                                                                <li class="divider"></li>
                                                                <% if (user.isActive()) { %>
                                                                    <li><a href="#" onclick="deactivateUser('<%= user.getId() %>')" style="color: #f39c12;"><i class="fa fa-lock"></i> Tạm khóa</a></li>
                                                                <% } else { %>
                                                                    <li><a href="#" onclick="activateUser('<%= user.getId() %>')" style="color: #27ae60;"><i class="fa fa-unlock"></i> Kích hoạt</a></li>
                                                                <% } %>
                                                                <li><a href="#" onclick="hardDeleteUser('<%= user.getId() %>')" style="color: #e74c3c;"><i class="fa fa-trash"></i> Xóa vĩnh viễn</a></li>
                                                            </ul>
                                                        </div>
                                                        
                                                        <!-- Nút Xóa -->
                                                        <button class="btn btn-danger btn-xs" onclick="deleteUser('<%= user.getId() %>')" title="Xóa tạm thời">
                                                            <i class="fa fa-trash-o"></i> Xóa
                                                        </button>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </section><!-- /.content -->
        </aside><!-- /.right-side -->
    </div><!-- ./wrapper -->

    <!-- Modal thêm người dùng -->
    <div class="modal fade" id="addUserModal" tabindex="-1" role="dialog" aria-labelledby="addUserModalLabel">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="addUserModalLabel">Thêm người dùng mới</h4>
                </div>
                <div class="modal-body">
                    <form id="addUserForm">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="username">Tên đăng nhập:</label>
                                    <input type="text" class="form-control" id="username" required>
                                </div>
                                <div class="form-group">
                                    <label for="email">Email:</label>
                                    <input type="email" class="form-control" id="email" required>
                                </div>
                                <div class="form-group">
                                    <label for="password">Mật khẩu:</label>
                                    <input type="password" class="form-control" id="password" required>
                                </div>
                                <div class="form-group">
                                    <label for="fullName">Họ và tên:</label>
                                    <input type="text" class="form-control" id="fullName" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="phone">Số điện thoại:</label>
                                    <input type="tel" class="form-control" id="phone">
                                </div>
                                <div class="form-group">
                                    <label for="role">Vai trò:</label>
                                    <select class="form-control" id="role" required>
                                        <option value="">Chọn vai trò</option>
                                        <option value="admin">Quản trị viên</option>
                                        <option value="customer_support">Hỗ trợ khách hàng</option>
                                        <option value="technical_staff">Nhân viên kỹ thuật</option>
                                        <option value="head_technician">Trưởng phòng kỹ thuật</option>
                                        <option value="storekeeper">Thủ kho</option>
                                        <option value="customer">Khách hàng</option>
                                        <option value="guest">Khách</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label for="permissions">Quyền hạn:</label>
                                    <textarea class="form-control" id="permissions" rows="3" placeholder='["view_users", "manage_users"]'></textarea>
                                </div>
                                <div class="form-group">
                                    <label>
                                        <input type="checkbox" id="isActive" checked> Kích hoạt tài khoản (có thể đăng nhập ngay)
                                    </label>
                                    <small class="text-muted">Tài khoản mới sẽ được kích hoạt tự động để có thể đăng nhập ngay lập tức</small>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <div class="pull-left">
                        <small class="text-info">
                            <i class="fa fa-info-circle"></i> 
                            Tài khoản mới sẽ được kích hoạt tự động và có thể đăng nhập ngay lập tức
                        </small>
                    </div>
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="saveUser()">Lưu người dùng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal xem chi tiết người dùng -->
    <div class="modal fade" id="userDetailModal" tabindex="-1" role="dialog" aria-labelledby="userDetailModalLabel">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="userDetailModalLabel">Chi tiết người dùng</h4>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <h5>Thông tin cơ bản</h5>
                            <p><strong>ID:</strong> <span id="detailUserId"></span></p>
                            <p><strong>Tên đăng nhập:</strong> <span id="detailUsername"></span></p>
                            <p><strong>Email:</strong> <span id="detailEmail"></span></p>
                            <p><strong>Họ và tên:</strong> <span id="detailFullName"></span></p>
                            <p><strong>Số điện thoại:</strong> <span id="detailPhone"></span></p>
                        </div>
                        <div class="col-md-6">
                            <h5>Thông tin hệ thống</h5>
                            <p><strong>Vai trò:</strong> <span id="detailRole"></span></p>
                            <p><strong>Quyền hạn:</strong> <span id="detailPermissions"></span></p>
                            <p><strong>Trạng thái:</strong> <span id="detailStatus"></span></p>
                            <p><strong>Ngày tạo:</strong> <span id="detailCreatedAt"></span></p>
                            <p><strong>Cập nhật lần cuối:</strong> <span id="detailUpdatedAt"></span></p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal đổi mật khẩu -->
    <div class="modal fade" id="changePasswordModal" tabindex="-1" role="dialog" aria-labelledby="changePasswordModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="changePasswordModalLabel">Đổi mật khẩu</h4>
                </div>
                <div class="modal-body">
                    <form id="changePasswordForm">
                        <div class="form-group">
                            <label for="newPassword">Mật khẩu mới:</label>
                            <input type="password" class="form-control" id="newPassword" required>
                        </div>
                        <div class="form-group">
                            <label for="confirmPassword">Xác nhận mật khẩu:</label>
                            <input type="password" class="form-control" id="confirmPassword" required>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="changePassword()">Đổi mật khẩu</button>
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

    <script type="text/javascript">
        var usersTable;
        var currentEditingUser = null;
        var currentPasswordUserId = null;

        $(document).ready(function() {
            // Initialize DataTable with pagination - sử dụng dữ liệu tĩnh từ JSP
            usersTable = $('#usersTable').DataTable({
                "language": {
                    "url": "//cdn.datatables.net/plug-ins/1.10.25/i18n/Vietnamese.json"
                },
                "processing": false,
                "serverSide": false,
                "paging": true,
                "pageLength": 10,
                "lengthMenu": [[5, 10, 25, 50, -1], [5, 10, 25, 50, "Tất cả"]],
                "searching": true,
                "ordering": true,
                "info": true,
                "autoWidth": false,
                "responsive": true,
                "dom": '<"row"<"col-sm-6"l><"col-sm-6"f>>' +
                       '<"row"<"col-sm-12"tr>>' +
                       '<"row"<"col-sm-5"i><"col-sm-7"p>>',
                "order": [[0, "desc"]],
                "columnDefs": [
                    {
                        "targets": [7], // Cột thao tác
                        "orderable": false,
                        "searchable": false
                    }
                ]
            });
        });

        // Hàm refresh bảng sau khi thao tác
        function refreshTable() {
            if (usersTable) {
                usersTable.draw();
            }
        }

        function getRoleLabel(role) {
            var roleLabels = {
                'admin': '<span class="label label-danger">Quản trị viên</span>',
                'customer_support': '<span class="label label-info">Hỗ trợ khách hàng</span>',
                'technical_staff': '<span class="label label-primary">Nhân viên kỹ thuật</span>',
                'head_technician': '<span class="label label-warning">Trưởng phòng kỹ thuật</span>',
                'storekeeper': '<span class="label label-success">Thủ kho</span>',
                'customer': '<span class="label label-default">Khách hàng</span>',
                'guest': '<span class="label label-default">Khách</span>'
            };
            return roleLabels[role] || '<span class="label label-default">' + role + '</span>';
        }

        function getStatusLabel(isActive) {
            if (isActive) {
                return '<span class="label label-success">Hoạt động</span>';
            } else {
                return '<span class="label label-warning">Tạm khóa</span>';
            }
        }

        function formatDate(dateString) {
            if (!dateString) return '-';
            var date = new Date(dateString);
            return date.toLocaleDateString('vi-VN') + ' ' + date.toLocaleTimeString('vi-VN');
        }

        function viewUser(id) {
            $.ajax({
                url: 'api/users?action=get&id=' + id,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        var user = response.data;
                        populateUserDetail(user);
                        $('#userDetailModal').modal('show');
                    } else {
                        showAlert('Không thể tải thông tin người dùng: ' + response.message, 'danger');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', xhr.responseText);
                    showAlert('Lỗi kết nối đến server: ' + error, 'danger');
                }
            });
        }

        function populateUserDetail(user) {
            document.getElementById('detailUserId').textContent = user.id;
            document.getElementById('detailUsername').textContent = user.username;
            document.getElementById('detailEmail').textContent = user.email;
            document.getElementById('detailFullName').textContent = user.fullName;
            document.getElementById('detailPhone').textContent = user.phone || '-';
            document.getElementById('detailRole').innerHTML = getRoleLabel(user.role);
            document.getElementById('detailPermissions').textContent = user.permissions || '[]';
            document.getElementById('detailStatus').innerHTML = getStatusLabel(user.isActive);
            document.getElementById('detailCreatedAt').textContent = formatDate(user.createdAt);
            document.getElementById('detailUpdatedAt').textContent = formatDate(user.updatedAt);
        }

        function editUser(id) {
            $.ajax({
                url: 'api/users?action=get&id=' + id,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        var user = response.data;
                        populateEditForm(user);
                        currentEditingUser = user;
                        $('#addUserModal').modal('show');
                        $('#addUserModalLabel').text('Chỉnh sửa người dùng');
                    } else {
                        showAlert('Không thể tải thông tin người dùng: ' + response.message, 'danger');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', xhr.responseText);
                    showAlert('Lỗi kết nối đến server: ' + error, 'danger');
                }
            });
        }

        function populateEditForm(user) {
            document.getElementById('username').value = user.username;
            document.getElementById('email').value = user.email;
            document.getElementById('password').value = ''; // Don't show password
            document.getElementById('password').required = false; // Not required for edit
            document.getElementById('fullName').value = user.fullName;
            document.getElementById('phone').value = user.phone || '';
            document.getElementById('role').value = user.role;
            document.getElementById('permissions').value = user.permissions || '[]';
            document.getElementById('isActive').checked = user.isActive;
        }

        function changePasswordUser(id) {
            currentPasswordUserId = id;
            $('#changePasswordModal').modal('show');
        }

        function changePassword() {
            var newPassword = document.getElementById('newPassword').value;
            var confirmPassword = document.getElementById('confirmPassword').value;

            if (!newPassword || !confirmPassword) {
                showAlert('Vui lòng điền đầy đủ thông tin', 'warning');
                return;
            }

            if (newPassword !== confirmPassword) {
                showAlert('Mật khẩu xác nhận không khớp', 'warning');
                return;
            }

            $.ajax({
                url: 'api/users',
                type: 'POST',
                data: {
                    action: 'changePassword',
                    id: currentPasswordUserId,
                    newPassword: newPassword
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        showAlert('Đã đổi mật khẩu thành công', 'success');
                        $('#changePasswordModal').modal('hide');
                        document.getElementById('changePasswordForm').reset();
                        currentPasswordUserId = null;
                    } else {
                        showAlert('Lỗi: ' + response.message, 'danger');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', xhr.responseText);
                    showAlert('Lỗi kết nối đến server: ' + error, 'danger');
                }
            });
        }

        function deleteUser(id) {
            if (confirm('Bạn có chắc chắn muốn tạm khóa người dùng này?\n\nLưu ý: Đây là xóa mềm, người dùng sẽ bị tạm khóa nhưng dữ liệu vẫn được giữ lại.')) {
                $.ajax({
                    url: 'api/users',
                    type: 'POST',
                    data: {
                        action: 'delete',
                        id: id
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            showAlert('Đã tạm khóa người dùng thành công', 'success');
                            location.reload(); // Reload trang để cập nhật dữ liệu
                        } else {
                            showAlert('Lỗi khi tạm khóa người dùng: ' + response.message, 'danger');
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('AJAX Error:', xhr.responseText);
                        showAlert('Lỗi kết nối đến server: ' + error, 'danger');
                    }
                });
            }
        }

        function hardDeleteUser(id) {
            if (confirm('⚠️ CẢNH BÁO: Bạn có chắc chắn muốn XÓA VĨNH VIỄN người dùng này?\n\n' +
                       'Hành động này KHÔNG THỂ HOÀN TÁC!\n' +
                       'Tất cả dữ liệu liên quan đến người dùng này sẽ bị xóa vĩnh viễn.\n\n' +
                       'Nhập "XÓA" để xác nhận:')) {
                
                var confirmation = prompt('Nhập "XÓA" để xác nhận xóa vĩnh viễn:');
                if (confirmation === 'XÓA') {
                    $.ajax({
                        url: 'api/users',
                        type: 'POST',
                        data: {
                            action: 'hardDelete',
                            id: id
                        },
                        dataType: 'json',
                        success: function(response) {
                            if (response.success) {
                                showAlert('Đã xóa vĩnh viễn người dùng thành công', 'success');
                                location.reload(); // Reload trang để cập nhật dữ liệu
                            } else {
                                showAlert('Lỗi khi xóa vĩnh viễn người dùng: ' + response.message, 'danger');
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error('AJAX Error:', xhr.responseText);
                            showAlert('Lỗi kết nối đến server: ' + error, 'danger');
                        }
                    });
                } else {
                    showAlert('Hủy bỏ xóa vĩnh viễn', 'info');
                }
            }
        }

        function deactivateUser(id) {
            if (confirm('Bạn có chắc chắn muốn tạm khóa người dùng này?')) {
                $.ajax({
                    url: 'api/users',
                    type: 'POST',
                    data: {
                        action: 'deactivate',
                        id: id
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            showAlert('Đã tạm khóa người dùng thành công', 'success');
                            location.reload(); // Reload trang để cập nhật dữ liệu
                        } else {
                            showAlert('Lỗi khi tạm khóa người dùng: ' + response.message, 'danger');
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('AJAX Error:', xhr.responseText);
                        showAlert('Lỗi kết nối đến server: ' + error, 'danger');
                    }
                });
            }
        }

        function activateUser(id) {
            if (confirm('Bạn có chắc chắn muốn kích hoạt người dùng này?')) {
                $.ajax({
                    url: 'api/users',
                    type: 'POST',
                    data: {
                        action: 'activate',
                        id: id
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            showAlert('Đã kích hoạt người dùng thành công', 'success');
                            location.reload(); // Reload trang để cập nhật dữ liệu
                        } else {
                            showAlert('Lỗi khi kích hoạt người dùng: ' + response.message, 'danger');
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('AJAX Error:', xhr.responseText);
                        showAlert('Lỗi kết nối đến server: ' + error, 'danger');
                    }
                });
            }
        }

        function saveUser() {
            var username = document.getElementById('username').value;
            var email = document.getElementById('email').value;
            var password = document.getElementById('password').value;
            var fullName = document.getElementById('fullName').value;
            var phone = document.getElementById('phone').value;
            var role = document.getElementById('role').value;
            var permissions = document.getElementById('permissions').value;
            var isActive = document.getElementById('isActive').checked;

            if (!username || !email || !fullName || !role) {
                showAlert('Vui lòng điền đầy đủ thông tin bắt buộc', 'warning');
                return;
            }

            // For new user, password is required
            if (!currentEditingUser && !password) {
                showAlert('Mật khẩu là bắt buộc cho người dùng mới', 'warning');
                return;
            }

            var formData = {
                username: username,
                email: email,
                fullName: fullName,
                phone: phone,
                role: role,
                permissions: permissions || '[]',
                isActive: isActive
            };

            // Only include password for new users
            if (!currentEditingUser) {
                formData.password = password;
                // Đảm bảo tài khoản mới được kích hoạt để có thể đăng nhập ngay
                formData.isActive = true;
            }

            var url = 'api/users';
            var action = currentEditingUser ? 'update' : 'add';
            formData.action = action;
            
            if (currentEditingUser) {
                formData.id = currentEditingUser.id;
            }

            $.ajax({
                url: url,
                type: 'POST',
                data: formData,
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        if (!currentEditingUser) {
                            showAlert('Tạo người dùng thành công! Tài khoản đã được kích hoạt và có thể đăng nhập ngay lập tức.', 'success');
                        } else {
                            showAlert(response.message, 'success');
                        }
                        $('#addUserModal').modal('hide');
                        document.getElementById('addUserForm').reset();
                        currentEditingUser = null;
                        $('#addUserModalLabel').text('Thêm người dùng mới');
                        location.reload(); // Reload trang để cập nhật dữ liệu
                    } else {
                        showAlert('Lỗi: ' + response.message, 'danger');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', xhr.responseText);
                    showAlert('Lỗi kết nối đến server: ' + error, 'danger');
                }
            });
        }

        function showAlert(message, type) {
            
            var alertClass = 'alert-' + type;
            var alertHtml = '<div class="alert ' + alertClass + ' alert-dismissible fade in" role="alert">' +
                           '<button type="button" class="close" data-dismiss="alert" aria-label="Close">' +
                           '<span aria-hidden="true">&times;</span></button>' +
                           message + '</div>';
            
            // Remove existing alerts
            $('.alert').remove();
            
            // Try to find the best container for the alert
            var container = $('.content');
            if (container.length === 0) {
                container = $('.panel');
            }
            if (container.length === 0) {
                container = $('body');
            }
            
            
            // Add new alert
            container.prepend(alertHtml);
            
            // Auto remove after 3 seconds
            setTimeout(function() {
                $('.alert').fadeOut(500, function() {
                    $(this).remove();
                });
            }, 5000);
        }

        // Reset form when modal is closed
        $('#addUserModal').on('hidden.bs.modal', function() {
            document.getElementById('addUserForm').reset();
            document.getElementById('password').required = true; // Reset password requirement
            currentEditingUser = null;
            $('#addUserModalLabel').text('Thêm người dùng mới');
        });

        // Reset password form when modal is closed
        $('#changePasswordModal').on('hidden.bs.modal', function() {
            document.getElementById('changePasswordForm').reset();
            currentPasswordUserId = null;
        });

    </script>
</body>
</html>