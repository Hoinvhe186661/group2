package com.hlgenerator.servlet;

import com.hlgenerator.dao.CustomerDAO;
import com.hlgenerator.model.Customer;
import org.json.JSONObject;
import org.json.JSONArray;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
// import javax.servlet.http.HttpSession; // Tạm thời comment vì không sử dụng
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/customers")
public class CustomerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CustomerDAO customerDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            customerDAO = new CustomerDAO();
            System.out.println("CustomerServlet: Initialized successfully");
        } catch (Exception e) {
            System.err.println("CustomerServlet initialization failed: " + e.getMessage());
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
        if (!isAuthenticated(request)) {
            sendErrorResponse(response, "Không có quyền truy cập", 401);
            return;
        }

        String action = request.getParameter("action");
        PrintWriter out = response.getWriter();

        try {
            switch (action != null ? action : "list") {
                case "list":
                    handleGetAllCustomers(out);
                    break;
                case "get":
                    handleGetCustomer(request, out);
                    break;
                case "search":
                    handleSearchCustomers(request, out);
                    break;
                case "generateCode":
                    handleGenerateCustomerCode(out);
                    break;
                default:
                    handleGetAllCustomers(out);
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
        
        // Check authentication
        if (!isAuthenticated(request)) {
            sendErrorResponse(response, "Không có quyền truy cập", 401);
            return;
        }

        String action = request.getParameter("action");
        PrintWriter out = response.getWriter();

        try {
            switch (action != null ? action : "add") {
                case "add":
                    handleAddCustomer(request, out);
                    break;
                case "update":
                    handleUpdateCustomer(request, out);
                    break;
                case "delete":
                    handleDeleteCustomer(request, out);
                    break;
                case "hardDelete":
                    handleHardDeleteCustomer(request, out);
                    break;
                case "activate":
                    handleActivateCustomer(request, out);
                    break;
                default:
                    sendErrorResponse(response, "Hành động không hợp lệ", 400);
                    break;
            }
        } catch (Exception e) {
            sendErrorResponse(response, "Lỗi máy chủ nội bộ: " + e.getMessage(), 500);
        }
    }

    private void handleGetAllCustomers(PrintWriter out) {
        try {
            List<Customer> customers = customerDAO.getAllCustomers();
            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("data", new JSONArray(customers));
            out.print(result.toString());
            System.out.println("handleGetAllCustomers: Successfully returned " + customers.size() + " customers");
        } catch (Exception e) {
            System.err.println("handleGetAllCustomers error: " + e.getMessage());
            e.printStackTrace();
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Lỗi khi lấy danh sách khách hàng: " + e.getMessage());
            out.print(error.toString());
        }
    }

    private void handleGetCustomer(HttpServletRequest request, PrintWriter out) {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            sendErrorResponse(out, "Mã khách hàng là bắt buộc", 400);
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            Customer customer = customerDAO.getCustomerById(id);
            
            JSONObject result = new JSONObject();
            if (customer != null) {
                result.put("success", true);
                result.put("data", customerToJSON(customer));
            } else {
                result.put("success", false);
                result.put("message", "Không tìm thấy khách hàng");
            }
            out.print(result.toString());
        } catch (NumberFormatException e) {
            sendErrorResponse(out, "Mã khách hàng không hợp lệ", 400);
        }
    }

    private void handleSearchCustomers(HttpServletRequest request, PrintWriter out) {
        String searchTerm = request.getParameter("search");
        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            handleGetAllCustomers(out);
            return;
        }

        List<Customer> customers = customerDAO.searchCustomers(searchTerm.trim());
        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("data", new JSONArray(customers));
        out.print(result.toString());
    }

    private void handleGenerateCustomerCode(PrintWriter out) {
        String nextCode = customerDAO.generateNextCustomerCode();
        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("customerCode", nextCode);
        out.print(result.toString());
    }

    private void handleAddCustomer(HttpServletRequest request, PrintWriter out) {
        try {
            // Get form parameters
            String customerCode = request.getParameter("customerCode");
            String companyName = request.getParameter("companyName");
            String contactPerson = request.getParameter("userContract");
            String email = request.getParameter("customerEmail");
            String phone = request.getParameter("customerPhone");
            String address = request.getParameter("customerAddress");
            String taxCode = request.getParameter("taxCode");
            String customerType = request.getParameter("customerType");

            // Validate required fields
            if (customerCode == null || customerCode.trim().isEmpty() ||
                contactPerson == null || contactPerson.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                phone == null || phone.trim().isEmpty() ||
                address == null || address.trim().isEmpty() ||
                customerType == null || customerType.trim().isEmpty()) {
                
                sendErrorResponse(out, "Tất cả các trường bắt buộc phải được điền", 400);
                return;
            }

            // Kiểm tra tên công ty chỉ bắt buộc khi loại khách hàng là doanh nghiệp
            if ("company".equals(customerType) && (companyName == null || companyName.trim().isEmpty())) {
                sendErrorResponse(out, "Vui lòng nhập tên công ty cho khách hàng doanh nghiệp", 400);
                return;
            }

            // Check if customer code already exists
            if (customerDAO.isCustomerCodeExists(customerCode.trim())) {
                sendErrorResponse(out, "Mã khách hàng đã tồn tại", 400);
                return;
            }

            // Create customer object
            Customer customer = new Customer(
                customerCode.trim(),
                companyName != null ? companyName.trim() : null,
                contactPerson.trim(),
                email.trim(),
                phone.trim(),
                address.trim(),
                taxCode != null ? taxCode.trim() : null,
                customerType.trim()
            );

            // Add to database
            boolean success = customerDAO.addCustomer(customer);
            
            JSONObject result = new JSONObject();
            if (success) {
                // Thêm activity log
                com.hlgenerator.util.ActionLogUtil.addAction(request, "Thêm khách hàng mới", "customers", 
                    null, "Đã thêm khách hàng: " + customerCode, "success");
                result.put("success", true);
                result.put("message", "Đã thêm khách hàng thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không thể thêm khách hàng");
            }
            out.print(result.toString());

        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi thêm khách hàng: " + e.getMessage(), 500);
        }
    }

    private void handleUpdateCustomer(HttpServletRequest request, PrintWriter out) {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                sendErrorResponse(out, "Mã khách hàng là bắt buộc", 400);
                return;
            }

            int id = Integer.parseInt(idParam);
            
            // Get form parameters
            String customerCode = request.getParameter("customerCode");
            String companyName = request.getParameter("companyName");
            String contactPerson = request.getParameter("userContract");
            String email = request.getParameter("customerEmail");
            String phone = request.getParameter("customerPhone");
            String address = request.getParameter("customerAddress");
            String taxCode = request.getParameter("taxCode");
            String customerType = request.getParameter("customerType");
            String status = request.getParameter("status");

            // Validate required fields
            if (customerCode == null || customerCode.trim().isEmpty() ||
                contactPerson == null || contactPerson.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                phone == null || phone.trim().isEmpty() ||
                address == null || address.trim().isEmpty() ||
                customerType == null || customerType.trim().isEmpty()) {
                
                sendErrorResponse(out, "Tất cả các trường bắt buộc phải được điền", 400);
                return;
            }

            // Kiểm tra tên công ty chỉ bắt buộc khi loại khách hàng là doanh nghiệp
            if ("company".equals(customerType) && (companyName == null || companyName.trim().isEmpty())) {
                sendErrorResponse(out, "Vui lòng nhập tên công ty cho khách hàng doanh nghiệp", 400);
                return;
            }

            // Check if customer code already exists (excluding current customer)
            if (customerDAO.isCustomerCodeExists(customerCode.trim(), id)) {
                sendErrorResponse(out, "Mã khách hàng đã tồn tại", 400);
                return;
            }

            // Get existing customer to preserve timestamps
            Customer existingCustomer = customerDAO.getCustomerById(id);
            if (existingCustomer == null) {
                sendErrorResponse(out, "Không tìm thấy khách hàng", 404);
                return;
            }

            // Update customer object
            existingCustomer.setCustomerCode(customerCode.trim());
            existingCustomer.setCompanyName(companyName != null ? companyName.trim() : null);
            existingCustomer.setContactPerson(contactPerson.trim());
            existingCustomer.setEmail(email.trim());
            existingCustomer.setPhone(phone.trim());
            existingCustomer.setAddress(address.trim());
            existingCustomer.setTaxCode(taxCode != null ? taxCode.trim() : null);
            existingCustomer.setCustomerType(customerType.trim());
            if (status != null && !status.trim().isEmpty()) {
                existingCustomer.setStatus(status.trim());
            }

            // Update in database
            boolean success = customerDAO.updateCustomer(existingCustomer);
            
            JSONObject result = new JSONObject();
            if (success) {
                // Thêm activity log
                com.hlgenerator.util.ActionLogUtil.addAction(request, "Cập nhật khách hàng", "customers", 
                    id, "Đã cập nhật khách hàng: " + customerCode, "info");
                result.put("success", true);
                result.put("message", "Đã cập nhật khách hàng thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không thể cập nhật khách hàng");
            }
            out.print(result.toString());

        } catch (NumberFormatException e) {
            sendErrorResponse(out, "Mã khách hàng không hợp lệ", 400);
        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi cập nhật khách hàng: " + e.getMessage(), 500);
        }
    }

    private void handleDeleteCustomer(HttpServletRequest request, PrintWriter out) {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                sendErrorResponse(out, "Mã khách hàng là bắt buộc", 400);
                return;
            }

            int id = Integer.parseInt(idParam);
            Customer customer = customerDAO.getCustomerById(id);
            boolean success = customerDAO.deleteCustomer(id);
            
            JSONObject result = new JSONObject();
            if (success) {
                // Thêm activity log
                String customerInfo = customer != null ? customer.getCustomerCode() : "ID: " + id;
                com.hlgenerator.util.ActionLogUtil.addAction(request, "Xóa khách hàng", "customers", 
                    id, "Đã xóa khách hàng: " + customerInfo, "warning");
                result.put("success", true);
                result.put("message", "Đã xóa khách hàng thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không thể xóa khách hàng");
            }
            out.print(result.toString());

        } catch (NumberFormatException e) {
            sendErrorResponse(out, "Mã khách hàng không hợp lệ", 400);
        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi xóa khách hàng: " + e.getMessage(), 500);
        }
    }

    private void handleHardDeleteCustomer(HttpServletRequest request, PrintWriter out) {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                sendErrorResponse(out, "Mã khách hàng là bắt buộc", 400);
                return;
            }

            int id = Integer.parseInt(idParam);
            Customer customer = customerDAO.getCustomerById(id);
            boolean success = customerDAO.hardDeleteCustomer(id);

            JSONObject result = new JSONObject();
            if (success) {
                String customerInfo = customer != null ? customer.getCustomerCode() : "ID: " + id;
                // Log action
                com.hlgenerator.util.ActionLogUtil.addAction(request, "Xóa vĩnh viễn khách hàng", "customers",
                        id, "Đã xóa vĩnh viễn khách hàng: " + customerInfo, "danger");
                result.put("success", true);
                result.put("message", "Đã xóa vĩnh viễn khách hàng thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không thể xóa vĩnh viễn khách hàng");
            }
            out.print(result.toString());

        } catch (NumberFormatException e) {
            sendErrorResponse(out, "Mã khách hàng không hợp lệ", 400);
        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi xóa vĩnh viễn khách hàng: " + e.getMessage(), 500);
        }
    }

    private void handleActivateCustomer(HttpServletRequest request, PrintWriter out) {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                sendErrorResponse(out, "Mã khách hàng là bắt buộc", 400);
                return;
            }

            int id = Integer.parseInt(idParam);
            Customer customer = customerDAO.getCustomerById(id);
            
            if (customer == null) {
                sendErrorResponse(out, "Không tìm thấy khách hàng", 404);
                return;
            }

            customer.setStatus("active");
            boolean success = customerDAO.updateCustomer(customer);
            
            JSONObject result = new JSONObject();
            if (success) {
                // Thêm activity log
                com.hlgenerator.util.ActionLogUtil.addAction(request, "Kích hoạt khách hàng", "customers", 
                    id, "Đã kích hoạt khách hàng: " + customer.getCustomerCode(), "success");
                result.put("success", true);
                result.put("message", "Đã kích hoạt khách hàng thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không thể kích hoạt khách hàng");
            }
            out.print(result.toString());

        } catch (NumberFormatException e) {
            sendErrorResponse(out, "Mã khách hàng không hợp lệ", 400);
        } catch (Exception e) {
            sendErrorResponse(out, "Lỗi khi kích hoạt khách hàng: " + e.getMessage(), 500);
        }
    }

    private boolean isAuthenticated(HttpServletRequest request) {
        javax.servlet.http.HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        
        Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
        if (isLoggedIn == null || !isLoggedIn) {
            return false;
        }
        
        // Kiểm tra quyền: chỉ admin và customer_support mới có thể quản lý khách hàng
        String userRole = (String) session.getAttribute("userRole");
        return "admin".equals(userRole) || "customer_support".equals(userRole);
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
    
    private JSONObject customerToJSON(Customer customer) {
        JSONObject json = new JSONObject();
        json.put("id", customer.getId());
        json.put("customerCode", customer.getCustomerCode());
        json.put("companyName", customer.getCompanyName());
        json.put("contactPerson", customer.getContactPerson());
        json.put("email", customer.getEmail());
        json.put("phone", customer.getPhone());
        json.put("address", customer.getAddress());
        json.put("taxCode", customer.getTaxCode());
        json.put("customerType", customer.getCustomerType());
        json.put("status", customer.getStatus());
        json.put("createdAt", customer.getCreatedAt());
        json.put("updatedAt", customer.getUpdatedAt());
        return json;
    }
}
