<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Panel | Quản lý khách hàng</title>
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
</head>
<body class="skin-black">
    <!-- header logo: style can be found in header.less -->
    <header class="header">
        <a href="admin.jsp" class="logo">
            Admin Panel
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
                            <i class="fa fa-dashboard"></i> <span>Dashboard</span>
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
                    <li class="active">
                        <a href="customers.jsp">
                            <i class="fa fa-users"></i> <span>Quản lý khách hàng</span>
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
                                <h3>Quản lý khách hàng</h3>
                                <div class="panel-tools">
                                    <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addCustomerModal">
                                        <i class="fa fa-plus"></i> Thêm khách hàng mới
                                    </button>
                                </div>
                            </header>
                            <div class="panel-body table-responsive">
                                <table class="table table-hover" id="customersTable">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Họ tên</th>
                                            <th>Email</th>
                                            <th>Số điện thoại</th>
                                            <th>Địa chỉ</th>
                                            <th>Ngày đăng ký</th>
                                            <th>Tổng đơn hàng</th>
                                            <th>Tổng chi tiêu</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>1</td>
                                            <td>Nguyễn Văn A</td>
                                            <td>nguyenvana@email.com</td>
                                            <td>0123456789</td>
                                            <td>123 Đường ABC, Quận 1, TP.HCM</td>
                                            <td>15/08/2025</td>
                                            <td>5</td>
                                            <td>2,500,000 VNĐ</td>
                                            <td><span class="label label-success">Hoạt động</span></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="viewCustomer(1)">
                                                    <i class="fa fa-eye"></i> Xem
                                                </button>
                                                <button class="btn btn-warning btn-xs" onclick="editCustomer(1)">
                                                    <i class="fa fa-edit"></i> Sửa
                                                </button>
                                                <button class="btn btn-danger btn-xs" onclick="deleteCustomer(1)">
                                                    <i class="fa fa-trash"></i> Xóa
                                                </button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>2</td>
                                            <td>Trần Thị B</td>
                                            <td>tranthib@email.com</td>
                                            <td>0987654321</td>
                                            <td>456 Đường XYZ, Quận 2, TP.HCM</td>
                                            <td>20/08/2025</td>
                                            <td>3</td>
                                            <td>1,800,000 VNĐ</td>
                                            <td><span class="label label-success">Hoạt động</span></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="viewCustomer(2)">
                                                    <i class="fa fa-eye"></i> Xem
                                                </button>
                                                <button class="btn btn-warning btn-xs" onclick="editCustomer(2)">
                                                    <i class="fa fa-edit"></i> Sửa
                                                </button>
                                                <button class="btn btn-danger btn-xs" onclick="deleteCustomer(2)">
                                                    <i class="fa fa-trash"></i> Xóa
                                                </button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>3</td>
                                            <td>Lê Văn C</td>
                                            <td>levanc@email.com</td>
                                            <td>0369852147</td>
                                            <td>789 Đường DEF, Quận 3, TP.HCM</td>
                                            <td>10/09/2025</td>
                                            <td>2</td>
                                            <td>3,200,000 VNĐ</td>
                                            <td><span class="label label-success">Hoạt động</span></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="viewCustomer(3)">
                                                    <i class="fa fa-eye"></i> Xem
                                                </button>
                                                <button class="btn btn-warning btn-xs" onclick="editCustomer(3)">
                                                    <i class="fa fa-edit"></i> Sửa
                                                </button>
                                                <button class="btn btn-danger btn-xs" onclick="deleteCustomer(3)">
                                                    <i class="fa fa-trash"></i> Xóa
                                                </button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>4</td>
                                            <td>Phạm Thị D</td>
                                            <td>phamthid@email.com</td>
                                            <td>0741852963</td>
                                            <td>321 Đường GHI, Quận 4, TP.HCM</td>
                                            <td>05/09/2025</td>
                                            <td>1</td>
                                            <td>750,000 VNĐ</td>
                                            <td><span class="label label-warning">Tạm khóa</span></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="viewCustomer(4)">
                                                    <i class="fa fa-eye"></i> Xem
                                                </button>
                                                <button class="btn btn-warning btn-xs" onclick="editCustomer(4)">
                                                    <i class="fa fa-edit"></i> Sửa
                                                </button>
                                                <button class="btn btn-success btn-xs" onclick="activateCustomer(4)">
                                                    <i class="fa fa-unlock"></i> Kích hoạt
                                                </button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>5</td>
                                            <td>Hoàng Văn E</td>
                                            <td>hoangvane@email.com</td>
                                            <td>0852741963</td>
                                            <td>654 Đường JKL, Quận 5, TP.HCM</td>
                                            <td>01/09/2025</td>
                                            <td>0</td>
                                            <td>0 VNĐ</td>
                                            <td><span class="label label-danger">Đã xóa</span></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="viewCustomer(5)">
                                                    <i class="fa fa-eye"></i> Xem
                                                </button>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </section><!-- /.content -->
        </aside><!-- /.right-side -->
    </div><!-- ./wrapper -->

    <!-- Modal thêm khách hàng -->
    <div class="modal fade" id="addCustomerModal" tabindex="-1" role="dialog" aria-labelledby="addCustomerModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="addCustomerModalLabel">Thêm khách hàng mới</h4>
                </div>
                <div class="modal-body">
                    <form id="addCustomerForm">
                        <div class="form-group">
                            <label for="customerName">Họ tên:</label>
                            <input type="text" class="form-control" id="customerName" required>
                        </div>
                        <div class="form-group">
                            <label for="customerEmail">Email:</label>
                            <input type="email" class="form-control" id="customerEmail" required>
                        </div>
                        <div class="form-group">
                            <label for="customerPhone">Số điện thoại:</label>
                            <input type="tel" class="form-control" id="customerPhone" required>
                        </div>
                        <div class="form-group">
                            <label for="customerAddress">Địa chỉ:</label>
                            <textarea class="form-control" id="customerAddress" rows="3" required></textarea>
                        </div>
                        <div class="form-group">
                            <label for="customerPassword">Mật khẩu:</label>
                            <input type="password" class="form-control" id="customerPassword" required>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="saveCustomer()">Lưu khách hàng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal xem chi tiết khách hàng -->
    <div class="modal fade" id="customerDetailModal" tabindex="-1" role="dialog" aria-labelledby="customerDetailModalLabel">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="customerDetailModalLabel">Chi tiết khách hàng</h4>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <h5>Thông tin cá nhân</h5>
                            <p><strong>Họ tên:</strong> <span id="detailCustomerName"></span></p>
                            <p><strong>Email:</strong> <span id="detailCustomerEmail"></span></p>
                            <p><strong>Số điện thoại:</strong> <span id="detailCustomerPhone"></span></p>
                            <p><strong>Địa chỉ:</strong> <span id="detailCustomerAddress"></span></p>
                            <p><strong>Ngày đăng ký:</strong> <span id="detailCustomerJoinDate"></span></p>
                        </div>
                        <div class="col-md-6">
                            <h5>Thống kê mua hàng</h5>
                            <p><strong>Tổng đơn hàng:</strong> <span id="detailTotalOrders"></span></p>
                            <p><strong>Tổng chi tiêu:</strong> <span id="detailTotalSpent"></span></p>
                            <p><strong>Đơn hàng gần nhất:</strong> <span id="detailLastOrder"></span></p>
                            <p><strong>Trạng thái:</strong> <span id="detailCustomerStatus"></span></p>
                        </div>
                    </div>
                    <hr>
                    <h5>Lịch sử đơn hàng</h5>
                    <div id="customerOrders"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
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
        $(document).ready(function() {
            $('#customersTable').DataTable({
                "language": {
                    "url": "//cdn.datatables.net/plug-ins/1.10.25/i18n/Vietnamese.json"
                }
            });
        });

        function viewCustomer(id) {
            // Mock data - trong thực tế sẽ lấy từ server
            document.getElementById('detailCustomerName').textContent = 'Nguyễn Văn A';
            document.getElementById('detailCustomerEmail').textContent = 'nguyenvana@email.com';
            document.getElementById('detailCustomerPhone').textContent = '0123456789';
            document.getElementById('detailCustomerAddress').textContent = '123 Đường ABC, Quận 1, TP.HCM';
            document.getElementById('detailCustomerJoinDate').textContent = '15/08/2025';
            document.getElementById('detailTotalOrders').textContent = '5';
            document.getElementById('detailTotalSpent').textContent = '2,500,000 VNĐ';
            document.getElementById('detailLastOrder').textContent = '21/09/2025';
            document.getElementById('detailCustomerStatus').innerHTML = '<span class="label label-success">Hoạt động</span>';
            
            document.getElementById('customerOrders').innerHTML = `
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>Mã đơn hàng</th>
                            <th>Ngày đặt</th>
                            <th>Tổng tiền</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>#ORD001</td>
                            <td>21/09/2025</td>
                            <td>1,000,000 VNĐ</td>
                            <td><span class="label label-warning">Đang xử lý</span></td>
                        </tr>
                        <tr>
                            <td>#ORD002</td>
                            <td>15/09/2025</td>
                            <td>750,000 VNĐ</td>
                            <td><span class="label label-success">Hoàn thành</span></td>
                        </tr>
                    </tbody>
                </table>
            `;
            
            $('#customerDetailModal').modal('show');
        }

        function editCustomer(id) {
            alert('Chỉnh sửa khách hàng ID: ' + id);
            // Thêm logic chỉnh sửa khách hàng ở đây
        }

        function deleteCustomer(id) {
            if (confirm('Bạn có chắc chắn muốn xóa khách hàng này?')) {
                alert('Đã xóa khách hàng ID: ' + id);
                // Thêm logic xóa khách hàng ở đây
            }
        }

        function activateCustomer(id) {
            if (confirm('Bạn có chắc chắn muốn kích hoạt khách hàng này?')) {
                alert('Đã kích hoạt khách hàng ID: ' + id);
                // Thêm logic kích hoạt khách hàng ở đây
            }
        }

        function saveCustomer() {
            var customerName = document.getElementById('customerName').value;
            var customerEmail = document.getElementById('customerEmail').value;
            var customerPhone = document.getElementById('customerPhone').value;
            var customerAddress = document.getElementById('customerAddress').value;
            var customerPassword = document.getElementById('customerPassword').value;

            if (customerName && customerEmail && customerPhone && customerAddress && customerPassword) {
                alert('Đã lưu khách hàng: ' + customerName);
                $('#addCustomerModal').modal('hide');
                // Thêm logic lưu khách hàng vào database ở đây
            } else {
                alert('Vui lòng điền đầy đủ thông tin bắt buộc');
            }
        }
    </script>
</body>
</html>
