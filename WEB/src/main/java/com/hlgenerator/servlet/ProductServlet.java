package com.hlgenerator.servlet;

import com.hlgenerator.dao.ProductDAO;
import com.hlgenerator.dao.PriceHistoryDAO;
import com.hlgenerator.model.PriceHistory;
import com.hlgenerator.dao.SupplierDAO;
import com.hlgenerator.model.Product;
import com.hlgenerator.model.Supplier;
import com.hlgenerator.util.AuthorizationUtil;
import com.hlgenerator.util.Permission;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.net.URL;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FilenameUtils;

@WebServlet({"/product", "/product.jsp"})
public class ProductServlet extends HttpServlet {
    private ProductDAO productDAO;
    private PriceHistoryDAO priceHistoryDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        productDAO = new ProductDAO();
        priceHistoryDAO = new PriceHistoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Thiết lập encoding UTF-8 TRƯỚC KHI đọc parameters
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // Check authentication and authorization for view operations
        String action = request.getParameter("action");
        if (action != null && !"view".equals(action) && !"priceHistory".equals(action)) {
            // For management operations, require login and view permission at minimum
            if (!AuthorizationUtil.isLoggedIn(request)) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }
            if (!AuthorizationUtil.hasAnyPermission(request, Permission.MANAGE_PRODUCTS, Permission.VIEW_PRODUCTS)) {
                response.sendRedirect(request.getContextPath() + "/403.jsp");
                return;
            }
        }
        
        if ("view".equals(action)) {
            viewProduct(request, response);
        } else if ("priceHistory".equals(action)) {
            getPriceHistory(request, response);
        } else if ("page".equals(action) || action == null) {
            showProductsPage(request, response);
        } else if ("edit".equals(action)) {
            showEditProductPage(request, response);
        } else if ("add".equals(action)) {
            showAddProductPage(request, response);
        } else if ("filter".equals(action)) {
            filterProducts(request, response);
        } else if ("checkCode".equals(action)) {
            checkProductCodeExists(request, response);
        } else if ("generateCode".equals(action)) {
            generateProductCode(request, response);
        } else if ("jsp".equals(action)) {
            // Xử lý request từ /product.jsp
            showProductsPage(request, response);
        } else {
            getAllProducts(request, response);
        }
    }
    
    /**
     * Hiển thị trang quản lý sản phẩm với tất cả dữ liệu cần thiết
     */
    private void showProductsPage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Lấy danh sách sản phẩm
            List<Product> products = productDAO.getAllProducts();
            
            
            // Lấy danh sách nhà cung cấp cho dropdown
            com.hlgenerator.dao.SupplierDAO supplierDAO = new com.hlgenerator.dao.SupplierDAO();
            List<com.hlgenerator.model.Supplier> suppliers = supplierDAO.getAllSuppliers();
            
            
            // Lấy thống kê sản phẩm
            Map<String, Integer> statistics = productDAO.getAllStatistics();
            
            // Chỉ sử dụng 3 danh mục cố định
            List<String> categories = getFixedCategories();
            
            // Set attributes cho JSP
            request.setAttribute("products", products);
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("statistics", statistics);
            request.setAttribute("categories", categories);
            
            
            // Forward to JSP
            request.getRequestDispatcher("/products.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/products.jsp").forward(request, response);
        }
    }
    
    /**
     * Hiển thị trang thêm sản phẩm với dữ liệu cần thiết
     */
    private void showAddProductPage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Lấy danh sách nhà cung cấp
            com.hlgenerator.dao.SupplierDAO supplierDAO = new com.hlgenerator.dao.SupplierDAO();
            List<com.hlgenerator.model.Supplier> suppliers = supplierDAO.getAllSuppliers();
            
            // Chỉ sử dụng 3 danh mục cố định
            List<String> categories = getFixedCategories();
            
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("categories", categories);
            request.setAttribute("action", "add");
            
            request.getRequestDispatcher("/products.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/products.jsp").forward(request, response);
        }
    }
    
    /**
     * Hiển thị trang sửa sản phẩm với dữ liệu cần thiết
     */
    private void showEditProductPage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int productId = Integer.parseInt(request.getParameter("id"));
            
            // Lấy thông tin sản phẩm
            Product product = productDAO.getProductById(productId);
            if (product == null) {
                request.setAttribute("error", "Không tìm thấy sản phẩm");
                request.getRequestDispatcher("/products.jsp").forward(request, response);
                return;
            }
            
            // Lấy danh sách nhà cung cấp
            com.hlgenerator.dao.SupplierDAO supplierDAO = new com.hlgenerator.dao.SupplierDAO();
            List<com.hlgenerator.model.Supplier> suppliers = supplierDAO.getAllSuppliers();
            
            // Chỉ sử dụng 3 danh mục cố định
            List<String> categories = getFixedCategories();
            
            request.setAttribute("product", product);
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("categories", categories);
            request.setAttribute("action", "edit");
            
            request.getRequestDispatcher("/products.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/products.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        
        // Check authentication and authorization for management operations
        if (!AuthorizationUtil.isLoggedIn(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\": false, \"message\": \"Chưa đăng nhập\"}");
            return;
        }
        
        if (!AuthorizationUtil.hasPermission(request, Permission.MANAGE_PRODUCTS)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"success\": false, \"message\": \"Không có quyền thực hiện\"}");
            return;
        }
        
        // Kiểm tra xem request có phải là multipart form data không
        if (ServletFileUpload.isMultipartContent(request)) {
            handleMultipartRequest(request, response);
        } else {
            // Xử lý request thông thường (không có file upload)
            String action = request.getParameter("action");
            System.out.println("DEBUG");
            System.out.println("Received action: '" + action + "'");
            System.out.println("Content-Type: " + request.getContentType());
            
            if ("delete".equals(action)) {
                deleteProduct(request, response);
            } else if ("hide".equals(action)) {
                hideProduct(request, response);
            } else if ("show".equals(action)) {
                showProduct(request, response);
            } else if ("updatePrice".equals(action)) {
                updateSellingPrice(request, response);
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid action or missing multipart data\"}");
            }
        }
    }

    private void handleMultipartRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Tạo factory và upload handler
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            
            // Parse request
            List<FileItem> items = upload.parseRequest(request);
            
            String action = null;
            String imageUrl = null;
            Product product = new Product();
            
            // Xử lý từng item
            for (FileItem item : items) {
                if (item.isFormField()) {
                    // Xử lý form field thông thường
                    String fieldName = item.getFieldName();
                    String fieldValue = item.getString("UTF-8");
                    
                    System.out.println("Field: " + fieldName + " = " + fieldValue);
                    
                    switch (fieldName) {
                        case "action":
                            action = fieldValue;
                            break;
                        case "id":
                            if (fieldValue != null && !fieldValue.trim().isEmpty()) {
                                product.setId(Integer.parseInt(fieldValue));
                            }
                            break;
                        case "product_code":
                            product.setProductCode(fieldValue);
                            break;
                        case "product_name":
                            product.setProductName(fieldValue);
                            break;
                        case "category":
                            product.setCategory(fieldValue);
                            break;
                        case "description":
                            product.setDescription(fieldValue);
                            break;
                        case "unit":
                            product.setUnit(fieldValue);
                            break;
                        case "unit_price":
                            if (fieldValue != null && !fieldValue.trim().isEmpty()) {
                                product.setUnitPrice(Double.parseDouble(fieldValue));
                            }
                            break;
                        case "supplier_id":
                            if (fieldValue != null && !fieldValue.trim().isEmpty()) {
                                product.setSupplierId(Integer.parseInt(fieldValue));
                            }
                            break;
                        case "specifications":
                            product.setSpecifications(fieldValue);
                            break;
                        case "warranty_months":
                            if (fieldValue != null && !fieldValue.trim().isEmpty()) {
                                product.setWarrantyMonths(Integer.parseInt(fieldValue));
                            }
                            break;
                        case "status":
                            product.setStatus(fieldValue);
                            break;
                    }
                } else {
                    // Xử lý file upload
                    if ("product_image".equals(item.getFieldName()) && !item.getName().isEmpty()) {
                        System.out.println("Processing file upload: " + item.getName());
                        imageUrl = handleFileUpload(item, request);
                        System.out.println("Image URL generated: " + imageUrl);
                    }
                }
            }
            
            // Set image URL nếu có
            if (imageUrl != null) {
                product.setImageUrl(imageUrl);
                System.out.println("Image URL set to product: " + imageUrl);
            } else {
                System.out.println("No image URL to set");
            }
            
            // Debug log product object
            System.out.println("=== PRODUCT OBJECT DEBUG ===");
            System.out.println("Product Code: " + product.getProductCode());
            System.out.println("Product Name: " + product.getProductName());
            System.out.println("Category: " + product.getCategory());
            System.out.println("Unit: " + product.getUnit());
            System.out.println("Unit Price: " + product.getUnitPrice());
            System.out.println("Supplier ID: " + product.getSupplierId());
            System.out.println("Image URL: " + product.getImageUrl());
            System.out.println("Warranty Months: " + product.getWarrantyMonths());
            System.out.println("Status: " + product.getStatus());
            System.out.println("Description: " + product.getDescription());
            System.out.println("Specifications: " + product.getSpecifications());
            
            // Validate số từ của mô tả và thông số kỹ thuật
            String description = product.getDescription();
            String specifications = product.getSpecifications();
            StringBuilder validationErrors = new StringBuilder();
            
            if (description != null && !description.trim().isEmpty()) {
                int descriptionWordCount = countWords(description);
                if (descriptionWordCount > 150) {
                    validationErrors.append("Mô tả không được vượt quá 150 từ. Hiện tại: ").append(descriptionWordCount).append(" từ. ");
                }
            }
            
            if (specifications != null && !specifications.trim().isEmpty()) {
                int specificationsWordCount = countWords(specifications);
                if (specificationsWordCount > 150) {
                    validationErrors.append("Thông số kỹ thuật không được vượt quá 150 từ. Hiện tại: ").append(specificationsWordCount).append(" từ. ");
                }
            }
            
            if (validationErrors.length() > 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"" + escapeJson(validationErrors.toString()) + "\"}");
                return;
            }
            
            // Xử lý action
            System.out.println("Action received: " + action);
            if ("add".equals(action)) {
                addProductWithFile(product, response);
            } else if ("update".equals(action)) {
                updateProductWithFile(product, response);
            } else {
                System.out.println("Invalid action: " + action);
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid action: " + action + "\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Error processing request: " + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Xử lý upload file và trả về đường dẫn file
     */
    private String handleFileUpload(FileItem fileItem, HttpServletRequest request) throws Exception {
        // Kiểm tra file có tồn tại không
        if (fileItem.getName() == null || fileItem.getName().trim().isEmpty()) {
            return null;
        }
        
        // Kiểm tra kích thước file (5MB)
        if (fileItem.getSize() > 5 * 1024 * 1024) {
            throw new Exception("File size too large. Maximum size is 5MB.");
        }
        
        // Kiểm tra định dạng file
        String fileName = fileItem.getName();
        String extension = FilenameUtils.getExtension(fileName).toLowerCase();
        if (!extension.matches("jpg|jpeg|png|gif")) {
            throw new Exception("Invalid file format. Only JPG, PNG, GIF.");
        }
        
        // Tạo tên file unique
        String uniqueFileName = UUID.randomUUID().toString() + "." + extension;
        
        // Đường dẫn thư mục upload
        String uploadPath = request.getServletContext().getRealPath("/uploads/products/");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        // Lưu file
        File uploadedFile = new File(uploadDir, uniqueFileName);
        fileItem.write(uploadedFile);
        
        // Trả về đường dẫn relative
        return "uploads/products/" + uniqueFileName;
    }
    
    /**
     * Thêm sản phẩm mới với file upload
     */
    private void addProductWithFile(Product product, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            System.out.println("=== ADD PRODUCT WITH FILE DEBUG ===");
            System.out.println("Product Code: " + product.getProductCode());
            System.out.println("Product Name: " + product.getProductName());
            System.out.println("Category: " + product.getCategory());
            System.out.println("Unit: " + product.getUnit());
            System.out.println("Unit Price: " + product.getUnitPrice());
            System.out.println("Supplier ID: " + product.getSupplierId());
            System.out.println("Image URL: " + product.getImageUrl());
            System.out.println("Warranty Months: " + product.getWarrantyMonths());
            System.out.println("Status: " + product.getStatus());
            System.out.println("Description: " + product.getDescription());
            System.out.println("Specifications: " + product.getSpecifications());
            
            // Tự động tạo mã sản phẩm nếu không có hoặc để trống
            if (product.getProductCode() == null || product.getProductCode().trim().isEmpty()) {
                String generatedCode = productDAO.generateNextProductCode();
                if (generatedCode != null) {
                    product.setProductCode(generatedCode);
                    System.out.println("Auto-generated product code: " + generatedCode);
                } else {
                    out.write("{\"success\": false, \"message\": \"Không thể tạo mã sản phẩm tự động\"}");
                    return;
                }
            }
            
            // Kiểm tra trùng mã sản phẩm
            if (productDAO.isProductCodeExists(product.getProductCode())) {
                out.write("{\"success\": false, \"message\": \"Mã sản phẩm đã tồn tại trong hệ thống. Vui lòng chọn mã khác.\"}");
                return;
            }
            
            boolean success = productDAO.addProduct(product);
            
            if (success) {
                out.write("{\"success\": true, \"message\": \"Sản phẩm đã được thêm thành công\"}");
            } else {
                String error = productDAO.getLastError();
                // Kiểm tra nếu lỗi do trùng mã từ database constraint
                if (error != null && error.contains("Duplicate entry")) {
                    out.write("{\"success\": false, \"message\": \"Mã sản phẩm đã tồn tại trong hệ thống. Vui lòng chọn mã khác.\"}");
                } else {
                    out.write("{\"success\": false, \"message\": \"Lỗi khi thêm sản phẩm: " + escapeJson(error != null ? error : "Lỗi không xác định") + "\"}");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = e.getMessage();
            if (errorMsg != null && errorMsg.contains("Duplicate entry")) {
                out.write("{\"success\": false, \"message\": \"Mã sản phẩm đã tồn tại trong hệ thống. Vui lòng chọn mã khác.\"}");
            } else {
                out.write("{\"success\": false, \"message\": \"Lỗi hệ thống: " + escapeJson(errorMsg != null ? errorMsg : "Lỗi không xác định") + "\"}");
            }
        }
    }
    
    /**
     * Cập nhật sản phẩm với file upload
     */
    private void updateProductWithFile(Product product, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            System.out.println("=== UPDATE PRODUCT WITH FILE DEBUG ===");
            System.out.println("Product ID: " + product.getId());
            System.out.println("Product: " + product.getProductName());
            System.out.println("Image URL: " + product.getImageUrl());
            
            // Lấy sản phẩm hiện tại từ database
            Product existingProduct = productDAO.getProductById(product.getId());
            if (existingProduct == null) {
                out.write("{\"success\": false, \"message\": \"Không tìm thấy sản phẩm với ID: " + product.getId() + "\"}");
                return;
            }
            
            // Không cho phép thay đổi mã sản phẩm, danh mục và giá bán (giá cập nhật theo nhập kho)
            if (product.getProductCode() != null && !product.getProductCode().equals(existingProduct.getProductCode())) {
                out.write("{\"success\": false, \"message\": \"Không được phép thay đổi mã sản phẩm.\"}");
                return;
            }
            
            if (product.getCategory() != null && !product.getCategory().equals(existingProduct.getCategory())) {
                out.write("{\"success\": false, \"message\": \"Không được phép thay đổi danh mục sản phẩm.\"}");
                return;
            }
            
            // Khôi phục mã sản phẩm và danh mục từ sản phẩm hiện tại để đảm bảo không bị thay đổi
            product.setProductCode(existingProduct.getProductCode());
            product.setCategory(existingProduct.getCategory());
            // Khóa giá bán: luôn dùng giá hiện tại trong DB
            product.setUnitPrice(existingProduct.getUnitPrice());
            
            boolean success = productDAO.updateProduct(product);
            
            if (success) {
                out.write("{\"success\": true, \"message\": \"Sản phẩm đã được cập nhật thành công\"}");
            } else {
                String error = productDAO.getLastError();
                out.write("{\"success\": false, \"message\": \"Lỗi khi cập nhật sản phẩm: " + escapeJson(error != null ? error : "Lỗi không xác định") + "\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"Lỗi hệ thống: " + escapeJson(e.getMessage() != null ? e.getMessage() : "Lỗi không xác định") + "\"}");
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

    private void getPriceHistory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        java.io.PrintWriter out = response.getWriter();
        try {
            String productIdParam = request.getParameter("productId");
            if (productIdParam == null || productIdParam.trim().isEmpty()) {
                // Cho phép không truyền productId để xem tổng thể
                productIdParam = null;
            }
            Integer productId = null;
            if (productIdParam != null) {
                productId = Integer.parseInt(productIdParam.trim());
            }
            String type = request.getParameter("type"); // purchase|selling|null
            String q = request.getParameter("q");
            int page = 1; int pageSize = 10;
            String pageParam = request.getParameter("page");
            String pageSizeParam = request.getParameter("pageSize");
            if (pageParam != null && !pageParam.trim().isEmpty()) { try { page = Integer.parseInt(pageParam.trim()); } catch (Exception ignore) {} }
            if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) { try { pageSize = Integer.parseInt(pageSizeParam.trim()); } catch (Exception ignore) {} }

            java.util.List<PriceHistory> list = priceHistoryDAO.getFilteredPriceHistory(productId, type, q, page, pageSize);
            int countAll = priceHistoryDAO.getFilteredPriceHistoryCount(productId, type, q);

            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"totalCount\":").append(countAll)
                .append(",\"currentPage\":").append(page)
                .append(",\"pageSize\":").append(pageSize)
                .append(",\"totalPages\":").append((int)Math.ceil((double)countAll / (double)pageSize))
                .append(",\"data\":[");
            for (int i = 0; i < list.size(); i++) {
                if (i>0) json.append(",");
                PriceHistory h = list.get(i);
                json.append("{");
                json.append("\"id\":").append(h.getId()).append(",");
                json.append("\"priceType\":\"").append(escapeJson(h.getPriceType())).append("\",");
                json.append("\"oldPrice\":").append(h.getOldPrice()==null?"null":h.getOldPrice()).append(",");
                json.append("\"newPrice\":").append(h.getNewPrice()==null?"null":h.getNewPrice()).append(",");
                json.append("\"reason\":\"").append(escapeJson(h.getReason()==null?"":h.getReason())).append("\",");
                // Thêm tên/mã sản phẩm để UI hiển thị
                json.append("\"productName\":\"").append(escapeJson(h.getProductName()==null?"":h.getProductName())).append("\",");
                json.append("\"productCode\":\"").append(escapeJson(h.getProductCode()==null?"":h.getProductCode())).append("\",");
                json.append("\"updatedAt\":\"").append(h.getUpdatedAt()).append("\",");
                json.append("\"updatedByName\":\"").append(escapeJson(h.getUpdatedByName()==null?"":h.getUpdatedByName())).append("\"");
                json.append("}");
            }
            json.append("]}");
            out.write(json.toString());
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private void updateSellingPrice(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        java.io.PrintWriter out = response.getWriter();
        try {
            String productIdParam = request.getParameter("productId");
            String newPriceParam = request.getParameter("newPrice");
            String reason = request.getParameter("reason");
            if (productIdParam == null || newPriceParam == null) {
                out.write("{\"success\":false,\"message\":\"Thiếu tham số\"}");
                return;
            }
            int productId = Integer.parseInt(productIdParam.trim());
            double newPrice = Double.parseDouble(newPriceParam.trim());
            if (newPrice <= 0) {
                out.write("{\"success\":false,\"message\":\"Giá mới phải > 0\"}");
                return;
            }
            // Lấy old price
            Product p = productDAO.getProductById(productId);
            if (p == null) {
                out.write("{\"success\":false,\"message\":\"Không tìm thấy sản phẩm\"}");
                return;
            }
            double oldPrice = p.getUnitPrice();
            boolean changed = Math.abs(oldPrice - newPrice) > 1e-6;
            if (!changed) {
                out.write("{\"success\":true,\"message\":\"Giá bán không thay đổi\"}");
                return;
            }
            boolean ok = productDAO.updateUnitPrice(productId, newPrice);
            if (!ok) {
                out.write("{\"success\":false,\"message\":\"" + escapeJson(productDAO.getLastError()) + "\"}");
                return;
            }
            // Ghi lịch sử
            Integer userId = (Integer) request.getSession().getAttribute("userId");
            PriceHistory ph = new PriceHistory();
            ph.setProductId(productId);
            ph.setPriceType("selling");
            ph.setOldPrice(oldPrice);
            ph.setNewPrice(newPrice);
            ph.setReason(reason);
            ph.setReferenceType("manual_update");
            ph.setUpdatedBy(userId);
            try { priceHistoryDAO.insert(ph); } catch (Exception ignore) {}

            int totalSellingUpdates = priceHistoryDAO.countUpdates(productId, "selling", null);
            // Cho UI quyết định nếu là lần thứ 3
            out.write("{\"success\":true,\"message\":\"Cập nhật giá bán thành công\",\"totalSellingUpdates\":" + totalSellingUpdates + "}");
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\":false,\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
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
    
    /**
     * Ẩn sản phẩm (soft delete) - chuyển status thành 'discontinued'
     */
    private void hideProduct(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success = productDAO.hideProduct(id);
            
            if (success) {
                out.write("{\"success\": true, \"message\": \"Ẩn sản phẩm thành công\"}");
            } else {
                String error = productDAO.getLastError();
                out.write("{\"success\": false, \"message\": \"" + escapeJson(error != null ? error : "Không thể ẩn sản phẩm") + "\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"Lỗi: " + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Hiện lại sản phẩm - chuyển status thành 'active'
     */
    private void showProduct(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success = productDAO.showProduct(id);
            
            if (success) {
                out.write("{\"success\": true, \"message\": \"Hiện sản phẩm thành công\"}");
            } else {
                String error = productDAO.getLastError();
                out.write("{\"success\": false, \"message\": \"" + escapeJson(error != null ? error : "Không thể hiện sản phẩm") + "\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"Lỗi: " + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Đếm số từ trong một chuỗi văn bản
     * @param text - Chuỗi văn bản cần đếm
     * @return Số từ trong chuỗi
     */
    private int countWords(String text) {
        if (text == null || text.trim().isEmpty()) {
            return 0;
        }
        // Loại bỏ khoảng trắng thừa và đếm số từ
        String trimmed = text.trim().replaceAll("\\s+", " ");
        String[] words = trimmed.split("\\s+");
        // Lọc bỏ các phần tử rỗng
        int count = 0;
        for (String word : words) {
            if (word.length() > 0) {
                count++;
            }
        }
        return count;
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
        String description = request.getParameter("description");
        String specifications = request.getParameter("specifications");
        
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
        
        // Validate unit price (cho phép để trống; nếu nhập phải hợp lệ > 0)
        if (!isEmpty(unitPriceStr)) {
            try {
                double price = Double.parseDouble(unitPriceStr.trim());
                if (price <= 0) {
                    errors.append("Giá sản phẩm phải lớn hơn 0 khi nhập. ");
                } else if (price > 9999999999.99) {
                    errors.append("Giá sản phẩm không được vượt quá 9999,999,999.99 VNĐ. ");
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
        
        // Validate số từ của mô tả
        if (description != null && !description.trim().isEmpty()) {
            int descriptionWordCount = countWords(description);
            if (descriptionWordCount > 150) {
                errors.append("Mô tả không được vượt quá 150 từ. Hiện tại: " + descriptionWordCount + " từ. ");
            }
        }
        
        if (specifications != null && !specifications.trim().isEmpty()) {
            int specificationsWordCount = countWords(specifications);
            if (specificationsWordCount > 150) {
                errors.append("Thông số kỹ thuật không được vượt quá 150 từ. Hiện tại: " + specificationsWordCount + " từ. ");
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
        double unitPrice = 0;
        String unitPriceStr2 = request.getParameter("unit_price");
        if (!isEmpty(unitPriceStr2)) {
            try { unitPrice = Double.parseDouble(unitPriceStr2.trim()); } catch (NumberFormatException ignore) { unitPrice = 0; }
        }
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
        String description = request.getParameter("description");
        String specifications = request.getParameter("specifications");
        
        // Mã sản phẩm sẽ được tự động tạo nếu để trống (xử lý ở createProductFromAddRequest)
        // Chỉ kiểm tra trùng nếu có mã
        if (!isEmpty(productCode)) {
            // Kiểm tra trùng mã sản phẩm
            if (productDAO.isProductCodeExists(productCode)) {
                errors.append("Mã sản phẩm đã tồn tại trong hệ thống. Vui lòng chọn mã khác. ");
            }
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
        // Validate unit price (cho phép để trống; nếu nhập phải hợp lệ > 0)
        if (!isEmpty(unitPriceStr)) {
            try {
                double unitPrice = Double.parseDouble(unitPriceStr.trim());
                if (unitPrice <= 0) {
                    errors.append("Giá sản phẩm phải lớn hơn 0 khi nhập. ");
                } else if (unitPrice > 9999999999.99) {
                    errors.append("Giá sản phẩm không được vượt quá 99,999,999.99 VNĐ. ");
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
        
        // Validate số từ của mô tả
        if (description != null && !description.trim().isEmpty()) {
            int descriptionWordCount = countWords(description);
            if (descriptionWordCount > 150) {
                errors.append("Mô tả không được vượt quá 150 từ. Hiện tại: " + descriptionWordCount + " từ. ");
            }
        }
        
        // Validate số từ của thông số kỹ thuật
        if (specifications != null && !specifications.trim().isEmpty()) {
            int specificationsWordCount = countWords(specifications);
            if (specificationsWordCount > 150) {
                errors.append("Thông số kỹ thuật không được vượt quá 150 từ. Hiện tại: " + specificationsWordCount + " từ. ");
            }
        }
        
        return new ValidationResult(errors.length() == 0, errors.toString());
    }
    
    private Product createProductFromAddRequest(HttpServletRequest request, String imageUrl) {
        String productCode = request.getParameter("product_code");
        if (productCode != null) {
            productCode = productCode.trim();
        }
        
        // Tự động tạo mã sản phẩm nếu không có hoặc để trống
        if (isEmpty(productCode)) {
            productCode = productDAO.generateNextProductCode();
            if (productCode == null) {
                throw new RuntimeException("Không thể tạo mã sản phẩm tự động");
            }
        }
        
        String productName = request.getParameter("product_name").trim();
        String category = request.getParameter("category").trim();
        String unit = request.getParameter("unit").trim();
        String description = getParameterOrDefault(request, "description", "");
        double unitPrice = 0;
        String unitPriceStr3 = request.getParameter("unit_price");
        if (!isEmpty(unitPriceStr3)) {
            try { unitPrice = Double.parseDouble(unitPriceStr3.trim()); } catch (NumberFormatException ignore) { unitPrice = 0; }
        }
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
    
    /**
     * Xử lý lọc và tìm kiếm sản phẩm từ backend
     */
    private void filterProducts(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Thiết lập encoding UTF-8
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        try {
            // Lấy các tham số lọc từ request
            String supplierId = request.getParameter("supplierId");
            String category = request.getParameter("category");
            String status = request.getParameter("status");
            String searchTerm = request.getParameter("search");
            String pageStr = request.getParameter("page");
            String pageSizeStr = request.getParameter("pageSize");
            
            // Debug UTF-8 encoding
            System.out.println("=== FILTER REQUEST DEBUG ===");
            System.out.println("Category received: " + category);
            if (category != null) {
                System.out.println("Category bytes: " + java.util.Arrays.toString(category.getBytes("UTF-8")));
                System.out.println("Category length: " + category.length());
            }
            System.out.println("Search received: " + searchTerm);
            
            // Thiết lập phân trang
            int page = 1;
            int pageSize = 10;
            
            if (pageStr != null && !pageStr.isEmpty()) {
                try {
                    page = Integer.parseInt(pageStr);
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }
            
            if (pageSizeStr != null && !pageSizeStr.isEmpty()) {
                try {
                    pageSize = Integer.parseInt(pageSizeStr);
                } catch (NumberFormatException e) {
                    pageSize = 10;
                }
            }
            
            // Khởi tạo DAO
            SupplierDAO supplierDAO = new SupplierDAO();
            
            // Lấy danh sách sản phẩm đã lọc
            List<Product> products = productDAO.getFilteredProducts(
                supplierId, category, status, searchTerm, page, pageSize
            );
            
            // Lấy tổng số sản phẩm để tính phân trang
            int totalProducts = productDAO.getFilteredProductsCount(
                supplierId, category, status, searchTerm
            );
            
            // Lấy danh sách nhà cung cấp và danh mục cho dropdown
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();
            // Chỉ sử dụng 3 danh mục cố định
            List<String> categories = getFixedCategories();
            
            // Tạo response JSON
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("totalProducts", totalProducts);
            jsonResponse.addProperty("currentPage", page);
            jsonResponse.addProperty("pageSize", pageSize);
            jsonResponse.addProperty("totalPages", (int) Math.ceil((double) totalProducts / pageSize));
            
            // Chuyển đổi danh sách sản phẩm thành JSON
            Gson gson = new Gson();
            jsonResponse.add("products", gson.toJsonTree(products));
            jsonResponse.add("suppliers", gson.toJsonTree(suppliers));
            jsonResponse.add("categories", gson.toJsonTree(categories));
            
            // Debug log
            System.out.println("Filter request - supplierId: " + supplierId + ", category: " + category + 
                             ", status: " + status + ", search: " + searchTerm + ", page: " + page);
            System.out.println("Found " + products.size() + " products, total: " + totalProducts);
            
            // Gửi response
            PrintWriter out = response.getWriter();
            out.print(jsonResponse.toString());
            out.flush();
            
        } catch (Exception e) {
            // Xử lý lỗi
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("message", "Lỗi khi lọc sản phẩm: " + e.getMessage());
            
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            PrintWriter out = response.getWriter();
            out.print(errorResponse.toString());
            out.flush();
            
            e.printStackTrace();
        }
    }
    
    /**
     * Kiểm tra mã sản phẩm có tồn tại không
     */
    private void checkProductCodeExists(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String productCode = request.getParameter("product_code");
            if (productCode == null || productCode.trim().isEmpty()) {
                out.write("{\"exists\": false}");
                return;
            }
            
            boolean exists = productDAO.isProductCodeExists(productCode.trim());
            out.write("{\"exists\": " + exists + "}");
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"exists\": false, \"error\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Sinh mã sản phẩm tự động
     */
    private void generateProductCode(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(HttpServletResponse.SC_OK);
        
        PrintWriter out = null;
        try {
            out = response.getWriter();
            String generatedCode = productDAO.generateNextProductCode();
            if (generatedCode != null) {
                out.print("{\"success\": true, \"productCode\": \"" + escapeJson(generatedCode) + "\"}");
            } else {
                String errorMsg = productDAO.getLastError();
                if (errorMsg == null || errorMsg.isEmpty()) {
                    errorMsg = "Không thể tạo mã sản phẩm";
                }
                out.print("{\"success\": false, \"message\": \"" + escapeJson(errorMsg) + "\"}");
            }
            out.flush();
        } catch (Exception e) {
            e.printStackTrace();
            if (out != null) {
                out.print("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
                out.flush();
            }
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
    
    
}


