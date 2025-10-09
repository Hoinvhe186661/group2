package com.hlgenerator.servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        performLogout(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        performLogout(request, response);
    }
    
    private void performLogout(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        // Lấy session hiện tại
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // Xóa tất cả attributes trong session
            session.removeAttribute("username");
            session.removeAttribute("isLoggedIn");
            session.removeAttribute("userRole");
            session.removeAttribute("fullName");
            session.removeAttribute("email");
            session.removeAttribute("loginTime");
            
            // Hủy session hoàn toàn
            session.invalidate();
        }
        
        // Xóa remember me cookie nếu có
        Cookie userCookie = new Cookie("rememberedUsername", "");
        userCookie.setMaxAge(0);
        userCookie.setPath("/");
        response.addCookie(userCookie);
        
        // Chuyển hướng về trang chủ (index.jsp)
        response.sendRedirect("index.jsp");
    }
}