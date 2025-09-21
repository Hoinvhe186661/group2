<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Panel | Quản lý sản phẩm</title>
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
                    <li class="active">
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
                                <h3>Quản lý sản phẩm</h3>
                                <div class="panel-tools">
                                    <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addProductModal">
                                        <i class="fa fa-plus"></i> Thêm sản phẩm mới
                                    </button>
                                </div>
                            </header>
                            <div class="panel-body table-responsive">
                                <table class="table table-hover" id="productsTable">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Hình ảnh</th>
                                            <th>Tên sản phẩm</th>
                                            <th>Giá</th>
                                            <th>Số lượng</th>
                                            <th>Danh mục</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>1</td>
                                            <td><img src="../images/sanpham1.jpg" width="50" height="50" class="img-thumbnail"></td>
                                            <td>Sản phẩm 1</td>
                                            <td>500,000 VNĐ</td>
                                            <td>25</td>
                                            <td>Điện tử</td>
                                            <td><span class="label label-success">Còn hàng</span></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="editProduct(1)">
                                                    <i class="fa fa-edit"></i> Sửa
                                                </button>
                                                <button class="btn btn-danger btn-xs" onclick="deleteProduct(1)">
                                                    <i class="fa fa-trash"></i> Xóa
                                                </button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>2</td>
                                            <td><img src="../images/sanpham2.jpg" width="50" height="50" class="img-thumbnail"></td>
                                            <td>Sản phẩm 2</td>
                                            <td>750,000 VNĐ</td>
                                            <td>15</td>
                                            <td>Thời trang</td>
                                            <td><span class="label label-success">Còn hàng</span></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="editProduct(2)">
                                                    <i class="fa fa-edit"></i> Sửa
                                                </button>
                                                <button class="btn btn-danger btn-xs" onclick="deleteProduct(2)">
                                                    <i class="fa fa-trash"></i> Xóa
                                                </button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>3</td>
                                            <td><img src="../images/sanpham3.jpg" width="50" height="50" class="img-thumbnail"></td>
                                            <td>Sản phẩm 3</td>
                                            <td>1,200,000 VNĐ</td>
                                            <td>0</td>
                                            <td>Gia dụng</td>
                                            <td><span class="label label-danger">Hết hàng</span></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="editProduct(3)">
                                                    <i class="fa fa-edit"></i> Sửa
                                                </button>
                                                <button class="btn btn-danger btn-xs" onclick="deleteProduct(3)">
                                                    <i class="fa fa-trash"></i> Xóa
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

    <!-- Modal thêm sản phẩm -->
    <div class="modal fade" id="addProductModal" tabindex="-1" role="dialog" aria-labelledby="addProductModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="addProductModalLabel">Thêm sản phẩm mới</h4>
                </div>
                <div class="modal-body">
                    <form id="addProductForm">
                        <div class="form-group">
                            <label for="productName">Tên sản phẩm:</label>
                            <input type="text" class="form-control" id="productName" required>
                        </div>
                        <div class="form-group">
                            <label for="productPrice">Giá:</label>
                            <input type="number" class="form-control" id="productPrice" required>
                        </div>
                        <div class="form-group">
                            <label for="productQuantity">Số lượng:</label>
                            <input type="number" class="form-control" id="productQuantity" required>
                        </div>
                        <div class="form-group">
                            <label for="productCategory">Danh mục:</label>
                            <select class="form-control" id="productCategory" required>
                                <option value="">Chọn danh mục</option>
                                <option value="dien-tu">Điện tử</option>
                                <option value="thoi-trang">Thời trang</option>
                                <option value="gia-dung">Gia dụng</option>
                                <option value="sach">Sách</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="productDescription">Mô tả:</label>
                            <textarea class="form-control" id="productDescription" rows="3"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="productImage">Hình ảnh:</label>
                            <input type="file" class="form-control" id="productImage" accept="image/*">
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="saveProduct()">Lưu sản phẩm</button>
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
            $('#productsTable').DataTable({
                "language": {
                    "url": "//cdn.datatables.net/plug-ins/1.10.25/i18n/Vietnamese.json"
                }
            });
        });

        function editProduct(id) {
            alert('Chỉnh sửa sản phẩm ID: ' + id);
            // Thêm logic chỉnh sửa sản phẩm ở đây
        }

        function deleteProduct(id) {
            if (confirm('Bạn có chắc chắn muốn xóa sản phẩm này?')) {
                alert('Đã xóa sản phẩm ID: ' + id);
                // Thêm logic xóa sản phẩm ở đây
            }
        }

        function saveProduct() {
            var productName = document.getElementById('productName').value;
            var productPrice = document.getElementById('productPrice').value;
            var productQuantity = document.getElementById('productQuantity').value;
            var productCategory = document.getElementById('productCategory').value;
            var productDescription = document.getElementById('productDescription').value;

            if (productName && productPrice && productQuantity && productCategory) {
                alert('Đã lưu sản phẩm: ' + productName);
                $('#addProductModal').modal('hide');
                // Thêm logic lưu sản phẩm vào database ở đây
            } else {
                alert('Vui lòng điền đầy đủ thông tin bắt buộc');
            }
        }
    </script>
</body>
</html>
