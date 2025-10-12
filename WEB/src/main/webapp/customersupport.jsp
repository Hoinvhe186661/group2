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
    
    // Kiểm tra quyền customer_support
    if (!"customer_support".equals(userRole) && !"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Hỗ Trợ Khách Hàng | Bảng Điều Khiển</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <meta name="description" content="Customer Support Panel">
    <meta name="keywords" content="Customer Support, Bootstrap 3, Template, Theme, Responsive">
    
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
    
    <!-- Custom styles for support stats -->
    <style>
        .st-orange { background-color: #ff9800 !important; }
        .st-purple { background-color: #9c27b0 !important; }
        .st-cyan { background-color: #00bcd4 !important; }
        .st-pink { background-color: #e91e63 !important; }
        .st-teal { background-color: #009688 !important; }
        .st-indigo { background-color: #3f51b5 !important; }
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
        <a href="customersupport.jsp" class="logo">
            Hỗ Trợ Khách Hàng
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
                            <span class="label label-success" id="unreadMessages">0</span>
                        </a>
                        <ul class="dropdown-menu">
                            <li class="header">Tin nhắn mới</li>
                            <li>
                                <!-- inner menu: contains the actual data -->
                                <ul class="menu">
                                    <li><!-- start message -->
                                        <a href="#">
                                            <div class="pull-left">
                                                <img src="img/26115.jpg" class="img-circle" alt="User Image"/>
                                            </div>
                                            <h4>
                                                Khách hàng ABC
                                            </h4>
                                            <p>Cần hỗ trợ về sản phẩm</p>
                                            <small class="pull-right"><i class="fa fa-clock-o"></i> 5 phút</small>
                                        </a>
                                    </li><!-- end message -->
                                    <li>
                                        <a href="#">
                                            <div class="pull-left">
                                                <img src="img/26115.jpg" class="img-circle" alt="user image"/>
                                            </div>
                                            <h4>
                                                Khách hàng XYZ
                                            </h4>
                                            <p>Hỏi về bảo hành</p>
                                            <small class="pull-right"><i class="fa fa-clock-o"></i> 2 giờ</small>
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            <li class="footer"><a href="support_management.jsp">Xem tất cả tin nhắn</a></li>
                        </ul>
                    </li>
                    <!-- Notifications -->
                    <li class="dropdown notifications-menu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="fa fa-bell"></i>
                            <span class="label label-warning" id="unreadNotifications">0</span>
                        </a>
                        <ul class="dropdown-menu">
                            <li class="header">Thông báo mới</li>
                            <li>
                                <ul class="menu">
                                    <li>
                                        <a href="#">
                                            <i class="fa fa-warning text-yellow"></i> Ticket khẩn cấp cần xử lý
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            <li class="footer"><a href="#">Xem tất cả</a></li>
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
                <!-- search form -->
                <form action="#" method="get" class="sidebar-form">
                    <div class="input-group">
                        <input type="text" name="q" class="form-control" placeholder="Tìm kiếm ticket..."/>
                        <span class="input-group-btn">
                            <button type='submit' name='seach' id='search-btn' class="btn btn-flat"><i class="fa fa-search"></i></button>
                        </span>
                    </div>
                </form>
                <!-- /.search form -->
                <!-- sidebar menu: : style can be found in sidebar.less -->
                <ul class="sidebar-menu">
                    <li class="active">
                        <a href="customersupport.jsp">
                            <i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
                        </a>
                    </li>
                    <li>
                        <a href="support_management.jsp">
                            <i class="fa fa-ticket"></i> <span>Quản lý yêu cầu hỗ trợ</span>
                            <small class="badge pull-right bg-red" id="openTickets">0</small>
                        </a>
                    </li>
                    <li>
                        <a href="customers.jsp">
                            <i class="fa fa-users"></i> <span>Danh sách khách hàng</span>
                        </a>
                    </li>
                    <li>
                        <a href="product">
                            <i class="fa fa-shopping-cart"></i> <span>Danh sách sản phẩm</span>
                        </a>
                    </li>
                    <li>
                        <a href="contracts.jsp">
                            <i class="fa fa-file-text"></i> <span>Hợp đồng khách hàng</span>
                        </a>
                    </li>
                    <li>
                        <a href="orders.jsp">
                            <i class="fa fa-file-text-o"></i> <span>Đơn hàng</span>
                        </a>
                    </li>
                    <li class="treeview">
                        <a href="#">
                            <i class="fa fa-bar-chart"></i> <span>Báo cáo</span>
                            <i class="fa fa-angle-left pull-right"></i>
                        </a>
                        <ul class="treeview-menu">
                            <li><a href="#"><i class="fa fa-circle-o"></i> Báo cáo ticket</a></li>
                            <li><a href="#"><i class="fa fa-circle-o"></i> Đánh giá hỗ trợ</a></li>
                            <li><a href="#"><i class="fa fa-circle-o"></i> Hiệu suất</a></li>
                        </ul>
                    </li>
                    <li>
                        <a href="#">
                            <i class="fa fa-book"></i> <span>Tài liệu hướng dẫn</span>
                        </a>
                    </li>
                </ul>
            </section>
            <!-- /.sidebar -->
        </aside>

        <aside class="right-side">
            <!-- Main content -->
            <section class="content">
                <!-- Statistics Row 1: Support Tickets -->
                <div class="row" style="margin-bottom:5px;">
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-red"><i class="fa fa-exclamation-circle"></i></span>
                            <div class="sm-st-info">
                                <span id="urgentTickets">0</span>
                                Ticket khẩn cấp
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-violet"><i class="fa fa-ticket"></i></span>
                            <div class="sm-st-info">
                                <span id="totalOpenTickets">0</span>
                                Ticket đang mở
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-blue"><i class="fa fa-check-circle"></i></span>
                            <div class="sm-st-info">
                                <span id="resolvedToday">0</span>
                                Đã giải quyết hôm nay
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-green"><i class="fa fa-smile-o"></i></span>
                            <div class="sm-st-info">
                                <span id="satisfactionRate">0%</span>
                                Hài lòng
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Statistics Row 2: Category Breakdown -->
                <div class="row" style="margin-bottom:5px;">
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-orange"><i class="fa fa-wrench"></i></span>
                            <div class="sm-st-info">
                                <span id="technicalTickets">0</span>
                                Kỹ thuật
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-purple"><i class="fa fa-money"></i></span>
                            <div class="sm-st-info">
                                <span id="billingTickets">0</span>
                                Thanh toán
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-cyan"><i class="fa fa-info-circle"></i></span>
                            <div class="sm-st-info">
                                <span id="generalTickets">0</span>
                                Thông tin chung
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-pink"><i class="fa fa-frown-o"></i></span>
                            <div class="sm-st-info">
                                <span id="complaintTickets">0</span>
                                Khiếu nại
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Main row -->
                <div class="row">
                    <div class="col-md-8">
                        <!--ticket trend chart start-->
                        <section class="panel">
                            <header class="panel-heading">
                                Biểu đồ xu hướng yêu cầu hỗ trợ
                            </header>
                            <div class="panel-body">
                                <canvas id="linechart" width="600" height="330"></canvas>
                            </div>
                        </section>
                        <!--ticket trend chart end-->
                    </div>
                    <div class="col-lg-4">
                        <!--notifications start-->
                        <section class="panel">
                            <header class="panel-heading">
                                Thông báo quan trọng
                            </header>
                            <div class="panel-body" id="noti-box">
                                <div class="alert alert-block alert-danger">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Khẩn cấp!</strong> Có 3 ticket mức độ khẩn cấp cần xử lý ngay.
                                </div>
                                <div class="alert alert-warning">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Chú ý!</strong> 5 ticket đã quá hạn phản hồi.
                                </div>
                                <div class="alert alert-success">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Tốt!</strong> Bạn đã giải quyết 15 ticket hôm nay.
                                </div>
                                <div class="alert alert-info">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Thông tin!</strong> Có 2 khách hàng mới cần liên hệ.
                                </div>
                            </div>
                        </section>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-8">
                        <section class="panel">
                            <header class="panel-heading">
                                Yêu cầu hỗ trợ gần đây
                            </header>
                            <div class="panel-body table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Mã Ticket</th>
                                            <th>Khách hàng</th>
                                            <th>Vấn đề</th>
                                            <th>Danh mục</th>
                                            <th>Độ ưu tiên</th>
                                            <th>Trạng thái</th>
                                            <th>Thời gian</th>
                                        </tr>
                                    </thead>
                                    <tbody id="recentTicketsTable">
                                        <tr>
                                            <td>#TK001</td>
                                            <td>Nguyễn Văn A</td>
                                            <td>Máy không khởi động</td>
                                            <td><span class="label label-info">Kỹ thuật</span></td>
                                            <td><span class="label label-danger">Khẩn cấp</span></td>
                                            <td><span class="label label-warning">Đang xử lý</span></td>
                                            <td>5 phút trước</td>
                                        </tr>
                                        <tr>
                                            <td>#TK002</td>
                                            <td>Trần Thị B</td>
                                            <td>Hỏi về bảo hành</td>
                                            <td><span class="label label-default">Chung</span></td>
                                            <td><span class="label label-warning">Trung bình</span></td>
                                            <td><span class="label label-primary">Đang chờ</span></td>
                                            <td>1 giờ trước</td>
                                        </tr>
                                        <tr>
                                            <td>#TK003</td>
                                            <td>Lê Văn C</td>
                                            <td>Thanh toán hóa đơn</td>
                                            <td><span class="label label-success">Thanh toán</span></td>
                                            <td><span class="label label-info">Thấp</span></td>
                                            <td><span class="label label-success">Hoàn thành</span></td>
                                            <td>2 giờ trước</td>
                                        </tr>
                                        <tr>
                                            <td>#TK004</td>
                                            <td>Phạm Thị D</td>
                                            <td>Khiếu nại chất lượng</td>
                                            <td><span class="label label-danger">Khiếu nại</span></td>
                                            <td><span class="label label-danger">Cao</span></td>
                                            <td><span class="label label-warning">Đang xử lý</span></td>
                                            <td>3 giờ trước</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            <div class="panel-footer">
                                <a href="support_management.jsp" class="btn btn-primary btn-sm">Xem tất cả yêu cầu</a>
                            </div>
                        </section>
                    </div>
                    <div class="col-md-4">
                        <section class="panel">
                            <header class="panel-heading">
                                Hiệu suất hôm nay
                            </header>
                            <div class="panel-body">
                                <div class="list-group">
                                    <div class="list-group-item">
                                        <h4 class="list-group-item-heading">Thời gian phản hồi trung bình</h4>
                                        <p class="list-group-item-text">
                                            <strong class="text-success" style="font-size: 24px;" id="avgResponseTime">15 phút</strong>
                                        </p>
                                    </div>
                                    <div class="list-group-item">
                                        <h4 class="list-group-item-heading">Thời gian giải quyết trung bình</h4>
                                        <p class="list-group-item-text">
                                            <strong class="text-info" style="font-size: 24px;" id="avgResolutionTime">2 giờ</strong>
                                        </p>
                                    </div>
                                    <div class="list-group-item">
                                        <h4 class="list-group-item-heading">Tỷ lệ giải quyết lần đầu</h4>
                                        <p class="list-group-item-text">
                                            <strong class="text-warning" style="font-size: 24px;" id="firstContactResolution">85%</strong>
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </section>
                        
                        <section class="panel">
                            <header class="panel-heading">
                                Khách hàng cần chú ý
                            </header>
                            <div class="panel-body">
                                <ul class="list-group">
                                    <li class="list-group-item">
                                        <span class="badge bg-red">3</span>
                                        Công ty ABC - Nhiều ticket
                                    </li>
                                    <li class="list-group-item">
                                        <span class="badge bg-yellow">2</span>
                                        Khách hàng XYZ - VIP
                                    </li>
                                    <li class="list-group-item">
                                        <span class="badge bg-orange">1</span>
                                        Doanh nghiệp DEF - Khiếu nại
                                    </li>
                                </ul>
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

    <script>
        $('#noti-box').slimScroll({
            height: '400px',
            size: '5px',
            BorderRadius: '5px'
        });
        
        // Load support statistics
        $(document).ready(function() {
            loadSupportStats();
            loadRecentTickets();
        });
        
        function loadSupportStats() {
            // Giả lập dữ liệu - sau này sẽ thay bằng API thực
            $('#urgentTickets').text('3');
            $('#totalOpenTickets').text('28');
            $('#resolvedToday').text('15');
            $('#satisfactionRate').text('92%');
            
            $('#technicalTickets').text('12');
            $('#billingTickets').text('5');
            $('#generalTickets').text('8');
            $('#complaintTickets').text('3');
            
            $('#openTickets').text('28');
            $('#unreadMessages').text('4');
            $('#unreadNotifications').text('2');
            
            // Có thể gọi API thực tế như sau:
            /*
            $.ajax({
                url: 'api/support?action=getStats',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        var stats = response.data;
                        $('#urgentTickets').text(stats.urgentTickets || 0);
                        $('#totalOpenTickets').text(stats.openTickets || 0);
                        // ... cập nhật các thống kê khác
                    }
                },
                error: function() {
                    console.log('Không thể tải thống kê hỗ trợ');
                }
            });
            */
        }
        
        function loadRecentTickets() {
            // Dữ liệu đã được hardcode trong HTML
            // Sau này có thể load động từ API
            console.log('Loaded recent tickets');
        }
    </script>
    
    <script type="text/javascript">
        $(function() {
            "use strict";
            // LINE CHART - Ticket Trend
            var data = {
                labels: ["Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "CN"],
                datasets: [
                    {
                        label: "Ticket mới",
                        fillColor: "rgba(220,53,69,0.2)",
                        strokeColor: "rgba(220,53,69,1)",
                        pointColor: "rgba(220,53,69,1)",
                        pointStrokeColor: "#fff",
                        pointHighlightFill: "#fff",
                        pointHighlightStroke: "rgba(220,53,69,1)",
                        data: [25, 30, 28, 35, 32, 20, 15]
                    },
                    {
                        label: "Ticket đã giải quyết",
                        fillColor: "rgba(40,167,69,0.2)",
                        strokeColor: "rgba(40,167,69,1)",
                        pointColor: "rgba(40,167,69,1)",
                        pointStrokeColor: "#fff",
                        pointHighlightFill: "#fff",
                        pointHighlightStroke: "rgba(40,167,69,1)",
                        data: [22, 28, 26, 33, 30, 18, 12]
                    },
                    {
                        label: "Ticket khẩn cấp",
                        fillColor: "rgba(255,193,7,0.2)",
                        strokeColor: "rgba(255,193,7,1)",
                        pointColor: "rgba(255,193,7,1)",
                        pointStrokeColor: "#fff",
                        pointHighlightFill: "#fff",
                        pointHighlightStroke: "rgba(255,193,7,1)",
                        data: [3, 5, 4, 6, 4, 2, 1]
                    }
                ]
            };
            new Chart(document.getElementById("linechart").getContext("2d")).Line(data,{
                responsive : true,
                maintainAspectRatio: false,
            });
        });
    </script>
</body>
</html>

