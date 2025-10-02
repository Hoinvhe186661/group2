package com.hlgenerator.servlet;

import com.hlgenerator.dao.ProductDAO;
import com.hlgenerator.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URL;

@WebServlet("/addProduct")
public class AddProductServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/products.jsp");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            // Validate và lấy dữ liệu từ form
            ValidationResult validation = validateFormData(request);
            if (!validation.isValid()) {
                redirectWithError(request, response, "validation_error", validation.getErrorMessage());
                return;
            }
            
            // Xử lý URL ảnh
            String imageUrl = handleImageUrl(request);
            
            // Tạo Product object
            Product product = createProductFromRequest(request, imageUrl);
            
            // Lưu vào database
            ProductDAO dao = new ProductDAO();
            boolean success = dao.addProduct(product);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/products.jsp?message=success");
            } else {
                handleDatabaseError(request, response, dao);
            }
            
        } catch (Exception e) {
            System.err.println("Error in AddProductServlet: " + e.getMessage());
            e.printStackTrace();
            redirectWithError(request, response, "system_error", "Lỗi hệ thống: " + e.getMessage());
        }
    }
    
    private ValidationResult validateFormData(HttpServletRequest request) {
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
        
        // Validate warranty months if provided
        String warrantyStr = request.getParameter("warranty_months");
        if (!isEmpty(warrantyStr)) {
            try {
                int warranty = Integer.parseInt(warrantyStr.trim());
                if (warranty < 0) {
                    errors.append("Thời gian bảo hành phải lớn hơn hoặc bằng 0. ");
                }
            } catch (NumberFormatException e) {
                errors.append("Thời gian bảo hành phải là số nguyên hợp lệ. ");
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
    
    private Product createProductFromRequest(HttpServletRequest request, String imageUrl) {
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
            
    private void handleDatabaseError(HttpServletRequest request, HttpServletResponse response, ProductDAO dao) throws IOException {
                String dbError = dao.getLastError();
                String errorMsg;
        
                if (dbError != null && !dbError.isEmpty()) {
                    if (dbError.contains("Duplicate entry")) {
                errorMsg = "Mã sản phẩm đã tồn tại trong hệ thống!";
                    } else if (dbError.contains("foreign key constraint")) {
                errorMsg = "Nhà cung cấp không tồn tại trong hệ thống!";
                    } else if (dbError.contains("Connection")) {
                errorMsg = "Lỗi kết nối database. Vui lòng thử lại sau!";
                    } else {
                errorMsg = "Lỗi database: " + dbError;
                    }
                } else {
            errorMsg = "Không thể thêm sản phẩm. Vui lòng kiểm tra lại thông tin!";
        }
        
        redirectWithError(request, response, "database_error", errorMsg);
    }
    
    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, 
                                 String errorType, String errorMessage) throws IOException {
        String encodedMsg = java.net.URLEncoder.encode(errorMessage, "UTF-8");
        response.sendRedirect(request.getContextPath() + "/products.jsp?" + errorType + "=" + encodedMsg);
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
}