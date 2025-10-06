package com.hlgenerator.servlet;

import com.hlgenerator.dao.ProductDAO;
import com.hlgenerator.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URL;
import java.util.List;

@WebServlet("/product")
public class ProductServlet extends HttpServlet {
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("view".equals(action)) {
            viewProduct(request, response);
        } else if ("page".equals(action) || action == null) {
            // Hiển thị trang quản lý sản phẩm
            showProductsPage(request, response);
        } else {
            getAllProducts(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        System.out.println("=== DOPOST DEBUG ===");
        System.out.println("Received action: '" + action + "'");
        System.out.println("Content-Type: " + request.getContentType());
        
        if ("add".equals(action)) {
            addProduct(request, response);
        } else if ("update".equals(action)) {
            updateProduct(request, response);
        } else if ("delete".equals(action)) {
            deleteProduct(request, response);
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\": false, \"message\": \"Invalid action\"}");
        }
    }
    
    private void getAllProducts(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            List<Product> products = productDAO.getAllProducts();
            // Convert to JSON manually or use a JSON library
            out.write("{\"success\": true, \"products\": [");
            for (int i = 0; i < products.size(); i++) {
                Product p = products.get(i);
                if (i > 0) out.write(",");
                out.write(String.format(
                    "{\"id\": %d, \"productCode\": \"%s\", \"productName\": \"%s\", \"category\": \"%s\", \"unitPrice\": %.2f}",
                    p.getId(), p.getProductCode(), p.getProductName(), p.getCategory(), p.getUnitPrice()
                ));
            }
            out.write("]}");
        } catch (Exception e) {
            out.write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
    
    private void viewProduct(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                out.write("{\"success\": false, \"message\": \"ID sản phẩm không được để trống\"}");
                return;
            }
            
            int id = Integer.parseInt(idParam.trim());
            System.out.println("=== VIEW PRODUCT DEBUG ===");
            System.out.println("Product ID: " + id);
            
            Product product = productDAO.getProductById(id);
            System.out.println("Product found: " + (product != null));
            
            if (product != null) {
                String json = String.format(
                    "{\"success\": true, \"product\": {" +
                    "\"id\": %d, \"productCode\": \"%s\", \"productName\": \"%s\", " +
                    "\"category\": \"%s\", \"description\": \"%s\", \"unit\": \"%s\", " +
                    "\"unitPrice\": %.2f, \"supplierId\": %d, \"specifications\": \"%s\", " +
                    "\"imageUrl\": \"%s\", \"warrantyMonths\": %d, \"status\": \"%s\"}}",
                    product.getId(), 
                    escapeJson(product.getProductCode()),
                    escapeJson(product.getProductName()),
                    escapeJson(product.getCategory()),
                    escapeJson(product.getDescription()),
                    escapeJson(product.getUnit()),
                    product.getUnitPrice(),
                    product.getSupplierId(),
                    escapeJson(product.getSpecifications()),
                    escapeJson(product.getImageUrl()),
                    product.getWarrantyMonths(),
                    escapeJson(product.getStatus())
                );
                System.out.println("JSON Response: " + json);
                out.write(json);
            } else {
                out.write("{\"success\": false, \"message\": \"Không tìm thấy sản phẩm với ID: " + id + "\"}");
            }
        } catch (NumberFormatException e) {
            out.write("{\"success\": false, \"message\": \"ID sản phẩm phải là số nguyên hợp lệ\"}");
        } catch (Exception e) {
            System.err.println("Error in viewProduct: " + e.getMessage());
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"Lỗi máy chủ: " + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    private void updateProduct(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            System.out.println("=== UPDATE PRODUCT DEBUG ===");
            System.out.println("Action: " + request.getParameter("action"));
            System.out.println("ID: " + request.getParameter("id"));
            System.out.println("Product Code: " + request.getParameter("product_code"));
            System.out.println("Product Name: " + request.getParameter("product_name"));
            
            // Validate và lấy dữ liệu từ form
            ValidationResult validation = validateUpdateData(request);
            if (!validation.isValid()) {
                out.write("{\"success\": false, \"message\": \"" + escapeJson(validation.getErrorMessage()) + "\"}");
                return;
            }
            
            // Xử lý URL ảnh
            String imageUrl = handleImageUrl(request);
            System.out.println("Image URL: " + imageUrl);
            
            // Tạo Product object
            Product product = createProductFromUpdateRequest(request, imageUrl);
            System.out.println("Product created with ID: " + product.getId());
            
            // Cập nhật trong database
            boolean success = productDAO.updateProduct(product);
            System.out.println("Update success: " + success);
            
            if (success) {
                out.write("{\"success\": true, \"message\": \"Cập nhật sản phẩm thành công\"}");
            } else {
                String dbError = productDAO.getLastError();
                String errorMsg = dbError != null ? dbError : "Không thể cập nhật sản phẩm";
                System.out.println("Database error: " + errorMsg);
                out.write("{\"success\": false, \"message\": \"" + escapeJson(errorMsg) + "\"}");
            }
            
        } catch (Exception e) {
            System.err.println("Error in updateProduct: " + e.getMessage());
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"Lỗi máy chủ: " + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    private void addProduct(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            System.out.println("=== ADD PRODUCT DEBUG ===");
            System.out.println("Action: " + request.getParameter("action"));
            System.out.println("Product Code: " + request.getParameter("product_code"));
            System.out.println("Product Name: " + request.getParameter("product_name"));
            
            // Validate và lấy dữ liệu từ form
            ValidationResult validation = validateAddData(request);
            if (!validation.isValid()) {
                out.write("{\"success\": false, \"message\": \"" + escapeJson(validation.getErrorMessage()) + "\"}");
                return;
            }
            
            // Xử lý URL ảnh
            String imageUrl = handleImageUrl(request);
            System.out.println("Image URL: " + imageUrl);
            
            // Tạo Product object
            Product product = createProductFromAddRequest(request, imageUrl);
            System.out.println("Product created");
            
            // Thêm vào database
            boolean success = productDAO.addProduct(product);
            System.out.println("Add success: " + success);
            
            if (success) {
                out.write("{\"success\": true, \"message\": \"Thêm sản phẩm thành công\"}");
            } else {
                String dbError = productDAO.getLastError();
                String errorMsg = dbError != null ? dbError : "Không thể thêm sản phẩm";
                System.out.println("Database error: " + errorMsg);
                out.write("{\"success\": false, \"message\": \"" + escapeJson(errorMsg) + "\"}");
            }
            
        } catch (Exception e) {
            System.err.println("Error in addProduct: " + e.getMessage());
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"Lỗi máy chủ: " + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    private void deleteProduct(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success = productDAO.deleteProduct(id);
            
            if (success) {
                out.write("{\"success\": true, \"message\": \"Product deleted successfully\"}");
            } else {
                out.write("{\"success\": false, \"message\": \"Failed to delete product\"}");
            }
        } catch (Exception e) {
            out.write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
    
    private ValidationResult validateUpdateData(HttpServletRequest request) {
        StringBuilder errors = new StringBuilder();
        
        String productCode = request.getParameter("product_code");
        String productName = request.getParameter("product_name");
        String category = request.getParameter("category");
        String unit = request.getParameter("unit");
        String unitPriceStr = request.getParameter("unit_price");
        String supplierIdStr = request.getParameter("supplier_id");
        String idStr = request.getParameter("id");
        
        // Validate ID
        if (isEmpty(idStr)) {
            errors.append("ID sản phẩm không được để trống. ");
        } else {
            try {
                int id = Integer.parseInt(idStr.trim());
                if (id <= 0) {
                    errors.append("ID sản phẩm phải lớn hơn 0. ");
                }
            } catch (NumberFormatException e) {
                errors.append("ID sản phẩm phải là số nguyên hợp lệ. ");
            }
        }
        
        // Validate required fields
        if (isEmpty(productCode)) {
            errors.append("Mã sản phẩm không được để trống. ");
        }
        if (isEmpty(productName)) {
            errors.append("Tên sản phẩm không được để trống. ");
        }
        if (isEmpty(category)) {
            errors.append("Danh mục không được để trống. ");
        }
        if (isEmpty(unit)) {
            errors.append("Đơn vị tính không được để trống. ");
        }
        
        // Validate unit price
        if (isEmpty(unitPriceStr)) {
            errors.append("Giá sản phẩm không được để trống. ");
        } else {
            try {
                double price = Double.parseDouble(unitPriceStr.trim());
                if (price < 0) {
                    errors.append("Giá sản phẩm phải lớn hơn hoặc bằng 0. ");
                }
            } catch (NumberFormatException e) {
                errors.append("Giá sản phẩm phải là số hợp lệ. ");
            }
        }
        
        // Validate supplier ID
        if (isEmpty(supplierIdStr)) {
            errors.append("Nhà cung cấp không được để trống. ");
        } else {
            try {
                int supplierId = Integer.parseInt(supplierIdStr.trim());
                if (supplierId <= 0) {
                    errors.append("ID nhà cung cấp phải lớn hơn 0. ");
                }
            } catch (NumberFormatException e) {
                errors.append("ID nhà cung cấp phải là số nguyên hợp lệ. ");
            }
        }
        
        return new ValidationResult(errors.length() == 0, errors.toString());
    }
    
    private String handleImageUrl(HttpServletRequest request) {
        String imageUrl = request.getParameter("image_url");
        
        // Nếu không có URL ảnh, sử dụng ảnh mặc định
        if (isEmpty(imageUrl)) {
            return request.getContextPath() + "/images/sanpham1.jpg";
        }
        
        // Validate URL format
        imageUrl = imageUrl.trim();
        if (!isValidImageUrl(imageUrl)) {
            // Nếu URL không hợp lệ, sử dụng ảnh mặc định
            return request.getContextPath() + "/images/sanpham1.jpg";
        }
        
        return imageUrl;
    }
    
    private boolean isValidImageUrl(String url) {
        try {
            // Kiểm tra format URL cơ bản
            new URL(url);
            
            // Kiểm tra extension ảnh
            String lowerUrl = url.toLowerCase();
            return lowerUrl.endsWith(".jpg") || lowerUrl.endsWith(".jpeg") || 
                   lowerUrl.endsWith(".png") || lowerUrl.endsWith(".gif") || 
                   lowerUrl.endsWith(".webp") || lowerUrl.contains("image") ||
                   lowerUrl.contains("photo") || lowerUrl.contains("picture");
                   
        } catch (Exception e) {
            return false;
        }
    }
    
    private Product createProductFromUpdateRequest(HttpServletRequest request, String imageUrl) {
        int id = Integer.parseInt(request.getParameter("id").trim());
        String productCode = request.getParameter("product_code").trim();
        String productName = request.getParameter("product_name").trim();
        String category = request.getParameter("category").trim();
        String unit = request.getParameter("unit").trim();
        String description = getParameterOrDefault(request, "description", "");
        double unitPrice = Double.parseDouble(request.getParameter("unit_price").trim());
        int supplierId = Integer.parseInt(request.getParameter("supplier_id").trim());
        String specifications = getParameterOrDefault(request, "specifications", "");
        int warrantyMonths = getIntParameterOrDefault(request, "warranty_months", 12);
        String status = getParameterOrDefault(request, "status", "active");
        
        Product product = new Product(productCode, productName, category, unit, description, 
                                    unitPrice, supplierId, specifications, imageUrl, warrantyMonths, status);
        product.setId(id);
        return product;
    }
    
    private boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }
    
    private String getParameterOrDefault(HttpServletRequest request, String paramName, String defaultValue) {
        String value = request.getParameter(paramName);
        return isEmpty(value) ? defaultValue : value.trim();
    }
    
    private int getIntParameterOrDefault(HttpServletRequest request, String paramName, int defaultValue) {
        String value = request.getParameter(paramName);
        if (isEmpty(value)) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
    
    private ValidationResult validateAddData(HttpServletRequest request) {
        StringBuilder errors = new StringBuilder();
        
        String productCode = request.getParameter("product_code");
        String productName = request.getParameter("product_name");
        String category = request.getParameter("category");
        String unit = request.getParameter("unit");
        String unitPriceStr = request.getParameter("unit_price");
        String supplierIdStr = request.getParameter("supplier_id");
        
        // Validate required fields
        if (isEmpty(productCode)) {
            errors.append("Mã sản phẩm không được để trống. ");
        }
        if (isEmpty(productName)) {
            errors.append("Tên sản phẩm không được để trống. ");
        }
        if (isEmpty(category)) {
            errors.append("Danh mục không được để trống. ");
        }
        if (isEmpty(unit)) {
            errors.append("Đơn vị không được để trống. ");
        }
        if (isEmpty(unitPriceStr)) {
            errors.append("Giá sản phẩm không được để trống. ");
        } else {
            try {
                double unitPrice = Double.parseDouble(unitPriceStr.trim());
                if (unitPrice < 0) {
                    errors.append("Giá sản phẩm phải lớn hơn hoặc bằng 0. ");
                }
            } catch (NumberFormatException e) {
                errors.append("Giá sản phẩm phải là số hợp lệ. ");
            }
        }
        if (isEmpty(supplierIdStr)) {
            errors.append("Nhà cung cấp không được để trống. ");
        } else {
            try {
                int supplierId = Integer.parseInt(supplierIdStr.trim());
                if (supplierId <= 0) {
                    errors.append("Nhà cung cấp phải là số nguyên dương. ");
                }
            } catch (NumberFormatException e) {
                errors.append("Nhà cung cấp phải là số nguyên hợp lệ. ");
            }
        }
        
        return new ValidationResult(errors.length() == 0, errors.toString());
    }
    
    private Product createProductFromAddRequest(HttpServletRequest request, String imageUrl) {
        String productCode = request.getParameter("product_code").trim();
        String productName = request.getParameter("product_name").trim();
        String category = request.getParameter("category").trim();
        String unit = request.getParameter("unit").trim();
        String description = getParameterOrDefault(request, "description", "");
        double unitPrice = Double.parseDouble(request.getParameter("unit_price").trim());
        int supplierId = Integer.parseInt(request.getParameter("supplier_id").trim());
        String specifications = getParameterOrDefault(request, "specifications", "");
        int warrantyMonths = getIntParameterOrDefault(request, "warranty_months", 12);
        String status = getParameterOrDefault(request, "status", "active");
        
        return new Product(productCode, productName, category, unit, description, 
                          unitPrice, supplierId, specifications, imageUrl, warrantyMonths, status);
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
    
    // Inner class for validation result
    private static class ValidationResult {
        private final boolean valid;
        private final String errorMessage;
        
        public ValidationResult(boolean valid, String errorMessage) {
            this.valid = valid;
            this.errorMessage = errorMessage;
        }
        
        public boolean isValid() {
            return valid;
        }
        
        public String getErrorMessage() {
            return errorMessage;
        }
    }
    
    // Method để hiển thị trang quản lý sản phẩm
    private void showProductsPage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Lấy danh sách sản phẩm
            List<Product> products = productDAO.getAllProducts();
            request.setAttribute("products", products);
            
            // Lấy thống kê
            java.util.Map<String, Integer> stats = productDAO.getAllStatistics();
            request.setAttribute("stats", stats);
            
            // Lấy danh sách danh mục
            java.util.List<String> categories = productDAO.getAllCategories();
            request.setAttribute("categories", categories);
            
            // Forward đến trang JSP
            request.getRequestDispatcher("/products.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi tải dữ liệu sản phẩm: " + e.getMessage());
        }
    }
}