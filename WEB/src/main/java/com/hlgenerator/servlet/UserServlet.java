package com.hlgenerator.servlet;

import com.hlgenerator.dao.UserDAO;
import com.hlgenerator.model.User;
import com.hlgenerator.util.AuthorizationUtil;
import com.hlgenerator.util.Permission;
import org.json.JSONObject;
import org.json.JSONArray;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

@WebServlet("/api/users")
public class UserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            userDAO = new UserDAO();
            System.out.println("UserServlet: Initialized successfully");
        } catch (Exception e) {
            System.err.println("UserServlet initialization failed: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set UTF-8 encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        if (!AuthorizationUtil.isLoggedIn(request)) {
            sendErrorResponse(response, "Vui lòng đăng nhập lại", 401);
            return;
        }
        if (!AuthorizationUtil.hasPermission(request, Permission.MANAGE_USERS)) {
            sendErrorResponse(response, "Không có quyền truy cập chức năng quản lý người dùng", 403);
            return;
        }

        String action = request.getParameter("action");
        String roleParam = request.getParameter("role");
        PrintWriter out = response.getWriter();

        try {
            // Nếu có parameter "role" mà không có action, tự động filter theo role
            if (roleParam != null && !roleParam.trim().isEmpty() && (action == null || action.isEmpty())) {
                handleGetUsersByRole(request, out);
                return;
            }
            
            switch (action != null ? action : "list") {
                case "list":
                    handleGetAllUsers(out);
                    break;
                case "get":
                    handleGetUser(request, out);
                    break;
                case "search":
                    handleSearchUsers(request, out);
                    break;
                case "getByRole":
                    handleGetUsersByRole(request, out);
                    break;
                case "getStats":
                    handleGetUserStats(out);
                    break;
                default:
                    handleGetAllUsers(out);
                    break;
            }
        } catch (Exception e) {
            sendErrorResponse(response, "Lỗi máy chủ nội bộ: " + e.getMessage(), 500);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set UTF-8 encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        if (!AuthorizationUtil.isLoggedIn(request)) {
            sendErrorResponse(response, "Vui lòng đăng nhập lại", 401);
            return;
        }
        if (!AuthorizationUtil.hasPermission(request, Permission.MANAGE_USERS)) {
            sendErrorResponse(response, "Không có quyền truy cập chức năng quản lý người dùng", 403);
            return;
        }

        String action = request.getParameter("action");
        PrintWriter out = response.getWriter();

        try {
            switch (action != null ? action : "add") {
                case "add":
                    handleAddUser(request, out);
                    com.hlgenerator.util.ActionLogUtil.addAction(request, "Tạo người dùng mới: " + request.getParameter("username"), "success");
                    break;
                case "update":
                    handleUpdateUser(request, out);
                    com.hlgenerator.util.ActionLogUtil.addAction(request, "Cập nhật người dùng #" + request.getParameter("id"), "info");
                    break;
                case "delete":
                    handleDeleteUser(request, out);
                    com.hlgenerator.util.ActionLogUtil.addAction(request, "Xóa (mềm) người dùng #" + request.getParameter("id"), "warning");
                    break;
                case "activate":
                    handleActivateUser(request, out);
                    com.hlgenerator.util.ActionLogUtil.addAction(request, "Kích hoạt người dùng #" + request.getParameter("id"), "success");
                    break;
                case "changePassword":
                    handleChangePassword(request, out);
                    com.hlgenerator.util.ActionLogUtil.addAction(request, "Đổi mật khẩu người dùng #" + request.getParameter("id"), "info");
                    break;
                case "deactivate":
                    handleDeactivateUser(request, out);
                    com.hlgenerator.util.ActionLogUtil.addAction(request, "Tạm khóa người dùng #" + request.getParameter("id"), "warning");
                    break;
                case "hardDelete":
                    handleHardDeleteUser(request, out);
                    com.hlgenerator.util.ActionLogUtil.addAction(request, "XÓA VĨNH VIỄN người dùng #" + request.getParameter("id"), "danger");
                    break;
                case "deleteByRole":
                    handleDeleteUsersByRole(request, out);
                    break;
                default:
                    sendErrorResponse(response, "Hành động không hợp lệ", 400);
                    break;
            }
        } catch (Exception e) {
            sendErrorResponse(response, "Lỗi máy chủ nội bộ: " + e.getMessage(), 500);
        }
    }

    private void handleGetAllUsers(PrintWriter out) {
        try {
            List<User> users = userDAO.getAllUsers();
            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("data", new JSONArray(users));
            out.print(result.toString());
            System.out.println("handleGetAllUsers: Successfully returned " + users.size() + " users");
        } catch (Exception e) {
            System.err.println("handleGetAllUsers error: " + e.getMessage());
            e.printStackTrace();
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Lỗi khi lấy danh sách người dùng: " + e.getMessage());
            out.print(error.toString());
        }
    }

    private void handleGetUser(HttpServletRequest request, PrintWriter out) {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            sendErrorResponse(out, "Mã người dùng là bắt buộc", 400);
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            User user = userDAO.getUserById(id);
            
            JSONObject result = new JSONObject();
            if (user != null) {
                result.put("success", true);
                result.put("data", userToJSON(user));
            } else {
                result.put("success", false);
                result.put("message", "Không tìm thấy người dùng");
            }
            out.print(result.toString());
        } catch (NumberFormatException e) {
            sendErrorResponse(out, "Mã người dùng không hợp lệ", 400);
        }
    }

    private void handleSearchUsers(HttpServletRequest request, PrintWriter out) {
        String searchTerm = request.getParameter("search");
        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            handleGetAllUsers(out);
            return;
        }

        List<User> users = userDAO.searchUsers(searchTerm.trim());
        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("data", new JSONArray(users));
        out.print(result.toString());
    }

    private void handleGetUsersByRole(HttpServletRequest request, PrintWriter out) {
        String role = request.getParameter("role");
        if (role == null || role.trim().isEmpty()) {
            sendErrorResponse(out, "Vai trò là bắt buộc", 400);
            return;
        }

        List<User> users = userDAO.getUsersByRole(role.trim());
        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("data", new JSONArray(users));
        out.print(result.toString());
    }

    private void handleGetUserStats(PrintWriter out) {
        try {
            JSONObject stats = new JSONObject();
            stats.put("totalUsers", userDAO.getTotalUserCount());
            stats.put("adminCount", userDAO.getUserCountByRole("admin"));
            stats.put("technicalStaffCount", userDAO.getUserCountByRole("technical_staff"));
            stats.put("customerSupportCount", userDAO.getUserCountByRole("customer_support"));
            stats.put("storekeeperCount", userDAO.getUserCountByRole("storekeeper"));
            stats.put("headTechnicianCount", userDAO.getUserCountByRole("head_technician"));
            stats.put("customerCount", userDAO.getUserCountByRole("customer"));
            
            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("data", stats);
            out.print(result.toString());
        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi lấy thống kê người dùng: " + e.getMessage(), 500);
        }
    }

    private void handleAddUser(HttpServletRequest request, PrintWriter out) {
        try {
            // Get form parameters
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String role = request.getParameter("role");
            String permissions = request.getParameter("permissions");
            String isActiveStr = request.getParameter("isActive");
            String customerIdParam = request.getParameter("customerId");

            // Validate required fields
            if (username == null || username.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                fullName == null || fullName.trim().isEmpty() ||
                role == null || role.trim().isEmpty()) {
                
                sendErrorResponse(out, "Tất cả các trường bắt buộc phải được điền", 400);
                return;
            }

            // Check if username already exists
            if (userDAO.isUsernameExists(username.trim())) {
                sendErrorResponse(out, "Tên đăng nhập đã tồn tại", 400);
                return;
            }

            // Check if email already exists
            if (userDAO.isEmailExists(email.trim())) {
                sendErrorResponse(out, "Email đã tồn tại", 400);
                return;
            }

            // Hash password
            String passwordHash = hashPassword(password.trim());

            // Create user object
            User user = new User(
                username.trim(),
                email.trim(),
                passwordHash,
                fullName.trim(),
                phone != null ? phone.trim() : null,
                role.trim(),
                permissions != null ? permissions.trim() : "[]",
                isActiveStr != null ? Boolean.parseBoolean(isActiveStr) : true
            );

            // If role is customer, require customerId and set it
            if ("customer".equalsIgnoreCase(role)) {
                Integer customerId = null;
                if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
                    try {
                        customerId = Integer.parseInt(customerIdParam.trim());
                    } catch (NumberFormatException e) {
                        sendErrorResponse(out, "customerId không hợp lệ", 400);
                        return;
                    }
                }
                if (customerId == null) {
                    sendErrorResponse(out, "Vui lòng chọn khách hàng cho tài khoản vai trò Khách hàng", 400);
                    return;
                }
                user.setCustomerId(customerId);
            } else {
                user.setCustomerId(null);
            }

            // Add to database
            boolean success = userDAO.addUser(user);
            
            JSONObject result = new JSONObject();
            if (success) {
                result.put("success", true);
                result.put("message", "Đã thêm người dùng thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không thể thêm người dùng");
            }
            out.print(result.toString());

        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi thêm người dùng: " + e.getMessage(), 500);
        }
    }

    private void handleUpdateUser(HttpServletRequest request, PrintWriter out) {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                sendErrorResponse(out, "Mã người dùng là bắt buộc", 400);
                return;
            }

            int id = Integer.parseInt(idParam);
            
            // Get form parameters
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String role = request.getParameter("role");
            String permissions = request.getParameter("permissions");
            String isActiveStr = request.getParameter("isActive");
            String customerIdParam = request.getParameter("customerId");

            // Validate required fields
            if (username == null || username.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                fullName == null || fullName.trim().isEmpty() ||
                role == null || role.trim().isEmpty()) {
                
                sendErrorResponse(out, "Tất cả các trường bắt buộc phải được điền", 400);
                return;
            }

            // Check if username already exists (excluding current user)
            if (userDAO.isUsernameExists(username.trim(), id)) {
                sendErrorResponse(out, "Tên đăng nhập đã tồn tại", 400);
                return;
            }

            // Check if email already exists (excluding current user)
            if (userDAO.isEmailExists(email.trim(), id)) {
                sendErrorResponse(out, "Email đã tồn tại", 400);
                return;
            }

            // Get existing user to preserve password
            User existingUser = userDAO.getUserById(id);
            if (existingUser == null) {
                sendErrorResponse(out, "Không tìm thấy người dùng", 404);
                return;
            }

            // Update user object
            existingUser.setUsername(username.trim());
            existingUser.setEmail(email.trim());
            existingUser.setFullName(fullName.trim());
            existingUser.setPhone(phone != null ? phone.trim() : null);
            existingUser.setRole(role.trim());
            existingUser.setPermissions(permissions != null ? permissions.trim() : "[]");
            if (isActiveStr != null) {
                existingUser.setActive(Boolean.parseBoolean(isActiveStr));
            }

            // Handle customerId based on role
            if ("customer".equalsIgnoreCase(role)) {
                Integer customerId = null;
                if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
                    try {
                        customerId = Integer.parseInt(customerIdParam.trim());
                    } catch (NumberFormatException e) {
                        sendErrorResponse(out, "customerId không hợp lệ", 400);
                        return;
                    }
                }
                if (customerId == null) {
                    sendErrorResponse(out, "Vui lòng chọn khách hàng cho tài khoản vai trò Khách hàng", 400);
                    return;
                }
                existingUser.setCustomerId(customerId);
            } else {
                existingUser.setCustomerId(null);
            }

            // Update in database
            boolean success = userDAO.updateUser(existingUser);
            
            JSONObject result = new JSONObject();
            if (success) {
                result.put("success", true);
                result.put("message", "Đã cập nhật người dùng thành công");
                // Đồng bộ lại session nếu người dùng cập nhật chính mình
                try {
                    HttpSession session = request.getSession(false);
                    if (session != null) {
                        Object sid = session.getAttribute("userId");
                        if (sid != null && String.valueOf(sid).equals(String.valueOf(existingUser.getId()))) {
                            session.setAttribute("username", existingUser.getUsername());
                            session.setAttribute("email", existingUser.getEmail());
                            session.setAttribute("fullName", existingUser.getFullName());
                            session.setAttribute("phone", existingUser.getPhone());
                            session.setAttribute("userRole", existingUser.getRole());
                        }
                    }
                } catch (Exception ignore) {}
            } else {
                result.put("success", false);
                result.put("message", "Không thể cập nhật người dùng");
            }
            out.print(result.toString());

        } catch (NumberFormatException e) {
            sendErrorResponse(out, "Mã người dùng không hợp lệ", 400);
        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi cập nhật người dùng: " + e.getMessage(), 500);
        }
    }

    private void handleDeleteUser(HttpServletRequest request, PrintWriter out) {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                sendErrorResponse(out, "Mã người dùng là bắt buộc", 400);
                return;
            }

            int id = Integer.parseInt(idParam);
            boolean success = userDAO.deleteUser(id);
            
            JSONObject result = new JSONObject();
            if (success) {
                result.put("success", true);
                result.put("message", "Đã xóa người dùng thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không thể xóa người dùng");
            }
            out.print(result.toString());

        } catch (NumberFormatException e) {
            sendErrorResponse(out, "Mã người dùng không hợp lệ", 400);
        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi xóa người dùng: " + e.getMessage(), 500);
        }
    }

    private void handleActivateUser(HttpServletRequest request, PrintWriter out) {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                sendErrorResponse(out, "Mã người dùng là bắt buộc", 400);
                return;
            }

            int id = Integer.parseInt(idParam);
            boolean success = userDAO.activateUser(id);
            
            JSONObject result = new JSONObject();
            if (success) {
                result.put("success", true);
                result.put("message", "Đã kích hoạt người dùng thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không thể kích hoạt người dùng");
            }
            out.print(result.toString());

        } catch (NumberFormatException e) {
            sendErrorResponse(out, "Mã người dùng không hợp lệ", 400);
        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi kích hoạt người dùng: " + e.getMessage(), 500);
        }
    }

    private void handleChangePassword(HttpServletRequest request, PrintWriter out) {
        try {
            String idParam = request.getParameter("id");
            String newPassword = request.getParameter("newPassword");
            
            if (idParam == null || idParam.trim().isEmpty() ||
                newPassword == null || newPassword.trim().isEmpty()) {
                sendErrorResponse(out, "Mã người dùng và mật khẩu mới là bắt buộc", 400);
                return;
            }

            int id = Integer.parseInt(idParam);
            String passwordHash = hashPassword(newPassword.trim());
            boolean success = userDAO.updateUserPassword(id, passwordHash);
            
            JSONObject result = new JSONObject();
            if (success) {
                result.put("success", true);
                result.put("message", "Đã đổi mật khẩu thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không thể đổi mật khẩu");
            }
            out.print(result.toString());

        } catch (NumberFormatException e) {
            sendErrorResponse(out, "Mã người dùng không hợp lệ", 400);
        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi đổi mật khẩu: " + e.getMessage(), 500);
        }
    }

    private void handleDeactivateUser(HttpServletRequest request, PrintWriter out) {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                sendErrorResponse(out, "Mã người dùng là bắt buộc", 400);
                return;
            }

            int id = Integer.parseInt(idParam);
            User user = userDAO.getUserById(id);
            
            if (user == null) {
                sendErrorResponse(out, "Không tìm thấy người dùng", 404);
                return;
            }

            user.setActive(false);
            boolean success = userDAO.updateUser(user);
            
            JSONObject result = new JSONObject();
            if (success) {
                result.put("success", true);
                result.put("message", "Đã tạm khóa người dùng thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không thể tạm khóa người dùng");
            }
            out.print(result.toString());

        } catch (NumberFormatException e) {
            sendErrorResponse(out, "Mã người dùng không hợp lệ", 400);
        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi tạm khóa người dùng: " + e.getMessage(), 500);
        }
    }

    private void handleHardDeleteUser(HttpServletRequest request, PrintWriter out) {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                sendErrorResponse(out, "Mã người dùng là bắt buộc", 400);
                return;
            }

            int id = Integer.parseInt(idParam);
            
            // Kiểm tra xem user có tồn tại không
            User user = userDAO.getUserById(id);
            if (user == null) {
                sendErrorResponse(out, "Không tìm thấy người dùng", 404);
                return;
            }

            // Thực hiện hard delete
            boolean success = userDAO.hardDeleteUser(id);
            
            JSONObject result = new JSONObject();
            if (success) {
                result.put("success", true);
                result.put("message", "Đã xóa vĩnh viễn người dùng thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không thể xóa vĩnh viễn người dùng");
            }
            out.print(result.toString());

        } catch (NumberFormatException e) {
            sendErrorResponse(out, "Mã người dùng không hợp lệ", 400);
        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi xóa vĩnh viễn người dùng: " + e.getMessage(), 500);
        }
    }

    private void handleDeleteUsersByRole(HttpServletRequest request, PrintWriter out) {
        try {
            String role = request.getParameter("role");
            String mode = request.getParameter("mode"); // "hard" hoặc "soft" (mặc định soft)
            if (role == null || role.trim().isEmpty()) {
                sendErrorResponse(out, "Vai trò là bắt buộc", 400);
                return;
            }
            boolean isHard = "hard".equalsIgnoreCase(String.valueOf(mode));

            int affected = isHard 
                ? userDAO.hardDeleteUsersByRole(role.trim())
                : userDAO.softDeleteUsersByRole(role.trim());

            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("deleted", affected);
            result.put("mode", isHard ? "hard" : "soft");
            result.put("role", role.trim());
            out.print(result.toString());

        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi xóa người dùng theo vai trò: " + e.getMessage(), 500);
        }
    }

    private void sendErrorResponse(HttpServletResponse response, String message, int statusCode) 
            throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json; charset=UTF-8");
        
        JSONObject error = new JSONObject();
        error.put("success", false);
        error.put("message", message);
        
        PrintWriter out = response.getWriter();
        out.print(error.toString());
    }

    private void sendErrorResponse(PrintWriter out, String message, int statusCode) {
        JSONObject error = new JSONObject();
        error.put("success", false);
        error.put("message", message);
        out.print(error.toString());
    }
    
    private JSONObject userToJSON(User user) {
        JSONObject json = new JSONObject();
        json.put("id", user.getId());
        json.put("username", user.getUsername());
        json.put("email", user.getEmail());
        json.put("fullName", user.getFullName());
        json.put("phone", user.getPhone());
        json.put("role", user.getRole());
        json.put("roleDisplayName", user.getRoleDisplayName());
        json.put("permissions", user.getPermissions());
        json.put("isActive", user.isActive());
        json.put("statusDisplayName", user.getStatusDisplayName());
        json.put("createdAt", user.getCreatedAt());
        json.put("updatedAt", user.getUpdatedAt());
        return json;
    }

    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }
}
