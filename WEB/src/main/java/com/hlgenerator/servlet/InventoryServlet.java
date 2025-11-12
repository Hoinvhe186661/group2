package com.hlgenerator.servlet;

import com.hlgenerator.dao.InventoryDAO;
import com.hlgenerator.dao.ProductDAO;
import com.hlgenerator.dao.PriceHistoryDAO;
import com.hlgenerator.dao.SupplierDAO;
import com.hlgenerator.dao.ContractDAO;
import com.hlgenerator.model.Inventory;
import com.hlgenerator.model.StockHistory;
import com.hlgenerator.model.Product;
import com.hlgenerator.model.Supplier;
import com.hlgenerator.model.Contract;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet("/inventory")
public class InventoryServlet extends HttpServlet {
    private InventoryDAO inventoryDAO;
    private ProductDAO productDAO;
    private PriceHistoryDAO priceHistoryDAO;
    private SupplierDAO supplierDAO;
    private ContractDAO contractDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        inventoryDAO = new InventoryDAO();
        productDAO = new ProductDAO();
        priceHistoryDAO = new PriceHistoryDAO();
        supplierDAO = new SupplierDAO();
        contractDAO = new ContractDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("isLoggedIn") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }

        Set<String> permissions = getUserPermissions(session);
        String userRole = (String) session.getAttribute("userRole");
        boolean canManageInventory = hasPermission(permissions, "manage_inventory") || isInventoryRole(userRole);
        boolean canViewInventory = canManageInventory || hasPermission(permissions, "view_inventory");

        if (!canViewInventory) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"message\":\"Không có quyền truy cập\"}");
            return;
        }

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
        } else if ("getSuppliers".equals(action)) {
            getSuppliersForDropdown(request, response);
        } else if ("getContracts".equals(action)) {
            getContractsForDropdown(request, response);
        } else if ("getContractInfo".equals(action)) {
            getContractInfo(request, response);
        } else if ("getContractInfoForStockOut".equals(action)) {
            getContractInfoForStockOut(request, response);
        } else if ("getContractsList".equals(action)) {
            getContractsList(request, response);
        } else if ("getContractDetails".equals(action)) {
            getContractDetails(request, response);
        } else if ("getStockList".equals(action)) {
            getStockList(request, response);
        } else if ("getStockBalance".equals(action)) {
            getStockBalance(request, response);
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
            int reservedStock = inventoryDAO.getReservedStock(productId);
            int availableStock = inventoryDAO.getAvailableStock(productId);
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
            json.append("\"reservedStock\":").append(reservedStock).append(",");
            json.append("\"availableStock\":").append(availableStock).append(",");
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
                json.append("\"stock\":").append(m.get("stock")).append(",");
                json.append("\"reserved\":").append(m.get("reserved")).append(",");
                json.append("\"available\":").append(m.get("available")).append("}");
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
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("isLoggedIn") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }

        Set<String> permissions = getUserPermissions(session);
        String userRole = (String) session.getAttribute("userRole");
        boolean canManageInventory = hasPermission(permissions, "manage_inventory") || isInventoryRole(userRole);

        if (!canManageInventory) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"success\":false,\"message\":\"Không có quyền thực hiện\"}");
            return;
        }
        
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
     * Lấy danh sách hợp đồng với lọc và phân trang
     * Lấy tất cả hợp đồng (không lọc theo trạng thái cụ thể)
     */
    private void getContractsList(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String status = request.getParameter("status");
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
            
            // Lấy danh sách hợp đồng
            List<Contract> allContracts = contractDAO.getAllContracts();
            
            // Lọc theo trạng thái và tìm kiếm
            List<Contract> filteredContracts = new java.util.ArrayList<>();
            
            for (Contract c : allContracts) {
                String contractStatus = c.getStatus();
                if (contractStatus == null) {
                    contractStatus = "";
                }
                
                // Lọc theo trạng thái nếu có filter
                if (status != null && !status.trim().isEmpty()) {
                    if (!status.equals(contractStatus)) {
                        continue;
                    }
                }
                
                // Lọc theo tìm kiếm (mã hợp đồng hoặc tên khách hàng)
                if (search != null && !search.trim().isEmpty()) {
                    String searchLower = search.toLowerCase();
                    String contractNumber = c.getContractNumber() != null ? c.getContractNumber().toLowerCase() : "";
                    String customerName = c.getCustomerName() != null ? c.getCustomerName().toLowerCase() : "";
                    if (!contractNumber.contains(searchLower) && !customerName.contains(searchLower)) {
                        continue;
                    }
                }
                
                filteredContracts.add(c);
            }
            
            // Log để debug
            System.out.println("InventoryServlet.getContractsList - Total contracts: " + allContracts.size() + 
                ", Filtered: " + filteredContracts.size());
            
            int totalCount = filteredContracts.size();
            
            // Phân trang
            int start = (page - 1) * pageSize;
            int end = Math.min(start + pageSize, totalCount);
            List<Contract> pagedContracts = new java.util.ArrayList<>();
            if (start < totalCount) {
                pagedContracts = filteredContracts.subList(start, end);
            }
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":[");
            
            for (int i = 0; i < pagedContracts.size(); i++) {
                if (i > 0) json.append(",");
                Contract c = pagedContracts.get(i);
                json.append("{");
                json.append("\"id\":").append(c.getId()).append(",");
                json.append("\"contractNumber\":\"").append(escapeJson(c.getContractNumber())).append("\",");
                json.append("\"customerId\":").append(c.getCustomerId()).append(",");
                json.append("\"customerName\":\"").append(escapeJson(c.getCustomerName() != null ? c.getCustomerName() : "")).append("\",");
                json.append("\"customerPhone\":\"").append(escapeJson(c.getCustomerPhone() != null ? c.getCustomerPhone() : "")).append("\",");
                json.append("\"contractType\":\"").append(escapeJson(c.getContractType() != null ? c.getContractType() : "")).append("\",");
                json.append("\"title\":\"").append(escapeJson(c.getTitle() != null ? c.getTitle() : "")).append("\",");
                json.append("\"startDate\":\"").append(c.getStartDate() != null ? c.getStartDate().toString() : "").append("\",");
                json.append("\"contractValue\":").append(c.getContractValue() != null ? c.getContractValue() : "null").append(",");
                json.append("\"status\":\"").append(escapeJson(c.getStatus() != null ? c.getStatus() : "")).append("\"");
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
                json.append("\"reservedStock\":").append(inv.getReservedQuantity()).append(",");
                json.append("\"availableStock\":").append(inv.getAvailableStock()).append(",");
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
     * Lấy danh sách nhà cung cấp cho dropdown (chỉ lấy active)
     */
    private void getSuppliersForDropdown(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();
            
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":[");
            
            int count = 0;
            for (Supplier s : suppliers) {
                // Chỉ lấy nhà cung cấp active
                if (s.getStatus() != null && "active".equals(s.getStatus())) {
                    if (count > 0) json.append(",");
                    json.append("{");
                    json.append("\"id\":").append(s.getId()).append(",");
                    json.append("\"supplierCode\":\"").append(escapeJson(s.getSupplierCode())).append("\",");
                    json.append("\"companyName\":\"").append(escapeJson(s.getCompanyName())).append("\",");
                    json.append("\"contactPerson\":\"").append(escapeJson(s.getContactPerson())).append("\"");
                    json.append("}");
                    count++;
                }
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
     * Lấy danh sách hợp đồng cho dropdown (lấy tất cả trừ deleted)
     */
    private void getContractsForDropdown(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            List<Contract> contracts = contractDAO.getAllContracts();
            
            System.out.println("getContractsForDropdown: Found " + contracts.size() + " contracts (excluding deleted)");
            
            // Nếu không có hợp đồng nào, thử lấy cả deleted để debug
            if (contracts.isEmpty()) {
                List<Contract> allContracts = contractDAO.getAllContractsIncludingDeleted();
                System.out.println("getContractsForDropdown: Total contracts in DB (including deleted): " + allContracts.size());
                if (!allContracts.isEmpty()) {
                    System.out.println("Warning: All contracts are marked as deleted!");
                }
            }
            
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":[");
            
            int count = 0;
            for (Contract c : contracts) {
                // Lấy tất cả hợp đồng (trừ deleted - đã được filter ở getAllContracts)
                // Bao gồm: draft, active, completed, terminated, expired
                if (count > 0) json.append(",");
                json.append("{");
                json.append("\"id\":").append(c.getId()).append(",");
                json.append("\"contractNumber\":\"").append(escapeJson(c.getContractNumber() != null ? c.getContractNumber() : "")).append("\",");
                json.append("\"customerId\":").append(c.getCustomerId()).append(",");
                json.append("\"customerName\":\"").append(escapeJson(c.getCustomerName() != null ? c.getCustomerName() : "")).append("\",");
                json.append("\"status\":\"").append(escapeJson(c.getStatus() != null ? c.getStatus() : "")).append("\"");
                json.append("}");
                count++;
                System.out.println("Added contract: ID=" + c.getId() + ", Number=" + c.getContractNumber() + ", Status=" + c.getStatus());
            }
            
            json.append("]}");
            System.out.println("getContractsForDropdown: Returning JSON with " + count + " contracts");
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Error in getContractsForDropdown: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"" + 
                escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Lấy thông tin hợp đồng và sản phẩm trong hợp đồng
     */
    private void getContractInfo(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String contractIdParam = request.getParameter("contractId");
            if (contractIdParam == null || contractIdParam.trim().isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Thiếu contractId\"}");
                return;
            }
            
            int contractId = Integer.parseInt(contractIdParam);
            Contract contract = contractDAO.getContractById(contractId);
            
            if (contract == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy hợp đồng\"}");
                return;
            }
            
            // Lấy danh sách sản phẩm trong hợp đồng - query được xử lý ở DAO
            java.util.List<java.util.Map<String, Object>> contractProducts = contractDAO.getContractProducts(contractId);
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":{");
            json.append("\"contractId\":").append(contract.getId()).append(",");
            json.append("\"contractNumber\":\"").append(escapeJson(contract.getContractNumber())).append("\",");
            json.append("\"customerId\":").append(contract.getCustomerId()).append(",");
            json.append("\"customerName\":\"").append(escapeJson(contract.getCustomerName() != null ? contract.getCustomerName() : "")).append("\",");
            json.append("\"products\":[");
            
            for (int i = 0; i < contractProducts.size(); i++) {
                if (i > 0) json.append(",");
                java.util.Map<String, Object> p = contractProducts.get(i);
                json.append("{");
                json.append("\"productId\":").append(p.get("productId")).append(",");
                json.append("\"quantity\":").append(p.get("quantity")).append(",");
                json.append("\"productCode\":\"").append(escapeJson((String)p.get("productCode"))).append("\",");
                json.append("\"productName\":\"").append(escapeJson((String)p.get("productName"))).append("\",");
                json.append("\"unit\":\"").append(escapeJson((String)p.get("unit"))).append("\"");
                json.append("}");
            }
            
            json.append("]}}");
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"" + 
                escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Lấy thông tin hợp đồng và sản phẩm cho form xuất kho
     * Backend xử lý toàn bộ: query hợp đồng, sản phẩm, và tồn kho theo từng warehouse
     * Trả về đầy đủ thông tin để frontend chỉ cần hiển thị
     */
    private void getContractInfoForStockOut(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String contractIdParam = request.getParameter("contractId");
            String warehouseParam = request.getParameter("warehouse"); // Warehouse để lấy tồn kho
            
            if (contractIdParam == null || contractIdParam.trim().isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Thiếu contractId\"}");
                return;
            }
            
            int contractId = Integer.parseInt(contractIdParam);
            Contract contract = contractDAO.getContractById(contractId);
            
            if (contract == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy hợp đồng\"}");
                return;
            }
            
            // Lấy danh sách sản phẩm trong hợp đồng từ database
            java.util.List<java.util.Map<String, Object>> contractProducts = contractDAO.getContractProducts(contractId);
            
            // Lấy ngày hiện tại từ database (hoặc server)
            java.util.Date today = new java.util.Date();
            java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
            String todayStr = dateFormat.format(today);
            
            // Build JSON response với đầy đủ thông tin
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":{");
            json.append("\"contractId\":").append(contract.getId()).append(",");
            json.append("\"contractNumber\":\"").append(escapeJson(contract.getContractNumber())).append("\",");
            json.append("\"customerId\":").append(contract.getCustomerId()).append(",");
            json.append("\"customerName\":\"").append(escapeJson(contract.getCustomerName() != null ? contract.getCustomerName() : "")).append("\",");
            json.append("\"defaultDate\":\"").append(todayStr).append("\","); // Ngày mặc định là hôm nay
            json.append("\"products\":[");
            
            // Với mỗi sản phẩm, query tồn kho từ database
            for (int i = 0; i < contractProducts.size(); i++) {
                if (i > 0) json.append(",");
                java.util.Map<String, Object> p = contractProducts.get(i);
                int productId = (Integer) p.get("productId");
                
                // Query tồn kho theo từng warehouse từ database
                java.util.List<java.util.Map<String, Object>> warehouseStocks = inventoryDAO.getWarehouseStocks(productId);
                
                json.append("{");
                json.append("\"productId\":").append(productId).append(",");
                json.append("\"quantity\":").append(p.get("quantity")).append(",");
                json.append("\"productCode\":\"").append(escapeJson((String)p.get("productCode"))).append("\",");
                json.append("\"productName\":\"").append(escapeJson((String)p.get("productName"))).append("\",");
                json.append("\"unit\":\"").append(escapeJson((String)p.get("unit"))).append("\",");
                
                // Thêm thông tin tồn kho theo từng warehouse
                json.append("\"stocks\":[");
                for (int j = 0; j < warehouseStocks.size(); j++) {
                    if (j > 0) json.append(",");
                    java.util.Map<String, Object> ws = warehouseStocks.get(j);
                    json.append("{");
                    json.append("\"warehouse\":\"").append(escapeJson((String)ws.get("warehouse"))).append("\",");
                    json.append("\"stock\":").append(ws.get("stock")).append(",");
                    json.append("\"reserved\":").append(ws.get("reserved")).append(",");
                    json.append("\"available\":").append(ws.get("available"));
                    json.append("}");
                }
                json.append("],");
                
                // Tồn kho tại warehouse được chọn (nếu có)
                int stockAtWarehouse = 0;
                if (warehouseParam != null && !warehouseParam.trim().isEmpty()) {
                    Inventory inv = inventoryDAO.getInventoryByProductAndWarehouse(productId, warehouseParam);
                    if (inv != null) {
                        stockAtWarehouse = inv.getAvailableStock();
                    }
                }
                json.append("\"stockAtSelectedWarehouse\":").append(stockAtWarehouse);
                
                json.append("}");
            }
            
            json.append("]}}");
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
            String dateFrom = request.getParameter("dateFrom");
            String dateTo = request.getParameter("dateTo");

            // Pagination
            int page = 1; int pageSize = 10;
            if (request.getParameter("page") != null) { try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignore) {} }
            if (request.getParameter("pageSize") != null) { try { pageSize = Integer.parseInt(request.getParameter("pageSize")); } catch (Exception ignore) {} }

            List<StockHistory> historyList = inventoryDAO.getFilteredStockHistory(productId, movementType, warehouse, search, dateFrom, dateTo, page, pageSize);
            int totalCount = inventoryDAO.getFilteredStockHistoryCount(productId, movementType, warehouse, search, dateFrom, dateTo);

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
                // Tồn kho hiện tại tại kho (snapshot): current, reserved, available
                int currentStockNow = 0;
                int reservedStockNow = 0;
                int availableStockNow = 0;
                try {
                    Inventory invNow = inventoryDAO.getInventoryByProductAndWarehouse(h.getProductId(), h.getWarehouseLocation());
                    if (invNow != null) {
                        currentStockNow = invNow.getCurrentStock();
                        reservedStockNow = invNow.getReservedQuantity();
                        availableStockNow = invNow.getAvailableStock();
                    }
                } catch (Exception ignore) {}
                json.append("\"currentStock\":").append(currentStockNow).append(",");
                json.append("\"reservedStock\":").append(reservedStockNow).append(",");
                json.append("\"availableStock\":").append(availableStockNow).append(",");
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
            @SuppressWarnings("unused")
            String supplierId = request.getParameter("supplierId"); // Lưu để có thể validate sau này
            String supplierName = request.getParameter("supplierName");
            String receiptDate = request.getParameter("receiptDate");
            
            // Lấy danh sách sản phẩm (JSON array từ frontend)
            String productsJson = request.getParameter("products");
            
            // Tạo notes với thông tin nhà cung cấp nếu có
            StringBuilder fullNotes = new StringBuilder();
            if (supplierName != null && !supplierName.trim().isEmpty()) {
                fullNotes.append("Nhà cung cấp: ").append(supplierName);
                if (receiptDate != null && !receiptDate.trim().isEmpty()) {
                    fullNotes.append(" | Ngày nhập: ").append(receiptDate);
                }
                if (notes != null && !notes.trim().isEmpty()) {
                    fullNotes.append("\n").append(notes);
                }
            } else if (notes != null && !notes.trim().isEmpty()) {
                fullNotes.append(notes);
            }
            
            // Parse products JSON - simplified parsing
            // Format: [{"productId":1,"quantity":10,"unitCost":1000,"warehouse":"Main Warehouse"}, ...]
            if (productsJson == null || productsJson.trim().isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Danh sách sản phẩm không được để trống\"}");
                return;
            }
            
            // Validate ghi chú tối đa 150 từ (nếu có)
            String notesToValidate = fullNotes.length() > 0 ? fullNotes.toString() : notes;
            if (notesToValidate != null && !notesToValidate.trim().isEmpty()) {
                int noteWords = countWords(notesToValidate);
                if (noteWords > 150) {
                    response.getWriter().write("{\"success\":false,\"message\":\"Ghi chú không được vượt quá 150 từ\"}");
                    return;
                }
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
                
                if (unitCost <= 0) {
                    errorMsg.append("Đơn giá phải lớn hơn 0. ");
                    allSuccess = false;
                    continue;
                }
                
                // Ghi nhận giá nhập trước khi thêm lịch sử, để so sánh thay đổi
                Double lastCostBefore = inventoryDAO.getLastUnitCost(productId);

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
                history.setNotes(fullNotes.length() > 0 ? fullNotes.toString() : notes);
                history.setCreatedBy(userId);
                
                inventoryDAO.addStockHistory(history);

                // Ghi chú: Việc cập nhật giá bán là chức năng của module Sale
                // Module kho chỉ quản lý giá nhập (unit_cost) và ghi vào stock_history
                // Đã loại bỏ logic tự động đề xuất giá bán để tách biệt trách nhiệm
                
                // Ghi lịch sử thay đổi giá mua nếu có thay đổi so với lần gần nhất
                if (unitCost > 0) {
                    boolean changed;
                    if (lastCostBefore == null) {
                        changed = true; // lần đầu có giá mua
                    } else {
                        changed = Math.abs(lastCostBefore - unitCost) > 1e-6;
                    }
                    if (changed) {
                        com.hlgenerator.model.PriceHistory ph = new com.hlgenerator.model.PriceHistory();
                        ph.setProductId(productId);
                        ph.setPriceType("purchase");
                        ph.setOldPrice(lastCostBefore);
                        ph.setNewPrice(unitCost);
                        ph.setReason(notes != null && !notes.isEmpty() ? notes : "Nhập kho");
                        ph.setReferenceType(referenceType != null ? referenceType : "stock_in");
                        // Không có reference_id cụ thể vì không lấy được ID stock_history ngay
                        ph.setUpdatedBy(userId);
                        try { priceHistoryDAO.insert(ph); } catch (Exception ignore) {}
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

    private int countWords(String s) {
        if (s == null) return 0;
        String trimmed = s.trim();
        if (trimmed.isEmpty()) return 0;
        String[] parts = trimmed.split("\\s+");
        int c = 0; for (String p : parts) { if (!p.isEmpty()) c++; }
        return c;
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
            String contractIdParam = request.getParameter("contractId"); // Lấy contractId nếu có
            
            // Lấy danh sách sản phẩm (JSON array từ frontend)
            String productsJson = request.getParameter("products");
            
            if (productsJson == null || productsJson.trim().isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Danh sách sản phẩm không được để trống\"}");
                return;
            }
            
            // Validate ghi chú tối đa 150 từ (nếu có)
            if (notes != null && !notes.trim().isEmpty()) {
                int noteWords = countWords(notes);
                if (noteWords > 150) {
                    response.getWriter().write("{\"success\":false,\"message\":\"Ghi chú không được vượt quá 150 từ\"}");
                    return;
                }
            }
            
            boolean allSuccess = true;
            StringBuilder errorMsg = new StringBuilder();
            
            // Parse JSON - cải thiện parsing để xử lý đúng format JSON
            productsJson = productsJson.trim();
            if (!productsJson.startsWith("[")) {
                response.getWriter().write("{\"success\":false,\"message\":\"Định dạng danh sách sản phẩm không hợp lệ\"}");
                return;
            }
            
            // Parse JSON array - xử lý đơn giản hóa
            String[] productEntries = productsJson.replace("[", "").replace("]", "").split("},\\{");
            
            for (String entry : productEntries) {
                entry = entry.replace("{", "").replace("}", "").trim();
                if (entry.isEmpty()) continue;
                
                String[] fields = entry.split(",");
                
                int productId = 0;
                int quantity = 0;
                String warehouse = "Main Warehouse";
                
                // Parse fields
                for (String field : fields) {
                    String[] kv = field.split(":");
                    if (kv.length == 2) {
                        String key = kv[0].trim().replace("\"", "").replace("'", "");
                        String value = kv[1].trim().replace("\"", "").replace("'", "");
                        
                        if ("productId".equals(key)) {
                            try {
                                productId = Integer.parseInt(value);
                            } catch (NumberFormatException e) {
                                errorMsg.append("ID sản phẩm không hợp lệ: ").append(value).append(". ");
                                allSuccess = false;
                                continue;
                            }
                        } else if ("quantity".equals(key)) {
                            try {
                                quantity = Integer.parseInt(value);
                            } catch (NumberFormatException e) {
                                errorMsg.append("Số lượng không hợp lệ: ").append(value).append(". ");
                                allSuccess = false;
                                continue;
                            }
                        } else if ("warehouse".equals(key)) {
                            warehouse = value;
                        }
                    }
                }
                
                // Validation cơ bản
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
                
                // VALIDATION TỒN KHO Ở BACKEND - Kiểm tra tồn kho hiện tại
                Inventory currentInventory = inventoryDAO.getInventoryByProductAndWarehouse(productId, warehouse);
                if (currentInventory == null) {
                    errorMsg.append("Sản phẩm ID ").append(productId).append(" không có trong kho ").append(warehouse).append(". ");
                    allSuccess = false;
                    continue;
                }
                
                int currentStock = currentInventory.getAvailableStock();
                if (quantity > currentStock) {
                    errorMsg.append("Sản phẩm ID ").append(productId)
                            .append(" (").append(currentInventory.getProductName()).append("): ")
                            .append("Số lượng xuất (").append(quantity)
                            .append(") vượt quá tồn kho khả dụng (").append(currentStock).append("). ");
                    allSuccess = false;
                    continue;
                }
                
                if (!inventoryDAO.releaseReservedStock(productId, warehouse, quantity)) {
                    System.out.println("Warning: Không thể giải phóng đủ số lượng giữ chỗ cho sản phẩm " + productId + ": " + inventoryDAO.getLastError());
                }
                
                // Trừ số lượng từ kho
                boolean stockSubtracted = inventoryDAO.subtractStock(productId, warehouse, quantity);
                
                if (!stockSubtracted) {
                    errorMsg.append("Lỗi khi xuất kho sản phẩm ID ").append(productId)
                            .append(": ").append(inventoryDAO.getLastError()).append(". ");
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
                        // Ignore if not a number
                    }
                }
                history.setNotes(notes);
                history.setCreatedBy(userId);
                
                inventoryDAO.addStockHistory(history);
            }
            
            if (allSuccess) {
                // Nếu có contractId, cập nhật trạng thái hợp đồng thành "active" (hiệu lực)
                String updateMessage = "Xuất kho thành công";
                if (contractIdParam != null && !contractIdParam.trim().isEmpty()) {
                    try {
                        int contractId = Integer.parseInt(contractIdParam.trim());
                        System.out.println("Attempting to update contract status for contract ID: " + contractId);
                        
                        // Kiểm tra hợp đồng có tồn tại không
                        Contract contract = contractDAO.getContractById(contractId);
                        if (contract != null) {
                            String currentStatus = contract.getStatus();
                            System.out.println("Contract ID " + contractId + " current status: " + currentStatus);
                            
                            // Cập nhật trạng thái hợp đồng thành "active" (hiệu lực) nếu đang là "draft"
                            if ("draft".equals(currentStatus)) {
                                boolean updated = contractDAO.updateContractStatus(contractId, "active");
                                if (updated) {
                                    updateMessage = "Xuất kho thành công. Hợp đồng đã được chuyển sang trạng thái hiệu lực.";
                                    System.out.println("Contract ID " + contractId + " status successfully updated to 'active'");
                                }
                            }
                            
                            // Đánh dấu các sản phẩm đã bàn giao (đã xuất kho)
                            try {
                                java.util.Properties props = new java.util.Properties();
                                java.io.InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties");
                                props.load(input);
                                
                                String url = props.getProperty("db.url");
                                String user = props.getProperty("db.username");
                                String pass = props.getProperty("db.password");
                                
                                try (java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, pass)) {
                                    // Parse JSON để lấy danh sách sản phẩm đã xuất (sử dụng biến productsJson đã có)
                                    if (productsJson != null && !productsJson.trim().isEmpty()) {
                                        org.json.JSONArray products = new org.json.JSONArray(productsJson);
                                        String updateDeliverySql = "UPDATE contract_products SET delivery_status = 'delivered' WHERE contract_id = ? AND product_id = ?";
                                        try (java.sql.PreparedStatement ps = conn.prepareStatement(updateDeliverySql)) {
                                            for (int i = 0; i < products.length(); i++) {
                                                try {
                                                    org.json.JSONObject product = products.getJSONObject(i);
                                                    int prodId = product.getInt("productId");
                                                    ps.setInt(1, contractId);
                                                    ps.setInt(2, prodId);
                                                    ps.executeUpdate();
                                                } catch (Exception e) {
                                                    System.out.println("Warning: Could not update delivery status for product: " + e.getMessage());
                                                }
                                            }
                                        }
                                    }
                                }
                            } catch (Exception e) {
                                System.out.println("Warning: Could not update delivery status: " + e.getMessage());
                            }
                        } else {
                            System.out.println("Error: Contract ID " + contractId + " not found in database");
                            updateMessage = "Xuất kho thành công. Cảnh báo: Không tìm thấy hợp đồng với ID " + contractId;
                        }
                    } catch (NumberFormatException e) {
                        System.out.println("Error: Invalid contractId format: " + contractIdParam);
                        updateMessage = "Xuất kho thành công. Cảnh báo: Mã hợp đồng không hợp lệ.";
                    } catch (Exception e) {
                        System.out.println("Error updating contract status: " + e.getMessage());
                        e.printStackTrace();
                        updateMessage = "Xuất kho thành công. Cảnh báo: Lỗi khi cập nhật trạng thái hợp đồng: " + e.getMessage();
                    }
                }
                
                response.getWriter().write("{\"success\":true,\"message\":\"" + 
                    escapeJson(updateMessage) + "\"}");
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
     * Lấy danh sách tồn kho cho trang stock.jsp
     * Hiển thị danh sách sản phẩm với tổng tồn kho (gộp tất cả các kho)
     * Filter được xử lý hoàn toàn bằng query ở backend
     */
    private void getStockList(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String category = request.getParameter("category");
            String status = request.getParameter("status");
            String keyword = request.getParameter("keyword");
            // Hỗ trợ cả "search" parameter để nhất quán với các trang khác
            if (keyword == null || keyword.isEmpty()) {
                keyword = request.getParameter("search");
            }
            
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
            
            List<Map<String, Object>> productsList = inventoryDAO.getProductsWithStock(
                category, keyword, status, page, pageSize);
            int totalCount = inventoryDAO.getProductsWithStockCount(
                category, keyword, status);
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":[");
            
            for (int i = 0; i < productsList.size(); i++) {
                if (i > 0) json.append(",");
                Map<String, Object> product = productsList.get(i);
                json.append("{");
                json.append("\"productId\":").append(product.get("productId")).append(",");
                json.append("\"productCode\":\"").append(escapeJson(product.get("productCode") != null ? product.get("productCode").toString() : "")).append("\",");
                json.append("\"productName\":\"").append(escapeJson(product.get("productName") != null ? product.get("productName").toString() : "")).append("\",");
                json.append("\"category\":\"").append(escapeJson(product.get("category") != null ? product.get("category").toString() : "")).append("\",");
                json.append("\"unit\":\"").append(escapeJson(product.get("unit") != null ? product.get("unit").toString() : "")).append("\",");
                json.append("\"totalStock\":").append(product.get("totalStock")).append(",");
                json.append("\"reservedStock\":").append(product.get("reservedStock")).append(",");
                json.append("\"availableStock\":").append(product.get("availableStock")).append(",");
                json.append("\"minStock\":").append(product.get("minStock")).append(",");
                Object maxStock = product.get("maxStock");
                json.append("\"maxStock\":").append(maxStock != null ? maxStock : "null").append(",");
                json.append("\"unitPrice\":").append(product.get("unitPrice")).append(",");
                json.append("\"imageUrl\":\"").append(escapeJson(product.get("imageUrl") != null ? product.get("imageUrl").toString() : "")).append("\"");
                json.append("}");
            }
            
            json.append("],\"pagination\":{");
            json.append("\"total\":").append(totalCount).append(",");
            json.append("\"currentPage\":").append(page).append(",");
            json.append("\"pageSize\":").append(pageSize).append(",");
            json.append("\"totalPages\":").append((int) Math.ceil((double) totalCount / pageSize)).append(",");
            int from = totalCount > 0 ? (page - 1) * pageSize + 1 : 0;
            int to = Math.min(page * pageSize, totalCount);
            json.append("\"from\":").append(from).append(",");
            json.append("\"to\":").append(to);
            json.append("}}");
            
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"" + 
                escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Lấy lịch sử tồn kho với tồn kho trước/sau mỗi giao dịch
     */
    private void getStockBalance(HttpServletRequest request, HttpServletResponse response) 
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
            String warehouse = request.getParameter("warehouse");
            String search = request.getParameter("q");
            String dateFrom = request.getParameter("dateFrom");
            String dateTo = request.getParameter("dateTo");

            // Pagination
            int page = 1; int pageSize = 10;
            if (request.getParameter("page") != null) { try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignore) {} }
            if (request.getParameter("pageSize") != null) { try { pageSize = Integer.parseInt(request.getParameter("pageSize")); } catch (Exception ignore) {} }

            List<Map<String, Object>> balanceList = inventoryDAO.getStockBalanceHistory(productId, warehouse, search, dateFrom, dateTo, page, pageSize);
            int totalCount = inventoryDAO.getStockBalanceHistoryCount(productId, warehouse, search, dateFrom, dateTo);

            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":[");

            for (int i = 0; i < balanceList.size(); i++) {
                if (i > 0) json.append(",");
                Map<String, Object> h = balanceList.get(i);
                json.append("{");
                json.append("\"id\":").append(h.get("id")).append(",");
                json.append("\"productId\":").append(h.get("productId")).append(",");
                json.append("\"productCode\":\"").append(escapeJson((String)h.get("productCode"))).append("\",");
                json.append("\"productName\":\"").append(escapeJson((String)h.get("productName"))).append("\",");
                json.append("\"movementType\":\"").append(escapeJson((String)h.get("movementType"))).append("\",");
                json.append("\"quantity\":").append(h.get("quantity")).append(",");
                json.append("\"stockBefore\":").append(h.get("stockBefore")).append(",");
                json.append("\"stockAfter\":").append(h.get("stockAfter")).append(",");
                json.append("\"warehouseLocation\":\"").append(escapeJson((String)h.get("warehouseLocation"))).append("\",");
                // Snapshot tồn kho hiện tại (theo thời điểm truy vấn)
                int currentStockNow = 0;
                int reservedStockNow = 0;
                int availableStockNow = 0;
                try {
                    Integer pid = (Integer) h.get("productId");
                    String wh = (String) h.get("warehouseLocation");
                    if (pid != null && wh != null) {
                        Inventory invNow = inventoryDAO.getInventoryByProductAndWarehouse(pid, wh);
                        if (invNow != null) {
                            currentStockNow = invNow.getCurrentStock();
                            reservedStockNow = invNow.getReservedQuantity();
                            availableStockNow = invNow.getAvailableStock();
                        }
                    }
                } catch (Exception ignore) {}
                json.append("\"currentStock\":").append(currentStockNow).append(",");
                json.append("\"reservedStock\":").append(reservedStockNow).append(",");
                json.append("\"availableStock\":").append(availableStockNow).append(",");
                json.append("\"createdAt\":\"").append(h.get("createdAt")).append("\",");
                json.append("\"createdByName\":\"").append(escapeJson((String)h.get("createdByName"))).append("\"");
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
     * Lấy chi tiết hợp đồng với danh sách sản phẩm và kiểm tra số lượng trong kho
     * Tác giả: Sơn Lê
     */
    private void getContractDetails(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String contractIdParam = request.getParameter("contractId");
            if (contractIdParam == null || contractIdParam.trim().isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Thiếu contractId\"}");
                return;
            }
            
            int contractId = Integer.parseInt(contractIdParam);
            Contract contract = contractDAO.getContractById(contractId);
            
            if (contract == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy hợp đồng\"}");
                return;
            }
            
            // Lấy danh sách sản phẩm trong hợp đồng
            java.util.List<java.util.Map<String, Object>> contractProducts = contractDAO.getContractProducts(contractId);
            
            // Kiểm tra số lượng trong kho cho từng sản phẩm
            java.util.List<java.util.Map<String, Object>> productsWithStock = new java.util.ArrayList<>();
            boolean allProductsAvailable = true;
            
            for (java.util.Map<String, Object> product : contractProducts) {
                int productId = (Integer) product.get("productId");
                java.math.BigDecimal requiredQuantity = (java.math.BigDecimal) product.get("quantity");
                int requiredQty = requiredQuantity.intValue();
                
                // Lấy tổng số lượng tồn kho của sản phẩm
                int totalStock = inventoryDAO.getTotalStock(productId);
                int reservedStock = inventoryDAO.getReservedStock(productId);
                int availableStock = inventoryDAO.getAvailableStock(productId);
                
                java.util.Map<String, Object> productWithStock = new java.util.HashMap<>(product);
                productWithStock.put("totalStock", totalStock);
                productWithStock.put("reservedStock", reservedStock);
                productWithStock.put("availableStock", availableStock);
                productWithStock.put("available", availableStock >= requiredQty);
                
                if (availableStock < requiredQty) {
                    allProductsAvailable = false;
                }
                
                productsWithStock.add(productWithStock);
            }
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"data\":{");
            json.append("\"contractId\":").append(contract.getId()).append(",");
            json.append("\"contractNumber\":\"").append(escapeJson(contract.getContractNumber())).append("\",");
            json.append("\"customerName\":\"").append(escapeJson(contract.getCustomerName() != null ? contract.getCustomerName() : "")).append("\",");
            json.append("\"status\":\"").append(escapeJson(contract.getStatus() != null ? contract.getStatus() : "")).append("\",");
            json.append("\"allProductsAvailable\":").append(allProductsAvailable).append(",");
            json.append("\"products\":[");
            
            for (int i = 0; i < productsWithStock.size(); i++) {
                if (i > 0) json.append(",");
                java.util.Map<String, Object> p = productsWithStock.get(i);
                json.append("{");
                json.append("\"productId\":").append(p.get("productId")).append(",");
                json.append("\"productCode\":\"").append(escapeJson((String)p.get("productCode"))).append("\",");
                json.append("\"productName\":\"").append(escapeJson((String)p.get("productName"))).append("\",");
                json.append("\"unit\":\"").append(escapeJson((String)p.get("unit"))).append("\",");
                json.append("\"quantity\":").append(p.get("quantity")).append(",");
                json.append("\"totalStock\":").append(p.get("totalStock")).append(",");
                json.append("\"reservedStock\":").append(p.get("reservedStock")).append(",");
                json.append("\"availableStock\":").append(p.get("availableStock")).append(",");
                json.append("\"available\":").append(p.get("available"));
                json.append("}");
            }
            
            json.append("]}}");
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"" + 
                escapeJson(e.getMessage()) + "\"}");
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

    private Set<String> getUserPermissions(HttpSession session) {
        Object permObj = session.getAttribute("userPermissions");
        if (permObj instanceof Set<?>) {
            Set<?> raw = (Set<?>) permObj;
            Set<String> perms = new HashSet<String>();
            for (Object item : raw) {
                if (item != null) {
                    perms.add(item.toString());
                }
            }
            return perms;
        }
        return new HashSet<String>();
    }

    private boolean hasPermission(Set<String> permissions, String permissionKey) {
        return permissions != null && permissionKey != null && permissions.contains(permissionKey);
    }

    private boolean isInventoryRole(String role) {
        if (role == null) {
            return false;
        }
        String normalized = role.trim().toLowerCase();
        return "admin".equals(normalized) || "storekeeper".equals(normalized);
    }
}

