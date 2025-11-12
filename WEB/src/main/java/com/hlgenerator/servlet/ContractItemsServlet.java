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

            String sql = "SELECT product_id, description, quantity, unit_price, warranty_months, notes, COALESCE(delivery_status, 'not_delivered') as delivery_status FROM contract_products WHERE contract_id = ? ORDER BY id";
            try (java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, pass);
                 java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, contractId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    JSONArray arr = new JSONArray();
                    while (rs.next()) {
                        JSONObject obj = new JSONObject();
                        obj.put("productId", rs.getInt("product_id"));
                        String desc = rs.getString("description");
                        obj.put("description", rs.wasNull() ? JSONObject.NULL : desc);
                        obj.put("quantity", rs.getBigDecimal("quantity"));
                        obj.put("unitPrice", rs.getBigDecimal("unit_price"));
                        int w = rs.getInt("warranty_months");
                        if (rs.wasNull()) {
                            obj.put("warrantyMonths", JSONObject.NULL);
                        } else {
                            obj.put("warrantyMonths", w);
                        }
                        String notes = rs.getString("notes");
                        obj.put("notes", rs.wasNull() ? JSONObject.NULL : notes);
                        String deliveryStatus = rs.getString("delivery_status");
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


