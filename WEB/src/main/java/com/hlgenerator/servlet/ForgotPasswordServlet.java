package com.hlgenerator.servlet;

import com.hlgenerator.dao.UserDAO;
import com.hlgenerator.model.User;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Properties;
import java.util.UUID;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập email");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByEmail(email);
        if (user == null || !user.isActive()) {
            req.setAttribute("success", "Nếu email tồn tại, chúng tôi đã gửi hướng dẫn đặt lại mật khẩu.");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

        String token = UUID.randomUUID().toString().replace("-", "");
        Timestamp expiresAt = Timestamp.from(Instant.now().plusSeconds(60 * 60)); // 60 minutes
        boolean saved = userDAO.savePasswordResetToken(user.getId(), token, expiresAt);
        if (!saved) {
            req.setAttribute("error", "Không thể tạo token đặt lại mật khẩu. Vui lòng thử lại sau.");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

        String resetLink = req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort() + req.getContextPath() + "/reset-password?token=" + token;

        try {
            final String toSend = email;
            final String body = "Xin chào " + (user.getFullName() != null ? user.getFullName() : user.getUsername()) +
                    "\n\nBạn đã yêu cầu đặt lại mật khẩu. Nhấn vào liên kết sau để đặt lại mật khẩu: \n" + resetLink +
                    "\n\nLiên kết sẽ hết hạn sau 60 phút. Nếu bạn không yêu cầu, hãy bỏ qua email này.";
            new Thread(() -> {
                try {
                    sendEmail(toSend, "Đặt lại mật khẩu", body);
                } catch (Exception ignored) { }
            }).start();
        } catch (Exception e) {
            req.setAttribute("error", "Không thể gửi email đặt lại mật khẩu. Vui lòng thử lại sau.");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("success", "Nếu email tồn tại, chúng tôi đã gửi hướng dẫn đặt lại mật khẩu.");
        req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
    }

    private void sendEmail(String to, String subject, String body) throws MessagingException {
        final String username = "nguyenvanhoitgm@gmail.com";
        final String password = "qvms fnhj ehgg qmcn";

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.mime.charset", "UTF-8");
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");
        props.put("mail.smtp.writetimeout", "10000");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(username));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject, "UTF-8");
        message.setText(body, "UTF-8");

        Transport.send(message);
    }
}


