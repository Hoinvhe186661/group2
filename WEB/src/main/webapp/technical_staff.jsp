<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hlgenerator.util.AuthorizationUtil, com.hlgenerator.util.Permission" %>
<%
    // Kiểm tra đăng nhập
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Kiểm tra quyền sử dụng permission
    if (!AuthorizationUtil.hasPermission(request, Permission.VIEW_TASKS) && 
        !AuthorizationUtil.hasPermission(request, Permission.MANAGE_TASKS)) {
        response.sendRedirect(request.getContextPath() + "/403.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dashboard Nhân viên Kỹ thuật | HL Generator Solutions</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <meta name="description" content="Technical Staff Dashboard for HL Generator Solutions">
    <meta name="keywords" content="Technical, Staff, Dashboard, Generator">
    
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
    
    <!-- Custom styles for technical staff -->
    <style>
        .st-orange { background-color: #ff9800 !important; }
        .st-purple { background-color: #9c27b0 !important; }
        .st-cyan { background-color: #00bcd4 !important; }
        .st-pink { background-color: #e91e63 !important; }
    </style>

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
</head>
<body class="skin-black">
    <!-- header logo: style can be found in header.less -->
    <header class="header">
        <a href="my_tasks.jsp" class="logo">
            Nhân viên Kỹ thuật
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
                    <!-- Messages: style can be found in dropdown.less-->
                    <li class="dropdown messages-menu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="fa fa-envelope"></i>
                            <span class="label label-success">3</span>
                        </a>
                        <ul class="dropdown-menu">
                            <li class="header">Bạn có 3 tin nhắn</li>
                            <li>
                                <!-- inner menu: contains the actual data -->
                                <ul class="menu">
                                    <li><!-- start message -->
                                        <a href="#">
                                            <div class="pull-left">
                                                <img src="img/26115.jpg" class="img-circle" alt="User Image"/>
                                            </div>
                                            <h4>
                                                Nhiệm vụ mới
                                            </h4>
                                            <p>Có nhiệm vụ mới cần xử lý</p>
                                            <small class="pull-right"><i class="fa fa-clock-o"></i> 5 phút</small>
                                        </a>
                                    </li><!-- end message -->
                                    <li>
                                        <a href="#">
                                            <div class="pull-left">
                                                <img src="img/26115.jpg" class="img-circle" alt="user image"/>
                                            </div>
                                            <h4>
                                                Bảo dưỡng định kỳ
                                            </h4>
                                            <p>Nhắc nhở bảo dưỡng máy phát điện</p>
                                            <small class="pull-right"><i class="fa fa-clock-o"></i> 2 giờ</small>
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            <li class="footer"><a href="#">Xem tất cả tin nhắn</a></li>
                        </ul>
                    </li>
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
                <!-- sidebar menu: : style can be found in sidebar.less -->
                <%@ include file="includes/sidebar-menu.jsp" %>
            </section>
            <!-- /.sidebar -->
        </aside>

        <aside class="right-side">
            <!-- Main content -->
            <section class="content">
                <div class="row" style="margin-bottom:5px;">
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-red"><i class="fa fa-tasks"></i></span>
                            <div class="sm-st-info">
                                <span id="totalTasks">0</span>
                                Tổng nhiệm vụ
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-violet"><i class="fa fa-clock-o"></i></span>
                            <div class="sm-st-info">
                                <span id="pendingTasks">0</span>
                                Đang chờ
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-blue"><i class="fa fa-play"></i></span>
                            <div class="sm-st-info">
                                <span id="inProgressTasks">0</span>
                                Đang thực hiện
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-green"><i class="fa fa-check"></i></span>
                            <div class="sm-st-info">
                                <span id="completedTasks">0</span>
                                Hoàn thành
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="row" style="margin-bottom:5px;">
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-orange"><i class="fa fa-cogs"></i></span>
                            <div class="sm-st-info">
                                <span id="maintenanceTasks">0</span>
                                Bảo dưỡng
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-purple"><i class="fa fa-wrench"></i></span>
                            <div class="sm-st-info">
                                <span id="repairTasks">0</span>
                                Sửa chữa
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-cyan"><i class="fa fa-search"></i></span>
                            <div class="sm-st-info">
                                <span id="inspectionTasks">0</span>
                                Kiểm tra
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-pink"><i class="fa fa-calendar"></i></span>
                            <div class="sm-st-info">
                                <span id="urgentTasks">0</span>
                                Khẩn cấp
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Main row -->
                <div class="row">
                    <div class="col-md-8">
                        <!--recent tasks start-->
                        <section class="panel">
                            <header class="panel-heading">
                                Nhiệm vụ gần đây
                            </header>
                            <div class="panel-body table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Mô tả</th>
                                            <th>Trạng thái</th>
                                            <th>Ưu tiên</th>
                                            <th>Ngày tạo</th>
                                            <th>Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody id="recentTasksTable">
                                        <tr>
                                            <td colspan="6" class="text-center text-muted">
                                                <i class="fa fa-spinner fa-spin"></i>
                                                Đang tải dữ liệu...
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </section>
                        <!--recent tasks end-->
                    </div>
                    <div class="col-lg-4">
                        <!--notifications start-->
                        <section class="panel">
                            <header class="panel-heading">
                                Thông báo
                            </header>
                            <div class="panel-body" id="noti-box">
                                <div class="alert alert-block alert-danger">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Cảnh báo!</strong> Nhiệm vụ #123 sắp hết hạn.
                                </div>
                                <div class="alert alert-success">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Thành công!</strong> Nhiệm vụ #120 đã hoàn thành.
                                </div>
                                <div class="alert alert-info">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Thông tin!</strong> Bạn có 2 nhiệm vụ mới.
                                </div>
                                <div class="alert alert-warning">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Chú ý!</strong> Kiểm tra máy phát điện định kỳ.
                                </div>
                            </div>
                        </section>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-8">
                        <section class="panel">
                            <header class="panel-heading">
                                Thống kê tuần
                            </header>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="d-flex justify-content-between mb-2">
                                            <span>Nhiệm vụ hoàn thành:</span>
                                            <strong>8/12</strong>
                                        </div>
                                        <div class="progress mb-3">
                                            <div class="progress-bar bg-success" style="width: 67%"></div>
                                        </div>
                                        <div class="d-flex justify-content-between mb-2">
                                            <span>Giờ làm việc:</span>
                                            <strong>32h</strong>
                                        </div>
                                        <div class="d-flex justify-content-between">
                                            <span>Hiệu suất:</span>
                                            <strong class="text-success">85%</strong>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <canvas id="taskChart" width="200" height="200"></canvas>
                                    </div>
                                </div>
                            </div>
                        </section>
                    </div>
                    <div class="col-md-4">
                        <section class="panel">
                            <header class="panel-heading">
                                Nhiệm vụ theo loại
                            </header>
                            <div class="panel-body">
                                <ul class="list-group">
                                    <li class="list-group-item">
                                        <span class="badge">5</span>
                                        Bảo dưỡng
                                    </li>
                                    <li class="list-group-item">
                                        <span class="badge">3</span>
                                        Sửa chữa
                                    </li>
                                    <li class="list-group-item">
                                        <span class="badge">2</span>
                                        Kiểm tra
                                    </li>
                                    <li class="list-group-item">
                                        <span class="badge">2</span>
                                        Khẩn cấp
                                    </li>
                                </ul>
                            </div>
                        </section>
                    </div>
                </div>
            </section><!-- /.content -->
            <div class="footer-main">
                Copyright &copy Dashboard Nhân viên Kỹ thuật, 2025
            </div>
        </aside><!-- /.right-side -->
    </div><!-- ./wrapper -->

    <!-- jQuery 2.0.2 -->
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
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
    <!-- Director dashboard demo (This is only for demo purposes) -->
    <script src="js/Director/dashboard.js" type="text/javascript"></script>

    <script>
        $('#noti-box').slimScroll({
            height: '400px',
            size: '5px',
            BorderRadius: '5px'
        });
        
        // Load task statistics
        $(document).ready(function() {
            loadTaskStats();
            loadRecentTasks();
        });
        
        function loadTaskStats() {
            // Simulate API call - replace with actual API
            setTimeout(() => {
                $('#totalTasks').text('12');
                $('#pendingTasks').text('3');
                $('#inProgressTasks').text('4');
                $('#completedTasks').text('5');
                $('#maintenanceTasks').text('5');
                $('#repairTasks').text('3');
                $('#inspectionTasks').text('2');
                $('#urgentTasks').text('2');
            }, 1000);
        }

        function loadRecentTasks() {
            // Simulate API call - replace with actual API
            setTimeout(() => {
                const tableBody = $('#recentTasksTable');
                tableBody.html(`
                    <tr>
                        <td>#123</td>
                        <td>Kiểm tra máy phát điện Cummins 100kVA</td>
                        <td><span class="label label-warning">Đang chờ</span></td>
                        <td><span class="label label-danger">Cao</span></td>
                        <td>18/10/2025</td>
                        <td><button class="btn btn-xs btn-primary">Xem</button></td>
                    </tr>
                    <tr>
                        <td>#122</td>
                        <td>Bảo dưỡng máy phát điện Denyo 50kVA</td>
                        <td><span class="label label-info">Đang thực hiện</span></td>
                        <td><span class="label label-warning">Trung bình</span></td>
                        <td>17/10/2025</td>
                        <td><button class="btn btn-xs btn-primary">Xem</button></td>
                    </tr>
                    <tr>
                        <td>#121</td>
                        <td>Thay thế phụ tùng máy phát điện Mitsubishi</td>
                        <td><span class="label label-success">Hoàn thành</span></td>
                        <td><span class="label label-success">Thấp</span></td>
                        <td>16/10/2025</td>
                        <td><button class="btn btn-xs btn-primary">Xem</button></td>
                    </tr>
                `);
            }, 1500);
        }
    </script>
    
    <script type="text/javascript">
        $(function() {
            "use strict";
            //TASK CHART
            var data = {
                labels: ["Bảo dưỡng", "Sửa chữa", "Kiểm tra", "Khẩn cấp"],
                datasets: [
                    {
                        label: "Nhiệm vụ",
                        fillColor: "rgba(220,220,220,0.2)",
                        strokeColor: "rgba(220,220,220,1)",
                        pointColor: "rgba(220,220,220,1)",
                        pointStrokeColor: "#fff",
                        pointHighlightFill: "#fff",
                        pointHighlightStroke: "rgba(220,220,220,1)",
                        data: [5, 3, 2, 2]
                    }
                ]
            };
            new Chart(document.getElementById("taskChart").getContext("2d")).Doughnut(data,{
                responsive : true,
                maintainAspectRatio: false,
            });
        });
    </script>
</body>
</html>
