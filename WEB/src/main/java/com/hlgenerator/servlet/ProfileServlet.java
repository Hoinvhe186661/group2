package com.hlgenerator.servlet;

import com.hlgenerator.dao.UserDAO;
import com.hlgenerator.dao.CustomerDAO;
import com.hlgenerator.model.User;
import com.hlgenerator.model.Customer;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/api/profile")
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;
    private CustomerDAO customerDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            userDAO = new UserDAO();
            customerDAO = new CustomerDAO();
            System.out.println("ProfileServlet: Initialized successfully");
        } catch (Exception e) {
            System.err.println("ProfileServlet initialization failed: " + e.getMessage());
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
        
        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isLoggedIn"))) {
            sendErrorResponse(response, "Không có quyền truy cập", 401);
            return;
        }

        PrintWriter out = response.getWriter();
        
        try {
            // Get user ID from session
            Object userIdObj = session.getAttribute("userId");
            if (userIdObj == null) {
                sendErrorResponse(response, "Không tìm thấy thông tin người dùng", 400);
                return;
            }

            int userId = Integer.parseInt(String.valueOf(userIdObj));
            User user = userDAO.getUserById(userId);
            
            if (user == null) {
                sendErrorResponse(response, "Không tìm thấy người dùng", 404);
                return;
            }

            // Build response with user data
            JSONObject userJson = userToJSON(user);
            
            // If user has customerId, load customer data
            if (user.getCustomerId() != null) {
                Customer customer = customerDAO.getCustomerById(user.getCustomerId());
                if (customer != null) {
                    // Add customer fields to response
                    userJson.put("companyName", customer.getCompanyName() != null ? customer.getCompanyName() : "");
                    userJson.put("address", customer.getAddress() != null ? customer.getAddress() : "");
                    userJson.put("customerId", customer.getId());
                }
            }

            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("data", userJson);
            out.print(result.toString());

        } catch (Exception e) {
            System.err.println("ProfileServlet doGet error: " + e.getMessage());
            e.printStackTrace();
            try {
                sendErrorResponse(response, "Lỗi khi lấy thông tin profile: " + e.getMessage(), 500);
            } catch (IOException ioException) {
                System.err.println("Error sending error response: " + ioException.getMessage());
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set UTF-8 encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isLoggedIn"))) {
            sendErrorResponse(response, "Không có quyền truy cập", 401);
            return;
        }

        PrintWriter out = response.getWriter();

        try {
            // Get user ID from session
            Object userIdObj = session.getAttribute("userId");
            if (userIdObj == null) {
                sendErrorResponse(response, "Không tìm thấy thông tin người dùng", 400);
                return;
            }

            int userId = Integer.parseInt(String.valueOf(userIdObj));
            
            // Get form parameters
            String email = request.getParameter("email");
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String companyName = request.getParameter("companyName");
            String address = request.getParameter("address");

            // Validate required fields
            if (email == null || email.trim().isEmpty() ||
                fullName == null || fullName.trim().isEmpty() ||
                phone == null || phone.trim().isEmpty()) {
                
                sendErrorResponse(response, "Email, Họ tên và Số điện thoại là bắt buộc", 400);
                return;
            }

            // Get existing user
            User existingUser = userDAO.getUserById(userId);
            if (existingUser == null) {
                sendErrorResponse(response, "Không tìm thấy người dùng", 404);
                return;
            }

            // Check if email already exists (excluding current user)
            if (userDAO.isEmailExists(email.trim(), userId)) {
                sendErrorResponse(response, "Email đã tồn tại", 400);
                return;
            }

            // Update user object
            existingUser.setEmail(email.trim());
            existingUser.setFullName(fullName.trim());
            existingUser.setPhone(phone != null ? phone.trim() : null);

            // Update user in database
            boolean userUpdateSuccess = userDAO.updateUser(existingUser);
            
            if (!userUpdateSuccess) {
                sendErrorResponse(response, "Không thể cập nhật thông tin người dùng", 500);
                return;
            }

            // Update session
            session.setAttribute("email", existingUser.getEmail());
            session.setAttribute("fullName", existingUser.getFullName());
            session.setAttribute("phone", existingUser.getPhone());

            // If user has customerId, update customer as well
            boolean customerUpdateSuccess = true;
            if (existingUser.getCustomerId() != null) {
                Customer existingCustomer = customerDAO.getCustomerById(existingUser.getCustomerId());
                if (existingCustomer != null) {
                    // Update customer fields
                    existingCustomer.setEmail(email.trim());
                    existingCustomer.setPhone(phone.trim());
                    existingCustomer.setContactPerson(fullName.trim());
                    
                    if (companyName != null && !companyName.trim().isEmpty()) {
                        existingCustomer.setCompanyName(companyName.trim());
                    }
                    
                    if (address != null && !address.trim().isEmpty()) {
                        existingCustomer.setAddress(address.trim());
                    }
                    
                    customerUpdateSuccess = customerDAO.updateCustomer(existingCustomer);
                }
            } else {
                // If no customerId but companyName or address provided, try to find or create customer
                if ((companyName != null && !companyName.trim().isEmpty()) || 
                    (address != null && !address.trim().isEmpty())) {
                    
                    // Try to find customer by email
                    java.util.List<Customer> customers = customerDAO.searchCustomers(email.trim());
                    Customer customer = null;
                    
                    if (customers != null && !customers.isEmpty()) {
                        // Use first matching customer
                        customer = customers.get(0);
                    }
                    
                    if (customer != null) {
                        // Update existing customer
                        customer.setEmail(email.trim());
                        customer.setPhone(phone.trim());
                        customer.setContactPerson(fullName.trim());
                        if (companyName != null && !companyName.trim().isEmpty()) {
                            customer.setCompanyName(companyName.trim());
                        }
                        if (address != null && !address.trim().isEmpty()) {
                            customer.setAddress(address.trim());
                        }
                        customerUpdateSuccess = customerDAO.updateCustomer(customer);
                        
                        // Link user to customer
                        existingUser.setCustomerId(customer.getId());
                        userDAO.updateUser(existingUser);
                        session.setAttribute("customerId", customer.getId());
                    }
                }
            }

            JSONObject result = new JSONObject();
            if (userUpdateSuccess && customerUpdateSuccess) {
                result.put("success", true);
                result.put("message", "Đã cập nhật thông tin thành công");
            } else if (userUpdateSuccess) {
                result.put("success", true);
                result.put("message", "Đã cập nhật thông tin người dùng thành công, nhưng cập nhật thông tin khách hàng thất bại");
            } else {
                result.put("success", false);
                result.put("message", "Không thể cập nhật thông tin");
            }
            out.print(result.toString());

        } catch (NumberFormatException e) {
            sendErrorResponse(response, "Mã người dùng không hợp lệ", 400);
        } catch (Exception e) {
            System.err.println("ProfileServlet doPost error: " + e.getMessage());
            e.printStackTrace();
            try {
                sendErrorResponse(response, "Lỗi khi cập nhật profile: " + e.getMessage(), 500);
            } catch (IOException ioException) {
                System.err.println("Error sending error response: " + ioException.getMessage());
            }
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

    private void sendErrorResponse(PrintWriter out, String message) {
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
        json.put("isActive", user.isActive());
        if (user.getCustomerId() != null) {
            json.put("customerId", user.getCustomerId());
        }
        return json;
    }
}

