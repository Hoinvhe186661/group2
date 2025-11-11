<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hlgenerator.util.AuthorizationUtil, com.hlgenerator.util.Permission" %>
<%
    // Kiểm tra đăng nhập
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Kiểm tra quyền sử dụng permission - cần có quyền quản lý kho hoặc sản phẩm
    if (!AuthorizationUtil.hasPermission(request, Permission.MANAGE_INVENTORY) && 
        !AuthorizationUtil.hasPermission(request, Permission.MANAGE_PRODUCTS)) {
        response.sendRedirect(request.getContextPath() + "/403.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Thủ kho - HL Generator Solutions</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-red: #dc3545;
            --primary-yellow: #ffc107;
            --dark-grey: #343a40;
            --light-grey: #f8f9fa;
            --white: #ffffff;
            --success: #28a745;
            --warning: #ffc107;
            --info: #17a2b8;
            --danger: #dc3545;
        }

        body {
            font-family: 'Roboto', sans-serif;
            background-color: var(--light-grey);
        }

        .sidebar {
            background: var(--dark-grey);
            min-height: 100vh;
            padding: 0;
        }

        .sidebar .nav-link {
            color: #adb5bd;
            padding: 12px 20px;
            border-radius: 0;
            transition: all 0.3s ease;
        }

        .sidebar .nav-link:hover {
            background-color: var(--primary-red);
            color: var(--white);
        }

        .sidebar .nav-link.active {
            background-color: var(--primary-red);
            color: var(--white);
        }

        .main-content {
            padding: 20px;
        }

        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }

        .card-header {
            background: linear-gradient(135deg, var(--primary-red), #c82333);
            color: var(--white);
            border-radius: 10px 10px 0 0 !important;
            font-weight: 600;
        }

        .stat-card {
            background: var(--white);
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 10px;
        }

        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #6c757d;
            font-size: 0.9rem;
        }

        .btn-primary {
            background-color: var(--primary-red);
            border-color: var(--primary-red);
        }

        .btn-primary:hover {
            background-color: #c82333;
            border-color: #c82333;
        }

        .table th {
            background-color: var(--light-grey);
            border-top: none;
            font-weight: 600;
        }

        .badge {
            font-size: 0.8rem;
            padding: 6px 12px;
        }

        .low-stock {
            color: var(--danger);
            font-weight: 600;
        }

        .normal-stock {
            color: var(--success);
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-3 col-lg-2 sidebar">
                <div class="p-3">
                    <h5 class="text-white mb-4">
                        <i class="fas fa-warehouse me-2"></i>
                        Thủ kho
                    </h5>
                    <nav class="nav flex-column">
                        <a class="nav-link active" href="storekeeper.jsp">
                            <i class="fas fa-tachometer-alt me-2"></i>
                            Dashboard
                        </a>
                        <a class="nav-link" href="products.jsp">
                            <i class="fas fa-boxes me-2"></i>
                            Quản lý kho
                        </a>
                        <a class="nav-link" href="supplier.jsp">
                            <i class="fas fa-truck me-2"></i>
                            Nhà cung cấp
                        </a>
                        <a class="nav-link" href="profile.jsp">
                            <i class="fas fa-user me-2"></i>
                            Hồ sơ cá nhân
                        </a>
                        <a class="nav-link" href="logout">
                            <i class="fas fa-sign-out-alt me-2"></i>
                            Đăng xuất
                        </a>
                    </nav>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-md-9 col-lg-10 main-content">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2 class="mb-0">
                        <i class="fas fa-tachometer-alt me-2"></i>
                        Dashboard Thủ kho
                    </h2>
                    <div class="text-muted">
                        Xin chào, <strong><%= username %></strong>
                    </div>
                </div>

                <!-- Statistics Cards -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon text-primary">
                                <i class="fas fa-boxes"></i>
                            </div>
                            <div class="stat-number text-primary" id="totalProducts">0</div>
                            <div class="stat-label">Tổng sản phẩm</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon text-warning">
                                <i class="fas fa-exclamation-triangle"></i>
                            </div>
                            <div class="stat-number text-warning" id="lowStockProducts">0</div>
                            <div class="stat-label">Sắp hết hàng</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon text-info">
                                <i class="fas fa-arrow-down"></i>
                            </div>
                            <div class="stat-number text-info" id="incomingStock">0</div>
                            <div class="stat-label">Hàng sắp về</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon text-success">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <div class="stat-number text-success" id="inStockProducts">0</div>
                            <div class="stat-label">Còn hàng</div>
                        </div>
                    </div>
                </div>

                <!-- Low Stock Alert -->
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="card border-warning">
                            <div class="card-header bg-warning text-dark">
                                <h5 class="mb-0">
                                    <i class="fas fa-exclamation-triangle me-2"></i>
                                    Cảnh báo tồn kho thấp
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Mã sản phẩm</th>
                                                <th>Tên sản phẩm</th>
                                                <th>Tồn kho hiện tại</th>
                                                <th>Tồn kho tối thiểu</th>
                                                <th>Trạng thái</th>
                                                <th>Hành động</th>
                                            </tr>
                                        </thead>
                                        <tbody id="lowStockTable">
                                            <tr>
                                                <td colspan="6" class="text-center text-muted">
                                                    <i class="fas fa-spinner fa-spin me-2"></i>
                                                    Đang tải dữ liệu...
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Stock Movements -->
                <div class="row">
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-exchange-alt me-2"></i>
                                    Giao dịch kho gần đây
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Thời gian</th>
                                                <th>Sản phẩm</th>
                                                <th>Loại</th>
                                                <th>Số lượng</th>
                                                <th>Ghi chú</th>
                                            </tr>
                                        </thead>
                                        <tbody id="stockMovementsTable">
                                            <tr>
                                                <td colspan="5" class="text-center text-muted">
                                                    <i class="fas fa-spinner fa-spin me-2"></i>
                                                    Đang tải dữ liệu...
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-chart-pie me-2"></i>
                                    Thống kê tồn kho
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="d-flex justify-content-between mb-2">
                                    <span>Sản phẩm còn hàng:</span>
                                    <strong class="normal-stock">85%</strong>
                                </div>
                                <div class="progress mb-3">
                                    <div class="progress-bar bg-success" style="width: 85%"></div>
                                </div>
                                <div class="d-flex justify-content-between mb-2">
                                    <span>Sắp hết hàng:</span>
                                    <strong class="low-stock">12%</strong>
                                </div>
                                <div class="progress mb-3">
                                    <div class="progress-bar bg-warning" style="width: 12%"></div>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span>Hết hàng:</span>
                                    <strong class="text-danger">3%</strong>
                                </div>
                                <div class="progress">
                                    <div class="progress-bar bg-danger" style="width: 3%"></div>
                                </div>
                            </div>
                        </div>

                        <div class="card mt-3">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-bell me-2"></i>
                                    Thông báo
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="alert alert-warning">
                                    <i class="fas fa-exclamation-triangle me-2"></i>
                                    Máy phát điện Cummins 100kVA sắp hết hàng
                                </div>
                                <div class="alert alert-info">
                                    <i class="fas fa-info-circle me-2"></i>
                                    Đơn hàng mới từ nhà cung cấp Denyo
                                </div>
                                <div class="alert alert-success">
                                    <i class="fas fa-check-circle me-2"></i>
                                    Đã nhập kho 50 sản phẩm mới
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Load inventory statistics
        function loadInventoryStats() {
            // Simulate API call - replace with actual API
            setTimeout(() => {
                document.getElementById('totalProducts').textContent = '150';
                document.getElementById('lowStockProducts').textContent = '8';
                document.getElementById('incomingStock').textContent = '25';
                document.getElementById('inStockProducts').textContent = '142';
            }, 1000);
        }

        // Load low stock products
        function loadLowStockProducts() {
            // Simulate API call - replace with actual API
            setTimeout(() => {
                const tableBody = document.getElementById('lowStockTable');
                tableBody.innerHTML = `
                    <tr>
                        <td>CUMMINS-100</td>
                        <td>Máy phát điện Cummins 100kVA</td>
                        <td>3</td>
                        <td>5</td>
                        <td><span class="badge bg-warning">Sắp hết</span></td>
                        <td><button class="btn btn-sm btn-primary">Đặt hàng</button></td>
                    </tr>
                    <tr>
                        <td>DENYO-50</td>
                        <td>Máy phát điện Denyo 50kVA</td>
                        <td>2</td>
                        <td>3</td>
                        <td><span class="badge bg-danger">Hết hàng</span></td>
                        <td><button class="btn btn-sm btn-primary">Đặt hàng</button></td>
                    </tr>
                    <tr>
                        <td>MITSUBISHI-75</td>
                        <td>Máy phát điện Mitsubishi 75kVA</td>
                        <td>4</td>
                        <td>5</td>
                        <td><span class="badge bg-warning">Sắp hết</span></td>
                        <td><button class="btn btn-sm btn-primary">Đặt hàng</button></td>
                    </tr>
                `;
            }, 1500);
        }

        // Load stock movements
        function loadStockMovements() {
            // Simulate API call - replace with actual API
            setTimeout(() => {
                const tableBody = document.getElementById('stockMovementsTable');
                tableBody.innerHTML = `
                    <tr>
                        <td>18/10/2025 14:30</td>
                        <td>Máy phát điện Cummins 100kVA</td>
                        <td><span class="badge bg-success">Nhập kho</span></td>
                        <td>+10</td>
                        <td>Nhập từ nhà cung cấp</td>
                    </tr>
                    <tr>
                        <td>18/10/2025 10:15</td>
                        <td>Máy phát điện Denyo 50kVA</td>
                        <td><span class="badge bg-danger">Xuất kho</span></td>
                        <td>-2</td>
                        <td>Bán cho khách hàng</td>
                    </tr>
                    <tr>
                        <td>17/10/2025 16:45</td>
                        <td>Máy phát điện Mitsubishi 75kVA</td>
                        <td><span class="badge bg-info">Điều chỉnh</span></td>
                        <td>+1</td>
                        <td>Kiểm kê phát hiện thừa</td>
                    </tr>
                `;
            }, 2000);
        }

        // Initialize dashboard
        document.addEventListener('DOMContentLoaded', function() {
            loadInventoryStats();
            loadLowStockProducts();
            loadStockMovements();
        });
    </script>
</body>
</html>
