<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Lấy context path để sử dụng cho các link
    String contextPath = request.getContextPath();
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>403 - Truy cập bị từ chối | HL Generator</title>
    
    <!-- Bootstrap 3.0.2 -->
    <link href="<%= contextPath %>/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- Font Awesome -->
    <link href="<%= contextPath %>/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="<%= contextPath %>/css/style.css" rel="stylesheet" type="text/css" />
    
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: 'Arial', sans-serif;
        }
        
        .error-container {
            text-align: center;
            background: white;
            padding: 60px 40px;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            max-width: 600px;
            width: 90%;
        }
        
        .error-code {
            font-size: 120px;
            font-weight: bold;
            color: #667eea;
            line-height: 1;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }
        
        .error-icon {
            font-size: 80px;
            color: #f44336;
            margin-bottom: 30px;
            animation: shake 0.5s ease-in-out;
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }
        
        .error-title {
            font-size: 32px;
            color: #333;
            margin-bottom: 20px;
            font-weight: bold;
        }
        
        .error-message {
            font-size: 18px;
            color: #666;
            margin-bottom: 40px;
            line-height: 1.6;
        }
        
        .error-details {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            border-left: 4px solid #f44336;
        }
        
        .error-details p {
            margin: 0;
            color: #555;
            font-size: 14px;
        }
        
        .btn-group {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 12px 30px;
            font-size: 16px;
            border-radius: 8px;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s;
            border: none;
            cursor: pointer;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
            color: white;
            text-decoration: none;
        }
        
        .btn-default {
            background: #f0f0f0;
            color: #333;
        }
        
        .btn-default:hover {
            background: #e0e0e0;
            color: #333;
            text-decoration: none;
            transform: translateY(-2px);
        }
        
        @media (max-width: 768px) {
            .error-code {
                font-size: 80px;
            }
            
            .error-icon {
                font-size: 60px;
            }
            
            .error-title {
                font-size: 24px;
            }
            
            .error-message {
                font-size: 16px;
            }
            
            .btn-group {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">
            <i class="fa fa-ban"></i>
        </div>
        <div class="error-code">403</div>
        <h1 class="error-title">Truy cập bị từ chối</h1>
        <p class="error-message">
            Xin lỗi, bạn không có quyền truy cập vào trang này.
        </p>
        
        <div class="error-details">
            <p>
                <i class="fa fa-info-circle"></i> 
                <strong>Lý do:</strong> Tài khoản của bạn không có quyền cần thiết để xem nội dung này.
            </p>
            <% if (isLoggedIn != null && isLoggedIn && username != null) { %>
            <p style="margin-top: 10px;">
                <i class="fa fa-user"></i> 
                <strong>Người dùng:</strong> <%= username %>
            </p>
            <% } %>
        </div>
        
        <div class="btn-group">
            <% if (isLoggedIn != null && isLoggedIn) { %>
                <a href="<%= contextPath %>/admin.jsp" class="btn btn-primary">
                    <i class="fa fa-home"></i> Về trang chủ
                </a>
            <% } else { %>
                <a href="<%= contextPath %>/login.jsp" class="btn btn-primary">
                    <i class="fa fa-sign-in"></i> Đăng nhập
                </a>
            <% } %>
            <a href="javascript:history.back()" class="btn btn-default">
                <i class="fa fa-arrow-left"></i> Quay lại
            </a>
        </div>
    </div>
</body>
</html>

