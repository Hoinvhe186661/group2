package com.hlgenerator.servlet;

import com.hlgenerator.dao.SupplierDAO;
import com.hlgenerator.model.Supplier;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/supplier")
public class SupplierServlet extends HttpServlet {
    private SupplierDAO supplierDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        supplierDAO = new SupplierDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("view".equals(action)) {
            viewSupplier(request, response);
        } else if ("page".equals(action) || action == null) {
            showSuppliersPage(request, response);
        } else if ("edit".equals(action)) {
            showEditSupplierPage(request, response);
        } else if ("add".equals(action)) {
            showAddSupplierPage(request, response);
        } else if ("filter".equals(action)) {
            filterSuppliers(request, response);
        } else if ("getFilterOptions".equals(action)) {
            getFilterOptions(request, response);
        } else {
            getAllSuppliers(request, response);
        }
    }
    
    /**
     * Hiển thị trang quản lý nhà cung cấp với tất cả dữ liệu cần thiết
     */
    private void showSuppliersPage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Lấy tham số lọc từ request
            String companyName = request.getParameter("companyFilter");
            String contactPerson = request.getParameter("contactFilter");
            String status = request.getParameter("statusFilter");
            String keyword = request.getParameter("searchInput");
            
            // Lấy tham số phân trang
            int page = 1;
            int pageSize = 10;
            try {
                String pageParam = request.getParameter("page");
                if (pageParam != null && !pageParam.trim().isEmpty()) {
                    page = Integer.parseInt(pageParam);
                }
                String pageSizeParam = request.getParameter("pageSize");
                if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
                    pageSize = Integer.parseInt(pageSizeParam);
                }
            } catch (NumberFormatException e) {
                // Sử dụng giá trị mặc định nếu parse lỗi
            }
            
            // Lấy danh sách nhà cung cấp với lọc backend
            List<Supplier> suppliers;
            int totalCount;
            
            if ((companyName != null && !companyName.isEmpty()) || 
                (contactPerson != null && !contactPerson.isEmpty()) || 
                (status != null && !status.isEmpty()) || 
                (keyword != null && !keyword.isEmpty())) {
                // Có điều kiện lọc - sử dụng backend filter
                suppliers = supplierDAO.getSuppliersWithBackendFilter(companyName, contactPerson, status, keyword, page, pageSize);
                totalCount = supplierDAO.countSuppliersWithFilter(companyName, contactPerson, status, keyword);
            } else {
                // Không có điều kiện lọc - lấy tất cả
                suppliers = supplierDAO.getAllSuppliers();
                totalCount = suppliers.size();
            }
            
            // Set attributes cho JSP
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("companyFilter", companyName);
            request.setAttribute("contactFilter", contactPerson);
            request.setAttribute("statusFilter", status);
            request.setAttribute("searchInput", keyword);
            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("totalPages", (int) Math.ceil((double) totalCount / pageSize));
            
            // Forward to JSP
            request.getRequestDispatcher("/supplier.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/supplier.jsp").forward(request, response);
        }
    }
    
    /**
     * Hiển thị trang thêm nhà cung cấp với dữ liệu cần thiết
     */
    private void showAddSupplierPage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            request.setAttribute("action", "add");
            request.getRequestDispatcher("/supplier.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/supplier.jsp").forward(request, response);
        }
    }
    
    /**
     * Hiển thị trang sửa nhà cung cấp với dữ liệu cần thiết
     */
    private void showEditSupplierPage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int supplierId = Integer.parseInt(request.getParameter("id"));
            
            // Lấy thông tin nhà cung cấp
            Supplier supplier = supplierDAO.getSupplierById(supplierId);
            if (supplier == null) {
                request.setAttribute("error", "Không tìm thấy nhà cung cấp");
                request.getRequestDispatcher("/supplier.jsp").forward(request, response);
                return;
            }
            
            request.setAttribute("supplier", supplier);
            request.setAttribute("action", "edit");
            
            request.getRequestDispatcher("/supplier.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/supplier.jsp").forward(request, response);
        }
    }
    
    /**
     * Xem chi tiết nhà cung cấp qua AJAX
     */
    private void viewSupplier(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Supplier s = supplierDAO.getSupplierById(id);
            if (s != null) {
                // Escape JSON strings properly
                String supplierCode = escapeJsonString(s.getSupplierCode());
                String companyName = escapeJsonString(s.getCompanyName());
                String contactPerson = escapeJsonString(s.getContactPerson());
                String email = escapeJsonString(s.getEmail());
                String phone = escapeJsonString(s.getPhone());
                String address = escapeJsonString(s.getAddress());
                String bankInfo = escapeJsonString(s.getBankInfo());
                String status = escapeJsonString(s.getStatus());
                
                response.getWriter().write("{\"success\":true,\"data\":{\"id\":" + s.getId() + 
                    ",\"supplierCode\":\"" + supplierCode + 
                    "\",\"companyName\":\"" + companyName + 
                    "\",\"contactPerson\":\"" + contactPerson + 
                    "\",\"email\":\"" + email + 
                    "\",\"phone\":\"" + phone + 
                    "\",\"address\":\"" + address + 
                    "\",\"bankInfo\":\"" + bankInfo + 
                    "\",\"status\":\"" + status + "\"}}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy nhà cung cấp\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Lấy tất cả nhà cung cấp qua AJAX
     */
    private void getAllSuppliers(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();
            response.getWriter().write("{\"success\":true,\"data\":" + suppliers + "}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}");
        }
    }

    /**
     * Lấy dữ liệu cho các dropdown filter
     */
    private void getFilterOptions(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            System.out.println("Getting filter options...");
            // Lấy danh sách tất cả nhà cung cấp để tạo dropdown
            List<Supplier> allSuppliers = supplierDAO.getAllSuppliers();
            System.out.println("Found " + allSuppliers.size() + " suppliers");
            
            // Tạo danh sách unique companies
            List<Supplier> companies = new ArrayList<>();
            List<Supplier> contacts = new ArrayList<>();
            
            for (Supplier supplier : allSuppliers) {
                // Thêm company nếu chưa có
                boolean companyExists = false;
                for (Supplier company : companies) {
                    if (company.getCompanyName() != null && 
                        company.getCompanyName().equals(supplier.getCompanyName())) {
                        companyExists = true;
                        break;
                    }
                }
                if (!companyExists && supplier.getCompanyName() != null && !supplier.getCompanyName().trim().isEmpty()) {
                    companies.add(supplier);
                }
                
                // Thêm contact nếu chưa có
                boolean contactExists = false;
                for (Supplier contact : contacts) {
                    if (contact.getContactPerson() != null && 
                        contact.getContactPerson().equals(supplier.getContactPerson())) {
                        contactExists = true;
                        break;
                    }
                }
                if (!contactExists && supplier.getContactPerson() != null && !supplier.getContactPerson().trim().isEmpty()) {
                    contacts.add(supplier);
                }
            }
            
            // Tạo JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":{");
            json.append("\"companies\":[");
            
            for (int i = 0; i < companies.size(); i++) {
                Supplier s = companies.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"companyName\":\"").append(escapeJsonString(s.getCompanyName())).append("\",");
                json.append("\"supplierCode\":\"").append(escapeJsonString(s.getSupplierCode())).append("\"");
                json.append("}");
            }
            
            json.append("],");
            json.append("\"contacts\":[");
            
            for (int i = 0; i < contacts.size(); i++) {
                Supplier s = contacts.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"contactPerson\":\"").append(escapeJsonString(s.getContactPerson())).append("\"");
                json.append("}");
            }
            
            json.append("]");
            json.append("}}");
            
            System.out.println("JSON response: " + json.toString());
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}");
        }
    }

    /**
     * Lọc nhà cung cấp qua AJAX với backend SQL query
     */
    private void filterSuppliers(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            // Lấy tham số lọc từ request
            String companyName = request.getParameter("companyFilter");
            String contactPerson = request.getParameter("contactFilter");
            String status = request.getParameter("statusFilter");
            String keyword = request.getParameter("searchInput");
            
            System.out.println("Filter parameters:");
            System.out.println("  companyName: " + companyName);
            System.out.println("  contactPerson: " + contactPerson);
            System.out.println("  status: " + status);
            System.out.println("  keyword: " + keyword);
            
            // Lấy tham số phân trang
            int page = 1;
            int pageSize = 10;
            try {
                String pageParam = request.getParameter("page");
                if (pageParam != null && !pageParam.trim().isEmpty()) {
                    page = Integer.parseInt(pageParam);
                }
                String pageSizeParam = request.getParameter("pageSize");
                if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
                    pageSize = Integer.parseInt(pageSizeParam);
                }
            } catch (NumberFormatException e) {
                // Sử dụng giá trị mặc định nếu parse lỗi
            }
            
            // Lấy danh sách nhà cung cấp với lọc backend
            List<Supplier> suppliers;
            int totalCount;
            
            if ((companyName != null && !companyName.isEmpty()) || 
                (contactPerson != null && !contactPerson.isEmpty()) || 
                (status != null && !status.isEmpty()) || 
                (keyword != null && !keyword.isEmpty())) {
                // Có điều kiện lọc - sử dụng backend filter
                suppliers = supplierDAO.getSuppliersWithBackendFilter(companyName, contactPerson, status, keyword, page, pageSize);
                totalCount = supplierDAO.countSuppliersWithFilter(companyName, contactPerson, status, keyword);
            } else {
                // Không có điều kiện lọc - lấy tất cả
                suppliers = supplierDAO.getAllSuppliers();
                totalCount = suppliers.size();
            }
            
            // Tạo JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":{");
            json.append("\"suppliers\":[");
            
            for (int i = 0; i < suppliers.size(); i++) {
                Supplier s = suppliers.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"id\":").append(s.getId()).append(",");
                json.append("\"supplierCode\":\"").append(escapeJsonString(s.getSupplierCode())).append("\",");
                json.append("\"companyName\":\"").append(escapeJsonString(s.getCompanyName())).append("\",");
                json.append("\"contactPerson\":\"").append(escapeJsonString(s.getContactPerson())).append("\",");
                json.append("\"email\":\"").append(escapeJsonString(s.getEmail())).append("\",");
                json.append("\"phone\":\"").append(escapeJsonString(s.getPhone())).append("\",");
                json.append("\"address\":\"").append(escapeJsonString(s.getAddress())).append("\",");
                json.append("\"bankInfo\":\"").append(escapeJsonString(s.getBankInfo())).append("\",");
                json.append("\"status\":\"").append(escapeJsonString(s.getStatus())).append("\"");
                json.append("}");
            }
            
            json.append("],");
            json.append("\"pagination\":{");
            json.append("\"currentPage\":").append(page).append(",");
            json.append("\"pageSize\":").append(pageSize).append(",");
            json.append("\"totalCount\":").append(totalCount).append(",");
            json.append("\"totalPages\":").append((int) Math.ceil((double) totalCount / pageSize));
            json.append("}");
            json.append("}}");
            
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        
        try {
            if ("add".equals(action)) {
                addSupplier(request, response);
            } else if ("update".equals(action)) {
                updateSupplier(request, response);
            } else if ("delete".equals(action)) {
                deleteSupplier(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/supplier?message=unsupported");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/supplier?message=system_error&error=" + 
                URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
    
    /**
     * Thêm nhà cung cấp mới
     */
    private void addSupplier(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            Supplier supplier = buildSupplierFromRequest(request);
            if (supplier.getStatus() == null || supplier.getStatus().isEmpty()) {
                supplier.setStatus("active");
            }
            
            // Validation
            if (supplier.getSupplierCode() == null || supplier.getSupplierCode().trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/supplier?message=validation_error&error=" + 
                    URLEncoder.encode("Mã nhà cung cấp không được để trống", "UTF-8"));
                return;
            }
            
            if (supplier.getCompanyName() == null || supplier.getCompanyName().trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/supplier?message=validation_error&error=" + 
                    URLEncoder.encode("Tên công ty không được để trống", "UTF-8"));
                return;
            }
            
            // Kiểm tra duplicate supplier_code
            if (supplierDAO.isSupplierCodeExists(supplier.getSupplierCode())) {
                response.sendRedirect(request.getContextPath() + "/supplier?message=validation_error&error=" + 
                    URLEncoder.encode("Mã nhà cung cấp đã tồn tại", "UTF-8"));
                return;
            }
            
            // Validation email format
            if (supplier.getEmail() != null && !supplier.getEmail().trim().isEmpty()) {
                if (!isValidEmail(supplier.getEmail())) {
                    response.sendRedirect(request.getContextPath() + "/supplier?message=validation_error&error=" + 
                        URLEncoder.encode("Email không đúng định dạng", "UTF-8"));
                    return;
                }
            }
            
            // Validation phone format
            if (supplier.getPhone() != null && !supplier.getPhone().trim().isEmpty()) {
                if (!isValidPhone(supplier.getPhone())) {
                    response.sendRedirect(request.getContextPath() + "/supplier?message=validation_error&error=" + 
                        URLEncoder.encode("Số điện thoại không đúng định dạng", "UTF-8"));
                    return;
                }
            }
            
            boolean success = supplierDAO.addSupplier(supplier);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/supplier?message=success");
            } else {
                String error = supplierDAO.getLastError();
                response.sendRedirect(request.getContextPath() + "/supplier?message=database_error&error=" + 
                    URLEncoder.encode(error != null ? error : "Lỗi không xác định", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/supplier?message=system_error&error=" + 
                URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
    
    /**
     * Cập nhật nhà cung cấp
     */
    private void updateSupplier(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int supplierId = Integer.parseInt(request.getParameter("id"));
            Supplier supplier = buildSupplierFromRequest(request);
            supplier.setId(supplierId);
            
            // Validation
            if (supplier.getSupplierCode() == null || supplier.getSupplierCode().trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/supplier?message=validation_error&error=" + 
                    URLEncoder.encode("Mã nhà cung cấp không được để trống", "UTF-8"));
                return;
            }
            
            if (supplier.getCompanyName() == null || supplier.getCompanyName().trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/supplier?message=validation_error&error=" + 
                    URLEncoder.encode("Tên công ty không được để trống", "UTF-8"));
                return;
            }
            
            // Kiểm tra duplicate supplier_code (trừ chính nó)
            if (supplierDAO.isSupplierCodeExists(supplier.getSupplierCode(), supplier.getId())) {
                response.sendRedirect(request.getContextPath() + "/supplier?message=validation_error&error=" + 
                    URLEncoder.encode("Mã nhà cung cấp đã tồn tại", "UTF-8"));
                return;
            }
            
            // Validation email format
            if (supplier.getEmail() != null && !supplier.getEmail().trim().isEmpty()) {
                if (!isValidEmail(supplier.getEmail())) {
                    response.sendRedirect(request.getContextPath() + "/supplier?message=validation_error&error=" + 
                        URLEncoder.encode("Email không đúng định dạng", "UTF-8"));
                    return;
                }
            }
            
            // Validation phone format
            if (supplier.getPhone() != null && !supplier.getPhone().trim().isEmpty()) {
                if (!isValidPhone(supplier.getPhone())) {
                    response.sendRedirect(request.getContextPath() + "/supplier?message=validation_error&error=" + 
                        URLEncoder.encode("Số điện thoại không đúng định dạng", "UTF-8"));
                    return;
                }
            }
            
            boolean success = supplierDAO.updateSupplier(supplier);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/supplier?message=update_success");
            } else {
                String error = supplierDAO.getLastError();
                response.sendRedirect(request.getContextPath() + "/supplier?message=database_error&error=" + 
                    URLEncoder.encode(error != null ? error : "Lỗi không xác định", "UTF-8"));
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/supplier?message=validation_error&error=" + 
                URLEncoder.encode("ID nhà cung cấp không hợp lệ", "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/supplier?message=system_error&error=" + 
                URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
    
    /**
     * Xóa nhà cung cấp
     */
    private void deleteSupplier(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int supplierId = Integer.parseInt(request.getParameter("id"));
            
            boolean success = supplierDAO.deleteSupplier(supplierId);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/supplier?message=delete_success");
            } else {
                String error = supplierDAO.getLastError();
                response.sendRedirect(request.getContextPath() + "/supplier?message=database_error&error=" + 
                    URLEncoder.encode(error != null ? error : "Lỗi không xác định", "UTF-8"));
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/supplier?message=validation_error&error=" + 
                URLEncoder.encode("ID nhà cung cấp không hợp lệ", "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/supplier?message=system_error&error=" + 
                URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }

    private Supplier buildSupplierFromRequest(HttpServletRequest req) {
        Supplier s = new Supplier();
        s.setSupplierCode(req.getParameter("supplier_code"));
        s.setCompanyName(req.getParameter("company_name"));
        s.setContactPerson(req.getParameter("contact_person"));
        s.setEmail(req.getParameter("email"));
        s.setPhone(req.getParameter("phone"));
        s.setAddress(req.getParameter("address"));
        
        // Xử lý bank_info từ 2 trường riêng biệt hoặc từ trường bank_info
        String bankInfo = req.getParameter("bank_info");
        if (bankInfo != null && !bankInfo.trim().isEmpty()) {
            // Nếu bank_info đã là JSON hợp lệ, giữ nguyên
            if (isValidJson(bankInfo)) {
                s.setBankInfo(bankInfo);
            } else {
                // Nếu không phải JSON, tạo JSON từ nội dung
                s.setBankInfo(createBankInfoJson(bankInfo));
            }
        } else {
            // Tạo JSON từ 2 trường riêng biệt
            String bankName = req.getParameter("bank_name");
            String accountNumber = req.getParameter("account_number");
            s.setBankInfo(createBankInfoJsonFromFields(bankName, accountNumber));
        }
        
        s.setStatus(req.getParameter("status"));
        return s;
    }


    
    private boolean isValidJson(String json) {
        if (json == null || json.trim().isEmpty()) return false;
        String trimmed = json.trim();
        return (trimmed.startsWith("{") && trimmed.endsWith("}")) || 
               (trimmed.startsWith("[") && trimmed.endsWith("]"));
    }
    
    private String createBankInfoJson(String bankInfo) {
        // Escape dấu ngoặc kép và các ký tự đặc biệt
        String escaped = (bankInfo != null ? bankInfo : "").replace("\\", "\\\\")
                                .replace("\"", "\\\"")
                                .replace("\n", "\\n")
                                .replace("\r", "\\r")
                                .replace("\t", "\\t");
        
        // Tạo JSON object với thông tin ngân hàng
        return "{\"bank_name\":\"" + escaped + "\",\"account_number\":\"\",\"notes\":\"\"}";
    }
    
    private String createBankInfoJsonFromFields(String bankName, String accountNumber) {
        // Escape dấu ngoặc kép và các ký tự đặc biệt
        String bankNameEscaped = (bankName != null ? bankName : "").replace("\\", "\\\\")
                                                                   .replace("\"", "\\\"")
                                                                   .replace("\n", "\\n")
                                                                   .replace("\r", "\\r")
                                                                   .replace("\t", "\\t");
        
        String accountNumberEscaped = (accountNumber != null ? accountNumber : "").replace("\\", "\\\\")
                                                                                  .replace("\"", "\\\"")
                                                                                  .replace("\n", "\\n")
                                                                                  .replace("\r", "\\r")
                                                                                  .replace("\t", "\\t");
        
        // Tạo JSON object với 2 trường riêng biệt
        return "{\"bank_name\":\"" + bankNameEscaped + "\",\"account_number\":\"" + accountNumberEscaped + "\"}";
    }
    
    private String escapeJsonString(String str) {
        if (str == null) {
            return "";
        }
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\b", "\\b")
                  .replace("\f", "\\f")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
    
    /**
     * Kiểm tra email có đúng định dạng không
     */
    private boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return true; // Email không bắt buộc
        }
        String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        return email.matches(emailRegex);
    }
    
    /**
     * Kiểm tra số điện thoại có đúng định dạng không
     */
    private boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return true; // Phone không bắt buộc
        }
        // Chấp nhận số điện thoại Việt Nam: 0xxxxxxxxx hoặc +84xxxxxxxxx
        String phoneRegex = "^(0|\\+84)[0-9]{9,10}$";
        return phone.matches(phoneRegex);
    }
}
