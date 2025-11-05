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
    
    // Kiểm tra quyền truy cập - chỉ admin mới được vào
    if (!"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/403.jsp");
        return;
    }
%>
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
                                            <i class="fa fa-envelope"></i> Liên Hệ 
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
                                                    
                                                </div>
                                                
                                            </div>
                                            <div class="form-group">
                                                <button type="button" class="btn btn-primary" id="saveGeneralBtn" onclick="saveGeneralSettings(this)">
                                                    <i class="fa fa-save"></i> Lưu cài đặt chung
                                                </button>
                                            </div>
                                        </form>
                                    </div>

                                    <!-- Cài đặt Liên hệ  -->
                                    <div role="tabpanel" class="tab-pane" id="email">
                                        <form id="emailSettingsForm">
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label for="siteEmail">Email liên hệ:</label>
                                                        <input type="email" class="form-control" id="siteEmail" value="contact@example.com" required pattern="^[a-zA-Z0-9._%+-]+@(gmail\.com|fpt\.edu\.vn)$" title="Chỉ chấp nhận email miền gmail.com hoặc fpt.edu.vn">
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="sitePhone">Số điện thoại:</label>
                                                        <input type="tel" class="form-control" id="sitePhone" value="0123456789" required pattern="^[0-9]{10,11}$" title="Chỉ cho phép số, 10 hoặc 11 chữ số">
                                                    </div>
                                                   
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label for="siteAddress">Địa chỉ:</label>
                                                        <textarea class="form-control" id="siteAddress" rows="3" required>123 Đường ABC, Quận 1, TP.HCM</textarea>
                                                    </div>
                                                    
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <button type="button" class="btn btn-primary" onclick="saveContactSettings(this)">
                                                    <i class="fa fa-save"></i> Lưu cài đặt Liên Hệ 
                                                </button>
                                            
                                            </div>
                                        </form>
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
        // Load settings từ database khi trang được mở
        window.onload = function() {
            loadSettings();
        };

        function loadSettings() {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'settings?action=getAll', true);
            xhr.withCredentials = true; // Đảm bảo gửi cookie/session
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if (response.success && response.data) {
                            var data = response.data;
                            
                            // Load cài đặt chung
                            if (data.site_name) {
                                document.getElementById('siteName').value = data.site_name;
                            }
                            if (data.site_description) {
                                document.getElementById('siteDescription').value = data.site_description;
                            }
                            if (data.site_email) {
                                document.getElementById('siteEmail').value = data.site_email;
                            }
                            if (data.site_phone) {
                                document.getElementById('sitePhone').value = data.site_phone;
                            }
                            if (data.site_address) {
                                document.getElementById('siteAddress').value = data.site_address;
                            }
                            
                            // (Đã bỏ các trường SMTP không sử dụng)
                        }
                    } catch (e) {
                        console.error('Lỗi khi load settings: ', e);
                    }
                }
            };
            xhr.send();
        }

        function saveGeneralSettings(buttonElement) {
            // Lấy dữ liệu từ form
            var siteName = document.getElementById('siteName').value;
            var siteDescription = document.getElementById('siteDescription').value;
            var siteEmail = document.getElementById('siteEmail').value;
            var sitePhone = document.getElementById('sitePhone').value;
            var siteAddress = document.getElementById('siteAddress').value;

            // Nếu trường email tồn tại, kiểm tra domain hợp lệ (gmail.com | fpt.edu.vn)
            if (siteEmail) {
                var emailPattern = /^[a-zA-Z0-9._%+-]+@(gmail\.com|fpt\.edu\.vn)$/;
                if (!emailPattern.test(siteEmail)) {
                    alert('Email liên hệ chỉ được phép thuộc miền gmail.com hoặc fpt.edu.vn');
                    try { document.getElementById('siteEmail').focus(); } catch (e) {}
                    return;
                }
            }

            // Lấy nút lưu để disable và hiển thị loading
            var saveButton = buttonElement || document.getElementById('saveGeneralBtn');
            var originalText = saveButton.innerHTML;
            saveButton.disabled = true;
            saveButton.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Đang lưu...';

            // Tạo URLSearchParams thay vì FormData
            var params = new URLSearchParams();
            params.append('action', 'saveGeneral');
            params.append('siteName', siteName);
            params.append('siteDescription', siteDescription);
            params.append('siteEmail', siteEmail);
            params.append('sitePhone', sitePhone);
            params.append('siteAddress', siteAddress);

            // Gửi AJAX request
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'settings', true);
            xhr.withCredentials = true; // Đảm bảo gửi cookie/session
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            var response = JSON.parse(xhr.responseText);
                            console.log('Response from server:', response);
                            if (response.success) {
                                // Hiển thị thông báo thành công
                                saveButton.innerHTML = '<i class="fa fa-check"></i> Đã lưu!';
                                saveButton.classList.add('btn-success');
                                
                                // Đợi 1 giây rồi redirect về index.jsp
                                setTimeout(function() {
                                    window.location.href = 'index.jsp';
                                }, 1000);
                            } else {
                                // Khôi phục nút và hiển thị lỗi
                                saveButton.disabled = false;
                                saveButton.innerHTML = originalText;
                                
                                // Xử lý lỗi "Không có quyền truy cập"
                                var errorMessage = response.message || 'Không thể lưu cài đặt';
                                if (errorMessage.includes('Không có quyền truy cập')) {
                                    alert('Lỗi: ' + errorMessage + '\n\nVui lòng đăng nhập lại với tài khoản admin để tiếp tục.');
                                    // Chuyển hướng đến trang login
                                    setTimeout(function() {
                                        window.location.href = 'login.jsp';
                                    }, 2000);
                                } else {
                                    alert('Lỗi: ' + errorMessage);
                                }
                                console.error('Server error:', response);
                            }
                        } catch (e) {
                            // Khôi phục nút và hiển thị lỗi
                            saveButton.disabled = false;
                            saveButton.innerHTML = originalText;
                            alert('Lỗi khi xử lý phản hồi từ server: ' + e.message);
                            console.error('Parse error:', e);
                            console.error('Response text:', xhr.responseText);
                        }
                    } else {
                        // Khôi phục nút và hiển thị lỗi
                        saveButton.disabled = false;
                        saveButton.innerHTML = originalText;
                        alert('Lỗi kết nối đến server (Status: ' + xhr.status + ')');
                        console.error('HTTP error:', xhr.status, xhr.statusText);
                    }
                }
            };
            xhr.send(params.toString());
        }

        function saveContactSettings(buttonElement) {
            // Lấy dữ liệu liên hệ
            var siteEmail = document.getElementById('siteEmail').value;
            var sitePhone = document.getElementById('sitePhone').value;
            var siteAddress = document.getElementById('siteAddress').value;

            // HTML5 validation cho form liên hệ
            var form = document.getElementById('emailSettingsForm');
            if (form && !form.checkValidity()) {
                form.reportValidity();
                return;
            }

            // Bảo vệ bổ sung ở JS: kiểm tra domain email
            var emailPattern = /^[a-zA-Z0-9._%+-]+@(gmail\.com|fpt\.edu\.vn)$/;
            if (!emailPattern.test(siteEmail)) {
                alert('Email liên hệ chỉ được phép thuộc miền gmail.com hoặc fpt.edu.vn');
                try { document.getElementById('siteEmail').focus(); } catch (e) {}
                return;
            }

            // Disable nút và hiển thị trạng thái
            var saveButton = buttonElement;
            var originalText = saveButton.innerHTML;
            saveButton.disabled = true;
            saveButton.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Đang lưu...';

            // Gửi như cài đặt chung để lưu vào bảng settings (site_email/phone/address)
            var params = new URLSearchParams();
            params.append('action', 'saveGeneral');
            params.append('siteEmail', siteEmail);
            params.append('sitePhone', sitePhone);
            params.append('siteAddress', siteAddress);

            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'settings', true);
            xhr.withCredentials = true;
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            var response = JSON.parse(xhr.responseText);
                            if (response.success) {
                                saveButton.innerHTML = '<i class="fa fa-check"></i> Đã lưu!';
                                saveButton.classList.add('btn-success');
                                setTimeout(function() {
                                    window.location.href = 'index.jsp';
                                }, 800);
                            } else {
                                saveButton.disabled = false;
                                saveButton.innerHTML = originalText;
                                alert('Lỗi: ' + (response.message || 'Không thể lưu cài đặt liên hệ'));
                            }
                        } catch (e) {
                            saveButton.disabled = false;
                            saveButton.innerHTML = originalText;
                            alert('Lỗi khi xử lý phản hồi từ server: ' + e.message);
                        }
                    } else {
                        saveButton.disabled = false;
                        saveButton.innerHTML = originalText;
                        alert('Lỗi kết nối đến server (Status: ' + xhr.status + ')');
                    }
                }
            };
            xhr.send(params.toString());
        }
    </script>
</body>
</html>
