package com.hlgenerator.servlet;

import com.hlgenerator.dao.SupportRequestDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/support-management")
public class SupportManagementServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set encoding TRƯỚC KHI đọc bất kỳ parameter nào
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        // Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("isLoggedIn") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String username = (String) session.getAttribute("username");
        String userRole = (String) session.getAttribute("userRole");
        
      
        if (!"customer_support".equals(userRole) && !"admin".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        
        
        
        
        String filterStatus = request.getParameter("status");
        String filterPriority = request.getParameter("priority");
        String filterCategory = request.getParameter("category");
        
       
        SupportRequestDAO supportDAO = new SupportRequestDAO();
        List<Map<String, Object>> allTickets = supportDAO.getAllSupportRequests();
        
        
        List<Map<String, Object>> filteredTickets = new ArrayList<Map<String, Object>>();
        
        for (Map<String, Object> ticket : allTickets) {
            boolean matchStatus = (filterStatus == null || filterStatus.isEmpty() || 
                                  filterStatus.equals(ticket.get("status")));
            boolean matchPriority = (filterPriority == null || filterPriority.isEmpty() || 
                                    filterPriority.equals(ticket.get("priority")));
            boolean matchCategory = (filterCategory == null || filterCategory.isEmpty() || 
                                    filterCategory.equals(ticket.get("category")));
            
            if (matchStatus && matchPriority && matchCategory) {
                filteredTickets.add(ticket);
            }
        }
        
        
        
        
        request.setAttribute("tickets", filteredTickets);
        request.setAttribute("filterStatus", filterStatus);
        request.setAttribute("filterPriority", filterPriority);
        request.setAttribute("filterCategory", filterCategory);
        request.setAttribute("totalTickets", filteredTickets.size());
        
        
        request.getRequestDispatcher("/support_management.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
       
        doGet(request, response);
    }
}

