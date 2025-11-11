<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	// Ensure permissions are available
	java.util.Set<String> __perms = (java.util.Set<String>) session.getAttribute("userPermissions");
	if (__perms == null) __perms = new java.util.HashSet<String>();
	String __role = (String) session.getAttribute("userRole");
	boolean __isAdmin = "admin".equals(__role);
%>
<aside class="left-side sidebar-offcanvas">
	<section class="sidebar">
		<div class="user-panel">
			<div class="pull-left image">
				<img src="img/26115.jpg" class="img-circle" alt="User Image" />
			</div>
			<div class="pull-left info">
				<p>Xin chào, <%= (String) (session.getAttribute("username") != null ? session.getAttribute("username") : "User") %></p>
				<a href="#"><i class="fa fa-circle text-success"></i> Online</a>
			</div>
		</div>
		<ul class="sidebar-menu">
			<li>
				<a href="admin">
					<i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
				</a>
			</li>
			<% if ( __perms.contains("manage_users") ) { %>
			<li>
				<a href="users">
					<i class="fa fa-user-secret"></i> <span>Quản lý người dùng</span>
				</a>
			</li>
			<% } %>
			<% if ( __perms.contains("manage_permissions") ) { %>
			<li>
				<a href="role_permissions.jsp">
					<i class="fa fa-lock"></i> <span>Phân quyền</span>
				</a>
			</li>
			<% } %>
			<% if ( __perms.contains("manage_email") ) { %>
			<li>
				<a href="email-management">
					<i class="fa fa-envelope"></i> <span>Quản lý Email</span>
				</a>
			</li>
			<% } %>
			<% if ( __perms.contains("manage_settings") ) { %>
			<li>
				<a href="settings.jsp">
					<i class="fa fa-cog"></i> <span>Cài đặt</span>
				</a>
			</li>
			<% } %>

			<% if ( __perms.contains("manage_support_requests") ) { %>
			<li>
				<a href="support-management">
					<i class="fa fa-headset"></i> <span>Quản lý yêu cầu hỗ trợ</span>
				</a>
			</li>
			<% } %>
			<% if ( __perms.contains("manage_feedback") ) { %>
			<li>
				<a href="feedback_management.jsp">
					<i class="fa fa-comments"></i> <span>Quản lý feedback</span>
				</a>
			</li>
			<% } %>
			<% if ( __perms.contains("manage_contracts") ) { %>
			<li>
				<a href="contracts.jsp">
					<i class="fa fa-file-contract"></i> <span>Quản lý hợp đồng</span>
				</a>
			</li>
			<% } %>
			<% if ( __perms.contains("manage_contacts") ) { %>
			<li>
				<a href="contact-management">
					<i class="fa fa-address-book"></i> <span>Quản lý liên hệ</span>
				</a>
			</li>
			<% } %>
			<% if ( __perms.contains("manage_customers") ) { %>
			<li>
				<a href="customers">
					<i class="fa fa-users"></i> <span>Quản lý khách hàng</span>
				</a>
			</li>
			<% } %>

			<% if ( __perms.contains("view_my_tasks") ) { %>
			<li>
				<a href="my_tasks.jsp">
					<i class="fa fa-tasks"></i> <span>Nhiệm vụ của tôi</span>
				</a>
			</li>
			<% } %>

			<% if ( __perms.contains("manage_tech_support_requests") ) { %>
			<li>
				<a href="tech_support_management.jsp">
					<i class="fa fa-life-ring"></i> <span>Yêu cầu hỗ trợ kỹ thuật</span>
				</a>
			</li>
			<% } %>
			<% if ( __perms.contains("manage_work_orders") ) { %>
			<li>
				<a href="work_orders.jsp">
					<i class="fa fa-clipboard-list"></i> <span>Đơn hàng công việc</span>
				</a>
			</li>
			<% } %>
			<% if ( __perms.contains("manage_technical_staff") ) { %>
			<li>
				<a href="technical_staff_management.jsp">
					<i class="fa fa-user-tie"></i> <span>Quản lý nhân viên kỹ thuật</span>
				</a>
			</li>
			<% } %>

			<% if ( __perms.contains("manage_products") ) { %>
			<li>
				<a href="products.jsp">
					<i class="fa fa-box"></i> <span>Quản lý sản phẩm</span>
				</a>
			</li>
			<% } %>
			<% if ( __perms.contains("manage_suppliers") ) { %>
			<li>
				<a href="supplier.jsp">
					<i class="fa fa-truck"></i> <span>Nhà cung cấp</span>
				</a>
			</li>
			<% } %>
			<% if ( __perms.contains("manage_inventory") ) { %>
			<li>
				<a href="inventory.jsp">
					<i class="fa fa-warehouse"></i> <span>Quản lý kho</span>
				</a>
			</li>
			<% } %>

			<% if ( __perms.contains("submit_support_request") ) { %>
			<li>
				<a href="support.jsp">
					<i class="fa fa-life-ring"></i> <span>Gửi yêu cầu hỗ trợ</span>
				</a>
			</li>
			<% } %>
			<% if ( __perms.contains("submit_contact") ) { %>
			<li>
				<a href="contact.jsp">
					<i class="fa fa-envelope-open"></i> <span>Gửi liên hệ</span>
				</a>
			</li>
			<% } %>
		</ul>
	</section>
</aside>


