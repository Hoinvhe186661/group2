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
import java.net.URLDecoder;
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
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        // Kiểm tra đăng nhập và quyền
        if (!checkAuth(request, response)) return;
        
        try {
            // Lấy filter parameters
            String pRole = getParameterUTF8(request, "role");
            String pStatus = getParameterUTF8(request, "status");
            String search = getParameterUTF8(request, "q");
            
            // Lấy tham số phân trang
            int[] pagination = parsePagination(request);
            int currentPage = pagination[0];
            int pageSize = pagination[1];
            
            // Đếm và lấy dữ liệu
            int total = userDAO.countUsersFiltered(pRole, pStatus, search);
            int totalPages = Math.max(1, (int) Math.ceil(total / (double) pageSize));
            if (currentPage > totalPages) currentPage = totalPages;
            
            List<User> filteredUsers = userDAO.getUsersPageFiltered(currentPage, pageSize, pRole, pStatus, search);
            Set<String> roles = extractRoles(userDAO.getAllUsers());
            
            // Set attributes
            setRequestAttributes(request, filteredUsers, roles, pRole, pStatus, search, total, currentPage, pageSize, totalPages);
            
            request.getRequestDispatcher("/users.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("Error in UserManagementServlet: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Error processing user management request", e);
        }
    }
    
    /**
     * Kiểm tra đăng nhập và quyền admin
     */
    private boolean checkAuth(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }
        
        String username = (String) session.getAttribute("username");
        Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
        String userRole = (String) session.getAttribute("userRole");
        
        if (username == null || isLoggedIn == null || !isLoggedIn) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }
        
        if (!"admin".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/403.jsp");
            return false;
        }
        
        return true;
    }
    
    /**
     * Parse tham số phân trang từ request
     */
    private int[] parsePagination(HttpServletRequest request) {
        int currentPage = parseInt(request.getParameter("page"), 1);
        int pageSize = parseInt(request.getParameter("size"), 10);
        return new int[]{Math.max(1, currentPage), Math.max(1, pageSize)};
    }
    
    /**
     * Parse string sang int với giá trị mặc định
     */
    private int parseInt(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) return defaultValue;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
    
    /**
     * Set tất cả request attributes
     */
    private void setRequestAttributes(HttpServletRequest request, List<User> users, Set<String> roles,
                                     String pRole, String pStatus, String search, int total,
                                     int currentPage, int pageSize, int totalPages) {
        request.setAttribute("filteredUsers", users);
        request.setAttribute("roles", roles);
        request.setAttribute("filterRole", pRole != null ? pRole : "");
        request.setAttribute("filterStatus", pStatus != null ? pStatus : "");
        request.setAttribute("search", search);
        request.setAttribute("totalUsers", total);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
    }
    /**
     * Trích xuất danh sách vai trò từ danh sách người dùng
     */
    private Set<String> extractRoles(List<User> users) {
        Set<String> roles = new TreeSet<>();
        for (User user : users) {
            String role = user.getRole();
            if (role != null && !role.trim().isEmpty()) {
                roles.add(role);
            }
        }
        return roles;
    }
    
    /**
     * Lấy parameter từ request và decode UTF-8
     */
    private String getParameterUTF8(HttpServletRequest request, String paramName) {
        String value = request.getParameter(paramName);
        if (value == null) return null;
        try {
            return URLDecoder.decode(value, "UTF-8").trim();
        } catch (Exception e) {
            return value.trim();
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

