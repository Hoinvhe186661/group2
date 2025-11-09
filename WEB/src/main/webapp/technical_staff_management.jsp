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
    <title>Quản Lý Nhân Viên Kỹ Thuật | HL Generator</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <!-- bootstrap 3.0.2 -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- font Awesome -->
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Ionicons -->
    <link href="css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="css/style.css" rel="stylesheet" type="text/css" />

    <style>
        .staff-card {
            border: 1px solid #ddd;
            border-radius: 8px;
            margin-bottom: 20px;
            background: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .staff-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 20px;
            border-radius: 8px 8px 0 0;
        }
        
        .staff-header h4 {
            margin: 0;
            font-weight: 600;
        }
        
        .staff-info {
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
        }
        
        .staff-stats {
            display: flex;
            gap: 20px;
            padding: 15px 20px;
            background: #f9f9f9;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-item .number {
            font-size: 24px;
            font-weight: bold;
            color: #667eea;
        }
        
        .stat-item .label {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
        }
        
        .tasks-table {
            margin: 0;
        }
        
        .tasks-table th {
            background: #f5f5f5;
            font-weight: 600;
            font-size: 12px;
            padding: 8px;
        }
        
        .tasks-table td {
            font-size: 12px;
            padding: 8px;
            vertical-align: middle;
        }
        
        .badge {
            padding: 4px 10px;
            font-size: 11px;
            font-weight: 600;
            border-radius: 12px;
        }
        
        .badge-urgent { background-color: #d9534f !important; }
        .badge-high { background-color: #f0ad4e !important; }
        .badge-medium { background-color: #5bc0de !important; }
        .badge-low { background-color: #5cb85c !important; }
        
        .badge-pending { background-color: #f0ad4e !important; }
        .badge-in_progress { background-color: #5bc0de !important; }
        .badge-completed { background-color: #5cb85c !important; }
        .badge-rejected { background-color: #d9534f !important; }
        .badge-cancelled { background-color: #777 !important; }
        
        .filter-section {
            background: white;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .no-tasks {
            padding: 20px;
            text-align: center;
            color: #999;
            font-style: italic;
        }
    </style>
</head>
<body class="skin-black">
    <!-- header logo -->
    <header class="header">
        <a href="headtech.jsp" class="logo">
            Quản Lý Nhân Viên Kỹ Thuật
        </a>
        <!-- Header Navbar -->
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
                    <!-- User Account -->
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
                            <i class="fa fa-ticket"></i> <span>Yêu cầu hỗ trợ kỹ thuật</span>
                        </a>
                    </li>
                    <li>
                        <a href="work_orders.jsp">
                            <i class="fa fa-file-text-o"></i> <span>Đơn hàng công việc</span>
                        </a>
                    </li>
                    <li class="active">
                        <a href="technical_staff_management.jsp">
                            <i class="fa fa-users"></i> <span>Quản lý nhân viên kỹ thuật</span>
                        </a>
                    </li>
                </ul>
            </section>
            <!-- /.sidebar -->
        </aside>

        <aside class="right-side">
            <section class="content-header">
                <h1>
                    Quản Lý Nhân Viên Kỹ Thuật
                    <small>Xem công việc của từng nhân viên</small>
                </h1>
                <ol class="breadcrumb">
                    <li><a href="headtech.jsp"><i class="fa fa-dashboard"></i> Trang chủ</a></li>
                    <li class="active">Quản lý nhân viên kỹ thuật</li>
                </ol>
            </section>

            <section class="content">
                <!-- Filter Section -->
                <div class="filter-section">
                    <div class="row">
                        <div class="col-md-3">
                            <div class="form-group">
                                <label>Lọc theo trạng thái:</label>
                                <select class="form-control" id="filterStatus">
                                    <option value="">Tất cả</option>
                                    <option value="pending">Chờ xử lý</option>
                                    <option value="in_progress">Đang thực hiện</option>
                                    <option value="completed">Hoàn thành</option>
                                    <option value="rejected">Đã từ chối</option>
                                    <option value="cancelled">Đã hủy</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group">
                                <label>Lọc theo độ ưu tiên:</label>
                                <select class="form-control" id="filterPriority">
                                    <option value="">Tất cả</option>
                                    <option value="urgent">Khẩn cấp</option>
                                    <option value="high">Cao</option>
                                    <option value="medium">Trung bình</option>
                                    <option value="low">Thấp</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group">
                                <label>Tìm kiếm:</label>
                                <input type="text" class="form-control" id="searchInput" placeholder="Tìm theo tên nhân viên, mã công việc...">
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group">
                                <label>&nbsp;</label>
                                <button class="btn btn-primary btn-block" id="btnApplyFilter">
                                    <i class="fa fa-filter"></i> Áp dụng bộ lọc
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Staff List -->
                <div id="staffListContainer">
                    <div class="text-center" style="padding: 40px;">
                        <i class="fa fa-spinner fa-spin fa-3x"></i>
                        <p>Đang tải dữ liệu...</p>
                    </div>
                </div>
            </section>
        </aside>
    </div>

    <!-- jQuery -->
    <script src="js/jquery.min.js"></script>
    <!-- Bootstrap -->
    <script src="js/bootstrap.min.js"></script>
    <!-- AdminLTE App -->
    <script src="js/AdminLTE/app.js"></script>

    <script>
        var ctx = '<%= request.getContextPath() %>';

        $(document).ready(function() {
            loadStaffData();
            
            $('#btnApplyFilter').click(function() {
                loadStaffData();
            });
            
            $('#searchInput').on('keypress', function(e) {
                if (e.which === 13) {
                    loadStaffData();
                }
            });
        });

        function loadStaffData() {
            // Get filter values
            var status = $('#filterStatus').val();
            var priority = $('#filterPriority').val();
            var search = $('#searchInput').val();
            
            // Build URL with parameters
            var url = ctx + '/api/technical-staff-management?action=list';
            if (status) {
                url += '&status=' + encodeURIComponent(status);
            }
            if (priority) {
                url += '&priority=' + encodeURIComponent(priority);
            }
            if (search) {
                url += '&search=' + encodeURIComponent(search);
            }
            
            // Show loading
            $('#staffListContainer').html('<div class="text-center" style="padding: 40px;"><i class="fa fa-spinner fa-spin fa-3x"></i><p>Đang tải dữ liệu...</p></div>');
            
            $.ajax({
                url: url,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response && response.success) {
                        var staffData = response.data || [];
                        renderStaffList(staffData);
                    } else {
                        $('#staffListContainer').html('<div class="alert alert-danger">Không thể tải dữ liệu: ' + (response.message || 'Lỗi không xác định') + '</div>');
                    }
                },
                error: function() {
                    $('#staffListContainer').html('<div class="alert alert-danger">Lỗi kết nối máy chủ</div>');
                }
            });
        }

        function renderStaffList(staffData) {
            var container = $('#staffListContainer');
            container.empty();
            
            if (staffData.length === 0) {
                container.html('<div class="alert alert-info">Không tìm thấy nhân viên nào</div>');
                return;
            }
            
            staffData.forEach(function(staff) {
                var staffCard = createStaffCard(staff);
                container.append(staffCard);
            });
        }

        function createStaffCard(staff) {
            var pendingCount = staff.tasks.filter(t => t.status === 'pending').length;
            var inProgressCount = staff.tasks.filter(t => t.status === 'in_progress').length;
            var completedCount = staff.tasks.filter(t => t.status === 'completed').length;
            var totalCount = staff.tasks.length;
            
            var card = $('<div class="staff-card"></div>');
            
            // Header
            var header = $('<div class="staff-header"></div>');
            header.append('<h4><i class="fa fa-user"></i> ' + (staff.fullName || 'N/A') + '</h4>');
            header.append('<small><i class="fa fa-envelope"></i> ' + (staff.email || 'N/A') + '</small>');
            card.append(header);
            
            // Info
            var info = $('<div class="staff-info"></div>');
            info.append('<p><strong>ID:</strong> ' + staff.id + ' | <strong>Vai trò:</strong> ' + (staff.role || 'technical_staff') + '</p>');
            card.append(info);
            
            // Stats
            var stats = $('<div class="staff-stats"></div>');
            stats.append('<div class="stat-item"><div class="number">' + totalCount + '</div><div class="label">Tổng công việc</div></div>');
            stats.append('<div class="stat-item"><div class="number" style="color: #f0ad4e;">' + pendingCount + '</div><div class="label">Chờ xử lý</div></div>');
            stats.append('<div class="stat-item"><div class="number" style="color: #5bc0de;">' + inProgressCount + '</div><div class="label">Đang thực hiện</div></div>');
            stats.append('<div class="stat-item"><div class="number" style="color: #5cb85c;">' + completedCount + '</div><div class="label">Hoàn thành</div></div>');
            card.append(stats);
            
            // Tasks Table
            if (staff.tasks.length > 0) {
                var tableContainer = $('<div style="padding: 15px 20px;"></div>');
                var table = $('<table class="table table-bordered table-hover tasks-table"></table>');
                
                var thead = $('<thead></thead>');
                thead.append('<tr>' +
                    '<th style="width: 80px;">Mã Task</th>' +
                    '<th>Mô tả</th>' +
                    '<th style="width: 100px;">Work Order</th>' +
                    '<th style="width: 90px;">Độ ưu tiên</th>' +
                    '<th style="width: 90px;">Trạng thái</th>' +
                    '<th style="width: 100px;">Giờ ước tính</th>' +
                    '<th style="width: 120px;">Ngày giao</th>' +
                    '<th style="width: 120px;">Deadline</th>' +
                    '<th style="width: 120px;">Ngày hoàn thành</th>' +
                '</tr>');
                table.append(thead);
                
                var tbody = $('<tbody></tbody>');
                staff.tasks.forEach(function(task) {
                    // Format ngày hoàn thành
                    var completionDateDisplay = '-';
                    if (task.completionDate) {
                        completionDateDisplay = formatDate(task.completionDate);
                        // Nếu task đã hoàn thành, hiển thị màu xanh
                        if (task.status === 'completed') {
                            completionDateDisplay = '<span class="text-success" style="font-weight: bold;"><i class="fa fa-check-circle"></i> ' + completionDateDisplay + '</span>';
                        }
                    }
                    
                    var row = $('<tr></tr>');
                    row.append('<td><strong>' + (task.taskNumber || 'N/A') + '</strong></td>');
                    row.append('<td>' + (task.taskDescription || '') + '</td>');
                    row.append('<td>' + (task.workOrderNumber || 'N/A') + '</td>');
                    row.append('<td>' + getPriorityBadge(task.priority) + '</td>');
                    row.append('<td>' + getStatusBadge(task.status) + '</td>');
                    row.append('<td class="text-center">' + (task.estimatedHours ? parseFloat(task.estimatedHours).toFixed(1) + 'h' : '-') + '</td>');
                    row.append('<td class="text-center">' + formatDate(task.startDate) + '</td>');
                    row.append('<td class="text-center">' + formatDate(task.deadline) + '</td>');
                    row.append('<td class="text-center">' + completionDateDisplay + '</td>');
                    tbody.append(row);
                });
                table.append(tbody);
                tableContainer.append(table);
                card.append(tableContainer);
            } else {
                card.append('<div class="no-tasks">Chưa có công việc nào được giao</div>');
            }
            
            return card;
        }

        function getPriorityBadge(priority) {
            if (!priority) return '<span class="badge">N/A</span>';
            var labels = {
                'urgent': 'Khẩn cấp',
                'high': 'Cao',
                'medium': 'Trung bình',
                'low': 'Thấp'
            };
            return '<span class="badge badge-' + priority + '">' + (labels[priority] || priority) + '</span>';
        }

        function getStatusBadge(status) {
            if (!status) return '<span class="badge">N/A</span>';
            var labels = {
                'pending': 'Chờ xử lý',
                'in_progress': 'Đang thực hiện',
                'completed': 'Hoàn thành',
                'rejected': 'Đã từ chối',
                'cancelled': 'Đã hủy'
            };
            return '<span class="badge badge-' + status + '">' + (labels[status] || status) + '</span>';
        }

        function formatDate(dateStr) {
            if (!dateStr) return '-';
            try {
                var date = new Date(dateStr);
                var day = String(date.getDate()).padStart(2, '0');
                var month = String(date.getMonth() + 1).padStart(2, '0');
                var year = date.getFullYear();
                return day + '/' + month + '/' + year;
            } catch(e) {
                return '-';
            }
        }
    </script>
</body>
</html>

