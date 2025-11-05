package com.hlgenerator.servlet;

import com.hlgenerator.dao.ContactDAO;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/contact")
public class ContactServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ContactDAO contactDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            contactDAO = new ContactDAO();
            System.out.println("ContactServlet: Initialized successfully");
        } catch (Exception e) {
            System.err.println("ContactServlet initialization failed: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Forward GET request to contact.jsp page
        request.getRequestDispatcher("/contact.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        // Lấy thông tin từ form
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String message = request.getParameter("message");

        // Validate input
        if (fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty() ||
            message == null || message.trim().isEmpty()) {
            sendJsonResponse(response, false, "Vui lòng điền đầy đủ thông tin", null);
            return;
        }

        try {
            // Lưu tin nhắn liên hệ
            boolean success = contactDAO.saveContactMessage(
                fullName.trim(),
                email.trim(),
                phone.trim(),
                message.trim()
            );

            if (success) {
                sendJsonResponse(response, true, "Cảm ơn bạn đã liên hệ! Chúng tôi sẽ phản hồi sớm nhất có thể.", null);
            } else {
                sendJsonResponse(response, false, "Có lỗi xảy ra khi gửi liên hệ. Vui lòng thử lại sau.", null);
            }
        } catch (Exception e) {
            System.err.println("Error processing contact form: " + e.getMessage());
            e.printStackTrace();
            sendJsonResponse(response, false, "Lỗi máy chủ: " + e.getMessage(), null);
        }
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, String message, Object data) 
            throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject result = new JSONObject();
        result.put("success", success);
        result.put("message", message);
        if (data != null) {
            result.put("data", data);
        }
        out.print(result.toString());
    }
}

