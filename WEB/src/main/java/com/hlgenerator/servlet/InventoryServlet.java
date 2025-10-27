package com.hlgenerator.servlet;

import com.hlgenerator.dao.InventoryDAO;
import com.hlgenerator.dao.ProductDAO;
import com.hlgenerator.model.Inventory;
import com.hlgenerator.model.StockHistory;
import com.hlgenerator.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

@WebServlet("/inventory")
public class InventoryServlet extends HttpServlet {
    private InventoryDAO inventoryDAO;
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        inventoryDAO = new InventoryDAO();
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        if ("getInventory".equals(action)) {
            getInventory(request, response);
        } else if ("getProducts".equals(action)) {
            getProductsForDropdown(request, response);
        } else if ("getHistory".equals(action)) {
            getStockHistory(request, response);
        } else if ("getStats".equals(action)) {
            getStatistics(request, response);
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid action\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        if ("stockIn".equals(action)) {
            handleStockIn(request, response);
        } else if ("stockOut".equals(action)) {
            handleStockOut(request, response);
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid action\"}");
        }
    }
    
    /**
     * Lấy danh sách tồn kho với lọc và phân trang
     */
    private void getInventory(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String category = request.getParameter("category");
            String warehouse = request.getParameter("warehouse");
            String stockStatus = request.getParameter("stockStatus");
            String search = request.getParameter("search");
            
            int page = 1;
            int pageSize = 10;
            try {
                if (request.getParameter("page") != null) {
                    page = Integer.parseInt(request.getParameter("page"));
                }
                if (request.getParameter("pageSize") != null) {
                    pageSize = Integer.parseInt(request.getParameter("pageSize"));
                }
            } catch (NumberFormatException e) {
                // Use default values
            }
            
            List<Inventory> inventoryList = inventoryDAO.getFilteredInventory(
                category, warehouse, stockStatus, search, page, pageSize);
            int totalCount = inventoryDAO.getFilteredInventoryCount(
                category, warehouse, stockStatus, search);
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":[");
            
            for (int i = 0; i < inventoryList.size(); i++) {
                if (i > 0) json.append(",");
                Inventory inv = inventoryList.get(i);
                json.append("{");
                json.append("\"id\":").append(inv.getId()).append(",");
                json.append("\"productId\":").append(inv.getProductId()).append(",");
                json.append("\"productCode\":\"").append(escapeJson(inv.getProductCode())).append("\",");
                json.append("\"productName\":\"").append(escapeJson(inv.getProductName())).append("\",");
                json.append("\"category\":\"").append(escapeJson(inv.getCategory())).append("\",");
                json.append("\"warehouse\":\"").append(escapeJson(inv.getWarehouseLocation())).append("\",");
                json.append("\"currentStock\":").append(inv.getCurrentStock()).append(",");
                json.append("\"minStock\":").append(inv.getMinStock()).append(",");
                json.append("\"maxStock\":").append(inv.getMaxStock());
                json.append("}");
            }
            
            json.append("],\"totalCount\":").append(totalCount);
            json.append(",\"currentPage\":").append(page);
            json.append(",\"pageSize\":").append(pageSize);
            json.append(",\"totalPages\":").append((int) Math.ceil((double) totalCount / pageSize));
            json.append("}");
            
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"" + 
                escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Lấy danh sách sản phẩm cho dropdown
     */
    private void getProductsForDropdown(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            List<Product> products = productDAO.getAllProducts();
            
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":[");
            
            for (int i = 0; i < products.size(); i++) {
                if (i > 0) json.append(",");
                Product p = products.get(i);
                json.append("{");
                json.append("\"id\":").append(p.getId()).append(",");
                json.append("\"productCode\":\"").append(escapeJson(p.getProductCode())).append("\",");
                json.append("\"productName\":\"").append(escapeJson(p.getProductName())).append("\",");
                json.append("\"unit\":\"").append(escapeJson(p.getUnit())).append("\"");
                json.append("}");
            }
            
            json.append("]}");
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"" + 
                escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Lấy lịch sử xuất nhập kho
     */
    private void getStockHistory(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            Integer productId = null;
            if (request.getParameter("productId") != null) {
                productId = Integer.parseInt(request.getParameter("productId"));
            }
            
            int limit = 50;
            if (request.getParameter("limit") != null) {
                limit = Integer.parseInt(request.getParameter("limit"));
            }
            
            List<StockHistory> historyList = inventoryDAO.getStockHistory(productId, limit);
            
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":[");
            
            for (int i = 0; i < historyList.size(); i++) {
                if (i > 0) json.append(",");
                StockHistory h = historyList.get(i);
                json.append("{");
                json.append("\"id\":").append(h.getId()).append(",");
                json.append("\"productCode\":\"").append(escapeJson(h.getProductCode())).append("\",");
                json.append("\"productName\":\"").append(escapeJson(h.getProductName())).append("\",");
                json.append("\"movementType\":\"").append(escapeJson(h.getMovementType())).append("\",");
                json.append("\"quantity\":").append(h.getQuantity()).append(",");
                json.append("\"referenceType\":\"").append(escapeJson(h.getReferenceType())).append("\",");
                json.append("\"createdAt\":\"").append(h.getCreatedAt()).append("\",");
                json.append("\"createdByName\":\"").append(escapeJson(h.getCreatedByName())).append("\"");
                json.append("}");
            }
            
            json.append("]}");
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"" + 
                escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Lấy thống kê tồn kho
     */
    private void getStatistics(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            Map<String, Integer> stats = inventoryDAO.getInventoryStatistics();
            
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":{");
            json.append("\"totalProducts\":").append(stats.get("totalProducts")).append(",");
            json.append("\"totalStock\":").append(stats.get("totalStock")).append(",");
            json.append("\"lowStockCount\":").append(stats.get("lowStockCount")).append(",");
            json.append("\"outOfStockCount\":").append(stats.get("outOfStockCount"));
            json.append("}}");
            
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"" + 
                escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Xử lý nhập kho
     */
    private void handleStockIn(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            // Lấy user ID từ session
            HttpSession session = request.getSession();
            Integer userId = (Integer) session.getAttribute("userId");
            
            // Lấy thông tin form
            String referenceType = request.getParameter("referenceType");
            String referenceId = request.getParameter("referenceId");
            String notes = request.getParameter("notes");
            
            // Lấy danh sách sản phẩm (JSON array từ frontend)
            String productsJson = request.getParameter("products");
            
            // Parse products JSON - simplified parsing
            // Format: [{"productId":1,"quantity":10,"unitCost":1000,"warehouse":"Main Warehouse"}, ...]
            if (productsJson == null || productsJson.trim().isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Danh sách sản phẩm không được để trống\"}");
                return;
            }
            
            // Validate và xử lý từng sản phẩm
            boolean allSuccess = true;
            StringBuilder errorMsg = new StringBuilder();
            
            // Simple JSON parsing (bạn có thể dùng thư viện JSON nếu muốn)
            String[] productEntries = productsJson.replace("[", "").replace("]", "").split("},\\{");
            
            for (String entry : productEntries) {
                entry = entry.replace("{", "").replace("}", "");
                String[] fields = entry.split(",");
                
                int productId = 0;
                int quantity = 0;
                double unitCost = 0;
                String warehouse = "Main Warehouse";
                
                // Parse fields
                for (String field : fields) {
                    String[] kv = field.split(":");
                    if (kv.length == 2) {
                        String key = kv[0].trim().replace("\"", "");
                        String value = kv[1].trim().replace("\"", "");
                        
                        if ("productId".equals(key)) {
                            productId = Integer.parseInt(value);
                        } else if ("quantity".equals(key)) {
                            quantity = Integer.parseInt(value);
                        } else if ("unitCost".equals(key)) {
                            unitCost = Double.parseDouble(value);
                        } else if ("warehouse".equals(key)) {
                            warehouse = value;
                        }
                    }
                }
                
                // Validation
                if (productId <= 0) {
                    errorMsg.append("ID sản phẩm không hợp lệ. ");
                    allSuccess = false;
                    continue;
                }
                
                if (quantity <= 0) {
                    errorMsg.append("Số lượng phải lớn hơn 0. ");
                    allSuccess = false;
                    continue;
                }
                
                if (unitCost < 0) {
                    errorMsg.append("Đơn giá không được âm. ");
                    allSuccess = false;
                    continue;
                }
                
                // Cộng số lượng vào kho
                boolean stockAdded = inventoryDAO.addStock(productId, warehouse, quantity);
                
                if (!stockAdded) {
                    errorMsg.append("Lỗi khi nhập kho sản phẩm ID ").append(productId).append(". ");
                    allSuccess = false;
                    continue;
                }
                
                // Ghi lịch sử
                StockHistory history = new StockHistory();
                history.setProductId(productId);
                history.setWarehouseLocation(warehouse);
                history.setMovementType("in");
                history.setQuantity(quantity);
                history.setReferenceType(referenceType);
                if (referenceId != null && !referenceId.trim().isEmpty()) {
                    try {
                        history.setReferenceId(Integer.parseInt(referenceId));
                    } catch (NumberFormatException e) {
                        // Ignore if not a number
                    }
                }
                history.setUnitCost(unitCost > 0 ? unitCost : null);
                history.setNotes(notes);
                history.setCreatedBy(userId);
                
                inventoryDAO.addStockHistory(history);
            }
            
            if (allSuccess) {
                response.getWriter().write("{\"success\":true,\"message\":\"Nhập kho thành công\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"" + 
                    escapeJson(errorMsg.toString()) + "\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"" + 
                escapeJson("Lỗi hệ thống: " + e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Xử lý xuất kho
     */
    private void handleStockOut(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            // Lấy user ID từ session
            HttpSession session = request.getSession();
            Integer userId = (Integer) session.getAttribute("userId");
            
            // Lấy thông tin form
            String referenceType = request.getParameter("referenceType");
            String referenceId = request.getParameter("referenceId");
            String notes = request.getParameter("notes");
            
            // Lấy danh sách sản phẩm
            String productsJson = request.getParameter("products");
            
            if (productsJson == null || productsJson.trim().isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Danh sách sản phẩm không được để trống\"}");
                return;
            }
            
            boolean allSuccess = true;
            StringBuilder errorMsg = new StringBuilder();
            
            // Parse JSON
            String[] productEntries = productsJson.replace("[", "").replace("]", "").split("},\\{");
            
            for (String entry : productEntries) {
                entry = entry.replace("{", "").replace("}", "");
                String[] fields = entry.split(",");
                
                int productId = 0;
                int quantity = 0;
                String warehouse = "Main Warehouse";
                
                // Parse fields
                for (String field : fields) {
                    String[] kv = field.split(":");
                    if (kv.length == 2) {
                        String key = kv[0].trim().replace("\"", "");
                        String value = kv[1].trim().replace("\"", "");
                        
                        if ("productId".equals(key)) {
                            productId = Integer.parseInt(value);
                        } else if ("quantity".equals(key)) {
                            quantity = Integer.parseInt(value);
                        } else if ("warehouse".equals(key)) {
                            warehouse = value;
                        }
                    }
                }
                
                // Validation
                if (productId <= 0) {
                    errorMsg.append("ID sản phẩm không hợp lệ. ");
                    allSuccess = false;
                    continue;
                }
                
                if (quantity <= 0) {
                    errorMsg.append("Số lượng phải lớn hơn 0. ");
                    allSuccess = false;
                    continue;
                }
                
                // Trừ số lượng từ kho
                boolean stockSubtracted = inventoryDAO.subtractStock(productId, warehouse, quantity);
                
                if (!stockSubtracted) {
                    errorMsg.append(inventoryDAO.getLastError()).append(" ");
                    allSuccess = false;
                    continue;
                }
                
                // Ghi lịch sử
                StockHistory history = new StockHistory();
                history.setProductId(productId);
                history.setWarehouseLocation(warehouse);
                history.setMovementType("out");
                history.setQuantity(quantity);
                history.setReferenceType(referenceType);
                if (referenceId != null && !referenceId.trim().isEmpty()) {
                    try {
                        history.setReferenceId(Integer.parseInt(referenceId));
                    } catch (NumberFormatException e) {
                        // Ignore
                    }
                }
                history.setNotes(notes);
                history.setCreatedBy(userId);
                
                inventoryDAO.addStockHistory(history);
            }
            
            if (allSuccess) {
                response.getWriter().write("{\"success\":true,\"message\":\"Xuất kho thành công\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"" + 
                    escapeJson(errorMsg.toString()) + "\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"" + 
                escapeJson("Lỗi hệ thống: " + e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Escape JSON string
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\b", "\\b")
                  .replace("\f", "\\f")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}

