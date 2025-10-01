package com.hlgenerator.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Demo credentials - trong thực tế nên lưu trong database
    private static final String DEMO_USERNAME = "admin";
    private static final String DEMO_PASSWORD = "admin123";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set UTF-8 encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        String username = request.getParameter("j_username");
        String password = request.getParameter("j_password");
        String rememberMe = request.getParameter("rememberMe");
        
        // Validation cơ bản
        if (username == null || username.trim().isEmpty()) {
            redirectWithError(request, response, "invalid_credentials", "Vui lòng nhập tên đăng nhập!");
            return;
        }
        
        if (password == null || password.trim().isEmpty()) {
            redirectWithError(request, response, "invalid_credentials", "Vui lòng nhập mật khẩu!");
            return;
        }
        
        // Debug: Log thông tin nhận được
        System.out.println("Username received: '" + username + "'");
        System.out.println("Password received: '" + password + "'");
        System.out.println("Expected username: '" + DEMO_USERNAME + "'");
        System.out.println("Expected password: '" + DEMO_PASSWORD + "'");
        
        // Kiểm tra thông tin đăng nhập
        if (DEMO_USERNAME.equals(username.trim()) && DEMO_PASSWORD.equals(password)) {
            // Đăng nhập thành công
            HttpSession session = request.getSession();
            session.setAttribute("username", username);
            session.setAttribute("isLoggedIn", true);
            
            // Xử lý remember me
            if ("on".equals(rememberMe)) {
                session.setMaxInactiveInterval(7 * 24 * 60 * 60); // 7 ngày
            } else {
                session.setMaxInactiveInterval(30 * 60); // 30 phút
            }
            
            // Redirect đến trang admin
            response.sendRedirect(request.getContextPath() + "/admin.jsp");
            return;
        }
        
        // Kiểm tra các trường hợp lỗi khác nhau
        if ("locked_user".equals(username.trim())) {
            redirectWithError(request, response, "account_locked", "Tài khoản này đã bị khóa do vi phạm chính sách!");
        } else if ("expired_user".equals(username.trim())) {
            redirectWithError(request, response, "session_expired", "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!");
        } else if ("guest".equals(username.trim())) {
            redirectWithError(request, response, "access_denied", "Tài khoản khách không có quyền truy cập hệ thống quản trị!");
        } else {
            // Thông tin đăng nhập sai
            redirectWithError(request, response, "invalid_credentials", 
                "Tên đăng nhập hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại!");
        }
    }
    
    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, 
            String errorType, String message) throws IOException {
        
        String redirectUrl = request.getContextPath() + "/login.jsp?error=true&errorType=" + errorType + "&message=" + 
            java.net.URLEncoder.encode(message, "UTF-8");
        response.sendRedirect(redirectUrl);
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Kiểm tra nếu đã đăng nhập thì redirect đến admin
        HttpSession session = request.getSession(false);
        if (session != null && Boolean.TRUE.equals(session.getAttribute("isLoggedIn"))) {
            response.sendRedirect(request.getContextPath() + "/admin.jsp");
            return;
        }
        
        // Nếu chưa đăng nhập thì hiển thị trang login
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
}
