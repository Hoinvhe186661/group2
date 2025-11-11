<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng điều khiển | Báo cáo</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <!-- bootstrap 3.0.2 -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- font Awesome -->
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Ionicons -->
    <link href="css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <!-- Morris chart -->
    <link href="css/morris/morris.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="css/style.css" rel="stylesheet" type="text/css" />
    <link href='http://fonts.googleapis.com/css?family=Lato' rel='stylesheet' type='text/css'>
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
                    <!-- User Account: style can be found in dropdown.less -->
                    <li class="dropdown user user-menu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="fa fa-user"></i>
                            <span>Admin <i class="caret"></i></span>
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
                        <p>Xin chào, Admin</p>
                        <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
                    </div>
                </div>
                
                <!-- sidebar menu: : style can be found in sidebar.less -->
                <%@ include file="includes/sidebar-menu.jsp" %>
            </section>
            <!-- /.sidebar -->
        </aside>

        <aside class="right-side">
            <!-- Main content -->
            <section class="content">
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel">
                            <header class="panel-heading">
                                <h3>Báo cáo thống kê</h3>
                                <div class="panel-tools">
                                    <div class="btn-group">
                                        <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown">
                                            Xuất báo cáo <span class="caret"></span>
                                        </button>
                                        <ul class="dropdown-menu">
                                            <li><a href="#" onclick="exportReport('pdf')"><i class="fa fa-file-pdf-o"></i> Xuất PDF</a></li>
                                            <li><a href="#" onclick="exportReport('excel')"><i class="fa fa-file-excel-o"></i> Xuất Excel</a></li>
                                            <li><a href="#" onclick="exportReport('csv')"><i class="fa fa-file-text-o"></i> Xuất CSV</a></li>
                                        </ul>
                                    </div>
                                </div>
                            </header>
                            <div class="panel-body">
                                <!-- Bộ lọc thời gian -->
                                <div class="row" style="margin-bottom: 20px;">
                                    <div class="col-md-3">
                                        <label>Từ ngày:</label>
                                        <input type="date" class="form-control" id="fromDate" value="2025-09-01">
                                    </div>
                                    <div class="col-md-3">
                                        <label>Đến ngày:</label>
                                        <input type="date" class="form-control" id="toDate" value="2025-09-30">
                                    </div>
                                    <div class="col-md-3">
                                        <label>Loại báo cáo:</label>
                                        <select class="form-control" id="reportType">
                                            <option value="sales">Báo cáo doanh thu</option>
                                            <option value="products">Báo cáo sản phẩm</option>
                                            <option value="customers">Báo cáo khách hàng</option>
                                            <option value="orders">Báo cáo đơn hàng</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label>&nbsp;</label><br>
                                        <button class="btn btn-primary" onclick="generateReport()">
                                            <i class="fa fa-refresh"></i> Tạo báo cáo
                                        </button>
                                    </div>
                                </div>

                                <!-- Tổng quan -->
                                <div class="row">
                                    <div class="col-md-3">
                                        <div class="sm-st clearfix">
                                            <span class="sm-st-icon st-red"><i class="fa fa-dollar"></i></span>
                                            <div class="sm-st-info">
                                                <span id="totalRevenue">25,000,000</span>
                                                Tổng doanh thu (VNĐ)
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="sm-st clearfix">
                                            <span class="sm-st-icon st-violet"><i class="fa fa-shopping-cart"></i></span>
                                            <div class="sm-st-info">
                                                <span id="totalOrders">150</span>
                                                Tổng đơn hàng
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="sm-st clearfix">
                                            <span class="sm-st-icon st-blue"><i class="fa fa-users"></i></span>
                                            <div class="sm-st-info">
                                                <span id="totalCustomers">320</span>
                                                Tổng khách hàng
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="sm-st clearfix">
                                            <span class="sm-st-icon st-green"><i class="fa fa-cube"></i></span>
                                            <div class="sm-st-info">
                                                <span id="totalProducts">45</span>
                                                Sản phẩm bán được
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Biểu đồ -->
                                <div class="row" style="margin-top: 30px;">
                                    <div class="col-md-8">
                                        <section class="panel">
                                            <header class="panel-heading">
                                                Biểu đồ doanh thu theo tháng
                                            </header>
                                            <div class="panel-body">
                                                <canvas id="revenueChart" width="600" height="300"></canvas>
                                            </div>
                                        </section>
                                    </div>
                                    <div class="col-md-4">
                                        <section class="panel">
                                            <header class="panel-heading">
                                                Top sản phẩm bán chạy
                                            </header>
                                            <div class="panel-body">
                                                <canvas id="topProductsChart" width="300" height="300"></canvas>
                                            </div>
                                        </section>
                                    </div>
                                </div>

                                <!-- Bảng chi tiết -->
                                <div class="row">
                                    <div class="col-md-12">
                                        <section class="panel">
                                            <header class="panel-heading">
                                                Chi tiết báo cáo
                                            </header>
                                            <div class="panel-body table-responsive">
                                                <table class="table table-hover" id="reportTable">
                                                    <thead>
                                                        <tr>
                                                            <th>Ngày</th>
                                                            <th>Doanh thu</th>
                                                            <th>Số đơn hàng</th>
                                                            <th>Khách hàng mới</th>
                                                            <th>Sản phẩm bán</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <tr>
                                                            <td>21/09/2025</td>
                                                            <td>2,500,000 VNĐ</td>
                                                            <td>15</td>
                                                            <td>3</td>
                                                            <td>25</td>
                                                        </tr>
                                                        <tr>
                                                            <td>20/09/2025</td>
                                                            <td>3,200,000 VNĐ</td>
                                                            <td>18</td>
                                                            <td>5</td>
                                                            <td>32</td>
                                                        </tr>
                                                        <tr>
                                                            <td>19/09/2025</td>
                                                            <td>1,800,000 VNĐ</td>
                                                            <td>12</td>
                                                            <td>2</td>
                                                            <td>18</td>
                                                        </tr>
                                                        <tr>
                                                            <td>18/09/2025</td>
                                                            <td>4,100,000 VNĐ</td>
                                                            <td>22</td>
                                                            <td>7</td>
                                                            <td>28</td>
                                                        </tr>
                                                        <tr>
                                                            <td>17/09/2025</td>
                                                            <td>2,900,000 VNĐ</td>
                                                            <td>16</td>
                                                            <td>4</td>
                                                            <td>21</td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </section>
                                    </div>
                                </div>
                            </div>
                        </div>
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
    <!-- Chart.js -->
    <script src="js/plugins/chart.js" type="text/javascript"></script>
    <!-- Director App -->
    <script src="js/Director/app.js" type="text/javascript"></script>

    <script type="text/javascript">
        $(document).ready(function() {
            generateReport();
        });

        function generateReport() {
            // Tạo biểu đồ doanh thu
            var revenueCtx = document.getElementById('revenueChart').getContext('2d');
            var revenueChart = new Chart(revenueCtx, {
                type: 'line',
                data: {
                    labels: ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6', 'Tháng 7'],
                    datasets: [{
                        label: 'Doanh thu (VNĐ)',
                        data: [12000000, 19000000, 15000000, 25000000, 22000000, 30000000, 25000000],
                        borderColor: 'rgb(75, 192, 192)',
                        tension: 0.1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false
                }
            });

            // Tạo biểu đồ sản phẩm bán chạy
            var productsCtx = document.getElementById('topProductsChart').getContext('2d');
            var productsChart = new Chart(productsCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Sản phẩm 1', 'Sản phẩm 2', 'Sản phẩm 3', 'Sản phẩm 4', 'Khác'],
                    datasets: [{
                        data: [30, 25, 20, 15, 10],
                        backgroundColor: [
                            '#FF6384',
                            '#36A2EB',
                            '#FFCE56',
                            '#4BC0C0',
                            '#9966FF'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false
                }
            });
        }

        function exportReport(format) {
            var fromDate = document.getElementById('fromDate').value;
            var toDate = document.getElementById('toDate').value;
            var reportType = document.getElementById('reportType').value;
            
            alert('Đang xuất báo cáo ' + reportType + ' từ ' + fromDate + ' đến ' + toDate + ' định dạng ' + format.toUpperCase());
            // Thêm logic xuất báo cáo ở đây
        }
    </script>
</body>
</html>
