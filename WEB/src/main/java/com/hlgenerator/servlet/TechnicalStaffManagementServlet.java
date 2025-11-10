package com.hlgenerator.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.hlgenerator.dao.WorkOrderTaskDAO;
import com.hlgenerator.util.AuthorizationUtil;
import com.hlgenerator.util.Permission;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

@WebServlet("/api/technical-staff-management")
public class TechnicalStaffManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger(TechnicalStaffManagementServlet.class.getName());
    
    private WorkOrderTaskDAO taskDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        super.init();
        taskDAO = new WorkOrderTaskDAO();
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        if (!AuthorizationUtil.isLoggedIn(request)) {
            sendError(response, "Unauthorized: Please login");
            return;
        }
        
        if (!AuthorizationUtil.hasAnyPermission(request, Permission.MANAGE_TASKS, Permission.VIEW_TASKS)) {
            sendError(response, "Forbidden: Không có quyền truy cập");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("list".equals(action)) {
            handleListStaff(request, response);
        } else {
            sendError(response, "Invalid action");
        }
    }

    private void handleListStaff(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        try {
            // Get filter parameters from request
            String statusFilter = request.getParameter("status");
            String priorityFilter = request.getParameter("priority");
            String searchKeyword = request.getParameter("search");
            
            // Normalize empty strings to null
            if (statusFilter != null && statusFilter.trim().isEmpty()) {
                statusFilter = null;
            }
            if (priorityFilter != null && priorityFilter.trim().isEmpty()) {
                priorityFilter = null;
            }
            if (searchKeyword != null && searchKeyword.trim().isEmpty()) {
                searchKeyword = null;
            }
            
            List<Map<String, Object>> staffList = taskDAO.getAllTechnicalStaffWithTasks(statusFilter, priorityFilter, searchKeyword);
            
            JsonObject result = new JsonObject();
            result.addProperty("success", true);
            result.add("data", gson.toJsonTree(staffList));
            result.addProperty("total", staffList.size());
            
            sendJson(response, result);
            
        } catch (Exception e) {
            logger.severe("Error listing technical staff: " + e.getMessage());
            sendError(response, "Error listing technical staff: " + e.getMessage());
        }
    }

    private void sendJson(HttpServletResponse response, JsonObject json) throws IOException {
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    private void sendError(HttpServletResponse response, String message) throws IOException {
        JsonObject result = new JsonObject();
        result.addProperty("success", false);
        result.addProperty("message", message);
        sendJson(response, result);
    }
}

