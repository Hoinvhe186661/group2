package com.hlgenerator.servlet;

import com.google.gson.Gson;
import com.hlgenerator.dao.CustomerDAO;
import com.hlgenerator.dao.ContactDAO;
import com.hlgenerator.model.Customer;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
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
    private ContactDAO contactDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            customerDAO = new CustomerDAO();
            contactDAO = new ContactDAO();
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
        
        // Kiểm tra nếu là request lấy danh sách khách hàng chờ (cần kiểm tra session trước)
        String action = request.getParameter("action");
        if ("getWaitingCustomers".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
                return;
            }
            
            String username = (String) session.getAttribute("username");
            Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
            String userRole = (String) session.getAttribute("userRole");
            
            if (username == null || isLoggedIn == null || !isLoggedIn) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
                return;
            }
            
            boolean canManageCustomers = "admin".equals(userRole) || "customer_support".equals(userRole);
            if (!canManageCustomers) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write("{\"error\":\"Không có quyền truy cập\"}");
                return;
            }
            
            try {
                List<Map<String, Object>> waitingCustomers = contactDAO.getContactedCustomers();
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write(new Gson().toJson(waitingCustomers));
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write("{\"error\":\"Lỗi server: " + e.getMessage() + "\"}");
            }
            return;
        }
        
        // Sinh mã khách hàng tự động
        if ("generateCustomerCode".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
                return;
            }
            
            String username = (String) session.getAttribute("username");
            Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
            String userRole = (String) session.getAttribute("userRole");
            
            if (username == null || isLoggedIn == null || !isLoggedIn) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
                return;
            }
            
            boolean canManageCustomers = "admin".equals(userRole) || "customer_support".equals(userRole);
            if (!canManageCustomers) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write("{\"error\":\"Không có quyền truy cập\"}");
                return;
            }
            
            try {
                String generatedCode = customerDAO.generateNextCustomerCode();
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write("{\"success\":true,\"data\":{\"customerCode\":\"" + generatedCode + "\"}}");
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write("{\"error\":\"Lỗi server: " + e.getMessage() + "\"}");
            }
            return;
        }
        
        response.setContentType("text/html; charset=UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
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
            // Lấy filter parameters
            // Với GET request, cần xử lý encoding đặc biệt
            String pType = getParameterUTF8(request, "customerType");
            String pStatus = getParameterUTF8(request, "status");
            String search = getParameterUTF8(request, "q");
            
            // Lấy tham số phân trang
            String pageParam = request.getParameter("page");
            String sizeParam = request.getParameter("size");
            int currentPage = 1;
            int pageSize = 10;
            try {
                if (pageParam != null) currentPage = Integer.parseInt(pageParam);
            } catch (Exception ignored) {}
            try {
                if (sizeParam != null) pageSize = Integer.parseInt(sizeParam);
            } catch (Exception ignored) {}
            if (currentPage < 1) currentPage = 1;
            if (pageSize < 1) pageSize = 10;
            
            // Đếm tổng số khách hàng với bộ lọc
            int total = customerDAO.countCustomersFiltered(pType, pStatus, search);
            int totalPages = (int) Math.ceil(total / (double) pageSize);
            if (totalPages == 0) totalPages = 1;
            if (currentPage > totalPages) currentPage = totalPages;
            
            // Lấy danh sách khách hàng với phân trang và bộ lọc
            List<Customer> filteredCustomers = customerDAO.getCustomersPageFiltered(
                currentPage, pageSize, pType, pStatus, search
            );
            
            System.out.println("CustomerManagementServlet: Loaded " + filteredCustomers.size() + " customers (page " + currentPage + " of " + totalPages + ", total: " + total + ")");
            
            // Lấy danh sách loại và trạng thái từ tất cả khách hàng (để hiển thị trong dropdown)
            List<Customer> allCustomers = customerDAO.getAllCustomers();
            Set<String> customerTypes = extractCustomerTypes(allCustomers);
            Set<String> statuses = extractStatuses(allCustomers);
            
            // Đặt dữ liệu vào request attributes
            request.setAttribute("filteredCustomers", filteredCustomers);
            request.setAttribute("customerTypes", customerTypes);
            request.setAttribute("statuses", statuses);
            
            request.setAttribute("filterType", pType != null ? pType : "");
            request.setAttribute("filterStatus", pStatus != null ? pStatus : "");
            request.setAttribute("search", search);
            request.setAttribute("totalCustomers", total);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalPages", totalPages);
            
            request.getRequestDispatcher("/customers.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("Error in CustomerManagementServlet: " + e.getMessage());
            e.printStackTrace();
            // Thay vì throw exception, hiển thị trang với danh sách rỗng
            try {
                request.setAttribute("filteredCustomers", new ArrayList<Customer>());
                request.setAttribute("customerTypes", new TreeSet<String>());
                request.setAttribute("statuses", new TreeSet<String>());
                request.setAttribute("filterType", "");
                request.setAttribute("filterStatus", "");
                request.setAttribute("search", "");
                request.setAttribute("totalCustomers", 0);
                request.setAttribute("currentPage", 1);
                request.setAttribute("pageSize", 10);
                request.setAttribute("totalPages", 1);
                request.getRequestDispatcher("/customers.jsp").forward(request, response);
            } catch (Exception e2) {
                throw new ServletException("Error processing customer management request", e);
            }
        }
    }
    
    
    /**
     * Trích xuất danh sách loại khách hàng từ tất cả khách hàng
     */
    private Set<String> extractCustomerTypes(List<Customer> customers) {
        Set<String> types = new TreeSet<>();
        if (customers != null) {
            for (Customer c : customers) {
                if (c != null && c.getCustomerType() != null && !c.getCustomerType().trim().isEmpty()) {
                    types.add(c.getCustomerType().trim());
                }
            }
        }
        return types;
    }
    
    /**
     * Trích xuất danh sách trạng thái từ tất cả khách hàng
     */
    private Set<String> extractStatuses(List<Customer> customers) {
        Set<String> statuses = new TreeSet<>();
        if (customers != null) {
            for (Customer c : customers) {
                if (c != null && c.getStatus() != null && !c.getStatus().trim().isEmpty()) {
                    statuses.add(c.getStatus().trim());
                }
            }
        }
        return statuses;
    }
    
    
    /**
     * Lấy parameter từ GET request và decode đúng với UTF-8
     * Xử lý trường hợp Tomcat chưa được cấu hình URIEncoding="UTF-8"
     */
    private String getParameterUTF8(HttpServletRequest request, String paramName) {
        String value = request.getParameter(paramName);
        if (value == null || value.trim().isEmpty()) {
            return value;
        }
        
        // Thử lấy từ raw query string để decode lại
        try {
            String queryString = request.getQueryString();
            if (queryString != null && queryString.contains(paramName + "=")) {
                // Parse query string thủ công
                String[] pairs = queryString.split("&");
                for (String pair : pairs) {
                    int idx = pair.indexOf("=");
                    if (idx > 0) {
                        String key = URLDecoder.decode(pair.substring(0, idx), "UTF-8");
                        if (key.equals(paramName)) {
                            String rawValue = pair.substring(idx + 1);
                            // Decode với UTF-8
                            return URLDecoder.decode(rawValue, "UTF-8").trim();
                        }
                    }
                }
            }
        } catch (Exception e) {
            // Nếu có lỗi, fallback về cách cũ
        }
        
        // Fallback: nếu parameter đã được decode sai (chứa "?" thay vì ký tự tiếng Việt)
        // Thử decode lại từ ISO-8859-1 bytes sang UTF-8
        if (value.contains("?") && !value.equals("?")) {
            try {
                byte[] bytes = value.getBytes("ISO-8859-1");
                String decoded = new String(bytes, "UTF-8");
                // Chỉ dùng nếu decoded không chứa replacement character
                if (!decoded.contains("") && !decoded.contains("")) {
                    return decoded.trim();
                }
            } catch (UnsupportedEncodingException e) {
                // Ignore
            }
        }
        
        // Nếu không có vấn đề, trả về giá trị gốc
        return value.trim();
    }
    
    /**
     * Decode parameter từ GET request (URL encoded) - DEPRECATED, dùng getParameterUTF8 thay thế
     * @deprecated Sử dụng getParameterUTF8() thay thế
     */
    @Deprecated
    private String decodeParam(String s) {
        if (s == null || s.trim().isEmpty()) return s;
        try {
            return URLDecoder.decode(s, "UTF-8").trim();
        } catch (Exception e) {
            try {
                return new String(s.getBytes("ISO-8859-1"), "UTF-8").trim();
            } catch (UnsupportedEncodingException e2) {
                return s.trim();
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        
        // Kiểm tra quyền truy cập
        HttpSession session = request.getSession(false);
        String username = (String) session.getAttribute("username");
        Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
        String userRole = (String) session.getAttribute("userRole");
        
        if (username == null || isLoggedIn == null || !isLoggedIn) {
            JsonResponse errorResponse = new JsonResponse();
            errorResponse.setSuccess(false);
            errorResponse.setMessage("Bạn cần đăng nhập để thực hiện thao tác này");
            response.getWriter().write(new Gson().toJson(errorResponse));
            return;
        }
        
        // Kiểm tra quyền: chỉ admin và customer_support mới có thể quản lý khách hàng
        boolean canManageCustomers = "admin".equals(userRole) || "customer_support".equals(userRole);
        if (!canManageCustomers) {
            JsonResponse errorResponse = new JsonResponse();
            errorResponse.setSuccess(false);
            errorResponse.setMessage("Bạn không có quyền thực hiện thao tác này");
            response.getWriter().write(new Gson().toJson(errorResponse));
            return;
        }
        
        String action = request.getParameter("action");
        String id = request.getParameter("id");
        String contactId = request.getParameter("contactId");
        
        try {
            JsonResponse jsonResponse = new JsonResponse();
            
            // Xử lý các action liên quan đến khách hàng chờ
            if ("confirmWaitingCustomer".equals(action)) {
                if (contactId == null || contactId.trim().isEmpty()) {
                    jsonResponse.setSuccess(false);
                    jsonResponse.setMessage("Thiếu thông tin contactId");
                } else {
                    try {
                        int contactIdInt = Integer.parseInt(contactId);
                        // Có thể cập nhật trạng thái contact message hoặc tạo customer mới
                        // Tạm thời chỉ cập nhật trạng thái thành "confirmed"
                        boolean success = contactDAO.updateMessageStatus(contactIdInt, "confirmed");
                        if (success) {
                            jsonResponse.setSuccess(true);
                            jsonResponse.setMessage("Đã xác nhận khách hàng thành công");
                        } else {
                            jsonResponse.setSuccess(false);
                            jsonResponse.setMessage("Lỗi khi xác nhận khách hàng");
                        }
                    } catch (NumberFormatException e) {
                        jsonResponse.setSuccess(false);
                        jsonResponse.setMessage("ID không hợp lệ");
                    }
                }
                response.getWriter().write(new Gson().toJson(jsonResponse));
                return;
            }
            
            if ("cancelWaitingCustomer".equals(action)) {
                if (contactId == null || contactId.trim().isEmpty()) {
                    jsonResponse.setSuccess(false);
                    jsonResponse.setMessage("Thiếu thông tin contactId");
                } else {
                    try {
                        int contactIdInt = Integer.parseInt(contactId);
                        // Cập nhật trạng thái thành "cancelled" hoặc xóa
                        boolean success = contactDAO.updateMessageStatus(contactIdInt, "cancelled");
                        if (success) {
                            jsonResponse.setSuccess(true);
                            jsonResponse.setMessage("Đã hủy bỏ khách hàng thành công");
                        } else {
                            jsonResponse.setSuccess(false);
                            jsonResponse.setMessage("Lỗi khi hủy bỏ khách hàng");
                        }
                    } catch (NumberFormatException e) {
                        jsonResponse.setSuccess(false);
                        jsonResponse.setMessage("ID không hợp lệ");
                    }
                }
                response.getWriter().write(new Gson().toJson(jsonResponse));
                return;
            }
            
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
