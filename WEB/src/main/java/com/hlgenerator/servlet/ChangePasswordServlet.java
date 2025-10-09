package com.hlgenerator.servlet;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.hlgenerator.dao.UserDAO;

@WebServlet("/api/changePassword")
public class ChangePasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession(false);
        
        // Kiểm tra đăng nhập
        if (session == null || session.getAttribute("userId") == null) {
            out.print("{\"success\": false, \"message\": \"Vui lòng đăng nhập!\"}");
            return;
        }
        
        int userId = (int) session.getAttribute("userId");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validate input
        if (currentPassword == null || currentPassword.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"Vui lòng nhập đầy đủ thông tin!\"}");
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            out.print("{\"success\": false, \"message\": \"Mật khẩu mới và xác nhận mật khẩu không khớp!\"}");
            return;
        }
        
        if (newPassword.length() < 6) {
            out.print("{\"success\": false, \"message\": \"Mật khẩu mới phải có ít nhất 6 ký tự!\"}");
            return;
        }
        
        // Use UserDAO to change password
        UserDAO userDAO = new UserDAO();
        boolean success = userDAO.changePassword(userId, currentPassword, newPassword);
        
        if (success) {
            out.print("{\"success\": true, \"message\": \"Đổi mật khẩu thành công!\"}");
        } else {
            out.print("{\"success\": false, \"message\": \"Mật khẩu hiện tại không đúng hoặc không thể cập nhật!\"}");
        }
    }
}

