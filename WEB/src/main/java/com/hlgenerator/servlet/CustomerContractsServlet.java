package com.hlgenerator.servlet;

import com.hlgenerator.util.AuthorizationUtil;
import com.hlgenerator.util.Permission;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/customer-contracts")
public class CustomerContractsServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		response.setCharacterEncoding("UTF-8");

		if (!AuthorizationUtil.isLoggedIn(request)) {
			response.sendRedirect(request.getContextPath() + "/login.jsp");
			return;
		}

		// Allow customers to view their own contracts, admins to view all
		if (!AuthorizationUtil.hasAnyPermission(request, Permission.MANAGE_CONTRACTS, Permission.VIEW_CUSTOMER_PROFILE)) {
			response.sendRedirect(request.getContextPath() + "/index.jsp");
			return;
		}

		// Forward to JSP (data will be loaded via AJAX from /api/contracts and /api/contract-items)
		request.getRequestDispatcher("/customer_contracts.jsp").forward(request, response);
	}
}


