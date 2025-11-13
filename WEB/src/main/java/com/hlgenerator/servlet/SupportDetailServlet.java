package com.hlgenerator.servlet;

import com.hlgenerator.dao.SupportRequestDAO;
import com.hlgenerator.dao.WorkOrderDAO;
import com.hlgenerator.model.WorkOrder;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Map;

@WebServlet("/support-detail")
public class SupportDetailServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        PrintWriter out = response.getWriter();
        
        // Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("isLoggedIn") == null) {
            out.print("{\"success\": false, \"message\": \"Chưa đăng nhập\"}");
            return;
        }
        
        String userRole = (String) session.getAttribute("userRole");
        
        // Kiểm tra quyền
        if (!"customer_support".equals(userRole) && !"admin".equals(userRole)) {
            out.print("{\"success\": false, \"message\": \"Không có quyền truy cập\"}");
            return;
        }
        
        // Lấy ID của ticket
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            out.print("{\"success\": false, \"message\": \"Thiếu ID ticket\"}");
            return;
        }
        
        try {
            int ticketId = Integer.parseInt(idParam);
            
            // Lấy chi tiết ticket từ database
            SupportRequestDAO supportDAO = new SupportRequestDAO();
            Map<String, Object> ticket = supportDAO.getSupportRequestById(ticketId);
            
            if (ticket == null) {
                out.print("{\"success\": false, \"message\": \"Không tìm thấy ticket\"}");
                return;
            }
            
            // Chuyển đổi Map thành JSON
            JSONObject json = new JSONObject();
            json.put("success", true);
            
            JSONObject data = new JSONObject();
            data.put("id", ticket.get("id"));
            data.put("ticketNumber", ticket.get("ticketNumber"));
            data.put("subject", ticket.get("subject"));
            data.put("description", ticket.get("description") != null ? ticket.get("description") : "");
            data.put("category", ticket.get("category"));
            data.put("priority", ticket.get("priority"));
            data.put("status", ticket.get("status"));
            data.put("resolution", ticket.get("resolution") != null ? ticket.get("resolution") : "");
            data.put("history", ticket.get("history") != null ? ticket.get("history") : "");
            
            // Thông tin khách hàng
            data.put("customerName", ticket.get("customerName") != null ? ticket.get("customerName") : "N/A");
            data.put("customerContact", ticket.get("customerContact") != null ? ticket.get("customerContact") : "N/A");
            data.put("customerEmail", ticket.get("customerEmail") != null ? ticket.get("customerEmail") : "");
            data.put("customerPhone", ticket.get("customerPhone") != null ? ticket.get("customerPhone") : "");
            data.put("customerAddress", ticket.get("customerAddress") != null ? ticket.get("customerAddress") : "");
            
            // Người xử lý
            data.put("assignedTo", ticket.get("assignedTo") != null ? ticket.get("assignedTo") : "");
            data.put("assignedToName", ticket.get("assignedToName") != null ? ticket.get("assignedToName") : "");
            data.put("assignedToEmail", ticket.get("assignedToEmail") != null ? ticket.get("assignedToEmail") : "");
            
            // Ngày tháng
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
            if (ticket.get("createdAt") != null) {
                data.put("createdAt", sdf.format(ticket.get("createdAt")));
            }
            if (ticket.get("resolvedAt") != null) {
                data.put("resolvedAt", sdf.format(ticket.get("resolvedAt")));
            }
            // Deadline - luôn trả về (có thể null)
            Object deadlineObj = ticket.get("deadline");
            System.out.println("DEBUG SupportDetailServlet: deadline object from ticket map = " + deadlineObj);
            System.out.println("DEBUG SupportDetailServlet: deadline object type = " + (deadlineObj != null ? deadlineObj.getClass().getName() : "null"));
            
            if (deadlineObj != null) {
                try {
                    // Deadline từ DB là yyyy-MM-dd, chuyển sang dd/MM/yyyy
                    String deadlineStr = deadlineObj.toString();
                    System.out.println("DEBUG SupportDetailServlet: deadline string = " + deadlineStr);
                    
                    if (deadlineStr != null && !deadlineStr.isEmpty() && !deadlineStr.equals("null")) {
                        java.sql.Date deadlineDate = java.sql.Date.valueOf(deadlineStr);
                        String formattedDeadline = dateFormat.format(deadlineDate);
                        data.put("deadline", formattedDeadline);
                        System.out.println("DEBUG SupportDetailServlet: formatted deadline = " + formattedDeadline);
                    } else {
                        data.put("deadline", "");
                        System.out.println("DEBUG SupportDetailServlet: deadline is empty or 'null' string, setting to empty");
                    }
                } catch (Exception e) {
                    // Nếu có lỗi, thử giữ nguyên format hoặc để rỗng
                    System.out.println("DEBUG SupportDetailServlet: Error formatting deadline: " + e.getMessage());
                    e.printStackTrace();
                    // Thử giữ nguyên format nếu có thể
                    String deadlineStr = deadlineObj.toString();
                    if (deadlineStr != null && !deadlineStr.isEmpty() && !deadlineStr.equals("null")) {
                        data.put("deadline", deadlineStr);
                    } else {
                        data.put("deadline", "");
                    }
                }
            } else {
                data.put("deadline", "");
                System.out.println("DEBUG SupportDetailServlet: deadline is null, setting to empty string");
            }
            
            System.out.println("DEBUG SupportDetailServlet: Final deadline in JSON data = " + data.get("deadline"));
            
            // Lấy technical_solution từ work_order nếu có
            try {
                WorkOrderDAO workOrderDAO = new WorkOrderDAO();
                String ticketTitle = (String) ticket.get("subject");
                Integer customerIdObj = (Integer) ticket.get("customerId");
                int customerId = customerIdObj != null ? customerIdObj : 0;
                
                WorkOrder workOrder = workOrderDAO.getWorkOrderByTicketId(ticketId, ticketTitle, customerId);
                if (workOrder != null && workOrder.getTechnicalSolution() != null && !workOrder.getTechnicalSolution().trim().isEmpty()) {
                    data.put("technicalSolution", workOrder.getTechnicalSolution());
                    System.out.println("DEBUG SupportDetailServlet: Found technical solution from work order: " + workOrder.getWorkOrderNumber());
                } else {
                    data.put("technicalSolution", "");
                    System.out.println("DEBUG SupportDetailServlet: No technical solution found for ticket " + ticketId);
                }
            } catch (Exception e) {
                System.out.println("DEBUG SupportDetailServlet: Error getting technical solution: " + e.getMessage());
                e.printStackTrace();
                data.put("technicalSolution", "");
            }
            
            // Lấy thông tin bảo hành từ description (parse hợp đồng và sản phẩm)
            try {
                String description = (String) ticket.get("description");
                System.out.println("DEBUG SupportDetailServlet: description = " + description);
                
                if (description != null && (description.contains("[Hợp đồng:") || description.contains("[Hợp đồng :"))) {
                    // Parse contract và product từ description - hỗ trợ cả [Hợp đồng: và [Hợp đồng :
                    java.util.regex.Pattern contractPattern = java.util.regex.Pattern.compile("\\[Hợp đồng\\s*:([^\\]]+)\\]");
                    java.util.regex.Pattern productPattern = java.util.regex.Pattern.compile("\\[Sản phẩm\\s*:([^\\]]+)\\]");
                    
                    java.util.regex.Matcher contractMatcher = contractPattern.matcher(description);
                    java.util.regex.Matcher productMatcher = productPattern.matcher(description);
                    
                    boolean hasContract = contractMatcher.find();
                    boolean hasProduct = productMatcher.find();
                    
                    System.out.println("DEBUG SupportDetailServlet: hasContract = " + hasContract + ", hasProduct = " + hasProduct);
                    
                    if (hasContract) {
                        String contractText = contractMatcher.group(1).trim();
                        System.out.println("DEBUG SupportDetailServlet: contractText = '" + contractText + "'");
                        
                        // Tìm contract_id từ contract_number hoặc title
                        // Contract text có thể là: "HD-20251114-0001 - ABC" hoặc chỉ "HD-20251114-0001"
                        int contractId = 0;
                        int productId = 0;
                        
                        try {
                            java.util.Properties props = new java.util.Properties();
                            java.io.InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties");
                            if (input != null) {
                                props.load(input);
                                String url = props.getProperty("db.url");
                                String user = props.getProperty("db.username");
                                String pass = props.getProperty("db.password");
                                
                                try (java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, pass)) {
                                    // Tách contractText thành các phần (có thể có format: "contractNumber - title")
                                    String contractNumber = contractText;
                                    String contractTitle = "";
                                    
                                    if (contractText.contains(" - ")) {
                                        String[] parts = contractText.split(" - ", 2);
                                        if (parts.length >= 1) {
                                            contractNumber = parts[0].trim();
                                        }
                                        if (parts.length >= 2) {
                                            contractTitle = parts[1].trim();
                                        }
                                        System.out.println("DEBUG SupportDetailServlet: Split contractText - contractNumber = '" + contractNumber + "', contractTitle = '" + contractTitle + "'");
                                    }
                                    
                                    // Tìm contract_id - thử nhiều cách theo thứ tự ưu tiên
                                    // 1. Tìm theo contract_number chính xác (nếu đã tách được)
                                    if (contractId == 0 && !contractNumber.equals(contractText)) {
                                        String contractSql = "SELECT id, contract_number, title FROM contracts WHERE contract_number = ? LIMIT 1";
                                        try (java.sql.PreparedStatement ps = conn.prepareStatement(contractSql)) {
                                            ps.setString(1, contractNumber);
                                            try (java.sql.ResultSet rs = ps.executeQuery()) {
                                                if (rs.next()) {
                                                    contractId = rs.getInt("id");
                                                    System.out.println("DEBUG SupportDetailServlet: Found contract_id = " + contractId + 
                                                                       " by contract_number = '" + contractNumber + "'");
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 2. Tìm theo title chính xác (nếu đã tách được)
                                    if (contractId == 0 && !contractTitle.isEmpty()) {
                                        String contractSql = "SELECT id, contract_number, title FROM contracts WHERE title = ? LIMIT 1";
                                        try (java.sql.PreparedStatement ps = conn.prepareStatement(contractSql)) {
                                            ps.setString(1, contractTitle);
                                            try (java.sql.ResultSet rs = ps.executeQuery()) {
                                                if (rs.next()) {
                                                    contractId = rs.getInt("id");
                                                    System.out.println("DEBUG SupportDetailServlet: Found contract_id = " + contractId + 
                                                                       " by title = '" + contractTitle + "'");
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 3. Tìm theo CONCAT(contract_number, ' - ', title) chính xác
                                    if (contractId == 0 && contractText.contains(" - ")) {
                                        String contractSql = "SELECT id, contract_number, title FROM contracts WHERE CONCAT(contract_number, ' - ', COALESCE(title, '')) = ? LIMIT 1";
                                        try (java.sql.PreparedStatement ps = conn.prepareStatement(contractSql)) {
                                            ps.setString(1, contractText);
                                            try (java.sql.ResultSet rs = ps.executeQuery()) {
                                                if (rs.next()) {
                                                    contractId = rs.getInt("id");
                                                    System.out.println("DEBUG SupportDetailServlet: Found contract_id = " + contractId + 
                                                                       " by CONCAT match = '" + contractText + "'");
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 4. Tìm theo contract_number LIKE
                                    if (contractId == 0) {
                                        String contractSql = "SELECT id, contract_number, title FROM contracts WHERE contract_number LIKE ? LIMIT 1";
                                        try (java.sql.PreparedStatement ps = conn.prepareStatement(contractSql)) {
                                            ps.setString(1, "%" + contractNumber + "%");
                                            try (java.sql.ResultSet rs = ps.executeQuery()) {
                                                if (rs.next()) {
                                                    contractId = rs.getInt("id");
                                                    System.out.println("DEBUG SupportDetailServlet: Found contract_id = " + contractId + 
                                                                       " by contract_number LIKE '%" + contractNumber + "%'");
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 5. Tìm theo title LIKE
                                    if (contractId == 0) {
                                        String contractSql = "SELECT id, contract_number, title FROM contracts WHERE title LIKE ? LIMIT 1";
                                        try (java.sql.PreparedStatement ps = conn.prepareStatement(contractSql)) {
                                            ps.setString(1, "%" + contractText + "%");
                                            try (java.sql.ResultSet rs = ps.executeQuery()) {
                                                if (rs.next()) {
                                                    contractId = rs.getInt("id");
                                                    System.out.println("DEBUG SupportDetailServlet: Found contract_id = " + contractId + 
                                                                       " by title LIKE '%" + contractText + "%'");
                                                }
                                            }
                                        }
                                    }
                                    
                                    if (contractId == 0) {
                                        System.out.println("DEBUG SupportDetailServlet: No contract found for text: '" + contractText + "'");
                                    }
                                    
                                    if (contractId > 0 && hasProduct) {
                                        String productText = productMatcher.group(1).trim();
                                        System.out.println("DEBUG SupportDetailServlet: productText = '" + productText + "'");
                                        
                                        // Tìm product_id từ contract_products - thử nhiều cách
                                        String productSql = "SELECT cp.product_id, cp.warranty_months, cp.description as cp_description, " +
                                                          "COALESCE(cp.delivery_status, 'not_delivered') as delivery_status, " +
                                                          "p.warranty_months as product_warranty_months, p.product_name " +
                                                          "FROM contract_products cp " +
                                                          "LEFT JOIN products p ON cp.product_id = p.id " +
                                                          "WHERE cp.contract_id = ? AND (" +
                                                          "cp.description = ? OR p.product_name = ? OR " +
                                                          "cp.description LIKE ? OR p.product_name LIKE ?) " +
                                                          "ORDER BY CASE WHEN cp.description = ? THEN 1 WHEN p.product_name = ? THEN 2 ELSE 3 END LIMIT 1";
                                        try (java.sql.PreparedStatement ps = conn.prepareStatement(productSql)) {
                                            ps.setInt(1, contractId);
                                            ps.setString(2, productText);
                                            ps.setString(3, productText);
                                            ps.setString(4, "%" + productText + "%");
                                            ps.setString(5, "%" + productText + "%");
                                            ps.setString(6, productText);
                                            ps.setString(7, productText);
                                            try (java.sql.ResultSet rs = ps.executeQuery()) {
                                                if (rs.next()) {
                                                    productId = rs.getInt("product_id");
                                                    System.out.println("DEBUG SupportDetailServlet: Found product_id = " + productId + 
                                                                       ", cp_description = " + rs.getString("cp_description") + 
                                                                       ", product_name = " + rs.getString("product_name"));
                                                    
                                                    // Lấy warranty_months
                                                    int warrantyMonths = rs.getInt("warranty_months");
                                                    if (rs.wasNull()) {
                                                        warrantyMonths = rs.getInt("product_warranty_months");
                                                        if (rs.wasNull()) {
                                                            warrantyMonths = 12;
                                                        }
                                                    }
                                                    
                                                    // Lấy delivery_status
                                                    String deliveryStatus = rs.getString("delivery_status");
                                                    
                                                    // Lấy ngày xuất kho
                                                    java.sql.Timestamp stockOutDate = null;
                                                    String stockOutDateStr = null;
                                                    String warrantyEndDateStr = null;
                                                    boolean warrantyValid = false;
                                                    long warrantyDaysRemaining = 0;
                                                    
                                                    // Thử tìm với reference_type = 'contract' trước
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
                                                                    SimpleDateFormat sdfStock = new SimpleDateFormat("yyyy-MM-dd");
                                                                    stockOutDateStr = sdfStock.format(stockOutDate);
                                                                    
                                                                    // Tính ngày hết hạn bảo hành
                                                                    java.util.Calendar cal = java.util.Calendar.getInstance();
                                                                    cal.setTimeInMillis(stockOutDate.getTime());
                                                                    cal.add(java.util.Calendar.MONTH, warrantyMonths);
                                                                    java.util.Date warrantyEndDate = cal.getTime();
                                                                    java.util.Date today = new java.util.Date();
                                                                    
                                                                    long diffInMillis = warrantyEndDate.getTime() - today.getTime();
                                                                    warrantyDaysRemaining = diffInMillis / (1000 * 60 * 60 * 24);
                                                                    warrantyValid = warrantyDaysRemaining >= 0;
                                                                    
                                                                    SimpleDateFormat dateFormatWarranty = new SimpleDateFormat("dd/MM/yyyy");
                                                                    warrantyEndDateStr = dateFormatWarranty.format(warrantyEndDate);
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
                                                                        SimpleDateFormat sdfStock = new SimpleDateFormat("yyyy-MM-dd");
                                                                        stockOutDateStr = sdfStock.format(stockOutDate);
                                                                        
                                                                        // Tính ngày hết hạn bảo hành
                                                                        java.util.Calendar cal = java.util.Calendar.getInstance();
                                                                        cal.setTimeInMillis(stockOutDate.getTime());
                                                                        cal.add(java.util.Calendar.MONTH, warrantyMonths);
                                                                        java.util.Date warrantyEndDate = cal.getTime();
                                                                        java.util.Date today = new java.util.Date();
                                                                        
                                                                        long diffInMillis = warrantyEndDate.getTime() - today.getTime();
                                                                        warrantyDaysRemaining = diffInMillis / (1000 * 60 * 60 * 24);
                                                                        warrantyValid = warrantyDaysRemaining >= 0;
                                                                        
                                                                        SimpleDateFormat dateFormatWarranty = new SimpleDateFormat("dd/MM/yyyy");
                                                                        warrantyEndDateStr = dateFormatWarranty.format(warrantyEndDate);
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                        // Nếu vẫn không tìm thấy, tìm bất kỳ bản ghi xuất kho nào của sản phẩm này
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
                                                                            SimpleDateFormat sdfStock = new SimpleDateFormat("yyyy-MM-dd");
                                                                            stockOutDateStr = sdfStock.format(stockOutDate);
                                                                            
                                                                            // Tính ngày hết hạn bảo hành
                                                                            java.util.Calendar cal = java.util.Calendar.getInstance();
                                                                            cal.setTimeInMillis(stockOutDate.getTime());
                                                                            cal.add(java.util.Calendar.MONTH, warrantyMonths);
                                                                            java.util.Date warrantyEndDate = cal.getTime();
                                                                            java.util.Date today = new java.util.Date();
                                                                            
                                                                            long diffInMillis = warrantyEndDate.getTime() - today.getTime();
                                                                            warrantyDaysRemaining = diffInMillis / (1000 * 60 * 60 * 24);
                                                                            warrantyValid = warrantyDaysRemaining >= 0;
                                                                            
                                                                            SimpleDateFormat dateFormatWarranty = new SimpleDateFormat("dd/MM/yyyy");
                                                                            warrantyEndDateStr = dateFormatWarranty.format(warrantyEndDate);
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    // Thêm thông tin bảo hành vào response
                                                    System.out.println("DEBUG SupportDetailServlet: Adding warranty info - " +
                                                                       "warrantyMonths=" + warrantyMonths + 
                                                                       ", stockOutDate=" + stockOutDateStr + 
                                                                       ", warrantyEndDate=" + warrantyEndDateStr + 
                                                                       ", warrantyValid=" + warrantyValid + 
                                                                       ", warrantyDaysRemaining=" + warrantyDaysRemaining);
                                                    data.put("warrantyMonths", warrantyMonths);
                                                    data.put("stockOutDate", stockOutDateStr != null ? stockOutDateStr : "");
                                                    data.put("warrantyEndDate", warrantyEndDateStr != null ? warrantyEndDateStr : "");
                                                    data.put("warrantyValid", warrantyValid);
                                                    data.put("warrantyDaysRemaining", warrantyDaysRemaining);
                                                } else {
                                                    System.out.println("DEBUG SupportDetailServlet: No product found for text: '" + productText + "' in contract_id: " + contractId);
                                                }
                                            }
                                        }
                                    } else {
                                        if (!hasProduct) {
                                            System.out.println("DEBUG SupportDetailServlet: No product pattern found in description");
                                        } else {
                                            System.out.println("DEBUG SupportDetailServlet: contractId = " + contractId + " (not found or <= 0)");
                                        }
                                    }
                                }
                            }
                        } catch (Exception e) {
                            System.out.println("DEBUG SupportDetailServlet: Error getting warranty info: " + e.getMessage());
                            e.printStackTrace();
                        }
                    } else {
                        System.out.println("DEBUG SupportDetailServlet: No contract pattern found in description");
                    }
                } else {
                    System.out.println("DEBUG SupportDetailServlet: Description does not contain [Hợp đồng: pattern");
                }
            } catch (Exception e) {
                System.out.println("DEBUG SupportDetailServlet: Error parsing warranty info from description: " + e.getMessage());
                e.printStackTrace();
            }
            
            json.put("data", data);
            out.print(json.toString());
            
        } catch (NumberFormatException e) {
            out.print("{\"success\": false, \"message\": \"ID không hợp lệ\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Lỗi: " + e.getMessage() + "\"}");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}

