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
        } else if ("getInventoryDetail".equals(action)) {
            getInventoryDetail(request, response);
        } else if ("getStats".equals(action)) {
            getStatistics(request, response);
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid action\"}");
        }
    }

    /**
     * Lấy chi tiết tồn kho + thông tin sản phẩm cho modal xem nhanh
     */
    private void getInventoryDetail(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            String idParam = request.getParameter("productId");
            if (idParam == null || idParam.trim().isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Thiếu productId\"}");
                return;
            }
            int productId = Integer.parseInt(idParam);

            Product p = productDAO.getProductById(productId);
            if (p == null) {
                // Fallback: tham số có thể là inventory.id → chuyển sang product_id
                Integer resolvedProductId = inventoryDAO.getProductIdByInventoryId(productId);
                if (resolvedProductId != null) {
                    productId = resolvedProductId;
                    p = productDAO.getProductById(productId);
                }
                if (p == null) {
                    response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy sản phẩm\"}");
                    return;
                }
            }

            Double lastUnitCost = inventoryDAO.getLastUnitCost(productId);
            int totalStock = inventoryDAO.getTotalStock(productId);
            int quantitySold = inventoryDAO.getQuantitySold(productId);
            java.util.List<java.util.Map<String, Object>> ws = inventoryDAO.getWarehouseStocks(productId);

            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":{");
            json.append("\"productId\":").append(productId).append(",");
            json.append("\"productCode\":\"").append(escapeJson(p.getProductCode())).append("\",");
            json.append("\"productName\":\"").append(escapeJson(p.getProductName())).append("\",");
            json.append("\"category\":\"").append(escapeJson(p.getCategory())).append("\",");
            json.append("\"unit\":\"").append(escapeJson(p.getUnit())).append("\",");
            json.append("\"unitPrice\":").append(p.getUnitPrice()).append(",");
            json.append("\"unitCost\":").append(lastUnitCost == null ? "null" : lastUnitCost).append(",");
            json.append("\"totalStock\":").append(totalStock).append(",");
            json.append("\"quantitySold\":").append(quantitySold).append(",");
            json.append("\"description\":\"").append(escapeJson(p.getDescription() == null? "" : p.getDescription())).append("\",");
            json.append("\"specifications\":\"").append(escapeJson(p.getSpecifications() == null? "" : p.getSpecifications())).append("\",");
            json.append("\"imageUrl\":\"").append(escapeJson(p.getImageUrl() == null? "" : p.getImageUrl())).append("\",");
            json.append("\"status\":\"").append(escapeJson(p.getStatus() == null? "" : p.getStatus())).append("\",");
            json.append("\"warehouses\":[");
            for (int i = 0; i < ws.size(); i++) {
                if (i>0) json.append(",");
                java.util.Map<String,Object> m = ws.get(i);
                json.append("{\"warehouse\":\"").append(escapeJson((String)m.get("warehouse"))).append("\",");
                json.append("\"stock\":").append((Integer)m.get("stock")).append("}");
            }
            json.append("]}}");
            response.getWriter().write(json.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
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
            
            // Chỉ sử dụng 3 danh mục cố định
            List<String> categories = getFixedCategories();
            
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
                // Thêm giá: đơn giá nhập gần nhất và giá bán hiện tại
                Double lastUnitCost = inventoryDAO.getLastUnitCost(inv.getProductId());
                json.append("\"unitCost\":").append(lastUnitCost == null ? "null" : lastUnitCost).append(",");
                json.append("\"unitPrice\":").append(inv.getUnitPrice());
                
                // Giữ lại các trường min/max để không phá vỡ client cũ (không còn hiển thị)
                json.append(",\"minStock\":").append(inv.getMinStock()).append(",");
                json.append("\"maxStock\":").append(inv.getMaxStock());
                json.append("}");
            }
            
            json.append("],\"totalCount\":").append(totalCount);
            json.append(",\"currentPage\":").append(page);
            json.append(",\"pageSize\":").append(pageSize);
            json.append(",\"totalPages\":").append((int) Math.ceil((double) totalCount / pageSize));
            
            // Thêm danh sách categories vào response (chỉ 3 danh mục cố định)
            json.append(",\"categories\":[");
            for (int i = 0; i < categories.size(); i++) {
                if (i > 0) json.append(",");
                json.append("\"").append(escapeJson(categories.get(i))).append("\"");
            }
            json.append("]");
            
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
                json.append("\"unit\":\"").append(escapeJson(p.getUnit())).append("\",");
                json.append("\"supplierId\":").append(p.getSupplierId()).append(",");
                json.append("\"supplierName\":\"").append(escapeJson(p.getSupplierName())).append("\"");
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
            String productIdParam = request.getParameter("productId");
            if (productIdParam != null) {
                productIdParam = productIdParam.trim();
                if (!productIdParam.isEmpty() && productIdParam.matches("\\d+")) {
                    productId = Integer.parseInt(productIdParam);
                }
            }
            // Filters
            String movementType = request.getParameter("type");
            String warehouse = request.getParameter("warehouse");
            String search = request.getParameter("q");

            // Pagination
            int page = 1; int pageSize = 10;
            if (request.getParameter("page") != null) { try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignore) {} }
            if (request.getParameter("pageSize") != null) { try { pageSize = Integer.parseInt(request.getParameter("pageSize")); } catch (Exception ignore) {} }

            List<StockHistory> historyList = inventoryDAO.getFilteredStockHistory(productId, movementType, warehouse, search, page, pageSize);
            int totalCount = inventoryDAO.getFilteredStockHistoryCount(productId, movementType, warehouse, search);

            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":[");

            for (int i = 0; i < historyList.size(); i++) {
                if (i > 0) json.append(",");
                StockHistory h = historyList.get(i);
                json.append("{");
                json.append("\"id\":").append(h.getId()).append(",");
                json.append("\"productId\":").append(h.getProductId()).append(",");
                json.append("\"productCode\":\"").append(escapeJson(h.getProductCode())).append("\",");
                json.append("\"productName\":\"").append(escapeJson(h.getProductName())).append("\",");
                json.append("\"movementType\":\"").append(escapeJson(h.getMovementType())).append("\",");
                json.append("\"quantity\":").append(h.getQuantity()).append(",");
                json.append("\"referenceType\":\"").append(escapeJson(h.getReferenceType())).append("\",");
                // Thêm thông tin kho và giá
                json.append("\"warehouseLocation\":\"").append(escapeJson(h.getWarehouseLocation())).append("\",");
                if (h.getUnitCost() != null) {
                    json.append("\"unitCost\":").append(h.getUnitCost()).append(",");
                } else {
                    json.append("\"unitCost\":null,");
                }
                // Giá bán hiện tại
                double unitPrice = 0;
                try {
                    Product p = productDAO.getProductById(h.getProductId());
                    if (p != null) unitPrice = p.getUnitPrice();
                } catch (Exception ignore) {}
                json.append("\"unitPrice\":").append(unitPrice).append(",");
                json.append("\"createdAt\":\"").append(h.getCreatedAt()).append("\",");
                json.append("\"createdByName\":\"").append(escapeJson(h.getCreatedByName())).append("\"");
                json.append("}");
            }
            json.append("],\"totalCount\":").append(totalCount);
            json.append(",\"currentPage\":").append(page);
            json.append(",\"pageSize\":").append(pageSize);
            json.append(",\"totalPages\":").append((int)Math.ceil((double) totalCount / pageSize));
            json.append("}");
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

                // Nếu sản phẩm chưa có giá bán, tự đặt = unitCost * 1.10 (lợi nhuận 10%)
                if (unitCost > 0) {
                    double suggestedSellingPrice = Math.round(unitCost * 1.10 * 100.0) / 100.0; // làm tròn 2 số lẻ
                    try {
                        productDAO.updateUnitPriceIfEmpty(productId, suggestedSellingPrice);
                    } catch (Exception ex) {
                        // Không chặn quy trình nhập kho nếu cập nhật giá thất bại
                        System.err.println("Warn: updateUnitPriceIfEmpty failed for product " + productId + ": " + ex.getMessage());
                    }
                }
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
     * Lấy danh sách 3 danh mục cố định
     * Tác giả: Sơn Lê
     * @return Danh sách 3 danh mục: Máy phát điện, Máy bơm nước, Máy tiện
     */
    private List<String> getFixedCategories() {
        List<String> categories = new java.util.ArrayList<>();
        categories.add("Máy phát điện");
        categories.add("Máy bơm nước");
        categories.add("Máy tiện");
        return categories;
    }
    
    /**
     * Escape JSON string
     * Tác giả: Sơn Lê
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

