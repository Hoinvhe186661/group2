package com.hlgenerator.util;

import com.hlgenerator.dao.ActivityLogDAO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActionLogUtil {
    /**
     * Thêm action log vào cả session và database
     */
    @SuppressWarnings("unchecked")
    public static void addAction(HttpServletRequest request, String message, String type) {
        if (message == null || message.trim().isEmpty()) return;
        
        // Lưu vào session (backward compatibility)
        HttpSession session = request.getSession(false);
        if (session != null) {
            List<Map<String, Object>> logs = (List<Map<String, Object>>) session.getAttribute("recentActions");
            if (logs == null) {
                logs = new ArrayList<>();
            }
            Map<String, Object> entry = new HashMap<>();
            entry.put("message", message);
            entry.put("type", (type == null || type.isEmpty()) ? "info" : type);
            entry.put("time", System.currentTimeMillis());
            logs.add(entry);
            if (logs.size() > 100) {
                logs = logs.subList(logs.size() - 100, logs.size());
            }
            session.setAttribute("recentActions", logs);
        }
        
        // Lưu vào database
        try {
            ActivityLogDAO activityLogDAO = new ActivityLogDAO();
            Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
            String ipAddress = getClientIpAddress(request);
            
            // Tạo JSON details từ message và type
            String details = "{\"message\":\"" + escapeJson(message) + "\",\"type\":\"" + 
                           (type != null ? type : "info") + "\"}";
            
            activityLogDAO.addActivityLog(userId, message, null, null, details, ipAddress);
        } catch (Exception e) {
            // Log error nhưng không throw để không ảnh hưởng đến flow chính
            System.err.println("Error saving activity log to database: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Thêm action log với thông tin chi tiết hơn
     */
    public static void addAction(HttpServletRequest request, String action, String tableName, 
                                Integer recordId, String message, String type) {
        if (action == null || action.trim().isEmpty()) return;
        
        // Sử dụng message nếu có, nếu không thì dùng action
        String displayMessage = (message != null && !message.trim().isEmpty()) ? message : action;
        String logType = (type != null && !type.isEmpty()) ? type : "info";
        
        // Lưu vào session (không gọi addAction để tránh duplicate)
        HttpSession session = request.getSession(false);
        if (session != null) {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> logs = (List<Map<String, Object>>) session.getAttribute("recentActions");
            if (logs == null) {
                logs = new ArrayList<>();
            }
            Map<String, Object> entry = new HashMap<>();
            entry.put("message", displayMessage);
            entry.put("type", logType);
            entry.put("time", System.currentTimeMillis());
            logs.add(entry);
            if (logs.size() > 100) {
                logs = logs.subList(logs.size() - 100, logs.size());
            }
            session.setAttribute("recentActions", logs);
        }
        
        // Lưu vào database với thông tin chi tiết (chỉ một lần)
        try {
            ActivityLogDAO activityLogDAO = new ActivityLogDAO();
            Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
            String ipAddress = getClientIpAddress(request);
            
            // Tạo JSON details
            String details = "{\"message\":\"" + escapeJson(displayMessage) + 
                           "\",\"type\":\"" + logType + "\"}";
            
            activityLogDAO.addActivityLog(userId, action, tableName, recordId, details, ipAddress);
        } catch (Exception e) {
            System.err.println("Error saving activity log to database: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Lấy IP address của client
     */
    private static String getClientIpAddress(HttpServletRequest request) {
        String ipAddress = request.getHeader("X-Forwarded-For");
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getHeader("Proxy-Client-IP");
        }
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getRemoteAddr();
        }
        // Nếu có nhiều IP, lấy IP đầu tiên
        if (ipAddress != null && ipAddress.contains(",")) {
            ipAddress = ipAddress.split(",")[0].trim();
        }
        return ipAddress;
    }
    
    /**
     * Escape JSON string
     */
    private static String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}


