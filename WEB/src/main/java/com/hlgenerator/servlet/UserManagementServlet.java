package com.hlgenerator.servlet;

import com.hlgenerator.dao.UserDAO;
import com.hlgenerator.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

/**
 * Servlet xử lý logic backend cho trang quản lý người dùng (users.jsp)
 * Tách biệt logic xử lý khỏi tầng presentation
 */
@WebServlet("/users")
public class UserManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            userDAO = new UserDAO();
            System.out.println("UserManagementServlet: Initialized successfully");
        } catch (Exception e) {
            System.err.println("UserManagementServlet initialization failed: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Failed to initialize UserManagementServlet", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set UTF-8 encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        // Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        String username = (String) session.getAttribute("username");
        Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
        String userRole = (String) session.getAttribute("userRole");
        
        if (username == null || isLoggedIn == null || !isLoggedIn) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Kiểm tra quyền truy cập - chỉ admin mới có thể quản lý người dùng
        if (!"admin".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/403.jsp");
            return;
        }
        
        try {
            // Lấy tất cả người dùng từ database
            List<User> allUsers = userDAO.getAllUsers();
            
            // Lấy các tham số filter từ request
            String pUsername = decodeParam(request.getParameter("username"));
            String pEmail = decodeParam(request.getParameter("email"));
            String pFullName = decodeParam(request.getParameter("fullName"));
            String pPhone = decodeParam(request.getParameter("phone"));
            String pRole = decodeParam(request.getParameter("role"));
            String pStatus = decodeParam(request.getParameter("status"));
            
            // Lọc danh sách người dùng
            List<User> filteredUsers = filterUsers(allUsers, pUsername, pEmail, pFullName, pPhone, pRole, pStatus);
            
            // Lấy danh sách vai trò để hiển thị trong dropdown
            Set<String> roles = extractRoles(allUsers);
            
            // Đặt dữ liệu vào request attributes
            request.setAttribute("filteredUsers", filteredUsers);
            request.setAttribute("roles", roles);
            request.setAttribute("filterUsername", pUsername != null ? pUsername : "");
            request.setAttribute("filterEmail", pEmail != null ? pEmail : "");
            request.setAttribute("filterFullName", pFullName != null ? pFullName : "");
            request.setAttribute("filterPhone", pPhone != null ? pPhone : "");
            request.setAttribute("filterRole", pRole != null ? pRole : "");
            request.setAttribute("filterStatus", pStatus != null ? pStatus : "");
            
            // Forward đến JSP để hiển thị
            request.getRequestDispatcher("/users.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("Error in UserManagementServlet: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Error processing user management request", e);
        }
    }
    
    /**
     * Lọc danh sách người dùng dựa trên các tiêu chí
     */
    private List<User> filterUsers(List<User> allUsers, String username, String email, 
                                   String fullName, String phone, String role, String status) {
        List<User> filtered = new ArrayList<>();
        
        for (User user : allUsers) {
            // Tìm kiếm theo các trường text (contains)
            if (!containsParam(username, user.getUsername())) continue;
            if (!containsParam(email, user.getEmail())) continue;
            if (!containsParam(fullName, user.getFullName())) continue;
            if (!containsParam(phone, user.getPhone())) continue;
            
            // So sánh chính xác cho vai trò
            if (!equalsParam(role, getUserRole(user))) continue;
            
            // Lọc theo trạng thái
            if (status != null && !status.trim().isEmpty()) {
                boolean wantActive = "active".equalsIgnoreCase(status);
                if (user.isActive() != wantActive) continue;
            }
            
            filtered.add(user);
        }
        
        return filtered;
    }
    
    /**
     * Trích xuất danh sách vai trò từ tất cả người dùng
     */
    private Set<String> extractRoles(List<User> users) {
        Set<String> roles = new TreeSet<>();
        for (User user : users) {
            String role = getUserRole(user);
            if (role != null && !role.isEmpty()) {
                roles.add(role);
            }
        }
        return roles;
    }
    
    /**
     * So sánh chính xác (equals) giữa tham số filter và giá trị thực tế
     */
    private boolean equalsParam(String param, String actual) {
        if (param == null || param.trim().isEmpty()) return true;
        String val = actual == null ? "" : actual.trim();
        return param.trim().equalsIgnoreCase(val);
    }
    
    /**
     * Kiểm tra xem giá trị thực tế có chứa tham số filter hay không
     */
    private boolean containsParam(String param, String actual) {
        if (param == null || param.trim().isEmpty()) return true;
        String val = actual == null ? "" : actual.trim().toLowerCase();
        return val.contains(param.trim().toLowerCase());
    }
    
    /**
     * Decode UTF-8 cho tham số
     */
    private String decodeParam(String s) {
        if (s == null) return null;
        try {
            return new String(s.getBytes("ISO-8859-1"), "UTF-8").trim();
        } catch (UnsupportedEncodingException e) { 
            return s.trim(); 
        }
    }
    
    /**
     * Lấy vai trò của người dùng
     */
    private String getUserRole(User user) {
        try {
            String role = user.getRole();
            return role != null ? role : (user.getRoleDisplayName() != null ? user.getRoleDisplayName() : "");
        } catch (Exception e) {
            return user.getRoleDisplayName() != null ? user.getRoleDisplayName() : "";
        }
    }
    
    /**
     * Utility class để chuyển đổi mã vai trò sang label tiếng Việt
     */
    public static class RoleHelper {
        public static String roleLabel(String raw) {
            if (raw == null) return "-";
            switch (raw) {
                case "admin": return "Quản trị viên";
                case "customer_support": return "Hỗ trợ khách hàng";
                case "technical_staff": return "Nhân viên kỹ thuật";
                case "head_technician": return "Trưởng phòng kỹ thuật";
                case "storekeeper": return "Thủ kho";
                case "customer": return "Khách hàng";
                case "guest": return "Khách";
                default: return raw;
            }
        }
        
        public static String statusLabel(boolean active) { 
            return active ? "Hoạt động" : "Tạm khóa"; 
        }
    }
}

