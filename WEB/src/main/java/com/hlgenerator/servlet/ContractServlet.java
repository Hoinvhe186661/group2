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
    private ContractDAO contractDAO; // DAO để thao tác với database

    @Override
    public void init() throws ServletException {
        super.init();
        contractDAO = new ContractDAO(); // Khởi tạo DAO khi servlet được load
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String action = request.getParameter("action"); // Lấy action từ request
        PrintWriter out = response.getWriter();

        // Lấy thông tin hợp đồng theo ID
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

        // Lấy danh sách hợp đồng đã xóa (thùng rác) với phân trang, tìm kiếm, sắp xếp
        if ("deleted".equalsIgnoreCase(action)) {
            String pageParam = request.getParameter("page");
            String pageSizeParam = request.getParameter("pageSize");
            String search = request.getParameter("search");
            String sortBy = request.getParameter("sortBy");
            String sortDir = request.getParameter("sortDir");
            
            System.out.println("Getting deleted contracts - page: " + pageParam + ", pageSize: " + pageSizeParam + ", search: " + search);
            
            // Parse và validate tham số phân trang
            int page = 1;
            int pageSize = 10;
            try { if (pageParam != null) page = Integer.parseInt(pageParam); } catch (Exception ignored) {}
            try { if (pageSizeParam != null) pageSize = Integer.parseInt(pageSizeParam); } catch (Exception ignored) {}
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 10;
            
            // Lấy danh sách hợp đồng đã xóa từ database
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

        // Lấy danh sách khách hàng để đổ vào dropdown
        if ("customers".equalsIgnoreCase(action)) {
            com.hlgenerator.dao.CustomerDAO customerDAO = new com.hlgenerator.dao.CustomerDAO();
            java.util.List<com.hlgenerator.model.Customer> customers = customerDAO.getAllCustomers();
            JSONArray arr = new JSONArray();
            // Chuyển đổi danh sách khách hàng sang JSON
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

        // Lấy danh sách sản phẩm để đổ vào dropdown (kèm thông tin tồn kho)
        if ("products".equalsIgnoreCase(action)) {
            try {
                // Sử dụng thông tin từ database.properties
                java.util.Properties props = new java.util.Properties();
                java.io.InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties");
                props.load(input);
                
                String url = props.getProperty("db.url");
                String user = props.getProperty("db.username");
                String pass = props.getProperty("db.password");
                
                try (java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, pass)) {
                    // Tính tồn kho khả dụng = current_stock - reserved_quantity (cho phép số âm)
                    String sql = "SELECT p.id, p.product_code, p.product_name, p.description, p.unit_price, p.warranty_months, " +
                                 "COALESCE(SUM(i.current_stock - i.reserved_quantity), 0) AS quantity " +
                                 "FROM products p " +
                                 "LEFT JOIN inventory i ON p.id = i.product_id " +
                                 "GROUP BY p.id, p.product_code, p.product_name, p.description, p.unit_price, p.warranty_months " +
                                 "ORDER BY p.product_name";
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
                            // Available stock có thể âm (cho phép số âm)
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

        // Kiểm tra số hợp đồng có trùng không (dùng cho validation real-time)
        if ("check_contract_number".equalsIgnoreCase(action)) {
            String contractNumber = request.getParameter("contractNumber");
            if (contractNumber == null || contractNumber.trim().isEmpty()) {
                out.print(errorJson("Số hợp đồng không được để trống"));
                return;
            }
            
            // Kiểm tra trùng trong danh sách hợp đồng đang dùng và trong thùng rác
            boolean exists = contractDAO.isContractNumberExists(contractNumber.trim());
            boolean existsIncludingDeleted = contractDAO.isContractNumberExistsIncludingDeleted(contractNumber.trim());
            
            JSONObject result = new JSONObject();
            result.put("exists", exists);
            result.put("existsInTrash", existsIncludingDeleted && !exists); // Có trong thùng rác nhưng không trong danh sách chính
            out.print(successJson(result));
            return;
        }

        // Sinh số hợp đồng tự động (format: HD-YYYYMMDD-XXXX)
        if ("generate_number".equalsIgnoreCase(action)) {
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
            // Thêm hợp đồng mới
            if ("add".equalsIgnoreCase(action)) {
                Contract c = parseContractFromRequest(request, false); // Parse dữ liệu từ request
                
                // Nếu không có số hợp đồng thì tự động sinh
                if (c.getContractNumber() == null || c.getContractNumber().trim().isEmpty()) {
                    c.setContractNumber(contractDAO.generateNextContractNumber());
                }
                
                // Kiểm tra độ dài tiêu đề và điều khoản
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
                
                // Nếu hợp đồng ở trạng thái "active" thì phải có đầy đủ thông tin
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
                
                // Kiểm tra số hợp đồng có trùng không (kể cả trong thùng rác)
                if (contractDAO.isContractNumberExistsIncludingDeleted(c.getContractNumber())) {
                    // Phân biệt trùng trong danh sách chính hay trong thùng rác
                    if (contractDAO.isContractNumberExists(c.getContractNumber())) {
                        out.print(errorJson("Số hợp đồng '" + c.getContractNumber() + "' đã tồn tại. Vui lòng chọn số hợp đồng khác."));
                    } else {
                        out.print(errorJson("Số hợp đồng '" + c.getContractNumber() + "' đã tồn tại trong thùng rác. Vui lòng chọn số hợp đồng khác hoặc khôi phục hợp đồng cũ."));
                    }
                    return;
                }
                
                // Lưu hợp đồng vào database
                boolean ok = contractDAO.addContract(c);
                if (ok) {
                    try {
                        // Lưu danh sách sản phẩm vào hợp đồng (và giữ chỗ tồn kho nếu status = active)
                        saveContractProducts(c.getId(), request);
                        out.print(successMsg("Thêm hợp đồng và sản phẩm thành công"));
                    } catch (Exception e) {
                        // Hợp đồng đã lưu nhưng lỗi khi lưu sản phẩm
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
            // Cập nhật hợp đồng
            } else if ("update".equalsIgnoreCase(action)) {
                Contract c = parseContractFromRequest(request, true); // Parse kèm ID
                
                // Kiểm tra số hợp đồng không được trống
                if (c.getContractNumber() == null || c.getContractNumber().trim().isEmpty()) {
                    out.print(errorJson("Số hợp đồng không được để trống"));
                    return;
                }

                // Kiểm tra độ dài tiêu đề và điều khoản
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
                
                // Nếu hợp đồng ở trạng thái "active" thì phải có đầy đủ thông tin
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
                
                // Lấy trạng thái cũ để xử lý giữ chỗ tồn kho khi thay đổi trạng thái
                Contract oldContract = contractDAO.getContractById(c.getId());
                String oldStatus = oldContract != null ? oldContract.getStatus() : null;
                String newStatus = c.getStatus();
                
                // Cập nhật hợp đồng trong database
                boolean ok = contractDAO.updateContract(c);
                if (ok) {
                    try {
                        String productsJson = request.getParameter("products");
                        
                        // Xử lý sản phẩm và giữ chỗ tồn kho
                        if (productsJson != null && !productsJson.trim().isEmpty()) {
                            // Có sản phẩm mới: xóa sản phẩm cũ (giải phóng tồn kho) và lưu mới
                            deleteContractProducts(c.getId());
                            saveContractProducts(c.getId(), request); // Tự động giữ chỗ nếu status = active
                        } else {
                            // Không có sản phẩm mới: chỉ xử lý giữ chỗ khi trạng thái thay đổi
                            if (oldStatus != null && !oldStatus.equals(newStatus)) {
                                if ("draft".equals(oldStatus) && "active".equals(newStatus)) {
                                    // Chuyển từ nháp sang hiệu lực: giữ chỗ sản phẩm hiện có
                                    reserveContractProducts(c.getId());
                                } else if ("active".equals(oldStatus) && "draft".equals(newStatus)) {
                                    // Chuyển từ hiệu lực sang nháp: giải phóng số lượng đã giữ chỗ
                                    releaseContractReservedQuantity(c.getId());
                                }
                            }
                        }
                        
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
            // Xóa hợp đồng (chuyển vào thùng rác - soft delete)
            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                // Giải phóng số lượng đã giữ chỗ khi xóa vào thùng rác
                releaseContractReservedQuantity(id);
                // Lấy ID người xóa từ session
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
                
                // Thực hiện soft delete (chỉ đổi status = 'deleted', không xóa thật)
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
            // Khôi phục hợp đồng từ thùng rác
            } else if ("restore".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                // Khôi phục về trạng thái "draft" (không giữ chỗ tồn kho)
                boolean ok = contractDAO.restoreContract(id);
                if (ok) {
                    out.print(successMsg("Khôi phục hợp đồng thành công. Hợp đồng đã được khôi phục về trạng thái 'Bản nháp'."));
                } else {
                    out.print(errorJson("Khôi phục hợp đồng thất bại"));
                }
            // Xóa vĩnh viễn hợp đồng (hard delete)
            } else if ("permanent_delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                // Xóa sản phẩm trước (giải phóng tồn kho)
                deleteContractProducts(id);
                // Xóa hợp đồng khỏi database
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

    // Parse dữ liệu từ request thành đối tượng Contract
    private Contract parseContractFromRequest(HttpServletRequest request, boolean includeId) {
        Contract c = new Contract();
        if (includeId) {
            c.setId(Integer.parseInt(request.getParameter("id"))); // Chỉ set ID khi update
        }
        c.setContractNumber(param(request, "contractNumber"));
        c.setCustomerId(Integer.parseInt(param(request, "customerId")));
        c.setContractType(param(request, "contractType"));
        c.setTitle(param(request, "title"));
        c.setStartDate(parseDate(param(request, "startDate")));
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

    // Lấy tham số từ request và trim
    private String param(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v != null ? v.trim() : null;
    }

    // Parse chuỗi ngày thành Date
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
        o.put("deletedAt", c.getDeletedAt());
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

    /**
     * Lưu sản phẩm vào hợp đồng và giữ chỗ tồn kho
     * Chỉ giữ chỗ khi hợp đồng ở trạng thái "active" (hiệu lực)
     * Hợp đồng ở trạng thái "draft" (nháp) không giữ chỗ sản phẩm
     */
    private void saveContractProducts(int contractId, HttpServletRequest request) {
        try {
            String productsJson = request.getParameter("products");
            if (productsJson != null && !productsJson.isEmpty()) {
                JSONArray products = new JSONArray(productsJson);
                
                // Load cấu hình database
                java.util.Properties props = new java.util.Properties();
                java.io.InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties");
                if (input == null) {
                    throw new RuntimeException("Cannot load database.properties file");
                }
                try {
                    props.load(input);
                } finally {
                    input.close();
                }
                
                String url = props.getProperty("db.url");
                String user = props.getProperty("db.username");
                String pass = props.getProperty("db.password");
                
                try (java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, pass)) {
                    // Lấy trạng thái hợp đồng để quyết định có giữ chỗ tồn kho hay không
                    String contractStatus = null;
                    String statusSql = "SELECT status FROM contracts WHERE id = ?";
                    try (java.sql.PreparedStatement psStatus = conn.prepareStatement(statusSql)) {
                        psStatus.setInt(1, contractId);
                        try (java.sql.ResultSet rsStatus = psStatus.executeQuery()) {
                            if (rsStatus.next()) {
                                contractStatus = rsStatus.getString("status");
                            }
                        }
                    }
                    
                    // Chỉ giữ chỗ tồn kho nếu hợp đồng ở trạng thái "active" (hiệu lực)
                    boolean shouldReserve = "active".equals(contractStatus);
                    
                    boolean oldAutoCommit = conn.getAutoCommit();
                    conn.setAutoCommit(false);
                    try {
                        for (int i = 0; i < products.length(); i++) {
                            JSONObject product = products.getJSONObject(i);
                            int productId = product.getInt("productId");
                            java.math.BigDecimal qty = toBigDecimal(product.opt("quantity"));
                            if (qty == null) qty = java.math.BigDecimal.ZERO;

                            // Kiểm tra tồn kho (chỉ để cảnh báo, không chặn)
                            String sumSql = "SELECT SUM(current_stock) FROM inventory WHERE product_id = ? FOR UPDATE";
                            int totalAvailable = 0;
                            try (java.sql.PreparedStatement ps = conn.prepareStatement(sumSql)) {
                                ps.setInt(1, productId);
                                try (java.sql.ResultSet rs = ps.executeQuery()) { if (rs.next()) totalAvailable = rs.getInt(1); }
                            }
                            // Cảnh báo nếu tồn kho không đủ (nhưng vẫn cho phép tạo hợp đồng)
                            if (totalAvailable <= 0) {
                                System.out.println("Cảnh báo: Sản phẩm ID " + productId + " đã hết hàng trong kho. Hợp đồng vẫn được tạo.");
                            }
                            if (qty.compareTo(new java.math.BigDecimal(totalAvailable)) > 0) {
                                System.out.println("Cảnh báo: Số lượng yêu cầu (" + qty + ") vượt quá tổng tồn kho (" + totalAvailable + ") cho sản phẩm ID " + productId + ". Hợp đồng vẫn được tạo.");
                            }

                            // Lưu sản phẩm vào bảng contract_products
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
                            
                            // Chỉ giữ chỗ tồn kho nếu hợp đồng ở trạng thái "active"
                            if (shouldReserve) {
                                // Giữ chỗ tồn kho (tăng reserved_quantity) thay vì trừ current_stock
                                // Chỉ khi xuất kho thực sự mới trừ current_stock
                                int remaining = qty.intValue();
                                int totalReserved = 0;
                                // Lấy danh sách kho theo tồn khả dụng giảm dần để giữ chỗ
                                String invRowsSql = "SELECT id, warehouse_location, current_stock, reserved_quantity, (current_stock - reserved_quantity) as available FROM inventory WHERE product_id = ? ORDER BY (current_stock - reserved_quantity) DESC";
                                try (java.sql.PreparedStatement psInv = conn.prepareStatement(invRowsSql)) {
                                    psInv.setInt(1, productId);
                                    try (java.sql.ResultSet rs = psInv.executeQuery()) {
                                        while (rs.next() && remaining > 0) {
                                            int invId = rs.getInt("id");
                                            int stock = rs.getInt("current_stock");
                                            int reserved = rs.getInt("reserved_quantity");
                                            
                                            // Giữ chỗ tất cả current_stock có sẵn trước
                                            int stockAvailable = stock - reserved; // Số lượng stock chưa được giữ chỗ
                                            
                                            // Bước 1: Giữ chỗ số lượng stock có sẵn (nếu có)
                                            int toReserveFromStock = Math.min(remaining, Math.max(stockAvailable, 0));
                                            
                                            // Bước 2: Nếu còn thiếu, giữ chỗ thêm phần thiếu để đánh dấu
                                            int shortage = remaining - toReserveFromStock;
                                            
                                            // Chỉ giữ chỗ phần thiếu nếu thực sự thiếu (shortage > 0)
                                            // Tổng giữ chỗ = stock có sẵn + phần thiếu
                                            int toReserve = toReserveFromStock;
                                            if (shortage > 0) {
                                                toReserve += shortage; // Giữ chỗ thêm phần thiếu
                                            }
                                            
                                            if (toReserve <= 0) continue;
                                            
                                            // Tăng reserved_quantity thay vì trừ current_stock
                                            String updateReservedSql = "UPDATE inventory SET reserved_quantity = reserved_quantity + ? WHERE id = ?";
                                            try (java.sql.PreparedStatement psUp = conn.prepareStatement(updateReservedSql)) {
                                                psUp.setInt(1, toReserve);
                                                psUp.setInt(2, invId);
                                                psUp.executeUpdate();
                                            }
                                            
                                            remaining -= toReserve;
                                            totalReserved += toReserve;
                                        }
                                    }
                                }
                                // Cảnh báo nếu tồn kho không đủ, nhưng vẫn cho phép tạo hợp đồng
                                if (remaining > 0) {
                                    System.out.println("Cảnh báo: Tồn kho không đủ để giữ chỗ cho sản phẩm ID " + productId + 
                                        ". Yêu cầu: " + qty.intValue() + ", đã giữ chỗ: " + totalReserved + ", còn thiếu: " + remaining);
                                }
                            } else {
                                System.out.println("Hợp đồng ID " + contractId + " ở trạng thái '" + contractStatus + "' - không giữ chỗ sản phẩm. Chỉ giữ chỗ khi hợp đồng ở trạng thái 'active'.");
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
            e.printStackTrace(); // In đầy đủ stack trace để debug
            throw new RuntimeException("Error saving contract products: " + e.getMessage(), e);
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

    /**
     * Giữ chỗ sản phẩm khi hợp đồng chuyển từ trạng thái "draft" sang "active"
     * Lấy danh sách sản phẩm hiện có trong hợp đồng và giữ chỗ chúng (tăng reserved_quantity)
     */
    private void reserveContractProducts(int contractId) {
        try {
            // Sử dụng thông tin từ database.properties
            java.util.Properties props = new java.util.Properties();
            java.io.InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties");
            if (input == null) {
                throw new RuntimeException("Cannot load database.properties file");
            }
            try {
                props.load(input);
            } finally {
                input.close();
            }
            
            String url = props.getProperty("db.url");
            String user = props.getProperty("db.username");
            String pass = props.getProperty("db.password");
            
            try (java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, pass)) {
                boolean oldAutoCommit = conn.getAutoCommit();
                conn.setAutoCommit(false);
                try {
                    // Lấy danh sách sản phẩm hiện có trong hợp đồng
                    String productsSql = "SELECT product_id, quantity FROM contract_products WHERE contract_id = ?";
                    try (java.sql.PreparedStatement psProducts = conn.prepareStatement(productsSql)) {
                        psProducts.setInt(1, contractId);
                        try (java.sql.ResultSet rs = psProducts.executeQuery()) {
                            while (rs.next()) {
                                int productId = rs.getInt("product_id");
                                int quantity = rs.getInt("quantity");
                                
                                // Giữ chỗ tồn kho cho sản phẩm này
                                int remaining = quantity;
                                int totalReserved = 0;
                                
                                // Lấy danh sách kho theo tồn khả dụng giảm dần để giữ chỗ
                                String invRowsSql = "SELECT id, warehouse_location, current_stock, reserved_quantity, (current_stock - reserved_quantity) as available FROM inventory WHERE product_id = ? ORDER BY (current_stock - reserved_quantity) DESC";
                                try (java.sql.PreparedStatement psInv = conn.prepareStatement(invRowsSql)) {
                                    psInv.setInt(1, productId);
                                    try (java.sql.ResultSet rsInv = psInv.executeQuery()) {
                                        while (rsInv.next() && remaining > 0) {
                                            int invId = rsInv.getInt("id");
                                            int stock = rsInv.getInt("current_stock");
                                            int reserved = rsInv.getInt("reserved_quantity");
                                            
                                            // Giữ chỗ tất cả current_stock có sẵn trước
                                            int stockAvailable = stock - reserved; // Số lượng stock chưa được giữ chỗ
                                            
                                            // Bước 1: Giữ chỗ số lượng stock có sẵn (nếu có)
                                            int toReserveFromStock = Math.min(remaining, Math.max(stockAvailable, 0));
                                            
                                            // Bước 2: Nếu còn thiếu, giữ chỗ thêm phần thiếu để đánh dấu
                                            int shortage = remaining - toReserveFromStock;
                                            
                                            // Chỉ giữ chỗ phần thiếu nếu thực sự thiếu (shortage > 0)
                                            // Tổng giữ chỗ = stock có sẵn + phần thiếu
                                            int toReserve = toReserveFromStock;
                                            if (shortage > 0) {
                                                toReserve += shortage; // Giữ chỗ thêm phần thiếu
                                            }
                                            
                                            if (toReserve <= 0) continue;
                                            
                                            // Tăng reserved_quantity thay vì trừ current_stock
                                            String updateReservedSql = "UPDATE inventory SET reserved_quantity = reserved_quantity + ? WHERE id = ?";
                                            try (java.sql.PreparedStatement psUp = conn.prepareStatement(updateReservedSql)) {
                                                psUp.setInt(1, toReserve);
                                                psUp.setInt(2, invId);
                                                psUp.executeUpdate();
                                            }
                                            
                                            remaining -= toReserve;
                                            totalReserved += toReserve;
                                        }
                                    }
                                }
                                
                                // Cảnh báo nếu tồn kho không đủ, nhưng vẫn cho phép giữ chỗ
                                if (remaining > 0) {
                                    System.out.println("Cảnh báo: Tồn kho không đủ để giữ chỗ cho sản phẩm ID " + productId + 
                                        ". Yêu cầu: " + quantity + ", đã giữ chỗ: " + totalReserved + ", còn thiếu: " + remaining);
                                } else {
                                    System.out.println("Đã giữ chỗ thành công " + totalReserved + " sản phẩm ID " + productId + " cho hợp đồng ID " + contractId);
                                }
                            }
                        }
                    }
                    
                    conn.commit();
                    conn.setAutoCommit(oldAutoCommit);
                } catch (Exception ex) {
                    try { conn.rollback(); } catch (Exception ignore) {}
                    throw ex;
                }
            }
        } catch (Exception e) {
            System.err.println("Error reserving contract products: " + e.getMessage());
            e.printStackTrace();
            // Không throw exception để không chặn quá trình cập nhật hợp đồng
        }
    }

    // Giải phóng số lượng đã giữ chỗ (giảm reserved_quantity) khi hợp đồng bị xóa hoặc chuyển từ active sang draft
    private void releaseContractReservedQuantity(int contractId) {
        // Vẫn giữ contract_products trong database, chỉ giải phóng tồn kho
        try {
            // Sử dụng thông tin từ database.properties
            java.util.Properties props = new java.util.Properties();
            java.io.InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties");
            if (input == null) {
                throw new RuntimeException("Cannot load database.properties file");
            }
            try {
                props.load(input);
            } finally {
                input.close();
            }
            
            String url = props.getProperty("db.url");
            String user = props.getProperty("db.username");
            String pass = props.getProperty("db.password");
            
            try (java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, pass)) {
                boolean oldAutoCommit = conn.getAutoCommit();
                conn.setAutoCommit(false);
                try {
                    // Hoàn lại reserved_quantity dựa trên số lượng trong contract_products
                    // Lấy tất cả sản phẩm trong hợp đồng để giảm reserved_quantity
                    String productsSql = "SELECT product_id, quantity FROM contract_products WHERE contract_id = ?";
                    try (java.sql.PreparedStatement psProducts = conn.prepareStatement(productsSql)) {
                        psProducts.setInt(1, contractId);
                        try (java.sql.ResultSet rs = psProducts.executeQuery()) {
                            while (rs.next()) {
                                int productId = rs.getInt("product_id");
                                int quantity = rs.getInt("quantity");
                                
                                // Giảm reserved_quantity (hoàn lại số lượng đã giữ chỗ)
                                // Phân bổ giảm reserved qua các kho có reserved > 0
                                String releaseSql = "SELECT id, warehouse_location, reserved_quantity FROM inventory " +
                                                   "WHERE product_id = ? AND reserved_quantity > 0 ORDER BY reserved_quantity DESC";
                                try (java.sql.PreparedStatement psRelease = conn.prepareStatement(releaseSql)) {
                                    psRelease.setInt(1, productId);
                                    try (java.sql.ResultSet rsRelease = psRelease.executeQuery()) {
                                        int remaining = quantity;
                                        while (rsRelease.next() && remaining > 0) {
                                            int invId = rsRelease.getInt("id");
                                            int reserved = rsRelease.getInt("reserved_quantity");
                                            int toRelease = Math.min(remaining, reserved);
                                            
                                            if (toRelease <= 0) continue;
                                            
                                            // Giảm reserved_quantity
                                            String updateReservedSql = "UPDATE inventory SET reserved_quantity = reserved_quantity - ? WHERE id = ? AND reserved_quantity >= ?";
                                            try (java.sql.PreparedStatement psUp = conn.prepareStatement(updateReservedSql)) {
                                                psUp.setInt(1, toRelease);
                                                psUp.setInt(2, invId);
                                                psUp.setInt(3, toRelease);
                                                psUp.executeUpdate();
                                            }
                                            
                                            remaining -= toRelease;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    conn.commit();
                    conn.setAutoCommit(oldAutoCommit);
                } catch (Exception ex) {
                    try { conn.rollback(); } catch (Exception ignore) {}
                    throw ex;
                }
            }
        } catch (Exception e) {
            System.err.println("Error releasing contract reserved quantity: " + e.getMessage());
            e.printStackTrace();
            // Không throw exception để không chặn quá trình soft delete
        }
    }

    // Xóa sản phẩm khỏi hợp đồng và giải phóng tồn kho đã giữ chỗ
    private void deleteContractProducts(int contractId) {
        try {
            // Load cấu hình database
            java.util.Properties props = new java.util.Properties();
            java.io.InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties");
            if (input == null) {
                throw new RuntimeException("Cannot load database.properties file");
            }
            try {
                props.load(input);
            } finally {
                input.close();
            }
            
            String url = props.getProperty("db.url");
            String user = props.getProperty("db.username");
            String pass = props.getProperty("db.password");
            
            try (java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, pass)) {
                boolean oldAutoCommit = conn.getAutoCommit();
                conn.setAutoCommit(false);
                try {
                    // Lấy danh sách sản phẩm trong hợp đồng để giải phóng tồn kho
                    String productsSql = "SELECT product_id, quantity FROM contract_products WHERE contract_id = ?";
                    try (java.sql.PreparedStatement psProducts = conn.prepareStatement(productsSql)) {
                        psProducts.setInt(1, contractId);
                        try (java.sql.ResultSet rs = psProducts.executeQuery()) {
                            while (rs.next()) {
                                int productId = rs.getInt("product_id");
                                int quantity = rs.getInt("quantity");
                                
                                // Giảm reserved_quantity (hoàn lại số lượng đã giữ chỗ)
                                // Phân bổ giảm reserved qua các kho có reserved > 0
                                String releaseSql = "SELECT id, warehouse_location, reserved_quantity FROM inventory " +
                                                   "WHERE product_id = ? AND reserved_quantity > 0 ORDER BY reserved_quantity DESC";
                                try (java.sql.PreparedStatement psRelease = conn.prepareStatement(releaseSql)) {
                                    psRelease.setInt(1, productId);
                                    try (java.sql.ResultSet rsRelease = psRelease.executeQuery()) {
                                        int remaining = quantity;
                                        while (rsRelease.next() && remaining > 0) {
                                            int invId = rsRelease.getInt("id");
                                            int reserved = rsRelease.getInt("reserved_quantity");
                                            int toRelease = Math.min(remaining, reserved);
                                            
                                            if (toRelease <= 0) continue;
                                            
                                            // Giảm reserved_quantity
                                            String updateReservedSql = "UPDATE inventory SET reserved_quantity = reserved_quantity - ? WHERE id = ? AND reserved_quantity >= ?";
                                            try (java.sql.PreparedStatement psUp = conn.prepareStatement(updateReservedSql)) {
                                                psUp.setInt(1, toRelease);
                                                psUp.setInt(2, invId);
                                                psUp.setInt(3, toRelease);
                                                psUp.executeUpdate();
                                            }
                                            
                                            remaining -= toRelease;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Xóa sản phẩm khỏi hợp đồng
                    String sql = "DELETE FROM contract_products WHERE contract_id = ?";
                    try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, contractId);
                        ps.executeUpdate();
                    }
                    
                    conn.commit();
                    conn.setAutoCommit(oldAutoCommit);
                } catch (Exception ex) {
                    try { conn.rollback(); } catch (Exception ignore) {}
                    throw ex;
                }
            }
        } catch (Exception e) {
            System.err.println("Error deleting contract products: " + e.getMessage());
            e.printStackTrace(); // In đầy đủ stack trace để debug
        }
    }
}


