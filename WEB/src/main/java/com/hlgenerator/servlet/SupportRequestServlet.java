package com.hlgenerator.servlet;

import com.hlgenerator.dao.SupportRequestDAO;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

@WebServlet("/api/support-requests")
public class SupportRequestServlet extends HttpServlet {
    private Integer resolveOrAttachCustomerId(HttpSession session) {
        if (session == null) return null;
        Object cid = session.getAttribute("customerId");
        if (cid instanceof Integer) return (Integer) cid;
        try {
            com.hlgenerator.dao.CustomerDAO customerDAO = new com.hlgenerator.dao.CustomerDAO();
            Object emailObj = session.getAttribute("email");
            if (emailObj != null) {
                String email = String.valueOf(emailObj);
                if (email != null && !"null".equalsIgnoreCase(email) && !email.trim().isEmpty()) {
                    com.hlgenerator.model.Customer cByEmail = customerDAO.getCustomerByEmail(email.trim());
                    if (cByEmail != null) {
                        session.setAttribute("customerId", cByEmail.getId());
                        return cByEmail.getId();
                    }
                }
            }

            Object usernameObj = session.getAttribute("username");
            if (usernameObj != null) {
                String username = String.valueOf(usernameObj);
                com.hlgenerator.dao.UserDAO userDAO = new com.hlgenerator.dao.UserDAO();
                com.hlgenerator.model.User user = userDAO.getUserByUsername(username);
                if (user != null && user.getEmail() != null) {
                    com.hlgenerator.model.Customer c = customerDAO.getCustomerByEmail(user.getEmail());
                    if (c != null) {
                        session.setAttribute("customerId", c.getId());
                        return c.getId();
                    }
                }
            }
        } catch (Exception ignore) {}
        return null;
    }

    private Integer ensureCustomerFromSession(HttpSession session) {
        if (session == null) return null;
        Object cid = session.getAttribute("customerId");
        if (cid instanceof Integer) return (Integer) cid;
        try {
            Object emailObj = session.getAttribute("email");
            Object nameObj = session.getAttribute("fullName");
            Object usernameObj = session.getAttribute("username");
            String email = emailObj != null ? String.valueOf(emailObj) : null;
            String name = nameObj != null && !"null".equals(String.valueOf(nameObj)) ? String.valueOf(nameObj) : (usernameObj != null ? String.valueOf(usernameObj) : "");

            if (email == null || email.trim().isEmpty() || "null".equalsIgnoreCase(email)) {
                return null; // cannot create without email due to UNIQUE(email)
            }

            com.hlgenerator.dao.CustomerDAO customerDAO = new com.hlgenerator.dao.CustomerDAO();
            com.hlgenerator.model.Customer existing = customerDAO.getCustomerByEmail(email.trim());
            if (existing != null) {
                session.setAttribute("customerId", existing.getId());
                return existing.getId();
            }

            // Auto-create minimal customer record for logged-in user
            String code = customerDAO.generateNextCustomerCode();
            com.hlgenerator.model.Customer newC = new com.hlgenerator.model.Customer();
            newC.setCustomerCode(code);
            newC.setCompanyName(name);
            newC.setContactPerson(name);
            newC.setEmail(email.trim());
            newC.setPhone("");
            newC.setAddress("");
            newC.setTaxCode("");
            newC.setCustomerType("individual");
            newC.setStatus("active");
            boolean created = customerDAO.addCustomer(newC);
            if (created) {
                com.hlgenerator.model.Customer createdC = customerDAO.getCustomerByEmail(email.trim());
                if (createdC != null) {
                    session.setAttribute("customerId", createdC.getId());
                    return createdC.getId();
                }
            }
        } catch (Exception ignore) {}
        return null;
    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        Integer customerId = session != null ? (Integer) session.getAttribute("customerId") : null;
        if (customerId == null) {
            customerId = resolveOrAttachCustomerId(session);
        }
        if (customerId == null) {
            customerId = ensureCustomerFromSession(session);
        }
        if (customerId == null) {
            response.setStatus(401);
            out.print(new JSONObject().put("success", false).put("message", "Chưa đăng nhập").toString());
            return;
        }

        SupportRequestDAO dao = new SupportRequestDAO();
        List<Map<String, Object>> list = dao.listByCustomerId(customerId);
        JSONArray arr = new JSONArray(list);
        JSONObject res = new JSONObject();
        res.put("success", true);
        res.put("data", arr);
        out.print(res.toString());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        Integer customerId = session != null ? (Integer) session.getAttribute("customerId") : null;
        if (customerId == null) {
            customerId = resolveOrAttachCustomerId(session);
        }
        if (customerId == null) {
            customerId = ensureCustomerFromSession(session);
        }
        if (customerId == null) {
            response.setStatus(401);
            out.print(new JSONObject().put("success", false).put("message", "Chưa đăng nhập").toString());
            return;
        }

        String action = request.getParameter("action");
        String subject = request.getParameter("subject");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        // Priority in create flow is controlled by backend default
        String priority = request.getParameter("priority");
        String deleteOldId = request.getParameter("delete_old_id");
        String id = request.getParameter("id");

        // Xử lý action cancel
        System.out.println("DEBUG: action=" + action + ", id=" + id);
        if ("cancel".equals(action) && id != null && !id.trim().isEmpty()) {
            try {
                int requestId = Integer.parseInt(id.trim());
                SupportRequestDAO dao = new SupportRequestDAO();
                boolean ok = dao.deleteById(requestId);
                
                JSONObject res = new JSONObject();
                res.put("success", ok);
                if (ok) {
                    res.put("message", "Đã hủy yêu cầu thành công");
                } else {
                    response.setStatus(500);
                    String err = "Không thể hủy yêu cầu";
                    try {
                        String daoErr = dao.getLastError();
                        if (daoErr != null && !daoErr.isEmpty()) {
                            err = err + ": " + daoErr;
                        }
                    } catch (Exception ignore) {}
                    res.put("message", err);
                }
                out.print(res.toString());
                return;
            } catch (NumberFormatException e) {
                response.setStatus(400);
                out.print(new JSONObject().put("success", false).put("message", "ID không hợp lệ").toString());
                return;
            }
        }

        // Rely on session-based identity only; no form identity check

        // Chỉ kiểm tra subject khi không phải action cancel
        if (subject == null || subject.trim().isEmpty()) {
            response.setStatus(400);
            out.print(new JSONObject().put("success", false).put("message", "Thiếu tiêu đề").toString());
            return;
        }

        if (category == null) category = "";
        if (priority == null) priority = "";
        category = category.trim().toLowerCase();
        priority = priority.trim().toLowerCase();
        // sanitize enums
        if (!("technical".equals(category) || "billing".equals(category) || "general".equals(category) || "complaint".equals(category))) {
            category = "general";
        }
        // Force default priority for create flow
        priority = "medium";
        if (subject.length() > 200) {
            subject = subject.substring(0, 200);
        }

        // verify customer exists to avoid FK errors if session holds a wrong id
        try {
            com.hlgenerator.dao.CustomerDAO customerDAO = new com.hlgenerator.dao.CustomerDAO();
            com.hlgenerator.model.Customer c = customerDAO.getCustomerById(customerId);
            if (c == null) {
                // try to re-resolve and persist to session
                Integer resolved = resolveOrAttachCustomerId(session);
                if (resolved == null) {
                    response.setStatus(400);
                    out.print(new JSONObject().put("success", false).put("message", "Không tìm thấy khách hàng cho tài khoản đang đăng nhập").toString());
                    return;
                }
                customerId = resolved;
            }
        } catch (Exception ignore) {}

        SupportRequestDAO dao = new SupportRequestDAO();
        boolean ok = dao.create(customerId, subject.trim(), description != null ? description.trim() : null, category, priority);
        
        // nếu có delete_old_id và tạo mới thành công, xóa bản cũ
        if (ok && deleteOldId != null && !deleteOldId.trim().isEmpty()) {
            try {
                int oldId = Integer.parseInt(deleteOldId.trim());
                dao.deleteById(oldId);
            } catch (Exception ignore) {}
        }

        JSONObject res = new JSONObject();
        res.put("success", ok);
        if (ok) {
            res.put("message", "Tạo yêu cầu thành công");
        } else {
            response.setStatus(500);
            String err = "Không thể tạo yêu cầu";
            try {
                String daoErr = dao.getLastError();
                if (daoErr != null && !daoErr.isEmpty()) {
                    err = err + ": " + daoErr;
                }
            } catch (Exception ignore) {}
            res.put("message", err);
        }
        out.print(res.toString());
    }
}


