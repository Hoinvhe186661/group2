<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Panel | Quản lý đơn hàng</title>
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
                        <a href="../products.jsp">
                            <i class="fa fa-shopping-cart"></i> <span>Quản lý sản phẩm</span>
                        </a>
                    </li>
                    <li class="active">
                        <a href="orders.jsp">
                            <i class="fa fa-file-text-o"></i> <span>Quản lý đơn hàng</span>
                        </a>
                    </li>
                    <li>
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
                                <h3>Quản lý đơn hàng</h3>
                                <div class="panel-tools">
                                    <div class="btn-group">
                                        <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown">
                                            Lọc theo trạng thái <span class="caret"></span>
                                        </button>
                                        <ul class="dropdown-menu">
                                            <li><a href="#" onclick="filterOrders('all')">Tất cả</a></li>
                                            <li><a href="#" onclick="filterOrders('pending')">Chờ xử lý</a></li>
                                            <li><a href="#" onclick="filterOrders('processing')">Đang xử lý</a></li>
                                            <li><a href="#" onclick="filterOrders('shipped')">Đang giao</a></li>
                                            <li><a href="#" onclick="filterOrders('delivered')">Đã giao</a></li>
                                            <li><a href="#" onclick="filterOrders('cancelled')">Đã hủy</a></li>
                                        </ul>
                                    </div>
                                </div>
                            </header>
                            <div class="panel-body table-responsive">
                                <table class="table table-hover" id="ordersTable">
                                    <thead>
                                        <tr>
                                            <th>Mã đơn hàng</th>
                                            <th>Khách hàng</th>
                                            <th>Sản phẩm</th>
                                            <th>Số lượng</th>
                                            <th>Tổng tiền</th>
                                            <th>Ngày đặt</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr data-status="processing">
                                            <td>#ORD001</td>
                                            <td>Nguyễn Văn A<br><small>nguyenvana@email.com</small></td>
                                            <td>Sản phẩm 1</td>
                                            <td>2</td>
                                            <td>1,000,000 VNĐ</td>
                                            <td>21/09/2025</td>
                                            <td><span class="label label-warning">Đang xử lý</span></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="viewOrder('ORD001')">
                                                    <i class="fa fa-eye"></i> Xem
                                                </button>
                                                <button class="btn btn-success btn-xs" onclick="updateOrderStatus('ORD001', 'shipped')">
                                                    <i class="fa fa-truck"></i> Giao hàng
                                                </button>
                                            </td>
                                        </tr>
                                        <tr data-status="shipped">
                                            <td>#ORD002</td>
                                            <td>Trần Thị B<br><small>tranthib@email.com</small></td>
                                            <td>Sản phẩm 2</td>
                                            <td>1</td>
                                            <td>750,000 VNĐ</td>
                                            <td>20/09/2025</td>
                                            <td><span class="label label-info">Đang giao</span></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="viewOrder('ORD002')">
                                                    <i class="fa fa-eye"></i> Xem
                                                </button>
                                                <button class="btn btn-success btn-xs" onclick="updateOrderStatus('ORD002', 'delivered')">
                                                    <i class="fa fa-check"></i> Hoàn thành
                                                </button>
                                            </td>
                                        </tr>
                                        <tr data-status="delivered">
                                            <td>#ORD003</td>
                                            <td>Lê Văn C<br><small>levanc@email.com</small></td>
                                            <td>Sản phẩm 3</td>
                                            <td>3</td>
                                            <td>3,600,000 VNĐ</td>
                                            <td>19/09/2025</td>
                                            <td><span class="label label-success">Đã giao</span></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="viewOrder('ORD003')">
                                                    <i class="fa fa-eye"></i> Xem
                                                </button>
                                            </td>
                                        </tr>
                                        <tr data-status="pending">
                                            <td>#ORD004</td>
                                            <td>Phạm Thị D<br><small>phamthid@email.com</small></td>
                                            <td>Sản phẩm 1, Sản phẩm 2</td>
                                            <td>1, 2</td>
                                            <td>2,000,000 VNĐ</td>
                                            <td>22/09/2025</td>
                                            <td><span class="label label-default">Chờ xử lý</span></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="viewOrder('ORD004')">
                                                    <i class="fa fa-eye"></i> Xem
                                                </button>
                                                <button class="btn btn-primary btn-xs" onclick="updateOrderStatus('ORD004', 'processing')">
                                                    <i class="fa fa-play"></i> Xử lý
                                                </button>
                                                <button class="btn btn-danger btn-xs" onclick="updateOrderStatus('ORD004', 'cancelled')">
                                                    <i class="fa fa-times"></i> Hủy
                                                </button>
                                            </td>
                                        </tr>
                                        <tr data-status="cancelled">
                                            <td>#ORD005</td>
                                            <td>Hoàng Văn E<br><small>hoangvane@email.com</small></td>
                                            <td>Sản phẩm 3</td>
                                            <td>1</td>
                                            <td>1,200,000 VNĐ</td>
                                            <td>18/09/2025</td>
                                            <td><span class="label label-danger">Đã hủy</span></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="viewOrder('ORD005')">
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

    <!-- Modal xem chi tiết đơn hàng -->
    <div class="modal fade" id="orderDetailModal" tabindex="-1" role="dialog" aria-labelledby="orderDetailModalLabel">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="orderDetailModalLabel">Chi tiết đơn hàng</h4>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <h5>Thông tin khách hàng</h5>
                            <p><strong>Tên:</strong> <span id="customerName"></span></p>
                            <p><strong>Email:</strong> <span id="customerEmail"></span></p>
                            <p><strong>Địa chỉ:</strong> <span id="customerAddress"></span></p>
                            <p><strong>Số điện thoại:</strong> <span id="customerPhone"></span></p>
                        </div>
                        <div class="col-md-6">
                            <h5>Thông tin đơn hàng</h5>
                            <p><strong>Mã đơn hàng:</strong> <span id="orderId"></span></p>
                            <p><strong>Ngày đặt:</strong> <span id="orderDate"></span></p>
                            <p><strong>Trạng thái:</strong> <span id="orderStatus"></span></p>
                            <p><strong>Tổng tiền:</strong> <span id="orderTotal"></span></p>
                        </div>
                    </div>
                    <hr>
                    <h5>Chi tiết sản phẩm</h5>
                    <div id="orderItems"></div>
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
            $('#ordersTable').DataTable({
                "language": {
                    "url": "//cdn.datatables.net/plug-ins/1.10.25/i18n/Vietnamese.json"
                }
            });
        });

        function filterOrders(status) {
            if (status === 'all') {
                $('#ordersTable tbody tr').show();
            } else {
                $('#ordersTable tbody tr').hide();
                $('#ordersTable tbody tr[data-status="' + status + '"]').show();
            }
        }

        function viewOrder(orderId) {
            // Mock data - trong thực tế sẽ lấy từ server
            document.getElementById('orderId').textContent = '#' + orderId;
            document.getElementById('customerName').textContent = 'Nguyễn Văn A';
            document.getElementById('customerEmail').textContent = 'nguyenvana@email.com';
            document.getElementById('customerAddress').textContent = '123 Đường ABC, Quận 1, TP.HCM';
            document.getElementById('customerPhone').textContent = '0123456789';
            document.getElementById('orderDate').textContent = '21/09/2025';
            document.getElementById('orderStatus').innerHTML = '<span class="label label-warning">Đang xử lý</span>';
            document.getElementById('orderTotal').textContent = '1,000,000 VNĐ';
            
            document.getElementById('orderItems').innerHTML = `
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>Sản phẩm</th>
                            <th>Số lượng</th>
                            <th>Giá</th>
                            <th>Thành tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Sản phẩm 1</td>
                            <td>2</td>
                            <td>500,000 VNĐ</td>
                            <td>1,000,000 VNĐ</td>
                        </tr>
                    </tbody>
                </table>
            `;
            
            $('#orderDetailModal').modal('show');
        }

        function updateOrderStatus(orderId, newStatus) {
            var statusText = '';
            var statusClass = '';
            
            switch(newStatus) {
                case 'processing':
                    statusText = 'Đang xử lý';
                    statusClass = 'label-warning';
                    break;
                case 'shipped':
                    statusText = 'Đang giao';
                    statusClass = 'label-info';
                    break;
                case 'delivered':
                    statusText = 'Đã giao';
                    statusClass = 'label-success';
                    break;
                case 'cancelled':
                    statusText = 'Đã hủy';
                    statusClass = 'label-danger';
                    break;
            }
            
            if (confirm('Bạn có chắc chắn muốn cập nhật trạng thái đơn hàng ' + orderId + ' thành "' + statusText + '"?')) {
                alert('Đã cập nhật trạng thái đơn hàng ' + orderId + ' thành "' + statusText + '"');
                // Thêm logic cập nhật trạng thái đơn hàng ở đây
            }
        }
    </script>
</body>
</html>
