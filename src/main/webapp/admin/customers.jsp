<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng điều khiển | Quản lý khách hàng</title>
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
    <link href='http://fonts.googleapis.com/css?family=Lato' rel='stylesheet' type='text/css'>
</head>
<body class="skin-black">
    <!-- header logo: style can be found in header.less -->
    <header class="header">
        <a href="admin.jsp" class="logo">
            Bảng điều khiển quản trị
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
                            <span>Admin <i class="caret"></i></span>
                        </a>
                        <ul class="dropdown-menu dropdown-custom dropdown-menu-right">
                            <li class="dropdown-header text-center">Tài khoản</li>
                            <li>
                                <a href="#">
                                <i class="fa fa-user fa-fw pull-right"></i>
                                    Hồ sơ
                                </a>
                                <a data-toggle="modal" href="#modal-user-settings">
                                <i class="fa fa-cog fa-fw pull-right"></i>
                                    Cài đặt
                                </a>
                            </li>
                            <li class="divider"></li>
                            <li>
                                <a href="../index.jsp"><i class="fa fa-ban fa-fw pull-right"></i> Đăng xuất</a>
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
                        <p>Xin chào, Admin</p>
                        <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
                    </div>
                </div>
                <!-- sidebar menu: : style can be found in sidebar.less -->
                <ul class="sidebar-menu">
                    <li>
                        <a href="admin.jsp">
                            <i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
                        </a>
                    </li>
                    <li>
                        <a href="products.jsp">
                            <i class="fa fa-shopping-cart"></i> <span>Quản lý sản phẩm</span>
                        </a>
                    </li>
                    <li>
                        <a href="orders.jsp">
                            <i class="fa fa-file-text-o"></i> <span>Quản lý đơn hàng</span>
                        </a>
                    </li>
                    <li class="active">
                        <a href="customers.jsp">
                            <i class="fa fa-users"></i> <span>Quản lý khách hàng</span>
                        </a>
                    </li>
                    <li>
                        <a href="reports.jsp">
                            <i class="fa fa-bar-chart"></i> <span>Báo cáo</span>
                        </a>
                    </li>
                    <li>
                        <a href="settings.jsp">
                            <i class="fa fa-cog"></i> <span>Cài đặt</span>
                        </a>
                    </li>
                </ul>
            </section>
            <!-- /.sidebar -->
        </aside>

        <aside class="right-side">
            <!-- Main content -->
            <section class="content">
                <div class="row">
                    <div class="col-xs-12">
                        <div class="panel">
                            <header class="panel-heading">
                                <h3>Quản lý khách hàng</h3>
                                <div class="panel-tools">
                                    <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addCustomerModal">
                                        <i class="fa fa-plus"></i> Thêm khách hàng mới
                                    </button>
                                </div>
                            </header>
                            <div class="panel-body table-responsive">
                                <table class="table table-hover" id="customersTable">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Mã khách hàng</th>
                                            <th>Tên công ty</th>
                                            <th>Người liên hệ</th>
                                            <th>Email</th>
                                            <th>Số điện thoại</th>
                                            <th>Địa chỉ</th>
                                            <th>Mã số thuế</th>
                                            <th>Loại khách hàng</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="customersTableBody">
                                        <%-- Lấy dữ liệu từ backend và render bằng JSP --%>
                                        <%
                                            com.hlgenerator.dao.CustomerDAO dao = new com.hlgenerator.dao.CustomerDAO();
                                            java.util.List<com.hlgenerator.model.Customer> customers = dao.getAllCustomers();
                                            for (com.hlgenerator.model.Customer customer : customers) {
                                        %>
                                        <tr>
                                            <td><%= customer.getId() %></td>
                                            <td><%= customer.getCustomerCode() %></td>
                                            <td><%= customer.getCompanyName() %></td>
                                            <td><%= customer.getContactPerson() %></td>
                                            <td><%= customer.getEmail() %></td>
                                            <td><%= customer.getPhone() %></td>
                                            <td><%= customer.getAddress() %></td>
                                            <td><%= customer.getTaxCode() %></td>
                                            <td><%= "company".equals(customer.getCustomerType()) ? "Doanh nghiệp" : "Cá nhân" %></td>
                                            <td><%= "active".equals(customer.getStatus()) ? "Hoạt động" : "Tạm khóa" %></td>
                                            <td>
                                                <button class="btn btn-info btn-xs" onclick="viewCustomer('<%= customer.getId() %>')"><i class="fa fa-eye"></i> Xem</button>
                                                <button class="btn btn-warning btn-xs" onclick="editCustomer('<%= customer.getId() %>')"><i class="fa fa-edit"></i> Sửa</button>
                                                <% if ("active".equals(customer.getStatus())) { %>
                                                    <button class="btn btn-danger btn-xs" onclick="deleteCustomer('<%= customer.getId() %>')"><i class="fa fa-trash"></i> Xóa</button>
                                                <% } else { %>
                                                    <button class="btn btn-success btn-xs" onclick="activateCustomer('<%= customer.getId() %>')"><i class="fa fa-unlock"></i> Kích hoạt</button>
                                                <% } %>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </section><!-- /.content -->
        </aside><!-- /.right-side -->
    </div><!-- ./wrapper -->

    <!-- Modal thêm khách hàng -->
    <div class="modal fade" id="addCustomerModal" tabindex="-1" role="dialog" aria-labelledby="addCustomerModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="addCustomerModalLabel">Thêm khách hàng mới</h4>
                </div>
                <div class="modal-body">
                    <form id="addCustomerForm">
                        <div class="form-group">
                            <label for="customerCode">Mã khách hàng:</label>
                            <input type="text" class="form-control" id="customerCode" required>
                        </div>
                        <div class="form-group">
                            <label for="companyName">Tên công ty:</label>
                            <input type="text" class="form-control" id="companyName" required>
                        </div>
                        <div class="form-group">
                            <label for="userContract">Người liên hệ:</label>
                            <input type="text" class="form-control" id="userContract" required>
                        </div>
                        <div class="form-group">
                            <label for="customerEmail">Email:</label>
                            <input type="email" class="form-control" id="customerEmail" required>
                        </div>
                        <div class="form-group">
                            <label for="customerPhone">Số điện thoại:</label>
                            <input type="tel" class="form-control" id="customerPhone" required>
                        </div>
                        <div class="form-group">
                            <label for="customerAddress">Địa chỉ:</label>
                            <textarea class="form-control" id="customerAddress" rows="3" required></textarea>
                        </div>
                        <div class="form-group">
                            <label for="taxCode">Mã số thuế:</label>
                            <input type="text" class="form-control" id="taxCode">
                        </div>
                        <div class="form-group">
                            <label for="customerType">Loại khách hàng:</label>
                            <select class="form-control" id="customerType" required>
                                <option value="">Chọn loại khách hàng</option>
                                <option value="individual">Cá nhân</option>
                                <option value="business">Doanh nghiệp</option>
                            </select>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="saveCustomer()">Lưu khách hàng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal xem chi tiết khách hàng -->
    <div class="modal fade" id="customerDetailModal" tabindex="-1" role="dialog" aria-labelledby="customerDetailModalLabel">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="customerDetailModalLabel">Chi tiết khách hàng</h4>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <h5>Thông tin khách hàng</h5>
                            <p><strong>ID:</strong> <span id="detailCustomerId"></span></p>
                            <p><strong>Mã khách hàng:</strong> <span id="detailCustomerCode"></span></p>
                            <p><strong>Tên công ty:</strong> <span id="detailCompanyName"></span></p>
                            <p><strong>Người liên hệ:</strong> <span id="detailUserContract"></span></p>
                            <p><strong>Email:</strong> <span id="detailCustomerEmail"></span></p>
                            <p><strong>Số điện thoại:</strong> <span id="detailCustomerPhone"></span></p>
                            <p><strong>Địa chỉ:</strong> <span id="detailCustomerAddress"></span></p>
                        </div>
                        <div class="col-md-6">
                            <h5>Thông tin bổ sung</h5>
                            <p><strong>Mã số thuế:</strong> <span id="detailTaxCode"></span></p>
                            <p><strong>Loại khách hàng:</strong> <span id="detailCustomerType"></span></p>
                            <p><strong>Ngày đăng ký:</strong> <span id="detailCustomerJoinDate"></span></p>
                            <p><strong>Trạng thái:</strong> <span id="detailCustomerStatus"></span></p>
                            <hr>
                            <h5>Thống kê mua hàng</h5>
                            <p><strong>Tổng đơn hàng:</strong> <span id="detailTotalOrders"></span></p>
                            <p><strong>Tổng chi tiêu:</strong> <span id="detailTotalSpent"></span></p>
                            <p><strong>Đơn hàng gần nhất:</strong> <span id="detailLastOrder"></span></p>
                        </div>
                    </div>
                    <hr>
                    <h5>Lịch sử đơn hàng</h5>
                    <div id="customerOrders"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
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

    <script type="text/javascript">
        var customersTable;
        var currentEditingCustomer = null;

        $(document).ready(function() {
            // Initialize DataTable
            customersTable = $('#customersTable').DataTable({
                "language": {
                    "url": "//cdn.datatables.net/plug-ins/1.10.25/i18n/Vietnamese.json"
                },
                "processing": true,
                "serverSide": false,
                "ajax": {
                    "url": "../api/customers?action=list",
                    "type": "GET",
                    "dataSrc": "data"
                },
                "columns": [
                    { "data": "id" },
                    { "data": "customerCode" },
                    { "data": "companyName" },
                    { "data": "contactPerson" },
                    { "data": "email" },
                    { "data": "phone" },
                    { "data": "address" },
                    { "data": "taxCode" },
                    { 
                        "data": "customerType",
                        "render": function(data, type, row) {
                            var labelClass = data === 'business' ? 'label-primary' : 'label-info';
                            var labelText = data === 'business' ? 'Doanh nghiệp' : 'Cá nhân';
                            return '<span class="label ' + labelClass + '">' + labelText + '</span>';
                        }
                    },
                    {
                        "data": null,
                        "render": function(data, type, row) {
                            var buttons = '<button class="btn btn-info btn-xs" onclick="viewCustomer(' + row.id + ')">' +
                                        '<i class="fa fa-eye"></i> Xem</button> ';
                            
                            buttons += '<button class="btn btn-warning btn-xs" onclick="editCustomer(' + row.id + ')">' +
                                      '<i class="fa fa-edit"></i> Sửa</button> ';
                            
                            if (row.status === 'active') {
                                buttons += '<button class="btn btn-danger btn-xs" onclick="deleteCustomer(' + row.id + ')">' +
                                          '<i class="fa fa-trash"></i> Xóa</button>';
                            } else {
                                buttons += '<button class="btn btn-success btn-xs" onclick="activateCustomer(' + row.id + ')">' +
                                          '<i class="fa fa-unlock"></i> Kích hoạt</button>';
                            }
                            
                            return buttons;
                        }
                    }
                ]
            });

            // Load initial data
            loadCustomers();
        });

        function loadCustomers() {
            $.ajax({
                url: '../api/customers?action=list',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        populateTable(response.data);
                    } else {
                        showAlert('Lỗi khi tải dữ liệu: ' + response.message, 'danger');
                    }
                },
                error: function() {
                    showAlert('Lỗi kết nối đến server', 'danger');
                }
            });
        }

        function populateTable(customers) {
            var tbody = $('#customersTableBody');
            tbody.empty();
            
            customers.forEach(function(customer) {
                var row = '<tr>' +
                    '<td>' + customer.id + '</td>' +
                    '<td>' + customer.customerCode + '</td>' +
                    '<td>' + customer.companyName + '</td>' +
                    '<td>' + customer.contactPerson + '</td>' +
                    '<td>' + customer.email + '</td>' +
                    '<td>' + customer.phone + '</td>' +
                    '<td>' + customer.address + '</td>' +
                    '<td>' + (customer.taxCode || '-') + '</td>' +
                    '<td>' + getCustomerTypeLabel(customer.customerType) + '</td>' +
                    '<td>' + getActionButtons(customer) + '</td>' +
                    '</tr>';
                tbody.append(row);
            });
        }

        function getCustomerTypeLabel(type) {
            if (type === 'business') {
                return '<span class="label label-primary">Doanh nghiệp</span>';
            } else {
                return '<span class="label label-info">Cá nhân</span>';
            }
        }

        function getActionButtons(customer) {
            var buttons = '<button class="btn btn-info btn-xs" onclick="viewCustomer(' + customer.id + ')">' +
                         '<i class="fa fa-eye"></i> Xem</button> ';
            
            buttons += '<button class="btn btn-warning btn-xs" onclick="editCustomer(' + customer.id + ')">' +
                      '<i class="fa fa-edit"></i> Sửa</button> ';
            
            if (customer.status === 'active') {
                buttons += '<button class="btn btn-danger btn-xs" onclick="deleteCustomer(' + customer.id + ')">' +
                          '<i class="fa fa-trash"></i> Xóa</button>';
            } else {
                buttons += '<button class="btn btn-success btn-xs" onclick="activateCustomer(' + customer.id + ')">' +
                          '<i class="fa fa-unlock"></i> Kích hoạt</button>';
            }
            
            return buttons;
        }

        function viewCustomer(id) {
            $.ajax({
                url: '../api/customers?action=get&id=' + id,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        var customer = response.data;
                        populateCustomerDetail(customer);
                        $('#customerDetailModal').modal('show');
                    } else {
                        showAlert('Không thể tải thông tin khách hàng: ' + response.message, 'danger');
                    }
                },
                error: function() {
                    showAlert('Lỗi kết nối đến server', 'danger');
                }
            });
        }

        function populateCustomerDetail(customer) {
            document.getElementById('detailCustomerId').textContent = customer.id;
            document.getElementById('detailCustomerCode').textContent = customer.customerCode;
            document.getElementById('detailCompanyName').textContent = customer.companyName;
            document.getElementById('detailUserContract').textContent = customer.contactPerson;
            document.getElementById('detailCustomerEmail').textContent = customer.email;
            document.getElementById('detailCustomerPhone').textContent = customer.phone;
            document.getElementById('detailCustomerAddress').textContent = customer.address;
            document.getElementById('detailTaxCode').textContent = customer.taxCode || '-';
            document.getElementById('detailCustomerType').innerHTML = getCustomerTypeLabel(customer.customerType);
            document.getElementById('detailCustomerJoinDate').textContent = formatDate(customer.createdAt);
            document.getElementById('detailCustomerStatus').innerHTML = getStatusLabel(customer.status);
            
            // Mock data for orders (in real app, this would come from another API)
            document.getElementById('detailTotalOrders').textContent = '0';
            document.getElementById('detailTotalSpent').textContent = '0 VNĐ';
            document.getElementById('detailLastOrder').textContent = '-';
            
            document.getElementById('customerOrders').innerHTML = '<p class="text-muted">Chưa có đơn hàng nào</p>';
        }

        function getStatusLabel(status) {
            if (status === 'active') {
                return '<span class="label label-success">Hoạt động</span>';
            } else {
                return '<span class="label label-warning">Tạm khóa</span>';
            }
        }

        function formatDate(dateString) {
            if (!dateString) return '-';
            var date = new Date(dateString);
            return date.toLocaleDateString('vi-VN');
        }

        function editCustomer(id) {
            $.ajax({
                url: '../api/customers?action=get&id=' + id,
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        var customer = response.data;
                        populateEditForm(customer);
                        currentEditingCustomer = customer;
                        $('#addCustomerModal').modal('show');
                        $('#addCustomerModalLabel').text('Chỉnh sửa khách hàng');
                    } else {
                        showAlert('Không thể tải thông tin khách hàng: ' + response.message, 'danger');
                    }
                },
                error: function() {
                    showAlert('Lỗi kết nối đến server', 'danger');
                }
            });
        }

        function populateEditForm(customer) {
            document.getElementById('customerCode').value = customer.customerCode;
            document.getElementById('companyName').value = customer.companyName;
            document.getElementById('userContract').value = customer.contactPerson;
            document.getElementById('customerEmail').value = customer.email;
            document.getElementById('customerPhone').value = customer.phone;
            document.getElementById('customerAddress').value = customer.address;
            document.getElementById('taxCode').value = customer.taxCode || '';
            document.getElementById('customerType').value = customer.customerType;
        }

        function deleteCustomer(id) {
            if (confirm('Bạn có chắc chắn muốn xóa khách hàng này?')) {
                $.ajax({
                    url: '../api/customers',
                    type: 'POST',
                    data: {
                        action: 'delete',
                        id: id
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            showAlert('Đã xóa khách hàng thành công', 'success');
                            loadCustomers();
                        } else {
                            showAlert('Lỗi khi xóa khách hàng: ' + response.message, 'danger');
                        }
                    },
                    error: function() {
                        showAlert('Lỗi kết nối đến server', 'danger');
                    }
                });
            }
        }

        function activateCustomer(id) {
            if (confirm('Bạn có chắc chắn muốn kích hoạt khách hàng này?')) {
                $.ajax({
                    url: '../api/customers',
                    type: 'POST',
                    data: {
                        action: 'activate',
                        id: id
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            showAlert('Đã kích hoạt khách hàng thành công', 'success');
                            loadCustomers();
                        } else {
                            showAlert('Lỗi khi kích hoạt khách hàng: ' + response.message, 'danger');
                        }
                    },
                    error: function() {
                        showAlert('Lỗi kết nối đến server', 'danger');
                    }
                });
            }
        }

        function saveCustomer() {
            var customerCode = document.getElementById('customerCode').value;
            var companyName = document.getElementById('companyName').value;
            var userContract = document.getElementById('userContract').value;
            var customerEmail = document.getElementById('customerEmail').value;
            var customerPhone = document.getElementById('customerPhone').value;
            var customerAddress = document.getElementById('customerAddress').value;
            var taxCode = document.getElementById('taxCode').value;
            var customerType = document.getElementById('customerType').value;

            if (!customerCode || !companyName || !userContract || !customerEmail || !customerPhone || !customerAddress || !customerType) {
                showAlert('Vui lòng điền đầy đủ thông tin bắt buộc', 'warning');
                return;
            }

            var formData = {
                customerCode: customerCode,
                companyName: companyName,
                userContract: userContract,
                customerEmail: customerEmail,
                customerPhone: customerPhone,
                customerAddress: customerAddress,
                taxCode: taxCode,
                customerType: customerType
            };

            var url = '../api/customers';
            var action = currentEditingCustomer ? 'update' : 'add';
            formData.action = action;
            
            if (currentEditingCustomer) {
                formData.id = currentEditingCustomer.id;
            }

            $.ajax({
                url: url,
                type: 'POST',
                data: formData,
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        showAlert(response.message, 'success');
                        $('#addCustomerModal').modal('hide');
                        document.getElementById('addCustomerForm').reset();
                        currentEditingCustomer = null;
                        $('#addCustomerModalLabel').text('Thêm khách hàng mới');
                        loadCustomers();
                    } else {
                        showAlert('Lỗi: ' + response.message, 'danger');
                    }
                },
                error: function() {
                    showAlert('Lỗi kết nối đến server', 'danger');
                }
            });
        }

        function showAlert(message, type) {
            var alertClass = 'alert-' + type;
            var alertHtml = '<div class="alert ' + alertClass + ' alert-dismissible fade in" role="alert">' +
                           '<button type="button" class="close" data-dismiss="alert" aria-label="Close">' +
                           '<span aria-hidden="true">&times;</span></button>' +
                           message + '</div>';
            
            // Remove existing alerts
            $('.alert').remove();
            
            // Add new alert
            $('.content').prepend(alertHtml);
            
            // Auto remove after 5 seconds
            setTimeout(function() {
                $('.alert').fadeOut();
            }, 5000);
        }

        // Reset form when modal is closed
        $('#addCustomerModal').on('hidden.bs.modal', function() {
            document.getElementById('addCustomerForm').reset();
            currentEditingCustomer = null;
            $('#addCustomerModalLabel').text('Thêm khách hàng mới');
        });
    </script>
</body>
</html>
