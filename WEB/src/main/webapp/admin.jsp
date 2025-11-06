<!-- <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Kiểm tra đăng nhập
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }
    // Nếu truy cập trực tiếp admin.jsp (không qua servlet) thì chuyển hướng về /admin để nạp dữ liệu
    if (request.getAttribute("customerCount") == null) {
        response.sendRedirect(request.getContextPath() + "/admin");
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
    
    <!-- Custom styles for admin dashboard -->
    <style>
        /* Màu sắc cho icon cards */
        .st-orange { background-color: #ff9800 !important; }
        .st-purple { background-color: #9c27b0 !important; }
        .st-cyan { background-color: #00bcd4 !important; }
        .st-pink { background-color: #e91e63 !important; }

        /* Smooth animations */
        .fade-in { opacity: 0; animation: fadeInUp 500ms ease-out forwards; }
        .fade-in.delay-1 { animation-delay: 80ms; }
        .fade-in.delay-2 { animation-delay: 160ms; }
        .fade-in.delay-3 { animation-delay: 240ms; }
        .fade-in.delay-4 { animation-delay: 320ms; }
        .slide-up { transform: translateY(8px); opacity: 0; animation: slideUp 450ms ease-out forwards; }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(6px);} to { opacity: 1; transform: translateY(0);} }
        @keyframes slideUp { to { transform: translateY(0); opacity: 1; } }

        /* Animate SVG bars on load */
        svg .chart-bar { transform-origin: bottom center; animation: growBar 700ms ease-out forwards; transform: scaleY(0.2); }
        svg .chart-bar:nth-child(odd) { animation-delay: 80ms; }
        @keyframes growBar { to { transform: scaleY(1); } }

        /* Fix text bị cắt - sử dụng template gốc và chỉ thêm word-wrap */
        .sm-st.clearfix::after {
            content: "";
            display: table;
            clear: both;
        }
        .sm-st-info { 
            word-wrap: break-word;
            overflow-wrap: break-word;
            white-space: normal;
        }
        .panel-body h3, .panel-body p { 
            word-wrap: break-word; 
            overflow-wrap: break-word;
            white-space: normal;
        }
        
        /* Scrollbar cho danh sách */
        #noti-box { max-height: 360px; overflow-y: auto; }
        #recentUsersList { max-height: 160px; overflow-y: auto; overflow-x: hidden; }
        #recentUsersList::-webkit-scrollbar { width: 8px; }
        #recentUsersList::-webkit-scrollbar-track { background: #f1f1f1; border-radius: 4px; }
        #recentUsersList::-webkit-scrollbar-thumb { background: #888; border-radius: 4px; }
        #recentUsersList::-webkit-scrollbar-thumb:hover { background: #555; }
    </style>

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
</head>
<body class="skin-black">
    <!-- Header -->
    <header class="header">
        <a href="customers" class="logo">Bảng điều khiển </a>
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
                            <span>Admin <i class="caret"></i></span>
                        </a>
                       <ul class="dropdown-menu dropdown-custom dropdown-menu-right">
                            <li class="dropdown-header text-center">Tài khoản</li>
                            <li><a href="profile.jsp"><i class="fa fa-user fa-fw pull-right"></i> Hồ sơ</a></li>
                            <li><a href="settings.jsp"><i class="fa fa-cog fa-fw pull-right"></i> Cài đặt</a></li>
                            <li class="divider"></li>
                            <li><a href="logout"><i class="fa fa-ban fa-fw pull-right"></i> Đăng xuất</a></li>
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
                        <p>Xin chào, <%= (String) session.getAttribute("username") %></p>
                        <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
                    </div>
                </div>
                
               
                <!-- sidebar menu: : style can be found in sidebar.less -->
                <ul class="sidebar-menu">
                    <li class="active">
                        <a href="admin">
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
                <!-- Hàng đầu: 4 phần tử dài nhất -->
                <div class="row" style="margin-bottom:5px;">
                    <div class="col-md-3 fade-in delay-1">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-orange"><i class="fa fa-user-secret"></i></span>
                            <div class="sm-st-info">
                                <span id="totalUsers"><%= request.getAttribute("totalUsers") != null ? request.getAttribute("totalUsers") : 0 %></span>
                                Người dùng hệ thống
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 fade-in delay-2">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-purple"><i class="fa fa-wrench"></i></span>
                            <div class="sm-st-info">
                                <span id="technicalStaff"><%= request.getAttribute("technicalStaffCount") != null ? request.getAttribute("technicalStaffCount") : 0 %></span>
                                Nhân viên kỹ thuật
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 fade-in delay-3">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-cyan"><i class="fa fa-headphones"></i></span>
                            <div class="sm-st-info">
                                <span id="supportStaff"><%= request.getAttribute("customerSupportCount") != null ? request.getAttribute("customerSupportCount") : 0 %></span>
                                Hỗ trợ khách hàng
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 fade-in delay-4">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-green"><i class="fa fa-user-tie"></i></span>
                            <div class="sm-st-info">
                                <span id="headTechnician"><%= request.getAttribute("headTechnicianCount") != null ? request.getAttribute("headTechnicianCount") : 0 %></span>
                                Trưởng phòng kỹ thuật
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Hàng thứ hai: các phần tử còn lại -->
                <div class="row" style="margin-bottom:5px;">
                    <div class="col-md-3 fade-in">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-green"><i class="fa fa-users"></i></span>
                            <div class="sm-st-info">
                                <span id="customerCount"><%= request.getAttribute("customerCount") != null ? request.getAttribute("customerCount") : 0 %></span>
                                Khách hàng
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 fade-in">
                        <div class="sm-st clearfix">
                            <span class="sm-st-icon st-pink"><i class="fa fa-warehouse"></i></span>
                            <div class="sm-st-info">
                                <span id="storekeepers"><%= request.getAttribute("storekeeperCount") != null ? request.getAttribute("storekeeperCount") : 0 %></span>
                                Thủ kho
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Main row -->
                <div class="row">
                    <div class="col-md-8">
                        <!--earning graph start-->
                        <section class="panel slide-up">
                            <header class="panel-heading">
                                Tổng quan khách hàng
                            </header>
                            <div class="panel-body">
                                <h3 style="margin:0 0 10px;">Tổng khách hàng: 
                                    <strong><%= request.getAttribute("customerCount") != null ? request.getAttribute("customerCount") : 0 %></strong>
                                </h3>
                                <div>
                                    <%= request.getAttribute("customerChartSvg") != null ? request.getAttribute("customerChartSvg") : "" %>
                                </div>
                                <p class="text-muted" style="margin-top:8px;">Dữ liệu cập nhật trực tiếp từ cơ sở dữ liệu.</p>
                            </div>
                        </section>
                        <!--earning graph end-->
                    </div>
                    <div class="col-lg-4">
                        <!--notifications start-->
                        <section class="panel slide-up">
                            <header class="panel-heading">
                                Nhật ký hoạt động gần đây
                            </header>
                            <div class="panel-body" id="noti-box">
                                <%
                                    @SuppressWarnings("unchecked")
                                    java.util.List<java.util.Map<String, Object>> recentActions = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("recentActions");
                                    if (recentActions != null && !recentActions.isEmpty()) {
                                        // Sắp xếp giảm dần theo thời gian
                                        recentActions.sort(new java.util.Comparator<java.util.Map<String, Object>>() {
                                            public int compare(java.util.Map<String, Object> a, java.util.Map<String, Object> b) {
                                                long ta = a.get("time") != null ? ((Number)a.get("time")).longValue() : 0L;
                                                long tb = b.get("time") != null ? ((Number)b.get("time")).longValue() : 0L;
                                                return Long.compare(tb, ta);
                                            }
                                        });
                                        int limit = Math.min(20, recentActions.size());
                                        for (int i = 0; i < limit; i++) {
                                            java.util.Map<String, Object> act = recentActions.get(i);
                                            String type = String.valueOf(act.getOrDefault("type", "info"));
                                            String message = String.valueOf(act.getOrDefault("message", ""));
                                            long t = act.get("time") != null ? ((Number)act.get("time")).longValue() : 0L;
                                            String timeText = t > 0 ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new java.util.Date(t)) : "";
                                %>
                                    <div class="alert alert-<%= type %> fade-in">
                                        <button data-dismiss="alert" class="close close-sm" type="button"><i class="fa fa-times"></i></button>
                                        <i class="fa <%= ("success".equals(type)?"fa-check":("warning".equals(type)?"fa-exclamation-triangle":("danger".equals(type)?"fa-times-circle":"fa-info-circle"))) %>"></i>
                                        <%= message %>
                                        <%= timeText.isEmpty()?"":" <small class=\"text-muted pull-right\"><i class=\"fa fa-clock-o\"></i> " + timeText + "</small>" %>
                                    </div>
                                <%
                                        }
                                    } else {
                                %>
                                    <div class="alert alert-info">Chưa có hoạt động nào gần đây.</div>
                                <%
                                    }
                                %>
                            </div>
                        </section>
                    </div>
                </div>

                <!-- Thống kê người dùng hệ thống -->
                <div class="row">
                    
                    <div class="col-md-6">
                        <section class="panel">
                            <header class="panel-heading">
                                Danh sách người dùng mới nhất
                            </header>
                            <div class="panel-body">
                                <ul class="list-group" id="recentUsersList">
                                    <%
                                        @SuppressWarnings("unchecked")
                                        java.util.List<com.hlgenerator.model.User> recentUsers = (java.util.List<com.hlgenerator.model.User>) request.getAttribute("recentUsers");
                                        if (recentUsers != null) {
                                            for (com.hlgenerator.model.User u : recentUsers) {
                                    %>
                                        <li class="list-group-item">
                                            <i class="fa fa-user"></i>
                                            <strong><%= (u.getFullName() != null && !u.getFullName().isEmpty()) ? u.getFullName() : u.getUsername() %></strong>
                                            <span class="label label-default" style="margin-left:6px;"><%= u.getRole() %></span>
                                        </li>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <li class="list-group-item text-muted">Không có dữ liệu.</li>
                                    <%
                                        }
                                    %>
                                </ul>
                            </div>
                        </section>
                    </div>
                </div>
                
                
            <div class="footer-main">
                Copyright &copy Bảng điều khiển quản trị, 2025
            </div>
        </aside><!-- /.right-side -->
    </div><!-- ./wrapper -->

    <!-- jQuery (local) -->
    <script src="js/jquery.min.js" type="text/javascript"></script>
    <!-- jQuery UI 1.10.3 -->
    <script src="js/jquery-ui-1.10.3.min.js" type="text/javascript"></script>
    <!-- Bootstrap -->
    <script src="js/bootstrap.min.js" type="text/javascript"></script>
    <!-- Director App -->
    <script src="js/Director/app.js" type="text/javascript"></script>
</body>
</html> 
