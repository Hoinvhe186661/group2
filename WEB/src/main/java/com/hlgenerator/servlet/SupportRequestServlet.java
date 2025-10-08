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
            Object usernameObj = session.getAttribute("username");
            if (usernameObj == null) return null;
            String username = String.valueOf(usernameObj);
            com.hlgenerator.dao.UserDAO userDAO = new com.hlgenerator.dao.UserDAO();
            com.hlgenerator.model.User user = userDAO.getUserByUsername(username);
            if (user == null) return null;
            com.hlgenerator.dao.CustomerDAO customerDAO = new com.hlgenerator.dao.CustomerDAO();
            com.hlgenerator.model.Customer c = customerDAO.getCustomerById(user.getId());
            if (c != null) {
                session.setAttribute("customerId", c.getId());
                return c.getId();
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
            response.setStatus(401);
            out.print(new JSONObject().put("success", false).put("message", "Chưa đăng nhập").toString());
            return;
        }

        String action = request.getParameter("action");
        String inputCustomerNameOrCode = request.getParameter("customerId");
        String inputEmail = request.getParameter("email");
        String subject = request.getParameter("subject");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
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

        // Validate identity (customer name/code and email must match logged-in account)
        try {
            String sessionEmail = session != null ? String.valueOf(session.getAttribute("email")) : null;
            com.hlgenerator.dao.CustomerDAO customerDAO = new com.hlgenerator.dao.CustomerDAO();
            com.hlgenerator.model.Customer sessionCustomer = (sessionEmail != null) ? customerDAO.getCustomerByEmail(sessionEmail) : null;
            if (sessionCustomer == null) {
                response.setStatus(401);
                response.getWriter().print(new JSONObject().put("success", false).put("message", "Không tìm thấy tài khoản khách hàng cho phiên đăng nhập").toString());
                return;
            }
            String entered = inputCustomerNameOrCode != null ? inputCustomerNameOrCode.trim() : "";
            String enteredEmail = inputEmail != null ? inputEmail.trim() : "";
            boolean emailOk = !enteredEmail.isEmpty() && sessionEmail != null && enteredEmail.equalsIgnoreCase(sessionEmail);
            boolean idOk = !entered.isEmpty() && (
                    entered.equalsIgnoreCase(String.valueOf(sessionCustomer.getCustomerCode())) ||
                    entered.equalsIgnoreCase(String.valueOf(sessionCustomer.getContactPerson())) ||
                    entered.equalsIgnoreCase(String.valueOf(sessionCustomer.getCompanyName()))
            );
            if (!emailOk || !idOk) {
                response.setStatus(400);
                String msg = !emailOk ? "Email không khớp với tài khoản đang đăng nhập" : "Tên/Code khách hàng không đúng với tài khoản đang đăng nhập";
                response.getWriter().print(new JSONObject().put("success", false).put("message", msg).toString());
                return;
            }
        } catch (Exception ignored) {
            response.setStatus(400);
            response.getWriter().print(new JSONObject().put("success", false).put("message", "Xác thực thông tin khách hàng thất bại").toString());
            return;
        }

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
        if (!("low".equals(priority) || "medium".equals(priority) || "high".equals(priority) || "urgent".equals(priority))) {
            priority = "medium";
        }
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


