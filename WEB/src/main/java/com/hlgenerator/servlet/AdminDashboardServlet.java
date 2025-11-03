package com.hlgenerator.servlet;

import com.hlgenerator.dao.UserDAO;
import com.hlgenerator.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/admin")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String username = session != null ? (String) session.getAttribute("username") : null;
        Boolean isLoggedIn = session != null ? (Boolean) session.getAttribute("isLoggedIn") : null;

        if (username == null || isLoggedIn == null || !isLoggedIn) {
            response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
            return;
        }

        UserDAO userDAO = new UserDAO();

        int totalUsers = userDAO.getTotalUserCount();
        int adminCount = userDAO.getUserCountByRole("admin");
        int technicalStaffCount = userDAO.getUserCountByRole("technical_staff");
        int customerSupportCount = userDAO.getUserCountByRole("customer_support");
        int storekeeperCount = userDAO.getUserCountByRole("storekeeper");
        int headTechnicianCount = userDAO.getUserCountByRole("head_technician");
        int customerCount = userDAO.getUserCountByRole("customer");

        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("adminCount", adminCount);
        request.setAttribute("technicalStaffCount", technicalStaffCount);
        request.setAttribute("customerSupportCount", customerSupportCount);
        request.setAttribute("storekeeperCount", storekeeperCount);
        request.setAttribute("headTechnicianCount", headTechnicianCount);
        request.setAttribute("customerCount", customerCount);

        // Danh sách 10 người dùng mới nhất
        List<User> allUsers = userDAO.getAllUsers();
        List<User> recentUsers = allUsers.stream()
                .sorted(Comparator.comparing(User::getId).reversed())
                .limit(10)
                .collect(Collectors.toList());
        request.setAttribute("recentUsers", recentUsers);

        // Monthly customer chart (last 12 months) rendered as inline SVG (no JS)
        Map<String, Integer> monthCounts = userDAO.getCustomerCountsLastNMonths(12);
        String chartSvg = buildCustomerChartSvg(monthCounts);
        request.setAttribute("customerChartSvg", chartSvg);

        // Notifications from session
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> recentActions = (List<Map<String, Object>>) (session != null ? session.getAttribute("recentActions") : null);
        request.setAttribute("recentActions", recentActions);

        request.getRequestDispatcher("/admin.jsp").forward(request, response);
    }

    private String buildCustomerChartSvg(Map<String, Integer> monthCounts) {
        if (monthCounts == null || monthCounts.isEmpty()) {
            return "";
        }
        int widthPerBar = 40;
        int gap = 16;
        int chartHeight = 220;
        int leftPad = 40;
        int bottomPad = 35;
        int max = monthCounts.values().stream().mapToInt(Integer::intValue).max().orElse(1);
        if (max <= 0) max = 1;
        int n = monthCounts.size();
        int chartWidth = leftPad + n * (widthPerBar + gap) + 10;

        StringBuilder sb = new StringBuilder();
        sb.append("<svg width=\"").append(chartWidth)
          .append("\" height=\"").append(chartHeight + bottomPad)
          .append("\" viewBox=\"0 0 ").append(chartWidth).append(' ').append(chartHeight + bottomPad)
          .append("\" xmlns=\"http://www.w3.org/2000/svg\">");

        // axes
        sb.append("<line x1=\"").append(leftPad).append("\" y1=\"").append(10)
          .append("\" x2=\"").append(leftPad).append("\" y2=\"").append(chartHeight)
          .append("\" stroke=\"#ccc\" stroke-width=\"1\" />");
        sb.append("<line x1=\"").append(leftPad).append("\" y1=\"").append(chartHeight)
          .append("\" x2=\"").append(chartWidth - 10).append("\" y2=\"").append(chartHeight)
          .append("\" stroke=\"#ccc\" stroke-width=\"1\" />");

        int i = 0;
        for (Map.Entry<String, Integer> e : monthCounts.entrySet()) {
            int count = e.getValue() != null ? e.getValue() : 0;
            double h = (count * 1.0 / max) * (chartHeight - 20);
            int x = leftPad + i * (widthPerBar + gap);
            int y = (int) (chartHeight - h);
            // bar
            sb.append("<rect class=\"chart-bar\" x=\"").append(x).append("\" y=\"").append(y)
              .append("\" width=\"").append(widthPerBar)
              .append("\" height=\"").append((int) h)
              .append("\" fill=\"#5DADE2\" />");
            // value label
            sb.append("<text x=\"").append(x + widthPerBar / 2).append("\" y=\"")
              .append(y - 5).append("\" text-anchor=\"middle\" font-size=\"11\" fill=\"#333\">")
              .append(count).append("</text>");
            // month label (MM/yy)
            String ym = e.getKey(); // yyyy-MM
            String label = ym.substring(5) + "/" + ym.substring(2, 4);
            sb.append("<text x=\"").append(x + widthPerBar / 2).append("\" y=\"")
              .append(chartHeight + 15).append("\" text-anchor=\"middle\" font-size=\"11\" fill=\"#666\">")
              .append(label).append("</text>");
            i++;
        }

        // title
        sb.append("<text x=\"").append(leftPad).append("\" y=\"18\" font-size=\"12\" fill=\"#444\">Khách hàng theo tháng (12 tháng gần nhất)</text>");
        sb.append("</svg>");
        return sb.toString();
    }
}


