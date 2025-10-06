<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Login | Đăng nhập quản trị</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <!-- bootstrap 3.0.2 -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- font Awesome -->
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="css/style.css" rel="stylesheet" type="text/css" />
    <link href='http://fonts.googleapis.com/css?family=Lato' rel='stylesheet' type='text/css'>
    
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-box {
            background: white;
            border-radius: 10px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            padding: 40px;
            width: 100%;
            max-width: 400px;
        }
        .login-logo {
            text-align: center;
            margin-bottom: 30px;
        }
        .login-logo h1 {
            color: #333;
            font-size: 28px;
            font-weight: 300;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-control {
            height: 45px;
            border-radius: 5px;
            border: 1px solid #ddd;
            padding: 0 15px;
        }
        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        .btn-login {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            height: 45px;
            border-radius: 5px;
            color: white;
            font-weight: 500;
            width: 100%;
        }
        .btn-login:hover {
            background: linear-gradient(135deg, #5a6fd8 0%, #6a4190 100%);
            color: white;
        }
        .alert {
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .back-link {
            text-align: center;
            margin-top: 20px;
        }
        .back-link a {
            color: #667eea;
            text-decoration: none;
        }
        .back-link a:hover {
            text-decoration: underline;
        }
        
        /* Validation styles */
        .form-group.has-error .form-control {
            border-color: #d9534f;
            box-shadow: 0 0 0 0.2rem rgba(217, 83, 79, 0.25);
        }
        
        .form-group.has-error .input-group-addon {
            background-color: #f2dede;
            border-color: #d9534f;
            color: #a94442;
        }
        
        .help-block {
            margin-top: 5px;
            margin-bottom: 0;
            font-size: 12px;
        }
        
        .help-block i {
            margin-right: 5px;
        }
        
        /* Alert animations */
        .alert {
            animation: slideDown 0.3s ease-out;
        }
        
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        /* Loading button styles */
        .btn-login:disabled {
            opacity: 0.7;
            cursor: not-allowed;
        }
        
        /* Demo buttons styles */
        .btn-group-vertical .btn {
            border-radius: 3px;
            font-size: 11px;
            padding: 5px 8px;
        }
    </style>
</head>
<body>
    <div class="login-box">
        <div class="login-logo">
            <h1><i class="fa fa-shield"></i> Bảng điều khiển quản trị</h1>
            <p>Đăng nhập quản trị hệ thống</p>
        </div>
        
        <% 
            String error = request.getParameter("error");
            String errorType = request.getParameter("errorType");
            String message = request.getParameter("message");
            
            if ("true".equals(error)) {
                String errorMessage = "Tên đăng nhập hoặc mật khẩu không đúng!";
                String alertClass = "alert-danger";
                String icon = "fa-exclamation-triangle";
                
                if ("invalid_credentials".equals(errorType)) {
                    errorMessage = "Tên đăng nhập hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại!";
                } else if ("account_locked".equals(errorType)) {
                    errorMessage = "Tài khoản đã bị khóa. Vui lòng liên hệ quản trị viên!";
                    alertClass = "alert-warning";
                    icon = "fa-lock";
                } else if ("session_expired".equals(errorType)) {
                    errorMessage = "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!";
                    alertClass = "alert-info";
                    icon = "fa-clock-o";
                } else if ("access_denied".equals(errorType)) {
                    errorMessage = "Bạn không có quyền truy cập vào hệ thống quản trị!";
                    alertClass = "alert-danger";
                    icon = "fa-ban";
                }
                
                if (message != null && !message.trim().isEmpty()) {
                    errorMessage = message;
                }
        %>
            <div class="alert <%= alertClass %> alert-dismissible fade in" role="alert">
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <i class="fa <%= icon %>"></i> 
                <strong>Lỗi đăng nhập:</strong> <%= errorMessage %>
            </div>
        <% } %>
        
        <% 
            String success = request.getParameter("success");
            String successMessage = request.getParameter("message");
            
            // Chỉ hiển thị success message khi không có error và có success=true
            if ("true".equals(success) && !"true".equals(error)) {
                if (successMessage == null || successMessage.trim().isEmpty()) {
                    successMessage = "Đăng nhập thành công!";
                }
        %>
            <div class="alert alert-success alert-dismissible fade in" role="alert">
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <i class="fa fa-check-circle"></i> 
                <strong>Thành công:</strong> <%= successMessage %>
            </div>
        <% } %>
        
        <form action="<%= request.getContextPath() %>/login" method="post" id="loginForm">
            <div class="form-group">
                <label for="j_username">Tên đăng nhập:</label>
                <div class="input-group">
                    <span class="input-group-addon"><i class="fa fa-user"></i></span>
                    <input type="text" class="form-control" id="j_username" name="j_username" 
                           placeholder="Nhập tên đăng nhập" required autofocus>
                </div>
            </div>
            
            <div class="form-group">
                <label for="j_password">Mật khẩu:</label>
                <div class="input-group">
                    <span class="input-group-addon"><i class="fa fa-lock"></i></span>
                    <input type="password" class="form-control" id="j_password" name="j_password" 
                           placeholder="Nhập mật khẩu" required>
                </div>
            </div>
            
            <div class="form-group">
                <label>
                    <input type="checkbox" id="rememberMe" name="rememberMe"> Ghi nhớ đăng nhập
                </label>
            </div>
            
            <div class="form-group">
                <button type="submit" class="btn btn-login">
                    <i class="fa fa-sign-in"></i> Đăng nhập
                </button>
            </div>
        </form>
        
        <div class="back-link">
            <a href="../index.jsp">
                <i class="fa fa-arrow-left"></i> Quay lại trang chủ
            </a>
        </div>
        
        <div style="text-align: center; margin-top: 20px; color: #666; font-size: 12px;">
            <p>© 2025 Bảng điều khiển quản trị. Tất cả quyền được bảo lưu.</p>
        </div>
    </div>

    <!-- jQuery 2.0.2 -->
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
    <script src="js/jquery.min.js" type="text/javascript"></script>
    <!-- Bootstrap -->
    <script src="js/bootstrap.min.js" type="text/javascript"></script>

    <script type="text/javascript">
        $(document).ready(function() {
            // Focus vào trường username khi trang load
            $('#j_username').focus();
            
            // Xử lý form submit
            $('#loginForm').on('submit', function(e) {
                var username = $('#j_username').val().trim();
                var password = $('#j_password').val().trim();
                
                // Xóa các thông báo lỗi cũ
                $('.alert').remove();
                $('.form-group').removeClass('has-error');
                $('.help-block').remove();
                
                var hasError = false;
                var errorMessages = [];
                
                // Validation username
                if (!username) {
                    showFieldError('#j_username', 'Vui lòng nhập tên đăng nhập!');
                    hasError = true;
                } else if (username.length < 3) {
                    showFieldError('#j_username', 'Tên đăng nhập phải có ít nhất 3 ký tự!');
                    hasError = true;
                } else if (!/^[a-zA-Z0-9_]+$/.test(username)) {
                    showFieldError('#j_username', 'Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới!');
                    hasError = true;
                }
                
                // Validation password
                if (!password) {
                    showFieldError('#j_password', 'Vui lòng nhập mật khẩu!');
                    hasError = true;
                } else if (password.length < 6) {
                    showFieldError('#j_password', 'Mật khẩu phải có ít nhất 6 ký tự!');
                    hasError = true;
                }
                
                if (hasError) {
                    e.preventDefault();
                    showAlert('danger', 'Vui lòng kiểm tra lại thông tin đăng nhập!', 'fa-exclamation-triangle');
                    return false;
                }
                
                // Hiển thị loading
                $('.btn-login').html('<i class="fa fa-spinner fa-spin"></i> Đang đăng nhập...');
                $('.btn-login').prop('disabled', true);
                
                // Tự động submit sau 1 giây để hiển thị loading
                setTimeout(function() {
                    // Form sẽ được submit tự nhiên
                }, 100);
            });
            
            // Xử lý phím Enter
            $(document).on('keypress', function(e) {
                if (e.which === 13) {
                    $('#loginForm').submit();
                }
            });
            
            // Xử lý khi người dùng nhập liệu
            $('#j_username, #j_password').on('input', function() {
                $(this).closest('.form-group').removeClass('has-error');
                $(this).closest('.form-group').find('.help-block').remove();
            });
        });
        
        // Hàm hiển thị lỗi cho field
        function showFieldError(fieldSelector, message) {
            var $field = $(fieldSelector);
            var $formGroup = $field.closest('.form-group');
            $formGroup.addClass('has-error');
            $field.after('<span class="help-block text-danger"><i class="fa fa-exclamation-circle"></i> ' + message + '</span>');
        }
        
        // Hàm hiển thị alert
        function showAlert(type, message, icon) {
            var alertClass = 'alert-' + type;
            var alertHtml = '<div class="alert ' + alertClass + ' alert-dismissible fade in" role="alert">' +
                '<button type="button" class="close" data-dismiss="alert" aria-label="Close">' +
                '<span aria-hidden="true">&times;</span></button>' +
                '<i class="fa ' + icon + '"></i> ' + message + '</div>';
            
            $('.login-logo').after(alertHtml);
        }
        
        // Demo credentials (chỉ để test)
        function fillDemoCredentials() {
            $('#j_username').val('admin');
            $('#j_password').val('admin123');
            showAlert('info', 'Đã điền thông tin demo. Bạn có thể đăng nhập ngay!', 'fa-info-circle');
        }
        
        // Hàm test các loại lỗi khác nhau
        function testError(type) {
            var messages = {
                'invalid_credentials': 'Tên đăng nhập hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại!',
                'account_locked': 'Tài khoản đã bị khóa. Vui lòng liên hệ quản trị viên!',
                'session_expired': 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!',
                'access_denied': 'Bạn không có quyền truy cập vào hệ thống quản trị!'
            };
            
            var icons = {
                'invalid_credentials': 'fa-exclamation-triangle',
                'account_locked': 'fa-lock',
                'session_expired': 'fa-clock-o',
                'access_denied': 'fa-ban'
            };
            
            var alertTypes = {
                'invalid_credentials': 'danger',
                'account_locked': 'warning',
                'session_expired': 'info',
                'access_denied': 'danger'
            };
            
            showAlert(alertTypes[type], messages[type], icons[type]);
        }
    </script>
    
    <!-- Demo buttons (chỉ hiển thị trong môi trường development) -->
    <div style="position: fixed; bottom: 20px; right: 20px; z-index: 1000;">
        <div class="btn-group-vertical" role="group">
            <button type="button" class="btn btn-info btn-sm" onclick="fillDemoCredentials()" 
                    style="background: rgba(255,255,255,0.2); border: 1px solid rgba(255,255,255,0.3); color: white; margin-bottom: 5px;">
                <i class="fa fa-key"></i> Demo Login
            </button>
            <button type="button" class="btn btn-warning btn-sm" onclick="testError('invalid_credentials')" 
                    style="background: rgba(255,255,255,0.2); border: 1px solid rgba(255,255,255,0.3); color: white; margin-bottom: 5px;">
                <i class="fa fa-exclamation-triangle"></i> Test Lỗi
            </button>
            <button type="button" class="btn btn-danger btn-sm" onclick="testError('account_locked')" 
                    style="background: rgba(255,255,255,0.2); border: 1px solid rgba(255,255,255,0.3); color: white;">
                <i class="fa fa-lock"></i> Test Khóa
            </button>
        </div>
    </div>
</body>
</html>
