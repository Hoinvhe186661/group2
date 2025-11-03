<!-- <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Kiểm tra đăng nhập
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng điều khiển | Bảng điều khiển</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <meta name="description" content="Admin Panel for Web Application">
    <meta name="keywords" content="Admin, Bootstrap 3, Template, Theme, Responsive">
    
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
    
    <!-- Custom styles for user stats -->
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
        <a href="admin.jsp" class="logo">
            Bảng điều khiển 
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
                            <span class="label label-success">4</span>
                        </a>
                        <ul class="dropdown-menu">
                            <li class="header">Bạn có 4 tin nhắn</li>
                            <li>
                                <!-- inner menu: contains the actual data -->
                                <ul class="menu">
                                    <li><!-- start message -->s
                                        <a href="#">
                                            <div class="pull-left">
                                                <img src="img/26115.jpg" class="img-circle" alt="User Image"/>
                                            </div>
                                            <h4>
                                                Hỗ trợ khách hàng
                                            </h4>
                                            <p>Có khách hàng cần hỗ trợ</p>
                                            <small class="pull-right"><i class="fa fa-clock-o"></i> 5 phút</small>
                                        </a>
                                    </li><!-- end message -->
                                    <li>
                                        <a href="#">
                                            <div class="pull-left">
                                                <img src="img/26115.jpg" class="img-circle" alt="user image"/>
                                            </div>
                                            <h4>
                                                Đơn hàng mới
                                            </h4>
                                            <p>Có đơn hàng mới cần xử lý</p>
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
                <ul class="sidebar-menu">
                    <li class="active">
                        <a href="admin.jsp">
                            <i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
                        </a>
                    </li>
                    
                    <li>
                        <a href="customers">
                            <i class="fa fa-users"></i> <span>Quản lý khách hàng</span>
                        </a>
                    </li>
                    <li>
                        <a href="users">
                            <i class="fa fa-user-secret"></i> <span>Quản lý người dùng</span>
                        </a>
                    </li>
                    <li>
                        <a href="email-management">
                            <i class="fa fa-envelope"></i> <span>Quản lý Email</span>
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
                <div class="row" style="margin-bottom:5px;">
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-red"><i class="fa fa-shopping-cart"></i></span>
                            <div class="sm-st-info">
                                <span>150</span>
                                Tổng sản phẩm
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-violet"><i class="fa fa-file-text-o"></i></span>
                            <div class="sm-st-info">
                                <span>45</span>
                                Đơn hàng mới
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-blue"><i class="fa fa-dollar"></i></span>
                            <div class="sm-st-info">
                                <span>25,000,000</span>
                                Doanh thu
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-green"><i class="fa fa-users"></i></span>
                            <div class="sm-st-info">
                                <span>320</span>
                                Khách hàng
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="row" style="margin-bottom:5px;">
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-orange"><i class="fa fa-user-secret"></i></span>
                            <div class="sm-st-info">
                                <span id="totalUsers">0</span>
                                Người dùng hệ thống
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-purple"><i class="fa fa-wrench"></i></span>
                            <div class="sm-st-info">
                                <span id="technicalStaff">0</span>
                                Nhân viên kỹ thuật
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-cyan"><i class="fa fa-headphones"></i></span>
                            <div class="sm-st-info">
                                <span id="supportStaff">0</span>
                                Hỗ trợ khách hàng
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-pink"><i class="fa fa-warehouse"></i></span>
                            <div class="sm-st-info">
                                <span id="storekeepers">0</span>
                                Thủ kho
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Main row -->
                <div class="row">
                    <div class="col-md-8">
                        <!--earning graph start-->
                        <section class="panel">
                            <header class="panel-heading">
                                Biểu đồ doanh thu
                            </header>
                            <div class="panel-body">
                                <canvas id="linechart" width="600" height="330"></canvas>
                            </div>
                        </section>
                        <!--earning graph end-->
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
                                    <strong>Cảnh báo!</strong> Có đơn hàng cần xử lý gấp.
                                </div>
                                <div class="alert alert-success">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Thành công!</strong> Đã cập nhật sản phẩm mới.
                                </div>
                                <div class="alert alert-info">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Thông tin!</strong> Có khách hàng mới đăng ký.
                                </div>
                                <div class="alert alert-warning">
                                    <button data-dismiss="alert" class="close close-sm" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <strong>Chú ý!</strong> Kiểm tra tồn kho sản phẩm.
                                </div>
                            </div>
                        </section>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-8">
                        <section class="panel">
                            <header class="panel-heading">
                                Đơn hàng gần đây
                            </header>
                            <div class="panel-body table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Khách hàng</th>
                                            <th>Sản phẩm</th>
                                            <th>Ngày đặt</th>
                                            <th>Trạng thái</th>
                                            <th>Tổng tiền</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>1</td>
                                            <td>Nguyễn Văn A</td>
                                            <td>Sản phẩm 1</td>
                                            <td>21/09/2025</td>
                                            <td><span class="label label-warning">Đang xử lý</span></td>
                                            <td>500,000 VNĐ</td>
                                        </tr>
                                        <tr>
                                            <td>2</td>
                                            <td>Trần Thị B</td>
                                            <td>Sản phẩm 2</td>
                                            <td>20/09/2025</td>
                                            <td><span class="label label-success">Hoàn thành</span></td>
                                            <td>750,000 VNĐ</td>
                                        </tr>
                                        <tr>
                                            <td>3</td>
                                            <td>Lê Văn C</td>
                                            <td>Sản phẩm 3</td>
                                            <td>19/09/2025</td>
                                            <td><span class="label label-info">Đang giao</span></td>
                                            <td>1,200,000 VNĐ</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </section>
                    </div>
                    <div class="col-md-4">
                        <section class="panel">
                            <header class="panel-heading">
                                Sản phẩm bán chạy
                            </header>
                            <div class="panel-body">
                                <ul class="list-group">
                                    <li class="list-group-item">
                                        <span class="badge">15</span>
                                        Sản phẩm 1
                                    </li>
                                    <li class="list-group-item">
                                        <span class="badge">12</span>
                                        Sản phẩm 2
                                    </li>
                                    <li class="list-group-item">
                                        <span class="badge">8</span>
                                        Sản phẩm 3
                                    </li>
                                    <li class="list-group-item">
                                        <span class="badge">6</span>
                                        Sản phẩm 4
                                    </li>
                                </ul>
                            </div>
                        </section>
                    </div>
                </div>
            </section><!-- /.content -->
            <div class="footer-main">
                Copyright &copy Bảng điều khiển quản trị, 2025
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
        
        // Load user statistics
        $(document).ready(function() {
            loadUserStats();
        });
        
        function loadUserStats() {
            $.ajax({
                url: 'api/users?action=getStats',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        var stats = response.data;
                        $('#totalUsers').text(stats.totalUsers || 0);
                        $('#technicalStaff').text(stats.technicalStaffCount || 0);
                        $('#supportStaff').text(stats.customerSupportCount || 0);
                        $('#storekeepers').text(stats.storekeeperCount || 0);
                    }
                },
                error: function() {
                    console.log('Không thể tải thống kê người dùng');
                }
            });
        }
    </script>
    
    <script type="text/javascript">
        $(function() {
            "use strict";
            //BAR CHART
            var data = {
                labels: ["Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6", "Tháng 7"],
                datasets: [
                    {
                        label: "Doanh thu",
                        fillColor: "rgba(220,220,220,0.2)",
                        strokeColor: "rgba(220,220,220,1)",
                        pointColor: "rgba(220,220,220,1)",
                        pointStrokeColor: "#fff",
                        pointHighlightFill: "#fff",
                        pointHighlightStroke: "rgba(220,220,220,1)",
                        data: [65, 59, 80, 81, 56, 55, 40]
                    },
                    {
                        label: "Lợi nhuận",
                        fillColor: "rgba(151,187,205,0.2)",
                        strokeColor: "rgba(151,187,205,1)",
                        pointColor: "rgba(151,187,205,1)",
                        pointStrokeColor: "#fff",
                        pointHighlightFill: "#fff",
                        pointHighlightStroke: "rgba(151,187,205,1)",
                        data: [28, 48, 40, 19, 86, 27, 90]
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
