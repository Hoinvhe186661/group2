<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f5f7fb; margin: 0; padding: 0; }
        .container { max-width: 420px; margin: 60px auto; background: #fff; padding: 24px; border-radius: 12px; box-shadow: 0 6px 24px rgba(0,0,0,0.08); }
        h2 { margin: 0 0 16px; }
        .form-group { margin-bottom: 14px; }
        label { display: block; margin-bottom: 6px; }
        input[type="password"] { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; }
        button { width: 100%; padding: 12px; background: #667eea; color: #fff; border: 0; border-radius: 8px; cursor: pointer; }
        .msg { margin: 10px 0; padding: 10px; border-radius: 8px; }
        .error { background: #ffe6e6; color: #b00020; }
        .links { text-align: center; margin-top: 12px; }
        .links a { color: #667eea; text-decoration: none; }
    </style>
    <meta http-equiv="Content-Security-Policy" content="default-src 'self'; style-src 'self' 'unsafe-inline';">
</head>
<body>
    <div class="container">
        <h2>Đặt lại mật khẩu</h2>
        <% if (request.getAttribute("error") != null) { %>
            <div class="msg error"><%= request.getAttribute("error") %></div>
        <% } %>
        <form method="post" action="reset-password">
            <input type="hidden" name="token" value="<%= request.getAttribute("token") != null ? request.getAttribute("token") : request.getParameter("token") %>">
            <div class="form-group">
                <label for="password">Mật khẩu mới</label>
                <input type="password" id="password" name="password" minlength="6" required>
            </div>
            <div class="form-group">
                <label for="confirm">Nhập lại mật khẩu mới</label>
                <input type="password" id="confirm" name="confirm" minlength="6" required>
            </div>
            <button type="submit">Cập nhật mật khẩu</button>
        </form>
        <div class="links">
            <a href="login.jsp">← Quay lại đăng nhập</a>
        </div>
    </div>
</body>
</html>


