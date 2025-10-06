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
        String normalizedUsername = username != null ? username.trim() : "";
        String normalizedPassword = password != null ? password.trim() : "";
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
        System.out.println("Username received: '" + normalizedUsername + "'");
        System.out.println("Password received: '" + normalizedPassword + "'");
        System.out.println("Expected username: '" + DEMO_USERNAME + "'");
        System.out.println("Expected password: '" + DEMO_PASSWORD + "'");
        
        // Kiểm tra thông tin đăng nhập
        if (DEMO_USERNAME.equals(normalizedUsername) && DEMO_PASSWORD.equals(normalizedPassword)) {
			// Đăng nhập thành công (admin)
			HttpSession session = request.getSession();
			session.setAttribute("username", username);
			session.setAttribute("isLoggedIn", true);
			session.setAttribute("role", "admin");
			
			// Xử lý remember me
			if ("on".equals(rememberMe)) {
				session.setMaxInactiveInterval(7 * 24 * 60 * 60); // 7 ngày
			} else {
				session.setMaxInactiveInterval(30 * 60); // 30 phút
			}
			
			// Redirect đến trang admin
			response.sendRedirect(request.getContextPath() + "/admin/admin.jsp");
			return;
        }
        
        // DB-backed login for customers
        try {
            com.hlgenerator.dao.UserDAO userDAO = new com.hlgenerator.dao.UserDAO();
            com.hlgenerator.dao.UserDAO.UserRecord user = userDAO.findByUsername(normalizedUsername);
            if (user != null && user.isActive && userDAO.verifyPassword(normalizedPassword, user.passwordHash)) {
                HttpSession session = request.getSession();
                session.setAttribute("username", user.username);
                session.setAttribute("isLoggedIn", true);
                session.setAttribute("role", user.role);
                if ("on".equals(rememberMe)) {
                    session.setMaxInactiveInterval(7 * 24 * 60 * 60);
                } else {
                    session.setMaxInactiveInterval(30 * 60);
                }

                // Optionally map to customer by email
                try {
                    com.hlgenerator.dao.CustomerDAO customerDAO = new com.hlgenerator.dao.CustomerDAO();
                    com.hlgenerator.model.Customer c = customerDAO.getCustomerByEmail(user.email);
                    if (c != null) {
                        session.setAttribute("customerId", c.getId());
                    } else {
                        // Nếu không tìm thấy customer, set customerId = user.id (nếu phù hợp)
                        session.setAttribute("customerId", user.id);
                    }
                } catch (Exception ignore) {
                    // Nếu lỗi, vẫn set customerId = user.id
                    session.setAttribute("customerId", user.id);
                }

                if ("admin".equalsIgnoreCase(user.role)) {
                    response.sendRedirect(request.getContextPath() + "/admin/admin.jsp");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/hotro.jsp");
                }
                return;
            }
        } catch (Exception ignore) {}
        
        // Kiểm tra các trường hợp lỗi khác nhau
        if ("locked_user".equals(normalizedUsername)) {
            redirectWithError(request, response, "account_locked", "Tài khoản này đã bị khóa do vi phạm chính sách!");
        } else if ("expired_user".equals(normalizedUsername)) {
            redirectWithError(request, response, "session_expired", "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!");
        } else if ("guest".equals(normalizedUsername)) {
            redirectWithError(request, response, "access_denied", "Tài khoản khách không có quyền truy cập hệ thống quản trị!");
        } else {
            // Thông tin đăng nhập sai
            redirectWithError(request, response, "invalid_credentials", 
                "Tên đăng nhập hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại!");
        }
        
        // Không tìm thấy người dùng hợp lệ => trả lỗi
    }
    
    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, 
            String errorType, String message) throws IOException {
        
        String redirectUrl = request.getContextPath() + "/admin/login.jsp?error=true&errorType=" + errorType + "&message=" + 
            java.net.URLEncoder.encode(message, "UTF-8");
        response.sendRedirect(redirectUrl);
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Kiểm tra nếu đã đăng nhập thì redirect đến admin
        HttpSession session = request.getSession(false);
        if (session != null && Boolean.TRUE.equals(session.getAttribute("isLoggedIn"))) {
            response.sendRedirect(request.getContextPath() + "/admin/admin.jsp");
            return;
        }
        
        // Nếu chưa đăng nhập thì hiển thị trang login
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
    }
}
