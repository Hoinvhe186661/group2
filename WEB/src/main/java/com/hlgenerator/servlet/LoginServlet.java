package com.hlgenerator.servlet;

import java.io.IOException;
import com.hlgenerator.dao.UserDAO;
import com.hlgenerator.model.User;

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
            String userRole = (String) session.getAttribute("userRole");
            if ("customer".equals(userRole)) {
                response.sendRedirect(request.getContextPath() + "/index.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin.jsp");
            }
            return;
        }
        
        // Chuyển hướng đến trang login
        response.sendRedirect(request.getContextPath() + "/login.jsp");
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
        
        // Xác thực thực tế với database
        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByUsername(username);
        
        boolean isValidLogin = false;
        String userRole = "customer";
        String fullName = "";
        String email = "";
        
        if (user != null && user.isActive()) {
            // Kiểm tra mật khẩu - sử dụng plain text cho demo
            // Trong thực tế nên sử dụng BCrypt.checkpw(password, user.getPasswordHash())
            if (password.equals(user.getPasswordHash()) || "password".equals(password) || 
                "admin123".equals(password) || "123456".equals(password)) {
                isValidLogin = true;
                userRole = user.getRole(); // Sử dụng role từ database
                fullName = user.getFullName();
                email = user.getEmail();
                System.out.println("DEBUG: User " + username + " logged in with role: " + userRole);
            }
        }
        
        // Fallback cho demo - accept common passwords
        if (!isValidLogin && ("admin".equals(password) || "password".equals(password) || "admin123".equals(password) || "123456".equals(password))) {
            isValidLogin = true;
            // Kiểm tra username để xác định vai trò - chỉ dùng khi không có trong database
            if ("customer".equals(username) || username.startsWith("customer")) {
                userRole = "customer";
                fullName = "Customer User";
                email = username + "@example.com";
            } else if ("admin".equals(username) || username.startsWith("admin")) {
                userRole = "admin";
                fullName = "Administrator";
                email = username + "@hlgenerator.com";
            } else {
                // Mặc định là customer cho các username khác
                userRole = "customer";
                fullName = "Customer User";
                email = username + "@example.com";
            }
        }
        
        if (isValidLogin) {
            // Đăng nhập thành công
            HttpSession session = request.getSession(true);
            session.setAttribute("userId", user != null ? user.getId() : 1);
            session.setAttribute("username", username);
            session.setAttribute("userRole", userRole);
            session.setAttribute("fullName", fullName);
            session.setAttribute("email", email);
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
            
            // Chuyển hướng dựa trên vai trò
            System.out.println("DEBUG: Redirecting user " + username + " with role: '" + userRole + "'");
            System.out.println("DEBUG: Role comparison - customer.equals(userRole): " + "customer".equals(userRole));
            System.out.println("DEBUG: Role comparison - userRole.equals('customer'): " + userRole.equals("customer"));
            if ("customer".equals(userRole)) {
                System.out.println("DEBUG: Redirecting to about.jsp");
                response.sendRedirect(request.getContextPath() + "/index.jsp");
            } else {
                System.out.println("DEBUG: Redirecting to admin.jsp");
                response.sendRedirect(request.getContextPath() + "/admin.jsp");
            }
            
        } else {
            // Đăng nhập thất bại
            request.setAttribute("errorMessage", "Mật khẩu không đúng! Thử: admin, password, admin123, hoặc 123456");
            request.setAttribute("username", username);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}