<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// XỬ LÝ ĐĂNG NHẬP TRỰC TIẾP TRONG JSP (KHÔNG CẦN SERVLET)
if ("POST".equals(request.getMethod())) {
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    
    // Kiểm tra đăng nhập đơn giản
    if (username != null && password != null && 
        !username.trim().isEmpty() && !password.trim().isEmpty()) {
        
        // Chấp nhận các mật khẩu này
        if ("admin".equals(password) || "password".equals(password) || 
            "admin123".equals(password) || "123456".equals(password)) {
            
            // Đăng nhập thành công
            session.setAttribute("username", username);
            session.setAttribute("isLoggedIn", true);
            session.setAttribute("userRole", "admin");
            
            // Chuyển hướng đến admin.jsp
            response.sendRedirect("admin.jsp");
            return;
        }
    }
}
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Nhập - HL Generator</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .login-box {
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            width: 100%;
            max-width: 400px;
        }
        
        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
            font-size: 24px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: bold;
        }
        
        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 15px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s;
        }
        
        input:focus {
            outline: none;
            border-color: #667eea;
        }
        
        button {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 18px;
            font-weight: bold;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        button:hover {
            transform: translateY(-2px);
        }
        
        .info {
            background: #e7f3ff;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            border-left: 4px solid #007bff;
        }
        
        .error {
            background: #ffe6e6;
            color: #d8000c;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            border-left: 4px solid #d8000c;
        }
        
        .back-link {
            text-align: center;
            margin-top: 20px;
        }
        
        .back-link a {
            color: #667eea;
            text-decoration: none;
        }
        
        code {
            background: #f0f8ff;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
        }
    </style>
</head>
<body>
    <div class="login-box">
        <h2>Chào Mừng Trở Lại</h2>
        
        <% 
        // Hiển thị lỗi nếu có
        if ("POST".equals(request.getMethod())) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            
            if (username == null || password == null || 
                username.trim().isEmpty() || password.trim().isEmpty()) {
        %>
            <div class="error">
                Vui lòng nhập đầy đủ thông tin đăng nhập!
            </div>
        <% 
            } else if (!"admin".equals(password) && !"password".equals(password) && 
                      !"admin123".equals(password) && !"123456".equals(password)) {
        %>
            <div class="error">
                Mật khẩu không đúng! Thử: <code>admin</code>, <code>password</code>, <code>admin123</code>, hoặc <code>123456</code>
            </div>
        <% 
            }
        }
        %>
        
        <form method="POST">
            <div class="form-group">
                <label>Tên đăng nhập:</label>
                <input type="text" name="username" 
                       value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>"
                       required>
            </div>
            
            <div class="form-group">
                <label>Mật khẩu:</label>
                <input type="password" name="password" required>
            </div>
            
            <button type="submit">ĐĂNG NHẬP</button>
        </form>
        
        
        <div class="back-link">
            <a href="index.jsp">← Quay về trang chủ</a>
        </div>
    </div>
</body>
</html>