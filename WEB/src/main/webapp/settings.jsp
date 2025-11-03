<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng điều khiển | Cài đặt</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <!-- bootstrap 3.0.2 -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- font Awesome -->
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Ionicons -->
    <link href="css/ionicons.min.css" rel="stylesheet" type="text/css" />
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
                <ul class="sidebar-menu">
                    <li>
                        <a href="admin.jsp">
                            <i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
                        </a>
                    </li>
                    <li>
                        <a href="product">
                            <i class="fa fa-shopping-cart"></i> <span>Quản lý sản phẩm</span>
                        </a>
                    </li>
                    <li>
                        <a href="orders.jsp">
                            <i class="fa fa-file-text-o"></i> <span>Quản lý đơn hàng</span>
                        </a>
                    </li>
                    <li>
                        <a href="customers">
                            <i class="fa fa-users"></i> <span>Quản lý khách hàng</span>
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
                    <li class="active">
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
                    <div class="col-md-12">
                        <div class="panel">
                            <header class="panel-heading">
                                <h3>Cài đặt hệ thống</h3>
                            </header>
                            <div class="panel-body">
                                <!-- Tab navigation -->
                                <ul class="nav nav-tabs" role="tablist">
                                    <li role="presentation" class="active">
                                        <a href="#general" aria-controls="general" role="tab" data-toggle="tab">
                                            <i class="fa fa-cog"></i> Cài đặt chung
                                        </a>
                                    </li>
                                    <li role="presentation">
                                        <a href="#email" aria-controls="email" role="tab" data-toggle="tab">
                                            <i class="fa fa-envelope"></i> Cài đặt email
                                        </a>
                                    </li>
                                    <li role="presentation">
                                        <a href="#payment" aria-controls="payment" role="tab" data-toggle="tab">
                                            <i class="fa fa-credit-card"></i> Thanh toán
                                        </a>
                                    </li>
                                    <li role="presentation">
                                        <a href="#security" aria-controls="security" role="tab" data-toggle="tab">
                                            <i class="fa fa-shield"></i> Bảo mật
                                        </a>
                                    </li>
                                    <li role="presentation">
                                        <a href="#backup" aria-controls="backup" role="tab" data-toggle="tab">
                                            <i class="fa fa-database"></i> Sao lưu
                                        </a>
                                    </li>
                                </ul>

                                <!-- Tab content -->
                                <div class="tab-content" style="margin-top: 20px;">
                                    <!-- Cài đặt chung -->
                                    <div role="tabpanel" class="tab-pane active" id="general">
                                        <form id="generalSettingsForm">
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label for="siteName">Tên website:</label>
                                                        <input type="text" class="form-control" id="siteName" value="Cửa hàng trực tuyến">
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="siteDescription">Mô tả website:</label>
                                                        <textarea class="form-control" id="siteDescription" rows="3">Cửa hàng trực tuyến chuyên bán các sản phẩm chất lượng cao</textarea>
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="siteEmail">Email liên hệ:</label>
                                                        <input type="email" class="form-control" id="siteEmail" value="contact@example.com">
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="sitePhone">Số điện thoại:</label>
                                                        <input type="tel" class="form-control" id="sitePhone" value="0123456789">
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label for="siteAddress">Địa chỉ:</label>
                                                        <textarea class="form-control" id="siteAddress" rows="3">123 Đường ABC, Quận 1, TP.HCM</textarea>
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="currency">Đơn vị tiền tệ:</label>
                                                        <select class="form-control" id="currency">
                                                            <option value="VND" selected>Việt Nam Đồng (VNĐ)</option>
                                                            <option value="USD">US Dollar ($)</option>
                                                            <option value="EUR">Euro (€)</option>
                                                        </select>
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="timezone">Múi giờ:</label>
                                                        <select class="form-control" id="timezone">
                                                            <option value="Asia/Ho_Chi_Minh" selected>Asia/Ho_Chi_Minh</option>
                                                            <option value="UTC">UTC</option>
                                                            <option value="America/New_York">America/New_York</option>
                                                        </select>
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="language">Ngôn ngữ:</label>
                                                        <select class="form-control" id="language">
                                                            <option value="vi" selected>Tiếng Việt</option>
                                                            <option value="en">English</option>
                                                            <option value="zh">中文</option>
                                                        </select>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <button type="button" class="btn btn-primary" onclick="saveGeneralSettings()">
                                                    <i class="fa fa-save"></i> Lưu cài đặt chung
                                                </button>
                                            </div>
                                        </form>
                                    </div>

                                    <!-- Cài đặt email -->
                                    <div role="tabpanel" class="tab-pane" id="email">
                                        <form id="emailSettingsForm">
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label for="smtpHost">SMTP Host:</label>
                                                        <input type="text" class="form-control" id="smtpHost" value="smtp.gmail.com">
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="smtpPort">SMTP Port:</label>
                                                        <input type="number" class="form-control" id="smtpPort" value="587">
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="smtpUsername">Tên đăng nhập:</label>
                                                        <input type="text" class="form-control" id="smtpUsername" value="your-email@gmail.com">
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label for="smtpPassword">Mật khẩu:</label>
                                                        <input type="password" class="form-control" id="smtpPassword" value="">
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="smtpEncryption">Mã hóa:</label>
                                                        <select class="form-control" id="smtpEncryption">
                                                            <option value="tls" selected>TLS</option>
                                                            <option value="ssl">SSL</option>
                                                            <option value="none">Không</option>
                                                        </select>
                                                    </div>
                                                    <div class="form-group">
                                                        <label>
                                                            <input type="checkbox" id="emailNotifications"> Gửi thông báo email
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <button type="button" class="btn btn-primary" onclick="saveEmailSettings()">
                                                    <i class="fa fa-save"></i> Lưu cài đặt email
                                                </button>
                                                <button type="button" class="btn btn-info" onclick="testEmail()">
                                                    <i class="fa fa-send"></i> Test email
                                                </button>
                                            </div>
                                        </form>
                                    </div>

                                    <!-- Cài đặt thanh toán -->
                                    <div role="tabpanel" class="tab-pane" id="payment">
                                        <form id="paymentSettingsForm">
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <h5>Thanh toán trực tuyến</h5>
                                                    <div class="form-group">
                                                        <label>
                                                            <input type="checkbox" id="enableOnlinePayment" checked> Kích hoạt thanh toán trực tuyến
                                                        </label>
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="paymentGateway">Cổng thanh toán:</label>
                                                        <select class="form-control" id="paymentGateway">
                                                            <option value="vnpay" selected>VNPay</option>
                                                            <option value="momo">MoMo</option>
                                                            <option value="zalopay">ZaloPay</option>
                                                            <option value="paypal">PayPal</option>
                                                        </select>
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="merchantId">Merchant ID:</label>
                                                        <input type="text" class="form-control" id="merchantId" value="">
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <h5>Thanh toán khi nhận hàng (COD)</h5>
                                                    <div class="form-group">
                                                        <label>
                                                            <input type="checkbox" id="enableCOD" checked> Kích hoạt COD
                                                        </label>
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="codFee">Phí COD:</label>
                                                        <input type="number" class="form-control" id="codFee" value="30000">
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="minOrderAmount">Đơn hàng tối thiểu:</label>
                                                        <input type="number" class="form-control" id="minOrderAmount" value="100000">
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <button type="button" class="btn btn-primary" onclick="savePaymentSettings()">
                                                    <i class="fa fa-save"></i> Lưu cài đặt thanh toán
                                                </button>
                                            </div>
                                        </form>
                                    </div>

                                    <!-- Cài đặt bảo mật -->
                                    <div role="tabpanel" class="tab-pane" id="security">
                                        <form id="securitySettingsForm">
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <h5>Bảo mật đăng nhập</h5>
                                                    <div class="form-group">
                                                        <label for="sessionTimeout">Thời gian hết phiên (phút):</label>
                                                        <input type="number" class="form-control" id="sessionTimeout" value="30">
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="maxLoginAttempts">Số lần đăng nhập sai tối đa:</label>
                                                        <input type="number" class="form-control" id="maxLoginAttempts" value="5">
                                                    </div>
                                                    <div class="form-group">
                                                        <label>
                                                            <input type="checkbox" id="requireStrongPassword" checked> Yêu cầu mật khẩu mạnh
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <h5>Bảo mật dữ liệu</h5>
                                                    <div class="form-group">
                                                        <label>
                                                            <input type="checkbox" id="enableSSL" checked> Kích hoạt SSL
                                                        </label>
                                                    </div>
                                                    <div class="form-group">
                                                        <label>
                                                            <input type="checkbox" id="enableBackup" checked> Tự động sao lưu
                                                        </label>
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="backupFrequency">Tần suất sao lưu:</label>
                                                        <select class="form-control" id="backupFrequency">
                                                            <option value="daily" selected>Hàng ngày</option>
                                                            <option value="weekly">Hàng tuần</option>
                                                            <option value="monthly">Hàng tháng</option>
                                                        </select>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <button type="button" class="btn btn-primary" onclick="saveSecuritySettings()">
                                                    <i class="fa fa-save"></i> Lưu cài đặt bảo mật
                                                </button>
                                            </div>
                                        </form>
                                    </div>

                                    <!-- Sao lưu -->
                                    <div role="tabpanel" class="tab-pane" id="backup">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <h5>Sao lưu dữ liệu</h5>
                                                <div class="form-group">
                                                    <button type="button" class="btn btn-success" onclick="createBackup()">
                                                        <i class="fa fa-download"></i> Tạo sao lưu ngay
                                                    </button>
                                                </div>
                                                <div class="form-group">
                                                    <label for="backupPath">Đường dẫn sao lưu:</label>
                                                    <input type="text" class="form-control" id="backupPath" value="/backups/" readonly>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <h5>Khôi phục dữ liệu</h5>
                                                <div class="form-group">
                                                    <label for="backupFile">Chọn file sao lưu:</label>
                                                    <input type="file" class="form-control" id="backupFile" accept=".sql,.zip">
                                                </div>
                                                <div class="form-group">
                                                    <button type="button" class="btn btn-warning" onclick="restoreBackup()">
                                                        <i class="fa fa-upload"></i> Khôi phục dữ liệu
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                        <hr>
                                        <h5>Lịch sử sao lưu</h5>
                                        <div class="table-responsive">
                                            <table class="table table-hover">
                                                <thead>
                                                    <tr>
                                                        <th>Ngày tạo</th>
                                                        <th>Kích thước</th>
                                                        <th>Trạng thái</th>
                                                        <th>Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <tr>
                                                        <td>21/09/2025 10:30</td>
                                                        <td>15.2 MB</td>
                                                        <td><span class="label label-success">Thành công</span></td>
                                                        <td>
                                                            <button class="btn btn-info btn-xs" onclick="downloadBackup('backup_20250921_1030.sql')">
                                                                <i class="fa fa-download"></i> Tải về
                                                            </button>
                                                            <button class="btn btn-danger btn-xs" onclick="deleteBackup('backup_20250921_1030.sql')">
                                                                <i class="fa fa-trash"></i> Xóa
                                                            </button>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>20/09/2025 10:30</td>
                                                        <td>14.8 MB</td>
                                                        <td><span class="label label-success">Thành công</span></td>
                                                        <td>
                                                            <button class="btn btn-info btn-xs" onclick="downloadBackup('backup_20250920_1030.sql')">
                                                                <i class="fa fa-download"></i> Tải về
                                                            </button>
                                                            <button class="btn btn-danger btn-xs" onclick="deleteBackup('backup_20250920_1030.sql')">
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
    <!-- Director App -->
    <script src="js/Director/app.js" type="text/javascript"></script>

    <script type="text/javascript">
        function saveGeneralSettings() {
            alert('Đã lưu cài đặt chung');
            // Thêm logic lưu cài đặt chung ở đây
        }

        function saveEmailSettings() {
            alert('Đã lưu cài đặt email');
            // Thêm logic lưu cài đặt email ở đây
        }

        function testEmail() {
            alert('Đang gửi email test...');
            // Thêm logic test email ở đây
        }

        function savePaymentSettings() {
            alert('Đã lưu cài đặt thanh toán');
            // Thêm logic lưu cài đặt thanh toán ở đây
        }

        function saveSecuritySettings() {
            alert('Đã lưu cài đặt bảo mật');
            // Thêm logic lưu cài đặt bảo mật ở đây
        }

        function createBackup() {
            if (confirm('Bạn có chắc chắn muốn tạo sao lưu dữ liệu?')) {
                alert('Đang tạo sao lưu...');
                // Thêm logic tạo sao lưu ở đây
            }
        }

        function restoreBackup() {
            var file = document.getElementById('backupFile').files[0];
            if (!file) {
                alert('Vui lòng chọn file sao lưu');
                return;
            }
            
            if (confirm('Bạn có chắc chắn muốn khôi phục dữ liệu từ file này? Dữ liệu hiện tại sẽ bị ghi đè.')) {
                alert('Đang khôi phục dữ liệu...');
                // Thêm logic khôi phục dữ liệu ở đây
            }
        }

        function downloadBackup(filename) {
            alert('Đang tải file: ' + filename);
            // Thêm logic tải file sao lưu ở đây
        }

        function deleteBackup(filename) {
            if (confirm('Bạn có chắc chắn muốn xóa file sao lưu: ' + filename + '?')) {
                alert('Đã xóa file: ' + filename);
                // Thêm logic xóa file sao lưu ở đây
            }
        }
    </script>
</body>
</html>
