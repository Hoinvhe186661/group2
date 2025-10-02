package com.hlgenerator.servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Kiểm tra xem user đã đăng nhập chưa
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("isLoggedIn") != null) {
            response.sendRedirect("admin.jsp");
            return;
        }
        
        // Chuyển hướng đến trang login
        response.sendRedirect("login.jsp");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
       String username = request.getParameter("username");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");
        
        // Validate input
        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ thông tin đăng nhập!");
            request.setAttribute("username", username);
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        // Simple authentication - accept any username with these passwords
        boolean isValidLogin = false;
        String userRole = "admin";
        
        // Accept common passwords for demo
        if ("admin".equals(password) || "password".equals(password) || "admin123".equals(password) || "123456".equals(password)) {
            isValidLogin = true;
        }
        
        if (isValidLogin) {
            // Đăng nhập thành công
            HttpSession session = request.getSession(true);
            session.setAttribute("userId", 1);
            session.setAttribute("username", username);
            session.setAttribute("userRole", userRole);
            session.setAttribute("fullName", "Administrator");
            session.setAttribute("email", username + "@hlgenerator.com");
            session.setAttribute("isLoggedIn", true);
            session.setAttribute("loginTime", System.currentTimeMillis());
            
            // Xử lý remember me
            if (remember != null && "on".equals(remember)) {
                Cookie userCookie = new Cookie("rememberedUsername", username);
                userCookie.setMaxAge(60 * 60 * 24 * 7); // 7 ngày
                userCookie.setPath("/");
                response.addCookie(userCookie);
            } else {
                // Xóa cookie nếu không chọn remember me
                Cookie userCookie = new Cookie("rememberedUsername", "");
                userCookie.setMaxAge(0);
                userCookie.setPath("/");
                response.addCookie(userCookie);
            }
            
            // Luôn chuyển hướng đến admin.jsp
            response.sendRedirect("admin.jsp");
            
        } else {
            // Đăng nhập thất bại
            request.setAttribute("errorMessage", "Mật khẩu không đúng! Thử: admin, password, admin123, hoặc 123456");
            request.setAttribute("username", username);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}