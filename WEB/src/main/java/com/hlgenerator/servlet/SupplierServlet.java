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
        } else {
            getAllSuppliers(request, response);
        }
    }
    
    /**
     * Hiển thị trang quản lý nhà cung cấp với tất cả dữ liệu cần thiết
     * Tác giả: Sơn Lê
     */
    private void showSuppliersPage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Lấy tham số lọc từ request
            String companyName = request.getParameter("companyFilter");
            String contactPerson = request.getParameter("contactFilter");
            String status = request.getParameter("statusFilter");
            String keyword = request.getParameter("searchInput");
            
            // Lấy danh sách nhà cung cấp (có hoặc không có lọc)
            List<Supplier> suppliers;
            if ((companyName != null && !companyName.isEmpty()) || 
                (contactPerson != null && !contactPerson.isEmpty()) || 
                (status != null && !status.isEmpty()) || 
                (keyword != null && !keyword.isEmpty())) {
                suppliers = supplierDAO.getFilteredSuppliers(companyName, contactPerson, status, keyword);
            } else {
                suppliers = supplierDAO.getAllSuppliers();
            }
            
            // Lấy danh sách tất cả để tạo dropdown lọc
            List<Supplier> allSuppliers = supplierDAO.getAllSuppliers();
            
            // Set attributes cho JSP
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("allSuppliers", allSuppliers);
            request.setAttribute("companyFilter", companyName);
            request.setAttribute("contactFilter", contactPerson);
            request.setAttribute("statusFilter", status);
            request.setAttribute("searchInput", keyword);
            
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
     * Tác giả: Sơn Lê
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
     * Tác giả: Sơn Lê
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
     * Tác giả: Sơn Lê
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
     * Tác giả: Sơn Lê
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
     * Tác giả: Sơn Lê
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
     * Tác giả: Sơn Lê
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
     * Tác giả: Sơn Lê
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
        String escaped = bankInfo.replace("\\", "\\\\")
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
}
