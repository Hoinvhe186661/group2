package com.hlgenerator.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Lấy session hiện tại
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // Xóa tất cả attributes trong session
            session.removeAttribute("username");
            session.removeAttribute("isLoggedIn");
            
            // Hoặc có thể invalidate toàn bộ session
            // session.invalidate();
        }
        
        // Redirect về trang login
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp?message=" + 
            java.net.URLEncoder.encode("Đã đăng xuất thành công!", "UTF-8"));
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
