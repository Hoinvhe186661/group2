<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Set, com.hlgenerator.model.Customer, com.hlgenerator.servlet.CustomerManagementServlet.CustomerHelper" %>
<%
    // Lấy dữ liệu từ request attributes (đã được set bởi servlet)
    @SuppressWarnings("unchecked")
    List<Customer> filteredCustomers = (List<Customer>) request.getAttribute("filteredCustomers");
    @SuppressWarnings("unchecked")
    Set<String> customerTypes = (Set<String>) request.getAttribute("customerTypes");
    @SuppressWarnings("unchecked")
    Set<String> statuses = (Set<String>) request.getAttribute("statuses");
    String pCode = (String) request.getAttribute("filterCode");
    String pType = (String) request.getAttribute("filterType");
    String pStatus = (String) request.getAttribute("filterStatus");
    String pContact = (String) request.getAttribute("filterContact");
    String pAddress = (String) request.getAttribute("filterAddress");
%>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Quản lý khách hàng</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <!-- CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="css/datatables/dataTables.bootstrap.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css" rel="stylesheet" type="text/css" />
    
    <style>
            .btn-xs {
                padding: 2px 8px;
                font-size: 11px;
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
        <a href="customers" class="logo">Bảng điều khiển </a>
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
                            <span>Admin <i class="caret"></i></span>
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
                        <p>Xin chào, Admin</p>
                        <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
                    </div>
                </div>
                <!-- search form -->
                <form action="#" method="get" class="sidebar-form">
                    <div class="input-group">
                        <input type="text" name="q" class="form-control" placeholder="Tìm kiếm..."/>
                        <span class="input-group-btn">
                            <button type='submit' name='seach' id='search-btn' class="btn btn-flat"><i class="fa fa-search"></i></button>
                        </span>
                    </div>
                </form>
                <!-- /.search form -->
                
                <ul class="sidebar-menu">
                    <li><a href="admin.jsp"><i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span></a></li>
                    
                        <li class="active"><a href="customers"><i class="fa fa-users"></i> <span>Quản lý khách
                                    hàng</span></a></li>
                        <li><a href="users"><i class="fa fa-user-secret"></i> <span>Quản lý người dùng</span></a>
                        </li>
                    <li><a href="email-management"><i class="fa fa-envelope"></i> <span>Quản lý Email</span></a></li>
                    <li><a href="reports.jsp"><i class="fa fa-bar-chart"></i> <span>Báo cáo</span></a></li>
                    <li><a href="settings.jsp"><i class="fa fa-cog"></i> <span>Cài đặt</span></a></li>
                </ul>
            </section>
        </aside>

        <!-- Main Content -->
        <aside class="right-side">
            <section class="content">
                <div class="row">
                    <div class="col-xs-12">
                        <div class="panel">
                            <header class="panel-heading">
                                <h3>Quản lý khách hàng</h3>
                                <div class="panel-tools">
                                        <button class="btn btn-primary btn-sm" data-toggle="modal"
                                            data-target="#addCustomerModal">
                                        <i class="fa fa-plus"></i> Thêm khách hàng mới
                                    </button>
                                </div>
                            </header>
                            
                            <div class="panel-body table-responsive">
                                
                                <form class="form-inline" method="get" action="customers" accept-charset="UTF-8" style="margin-bottom: 10px;">
                                    <div class="row" style="margin-bottom: 10px;">
                                        
                                        <div class="col-sm-3">
                                            <label for="filterCustomerType">Loại khách hàng</label>
                                            <select id="filterCustomerType" name="customerType" class="form-control" style="width:100%">
                                                <option value="">Tất cả</option>
                                                <% 
                                                if (customerTypes != null) {
                                                    for (String raw : customerTypes) { 
                                                        String label = CustomerHelper.typeLabel(raw);
                                                %>
                                                <option value="<%= raw %>" <%= (pType != null && pType.equalsIgnoreCase(raw)) ? "selected" : "" %>>
                                                    <%= label %>
                                                </option>
                                                <% 
                                                    } 
                                                }
                                                %>
                                            </select>
                                        </div>
                                        <div class="col-sm-3">
                                            <label for="filterStatus">Trạng thái</label>
                                            <select id="filterStatus" name="status" class="form-control" style="width:100%">
                                                <option value="">Tất cả</option>
                                                <% 
                                                if (statuses != null) {
                                                    for (String raw : statuses) { 
                                                        String label = CustomerHelper.statusLabel(raw);
                                                %>
                                                <option value="<%= raw %>" <%= (pStatus != null && pStatus.equalsIgnoreCase(raw)) ? "selected" : "" %>>
                                                    <%= label %>
                                                </option>
                                                <% 
                                                    } 
                                                }
                                                %>
                                            </select>
                                        </div>
                                        
                                    </div>
                                    <div class="row" style="margin-bottom: 10px;">
                                        
                                    </div>
                                    <div class="row" style="margin-bottom: 10px;">
                                        <div class="col-sm-12">
                                            <button type="submit" class="btn btn-primary btn-sm">
                                                <i class="fa fa-filter"></i> Lọc
                                            </button>
                                            <a href="customers" class="btn btn-default btn-sm">
                                                <i class="fa fa-times"></i> Xóa lọc
                                            </a>
                                        </div>
                                    </div>
                                </form>
                                
                                <div id="filterSummary" style="margin: 5px 0 10px 0;"></div>
                                
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
                                    <tbody>
                                        <% 
                                        if (filteredCustomers != null) {
                                            for (Customer customer : filteredCustomers) { 
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
                                            <td><%= CustomerHelper.typeLabel(customer.getCustomerType()) %></td>
                                            <td><%= CustomerHelper.statusLabel(customer.getStatus()) %></td>
                                            <td class="action-buttons">
                                                <button class="btn btn-info btn-xs" onclick="viewCustomer('<%= customer.getId() %>')">
                                                    <i class="fa fa-eye"></i> Xem
                                                </button>
                                                <button class="btn btn-warning btn-xs" onclick="editCustomer('<%= customer.getId() %>')">
                                                    <i class="fa fa-edit"></i> Sửa
                                                </button>
                                                <% if ("active".equals(customer.getStatus())) { %>
                                                <button class="btn btn-danger btn-xs" onclick="deleteCustomer('<%= customer.getId() %>')">
                                                    <i class="fa fa-trash"></i> Xóa
                                                </button>
                                                <% } else { %>
                                                <button class="btn btn-success btn-xs" onclick="activateCustomer('<%= customer.getId() %>')">
                                                    <i class="fa fa-unlock"></i> Kích hoạt
                                                </button>
                                                <% } %>
                                            </td>
                                        </tr>
                                        <% 
                                            }
                                        }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </aside>
    </div>

    <!-- Modal thêm/sửa khách hàng -->
    <div class="modal fade" id="addCustomerModal" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Thêm khách hàng mới</h4>
                </div>
                <div class="modal-body">
                    <form id="addCustomerForm">
                        <div class="form-group">
                            <label>Mã khách hàng:</label>
                            <input type="text" class="form-control" id="customerCode" required>
                        </div>
                        <div class="form-group">
                            <label>Tên công ty:</label>
                            <input type="text" class="form-control" id="companyName">
                        </div>
                        <div class="form-group">
                            <label>Người liên hệ:</label>
                            <input type="text" class="form-control" id="userContract" required>
                        </div>
                        <div class="form-group">
                            <label>Email: <small class="text-muted"></small></label>
                            <input type="email" class="form-control" id="customerEmail" placeholder="" required>
                        </div>
                        <div class="form-group">
                            <label>Số điện thoại:</label>
                            <input type="tel" class="form-control" id="customerPhone" required>
                        </div>
                        <div class="form-group">
                            <label>Địa chỉ:</label>
                            <textarea class="form-control" id="customerAddress" rows="3" required></textarea>
                        </div>
                        <div class="form-group">
                            <label>Mã số thuế:</label>
                            <input type="text" class="form-control" id="taxCode">
                        </div>
                        <div class="form-group">
                            <label>Loại khách hàng:</label>
                            <select class="form-control" id="customerType" required>
                                <option value="">Chọn loại khách hàng</option>
                                <option value="individual">Cá nhân</option>
                                <option value="company">Doanh nghiệp</option>
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
    <div class="modal fade" id="customerDetailModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Chi tiết khách hàng</h4>
                </div>
                <div class="modal-body" id="customerDetailContent">
                    <!-- Nội dung sẽ được load bằng JavaScript -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
    <script src="js/jquery.min.js" type="text/javascript"></script>
    <script src="js/bootstrap.min.js" type="text/javascript"></script>
    <script src="js/plugins/datatables/jquery.dataTables.js" type="text/javascript"></script>
    <script src="js/plugins/datatables/dataTables.bootstrap.js" type="text/javascript"></script>

    <script type="text/javascript">
        var customersTable;
        var currentEditingCustomer = null;

            $(document).ready(function () {
            customersTable = $('#customersTable').DataTable({
                "language": { "url": "//cdn.datatables.net/plug-ins/1.10.25/i18n/Vietnamese.json" },
                    "processing": false,
                    "serverSide": false,
                    "paging": true,
                    "searching": false,
                    "dom": 'lrtip',
                    "ordering": true,
                    "info": true,
                    "autoWidth": false,
                    "responsive": true,
                "order": [[0, "desc"]],
                "columnDefs": [{ "targets": [10], "orderable": false, "searchable": false }]
            });

                // Hiển thị tóm tắt lựa chọn hiện tại (đọc từ tham số GET đã bind sẵn vào selected)
                function renderFilterSummary() {
                    var params = new URLSearchParams(window.location.search);
                    var items = [];
                    var code = params.get('customerCode') || '';
                    var contact = params.get('contactPerson') || '';
                    var type = params.get('customerType') || '';
                    var status = params.get('status') || '';
                    var address = params.get('address') || '';
                    if (code) items.push('<span class="label label-primary" style="margin-right:6px;">Mã KH: ' + $('<div>').text(code).html() + '</span>');
                    if (contact) items.push('<span class="label label-info" style="margin-right:6px;">Người LH: ' + $('<div>').text(contact).html() + '</span>');
                    if (type) items.push('<span class="label label-success" style="margin-right:6px;">Loại: ' + $('<div>').text(type).html() + '</span>');
                    if (status) items.push('<span class="label label-warning" style="margin-right:6px;">Trạng thái: ' + $('<div>').text(status).html() + '</span>');
                    if (address) items.push('<span class="label label-default" style="margin-right:6px;">Địa chỉ: ' + $('<div>').text(address).html() + '</span>');
                    $('#filterSummary').html(items.join(''));
                }
                renderFilterSummary();
        });

        function viewCustomer(id) {
            $.ajax({
                url: 'api/customers?action=get&id=' + id,
                type: 'GET',
                dataType: 'json',
                    success: function (response) {
                    if (response.success) {
                        var customer = response.data;
                        var content = '<div class="row">' +
                            '<div class="col-md-6"><h5>Thông tin cơ bản</h5>' +
                            '<p><strong>ID:</strong> ' + customer.id + '</p>' +
                            '<p><strong>Mã khách hàng:</strong> ' + customer.customerCode + '</p>' +
                            '<p><strong>Tên công ty:</strong> ' + customer.companyName + '</p>' +
                            '<p><strong>Người liên hệ:</strong> ' + customer.contactPerson + '</p>' +
                            '<p><strong>Email:</strong> ' + customer.email + '</p>' +
                            '<p><strong>Số điện thoại:</strong> ' + customer.phone + '</p>' +
                            '<p><strong>Địa chỉ:</strong> ' + customer.address + '</p>' +
                            '</div>' +
                            '<div class="col-md-6"><h5>Thông tin bổ sung</h5>' +
                            '<p><strong>Mã số thuế:</strong> ' + (customer.taxCode || '-') + '</p>' +
                            '<p><strong>Loại khách hàng:</strong> ' + (customer.customerType === 'company' ? 'Doanh nghiệp' : 'Cá nhân') + '</p>' +
                            '<p><strong>Trạng thái:</strong> ' + (customer.status === 'active' ? 'Hoạt động' : 'Tạm khóa') + '</p>' +
                            '</div></div>';
                        $('#customerDetailContent').html(content);
                        $('#customerDetailModal').modal('show');
                    } else {
                        alert('Không thể tải thông tin khách hàng: ' + response.message);
                    }
                },
                    error: function () {
                    alert('Lỗi kết nối đến server');
                }
            });
        }

        function editCustomer(id) {
            $.ajax({
                url: 'api/customers?action=get&id=' + id,
                type: 'GET',
                dataType: 'json',
                    success: function (response) {
                    if (response.success) {
                        var customer = response.data;
                        $('#customerCode').val(customer.customerCode);
                        $('#companyName').val(customer.companyName);
                        $('#userContract').val(customer.contactPerson);
                        $('#customerEmail').val(customer.email);
                        $('#customerPhone').val(customer.phone);
                        $('#customerAddress').val(customer.address);
                        $('#taxCode').val(customer.taxCode || '');
                        $('#customerType').val(customer.customerType);
                        currentEditingCustomer = customer;
                        $('#addCustomerModal .modal-title').text('Chỉnh sửa khách hàng');
                        $('#addCustomerModal').modal('show');
                    } else {
                        alert('Không thể tải thông tin khách hàng: ' + response.message);
                    }
                },
                    error: function () {
                    alert('Lỗi kết nối đến server');
                }
            });
        }

        function deleteCustomer(id) {
            if (confirm('Bạn có chắc chắn muốn xóa khách hàng này?')) {
                $.ajax({
                    url: 'api/customers',
                    type: 'POST',
                    data: { action: 'delete', id: id },
                    dataType: 'json',
                        success: function (response) {
                        if (response.success) {
                            alert('Đã xóa khách hàng thành công');
                            location.reload();
                        } else {
                            alert('Lỗi khi xóa khách hàng: ' + response.message);
                        }
                    },
                        error: function () {
                        alert('Lỗi kết nối đến server');
                    }
                });
            }
        }

        function activateCustomer(id) {
            if (confirm('Bạn có chắc chắn muốn kích hoạt khách hàng này?')) {
                $.ajax({
                    url: 'api/customers',
                    type: 'POST',
                    data: { action: 'activate', id: id },
                    dataType: 'json',
                        success: function (response) {
                        if (response.success) {
                            alert('Đã kích hoạt khách hàng thành công');
                            location.reload();
                        } else {
                            alert('Lỗi khi kích hoạt khách hàng: ' + response.message);
                        }
                    },
                        error: function () {
                        alert('Lỗi kết nối đến server');
                    }
                });
            }
        }

        function saveCustomer() {
            var formData = {
                customerCode: $('#customerCode').val(),
                companyName: $('#companyName').val(),
                userContract: $('#userContract').val(),
                customerEmail: $('#customerEmail').val(),
                customerPhone: $('#customerPhone').val(),
                customerAddress: $('#customerAddress').val(),
                taxCode: $('#taxCode').val(),
                customerType: $('#customerType').val()
            };

            // Kiểm tra các trường bắt buộc cơ bản
            if (!formData.customerCode || !formData.userContract || 
                !formData.customerEmail || !formData.customerPhone || !formData.customerAddress || !formData.customerType) {
                alert('Vui lòng điền đầy đủ thông tin bắt buộc');
                return;
            }

                // Ràng buộc: Mã khách hàng phải có cả chữ và số, chỉ cho phép ký tự chữ và số
                var code = (formData.customerCode || '').trim();
                var codeRegex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z0-9]+$/;
                if (!codeRegex.test(code)) {
                    alert('Mã khách hàng phải bao gồm cả chữ và số, và chỉ chứa ký tự chữ/số.');
                    $('#customerCode').focus();
                    return;
                }

                // Ràng buộc: Email phải là @gmail.com hoặc @fpt.edu.vn
                var email = (formData.customerEmail || '').trim();
                var emailRegex = /^[A-Za-z0-9._%+-]+@(gmail\.com|fpt\.edu\.vn)$/i;
                if (!emailRegex.test(email)) {
                    alert('Email phải có định dạng @gmail.com hoặc @fpt.edu.vn');
                    $('#customerEmail').focus();
                    return;
                }

                // Ràng buộc: Số điện thoại 10 hoặc 11 chữ số
                var phone = (formData.customerPhone || '').trim();
                var phoneRegex = /^\d{10,11}$/;
                if (!phoneRegex.test(phone)) {
                    alert('Số điện thoại phải gồm 10 hoặc 11 chữ số.');
                    $('#customerPhone').focus();
                    return;
                }

            // Kiểm tra tên công ty chỉ bắt buộc khi loại khách hàng là doanh nghiệp
            if (formData.customerType === 'company' && (!formData.companyName || formData.companyName.trim() === '')) {
                alert('Vui lòng nhập tên công ty cho khách hàng doanh nghiệp');
                return;
            }

            var action = currentEditingCustomer ? 'update' : 'add';
            formData.action = action;
            if (currentEditingCustomer) {
                formData.id = currentEditingCustomer.id;
            }

            $.ajax({
                url: 'api/customers',
                type: 'POST',
                data: formData,
                dataType: 'json',
                    success: function (response) {
                    if (response.success) {
                        alert(response.message);
                        $('#addCustomerModal').modal('hide');
                        $('#addCustomerForm')[0].reset();
                        currentEditingCustomer = null;
                        $('#addCustomerModal .modal-title').text('Thêm khách hàng mới');
                        location.reload();
                    } else {
                        alert('Lỗi: ' + response.message);
                    }
                },
                    error: function () {
                    alert('Lỗi kết nối đến server');
                }
            });
        }

        // Reset form when modal is closed
            $('#addCustomerModal').on('hidden.bs.modal', function () {
            $('#addCustomerForm')[0].reset();
            currentEditingCustomer = null;
            $('#addCustomerModal .modal-title').text('Thêm khách hàng mới');
            // Reset label về mặc định
            $('label[for="companyName"]').text('Tên công ty:');
        });

        // Cập nhật label khi thay đổi loại khách hàng
            $('#customerType').on('change', function () {
            var customerType = $(this).val();
            var label = $('label[for="companyName"]');
            
            if (customerType === 'individual') {
                label.text('Tên công ty: (Tùy chọn)');
            } else if (customerType === 'company') {
                label.text('Tên công ty: *');
            } else {
                label.text('Tên công ty:');
            }
        });
    </script>
</body>

</html>