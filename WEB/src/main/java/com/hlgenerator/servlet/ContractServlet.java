package com.hlgenerator.servlet;

import com.hlgenerator.dao.ContractDAO;
import com.hlgenerator.model.Contract;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

@WebServlet("/api/contracts")
public class ContractServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ContractDAO contractDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        contractDAO = new ContractDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String action = request.getParameter("action");
        PrintWriter out = response.getWriter();

        if ("get".equalsIgnoreCase(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            Contract c = contractDAO.getContractById(id);
            if (c != null) {
                out.print(successJson(toJson(c)));
            } else {
                out.print(errorJson("Không tìm thấy hợp đồng"));
            }
            return;
        }

        if ("deleted".equalsIgnoreCase(action)) {
            // Trả về danh sách hợp đồng đã bị xóa với tìm kiếm, sắp xếp và phân trang
            String pageParam = request.getParameter("page");
            String pageSizeParam = request.getParameter("pageSize");
            String search = request.getParameter("search");
            String sortBy = request.getParameter("sortBy");
            String sortDir = request.getParameter("sortDir");
            
            System.out.println("Getting deleted contracts - page: " + pageParam + ", pageSize: " + pageSizeParam + ", search: " + search);
            
            int page = 1;
            int pageSize = 10;
            try { if (pageParam != null) page = Integer.parseInt(pageParam); } catch (Exception ignored) {}
            try { if (pageSizeParam != null) pageSize = Integer.parseInt(pageSizeParam); } catch (Exception ignored) {}
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 10;
            
            // Lấy danh sách hợp đồng đã bị xóa với phân trang
            List<Contract> contracts = contractDAO.getDeletedContractsPage(page, pageSize, search, sortBy, sortDir);
            int totalRecords = contractDAO.countDeletedContracts(search);
            int totalPages = (int) Math.ceil(totalRecords / (double) pageSize);
            if (totalPages == 0) totalPages = 1;
            
            System.out.println("Found " + contracts.size() + " deleted contracts, total: " + totalRecords);
            
            JSONArray arr = new JSONArray();
            for (Contract c : contracts) {
                JSONObject contractJson = toJson(c);
                contractJson.put("deletedByName", c.getDeletedByName());
                arr.put(contractJson);
            }
            
            JSONObject result = new JSONObject();
            result.put("data", arr);
            result.put("totalPages", totalPages);
            result.put("totalRecords", totalRecords);
            result.put("currentPage", page);
            result.put("pageSize", pageSize);
            
            System.out.println("Response: " + result.toString());
            out.print(successJson(result));
            return;
        }

        if ("customers".equalsIgnoreCase(action)) {
            // Trả về danh sách khách hàng cho dropdown
            com.hlgenerator.dao.CustomerDAO customerDAO = new com.hlgenerator.dao.CustomerDAO();
            java.util.List<com.hlgenerator.model.Customer> customers = customerDAO.getAllCustomers();
            JSONArray arr = new JSONArray();
            for (com.hlgenerator.model.Customer customer : customers) {
                JSONObject obj = new JSONObject();
                obj.put("id", customer.getId());
                obj.put("customerCode", customer.getCustomerCode());
                obj.put("companyName", customer.getCompanyName());
                obj.put("contactPerson", customer.getContactPerson());
                arr.put(obj);
            }
            out.print(successJson(arr));
            return;
        }

        if ("products".equalsIgnoreCase(action)) {
            // Trả về danh sách sản phẩm cho dropdown
            try {
                // Sử dụng thông tin từ database.properties
                java.util.Properties props = new java.util.Properties();
                java.io.InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties");
                props.load(input);
                
                String url = props.getProperty("db.url");
                String user = props.getProperty("db.username");
                String pass = props.getProperty("db.password");
                
                try (java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, pass)) {
                    String sql = "SELECT p.id, p.product_code, p.product_name, p.description, p.unit_price, p.warranty_months, COALESCE(i.current_stock, 0) AS quantity " +
                                 "FROM products p LEFT JOIN inventory i ON p.id = i.product_id ORDER BY p.product_name";
                    try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                        java.sql.ResultSet rs = ps.executeQuery();
                        JSONArray arr = new JSONArray();
                        while (rs.next()) {
                            JSONObject obj = new JSONObject();
                            obj.put("id", rs.getInt("id"));
                            obj.put("productCode", rs.getString("product_code"));
                            obj.put("productName", rs.getString("product_name"));
                            obj.put("description", rs.getString("description"));
                            obj.put("unitPrice", rs.getBigDecimal("unit_price"));
                            obj.put("warrantyMonths", rs.getInt("warranty_months"));
                            obj.put("quantity", rs.getInt("quantity"));
                            arr.put(obj);
                        }
                        out.print(successJson(arr));
                    }
                }
            } catch (Exception e) {
                out.print(errorJson("Lỗi lấy danh sách sản phẩm: " + e.getMessage()));
            }
            return;
        }

        if ("check_contract_number".equalsIgnoreCase(action)) {
            // Kiểm tra trùng lặp số hợp đồng
            String contractNumber = request.getParameter("contractNumber");
            if (contractNumber == null || contractNumber.trim().isEmpty()) {
                out.print(errorJson("Số hợp đồng không được để trống"));
                return;
            }
            
            boolean exists = contractDAO.isContractNumberExists(contractNumber.trim());
            boolean existsIncludingDeleted = contractDAO.isContractNumberExistsIncludingDeleted(contractNumber.trim());
            
            JSONObject result = new JSONObject();
            result.put("exists", exists);
            result.put("existsInTrash", existsIncludingDeleted && !exists);
            out.print(successJson(result));
            return;
        }

        if ("generate_number".equalsIgnoreCase(action)) {
            // Sinh số hợp đồng mới
            String generated = contractDAO.generateNextContractNumber();
            org.json.JSONObject result = new org.json.JSONObject();
            result.put("contractNumber", generated);
            out.print(successJson(result));
            return;
        }

        // Lấy customerId từ session để lọc hợp đồng
        Integer customerId = null;
        try {
            Object sessionCustomerId = request.getSession().getAttribute("customerId");
            if (sessionCustomerId != null && !sessionCustomerId.toString().equals("null")) {
                customerId = Integer.parseInt(sessionCustomerId.toString());
            }
        } catch (Exception e) {
            // Ignore session errors
        }
        
        List<Contract> contracts;
        if (customerId != null) {
            // Chỉ lấy hợp đồng của customer hiện tại
            contracts = contractDAO.getContractsByCustomerId(customerId);
        } else {
            // Nếu không có customerId trong session, trả về tất cả (cho admin)
            contracts = contractDAO.getAllContracts();
        }
        
        JSONArray arr = new JSONArray();
        for (Contract c : contracts) arr.put(toJson(c));
        out.print(successJson(arr));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String action = request.getParameter("action");
        PrintWriter out = response.getWriter();

        try {
            if ("add".equalsIgnoreCase(action)) {
                Contract c = parseContractFromRequest(request, false);
                
                // Nếu frontend không gửi hoặc để trống, tự sinh số hợp đồng
                if (c.getContractNumber() == null || c.getContractNumber().trim().isEmpty()) {
                    c.setContractNumber(contractDAO.generateNextContractNumber());
                }
                
                // Validate độ dài tiêu đề và điều khoản
                if (c.getTitle() != null && c.getTitle().length() > 150) {
                    out.print(errorJson("Tiêu đề vượt quá 150 ký tự"));
                    return;
                }
                if (c.getTerms() != null && c.getTerms().length() > 2000) {
                    out.print(errorJson("Điều khoản vượt quá 2000 ký tự"));
                    return;
                }

                if (c.getCustomerId() <= 0) {
                    out.print(errorJson("Vui lòng chọn khách hàng"));
                    return;
                }
                
                // Validation cho trạng thái "active" (hiệu lực)
                if ("active".equals(c.getStatus())) {
                    // Tiêu đề bắt buộc
                    if (c.getTitle() == null || c.getTitle().trim().isEmpty()) {
                        out.print(errorJson("Tiêu đề không được để trống khi trạng thái là 'Hiệu Lực'"));
                        return;
                    }
                    // Điều khoản bắt buộc
                    if (c.getTerms() == null || c.getTerms().trim().isEmpty()) {
                        out.print(errorJson("Điều khoản không được để trống khi trạng thái là 'Hiệu Lực'"));
                        return;
                    }
                    // Phải có ít nhất 1 sản phẩm
                    String productsJson = request.getParameter("products");
                    if (productsJson == null || productsJson.trim().isEmpty()) {
                        out.print(errorJson("Hợp đồng ở trạng thái 'Hiệu Lực' phải có ít nhất 1 sản phẩm"));
                        return;
                    }
                    try {
                        JSONArray products = new JSONArray(productsJson);
                        if (products.length() == 0) {
                            out.print(errorJson("Hợp đồng ở trạng thái 'Hiệu Lực' phải có ít nhất 1 sản phẩm"));
                            return;
                        }
                    } catch (Exception e) {
                        out.print(errorJson("Hợp đồng ở trạng thái 'Hiệu Lực' phải có ít nhất 1 sản phẩm"));
                        return;
                    }
                }
                
                // Kiểm tra trùng lặp số hợp đồng (bao gồm cả trong thùng rác)
                if (contractDAO.isContractNumberExistsIncludingDeleted(c.getContractNumber())) {
                    // Kiểm tra xem có phải trong thùng rác không
                    if (contractDAO.isContractNumberExists(c.getContractNumber())) {
                        out.print(errorJson("Số hợp đồng '" + c.getContractNumber() + "' đã tồn tại. Vui lòng chọn số hợp đồng khác."));
                    } else {
                        out.print(errorJson("Số hợp đồng '" + c.getContractNumber() + "' đã tồn tại trong thùng rác. Vui lòng chọn số hợp đồng khác hoặc khôi phục hợp đồng cũ."));
                    }
                    return;
                }
                
                boolean ok = contractDAO.addContract(c);
                if (ok) {
                    try {
                        // Lưu sản phẩm nếu có
                        saveContractProducts(c.getId(), request);
                        out.print(successMsg("Thêm hợp đồng và sản phẩm thành công"));
                    } catch (Exception e) {
                        // Nếu lưu sản phẩm lỗi, vẫn báo thành công vì hợp đồng đã được lưu
                        out.print(successMsg("Thêm hợp đồng thành công, nhưng có lỗi khi lưu sản phẩm: " + e.getMessage()));
                    }
                } else {
                    // Kiểm tra lại trùng lặp để đưa ra thông báo cụ thể
                    if (contractDAO.isContractNumberExistsIncludingDeleted(c.getContractNumber())) {
                        if (contractDAO.isContractNumberExists(c.getContractNumber())) {
                            out.print(errorJson("Số hợp đồng '" + c.getContractNumber() + "' đã tồn tại. Vui lòng chọn số hợp đồng khác."));
                        } else {
                            out.print(errorJson("Số hợp đồng '" + c.getContractNumber() + "' đã tồn tại trong thùng rác. Vui lòng chọn số hợp đồng khác hoặc khôi phục hợp đồng cũ."));
                        }
                    } else {
                        out.print(errorJson("Thêm hợp đồng thất bại. Vui lòng kiểm tra lại thông tin đã nhập."));
                    }
                }
            } else if ("update".equalsIgnoreCase(action)) {
                Contract c = parseContractFromRequest(request, true);
                
                // Validation cơ bản
                if (c.getContractNumber() == null || c.getContractNumber().trim().isEmpty()) {
                    out.print(errorJson("Số hợp đồng không được để trống"));
                    return;
                }

                // Validate độ dài tiêu đề và điều khoản
                if (c.getTitle() != null && c.getTitle().length() > 150) {
                    out.print(errorJson("Tiêu đề vượt quá 150 ký tự"));
                    return;
                }
                if (c.getTerms() != null && c.getTerms().length() > 2000) {
                    out.print(errorJson("Điều khoản vượt quá 2000 ký tự"));
                    return;
                }
                
                if (c.getCustomerId() <= 0) {
                    out.print(errorJson("Vui lòng chọn khách hàng"));
                    return;
                }
                
                // Validation cho trạng thái "active" (hiệu lực)
                if ("active".equals(c.getStatus())) {
                    // Tiêu đề bắt buộc
                    if (c.getTitle() == null || c.getTitle().trim().isEmpty()) {
                        out.print(errorJson("Tiêu đề không được để trống khi trạng thái là 'Hiệu Lực'"));
                        return;
                    }
                    // Điều khoản bắt buộc
                    if (c.getTerms() == null || c.getTerms().trim().isEmpty()) {
                        out.print(errorJson("Điều khoản không được để trống khi trạng thái là 'Hiệu Lực'"));
                        return;
                    }
                    // Phải có ít nhất 1 sản phẩm
                    String productsJson = request.getParameter("products");
                    if (productsJson == null || productsJson.trim().isEmpty()) {
                        out.print(errorJson("Hợp đồng ở trạng thái 'Hiệu Lực' phải có ít nhất 1 sản phẩm"));
                        return;
                    }
                    try {
                        JSONArray products = new JSONArray(productsJson);
                        if (products.length() == 0) {
                            out.print(errorJson("Hợp đồng ở trạng thái 'Hiệu Lực' phải có ít nhất 1 sản phẩm"));
                            return;
                        }
                    } catch (Exception e) {
                        out.print(errorJson("Hợp đồng ở trạng thái 'Hiệu Lực' phải có ít nhất 1 sản phẩm"));
                        return;
                    }
                }
                
                // Kiểm tra trùng lặp số hợp đồng (bao gồm cả trong thùng rác, loại trừ chính hợp đồng đang sửa)
                if (contractDAO.isContractNumberExistsIncludingDeleted(c.getContractNumber(), c.getId())) {
                    // Kiểm tra xem có phải trong thùng rác không
                    if (contractDAO.isContractNumberExists(c.getContractNumber(), c.getId())) {
                        out.print(errorJson("Số hợp đồng '" + c.getContractNumber() + "' đã tồn tại. Vui lòng chọn số hợp đồng khác."));
                    } else {
                        out.print(errorJson("Số hợp đồng '" + c.getContractNumber() + "' đã tồn tại trong thùng rác. Vui lòng chọn số hợp đồng khác hoặc khôi phục hợp đồng cũ."));
                    }
                    return;
                }
                
                boolean ok = contractDAO.updateContract(c);
                if (ok) {
                    try {
                        // Xóa sản phẩm cũ và lưu mới
                        deleteContractProducts(c.getId());
                        saveContractProducts(c.getId(), request);
                        out.print(successMsg("Cập nhật hợp đồng và sản phẩm thành công"));
                    } catch (Exception e) {
                        // Nếu lưu sản phẩm lỗi, vẫn báo thành công vì hợp đồng đã được cập nhật
                        out.print(successMsg("Cập nhật hợp đồng thành công, nhưng có lỗi khi lưu sản phẩm: " + e.getMessage()));
                    }
                } else {
                    // Kiểm tra lại trùng lặp để đưa ra thông báo cụ thể
                    if (contractDAO.isContractNumberExistsIncludingDeleted(c.getContractNumber(), c.getId())) {
                        if (contractDAO.isContractNumberExists(c.getContractNumber(), c.getId())) {
                            out.print(errorJson("Số hợp đồng '" + c.getContractNumber() + "' đã tồn tại. Vui lòng chọn số hợp đồng khác."));
                        } else {
                            out.print(errorJson("Số hợp đồng '" + c.getContractNumber() + "' đã tồn tại trong thùng rác. Vui lòng chọn số hợp đồng khác hoặc khôi phục hợp đồng cũ."));
                        }
                    } else {
                        out.print(errorJson("Cập nhật hợp đồng thất bại. Vui lòng kiểm tra lại thông tin đã nhập."));
                    }
                }
            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                // Lấy thông tin người xóa từ session
                Integer deletedBy = null;
                try {
                    Object sessionUserId = request.getSession().getAttribute("userId");
                    System.out.println("Session userId: " + sessionUserId);
                    if (sessionUserId != null && !sessionUserId.toString().equals("null")) {
                        deletedBy = Integer.parseInt(sessionUserId.toString());
                        System.out.println("Parsed deletedBy: " + deletedBy);
                    }
                } catch (Exception e) {
                    System.out.println("Error getting userId from session: " + e.getMessage());
                }
                
                boolean ok;
                if (deletedBy != null) {
                    System.out.println("Using deleteContract with deletedBy: " + deletedBy);
                    ok = contractDAO.deleteContract(id, deletedBy);
                } else {
                    System.out.println("Using deleteContract without deletedBy");
                    ok = contractDAO.deleteContract(id);
                }
                System.out.println("Delete result: " + ok);
                out.print(ok ? successMsg("Đã chuyển hợp đồng vào thùng rác") : errorJson("Xóa hợp đồng thất bại"));
            } else if ("restore".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                // Luôn khôi phục về trạng thái "draft" để đảm bảo quy trình phê duyệt
                boolean ok = contractDAO.restoreContract(id);
                out.print(ok ? successMsg("Khôi phục hợp đồng thành công. Hợp đồng đã được khôi phục về trạng thái 'Bản nháp'.") : errorJson("Khôi phục hợp đồng thất bại"));
            } else if ("permanent_delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                // Xóa sản phẩm trước
                deleteContractProducts(id);
                boolean ok = contractDAO.permanentlyDeleteContract(id);
                out.print(ok ? successMsg("Xóa vĩnh viễn hợp đồng thành công") : errorJson("Xóa vĩnh viễn hợp đồng thất bại"));
            } else {
                out.print(errorJson("Hành động không hợp lệ"));
            }
        } catch (NumberFormatException ex) {
            out.print(errorJson("Lỗi định dạng số: " + ex.getMessage()));
        } catch (IllegalArgumentException ex) {
            out.print(errorJson("Dữ liệu không hợp lệ: " + ex.getMessage()));
        } catch (Exception ex) {
            out.print(errorJson("Lỗi hệ thống: " + ex.getMessage()));
        }
    }

    private Contract parseContractFromRequest(HttpServletRequest request, boolean includeId) {
        Contract c = new Contract();
        if (includeId) {
            c.setId(Integer.parseInt(request.getParameter("id")));
        }
        c.setContractNumber(param(request, "contractNumber"));
        c.setCustomerId(Integer.parseInt(param(request, "customerId")));
        c.setContractType(param(request, "contractType"));
        c.setTitle(param(request, "title"));
        c.setStartDate(null); // Không dùng startDate nữa, để null
        c.setEndDate(parseDate(param(request, "endDate")));
        String value = param(request, "contractValue");
        c.setContractValue(value == null || value.isEmpty() ? null : new BigDecimal(value));
        c.setStatus(param(request, "status"));
        c.setTerms(param(request, "terms"));
        c.setSignedDate(parseDate(param(request, "signedDate")));
        String createdBy = param(request, "createdBy");
        c.setCreatedBy((createdBy == null || createdBy.isEmpty()) ? null : Integer.parseInt(createdBy));
        return c;
    }

    private String param(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v != null ? v.trim() : null;
    }

    private Date parseDate(String v) {
        try {
            return (v == null || v.isEmpty()) ? null : Date.valueOf(v);
        } catch (Exception e) {
            return null;
        }
    }

    private JSONObject toJson(Contract c) {
        JSONObject o = new JSONObject();
        o.put("id", c.getId());
        o.put("contractNumber", c.getContractNumber());
        o.put("customerId", c.getCustomerId());
        // Bổ sung tên và điện thoại khách hàng để hiển thị ở trang chi tiết
        o.put("customerName", c.getCustomerName());
        o.put("customerPhone", c.getCustomerPhone());
        o.put("contractType", c.getContractType());
        o.put("title", c.getTitle());
        o.put("startDate", c.getStartDate());
        o.put("endDate", c.getEndDate());
        o.put("contractValue", c.getContractValue());
        o.put("status", c.getStatus());
        o.put("terms", c.getTerms());
        o.put("signedDate", c.getSignedDate());
        o.put("createdBy", c.getCreatedBy());
        o.put("createdAt", c.getCreatedAt());
        o.put("updatedAt", c.getUpdatedAt());
        return o;
    }

    private JSONObject successJson(Object data) {
        JSONObject o = new JSONObject();
        o.put("success", true);
        o.put("data", data);
        return o;
    }

    private JSONObject successMsg(String msg) {
        JSONObject o = new JSONObject();
        o.put("success", true);
        o.put("message", msg);
        return o;
    }

    private JSONObject errorJson(String msg) {
        JSONObject o = new JSONObject();
        o.put("success", false);
        o.put("message", msg);
        return o;
    }

    private void saveContractProducts(int contractId, HttpServletRequest request) {
        try {
            String productsJson = request.getParameter("products");
            if (productsJson != null && !productsJson.isEmpty()) {
                JSONArray products = new JSONArray(productsJson);
                
                // Lấy userId từ session
                Integer userId = null;
                try {
                    Object sessionUserId = request.getSession().getAttribute("userId");
                    if (sessionUserId != null && !sessionUserId.toString().equals("null")) {
                        userId = Integer.parseInt(sessionUserId.toString());
                    }
                } catch (Exception e) {
                    // Ignore if cannot get userId from session
                }
                
                // Sử dụng thông tin từ database.properties
                java.util.Properties props = new java.util.Properties();
                java.io.InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties");
                props.load(input);
                
                String url = props.getProperty("db.url");
                String user = props.getProperty("db.username");
                String pass = props.getProperty("db.password");
                
                try (java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, pass)) {
                    boolean oldAutoCommit = conn.getAutoCommit();
                    conn.setAutoCommit(false);
                    try {
                        for (int i = 0; i < products.length(); i++) {
                            JSONObject product = products.getJSONObject(i);
                            int productId = product.getInt("productId");
                            java.math.BigDecimal qty = toBigDecimal(product.opt("quantity"));
                            if (qty == null) qty = java.math.BigDecimal.ZERO;

                            // Tính toán và trừ tồn kho đa kho (nếu có nhiều dòng inventory cho cùng product)
                            // Khóa các dòng tồn kho của product để tính an toàn
                            String sumSql = "SELECT SUM(current_stock) FROM inventory WHERE product_id = ? FOR UPDATE";
                            int totalAvailable = 0;
                            try (java.sql.PreparedStatement ps = conn.prepareStatement(sumSql)) {
                                ps.setInt(1, productId);
                                try (java.sql.ResultSet rs = ps.executeQuery()) { if (rs.next()) totalAvailable = rs.getInt(1); }
                            }
                            if (totalAvailable <= 0) {
                                throw new RuntimeException("Sản phẩm ID " + productId + " đã hết hàng");
                            }
                            if (qty.compareTo(new java.math.BigDecimal(totalAvailable)) > 0) {
                                throw new RuntimeException("Số lượng vượt quá tổng tồn kho cho sản phẩm ID " + productId);
                            }

                            // Thêm vào contract_products
                            String insertSql = "INSERT INTO contract_products (contract_id, product_id, description, quantity, unit_price, warranty_months, notes, delivery_status) VALUES (?, ?, ?, ?, ?, ?, ?, 'not_delivered')";
                            try (java.sql.PreparedStatement ps = conn.prepareStatement(insertSql)) {
                                ps.setInt(1, contractId);
                                ps.setInt(2, productId);
                                ps.setString(3, product.optString("description", null));
                                ps.setBigDecimal(4, qty);
                                ps.setBigDecimal(5, toBigDecimal(product.opt("unitPrice")));
                                if (product.has("warrantyMonths") && !product.isNull("warrantyMonths")) {
                                    ps.setInt(6, product.getInt("warrantyMonths"));
                                } else {
                                    ps.setNull(6, java.sql.Types.INTEGER);
                                }
                                ps.setString(7, product.optString("notes", null));
                                ps.executeUpdate();
                            }
                            // Trừ tồn kho phân bổ qua các kho, ghi lịch sử cho từng lần trừ
                            int remaining = qty.intValue();
                            // Lấy danh sách kho theo tồn giảm dần để trừ
                            String invRowsSql = "SELECT warehouse_location, current_stock FROM inventory WHERE product_id = ? AND current_stock > 0 ORDER BY current_stock DESC";
                            try (java.sql.PreparedStatement psInv = conn.prepareStatement(invRowsSql)) {
                                psInv.setInt(1, productId);
                                try (java.sql.ResultSet rs = psInv.executeQuery()) {
                                    while (rs.next() && remaining > 0) {
                                        String wh = rs.getString("warehouse_location");
                                        int stock = rs.getInt("current_stock");
                                        int deduct = Math.min(remaining, stock);
                                        if (deduct <= 0) continue;
                                        // Update tồn kho cho kho này
                                        String updateStockSql = "UPDATE inventory SET current_stock = current_stock - ? WHERE product_id = ? AND warehouse_location = ?";
                                        try (java.sql.PreparedStatement psUp = conn.prepareStatement(updateStockSql)) {
                                            psUp.setInt(1, deduct);
                                            psUp.setInt(2, productId);
                                            psUp.setString(3, wh);
                                            psUp.executeUpdate();
                                        }
                                        // Ghi lịch sử cho phần trừ này
                                        String insertHistorySql = "INSERT INTO stock_history (product_id, warehouse_location, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (?, ?, 'out', ?, 'contract', ?, ?, ?)";
                                        try (java.sql.PreparedStatement psH = conn.prepareStatement(insertHistorySql)) {
                                            psH.setInt(1, productId);
                                            psH.setString(2, wh);
                                            psH.setInt(3, deduct);
                                            psH.setInt(4, contractId);
                                            String notes = "Xuất kho từ hợp đồng #" + contractId;
                                            String description = product.optString("description", null);
                                            if (description != null && !description.isEmpty()) { notes += " - " + description; }
                                            psH.setString(5, notes);
                                            if (userId != null) { psH.setInt(6, userId); } else { psH.setNull(6, java.sql.Types.INTEGER); }
                                            psH.executeUpdate();
                                        }
                                        remaining -= deduct;
                                    }
                                }
                            }
                            if (remaining > 0) {
                                throw new RuntimeException("Tồn kho không đủ để xuất cho sản phẩm ID " + productId);
                            }
                        }
                        conn.commit();
                        conn.setAutoCommit(oldAutoCommit);
                    } catch (Exception ex) {
                        try { conn.rollback(); } catch (Exception ignore) {}
                        throw ex;
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error saving contract products: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }

    private java.math.BigDecimal toBigDecimal(Object value) {
        if (value == null || org.json.JSONObject.NULL.equals(value)) {
            return null;
        }
        if (value instanceof java.math.BigDecimal) {
            return (java.math.BigDecimal) value;
        }
        if (value instanceof Number) {
            // Use toString to avoid floating precision issues from double
            return new java.math.BigDecimal(value.toString());
        }
        // Fallback assume string
        String s = value.toString().trim();
        if (s.isEmpty()) return null;
        return new java.math.BigDecimal(s);
    }

    private void deleteContractProducts(int contractId) {
        try {
            // Sử dụng thông tin từ database.properties
            java.util.Properties props = new java.util.Properties();
            java.io.InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties");
            props.load(input);
            
            String url = props.getProperty("db.url");
            String user = props.getProperty("db.username");
            String pass = props.getProperty("db.password");
            
            try (java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, pass)) {
                String sql = "DELETE FROM contract_products WHERE contract_id = ?";
                try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, contractId);
                    ps.executeUpdate();
                }
            }
        } catch (Exception e) {
            System.err.println("Error deleting contract products: " + e.getMessage());
        }
    }
}


