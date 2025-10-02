package com.hlgenerator.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/simple-login")
public class SimpleLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        out.println("<html><head><meta charset='UTF-8'></head><body>");
        out.println("<h2>Debug Login</h2>");
        out.println("<p>Username nhận được: " + username + "</p>");
        out.println("<p>Password nhận được: " + password + "</p>");
        
        // Kiểm tra input
        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            out.println("<p style='color:red'>LỖI: Thiếu thông tin đăng nhập!</p>");
            out.println("<p><a href='test-login.jsp'>Thử lại</a></p>");
        } else {
            // Kiểm tra password
            if ("admin".equals(password) || "password".equals(password) || "admin123".equals(password) || "123456".equals(password)) {
                // Đăng nhập thành công
                HttpSession session = request.getSession(true);
                session.setAttribute("username", username);
                session.setAttribute("isLoggedIn", true);
                
                out.println("<p style='color:green'>THÀNH CÔNG: Đăng nhập OK!</p>");
                out.println("<p>Đang chuyển hướng đến admin.jsp...</p>");
                out.println("<script>setTimeout(function(){ window.location.href='admin.jsp'; }, 2000);</script>");
            } else {
                out.println("<p style='color:red'>LỖI: Mật khẩu không đúng!</p>");
                out.println("<p>Thử: admin, password, admin123, hoặc 123456</p>");
                out.println("<p><a href='test-login.jsp'>Thử lại</a></p>");
            }
        }
        
        out.println("</body></html>");
    }
}
