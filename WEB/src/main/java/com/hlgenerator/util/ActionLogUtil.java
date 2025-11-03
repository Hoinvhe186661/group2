package com.hlgenerator.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActionLogUtil {
    @SuppressWarnings("unchecked")
    public static void addAction(HttpServletRequest request, String message, String type) {
        if (message == null || message.trim().isEmpty()) return;
        HttpSession session = request.getSession(false);
        if (session == null) return;
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
}


