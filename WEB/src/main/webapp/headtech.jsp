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
    
    // CHỈ CHO PHÉP HEAD_TECHNICIAN (không cho admin vào)
    if (!"head_technician".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/403.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng Điều Khiển Kỹ Thuật | HL Generator</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <meta name="description" content="Technical Dashboard">
    <meta name="keywords" content="Technical, Dashboard, Bootstrap 3">
    
    <!-- bootstrap 3.0.2 -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- font Awesome -->
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Ionicons -->
    <link href="css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <!-- Morris chart -->
    <link href="css/morris/morris.css" rel="stylesheet" type="text/css" />
    <!-- jvectormap -->
    <link href="css/jvectormap/jquery-jvectormap-1.2.2.css" rel="stylesheet" type="text/css" />
    <!-- Date Picker -->
    <link href="css/datepicker/datepicker3.css" rel="stylesheet" type="text/css" />
    <!-- Daterange picker -->
    <link href="css/daterangepicker/daterangepicker-bs3.css" rel="stylesheet" type="text/css" />
    <!-- iCheck for checkboxes and radio inputs -->
    <link href="css/iCheck/all.css" rel="stylesheet" type="text/css" />
    <link href='http://fonts.googleapis.com/css?family=Lato' rel='stylesheet' type='text/css'>
    <!-- Theme style -->
    <link href="css/style.css" rel="stylesheet" type="text/css" />

    <!-- Custom styles -->
    <style>
        .st-orange { background-color: #ff9800 !important; }
        .st-purple { background-color: #9c27b0 !important; }
        .st-cyan { background-color: #00bcd4 !important; }
        .st-pink { background-color: #e91e63 !important; }
        .st-teal { background-color: #009688 !important; }
        .st-indigo { background-color: #3f51b5 !important; }
    </style>

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
</head>
<body class="skin-black">
    <!-- header logo -->
    <header class="header">
        <a href="headtech.jsp" class="logo">
            Bảng Điều Khiển Kỹ Thuật
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
                    <!-- Notifications -->
                    <li class="dropdown messages-menu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="fa fa-bell"></i>
                            <span class="label label-warning" id="notificationCount">0</span>
                        </a>
                        <ul class="dropdown-menu">
                            <li class="header">Thông báo công việc</li>
                            <li>
                                <ul class="menu" id="notificationList">
                                    <li>
                                        <a href="#">
                                            <div class="pull-left">
                                                <i class="fa fa-warning text-yellow"></i>
                                            </div>
                                            <h4>Công việc ưu tiên cao</h4>
                                            <p>Có <span id="urgentWorkOrders">0</span> công việc cần xử lý gấp</p>
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            <li class="footer"><a href="tech_support_management.jsp">Xem tất cả</a></li>
                        </ul>
                    </li>
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
		<jsp:include page="partials/sidebar.jsp"/>

        <aside class="right-side">
            <!-- Main content -->
            <section class="content">
                <!-- Top Statistics Row 1 -->
                <div class="row" style="margin-bottom:5px;">
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-blue"><i class="fa fa-file-text-o"></i></span>
                            <div class="sm-st-info">
                                <span id="totalWorkOrders">0</span>
                                Tổng đơn hàng
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-violet"><i class="fa fa-clock-o"></i></span>
                            <div class="sm-st-info">
                                <span id="pendingWorkOrders">0</span>
                                Chờ xử lý
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-orange"><i class="fa fa-spinner"></i></span>
                            <div class="sm-st-info">
                                <span id="inProgressWorkOrders">0</span>
                                Đang thực hiện
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-green"><i class="fa fa-check-circle-o"></i></span>
                            <div class="sm-st-info">
                                <span id="completedWorkOrders">0</span>
                                Hoàn thành
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Top Statistics Row 2 -->
                <div class="row" style="margin-bottom:5px;">
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-red"><i class="fa fa-ticket"></i></span>
                            <div class="sm-st-info">
                                <span id="techTicketsCount">0</span>
                                Ticket kỹ thuật
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-purple"><i class="fa fa-users"></i></span>
                            <div class="sm-st-info">
                                <span id="techStaffCount">0</span>
                                Nhân viên kỹ thuật
                            </div>
                            </div>
                                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-pink"><i class="fa fa-exclamation-triangle"></i></span>
                            <div class="sm-st-info">
                                <span id="urgentCount">0</span>
                                Ưu tiên cao
                                    </div>
                                    </div>
                                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-cyan"><i class="fa fa-clock-o"></i></span>
                            <div class="sm-st-info">
                                <span id="totalHours">0</span>
                                Tổng giờ ước tính
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Main row -->
                <div class="row">
                    <div class="col-md-8">
                        <!--work orders chart start-->
                        <section class="panel">
                            <header class="panel-heading">
                                Biểu đồ công việc kỹ thuật
                            </header>
                            <div class="panel-body">
                                <canvas id="workOrdersChart" width="600" height="330"></canvas>
                            </div>
                        </section>
                        <!--work orders chart end-->
                    </div>
                    <div class="col-lg-4">
                        <!--notifications start-->
                        <section class="panel">
                            <header class="panel-heading">
                                Cảnh báo & Thông báo
                            </header>
                            <div class="panel-body" id="noti-box">
                                <div class="alert alert-block alert-danger">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Khẩn cấp!</strong> Có <span id="urgentAlert">0</span> công việc ưu tiên cao cần xử lý ngay.
                                </div>
                                <div class="alert alert-warning">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Chú ý!</strong> Có <span id="overdueAlert">0</span> công việc quá hạn.
                                </div>
                                <div class="alert alert-info">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Thông tin!</strong> Có <span id="newTicketsAlert">0</span> ticket mới cần phân công.
                                </div>
                                <div class="alert alert-success">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Tốt!</strong> Đã hoàn thành <span id="completedTodayAlert">0</span> công việc hôm nay.
                                </div>
                            </div>
                        </section>
                                </div>
                            </div>
                
                <div class="row">
                    <div class="col-md-8">
                        <section class="panel">
                            <header class="panel-heading">
                                Đơn hàng công việc gần đây
                            </header>
                            <div class="panel-body table-responsive">
                                <table class="table table-hover" id="recentWorkOrdersTable">
                                    <thead>
                                        <tr>
                                            <th>Mã đơn</th>
                                            <th>Khách hàng</th>
                                            <th>Tiêu đề</th>
                                            <th>Độ ưu tiên</th>
                                            <th>Trạng thái</th>
                                            <th>Phân công</th>
                                        </tr>
                                    </thead>
                                    <tbody id="recentWorkOrdersBody">
                                        <tr>
                                            <td colspan="6" class="text-center">Đang tải dữ liệu...</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </section>
                        </div>
                    <div class="col-md-4">
                        <section class="panel">
                            <header class="panel-heading">
                                Nhân viên kỹ thuật
                            </header>
                            <div class="panel-body">
                                <ul class="list-group" id="techStaffList">
                                    <li class="list-group-item">
                                        <span class="badge">0</span>
                                        Đang tải...
                                    </li>
                                </ul>
                </div>
            </section>
                            </div>
                        </div>
            </section><!-- /.content -->
            <div class="footer-main">
                Copyright &copy Bảng điều khiển kỹ thuật - HL Generator, 2025
                            </div>
        </aside><!-- /.right-side -->
    </div><!-- ./wrapper -->

    <!-- jQuery 2.0.2 -->
    <script src="js/jquery.min.js" type="text/javascript"></script>
    <!-- jQuery UI 1.10.3 -->
    <script src="js/jquery-ui-1.10.3.min.js" type="text/javascript"></script>
    <!-- Bootstrap -->
    <script src="js/bootstrap.min.js" type="text/javascript"></script>
    <!-- daterangepicker -->
    <script src="js/plugins/daterangepicker/daterangepicker.js" type="text/javascript"></script>
    <script src="js/plugins/chart.js" type="text/javascript"></script>
    <!-- iCheck -->
    <script src="js/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
    <!-- Director App -->
    <script src="js/Director/app.js" type="text/javascript"></script>

    <script>
        var ctx = '<%= request.getContextPath() %>';
        var allWorkOrders = [];
        var technicalStaff = [];
        
        $(document).ready(function() {
            // Load all dashboard data
            loadWorkOrders();
            loadTechnicalStaff();
            loadTechTickets();
            
            // Initialize slimScroll for notifications
            $('#noti-box').slimScroll({
                height: '400px',
                size: '5px',
                BorderRadius: '5px'
            });
        });
        
        // Load Work Orders
        function loadWorkOrders() {
            $.ajax({
                url: ctx + '/api/work-orders?action=list',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        allWorkOrders = response.data || [];
                        updateWorkOrderStatistics();
                        renderRecentWorkOrders();
                        renderWorkOrdersChart();
                    }
                },
                error: function() {
                    console.log('Không thể tải dữ liệu work orders');
                }
            });
        }
        
        // Update Work Order Statistics
        function updateWorkOrderStatistics() {
            var total = allWorkOrders.length;
            var pending = allWorkOrders.filter(w => w.status === 'pending').length;
            var inProgress = allWorkOrders.filter(w => w.status === 'in_progress').length;
            var completed = allWorkOrders.filter(w => w.status === 'completed').length;
            var urgent = allWorkOrders.filter(w => w.priority === 'urgent' || w.priority === 'high').length;
            
            // Calculate total estimated hours
            var totalHours = 0;
            allWorkOrders.forEach(function(w) {
                if(w.estimatedHours) {
                    totalHours += parseFloat(w.estimatedHours);
                }
            });
            
            $('#totalWorkOrders').text(total);
            $('#pendingWorkOrders').text(pending);
            $('#inProgressWorkOrders').text(inProgress);
            $('#completedWorkOrders').text(completed);
            $('#urgentCount').text(urgent);
            $('#totalHours').text(totalHours.toFixed(1) + 'h');
            
            // Update alerts
            $('#urgentAlert').text(urgent);
            $('#urgentWorkOrders').text(urgent);
            $('#notificationCount').text(urgent);
            
            // Calculate completed today (mock data for now)
            var today = new Date().toISOString().split('T')[0];
            var completedToday = allWorkOrders.filter(w => 
                w.status === 'completed' && 
                w.completionDate && 
                w.completionDate.includes(today)
            ).length;
            $('#completedTodayAlert').text(completedToday);
        }
        
        // Render Recent Work Orders Table
        function renderRecentWorkOrders() {
            var tbody = $('#recentWorkOrdersBody');
            tbody.empty();
            
            if(!allWorkOrders || allWorkOrders.length === 0) {
                tbody.append('<tr><td colspan="6" class="text-center">Không có dữ liệu</td></tr>');
                return;
            }
            
            // Get latest 10 work orders
            var recentOrders = allWorkOrders.slice(0, 10);
            
            recentOrders.forEach(function(wo) {
                var row = '<tr>' +
                    '<td>' + (wo.workOrderNumber || '#' + wo.id) + '</td>' +
                    '<td>' + (wo.customerName || 'N/A') + '</td>' +
                    '<td>' + (wo.title || '') + '</td>' +
                    '<td>' + getPriorityBadge(wo.priority) + '</td>' +
                    '<td>' + getStatusBadge(wo.status) + '</td>' +
                    '<td>' + (wo.assignedToName || 'Chưa phân công') + '</td>' +
                '</tr>';
                tbody.append(row);
            });
        }
        
        // Load Technical Staff
        function loadTechnicalStaff() {
            $.ajax({
                url: ctx + '/api/users?role=technical_staff',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if(response && response.success) {
                        technicalStaff = response.data || [];
                        $('#techStaffCount').text(technicalStaff.length);
                        renderTechnicalStaffList();
                    }
                },
                error: function() {
                    console.log('Không thể tải danh sách nhân viên kỹ thuật');
                }
            });
        }
        
        // Render Technical Staff List
        function renderTechnicalStaffList() {
            var list = $('#techStaffList');
            list.empty();
            
            if(!technicalStaff || technicalStaff.length === 0) {
                list.append('<li class="list-group-item">Không có nhân viên</li>');
                return;
            }
            
            technicalStaff.forEach(function(staff) {
                // Count assigned work orders
                var assignedCount = allWorkOrders.filter(w => 
                    w.assignedTo == staff.id && 
                    (w.status === 'pending' || w.status === 'in_progress')
                ).length;
                
                list.append(
                    '<li class="list-group-item">' +
                        '<span class="badge">' + assignedCount + '</span>' +
                        staff.fullName +
                    '</li>'
                );
            });
        }
        
        // Load Tech Tickets
        function loadTechTickets() {
            $.ajax({
                url: ctx + '/api/tech-support?action=stats',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if(response && response.success && response.data) {
                        var openTickets = (response.data.open || 0) + (response.data.inProgress || 0);
                        var newTickets = response.data.open || 0;
                        $('#techTicketsCount').text(openTickets);
                        $('#newTicketsAlert').text(newTickets);
                    }
                },
                error: function() {
                    console.log('Không thể tải thống kê tickets');
                }
            });
        }
        
        // Render Work Orders Chart
        function renderWorkOrdersChart() {
            var statusData = {
                pending: allWorkOrders.filter(w => w.status === 'pending').length,
                inProgress: allWorkOrders.filter(w => w.status === 'in_progress').length,
                completed: allWorkOrders.filter(w => w.status === 'completed').length,
                cancelled: allWorkOrders.filter(w => w.status === 'cancelled').length
            };
            
            var data = {
                labels: ["Chờ xử lý", "Đang thực hiện", "Hoàn thành", "Đã hủy"],
                datasets: [
                    {
                        label: "Trạng thái công việc",
                        fillColor: "rgba(151,187,205,0.2)",
                        strokeColor: "rgba(151,187,205,1)",
                        pointColor: "rgba(151,187,205,1)",
                        pointStrokeColor: "#fff",
                        pointHighlightFill: "#fff",
                        pointHighlightStroke: "rgba(151,187,205,1)",
                        data: [statusData.pending, statusData.inProgress, statusData.completed, statusData.cancelled]
                    }
                ]
            };
            
            new Chart(document.getElementById("workOrdersChart").getContext("2d")).Bar(data, {
                responsive: true,
                maintainAspectRatio: false
            });
        }
        
        // Helper Functions
        function getPriorityBadge(priority) {
            var labels = {
                'urgent': 'Khẩn cấp',
                'high': 'Cao',
                'medium': 'Trung bình',
                'low': 'Thấp'
            };
            var colors = {
                'urgent': 'danger',
                'high': 'warning',
                'medium': 'info',
                'low': 'success'
            };
            return '<span class="label label-' + (colors[priority] || 'default') + '">' + 
                   (labels[priority] || 'N/A') + '</span>';
        }
        
        function getStatusBadge(status) {
            var labels = {
                'pending': 'Chờ xử lý',
                'in_progress': 'Đang thực hiện',
                'completed': 'Hoàn thành',
                'cancelled': 'Đã hủy'
            };
            var colors = {
                'pending': 'warning',
                'in_progress': 'info',
                'completed': 'success',
                'cancelled': 'default'
            };
            return '<span class="label label-' + (colors[status] || 'default') + '">' + 
                   (labels[status] || 'N/A') + '</span>';
        }
    </script>
</body>
</html>

