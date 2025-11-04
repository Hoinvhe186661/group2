package com.hlgenerator.servlet;

import com.hlgenerator.dao.ProductDAO;
import com.hlgenerator.dao.SupplierDAO;
import com.hlgenerator.model.Product;
import com.hlgenerator.model.Supplier;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/guest-products")
public class GuestProductServlet extends HttpServlet {
    private ProductDAO productDAO;
    private SupplierDAO supplierDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        productDAO = new ProductDAO();
        supplierDAO = new SupplierDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Thiết lập encoding UTF-8
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        if ("detail".equals(action)) {
            showProductDetail(request, response);
        } else if ("filter".equals(action)) {
            filterProducts(request, response);
        } else if ("page".equals(action) || action == null) {
            showProductsPage(request, response);
        } else {
            showProductsPage(request, response);
        }
    }

    /**
     * Hiển thị trang sản phẩm cho guest
     */
    private void showProductsPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            // Lấy các tham số từ request
            String sortBy = request.getParameter("sortBy"); // "all", "price_asc", "price_desc"
            String pageStr = request.getParameter("page");
            String searchTerm = request.getParameter("searchTerm"); // Thêm search term
            
            // Thiết lập phân trang
            int page = 1;
            int pageSize = 9; // 9 sản phẩm mỗi trang (3 cột x 3 hàng)
            
            if (pageStr != null && !pageStr.isEmpty()) {
                try {
                    page = Integer.parseInt(pageStr);
                    if (page < 1) page = 1;
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }
            
            // Xử lý search term - nếu null hoặc empty thì set null
            String finalSearchTerm = (searchTerm != null && !searchTerm.trim().isEmpty()) 
                ? searchTerm.trim() : null;
            
            // Lấy tổng số sản phẩm active (có search nếu có)
            int totalProducts = productDAO.getFilteredProductsCount(null, null, "active", finalSearchTerm);
            int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
            
            // Lấy danh sách sản phẩm active cho guest với phân trang, sort và search
            List<Product> products = productDAO.getFilteredProducts(
                null, null, "active", finalSearchTerm, page, pageSize, sortBy
            );
            
            // Đảm bảo tất cả sản phẩm có image_url và description hợp lệ
            for (Product p : products) {
                if (p.getImageUrl() == null || p.getImageUrl().trim().isEmpty() || "null".equals(p.getImageUrl())) {
                    p.setImageUrl("images/sanpham1.jpg"); // Ảnh mặc định
                }
                if (p.getDescription() == null || p.getDescription().trim().isEmpty() || "null".equals(p.getDescription())) {
                    String supplierName = p.getSupplierName() != null ? p.getSupplierName() : "nhà cung cấp uy tín";
                    p.setDescription("Sản phẩm chất lượng cao từ " + supplierName);
                }
            }
            
            // Lấy danh sách nhà cung cấp active
            List<Supplier> allSuppliers = supplierDAO.getAllSuppliers();
            List<Supplier> activeSuppliers = new ArrayList<>();
            for (Supplier s : allSuppliers) {
                if ("active".equals(s.getStatus())) {
                    activeSuppliers.add(s);
                }
            }
            
            // Set attributes cho JSP
            request.setAttribute("products", products);
            request.setAttribute("suppliers", activeSuppliers);
            request.setAttribute("totalProducts", totalProducts);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentSort", sortBy != null ? sortBy : "all");
            request.setAttribute("searchTerm", finalSearchTerm); // Thêm search term vào attribute
            
            // Forward to JSP
            request.getRequestDispatcher("/guest_products.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/guest_products.jsp").forward(request, response);
        }
    }

    /**
     * Xử lý lọc và tìm kiếm sản phẩm cho guest
     */
    private void filterProducts(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Thiết lập encoding UTF-8
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        try {
            // Lấy các tham số lọc từ request
            String[] supplierIds = request.getParameterValues("supplierId"); // Có thể có nhiều supplierId
            String priceMin = request.getParameter("priceMin");
            String priceMax = request.getParameter("priceMax");
            String sortBy = request.getParameter("sortBy"); // "all", "price_asc", "price_desc"
            String searchTerm = request.getParameter("searchTerm"); // Thêm search term
            String pageStr = request.getParameter("page");
            String pageSizeStr = request.getParameter("pageSize");
            
            // Thiết lập phân trang
            int page = 1;
            int pageSize = 9; // 9 sản phẩm mỗi trang (3 cột x 3 hàng)
            
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
                    pageSize = 9;
                }
            }
            
            // Xử lý supplier filter
            String supplierIdFilter = null;
            List<Integer> supplierIdList = null;
            if (supplierIds != null && supplierIds.length > 0) {
                supplierIdList = new ArrayList<>();
                for (String id : supplierIds) {
                    try {
                        supplierIdList.add(Integer.parseInt(id));
                    } catch (NumberFormatException e) {
                        // Bỏ qua ID không hợp lệ
                    }
                }
                // Nếu chỉ có 1 supplier, có thể dùng để filter ở SQL level
                if (supplierIdList.size() == 1) {
                    supplierIdFilter = String.valueOf(supplierIdList.get(0));
                }
            }
            
            // Xử lý search term
            String finalSearchTerm = (searchTerm != null && !searchTerm.trim().isEmpty()) 
                ? searchTerm.trim() : null;
            
            // Xử lý price range filter
            Double minPrice = null;
            Double maxPrice = null;
            if (priceMin != null && !priceMin.trim().isEmpty()) {
                try {
                    minPrice = Double.parseDouble(priceMin);
                    System.out.println("Price filter - minPrice: " + minPrice);
                } catch (NumberFormatException e) {
                    // Bỏ qua nếu giá không hợp lệ
                    System.out.println("Invalid minPrice: " + priceMin);
                }
            }
            if (priceMax != null && !priceMax.trim().isEmpty()) {
                try {
                    maxPrice = Double.parseDouble(priceMax);
                    System.out.println("Price filter - maxPrice: " + maxPrice);
                } catch (NumberFormatException e) {
                    // Bỏ qua nếu giá không hợp lệ
                    System.out.println("Invalid maxPrice: " + priceMax);
                }
            }
            
            // Tạo final variables để dùng trong lambda
            final List<Integer> finalSupplierIdList = supplierIdList;
            final Double finalMinPrice = minPrice;
            final Double finalMaxPrice = maxPrice;
            final String finalSearchTermForFilter = finalSearchTerm;
            
            // Nếu có filter phức tạp (nhiều suppliers hoặc price range), cần lấy tất cả rồi filter ở Java
            // Nếu không, có thể dùng DAO với phân trang trực tiếp
            boolean needJavaFilter = (finalSupplierIdList != null && finalSupplierIdList.size() > 1) || 
                                    (finalMinPrice != null || finalMaxPrice != null);
            
            List<Product> products;
            int totalProducts;
            
            if (needJavaFilter) {
                // Lấy tất cả sản phẩm active (có thể filter 1 supplier và search ở SQL nếu có)
                // Nếu có searchTerm, dùng phương thức tìm kiếm chính xác
                if (finalSearchTermForFilter != null && !finalSearchTermForFilter.trim().isEmpty()) {
                    products = productDAO.getFilteredProductsWithExactSearch(
                        supplierIdFilter, null, "active", finalSearchTermForFilter, 1, 10000, null // Chưa sort, sẽ sort sau
                    );
                } else {
                    products = productDAO.getFilteredProducts(
                        supplierIdFilter, null, "active", null, 1, 10000, null // Chưa sort, sẽ sort sau
                    );
                }
                
                // Filter nhiều suppliers nếu cần
                if (finalSupplierIdList != null && finalSupplierIdList.size() > 1) {
                    products.removeIf(p -> !finalSupplierIdList.contains(p.getSupplierId()));
                }
                
                // Filter theo giá: lớn hơn min (> min) và nhỏ hơn hoặc bằng max (<= max)
                if (finalMinPrice != null) {
                    System.out.println("Filtering products: removing prices <= " + finalMinPrice);
                    int beforeCount = products.size();
                    products.removeIf(p -> {
                        boolean shouldRemove = p.getUnitPrice() <= finalMinPrice;
                        if (shouldRemove) {
                            System.out.println("Removing product: " + p.getProductName() + " with price: " + p.getUnitPrice());
                        }
                        return shouldRemove;
                    });
                    System.out.println("Filtered: " + beforeCount + " -> " + products.size() + " products");
                }
                if (finalMaxPrice != null) {
                    System.out.println("Filtering products: removing prices > " + finalMaxPrice);
                    int beforeCount = products.size();
                    products.removeIf(p -> {
                        boolean shouldRemove = p.getUnitPrice() > finalMaxPrice;
                        if (shouldRemove) {
                            System.out.println("Removing product: " + p.getProductName() + " with price: " + p.getUnitPrice());
                        }
                        return shouldRemove;
                    });
                    System.out.println("Filtered: " + beforeCount + " -> " + products.size() + " products");
                }
                
                // Sắp xếp ở Java level
                if ("price_asc".equals(sortBy)) {
                    products.sort((p1, p2) -> Double.compare(p1.getUnitPrice(), p2.getUnitPrice()));
                } else if ("price_desc".equals(sortBy)) {
                    products.sort((p1, p2) -> Double.compare(p2.getUnitPrice(), p1.getUnitPrice()));
                }
                // "all" hoặc null: giữ nguyên thứ tự
                
                totalProducts = products.size();
                
                // Phân trang ở Java level
                int startIndex = (page - 1) * pageSize;
                int endIndex = Math.min(startIndex + pageSize, totalProducts);
                List<Product> pagedProducts = new ArrayList<>();
                for (int i = startIndex; i < endIndex; i++) {
                    pagedProducts.add(products.get(i));
                }
                products = pagedProducts;
            } else {
                // Không có filter phức tạp, có thể dùng DAO với phân trang và sort trực tiếp
                // Nếu có searchTerm, dùng phương thức tìm kiếm chính xác
                if (finalSearchTermForFilter != null && !finalSearchTermForFilter.trim().isEmpty()) {
                    // Lấy tổng số trước (để tính pagination) với tìm kiếm chính xác
                    totalProducts = productDAO.getFilteredProductsCountWithExactSearch(supplierIdFilter, null, "active", finalSearchTermForFilter);
                    
                    // Lấy products với phân trang, sort và search chính xác từ DAO
                    products = productDAO.getFilteredProductsWithExactSearch(
                        supplierIdFilter, null, "active", finalSearchTermForFilter, page, pageSize, sortBy
                    );
                    
                    // Nếu có price filter, cần filter lại và đếm lại
                    if (finalMinPrice != null || finalMaxPrice != null) {
                        List<Product> allProducts = productDAO.getFilteredProductsWithExactSearch(
                            supplierIdFilter, null, "active", finalSearchTermForFilter, 1, 10000, sortBy
                        );
                        if (finalMinPrice != null) {
                            System.out.println("Filtering products (exact search): removing prices <= " + finalMinPrice);
                            int beforeCount = allProducts.size();
                            allProducts.removeIf(p -> {
                                boolean shouldRemove = p.getUnitPrice() <= finalMinPrice;
                                if (shouldRemove) {
                                    System.out.println("Removing product: " + p.getProductName() + " with price: " + p.getUnitPrice());
                                }
                                return shouldRemove;
                            });
                            System.out.println("Filtered: " + beforeCount + " -> " + allProducts.size() + " products");
                        }
                        if (finalMaxPrice != null) {
                            System.out.println("Filtering products (exact search): removing prices > " + finalMaxPrice);
                            int beforeCount = allProducts.size();
                            allProducts.removeIf(p -> {
                                boolean shouldRemove = p.getUnitPrice() > finalMaxPrice;
                                if (shouldRemove) {
                                    System.out.println("Removing product: " + p.getProductName() + " with price: " + p.getUnitPrice());
                                }
                                return shouldRemove;
                            });
                            System.out.println("Filtered: " + beforeCount + " -> " + allProducts.size() + " products");
                        }
                        totalProducts = allProducts.size();
                        int startIndex = (page - 1) * pageSize;
                        int endIndex = Math.min(startIndex + pageSize, totalProducts);
                        products = new ArrayList<>();
                        for (int i = startIndex; i < endIndex; i++) {
                            products.add(allProducts.get(i));
                        }
                    }
                } else {
                    // Không có searchTerm, dùng phương thức thông thường
                    // Lấy tổng số trước (để tính pagination)
                    totalProducts = productDAO.getFilteredProductsCount(supplierIdFilter, null, "active", null);
                    
                    // Lấy products với phân trang và sort từ DAO
                    products = productDAO.getFilteredProducts(
                        supplierIdFilter, null, "active", null, page, pageSize, sortBy
                    );
                    
                    // Nếu có price filter, cần filter lại và đếm lại
                    if (finalMinPrice != null || finalMaxPrice != null) {
                        List<Product> allProducts = productDAO.getFilteredProducts(
                            supplierIdFilter, null, "active", null, 1, 10000, sortBy
                        );
                    if (finalMinPrice != null) {
                        System.out.println("Filtering products (no search): removing prices <= " + finalMinPrice);
                        int beforeCount = allProducts.size();
                        allProducts.removeIf(p -> {
                            boolean shouldRemove = p.getUnitPrice() <= finalMinPrice;
                            if (shouldRemove) {
                                System.out.println("Removing product: " + p.getProductName() + " with price: " + p.getUnitPrice());
                            }
                            return shouldRemove;
                        });
                        System.out.println("Filtered: " + beforeCount + " -> " + allProducts.size() + " products");
                    }
                    if (finalMaxPrice != null) {
                        System.out.println("Filtering products (no search): removing prices > " + finalMaxPrice);
                        int beforeCount = allProducts.size();
                        allProducts.removeIf(p -> {
                            boolean shouldRemove = p.getUnitPrice() > finalMaxPrice;
                            if (shouldRemove) {
                                System.out.println("Removing product: " + p.getProductName() + " with price: " + p.getUnitPrice());
                            }
                            return shouldRemove;
                        });
                        System.out.println("Filtered: " + beforeCount + " -> " + allProducts.size() + " products");
                    }
                    totalProducts = allProducts.size();
                        int startIndex = (page - 1) * pageSize;
                        int endIndex = Math.min(startIndex + pageSize, totalProducts);
                        products = new ArrayList<>();
                        for (int i = startIndex; i < endIndex; i++) {
                            products.add(allProducts.get(i));
                        }
                    }
                }
            }
            
            int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
            
            // Đảm bảo tất cả sản phẩm có image_url và description hợp lệ
            for (Product p : products) {
                if (p.getImageUrl() == null || p.getImageUrl().trim().isEmpty() || "null".equals(p.getImageUrl())) {
                    p.setImageUrl("images/sanpham1.jpg"); // Ảnh mặc định
                }
                if (p.getDescription() == null || p.getDescription().trim().isEmpty() || "null".equals(p.getDescription())) {
                    String supplierName = p.getSupplierName() != null ? p.getSupplierName() : "nhà cung cấp uy tín";
                    p.setDescription("Sản phẩm chất lượng cao từ " + supplierName);
                }
            }
            
            // Lấy danh sách nhà cung cấp active
            List<Supplier> allSuppliers = supplierDAO.getAllSuppliers();
            List<Supplier> activeSuppliers = new ArrayList<>();
            for (Supplier s : allSuppliers) {
                if ("active".equals(s.getStatus())) {
                    activeSuppliers.add(s);
                }
            }
            
            // Tạo response JSON
            Gson gson = new Gson();
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("totalProducts", totalProducts);
            jsonResponse.addProperty("currentPage", page);
            jsonResponse.addProperty("pageSize", pageSize);
            jsonResponse.addProperty("totalPages", totalPages);
            jsonResponse.add("products", gson.toJsonTree(products));
            jsonResponse.add("suppliers", gson.toJsonTree(activeSuppliers));
            
            // Gửi response
            PrintWriter out = response.getWriter();
            out.print(jsonResponse.toString());
            out.flush();
            
        } catch (Exception e) {
            e.printStackTrace();
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("message", "Lỗi khi lọc sản phẩm: " + e.getMessage());
            PrintWriter out = response.getWriter();
            out.print(errorResponse.toString());
            out.flush();
        }
    }

    /**
     * Hiển thị trang chi tiết sản phẩm cho guest
     */
    private void showProductDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            // Debug log
            System.out.println("=== SHOW PRODUCT DETAIL ===");
            System.out.println("Action: " + request.getParameter("action"));
            System.out.println("Product ID: " + request.getParameter("id"));
            
            // Lấy product ID từ parameter
            String productIdStr = request.getParameter("id");
            if (productIdStr == null || productIdStr.trim().isEmpty()) {
                System.out.println("ERROR: Product ID is null or empty");
                request.setAttribute("error", "Không tìm thấy sản phẩm");
                request.getRequestDispatcher("/guest_products.jsp").forward(request, response);
                return;
            }
            
            // Xử lý trường hợp ID có ký tự không hợp lệ (như "3:455")
            // Chỉ lấy phần số trước dấu ":" hoặc khoảng trắng
            String cleanIdStr = productIdStr.trim();
            if (cleanIdStr.contains(":")) {
                cleanIdStr = cleanIdStr.split(":")[0];
            }
            if (cleanIdStr.contains(" ")) {
                cleanIdStr = cleanIdStr.split(" ")[0];
            }
            
            int productId;
            try {
                productId = Integer.parseInt(cleanIdStr);
                System.out.println("Parsed Product ID: " + productId + " (from: " + productIdStr + ")");
            } catch (NumberFormatException e) {
                System.out.println("ERROR: Invalid Product ID format: " + productIdStr);
                request.setAttribute("error", "ID sản phẩm không hợp lệ: " + productIdStr);
                request.getRequestDispatcher("/guest_products.jsp").forward(request, response);
                return;
            }
            
            // Lấy thông tin sản phẩm
            Product product = productDAO.getProductById(productId);
            
            if (product == null || !"active".equals(product.getStatus())) {
                request.setAttribute("error", "Sản phẩm không tồn tại hoặc đã ngừng kinh doanh");
                request.getRequestDispatcher("/guest_products.jsp").forward(request, response);
                return;
            }
            
            // Đảm bảo sản phẩm có image_url và description hợp lệ
            if (product.getImageUrl() == null || product.getImageUrl().trim().isEmpty() || "null".equals(product.getImageUrl())) {
                product.setImageUrl("images/sanpham1.jpg");
            }
            if (product.getDescription() == null || product.getDescription().trim().isEmpty() || "null".equals(product.getDescription())) {
                String supplierName = product.getSupplierName() != null ? product.getSupplierName() : "nhà cung cấp uy tín";
                product.setDescription("Sản phẩm chất lượng cao từ " + supplierName);
            }
            
            // Set attribute cho JSP
            request.setAttribute("product", product);
            
            // Forward to JSP
            request.getRequestDispatcher("/guest_product_detail.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải thông tin sản phẩm: " + e.getMessage());
            request.getRequestDispatcher("/guest_products.jsp").forward(request, response);
        }
    }
}

