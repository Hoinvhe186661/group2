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
                boolean ok = contractDAO.addContract(c);
                if (ok) {
                    // Lưu sản phẩm nếu có
                    saveContractProducts(c.getId(), request);
                    out.print(successMsg("Thêm hợp đồng và sản phẩm thành công"));
                } else {
                    out.print(errorJson("Thêm hợp đồng thất bại"));
                }
            } else if ("update".equalsIgnoreCase(action)) {
                Contract c = parseContractFromRequest(request, true);
                boolean ok = contractDAO.updateContract(c);
                if (ok) {
                    // Xóa sản phẩm cũ và lưu mới
                    deleteContractProducts(c.getId());
                    saveContractProducts(c.getId(), request);
                    out.print(successMsg("Cập nhật hợp đồng và sản phẩm thành công"));
                } else {
                    out.print(errorJson("Cập nhật hợp đồng thất bại"));
                }
            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                // Xóa sản phẩm trước
                deleteContractProducts(id);
                boolean ok = contractDAO.deleteContract(id);
                out.print(ok ? successMsg("Xóa hợp đồng thành công") : errorJson("Xóa hợp đồng thất bại"));
            } else {
                out.print(errorJson("Hành động không hợp lệ"));
            }
        } catch (Exception ex) {
            out.print(errorJson("Lỗi: " + ex.getMessage()));
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

                            // Kiểm tra tồn kho hiện tại
                            int currentStock = 0;
                            String stockSql = "SELECT COALESCE(current_stock, 0) FROM inventory WHERE product_id = ? FOR UPDATE";
                            try (java.sql.PreparedStatement ps = conn.prepareStatement(stockSql)) {
                                ps.setInt(1, productId);
                                try (java.sql.ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) {
                                        currentStock = rs.getInt(1);
                                    } else {
                                        currentStock = 0;
                                    }
                                }
                            }

                            if (currentStock <= 0) {
                                throw new RuntimeException("Sản phẩm ID " + productId + " đã hết hàng");
                            }
                            if (qty.compareTo(new java.math.BigDecimal(currentStock)) > 0) {
                                throw new RuntimeException("Số lượng vượt quá tồn kho cho sản phẩm ID " + productId);
                            }

                            // Thêm vào contract_products
                            String insertSql = "INSERT INTO contract_products (contract_id, product_id, description, quantity, unit_price, warranty_months, notes) VALUES (?, ?, ?, ?, ?, ?, ?)";
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

                            // Trừ tồn kho
                            String updateStockSql = "UPDATE inventory SET current_stock = current_stock - ? WHERE product_id = ?";
                            try (java.sql.PreparedStatement ps = conn.prepareStatement(updateStockSql)) {
                                ps.setBigDecimal(1, qty);
                                ps.setInt(2, productId);
                                ps.executeUpdate();
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


