package com.hlgenerator.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/customer-contracts")
public class CustomerContractsServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		response.setCharacterEncoding("UTF-8");

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("isLoggedIn") == null) {
			response.sendRedirect(request.getContextPath() + "/login.jsp");
			return;
		}

		String role = (String) session.getAttribute("userRole");
		if (!"customer".equals(role) && !"admin".equals(role)) {
			response.sendRedirect(request.getContextPath() + "/index.jsp");
			return;
		}

		// Forward to JSP (data will be loaded via AJAX from /api/contracts and /api/contract-items)
		request.getRequestDispatcher("/customer_contracts.jsp").forward(request, response);
	}
}


