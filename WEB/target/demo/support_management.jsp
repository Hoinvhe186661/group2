<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
    // Kiểm tra đăng nhập
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Kiểm tra quyền customer_support hoặc admin
    if (!"customer_support".equals(userRole) && !"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Yêu Cầu Hỗ Trợ | Bảng Điều Khiển</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <!-- bootstrap 3.0.2 -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- font Awesome -->
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Ionicons -->
    <link href="css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <!-- DataTables -->
    <link href="css/datatables/dataTables.bootstrap.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="css/style.css" rel="stylesheet" type="text/css" />

    <style>
         .filter-section {
             background: #f9f9f9;
            padding: 15px;
             margin-bottom: 20px;
            border-radius: 5px;
         }
         .ticket-priority-urgent { border-left: 4px solid #d9534f; }
         .ticket-priority-high { border-left: 4px solid #f0ad4e; }
         .ticket-priority-medium { border-left: 4px solid #5bc0de; }
         .ticket-priority-low { border-left: 4px solid #5cb85c; }
         
         /* Tối ưu cho tiếng Việt */
         #detailDescription {
             font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
             line-height: 1.5;
             direction: ltr;
             unicode-bidi: embed;
         }
         
         /* Placeholder styling cho tiếng Việt */
         #detailDescription::placeholder {
             color: #999;
             font-style: italic;
         }
         
         /* Styling cho các trường bị khóa */
         input[readonly], textarea[readonly], select[disabled] {
             background-color: #f5f5f5;
             color: #666;
             cursor: not-allowed;
         }
         
         /* Styling cho các trường được phép chỉnh sửa */
         input:not([readonly]), textarea:not([readonly]), select:not([disabled]) {
             background-color: #fff;
             border-color: #5bc0de;
         }
         
         /* Label styling để phân biệt */
         .form-group label {
             font-weight: bold;
         }
         
         .form-group label:after {
             content: " *";
             color: #5bc0de;
             font-weight: normal;
         }
         
         /* Loại bỏ dấu * cho các trường readonly */
         input[readonly] + label:after,
         textarea[readonly] + label:after,
         select[disabled] + label:after {
             display: none;
         }
         
         /* Styling cho button chuyển tiếp */
         .btn-success.btn-xs {
             background-color: #5cb85c;
             border-color: #4cae4c;
         }
         
         .btn-success.btn-xs:hover {
             background-color: #449d44;
             border-color: #398439;
         }
         
         /* Modal chuyển tiếp */
         #forwardModal .modal-header {
             background-color: #5cb85c;
             color: white;
         }
         
         #forwardModal .modal-header .close {
             color: white;
             opacity: 0.8;
         }
         
         #forwardModal .modal-header .close:hover {
             opacity: 1;
        }
    </style>
</head>
<body class="skin-black">
    <!-- header logo: style can be found in header.less -->
    <header class="header">
        <a href="support-management" class="logo">
            Quản Lý Yêu Cầu Hỗ Trợ
        </a>
        <!-- Header Navbar: style can be found in header.less -->
        <nav class="navbar navbar-static-top" role="navigation">
            <!-- Sidebar toggle button-->
            <a href="#" class="navbar-btn sidebar-toggle" data-toggle="offcanvas" role="button">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </a>
            <div class="navbar-right">
                <ul class="nav navbar-nav">
                    <!-- User Account: style can be found in dropdown.less -->
                    <li class="dropdown user user-menu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="fa fa-user"></i>
                            <span>${sessionScope.username} <i class="caret"></i></span>
                        </a>
                        <ul class="dropdown-menu dropdown-custom dropdown-menu-right">
                            <li class="dropdown-header text-center">Tài khoản</li>
                            <li>
                                <a href="profile.jsp">
                                <i class="fa fa-user fa-fw pull-right"></i>
                                    Hồ sơ
                                </a>
                                <a href="settings.jsp">
                                <i class="fa fa-cog fa-fw pull-right"></i>
                                    Cài đặt cá nhân
                                </a>
                            </li>
                            <li class="divider"></li>
                            <li>
                                <a href="logout"><i class="fa fa-ban fa-fw pull-right"></i> Đăng xuất</a>
                            </li>
                        </ul>
                    </li>
                </ul>
            </div>
        </nav>
    </header>
    
    <div class="wrapper row-offcanvas row-offcanvas-left">
        <!-- Left side column. contains the logo and sidebar -->
        <aside class="left-side sidebar-offcanvas">
            <!-- sidebar: style can be found in sidebar.less -->
            <section class="sidebar">
                <!-- Sidebar user panel -->
                <div class="user-panel">
                    <div class="pull-left image">
                        <img src="img/26115.jpg" class="img-circle" alt="User Image" />
                    </div>
                    <div class="pull-left info">
                        <p>Xin chào, <%= username %></p>
                        <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
                    </div>
                </div>
                <!-- sidebar menu: : style can be found in sidebar.less -->
                <ul class="sidebar-menu">
                    <li>
                        <a href="customersupport.jsp">
                            <i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
                        </a>
                    </li>
                    <li class="active">
                        <a href="support-management">
                            <i class="fa fa-ticket"></i> <span>Quản lý yêu cầu hỗ trợ</span>
                        </a>
                    </li>
                    <li>
                        <a href="contracts.jsp">
                            <i class="fa fa-file-text"></i> <span>Hợp đồng khách hàng</span>
                        </a>
                    </li>
                </ul>
            </section>
            <!-- /.sidebar -->
        </aside>

        <aside class="right-side">
            <!-- Main content -->
            <section class="content">
                <!-- Filter Section -->
                <div class="filter-section">
                    <form method="GET" action="support-management">
                <div class="row">
                        <div class="col-md-3">
                            <label>Trạng thái:</label>
                                <select name="status" class="form-control">
                                            <option value="">Tất cả</option>
                                    <option value="open" ${param.status == 'open' ? 'selected' : ''}>Đang chờ</option>
                                    <option value="in_progress" ${param.status == 'in_progress' ? 'selected' : ''}>Đang xử lý</option>
                                    <option value="resolved" ${param.status == 'resolved' ? 'selected' : ''}>Hoàn thành</option>
                                    <option value="closed" ${param.status == 'closed' ? 'selected' : ''}>Đã đóng</option>
                                        </select>
                                    </div>
                        <div class="col-md-3">
                            <label>Độ ưu tiên:</label>
                                <select name="priority" class="form-control">
                                            <option value="">Tất cả</option>
                                    <option value="urgent" ${param.priority == 'urgent' ? 'selected' : ''}>Khẩn cấp</option>
                                    <option value="high" ${param.priority == 'high' ? 'selected' : ''}>Cao</option>
                                    <option value="medium" ${param.priority == 'medium' ? 'selected' : ''}>Trung bình</option>
                                    <option value="low" ${param.priority == 'low' ? 'selected' : ''}>Thấp</option>
                                        </select>
                                    </div>
                        <div class="col-md-3">
                            <label>Danh mục:</label>
                                <select name="category" class="form-control">
                                <option value="">Tất cả</option>
                                    <option value="technical" ${param.category == 'technical' ? 'selected' : ''}>Kỹ thuật</option>
                                    <option value="billing" ${param.category == 'billing' ? 'selected' : ''}>Thanh toán</option>
                                    <option value="general" ${param.category == 'general' ? 'selected' : ''}>Chung</option>
                                    <option value="complaint" ${param.category == 'complaint' ? 'selected' : ''}>Khiếu nại</option>
                            </select>
                                    </div>
                        <div class="col-md-3">
                            <label>&nbsp;</label><br>
                                <button type="submit" class="btn btn-primary">
                                        <i class="fa fa-filter"></i> Lọc
                                    </button>
                                <a href="support-management" class="btn btn-default">
                                 <i class="fa fa-refresh"></i> Xóa bộ lọc
                                </a>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Tickets Table -->
                <div class="row">
                    <div class="col-md-12">
                        <section class="panel">
                            <header class="panel-heading">
                                <h3>Danh sách yêu cầu hỗ trợ</h3>
                            </header>
                            <div class="panel-body">
                                <div class="table-responsive">
                                    <table id="ticketsTable" class="table table-striped table-bordered table-hover">
                                    <thead>
                                        <tr>
                                                <th>ID</th>
                                                <th>Mã Ticket</th>
                                            <th>Khách hàng</th>
                                            <th>Tiêu đề</th>
                                                <th>Danh mục</th>
                                                <th>Độ ưu tiên</th>
                                                <th>Trạng thái</th>
                                                <th>Ngày tạo</th>
                                                <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty tickets}">
                                                <c:forEach var="ticket" items="${tickets}">
                                                <tr class="ticket-priority-${ticket.priority}">
                                                    <td>${ticket.id}</td>
                                                    <td><strong>#${ticket.ticketNumber}</strong></td>
                                                    <td>${not empty ticket.customerName ? ticket.customerName : 'N/A'}</td>
                                                    <td>${ticket.subject}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${ticket.category == 'technical'}">
                                                                <span class='label label-info'>Kỹ thuật</span>
                                                            </c:when>
                                                            <c:when test="${ticket.category == 'billing'}">
                                                                <span class='label label-success'>Thanh toán</span>
                                                            </c:when>
                                                            <c:when test="${ticket.category == 'general'}">
                                                                <span class='label label-default'>Chung</span>
                                                            </c:when>
                                                            <c:when test="${ticket.category == 'complaint'}">
                                                                <span class='label label-danger'>Khiếu nại</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class='label label-default'>${ticket.category}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${ticket.priority == 'low'}">
                                                                <span class='label label-info'>Thấp</span>
                                                            </c:when>
                                                            <c:when test="${ticket.priority == 'medium'}">
                                                                <span class='label label-warning'>Trung bình</span>
                                                            </c:when>
                                                            <c:when test="${ticket.priority == 'high'}">
                                                                <span class='label label-danger'>Cao</span>
                                                            </c:when>
                                                            <c:when test="${ticket.priority == 'urgent'}">
                                                                <span class='label label-danger'>Khẩn cấp</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class='label label-default'>${ticket.priority}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${ticket.status == 'open'}">
                                                                <span class='label label-primary'>Đang chờ</span>
                                                            </c:when>
                                                            <c:when test="${ticket.status == 'in_progress'}">
                                                                <span class='label label-warning'>Đang xử lý</span>
                                                            </c:when>
                                                            <c:when test="${ticket.status == 'resolved'}">
                                                                <span class='label label-success'>Hoàn thành</span>
                                                            </c:when>
                                                            <c:when test="${ticket.status == 'closed'}">
                                                                <span class='label label-default'>Đã đóng</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class='label label-default'>${ticket.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                    </td>
                                                    <td>
                                                        <a href="support_detail.jsp?id=${ticket.id}" class="btn btn-info btn-xs" title="Xem chi tiết">
                                                            <i class="fa fa-eye"></i> Xem
                                                        </a>
                                                        <a href="support_edit.jsp?id=${ticket.id}" class="btn btn-warning btn-xs" title="Chỉnh sửa">
                                                            <i class="fa fa-edit"></i> Sửa
                                                        </a>
                                                        <a href="support_forward.jsp?id=${ticket.id}" class="btn btn-success btn-xs" title="Chuyển tiếp">
                                                            <i class="fa fa-forward"></i> Chuyển tiếp
                                                        </a>
                                                    </td>
                                                </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="9" class="text-center">
                                                        <i class="fa fa-info-circle"></i> 
                                                        <c:choose>
                                                            <c:when test="${not empty param.status or not empty param.priority or not empty param.category}">
                                                                Không tìm thấy yêu cầu hỗ trợ phù hợp với bộ lọc
                                                            </c:when>
                                                            <c:otherwise>
                                                                Chưa có yêu cầu hỗ trợ nào
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                    </div>
                </div>
            </section>
                            </div>
                        </div>
            </section><!-- /.content -->
        </aside><!-- /.right-side -->
    </div><!-- ./wrapper -->

    <!-- jQuery 2.0.2 -->
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
    <script src="js/jquery.min.js" type="text/javascript"></script>
    <!-- jQuery UI 1.10.3 -->
    <script src="js/jquery-ui-1.10.3.min.js" type="text/javascript"></script>
    <!-- Bootstrap -->
    <script src="js/bootstrap.min.js" type="text/javascript"></script>
    <!-- DataTables -->
    <script src="js/plugins/datatables/jquery.dataTables.js" type="text/javascript"></script>
    <script src="js/plugins/datatables/dataTables.bootstrap.js" type="text/javascript"></script>
    <!-- Director App -->
    <script src="js/Director/app.js" type="text/javascript"></script>

    <script>
        $(document).ready(function() {
            // Khởi tạo DataTable với dữ liệu đã có sẵn trong HTML
            $('#ticketsTable').DataTable({
                    "language": {
                        "url": "//cdn.datatables.net/plug-ins/1.10.24/i18n/Vietnamese.json"
                },
                "pageLength": 10,
                "order": [[7, "desc"]], // Sort by Ngày tạo (column 7) giảm dần
                "columnDefs": [
                    { "orderable": false, "targets": 8 } // Không sort cột Thao tác
                ]
            });
        });
    </script>
</body>
</html>