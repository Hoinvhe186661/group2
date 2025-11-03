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
        
        if ("filter".equals(action)) {
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
            // Lấy danh sách sản phẩm active cho guest (chỉ hiển thị sản phẩm active)
            List<Product> allProducts = productDAO.getFilteredProducts(
                null, null, "active", null, 1, 10000
            );
            
            // Đảm bảo tất cả sản phẩm có image_url và description hợp lệ
            for (Product p : allProducts) {
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
            request.setAttribute("products", allProducts);
            request.setAttribute("suppliers", activeSuppliers);
            
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
            
            // Lấy danh sách sản phẩm đã lọc (chỉ lấy sản phẩm active)
            // Lấy tất cả để lọc giá và sắp xếp ở đây
            String supplierIdFilter = null;
            if (supplierIds != null && supplierIds.length > 0) {
                // Nếu có nhiều supplier, lấy tất cả sản phẩm rồi filter sau
                // Hoặc có thể dùng supplier đầu tiên nếu chỉ hỗ trợ 1 supplier trong DAO
                supplierIdFilter = supplierIds[0]; // Tạm thời lấy supplier đầu tiên
            }
            
            List<Product> products = productDAO.getFilteredProducts(
                supplierIdFilter, null, "active", null, 1, 10000 // Tăng limit để lấy tất cả sản phẩm
            );
            
            // Nếu có nhiều supplier được chọn, lọc thêm
            if (supplierIds != null && supplierIds.length > 1) {
                List<Integer> supplierIdList = new ArrayList<>();
                for (String id : supplierIds) {
                    try {
                        supplierIdList.add(Integer.parseInt(id));
                    } catch (NumberFormatException e) {
                        // Bỏ qua ID không hợp lệ
                    }
                }
                if (!supplierIdList.isEmpty()) {
                    products.removeIf(p -> !supplierIdList.contains(p.getSupplierId()));
                }
            }
            
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
            
            // Lọc theo giá nếu có
            if (priceMin != null && !priceMin.trim().isEmpty()) {
                try {
                    double minPrice = Double.parseDouble(priceMin);
                    products.removeIf(p -> p.getUnitPrice() < minPrice);
                } catch (NumberFormatException e) {
                    // Bỏ qua nếu giá không hợp lệ
                }
            }
            
            if (priceMax != null && !priceMax.trim().isEmpty()) {
                try {
                    double maxPrice = Double.parseDouble(priceMax);
                    products.removeIf(p -> p.getUnitPrice() > maxPrice);
                } catch (NumberFormatException e) {
                    // Bỏ qua nếu giá không hợp lệ
                }
            }
            
            // Sắp xếp
            if ("price_asc".equals(sortBy)) {
                products.sort((p1, p2) -> Double.compare(p1.getUnitPrice(), p2.getUnitPrice()));
            } else if ("price_desc".equals(sortBy)) {
                products.sort((p1, p2) -> Double.compare(p2.getUnitPrice(), p1.getUnitPrice()));
            }
            // "all" hoặc null: giữ nguyên thứ tự
            
            // Tính toán phân trang
            int totalProducts = products.size();
            int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
            
            // Lấy sản phẩm cho trang hiện tại
            int startIndex = (page - 1) * pageSize;
            int endIndex = Math.min(startIndex + pageSize, totalProducts);
            List<Product> pagedProducts = new ArrayList<>();
            for (int i = startIndex; i < endIndex; i++) {
                pagedProducts.add(products.get(i));
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
            jsonResponse.add("products", gson.toJsonTree(pagedProducts));
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
}

