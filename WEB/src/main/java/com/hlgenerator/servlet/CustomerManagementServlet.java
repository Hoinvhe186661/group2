package com.hlgenerator.servlet;

import com.google.gson.Gson;
import com.hlgenerator.dao.CustomerDAO;
import com.hlgenerator.model.Customer;

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
 * Servlet xử lý logic backend cho trang quản lý khách hàng (customers.jsp)
 * Tách biệt logic xử lý khỏi tầng presentation
 */
@WebServlet("/customers")
public class CustomerManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CustomerDAO customerDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            customerDAO = new CustomerDAO();
            System.out.println("CustomerManagementServlet: Initialized successfully");
        } catch (Exception e) {
            System.err.println("CustomerManagementServlet initialization failed: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Failed to initialize CustomerManagementServlet", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
       
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        
        HttpSession session = request.getSession(false);
        String username = (String) session.getAttribute("username");
        Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
        String userRole = (String) session.getAttribute("userRole");
        
        if (username == null || isLoggedIn == null || !isLoggedIn) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
       
        boolean canManageCustomers = "admin".equals(userRole) || "customer_support".equals(userRole);
        if (!canManageCustomers) {
            response.sendRedirect(request.getContextPath() + "/403.jsp");
            return;
        }
        
        try {
            
            List<Customer> allCustomers = customerDAO.getAllCustomers();
            
            
        
            String pType = decodeParam(request.getParameter("customerType"));
            String pStatus = decodeParam(request.getParameter("status"));
            
            
            
            List<Customer> filteredCustomers = filterCustomers(allCustomers,  pType, pStatus);
            
            
            Set<String> customerTypes = extractCustomerTypes(allCustomers);
            Set<String> statuses = extractStatuses(allCustomers);
            
            // Đặt dữ liệu vào request attributes
            request.setAttribute("filteredCustomers", filteredCustomers);
            request.setAttribute("customerTypes", customerTypes);
            request.setAttribute("statuses", statuses);
            
            request.setAttribute("filterType", pType != null ? pType : "");
            request.setAttribute("filterStatus", pStatus != null ? pStatus : "");
           
            
            
            request.getRequestDispatcher("/customers.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("Error in CustomerManagementServlet: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Error processing customer management request", e);
        }
    }
    
    
    private List<Customer> filterCustomers(List<Customer> allCustomers, 
                                          String type, String status) {
        List<Customer> filtered = new ArrayList<>();
        
        for (Customer c : allCustomers) {
           
            
            
            if (!equalsParam(type, c.getCustomerType())) continue;
            
            
            if (!equalsParam(status, c.getStatus())) continue;
            
    
            
            filtered.add(c);
        }
        
        return filtered;
    }
    
    /**
     * Trích xuất danh sách loại khách hàng từ tất cả khách hàng
     */
    private Set<String> extractCustomerTypes(List<Customer> customers) {
        Set<String> types = new TreeSet<>();
        for (Customer c : customers) {
            if (c.getCustomerType() != null && !c.getCustomerType().trim().isEmpty()) {
                types.add(c.getCustomerType().trim());
            }
        }
        return types;
    }
    
    /**
     * Trích xuất danh sách trạng thái từ tất cả khách hàng
     */
    private Set<String> extractStatuses(List<Customer> customers) {
        Set<String> statuses = new TreeSet<>();
        for (Customer c : customers) {
            if (c.getStatus() != null && !c.getStatus().trim().isEmpty()) {
                statuses.add(c.getStatus().trim());
            }
        }
        return statuses;
    }
    
    
    private boolean equalsParam(String param, String actual) {
        if (param == null || param.trim().isEmpty()) return true;
        String val = actual == null ? "" : actual.trim();
        return param.trim().equalsIgnoreCase(val);
    }
    
    
    private boolean containsParam(String param, String actual) {
        if (param == null || param.trim().isEmpty()) return true;
        String val = actual == null ? "" : actual.trim().toLowerCase();
        return val.contains(param.trim().toLowerCase());
    }
    
    
    private String decodeParam(String s) {
        if (s == null) return null;
        try {
            return new String(s.getBytes("ISO-8859-1"), "UTF-8").trim();
        } catch (UnsupportedEncodingException e) { 
            return s.trim(); 
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        
        String action = request.getParameter("action");
        String id = request.getParameter("id");
        
        try {
            JsonResponse jsonResponse = new JsonResponse();
            
            switch (action) {
                case "get":
                    Customer customer = customerDAO.getCustomerById(Integer.parseInt(id));
                    if (customer != null) {
                        jsonResponse.setSuccess(true);
                        jsonResponse.setData(customer);
                    } else {
                        jsonResponse.setSuccess(false);
                        jsonResponse.setMessage("Không tìm thấy khách hàng");
                    }
                    break;
                    
                case "delete":
                case "deactivate":
                    // Xóa tạm thời hoặc tạm khóa (đều cập nhật status thành inactive)
                    Customer customerToDeactivate = customerDAO.getCustomerById(Integer.parseInt(id));
                    if (customerToDeactivate != null) {
                        customerToDeactivate.setStatus("inactive");
                        boolean deactivated = customerDAO.updateCustomer(customerToDeactivate);
                        jsonResponse.setSuccess(deactivated);
                        jsonResponse.setMessage(deactivated ? "Đã tạm khóa khách hàng" : "Lỗi khi tạm khóa khách hàng");
                    } else {
                        jsonResponse.setSuccess(false);
                        jsonResponse.setMessage("Không tìm thấy khách hàng");
                    }
                    break;
                    
                case "activate":
                    Customer customerToActivate = customerDAO.getCustomerById(Integer.parseInt(id));
                    if (customerToActivate != null) {
                        customerToActivate.setStatus("active");
                        boolean activated = customerDAO.updateCustomer(customerToActivate);
                        jsonResponse.setSuccess(activated);
                        jsonResponse.setMessage(activated ? "Đã kích hoạt khách hàng" : "Lỗi khi kích hoạt khách hàng");
                    } else {
                        jsonResponse.setSuccess(false);
                        jsonResponse.setMessage("Không tìm thấy khách hàng");
                    }
                    break;
                    
                case "hardDelete":
                    // Xóa vĩnh viễn khỏi database
                    boolean hardDeleted = customerDAO.hardDeleteCustomer(Integer.parseInt(id));
                    jsonResponse.setSuccess(hardDeleted);
                    jsonResponse.setMessage(hardDeleted ? "Đã xóa vĩnh viễn khách hàng" : "Lỗi khi xóa vĩnh viễn khách hàng");
                    break;
                    
                case "update":
                    // Xử lý cập nhật thông tin khách hàng
                    // ... code cập nhật ...
                    break;
                    
                case "add":
                    // Xử lý thêm khách hàng mới
                    // ... code thêm mới ...
                    break;
                    
                default:
                    jsonResponse.setSuccess(false);
                    jsonResponse.setMessage("Hành động không hợp lệ");
            }
            
            response.getWriter().write(new Gson().toJson(jsonResponse));
            
        } catch (Exception e) {
            JsonResponse errorResponse = new JsonResponse();
            errorResponse.setSuccess(false);
            errorResponse.setMessage("Lỗi: " + e.getMessage());
            response.getWriter().write(new Gson().toJson(errorResponse));
        }
    }
    
    private class JsonResponse {
        private boolean success;
        private String message;
        private Object data;
        
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        public Object getData() { return data; }
        public void setData(Object data) { this.data = data; }
    }
    
    public static class CustomerHelper {
        public static String typeLabel(String raw) {
            if (raw == null) return "-";
            return raw.equalsIgnoreCase("company") ? "Doanh nghiệp" : "Cá nhân";
        }
        
        public static String statusLabel(String raw) {
            if (raw == null) return "-";
            return raw.equalsIgnoreCase("active") ? "Hoạt động" : "Tạm khóa";
        }
    }
}

