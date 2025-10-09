package com.hlgenerator.servlet;

import com.hlgenerator.dao.UserDAO;
import com.hlgenerator.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token = req.getParameter("token");
        if (token != null) token = token.trim();
        if (token == null || token.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        req.setAttribute("token", token);
        req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String token = req.getParameter("token");
        if (token != null) token = token.trim();
        String password = req.getParameter("password");
        String confirm = req.getParameter("confirm");

        if (token == null || token.trim().isEmpty()) {
            req.setAttribute("error", "Thiếu token đặt lại mật khẩu");
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
            return;
        }

        if (password == null || password.length() < 6 || !password.equals(confirm)) {
            req.setAttribute("token", token);
            req.setAttribute("error", "Mật khẩu không hợp lệ hoặc không khớp (>= 6 ký tự)");
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByResetToken(token);
        if (user == null) {
            req.setAttribute("error", "Token không hợp lệ hoặc đã hết hạn");
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
            return;
        }

        // Token already validated for expiry via DAO

        String hash = sha256(password);
        userDAO.updateUserPassword(user.getId(), hash);
        userDAO.clearPasswordResetToken(user.getId());


        resp.sendRedirect(req.getContextPath() + "/login.jsp?reset=success");
    }

    private String sha256(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(input.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }
}


