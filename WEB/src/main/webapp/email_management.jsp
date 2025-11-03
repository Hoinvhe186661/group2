<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.text.SimpleDateFormat, com.hlgenerator.model.EmailNotification" %>
<%
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    String userRole = (String) session.getAttribute("userRole");
    if (!"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/admin.jsp");
        return;
    }
    
    @SuppressWarnings("unchecked")
    List<EmailNotification> emails = (List<EmailNotification>) request.getAttribute("emails");
    if (emails == null) emails = new java.util.ArrayList<EmailNotification>();
    
    String action = request.getParameter("action");
    String filterEmailType = (String) request.getAttribute("filterEmailType");
    String filterStatus = (String) request.getAttribute("filterStatus");
    String filterSearch = (String) request.getAttribute("filterSearch");
    String filterStartDate = (String) request.getAttribute("filterStartDate");
    String filterEndDate = (String) request.getAttribute("filterEndDate");
    
    EmailNotification viewEmail = (EmailNotification) request.getAttribute("email");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý Email</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <!-- CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="css/datatables/dataTables.bootstrap.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css" rel="stylesheet" type="text/css" />
    
    <style>
        .email-content-preview {
            max-height: 100px;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .filter-section {
            background: #f9f9f9;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .action-buttons {
            white-space: nowrap;
        }
        .action-buttons .btn {
            margin: 1px;
        }
    </style>
</head>

<body class="skin-black">
    <!-- Header -->
    <header class="header">
        <a href="admin.jsp" class="logo">Bảng điều khiển</a>
        <nav class="navbar navbar-static-top" role="navigation">
            <a href="#" class="navbar-btn sidebar-toggle" data-toggle="offcanvas" role="button">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </a>
            <div class="navbar-right">
                <ul class="nav navbar-nav">
                    <li class="dropdown user user-menu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="fa fa-user"></i>
                            <span><%= username %> <i class="caret"></i></span>
                        </a>
                        <ul class="dropdown-menu dropdown-custom dropdown-menu-right">
                            <li class="dropdown-header text-center">Tài khoản</li>
                            <li><a href="profile.jsp"><i class="fa fa-user fa-fw pull-right"></i> Hồ sơ</a></li>
                            <li><a href="settings.jsp"><i class="fa fa-cog fa-fw pull-right"></i> Cài đặt</a></li>
                            <li class="divider"></li>
                            <li><a href="logout"><i class="fa fa-ban fa-fw pull-right"></i> Đăng xuất</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </nav>
    </header>
    
    <div class="wrapper row-offcanvas row-offcanvas-left">
        <!-- Sidebar -->
        <aside class="left-side sidebar-offcanvas">
            <section class="sidebar">
                <div class="user-panel">
                    <div class="pull-left image">
                        <img src="img/26115.jpg" class="img-circle" alt="User Image" />
                    </div>
                    <div class="pull-left info">
                        <p>Xin chào, <%= username %></p>
                        <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
                    </div>
                </div>
                <ul class="sidebar-menu">
                    <li><a href="admin.jsp"><i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span></a></li>
                    <li><a href="customers"><i class="fa fa-users"></i> <span>Quản lý khách hàng</span></a></li>
                    <li><a href="users"><i class="fa fa-user-secret"></i> <span>Quản lý người dùng</span></a></li>
                    <li class="active"><a href="email-management"><i class="fa fa-envelope"></i> <span>Quản lý Email</span></a></li>
                    <li><a href="reports.jsp"><i class="fa fa-bar-chart"></i> <span>Báo cáo</span></a></li>
                    <li><a href="settings.jsp"><i class="fa fa-cog"></i> <span>Cài đặt</span></a></li>
                </ul>
            </section>
        </aside>

        <aside class="right-side">
            <section class="content">
                <%
                    if ("create".equals(action)) {
                %>
                <!-- Create Email Form -->
                <div class="row">
                    <div class="col-md-12">
                        <section class="panel">
                            <header class="panel-heading">
                                <h3><i class="fa fa-envelope"></i> Tạo Email Mới</h3>
                            </header>
                            <div class="panel-body">
                                <form id="emailForm" method="post" action="email-management" enctype="multipart/form-data">
                                    <input type="hidden" name="action" value="send">
                                    
                                    <div class="form-group">
                                        <label>Loại Email <span class="text-danger">*</span></label>
                                        <select name="emailType" id="emailType" class="form-control" required>
                                            <option value="internal">Email Nội bộ</option>
                                            <option value="marketing">Email Marketing</option>
                                        </select>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label>Tiêu đề <span class="text-danger">*</span></label>
                                        <input type="text" name="subject" id="subject" class="form-control" 
                                               placeholder="Nhập tiêu đề email" required>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label>Chọn Role người nhận</label>
                                        <div style="max-height: 200px; overflow-y: auto; border: 1px solid #ddd; padding: 10px; border-radius: 4px;">
                                            <label class="checkbox-inline"><input type="checkbox" name="roles" value="admin"> Admin</label><br>
                                            <label class="checkbox-inline"><input type="checkbox" name="roles" value="customer_support"> Hỗ trợ khách hàng</label><br>
                                            <label class="checkbox-inline"><input type="checkbox" name="roles" value="technical_staff"> Nhân viên kỹ thuật</label><br>
                                            <label class="checkbox-inline"><input type="checkbox" name="roles" value="head_technician"> Trưởng phòng kỹ thuật</label><br>
                                            <label class="checkbox-inline"><input type="checkbox" name="roles" value="storekeeper"> Thủ kho</label><br>
                                            <label class="checkbox-inline"><input type="checkbox" name="roles" value="customer"> Khách hàng</label><br>
                                        </div>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label>Hoặc nhập email trực tiếp (mỗi email một dòng hoặc phân cách bằng dấu phẩy)</label>
                                        <textarea name="customEmails" id="customEmails" class="form-control" 
                                                  rows="4" placeholder="user1@example.com&#10;user2@example.com"></textarea>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label>Nội dung <span class="text-danger">*</span></label>
                                        <textarea name="content" id="content" class="form-control" 
                                                  rows="10" placeholder="Nhập nội dung email" required></textarea>
                                        <small class="text-muted">Hỗ trợ HTML hoặc văn bản thuần</small>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label>File đính kèm (có thể chọn nhiều file)</label>
                                        <input type="file" name="attachments" id="attachments" 
                                               class="form-control" multiple accept="*/*">
                                        <small class="text-muted">Tối đa 10MB mỗi file, tổng tối đa 50MB</small>
                                        <div id="fileList" style="margin-top: 10px;"></div>
                                    </div>
                                    
                                    <div class="form-group">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fa fa-paper-plane"></i> Gửi Email
                                        </button>
                                        <a href="email-management" class="btn btn-default">
                                            <i class="fa fa-times"></i> Hủy
                                        </a>
                                        <button type="button" class="btn btn-info" id="testConnectionBtn">
                                            <i class="fa fa-plug"></i> Kiểm tra kết nối
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </section>
                    </div>
                </div>
                
                <%
                    } else if ("view".equals(action) && viewEmail != null) {
                %>
                <!-- View Email Details -->
                <div class="row">
                    <div class="col-md-12">
                        <section class="panel">
                            <header class="panel-heading">
                                <h3><i class="fa fa-eye"></i> Chi tiết Email</h3>
                            </header>
                            <div class="panel-body">
                                <div class="form-horizontal">
                                    <div class="form-group">
                                        <label class="col-sm-2">Tiêu đề:</label>
                                        <div class="col-sm-10">
                                            <p class="form-control-static"><strong><%= viewEmail.getSubject() %></strong></p>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2">Loại:</label>
                                        <div class="col-sm-10">
                                            <p class="form-control-static">
                                                <span class="label label-info"><%= viewEmail.getEmailTypeDisplayName() %></span>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2">Trạng thái:</label>
                                        <div class="col-sm-10">
                                            <p class="form-control-static">
                                                <span class="label <%= viewEmail.getStatusBadgeClass() %>">
                                                    <%= viewEmail.getStatusDisplayName() %>
                                                </span>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2">Số người nhận:</label>
                                        <div class="col-sm-10">
                                            <p class="form-control-static">
                                                Tổng: <strong><%= viewEmail.getRecipientCount() %></strong> | 
                                                Thành công: <span class="text-success"><strong><%= viewEmail.getSuccessCount() %></strong></span> | 
                                                Thất bại: <span class="text-danger"><strong><%= viewEmail.getFailedCount() %></strong></span>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2">Người gửi:</label>
                                        <div class="col-sm-10">
                                            <p class="form-control-static"><%= viewEmail.getSentByName() %></p>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2">Thời gian tạo:</label>
                                        <div class="col-sm-10">
                                            <p class="form-control-static">
                                                <%= viewEmail.getCreatedAt() != null ? dateFormat.format(viewEmail.getCreatedAt()) : "N/A" %>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2">Thời gian gửi:</label>
                                        <div class="col-sm-10">
                                            <p class="form-control-static">
                                                <%= viewEmail.getSentAt() != null ? dateFormat.format(viewEmail.getSentAt()) : "Chưa gửi" %>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2">Nội dung:</label>
                                        <div class="col-sm-10">
                                            <div class="well" style="white-space: pre-wrap;"><%= viewEmail.getContent() %></div>
                                        </div>
                                    </div>
                                    <% if (viewEmail.getErrorMessage() != null && !viewEmail.getErrorMessage().isEmpty()) { %>
                                    <div class="form-group">
                                        <label class="col-sm-2">Lỗi:</label>
                                        <div class="col-sm-10">
                                            <p class="form-control-static text-danger"><%= viewEmail.getErrorMessage() %></p>
                                        </div>
                                    </div>
                                    <% } %>
                                </div>
                                <div class="form-group">
                                    <a href="email-management" class="btn btn-default">
                                        <i class="fa fa-arrow-left"></i> Quay lại
                                    </a>
                                </div>
                            </div>
                        </section>
                    </div>
                </div>
                
                <%
                    } else {
                %>
                <!-- Email List -->
                <div class="row">
                    <div class="col-md-12">
                        <section class="panel">
                            <header class="panel-heading">
                                <h3><i class="fa fa-envelope"></i> Quản lý Email</h3>
                            </header>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <a href="email-management?action=create" class="btn btn-primary">
                                            <i class="fa fa-plus"></i> Tạo Email Mới
                                        </a>
                                    </div>
                                </div>
                                
                                <!-- Filters -->
                                <div class="filter-section">
                                    <form id="filterForm" method="get" action="email-management">
                                        <div class="row">
                                            <div class="col-md-2">
                                                <div class="form-group">
                                                    <label>Loại Email</label>
                                                    <select name="emailType" class="form-control">
                                                        <option value="">Tất cả</option>
                                                        <option value="internal" <%= "internal".equals(filterEmailType) ? "selected" : "" %>>Nội bộ</option>
                                                        <option value="marketing" <%= "marketing".equals(filterEmailType) ? "selected" : "" %>>Marketing</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="form-group">
                                                    <label>Trạng thái</label>
                                                    <select name="status" class="form-control">
                                                        <option value="">Tất cả</option>
                                                        <option value="pending" <%= "pending".equals(filterStatus) ? "selected" : "" %>>Chờ gửi</option>
                                                        <option value="sending" <%= "sending".equals(filterStatus) ? "selected" : "" %>>Đang gửi</option>
                                                        <option value="completed" <%= "completed".equals(filterStatus) ? "selected" : "" %>>Hoàn thành</option>
                                                        <option value="failed" <%= "failed".equals(filterStatus) ? "selected" : "" %>>Thất bại</option>
                                                        <option value="partial" <%= "partial".equals(filterStatus) ? "selected" : "" %>>Một phần</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="form-group">
                                                    <label>Từ ngày</label>
                                                    <input type="date" name="startDate" class="form-control" value="<%= filterStartDate != null ? filterStartDate : "" %>">
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="form-group">
                                                    <label>Đến ngày</label>
                                                    <input type="date" name="endDate" class="form-control" value="<%= filterEndDate != null ? filterEndDate : "" %>">
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="form-group">
                                                    <label>Tìm kiếm</label>
                                                    <input type="text" name="search" class="form-control" 
                                                           placeholder="Tiêu đề, nội dung..." value="<%= filterSearch != null ? filterSearch : "" %>">
                                                </div>
                                            </div>
                                            <div class="col-md-1">
                                                <div class="form-group">
                                                    <label>&nbsp;</label>
                                                    <button type="submit" class="btn btn-primary form-control">
                                                        <i class="fa fa-search"></i> Lọc
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                                
                                <!-- Email Table -->
                                <div class="table-responsive">
                                    <table class="table table-hover table-striped">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Tiêu đề</th>
                                                <th>Loại</th>
                                                <th>Trạng thái</th>
                                                <th>Số người nhận</th>
                                                <th>Người gửi</th>
                                                <th>Ngày tạo</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (emails.isEmpty()) { %>
                                            <tr>
                                                <td colspan="8" class="text-center">Không có dữ liệu</td>
                                            </tr>
                                            <% } else { 
                                                for (EmailNotification email : emails) {
                                            %>
                                            <tr>
                                                <td><%= email.getId() %></td>
                                                <td><%= email.getSubject() %></td>
                                                <td><span class="label label-info"><%= email.getEmailTypeDisplayName() %></span></td>
                                                <td><span class="label <%= email.getStatusBadgeClass() %>"><%= email.getStatusDisplayName() %></span></td>
                                                <td>
                                                    <small>
                                                        Tổng: <strong><%= email.getRecipientCount() %></strong><br>
                                                        Thành công: <span class="text-success"><%= email.getSuccessCount() %></span> | 
                                                        Thất bại: <span class="text-danger"><%= email.getFailedCount() %></span>
                                                    </small>
                                                </td>
                                                <td><%= email.getSentByName() %></td>
                                                <td><%= email.getCreatedAt() != null ? dateFormat.format(email.getCreatedAt()) : "N/A" %></td>
                                                <td class="action-buttons">
                                                    <a href="email-management?action=view&id=<%= email.getId() %>" 
                                                       class="btn btn-xs btn-info" title="Xem chi tiết">
                                                        <i class="fa fa-eye"></i>
                                                    </a>
                                                    <button class="btn btn-xs btn-danger delete-email" 
                                                            data-id="<%= email.getId() %>" title="Xóa">
                                                        <i class="fa fa-trash"></i>
                                                    </button>
                                                </td>
                                            </tr>
                                            <% }
                                               } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </section>
                    </div>
                </div>
                <% } %>
            </section>
            
            <div class="footer-main">
                Copyright &copy Bảng điều khiển quản trị, 2025
            </div>
        </aside>
    </div>

    <!-- jQuery -->
    <script src="js/jquery.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/Director/app.js"></script>
    
    <script>
        $(document).ready(function() {
            // Show selected files
            $('#attachments').on('change', function() {
                var files = this.files;
                var fileList = $('#fileList');
                fileList.empty();
                
                if (files.length > 0) {
                    var html = '<div class="alert alert-info"><strong>File đã chọn:</strong><ul>';
                    for (var i = 0; i < files.length; i++) {
                        var fileSize = (files[i].size / 1024 / 1024).toFixed(2);
                        html += '<li>' + files[i].name + ' (' + fileSize + ' MB)</li>';
                    }
                    html += '</ul></div>';
                    fileList.html(html);
                }
            });
            
            // Handle email form submission
            $('#emailForm').on('submit', function(e) {
                e.preventDefault();
                
                var hasRole = $('input[name="roles"]:checked').length > 0;
                var hasEmail = $('#customEmails').val().trim().length > 0;
                
                if (!hasRole && !hasEmail) {
                    alert('Vui lòng chọn ít nhất một role hoặc nhập email người nhận');
                    return;
                }
                
                // Validate file sizes
                var files = $('#attachments')[0].files;
                var totalSize = 0;
                for (var i = 0; i < files.length; i++) {
                    totalSize += files[i].size;
                    if (files[i].size > 10 * 1024 * 1024) {
                        alert('File "' + files[i].name + '" vượt quá 10MB');
                        return;
                    }
                }
                if (totalSize > 50 * 1024 * 1024) {
                    alert('Tổng dung lượng file vượt quá 50MB');
                    return;
                }
                
                if (!confirm('Bạn có chắc chắn muốn gửi email này?')) {
                    return;
                }
                
                // Create FormData for file upload
                var formData = new FormData(this);
                
                $.ajax({
                    url: 'email-management',
                    type: 'POST',
                    data: formData,
                    processData: false,
                    contentType: false,
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            window.location.href = 'email-management';
                        } else {
                            alert('Lỗi: ' + response.message);
                        }
                    },
                    error: function() {
                        alert('Có lỗi xảy ra khi gửi email');
                    }
                });
            });
            
            // Test connection
            $('#testConnectionBtn').on('click', function() {
                $.ajax({
                    url: 'email-management?action=testConnection',
                    type: 'GET',
                    dataType: 'json',
                    success: function(response) {
                        alert(response.message);
                    },
                    error: function() {
                        alert('Không thể kiểm tra kết nối');
                    }
                });
            });
            
            // Delete email
            $('.delete-email').on('click', function() {
                var id = $(this).data('id');
                if (confirm('Bạn có chắc chắn muốn xóa email notification này?')) {
                    $.ajax({
                        url: 'email-management',
                        type: 'POST',
                        data: {
                            action: 'delete',
                            id: id
                        },
                        dataType: 'json',
                        success: function(response) {
                            alert(response.message);
                            if (response.success) {
                                location.reload();
                            }
                        },
                        error: function() {
                            alert('Có lỗi xảy ra khi xóa');
                        }
                    });
                }
            });
        });
    </script>
</body>
</html>

