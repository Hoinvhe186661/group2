package com.hlgenerator.servlet;

import com.hlgenerator.dao.SupportRequestDAO;
import com.hlgenerator.dao.WorkOrderDAO;
import com.hlgenerator.model.WorkOrder;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Map;

@WebServlet("/support-detail")
public class SupportDetailServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        PrintWriter out = response.getWriter();
        
        // Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("isLoggedIn") == null) {
            out.print("{\"success\": false, \"message\": \"Chưa đăng nhập\"}");
            return;
        }
        
        String userRole = (String) session.getAttribute("userRole");
        
        // Kiểm tra quyền
        if (!"customer_support".equals(userRole) && !"admin".equals(userRole)) {
            out.print("{\"success\": false, \"message\": \"Không có quyền truy cập\"}");
            return;
        }
        
        // Lấy ID của ticket
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            out.print("{\"success\": false, \"message\": \"Thiếu ID ticket\"}");
            return;
        }
        
        try {
            int ticketId = Integer.parseInt(idParam);
            
            // Lấy chi tiết ticket từ database
            SupportRequestDAO supportDAO = new SupportRequestDAO();
            Map<String, Object> ticket = supportDAO.getSupportRequestById(ticketId);
            
            if (ticket == null) {
                out.print("{\"success\": false, \"message\": \"Không tìm thấy ticket\"}");
                return;
            }
            
            // Chuyển đổi Map thành JSON
            JSONObject json = new JSONObject();
            json.put("success", true);
            
            JSONObject data = new JSONObject();
            data.put("id", ticket.get("id"));
            data.put("ticketNumber", ticket.get("ticketNumber"));
            data.put("subject", ticket.get("subject"));
            data.put("description", ticket.get("description") != null ? ticket.get("description") : "");
            data.put("category", ticket.get("category"));
            data.put("priority", ticket.get("priority"));
            data.put("status", ticket.get("status"));
            data.put("resolution", ticket.get("resolution") != null ? ticket.get("resolution") : "");
            data.put("history", ticket.get("history") != null ? ticket.get("history") : "");
            
            // Thông tin khách hàng
            data.put("customerName", ticket.get("customerName") != null ? ticket.get("customerName") : "N/A");
            data.put("customerContact", ticket.get("customerContact") != null ? ticket.get("customerContact") : "N/A");
            data.put("customerEmail", ticket.get("customerEmail") != null ? ticket.get("customerEmail") : "");
            data.put("customerPhone", ticket.get("customerPhone") != null ? ticket.get("customerPhone") : "");
            data.put("customerAddress", ticket.get("customerAddress") != null ? ticket.get("customerAddress") : "");
            
            // Người xử lý
            data.put("assignedTo", ticket.get("assignedTo") != null ? ticket.get("assignedTo") : "");
            data.put("assignedToName", ticket.get("assignedToName") != null ? ticket.get("assignedToName") : "");
            data.put("assignedToEmail", ticket.get("assignedToEmail") != null ? ticket.get("assignedToEmail") : "");
            
            // Ngày tháng
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
            if (ticket.get("createdAt") != null) {
                data.put("createdAt", sdf.format(ticket.get("createdAt")));
            }
            if (ticket.get("resolvedAt") != null) {
                data.put("resolvedAt", sdf.format(ticket.get("resolvedAt")));
            }
            // Deadline - luôn trả về (có thể null)
            Object deadlineObj = ticket.get("deadline");
            System.out.println("DEBUG SupportDetailServlet: deadline object from ticket map = " + deadlineObj);
            System.out.println("DEBUG SupportDetailServlet: deadline object type = " + (deadlineObj != null ? deadlineObj.getClass().getName() : "null"));
            
            if (deadlineObj != null) {
                try {
                    // Deadline từ DB là yyyy-MM-dd, chuyển sang dd/MM/yyyy
                    String deadlineStr = deadlineObj.toString();
                    System.out.println("DEBUG SupportDetailServlet: deadline string = " + deadlineStr);
                    
                    if (deadlineStr != null && !deadlineStr.isEmpty() && !deadlineStr.equals("null")) {
                        java.sql.Date deadlineDate = java.sql.Date.valueOf(deadlineStr);
                        String formattedDeadline = dateFormat.format(deadlineDate);
                        data.put("deadline", formattedDeadline);
                        System.out.println("DEBUG SupportDetailServlet: formatted deadline = " + formattedDeadline);
                    } else {
                        data.put("deadline", "");
                        System.out.println("DEBUG SupportDetailServlet: deadline is empty or 'null' string, setting to empty");
                    }
                } catch (Exception e) {
                    // Nếu có lỗi, thử giữ nguyên format hoặc để rỗng
                    System.out.println("DEBUG SupportDetailServlet: Error formatting deadline: " + e.getMessage());
                    e.printStackTrace();
                    // Thử giữ nguyên format nếu có thể
                    String deadlineStr = deadlineObj.toString();
                    if (deadlineStr != null && !deadlineStr.isEmpty() && !deadlineStr.equals("null")) {
                        data.put("deadline", deadlineStr);
                    } else {
                        data.put("deadline", "");
                    }
                }
            } else {
                data.put("deadline", "");
                System.out.println("DEBUG SupportDetailServlet: deadline is null, setting to empty string");
            }
            
            System.out.println("DEBUG SupportDetailServlet: Final deadline in JSON data = " + data.get("deadline"));
            
            // Lấy technical_solution từ work_order nếu có
            try {
                WorkOrderDAO workOrderDAO = new WorkOrderDAO();
                String ticketTitle = (String) ticket.get("subject");
                Integer customerIdObj = (Integer) ticket.get("customerId");
                int customerId = customerIdObj != null ? customerIdObj : 0;
                
                WorkOrder workOrder = workOrderDAO.getWorkOrderByTicketId(ticketId, ticketTitle, customerId);
                if (workOrder != null && workOrder.getTechnicalSolution() != null && !workOrder.getTechnicalSolution().trim().isEmpty()) {
                    data.put("technicalSolution", workOrder.getTechnicalSolution());
                    System.out.println("DEBUG SupportDetailServlet: Found technical solution from work order: " + workOrder.getWorkOrderNumber());
                } else {
                    data.put("technicalSolution", "");
                    System.out.println("DEBUG SupportDetailServlet: No technical solution found for ticket " + ticketId);
                }
            } catch (Exception e) {
                System.out.println("DEBUG SupportDetailServlet: Error getting technical solution: " + e.getMessage());
                e.printStackTrace();
                data.put("technicalSolution", "");
            }
            
            json.put("data", data);
            out.print(json.toString());
            
        } catch (NumberFormatException e) {
            out.print("{\"success\": false, \"message\": \"ID không hợp lệ\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Lỗi: " + e.getMessage() + "\"}");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}

