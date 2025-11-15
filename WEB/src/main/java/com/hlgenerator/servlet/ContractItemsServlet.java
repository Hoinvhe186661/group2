package com.hlgenerator.servlet;

import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/api/contract-items")
public class ContractItemsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Lấy danh sách sản phẩm trong hợp đồng
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        PrintWriter out = response.getWriter();

        String contractIdStr = request.getParameter("contractId");
        if (contractIdStr == null || contractIdStr.isEmpty()) {
            out.print(errorJson("Thiếu tham số contractId"));
            return;
        }

        try {
            int contractId = Integer.parseInt(contractIdStr);

            java.util.Properties props = new java.util.Properties();
            java.io.InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties");
            if (input == null) {
                out.print(errorJson("Không tìm thấy cấu hình database.properties"));
                return;
            }
            props.load(input);

            String url = props.getProperty("db.url");
            String user = props.getProperty("db.username");
            String pass = props.getProperty("db.password");

            // Lấy danh sách sản phẩm trong hợp đồng (kèm thông tin sản phẩm và trạng thái bàn giao)
            String sql = "SELECT cp.product_id, cp.description, cp.quantity, cp.unit_price, cp.warranty_months, cp.notes, " +
                         "COALESCE(cp.delivery_status, 'not_delivered') as delivery_status, " +
                         "p.product_name, p.warranty_months as product_warranty_months " +
                         "FROM contract_products cp " +
                         "LEFT JOIN products p ON cp.product_id = p.id " +
                         "WHERE cp.contract_id = ? ORDER BY cp.id";
            try (java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, pass);
                 java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, contractId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    JSONArray arr = new JSONArray();
                    while (rs.next()) {
                        JSONObject obj = new JSONObject();
                        obj.put("productId", rs.getInt("product_id"));
                        String productName = rs.getString("product_name");
                        obj.put("productName", rs.wasNull() ? JSONObject.NULL : productName);
                        String desc = rs.getString("description");
                        obj.put("description", rs.wasNull() ? JSONObject.NULL : desc);
                        obj.put("quantity", rs.getBigDecimal("quantity"));
                        obj.put("unitPrice", rs.getBigDecimal("unit_price"));
                        
                        // Lấy thời gian bảo hành: ưu tiên từ contract_products, nếu không có thì lấy từ products, mặc định 12 tháng
                        int warrantyMonths = rs.getInt("warranty_months");
                        if (rs.wasNull()) {
                            warrantyMonths = rs.getInt("product_warranty_months");
                            if (rs.wasNull()) {
                                warrantyMonths = 12; // Mặc định 12 tháng
                            }
                        }
                        obj.put("warrantyMonths", warrantyMonths);
                        
                        // Tìm ngày xuất kho từ stock_history để tính bảo hành
                        int productId = rs.getInt("product_id");
                        String deliveryStatus = rs.getString("delivery_status");
                        java.sql.Timestamp stockOutDate = null;
                        String stockOutDateStr = null;
                        try {
                            // Tìm ngày xuất kho với reference_type = 'contract' trước
                            String stockOutSql = "SELECT MIN(created_at) as stock_out_date " +
                                               "FROM stock_history " +
                                               "WHERE product_id = ? AND movement_type = 'out' " +
                                               "AND reference_type = 'contract' AND reference_id = ? " +
                                               "ORDER BY created_at ASC LIMIT 1";
                            try (java.sql.PreparedStatement psStock = conn.prepareStatement(stockOutSql)) {
                                psStock.setInt(1, productId);
                                psStock.setInt(2, contractId);
                                try (java.sql.ResultSet rsStock = psStock.executeQuery()) {
                                    if (rsStock.next()) {
                                        stockOutDate = rsStock.getTimestamp("stock_out_date");
                                        if (stockOutDate != null) {
                                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                                            stockOutDateStr = sdf.format(stockOutDate);
                                        }
                                    }
                                }
                            }
                            
                            // Nếu không tìm thấy và sản phẩm đã bàn giao, thử tìm với điều kiện linh hoạt hơn
                            if (stockOutDate == null && "delivered".equals(deliveryStatus)) {
                                // Thử tìm với reference_id khớp, bất kể reference_type
                                String flexibleSql = "SELECT MIN(created_at) as stock_out_date " +
                                                   "FROM stock_history " +
                                                   "WHERE product_id = ? AND movement_type = 'out' " +
                                                   "AND reference_id = ? " +
                                                   "ORDER BY created_at ASC LIMIT 1";
                                try (java.sql.PreparedStatement psStock2 = conn.prepareStatement(flexibleSql)) {
                                    psStock2.setInt(1, productId);
                                    psStock2.setInt(2, contractId);
                                    try (java.sql.ResultSet rsStock2 = psStock2.executeQuery()) {
                                        if (rsStock2.next()) {
                                            stockOutDate = rsStock2.getTimestamp("stock_out_date");
                                            if (stockOutDate != null) {
                                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                                                stockOutDateStr = sdf.format(stockOutDate);
                                            }
                                        }
                                    }
                                }
                                
                                // Nếu vẫn không tìm thấy, tìm bất kỳ bản ghi xuất kho nào của sản phẩm này
                                // (có thể sản phẩm đã được xuất kho nhưng không có reference_id)
                                if (stockOutDate == null) {
                                    String anyOutSql = "SELECT MIN(created_at) as stock_out_date " +
                                                      "FROM stock_history " +
                                                      "WHERE product_id = ? AND movement_type = 'out' " +
                                                      "ORDER BY created_at ASC LIMIT 1";
                                    try (java.sql.PreparedStatement psStock3 = conn.prepareStatement(anyOutSql)) {
                                        psStock3.setInt(1, productId);
                                        try (java.sql.ResultSet rsStock3 = psStock3.executeQuery()) {
                                            if (rsStock3.next()) {
                                                stockOutDate = rsStock3.getTimestamp("stock_out_date");
                                                if (stockOutDate != null) {
                                                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                                                    stockOutDateStr = sdf.format(stockOutDate);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } catch (Exception e) {
                            // Nếu có lỗi, bỏ qua
                            System.out.println("Error getting stock out date: " + e.getMessage());
                        }
                        
                        obj.put("stockOutDate", stockOutDateStr != null ? stockOutDateStr : JSONObject.NULL);
                        
                        // Tính toán thông tin bảo hành: ngày hết hạn = ngày xuất kho + thời gian bảo hành
                        if (stockOutDate != null && warrantyMonths > 0) {
                            java.util.Calendar cal = java.util.Calendar.getInstance();
                            cal.setTimeInMillis(stockOutDate.getTime());
                            cal.add(java.util.Calendar.MONTH, warrantyMonths); // Cộng thêm số tháng bảo hành
                            java.util.Date warrantyEndDate = cal.getTime();
                            java.util.Date today = new java.util.Date();
                            
                            // Tính số ngày còn lại của bảo hành
                            long diffInMillis = warrantyEndDate.getTime() - today.getTime();
                            long diffInDays = diffInMillis / (1000 * 60 * 60 * 24);
                            
                            boolean isWarrantyValid = diffInDays >= 0; // Còn bảo hành nếu >= 0
                            obj.put("warrantyValid", isWarrantyValid);
                            obj.put("warrantyDaysRemaining", diffInDays);
                            
                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                            obj.put("warrantyEndDate", sdf.format(warrantyEndDate));
                        } else {
                            // Nếu chưa xuất kho hoặc không có bảo hành thì không tính
                            obj.put("warrantyValid", JSONObject.NULL);
                            obj.put("warrantyDaysRemaining", JSONObject.NULL);
                            obj.put("warrantyEndDate", JSONObject.NULL);
                        }
                        
                        String notes = rs.getString("notes");
                        obj.put("notes", rs.wasNull() ? JSONObject.NULL : notes);
                        // deliveryStatus đã được lấy ở trên (dòng 80)
                        obj.put("deliveryStatus", deliveryStatus != null ? deliveryStatus : "not_delivered");
                        arr.put(obj);
                    }
                    out.print(successJson(arr));
                }
            }
        } catch (Exception e) {
            out.print(errorJson("Lỗi lấy sản phẩm hợp đồng: " + e.getMessage()));
        }
    }

    private JSONObject successJson(Object data) {
        JSONObject o = new JSONObject();
        o.put("success", true);
        o.put("data", data);
        return o;
    }

    private JSONObject errorJson(String msg) {
        JSONObject o = new JSONObject();
        o.put("success", false);
        o.put("message", msg);
        return o;
    }
}


