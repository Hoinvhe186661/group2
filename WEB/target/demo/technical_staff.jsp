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
    
    // Kiểm tra quyền technical_staff
    if (!"technical_staff".equals(userRole) && !"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/403.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Nhân viên Kỹ thuật - HL Generator Solutions</title>
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
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-3 col-lg-2 sidebar">
                <div class="p-3">
                    <h5 class="text-white mb-4">
                        <i class="fas fa-wrench me-2"></i>
                        Nhân viên Kỹ thuật
                    </h5>
                    <nav class="nav flex-column">
                        <a class="nav-link active" href="technical_staff.jsp">
                            <i class="fas fa-tachometer-alt me-2"></i>
                            Dashboard
                        </a>
                        <a class="nav-link" href="my_tasks.jsp">
                            <i class="fas fa-tasks me-2"></i>
                            Nhiệm vụ của tôi
                        </a>
                        <a class="nav-link" href="products.jsp">
                            <i class="fas fa-cogs me-2"></i>
                            Sản phẩm
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
                        Dashboard Nhân viên Kỹ thuật
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
                                <i class="fas fa-tasks"></i>
                            </div>
                            <div class="stat-number text-primary" id="totalTasks">0</div>
                            <div class="stat-label">Tổng nhiệm vụ</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon text-warning">
                                <i class="fas fa-clock"></i>
                            </div>
                            <div class="stat-number text-warning" id="pendingTasks">0</div>
                            <div class="stat-label">Đang chờ</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon text-info">
                                <i class="fas fa-play"></i>
                            </div>
                            <div class="stat-number text-info" id="inProgressTasks">0</div>
                            <div class="stat-label">Đang thực hiện</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon text-success">
                                <i class="fas fa-check"></i>
                            </div>
                            <div class="stat-number text-success" id="completedTasks">0</div>
                            <div class="stat-label">Hoàn thành</div>
                        </div>
                    </div>
                </div>

                <!-- Recent Tasks -->
                <div class="row">
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-list me-2"></i>
                                    Nhiệm vụ gần đây
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Mô tả</th>
                                                <th>Trạng thái</th>
                                                <th>Ưu tiên</th>
                                                <th>Ngày tạo</th>
                                            </tr>
                                        </thead>
                                        <tbody id="recentTasksTable">
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
                                    <i class="fas fa-bell me-2"></i>
                                    Thông báo
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="alert alert-info">
                                    <i class="fas fa-info-circle me-2"></i>
                                    Bạn có 2 nhiệm vụ mới cần xử lý
                                </div>
                                <div class="alert alert-warning">
                                    <i class="fas fa-exclamation-triangle me-2"></i>
                                    Nhiệm vụ #123 sắp hết hạn
                                </div>
                                <div class="alert alert-success">
                                    <i class="fas fa-check-circle me-2"></i>
                                    Nhiệm vụ #120 đã hoàn thành
                                </div>
                            </div>
                        </div>

                        <div class="card mt-3">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-chart-pie me-2"></i>
                                    Thống kê tuần
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="d-flex justify-content-between mb-2">
                                    <span>Nhiệm vụ hoàn thành:</span>
                                    <strong>8/12</strong>
                                </div>
                                <div class="progress mb-3">
                                    <div class="progress-bar bg-success" style="width: 67%"></div>
                                </div>
                                <div class="d-flex justify-content-between mb-2">
                                    <span>Giờ làm việc:</span>
                                    <strong>32h</strong>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span>Hiệu suất:</span>
                                    <strong class="text-success">85%</strong>
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
        // Load task statistics
        function loadTaskStats() {
            // Simulate API call - replace with actual API
            setTimeout(() => {
                document.getElementById('totalTasks').textContent = '12';
                document.getElementById('pendingTasks').textContent = '3';
                document.getElementById('inProgressTasks').textContent = '4';
                document.getElementById('completedTasks').textContent = '5';
            }, 1000);
        }

        // Load recent tasks
        function loadRecentTasks() {
            // Simulate API call - replace with actual API
            setTimeout(() => {
                const tableBody = document.getElementById('recentTasksTable');
                tableBody.innerHTML = `
                    <tr>
                        <td>#123</td>
                        <td>Kiểm tra máy phát điện Cummins 100kVA</td>
                        <td><span class="badge bg-warning">Đang chờ</span></td>
                        <td><span class="badge bg-danger">Cao</span></td>
                        <td>18/10/2025</td>
                    </tr>
                    <tr>
                        <td>#122</td>
                        <td>Bảo dưỡng máy phát điện Denyo 50kVA</td>
                        <td><span class="badge bg-info">Đang thực hiện</span></td>
                        <td><span class="badge bg-warning">Trung bình</span></td>
                        <td>17/10/2025</td>
                    </tr>
                    <tr>
                        <td>#121</td>
                        <td>Thay thế phụ tùng máy phát điện Mitsubishi</td>
                        <td><span class="badge bg-success">Hoàn thành</span></td>
                        <td><span class="badge bg-success">Thấp</span></td>
                        <td>16/10/2025</td>
                    </tr>
                `;
            }, 1500);
        }

        // Initialize dashboard
        document.addEventListener('DOMContentLoaded', function() {
            loadTaskStats();
            loadRecentTasks();
        });
    </script>
</body>
</html>
