<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Kiểm tra đăng nhập
    String username = (String) session.getAttribute("username");
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || isLoggedIn == null || !isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Kiểm tra quyền customer
    if (!"customer".equals(userRole) && !"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/403.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Khách hàng - HL Generator Solutions</title>
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

        .welcome-banner {
            background: linear-gradient(135deg, var(--primary-red), #c82333);
            color: var(--white);
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
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
                        <i class="fas fa-user me-2"></i>
                        Khách hàng
                    </h5>
                    <nav class="nav flex-column">
                        <a class="nav-link active" href="customer_dashboard.jsp">
                            <i class="fas fa-tachometer-alt me-2"></i>
                            Dashboard
                        </a>
                        <a class="nav-link" href="products.jsp">
                            <i class="fas fa-boxes me-2"></i>
                            Sản phẩm
                        </a>
                        <a class="nav-link" href="orders.jsp">
                            <i class="fas fa-shopping-cart me-2"></i>
                            Đơn hàng của tôi
                        </a>
                        <a class="nav-link" href="contracts.jsp">
                            <i class="fas fa-file-contract me-2"></i>
                            Hợp đồng
                        </a>
                        <a class="nav-link" href="support.jsp">
                            <i class="fas fa-headset me-2"></i>
                            Hỗ trợ
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
                <!-- Welcome Banner -->
                <div class="welcome-banner">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h2 class="mb-2">
                                <i class="fas fa-handshake me-2"></i>
                                Chào mừng trở lại!
                            </h2>
                            <p class="mb-0">Xin chào <strong><%= username %></strong>, chúng tôi rất vui được phục vụ bạn!</p>
                        </div>
                        <div class="col-md-4 text-end">
                            <i class="fas fa-user-circle" style="font-size: 4rem; opacity: 0.3;"></i>
                        </div>
                    </div>
                </div>

                <!-- Statistics Cards -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon text-primary">
                                <i class="fas fa-shopping-cart"></i>
                            </div>
                            <div class="stat-number text-primary" id="totalOrders">0</div>
                            <div class="stat-label">Tổng đơn hàng</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon text-warning">
                                <i class="fas fa-clock"></i>
                            </div>
                            <div class="stat-number text-warning" id="pendingOrders">0</div>
                            <div class="stat-label">Đang xử lý</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon text-info">
                                <i class="fas fa-file-contract"></i>
                            </div>
                            <div class="stat-number text-info" id="activeContracts">0</div>
                            <div class="stat-label">Hợp đồng hoạt động</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon text-success">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <div class="stat-number text-success" id="completedOrders">0</div>
                            <div class="stat-label">Đã hoàn thành</div>
                        </div>
                    </div>
                </div>

                <!-- Recent Orders -->
                <div class="row">
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-list me-2"></i>
                                    Đơn hàng gần đây
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Mã đơn hàng</th>
                                                <th>Sản phẩm</th>
                                                <th>Ngày đặt</th>
                                                <th>Trạng thái</th>
                                                <th>Tổng tiền</th>
                                                <th>Hành động</th>
                                            </tr>
                                        </thead>
                                        <tbody id="recentOrdersTable">
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

                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-bell me-2"></i>
                                    Thông báo
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="alert alert-info">
                                    <i class="fas fa-info-circle me-2"></i>
                                    Đơn hàng #ORD-001 đã được xác nhận
                                </div>
                                <div class="alert alert-success">
                                    <i class="fas fa-check-circle me-2"></i>
                                    Đơn hàng #ORD-002 đã hoàn thành
                                </div>
                                <div class="alert alert-warning">
                                    <i class="fas fa-exclamation-triangle me-2"></i>
                                    Có sản phẩm mới phù hợp với nhu cầu
                                </div>
                            </div>
                        </div>

                        <div class="card mt-3">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-headset me-2"></i>
                                    Hỗ trợ nhanh
                                </h5>
                            </div>
                            <div class="card-body">
                                <p class="mb-3">Cần hỗ trợ? Chúng tôi luôn sẵn sàng giúp đỡ!</p>
                                <div class="d-grid gap-2">
                                    <button class="btn btn-primary">
                                        <i class="fas fa-phone me-2"></i>
                                        Gọi hotline
                                    </button>
                                    <button class="btn btn-outline-primary">
                                        <i class="fas fa-comments me-2"></i>
                                        Chat trực tuyến
                                    </button>
                                    <button class="btn btn-outline-primary">
                                        <i class="fas fa-envelope me-2"></i>
                                        Gửi email
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div class="card mt-3">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-star me-2"></i>
                                    Sản phẩm yêu thích
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="list-group list-group-flush">
                                    <div class="list-group-item d-flex justify-content-between align-items-center">
                                        Máy phát điện Cummins 100kVA
                                        <span class="badge bg-primary rounded-pill">Xem</span>
                                    </div>
                                    <div class="list-group-item d-flex justify-content-between align-items-center">
                                        Máy phát điện Denyo 50kVA
                                        <span class="badge bg-primary rounded-pill">Xem</span>
                                    </div>
                                    <div class="list-group-item d-flex justify-content-between align-items-center">
                                        Máy phát điện Mitsubishi 75kVA
                                        <span class="badge bg-primary rounded-pill">Xem</span>
                                    </div>
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
        // Load customer statistics
        function loadCustomerStats() {
            // Simulate API call - replace with actual API
            setTimeout(() => {
                document.getElementById('totalOrders').textContent = '8';
                document.getElementById('pendingOrders').textContent = '2';
                document.getElementById('activeContracts').textContent = '3';
                document.getElementById('completedOrders').textContent = '6';
            }, 1000);
        }

        // Load recent orders
        function loadRecentOrders() {
            // Simulate API call - replace with actual API
            setTimeout(() => {
                const tableBody = document.getElementById('recentOrdersTable');
                tableBody.innerHTML = `
                    <tr>
                        <td>#ORD-003</td>
                        <td>Máy phát điện Cummins 100kVA</td>
                        <td>18/10/2025</td>
                        <td><span class="badge bg-warning">Đang xử lý</span></td>
                        <td>250,000,000 VNĐ</td>
                        <td><button class="btn btn-sm btn-outline-primary">Xem chi tiết</button></td>
                    </tr>
                    <tr>
                        <td>#ORD-002</td>
                        <td>Máy phát điện Denyo 50kVA</td>
                        <td>15/10/2025</td>
                        <td><span class="badge bg-success">Hoàn thành</span></td>
                        <td>180,000,000 VNĐ</td>
                        <td><button class="btn btn-sm btn-outline-primary">Xem chi tiết</button></td>
                    </tr>
                    <tr>
                        <td>#ORD-001</td>
                        <td>Máy phát điện Mitsubishi 75kVA</td>
                        <td>12/10/2025</td>
                        <td><span class="badge bg-info">Đang giao</span></td>
                        <td>220,000,000 VNĐ</td>
                        <td><button class="btn btn-sm btn-outline-primary">Xem chi tiết</button></td>
                    </tr>
                `;
            }, 1500);
        }

        // Initialize dashboard
        document.addEventListener('DOMContentLoaded', function() {
            loadCustomerStats();
            loadRecentOrders();
        });
    </script>
</body>
</html>
