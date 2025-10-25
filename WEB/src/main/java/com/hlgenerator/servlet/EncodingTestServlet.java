package com.hlgenerator.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/encoding-test")
public class EncodingTestServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<title>Encoding Test</title>");
        out.println("</head>");
        out.println("<body>");
        out.println("<h1>Test Encoding UTF-8</h1>");
        out.println("<p>Tiếng Việt có dấu: á, à, ả, ã, ạ, ă, ắ, ằ, ẳ, ẵ, ặ, â, ấ, ầ, ẩ, ẫ, ậ</p>");
        out.println("<p>Đặc biệt: đ, Đ</p>");
        out.println("<p>Ký tự đặc biệt: ư, ơ, ô, ê, ế, ề, ể, ễ, ệ</p>");
        out.println("<p>Test sản phẩm: Máy phát điện Perkins công suất 50KVA</p>");
        out.println("<p>Test hợp đồng: Hợp đồng 123 - HĐ #1</p>");
        out.println("<p>Test mô tả: Máy bị hỏng mô tơ</p>");
        out.println("</body>");
        out.println("</html>");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        String input = request.getParameter("text");
        if (input == null) {
            input = "Không có dữ liệu";
        }
        
        PrintWriter out = response.getWriter();
        out.println("{\"received\": \"" + input + "\", \"status\": \"success\"}");
    }
}
