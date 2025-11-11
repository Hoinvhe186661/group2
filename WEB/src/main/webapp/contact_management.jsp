<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Set" %>
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
    
    // Kiểm tra quyền: chỉ người có quyền manage_contacts mới truy cập được
    @SuppressWarnings("unchecked")
    Set<String> userPermissions = (Set<String>) session.getAttribute("userPermissions");
    if (userPermissions == null || !userPermissions.contains("manage_contacts")) {
        response.sendRedirect(request.getContextPath() + "/error/403.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Liên Hệ | Bảng Điều Khiển</title>
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
        .message-status-new { border-left: 4px solid #d9534f; }
        .message-status-replied { border-left: 4px solid #5cb85c; }
        .message-status-read { border-left: 4px solid #5bc0de; }
        
        .message-detail {
            white-space: pre-wrap;
            word-wrap: break-word;
            font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
            line-height: 1.6;
        }
    </style>
</head>
<body class="skin-black">
    <!-- header logo: style can be found in header.less -->
    <header class="header">
        <a href="contact-management" class="logo">
            Quản Lý Liên Hệ
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
                            <span><%= username %> <i class="caret"></i></span>
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
		<jsp:include page="partials/sidebar.jsp"/>

        <aside class="right-side">
            <!-- Main content -->
            <section class="content">
                <!-- Filter Section -->
                <div class="filter-section">
                    <form method="GET" action="contact-management">
                        <div class="row">
                            <div class="col-md-2">
                                <label>Trạng thái:</label>
                                <select name="status" class="form-control">
                                    <option value="">Tất cả</option>
                                    <option value="new" ${param.status == 'new' ? 'selected' : ''}>Mới</option>
                                    <option value="read" ${param.status == 'read' ? 'selected' : ''}>Đã đọc</option>
                                    <option value="replied" ${param.status == 'replied' ? 'selected' : ''}>Đã liên hệ </option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label>Tìm kiếm:</label>
                                <input type="text" class="form-control" name="q" placeholder="ID, tên, email, SĐT, tin nhắn" value="<%= request.getParameter("q") != null ? request.getParameter("q") : "" %>">
                            </div>
                            <div class="col-md-2">
                                <label>Từ ngày:</label>
                                <input type="date" name="startDate" class="form-control" value="${param.startDate}">
                            </div>
                            <div class="col-md-2">
                                <label>Đến ngày:</label>
                                <input type="date" name="endDate" class="form-control" value="${param.endDate}">
                            </div>
                            <div class="col-md-1">
                                <label>Hiển thị:</label>
                                <%
                                    int _sz = 10;
                                    try { 
                                        String sp = request.getParameter("size"); 
                                        if (sp != null) _sz = Integer.parseInt(sp); 
                                    } catch (Exception ignored) {}
                                %>
                                <select name="size" class="form-control" onchange="this.form.submit()">
                                    <option value="5" <%= _sz == 5 ? "selected" : "" %>>5</option>
                                    <option value="10" <%= _sz == 10 ? "selected" : "" %>>10</option>
                                    <option value="25" <%= _sz == 25 ? "selected" : "" %>>25</option>
                                    <option value="50" <%= _sz == 50 ? "selected" : "" %>>50</option>
                                    <option value="100" <%= _sz == 100 ? "selected" : "" %>>100</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label>&nbsp;</label><br>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa fa-filter"></i> Lọc
                                </button>
                                <a href="contact-management" class="btn btn-default">
                                    <i class="fa fa-refresh"></i> Xóa bộ lọc
                                </a>
                            </div>
                        </div>
                        <div class="row" style="margin-top: 5px;">
                            <div class="col-md-12 text-right">
                                <span class="text-muted">Tổng số: <strong>${totalMessages}</strong> tin nhắn</span>
                            </div>
                        </div>
                        <input type="hidden" name="page" value="1">
                    </form>
                </div>

                <!-- Messages Table -->
                <div class="row">
                    <div class="col-md-12">
                        <section class="panel">
                            <header class="panel-heading">
                                <h3>Danh sách liên hệ</h3>
                            </header>
                            <div class="panel-body">
                                <div class="table-responsive">
                                    <table id="messagesTable" class="table table-striped table-bordered table-hover">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Họ tên</th>
                                                <th>Email</th>
                                                <th>Số điện thoại</th>
                                                <th>Tin nhắn</th>
                                                <th>Trạng thái</th>
                                                <th>Ngày gửi</th>
                                                <th>Ngày phản hồi</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${not empty messages}">
                                                    <c:forEach var="message" items="${messages}">
                                                        <tr class="message-status-${message.status}">
                                                            <td>${message.id}</td>
                                                            <td><strong>${message.fullName}</strong></td>
                                                            <td>${message.email}</td>
                                                            <td>${message.phone}</td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${fn:length(message.message) > 50}">
                                                                        ${fn:substring(message.message, 0, 50)}...
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        ${message.message}
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${message.status == 'new'}">
                                                                        <span class="label label-danger">Mới</span>
                                                                    </c:when>
                                                                    <c:when test="${message.status == 'read'}">
                                                                        <span class="label label-info">Đã đọc</span>
                                                                    </c:when>
                                                                    <c:when test="${message.status == 'replied'}">
                                                                        <span class="label label-success">Đã liên hệ </span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="label label-default">${message.status}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <fmt:formatDate value="${message.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty message.repliedAt}">
                                                                        <fmt:formatDate value="${message.repliedAt}" pattern="dd/MM/yyyy HH:mm" />
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="text-muted">-</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <button class="btn btn-info btn-xs view-message-btn" 
                                                                        data-message-id="${message.id}" 
                                                                        data-contact-method="${message.contactMethod != null ? message.contactMethod : ''}"
                                                                        data-address="${message.address != null ? message.address : ''}"
                                                                        data-customer-type="${message.customerType != null ? message.customerType : ''}"
                                                                        data-company-name="${message.companyName != null ? message.companyName : ''}"
                                                                        data-tax-code="${message.taxCode != null ? message.taxCode : ''}"
                                                                        title="Xem chi tiết">
                                                                    <i class="fa fa-eye"></i> Xem
                                                                </button>
                                                                <c:choose>
                                                                    <c:when test="${message.status == 'replied'}">
                                                                        <button class="btn btn-success btn-xs" disabled title="Đã liên hệ" style="cursor: not-allowed;">
                                                                            <i class="fa fa-check"></i> Đã liên hệ
                                                                        </button>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <button class="btn btn-primary btn-xs mark-replied-btn" data-message-id="${message.id}" title="Đánh dấu đã liên hệ">
                                                                            <i class="fa fa-reply"></i> Đã liên hệ
                                                                        </button>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <tr>
                                                        <td colspan="9" class="text-center">
                                                            <p class="text-muted">Không có tin nhắn nào.</p>
                                                        </td>
                                                    </tr>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                                
                                <!-- Phân trang -->
                                <div class="row" style="margin-top: 10px;">
                                    <div class="col-md-6">
                                        <div class="text-muted" style="line-height: 34px;">
                                            <%
                                                int _currentPage = (Integer) request.getAttribute("currentPage");
                                                int _pageSize = (Integer) request.getAttribute("pageSize");
                                                int _total = (Integer) request.getAttribute("totalMessages");
                                                int _startIdx = (_currentPage - 1) * _pageSize + 1;
                                                int _endIdx = Math.min(_currentPage * _pageSize, _total);
                                                if (_total == 0) { 
                                                    _startIdx = 0; 
                                                    _endIdx = 0; 
                                                }
                                            %>
                                            Hiển thị <%= _startIdx %> - <%= _endIdx %> của <%= _total %> tin nhắn
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <nav aria-label="Phân trang tin nhắn" class="pull-right">
                                            <ul class="pagination pagination-sm" style="margin: 0;">
                                                <%
                                                    // Xây base query giữ nguyên filter
                                                    java.util.List<String> _p = new java.util.ArrayList<String>();
                                                    try { 
                                                        String v = request.getParameter("status"); 
                                                        if (v != null && !v.isEmpty()) 
                                                            _p.add("status=" + java.net.URLEncoder.encode(v, "UTF-8")); 
                                                    } catch (Exception ignored) {}
                                                    try { 
                                                        String v = request.getParameter("q"); 
                                                        if (v != null && !v.isEmpty()) 
                                                            _p.add("q=" + java.net.URLEncoder.encode(v, "UTF-8")); 
                                                    } catch (Exception ignored) {}
                                                    try { 
                                                        String v = request.getParameter("startDate"); 
                                                        if (v != null && !v.isEmpty()) 
                                                            _p.add("startDate=" + java.net.URLEncoder.encode(v, "UTF-8")); 
                                                    } catch (Exception ignored) {}
                                                    try { 
                                                        String v = request.getParameter("endDate"); 
                                                        if (v != null && !v.isEmpty()) 
                                                            _p.add("endDate=" + java.net.URLEncoder.encode(v, "UTF-8")); 
                                                    } catch (Exception ignored) {}
                                                    _p.add("size=" + _pageSize);
                                                    String _base = "contact-management" + (_p.isEmpty() ? "" : ("?" + String.join("&", _p)));
                                                    
                                                    int _totalPages = (Integer) request.getAttribute("totalPages");
                                                    
                                                    // Nút prev
                                                    int _prev = Math.max(1, _currentPage - 1);
                                                %>
                                                <li class="<%= _currentPage == 1 ? "disabled" : "" %>">
                                                    <a href="<%= _base + "&page=" + _prev %>">&laquo;</a>
                                                </li>
                                                <%
                                                    int _s = Math.max(1, _currentPage - 2);
                                                    int _e = Math.min(_totalPages, _currentPage + 2);
                                                    if (_s > 1) {
                                                %>
                                                <li><a href="<%= _base + "&page=1" %>">1</a></li>
                                                <%= (_s > 2) ? "<li class=\"disabled\"><span>...</span></li>" : "" %>
                                                <%
                                                    }
                                                    for (int i = _s; i <= _e; i++) {
                                                %>
                                                <li class="<%= i == _currentPage ? "active" : "" %>">
                                                    <a href="<%= _base + "&page=" + i %>"><%= i %></a>
                                                </li>
                                                <%
                                                    }
                                                    if (_e < _totalPages) {
                                                %>
                                                <%= (_e < _totalPages - 1) ? "<li class=\"disabled\"><span>...</span></li>" : "" %>
                                                <li><a href="<%= _base + "&page=" + _totalPages %>"><%= _totalPages %></a></li>
                                                <%
                                                    }
                                                    int _next = Math.min(_totalPages, _currentPage + 1);
                                                %>
                                                <li class="<%= _currentPage == _totalPages ? "disabled" : "" %>">
                                                    <a href="<%= _base + "&page=" + _next %>">&raquo;</a>
                                                </li>
                                            </ul>
                                        </nav>
                                    </div>
                                </div>
                            </div>
                        </section>
                    </div>
                </div>
            </section><!-- /.content -->
            <div class="footer-main">
                Copyright &copy Hệ thống hỗ trợ khách hàng - HL Generator, 2025
            </div>
        </aside><!-- /.right-side -->
    </div><!-- ./wrapper -->

    <!-- Modal xem chi tiết tin nhắn -->
    <div class="modal fade" id="viewMessageModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title">Chi tiết tin nhắn liên hệ</h4>
                </div>
                <div class="modal-body" id="messageDetailContent">
                    <!-- Nội dung sẽ được load bằng JavaScript -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                    <button type="button" class="btn btn-primary" id="btnMarkAsReplied">Đánh dấu đã liên hệ </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal đánh dấu đã liên hệ -->
    <div class="modal fade" id="markContactedModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title">Đánh dấu đã liên hệ</h4>
                </div>
                <div class="modal-body" id="markContactedContent">
                    <!-- Nội dung sẽ được load bằng JavaScript -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" id="btnConfirmContacted">Xác nhận</button>
                </div>
            </div>
        </div>
    </div>

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
        var currentMessageId = null;
        var shouldReloadAfterModalClose = false;
        
        // Đảm bảo jQuery đã sẵn sàng
        $(document).ready(function() {
            console.log('Contact management script loaded');
            
            // Xử lý click button xem chi tiết
            $(document).on('click', '.view-message-btn', function(e) {
                e.preventDefault();
                e.stopPropagation();
                console.log('View button clicked');
                var $btn = $(this);
                var messageId = $btn.data('message-id');
                console.log('Message ID:', messageId, 'Button:', $btn);
                if (messageId) {
                    viewMessage(messageId, $btn);
                } else {
                    console.error('Message ID not found');
                    alert('Không tìm thấy ID tin nhắn');
                }
                return false;
            });
            
            // Xử lý click button đánh dấu đã đọc
            $(document).on('click', '.mark-read-btn', function(e) {
                e.preventDefault();
                e.stopPropagation();
                var messageId = $(this).data('message-id');
                updateStatus(messageId, 'read');
                return false;
            });
            
            // Xử lý click button đánh dấu đã liên hệ
            $(document).on('click', '.mark-replied-btn', function(e) {
                e.preventDefault();
                e.stopPropagation();
                var messageId = $(this).data('message-id');
                showMarkContactedModal(messageId);
                return false;
            });
            
            // Xác nhận đánh dấu đã liên hệ - sử dụng event delegation
            $(document).on('click', '#btnConfirmContacted', function(e) {
                e.preventDefault();
                e.stopPropagation();
                console.log('Confirm button clicked');
                
                var contactMethod = $('#contactMethod').val();
                var customerType = $('#customerType').val();
                var address = $('#address').val();
                var companyName = $('#companyName').val();
                var taxCode = $('#taxCode').val();
                
                // Validation: Kiểm tra phương thức liên hệ
                if (!contactMethod || contactMethod.trim() === '') {
                    alert('Vui lòng chọn phương thức liên hệ!');
                    return false;
                }
                
                // Nếu chọn "Khác", lấy giá trị từ input
                if (contactMethod === 'Khác') {
                    var otherMethod = $('#otherMethod').val();
                    if (!otherMethod || otherMethod.trim() === '') {
                        alert('Vui lòng nhập phương thức liên hệ!');
                        return false;
                    }
                    contactMethod = otherMethod.trim();
                }
                
                // Validation: Kiểm tra loại khách hàng
                if (!customerType || customerType.trim() === '') {
                    alert('Vui lòng chọn loại khách hàng!');
                    $('#customerType').focus();
                    return false;
                }
                
                // Validation: Nếu là doanh nghiệp, kiểm tra tên công ty
                if (customerType === 'company') {
                    if (!companyName || companyName.trim() === '') {
                        alert('Vui lòng nhập tên công ty!');
                        $('#companyName').focus();
                        return false;
                    }
                }
                
                // Gửi request cập nhật
                $.ajax({
                    url: 'contact-management',
                    type: 'POST',
                    data: {
                        action: 'updateStatus',
                        id: currentMessageId,
                        status: 'replied',
                        contactMethod: contactMethod,
                        address: address ? address.trim() : '',
                        customerType: customerType,
                        companyName: companyName ? companyName.trim() : '',
                        taxCode: taxCode ? taxCode.trim() : ''
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            alert('✓ ' + response.message);
                            $('#markContactedModal').modal('hide');
                            location.reload();
                        } else {
                            alert('✗ ' + response.message);
                        }
                    },
                    error: function() {
                        alert('✗ Không thể cập nhật. Vui lòng thử lại!');
                    }
                });
                
                return false;
            });
        });
        
        // Xem chi tiết tin nhắn
        function viewMessage(messageId, $button) {
            console.log('viewMessage called with messageId:', messageId, 'button:', $button);
            currentMessageId = messageId;
            
            // Nếu không có button, tìm lại từ messageId
            if (!$button || $button.length === 0) {
                $button = $('.view-message-btn[data-message-id="' + messageId + '"]');
                console.log('Button found by ID:', $button.length);
            }
            
            // Tìm dòng trong bảng - ưu tiên sử dụng closest từ button
            var row = null;
            if ($button && $button.length > 0) {
                row = $button.closest('tr');
                console.log('Row found by closest:', row.length);
            }
            
            // Nếu không tìm được bằng cách trên, thử tìm bằng ID
            if (!row || row.length === 0) {
                row = $('#messagesTable tbody tr').filter(function() {
                    var firstTdText = $(this).find('td:first').text().trim();
                    var match = firstTdText == messageId || parseInt(firstTdText) == messageId;
                    if (match) console.log('Row found by ID filter:', $(this).find('td:first').text());
                    return match;
                });
                console.log('Row found by ID filter:', row.length);
            }
            
            // Nếu vẫn không tìm được, thử tìm bằng data attribute
            if (!row || row.length === 0) {
                row = $('#messagesTable tbody tr').has('.view-message-btn[data-message-id="' + messageId + '"]');
                console.log('Row found by has selector:', row.length);
            }
            
            if (!row || row.length === 0) {
                console.error('Không tìm thấy dòng cho messageId:', messageId);
                console.error('Total rows in table:', $('#messagesTable tbody tr').length);
                alert('Không tìm thấy tin nhắn với ID: ' + messageId);
                return;
            }
            
            console.log('Row found successfully, columns:', row.find('td').length);
            
            // Lấy thông tin từ bảng
            var fullName = row.find('td:eq(1)').text().trim();
            var email = row.find('td:eq(2)').text().trim();
            var phone = row.find('td:eq(3)').text().trim();
            var message = row.find('td:eq(4)').text().trim();
            var status = row.find('td:eq(5) span').text().trim();
            var createdAt = row.find('td:eq(6)').text().trim();
            var repliedAt = row.find('td:eq(7)').text().trim();
            
            // Lấy các thông tin bổ sung từ data attribute của button (ưu tiên button được click)
            var $viewBtn = $button && $button.length > 0 ? $button : row.find('.view-message-btn');
            var contactMethod = String($viewBtn.data('contact-method') || '');
            var address = String($viewBtn.data('address') || '');
            var customerType = String($viewBtn.data('customer-type') || '');
            var companyName = String($viewBtn.data('company-name') || '');
            var taxCode = String($viewBtn.data('tax-code') || '');
            
            // Lấy toàn bộ nội dung tin nhắn (có thể cần gọi API)
            // Tạm thời dùng nội dung từ bảng
            var html = '<div class="row">';
            html += '<div class="col-md-12">';
            html += '<h5 style="margin-top: 0; margin-bottom: 20px; color: #333; border-bottom: 2px solid #eee; padding-bottom: 10px;">Thông tin liên hệ</h5>';
            html += '<div class="form-group">';
            html += '<label>Họ tên:</label>';
            html += '<p class="form-control-static"><strong>' + escapeHtml(fullName) + '</strong></p>';
            html += '</div>';
            html += '<div class="form-group">';
            html += '<label>Email:</label>';
            html += '<p class="form-control-static"><a href="mailto:' + escapeHtml(email) + '">' + escapeHtml(email) + '</a></p>';
            html += '</div>';
            html += '<div class="form-group">';
            html += '<label>Số điện thoại:</label>';
            html += '<p class="form-control-static"><a href="tel:' + escapeHtml(phone) + '">' + escapeHtml(phone) + '</a></p>';
            html += '</div>';
            if (address && String(address).trim() !== '') {
                html += '<div class="form-group">';
                html += '<label>Địa chỉ:</label>';
                html += '<p class="form-control-static">' + escapeHtml(String(address)) + '</p>';
                html += '</div>';
            }
            html += '<div class="form-group">';
            html += '<label>Trạng thái:</label>';
            html += '<p class="form-control-static"><span class="label label-' + (status === 'Mới' ? 'danger' : status === 'Đã liên hệ ' ? 'success' : 'info') + '">' + escapeHtml(status) + '</span></p>';
            html += '</div>';
            html += '<div class="form-group">';
            html += '<label>Ngày gửi:</label>';
            html += '<p class="form-control-static">' + escapeHtml(createdAt) + '</p>';
            html += '</div>';
            if (repliedAt && repliedAt !== '-') {
                html += '<div class="form-group">';
                html += '<label>Ngày phản hồi:</label>';
                html += '<p class="form-control-static">' + escapeHtml(repliedAt) + '</p>';
                html += '</div>';
            }
            if (contactMethod && String(contactMethod).trim() !== '') {
                html += '<div class="form-group">';
                html += '<label>Phương thức liên hệ:</label>';
                html += '<p class="form-control-static"><span class="label label-info">' + escapeHtml(String(contactMethod)) + '</span></p>';
                html += '</div>';
            }
            html += '<hr>';
            html += '<h5 style="margin-top: 0; margin-bottom: 20px; color: #333; border-bottom: 2px solid #eee; padding-bottom: 10px;">Thông tin khách hàng</h5>';
            if (customerType && String(customerType).trim() !== '') {
                html += '<div class="form-group">';
                html += '<label>Loại khách hàng:</label>';
                var customerTypeLabel = String(customerType) === 'company' ? 'Doanh nghiệp' : 'Cá nhân';
                html += '<p class="form-control-static"><span class="label label-primary">' + escapeHtml(customerTypeLabel) + '</span></p>';
                html += '</div>';
            }
            if (companyName && String(companyName).trim() !== '') {
                html += '<div class="form-group">';
                html += '<label>Tên công ty:</label>';
                html += '<p class="form-control-static"><strong>' + escapeHtml(String(companyName)) + '</strong></p>';
                html += '</div>';
            }
            if (taxCode && String(taxCode).trim() !== '') {
                html += '<div class="form-group">';
                html += '<label>Mã số thuế:</label>';
                html += '<p class="form-control-static">' + escapeHtml(String(taxCode)) + '</p>';
                html += '</div>';
            }
            html += '<hr>';
            html += '<div class="form-group">';
            html += '<label>Nội dung tin nhắn:</label>';
            html += '<div class="message-detail" style="background: #f9f9f9; padding: 15px; border-radius: 5px; border: 1px solid #ddd;">';
            html += escapeHtml(message);
            html += '</div>';
            html += '</div>';
            html += '</div>';
            html += '</div>';
            html += '</div>';
            
            $('#messageDetailContent').html(html);
            
            // Nếu chưa đọc, tự động đánh dấu đã đọc sau khi modal hiển thị
            var isNewMessage = (status === 'Mới');
            
            // Đăng ký event một lần để xử lý cập nhật trạng thái
            $('#viewMessageModal').off('shown.bs.modal.viewMessage').on('shown.bs.modal.viewMessage', function() {
                if (isNewMessage) {
                    updateStatus(messageId, 'read', false, false);
                }
            });
            
            // Hiển thị modal
            $('#viewMessageModal').modal('show');
        }
        
        // Cập nhật trạng thái
        function updateStatus(messageId, status, showAlert, reload) {
            if (showAlert === undefined) showAlert = true;
            if (reload === undefined) reload = true;
            
            if (showAlert && !confirm('Bạn có chắc muốn cập nhật trạng thái?')) {
                return;
            }
            
            $.ajax({
                url: 'contact-management',
                type: 'POST',
                data: {
                    action: 'updateStatus',
                    id: messageId,
                    status: status
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        if (showAlert) {
                            alert('✓ ' + response.message);
                        }
                        // Chỉ reload nếu được yêu cầu
                        if (reload) {
                            location.reload();
                        } else {
                            // Nếu đang mở modal, đánh dấu để reload sau khi đóng
                            if ($('#viewMessageModal').hasClass('in') || $('#viewMessageModal').is(':visible')) {
                                shouldReloadAfterModalClose = true;
                            } else {
                                location.reload();
                            }
                        }
                    } else {
                        alert('✗ ' + response.message);
                    }
                },
                error: function() {
                    alert('✗ Không thể cập nhật. Vui lòng thử lại!');
                }
            });
        }
        
        // Đánh dấu đã phản hồi từ modal xem chi tiết
        $('#btnMarkAsReplied').click(function() {
            if (currentMessageId) {
                $('#viewMessageModal').modal('hide');
                showMarkContactedModal(currentMessageId);
            }
        });
        
        // Hiển thị modal đánh dấu đã liên hệ
        function showMarkContactedModal(messageId) {
            currentMessageId = messageId;
            
            // Tìm dòng trong bảng
            var row = $('#messagesTable tbody tr').filter(function() {
                return $(this).find('td:first').text() == messageId;
            });
            
            if (row.length === 0) {
                alert('Không tìm thấy tin nhắn');
                return;
            }
            
            // Lấy thông tin từ bảng
            var fullName = row.find('td:eq(1)').text().trim();
            var email = row.find('td:eq(2)').text().trim();
            var phone = row.find('td:eq(3)').text().trim();
            var message = row.find('td:eq(4)').text().trim();
            var status = row.find('td:eq(5) span').text().trim();
            var createdAt = row.find('td:eq(6)').text().trim();
            
            // Tạo HTML với thông tin đầy đủ và form
            var html = '<div class="row">';
            html += '<div class="col-md-12">';
            html += '<h5 style="margin-top: 0; margin-bottom: 20px; color: #333;">Thông tin liên hệ</h5>';
            html += '<div class="form-group">';
            html += '<label>Họ tên:</label>';
            html += '<p class="form-control-static"><strong>' + escapeHtml(fullName) + '</strong></p>';
            html += '</div>';
            html += '<div class="form-group">';
            html += '<label>Email:</label>';
            html += '<p class="form-control-static"><a href="mailto:' + escapeHtml(email) + '">' + escapeHtml(email) + '</a></p>';
            html += '</div>';
            html += '<div class="form-group">';
            html += '<label>Số điện thoại:</label>';
            html += '<p class="form-control-static"><a href="tel:' + escapeHtml(phone) + '">' + escapeHtml(phone) + '</a></p>';
            html += '</div>';
            html += '<div class="form-group">';
            html += '<label>Nội dung tin nhắn:</label>';
            html += '<div class="message-detail" style="background: #f9f9f9; padding: 15px; border-radius: 5px; border: 1px solid #ddd; max-height: 150px; overflow-y: auto;">';
            html += escapeHtml(message);
            html += '</div>';
            html += '</div>';
            html += '<div class="form-group">';
            html += '<label>Ngày gửi:</label>';
            html += '<p class="form-control-static">' + escapeHtml(createdAt) + '</p>';
            html += '</div>';
            html += '<hr>';
            html += '<h5 style="margin-top: 0; margin-bottom: 20px; color: #333;">Thông tin bổ sung</h5>';
            html += '<div class="form-group">';
            html += '<label for="address">Địa chỉ:</label>';
            html += '<input type="text" class="form-control" id="address" placeholder="Nhập địa chỉ" maxlength="500">';
            html += '</div>';
            html += '<div class="form-group">';
            html += '<label for="customerType">Loại khách hàng: <span style="color: red;">*</span></label>';
            html += '<select class="form-control" id="customerType" required>';
            html += '<option value="">-- Chọn loại khách hàng --</option>';
            html += '<option value="individual">Cá nhân</option>';
            html += '<option value="company">Doanh nghiệp</option>';
            html += '</select>';
            html += '</div>';
            html += '<div class="form-group" id="companyFieldsGroup" style="display: none;">';
            html += '<label for="companyName">Tên công ty: <span style="color: red;">*</span></label>';
            html += '<input type="text" class="form-control" id="companyName" placeholder="Nhập tên công ty" maxlength="255">';
            html += '</div>';
            html += '<div class="form-group" id="taxCodeFieldsGroup" style="display: none;">';
            html += '<label for="taxCode">Mã số thuế:</label>';
            html += '<input type="text" class="form-control" id="taxCode" placeholder="Nhập mã số thuế" maxlength="50">';
            html += '</div>';
            html += '<hr>';
            html += '<div class="form-group">';
            html += '<label for="contactMethod">Đã liên hệ bằng gì? <span style="color: red;">*</span></label>';
            html += '<select class="form-control" id="contactMethod" required>';
            html += '<option value="">-- Chọn phương thức liên hệ --</option>';
            html += '<option value="Email">Email</option>';
            html += '<option value="Điện thoại">Điện thoại</option>';
            html += '<option value="Tin nhắn">Tin nhắn</option>';
            html += '<option value="Trực tiếp">Trực tiếp</option>';
            html += '<option value="Khác">Khác</option>';
            html += '</select>';
            html += '</div>';
            html += '<div class="form-group" id="otherMethodGroup" style="display: none;">';
            html += '<label for="otherMethod">Mô tả phương thức khác:</label>';
            html += '<input type="text" class="form-control" id="otherMethod" placeholder="Nhập phương thức liên hệ">';
            html += '</div>';
            html += '</div>';
            html += '</div>';
            
            $('#markContactedContent').html(html);
            
            // Xử lý khi chọn loại khách hàng - sử dụng off để tránh đăng ký nhiều lần
            $('#customerType').off('change').on('change', function() {
                var customerType = $(this).val();
                if (customerType === 'company') {
                    $('#companyFieldsGroup').show();
                    $('#taxCodeFieldsGroup').show();
                    $('#companyName').prop('required', true);
                } else {
                    $('#companyFieldsGroup').hide();
                    $('#taxCodeFieldsGroup').hide();
                    $('#companyName').prop('required', false);
                    $('#taxCode').prop('required', false);
                    $('#companyName').val('');
                    $('#taxCode').val('');
                }
            });
            
            // Xử lý khi chọn "Khác" - sử dụng off để tránh đăng ký nhiều lần
            $('#contactMethod').off('change').on('change', function() {
                if ($(this).val() === 'Khác') {
                    $('#otherMethodGroup').show();
                    $('#otherMethod').prop('required', true);
                } else {
                    $('#otherMethodGroup').hide();
                    $('#otherMethod').prop('required', false);
                    $('#otherMethod').val('');
                }
            });
            
            // Hiển thị modal
            $('#markContactedModal').modal('show');
        }
        
        
        // Hàm escape HTML
        function escapeHtml(text) {
            var map = {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#039;'
            };
            return text.replace(/[&<>"']/g, function(m) { return map[m]; });
        }
    </script>
</body>
</html>

