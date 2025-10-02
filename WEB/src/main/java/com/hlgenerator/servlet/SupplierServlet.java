package com.hlgenerator.servlet;

import com.hlgenerator.dao.SupplierDAO;
import com.hlgenerator.model.Supplier;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;

public class SupplierServlet extends HttpServlet {
    private SupplierDAO supplierDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        supplierDAO = new SupplierDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/suppliers.jsp");
            return;
        }
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if ("view".equals(action)) {
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
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"Hành động không hỗ trợ\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            Supplier s = buildSupplierFromRequest(request);
            if (s.getStatus() == null || s.getStatus().isEmpty()) s.setStatus("active");
            boolean ok = supplierDAO.addSupplier(s);
            redirect(request, response, ok, supplierDAO.getLastError(), "suppliers.jsp", ok ? "add_ok" : "add_err");
        } else if ("update".equals(action)) {
            Supplier s = buildSupplierFromRequest(request);
            try { s.setId(Integer.parseInt(request.getParameter("id"))); } catch (Exception ignore) {}
            boolean ok = supplierDAO.updateSupplier(s);
            redirect(request, response, ok, supplierDAO.getLastError(), "suppliers.jsp", ok ? "upd_ok" : "upd_err");
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean ok = supplierDAO.deleteSupplier(id);
            redirect(request, response, ok, supplierDAO.getLastError(), "suppliers.jsp", ok ? "del_ok" : "del_err");
        } else {
            response.sendRedirect(request.getContextPath() + "/suppliers.jsp?message=unsupported");
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

    private void redirect(HttpServletRequest req, HttpServletResponse resp, boolean ok, String err, String page, String flag) throws IOException {
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/" + page + "?message=" + flag);
        } else {
            String e = err != null ? URLEncoder.encode(err, "UTF-8") : "";
            resp.sendRedirect(req.getContextPath() + "/" + page + "?message=" + flag + "&error=" + e);
        }
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
