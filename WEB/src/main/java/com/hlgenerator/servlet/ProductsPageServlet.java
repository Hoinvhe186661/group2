package com.hlgenerator.servlet;

import com.hlgenerator.dao.ProductDAO;
import com.hlgenerator.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/products")
public class ProductsPageServlet extends HttpServlet {
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

