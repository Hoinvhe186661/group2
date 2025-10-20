package com.hlgenerator.servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.hlgenerator.dao.UserDAO;
import com.hlgenerator.model.User;

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
            
            String redirectUrl = "";
            switch (userRole) {
                case "admin":
                    redirectUrl = "/admin.jsp";
                    break;
                case "customer_support":
                    redirectUrl = "/customersupport.jsp";
                    break;
                case "head_technician":
                    redirectUrl = "/headtech.jsp";
                    break;
                case "technical_staff":
                    redirectUrl = "/technical_staff.jsp";
                    break;
                case "storekeeper":
                    redirectUrl = "/storekeeper.jsp";
                    break;
                case "customer":
                    redirectUrl = "/index.jsp";
                    break;
                case "guest":
                    redirectUrl = "/index.jsp";
                    break;
                default:
                    redirectUrl = "/index.jsp";
                    break;
            }
            
            response.sendRedirect(request.getContextPath() + redirectUrl);
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
        
        // Debug logging
        if (user == null) {
            System.out.println("DEBUG: User '" + username + "' NOT FOUND in database!");
        } else {
            System.out.println("DEBUG: User '" + username + "' found. Active: " + user.isActive() + ", Password: " + user.getPasswordHash());
        }
        
        if (user != null && user.isActive()) {
            String inputHash = sha256(password);
            if (inputHash.equals(user.getPasswordHash()) || password.equals(user.getPasswordHash())) {
                isValidLogin = true;
                userRole = user.getRole(); // Sử dụng role từ database
                fullName = user.getFullName();
                email = user.getEmail();
                System.out.println("DEBUG: User " + username + " logged in with role: " + userRole);
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
            
            // Set customerId nếu là customer
            if ("customer".equals(userRole) && email != null && !email.trim().isEmpty()) {
                try {
                    com.hlgenerator.dao.CustomerDAO customerDAO = new com.hlgenerator.dao.CustomerDAO();
                    com.hlgenerator.model.Customer customer = customerDAO.getCustomerByEmail(email.trim());
                    if (customer != null) {
                        session.setAttribute("customerId", customer.getId());
                        System.out.println("DEBUG: Set customerId to " + customer.getId() + " for user " + username);
                    } else {
                        // Tạo customer mới nếu chưa có
                        String code = customerDAO.generateNextCustomerCode();
                        com.hlgenerator.model.Customer newCustomer = new com.hlgenerator.model.Customer();
                        newCustomer.setCustomerCode(code);
                        newCustomer.setCompanyName(fullName);
                        newCustomer.setContactPerson(fullName);
                        newCustomer.setEmail(email.trim());
                        newCustomer.setPhone("");
                        newCustomer.setAddress("");
                        newCustomer.setTaxCode("");
                        newCustomer.setCustomerType("individual");
                        newCustomer.setStatus("active");
                        if (customerDAO.addCustomer(newCustomer)) {
                            com.hlgenerator.model.Customer createdCustomer = customerDAO.getCustomerByEmail(email.trim());
                            if (createdCustomer != null) {
                                session.setAttribute("customerId", createdCustomer.getId());
                                System.out.println("DEBUG: Created new customer with ID " + createdCustomer.getId() + " for user " + username);
                            }
                        }
                    }
                } catch (Exception e) {
                    System.out.println("DEBUG: Error setting customerId for user " + username + ": " + e.getMessage());
                }
            }
            
            
            // Chuyển hướng dựa trên vai trò
            System.out.println("DEBUG: Redirecting user " + username + " with role: '" + userRole + "'");
            
            String redirectUrl = "";
            switch (userRole) {
                case "admin":
                    redirectUrl = "/admin.jsp";
                    break;
                case "customer_support":
                    redirectUrl = "/customersupport.jsp";
                    break;
                case "head_technician":
                    redirectUrl = "/headtech.jsp";
                    break;
                case "technical_staff":
                    redirectUrl = "/technical_staff.jsp";
                    break;
                case "storekeeper":
                    redirectUrl = "/storekeeper.jsp";
                    break;
                case "customer":
                    redirectUrl = "/index.jsp";
                    break;
                case "guest":
                    redirectUrl = "/index.jsp";
                    break;
                default:
                    redirectUrl = "/index.jsp";
                    break;
            }
            
            System.out.println("DEBUG: Redirecting to: " + redirectUrl);
            response.sendRedirect(request.getContextPath() + redirectUrl);
            
        } else {
            // Đăng nhập thất bại
            request.setAttribute("errorMessage", "Mật khẩu hoặc tài khoản không đúng");
            request.setAttribute("username", username);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    private String sha256(String input) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(input.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (java.security.NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }
}