<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>403 - Truy cập bị từ chối | HL Generator Solutions</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-red: #dc3545;
            --primary-yellow: #ffc107;
            --dark-grey: #343a40;
            --light-grey: #f8f9fa;
            --white: #ffffff;
        }

        body {
            font-family: 'Roboto', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .error-container {
            background: var(--white);
            border-radius: 20px;
            padding: 60px 40px;
            text-align: center;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            max-width: 600px;
            width: 90%;
        }

        .error-code {
            font-size: 8rem;
            font-weight: 900;
            color: var(--primary-red);
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }

        .error-title {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--dark-grey);
            margin-bottom: 20px;
        }

        .error-message {
            font-size: 1.2rem;
            color: #6c757d;
            margin-bottom: 40px;
            line-height: 1.6;
        }

        .error-icon {
            font-size: 4rem;
            color: var(--primary-red);
            margin-bottom: 30px;
            animation: shake 0.5s ease-in-out infinite alternate;
        }

        @keyframes shake {
            0% { transform: translateX(0); }
            100% { transform: translateX(10px); }
        }

        .btn-primary {
            background-color: var(--primary-red);
            border-color: var(--primary-red);
            padding: 12px 30px;
            font-weight: 600;
            border-radius: 50px;
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            background-color: #c82333;
            border-color: #c82333;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3);
        }

        .btn-outline-primary {
            color: var(--primary-red);
            border-color: var(--primary-red);
            padding: 12px 30px;
            font-weight: 600;
            border-radius: 50px;
            margin-left: 15px;
            transition: all 0.3s ease;
        }

        .btn-outline-primary:hover {
            background-color: var(--primary-red);
            border-color: var(--primary-red);
            transform: translateY(-2px);
        }

        .suggestions {
            background: var(--light-grey);
            border-radius: 10px;
            padding: 30px;
            margin-top: 40px;
            text-align: left;
        }

        .suggestions h5 {
            color: var(--dark-grey);
            margin-bottom: 20px;
            font-weight: 600;
        }

        .suggestions ul {
            list-style: none;
            padding: 0;
        }

        .suggestions li {
            padding: 8px 0;
            color: #6c757d;
        }

        .suggestions li i {
            color: var(--primary-red);
            margin-right: 10px;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">
            <i class="fas fa-ban"></i>
        </div>
        
        <div class="error-code">403</div>
        
        <h1 class="error-title">Truy cập bị từ chối</h1>
        
        <p class="error-message">
            Xin lỗi, bạn không có quyền truy cập vào trang này. 
            Vui lòng liên hệ quản trị viên nếu bạn cho rằng đây là lỗi.
        </p>
        
        <div class="d-flex justify-content-center flex-wrap">
            <a href="javascript:history.back()" class="btn btn-primary">
                <i class="fas fa-arrow-left me-2"></i>
                Quay lại
            </a>
            <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-outline-primary">
                <i class="fas fa-home me-2"></i>
                Trang chủ
            </a>
        </div>
        
        <div class="suggestions">
            <h5><i class="fas fa-lightbulb me-2"></i>Gợi ý:</h5>
            <ul>
                <li><i class="fas fa-check"></i>Kiểm tra lại quyền truy cập của tài khoản</li>
                <li><i class="fas fa-check"></i>Đăng nhập với tài khoản có quyền phù hợp</li>
                <li><i class="fas fa-check"></i>Liên hệ quản trị viên để được cấp quyền</li>
                <li><i class="fas fa-check"></i>Quay lại trang trước hoặc trang chủ</li>
            </ul>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto redirect after 30 seconds
        let countdown = 30;
        const countdownElement = document.createElement('div');
        countdownElement.className = 'mt-3 text-muted';
        countdownElement.innerHTML = `Tự động chuyển về trang chủ sau <span id="countdown">${countdown}</span> giây...`;
        document.querySelector('.error-container').appendChild(countdownElement);
        
        const countdownInterval = setInterval(() => {
            countdown--;
            document.getElementById('countdown').textContent = countdown;
            
            if (countdown <= 0) {
                clearInterval(countdownInterval);
                window.location.href = '<%= request.getContextPath() %>/index.jsp';
            }
        }, 1000);
    </script>
</body>
</html>
