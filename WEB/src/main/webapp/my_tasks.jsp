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
    
    // Kiểm tra quyền truy cập - cần có quyền xem hoặc quản lý công việc
    boolean canManage = AuthorizationUtil.hasPermission(request, Permission.MANAGE_TASKS);
    boolean canView = AuthorizationUtil.hasPermission(request, Permission.VIEW_TASKS);
    if (!canManage && !canView) {
        response.sendRedirect(request.getContextPath() + "/403.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng điều khiển | Nhiệm vụ của tôi</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css" rel="stylesheet" type="text/css" />
    <style>
        /* Styles for filter section */
        .filter-section {
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 15px;
            margin-bottom: 15px;
        }
        .filter-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            cursor: pointer;
        }
        .filter-header h4 {
            margin: 0;
            font-size: 14px;
            font-weight: 600;
            color: #495057;
        }
        .filter-header i {
            transition: transform 0.3s;
        }
        .filter-header i.rotated {
            transform: rotate(180deg);
        }
        .filter-content {
            display: none;
        }
        .filter-content.show {
            display: block;
        }
        .filter-row {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 10px;
        }
        .filter-row:last-child {
            margin-bottom: 0;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            min-width: 140px;
            flex: 1 1 auto;
        }
        .filter-group.small {
            min-width: 100px;
            flex: 0 0 auto;
        }
        .filter-group label {
            font-weight: 600;
            margin-bottom: 4px;
            font-size: 12px;
            color: #495057;
        }
        .filter-group .form-control {
            height: 32px;
            font-size: 12px;
            padding: 6px 10px;
        }
        .filter-actions {
            display: flex;
            gap: 8px;
            align-items: flex-end;
        }
        .filter-actions .btn {
            height: 32px;
            padding: 6px 14px;
            font-size: 12px;
            white-space: nowrap;
        }
        
        @media (max-width: 1200px) {
            .filter-group {
                min-width: 120px;
            }
        }
        @media (max-width: 768px) {
            .filter-row {
                flex-direction: column;
                align-items: stretch;
            }
            .filter-group {
                min-width: 100%;
            }
            .filter-actions {
                width: 100%;
            }
            .filter-actions .btn {
                flex: 1;
            }
        }
        /* Reason cell: wrap long words and limit visual size */
        .reason-cell {
            max-width: 320px;
            word-break: break-word;
            overflow: hidden;
        }
        .reason-ellipsis {
            display: -webkit-box;
            -webkit-line-clamp: 2;
            line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            white-space: normal;
        }
        .ticket-desc-ellipsis {
            display: -webkit-box;
            -webkit-line-clamp: 2;
            line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            white-space: normal;
            word-break: break-word;
        }
        /* Reject modal textarea counter */
        .char-counter {
            font-size: 12px;
            color: #6c757d;
            float: right;
        }
    </style>
</head>
<body class="skin-black">
    <header class="header">
        <a href="my_tasks.jsp" class="logo">
            Nhân Viên Kỹ Thuật
        </a>
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
                            <span><%= session.getAttribute("username") != null ? session.getAttribute("username") : "User" %> <i class="caret"></i></span>
                        </a>
                        <ul class="dropdown-menu dropdown-custom dropdown-menu-right">
                            <li class="dropdown-header text-center">Tài khoản</li>
                            <li>
                                <a href="profile.jsp"><i class="fa fa-user fa-fw pull-right"></i> Hồ sơ</a>
                                <a href="settings.jsp"><i class="fa fa-cog fa-fw pull-right"></i> Cài đặt</a>
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
        <aside class="left-side sidebar-offcanvas">
            <section class="sidebar">
                <div class="user-panel">
                    <div class="pull-left image">
                        <img src="img/26115.jpg" class="img-circle" alt="User Image" />
                    </div>
                    <div class="pull-left info">
                        <p>Xin chào, <%= session.getAttribute("username") != null ? session.getAttribute("username") : "User" %></p>
                        <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
                    </div>
                </div>
                <%@ include file="includes/sidebar-menu.jsp" %>
            </section>
        </aside>

        <aside class="right-side">
            <section class="content">
                <div class="row">
                    <div class="col-xs-12">
                        <div class="panel">
                            <header class="panel-heading">
                                <h3>Nhiệm vụ của tôi</h3>
                            </header>
                                <div class="panel-body table-responsive">
                                    <div class="filter-section">
                                        <div class="filter-header" onclick="toggleFilters()">
                                            <h4><i class="fa fa-filter"></i> Bộ lọc</h4>
                                            <i class="fa fa-chevron-down" id="filterToggleIcon"></i>
                                        </div>
                                        <div class="filter-content" id="filterContent">
                                            <form onsubmit="event.preventDefault(); loadTasks();">
                                                <div class="filter-row">
                                                    <div class="filter-group">
                                                        <label for="statusFilter">Trạng thái</label>
                                                        <select id="statusFilter" class="form-control">
                                                            <option value="">Tất cả</option>
                                                            <option value="pending">Chờ nhận</option>
                                                            <option value="in_progress">Đang thực hiện</option>
                                                            <option value="completed">Đã hoàn thành</option>
                                                            <option value="cancelled">Đã hủy</option>
                                                            <option value="rejected">Đã từ chối</option>
                                                        </select>
                                                    </div>
                                                    <div class="filter-group">
                                                        <label for="priorityFilter">Ưu tiên</label>
                                                        <select id="priorityFilter" class="form-control">
                                                            <option value="">Tất cả</option>
                                                            <option value="urgent">Khẩn cấp</option>
                                                            <option value="high">Cao</option>
                                                            <option value="medium">Trung bình</option>
                                                            <option value="low">Thấp</option>
                                                        </select>
                                                    </div>
                                                    <div class="filter-group">
                                                        <label for="q">Tìm kiếm</label>
                                                        <input type="text" id="q" class="form-control" placeholder="Mã nhiệm vụ, Mô tả nhiệm vụ">
                                                    </div>
                                                </div>
                                                <div class="filter-row">
                                                    <div class="filter-group">
                                                        <label for="scheduledFrom">Ngày bắt đầu từ</label>
                                                        <input type="date" id="scheduledFrom" class="form-control">
                                                    </div>
                                                    <div class="filter-group">
                                                        <label for="scheduledTo">Đến</label>
                                                        <input type="date" id="scheduledTo" class="form-control">
                                                    </div>
                                                    <div class="filter-group small">
                                                        <label for="pageSize">Hiển thị</label>
                                                        <select id="pageSize" class="form-control" onchange="changePageSize()">
                                                            <option value="5">5</option>
                                                            <option value="10" selected>10</option>
                                                            <option value="20">20</option>
                                                            <option value="50">50</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="filter-row">
                                                    <div class="filter-actions">
                                                        <button class="btn btn-primary" type="submit">
                                                            <i class="fa fa-filter"></i> Lọc
                                                        </button>
                                                        <button class="btn btn-default" type="button" onclick="resetFilters()">
                                                            <i class="fa fa-times"></i> Xóa lọc
                                                        </button>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                    <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>WO</th>
                                            <th>Nhiệm vụ</th>
                                            <th>Trạng thái</th>
                                            <th>Ưu tiên</th>
                                            <th>Thời gian dự kiến</th>
                                            <th>Ngày nhận</th>
                                            <th>Ngày hoàn thành</th>
                                            <th>Mô tả từ ticket</th>
                                            <th>Lý do từ chối</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="taskBody">
                                        <tr><td colspan="10" class="text-center text-muted">Đang tải...</td></tr>
                                    </tbody>
                                </table>
                                <nav aria-label="Task pagination">
                                    <ul id="taskPagination" class="pagination"></ul>
                                </nav>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </aside>
    </div>

    <!-- Modal: Báo cáo hoàn thành nhiệm vụ -->
    <div class="modal fade" id="completeTaskModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header" style="background-color: #00a65a; color: white;">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="color: white; opacity: 0.8;">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title">
                        <i class="fa fa-flag-checkered"></i> Báo cáo hoàn thành nhiệm vụ
                    </h4>
                </div>
                
                <form id="completeTaskForm" enctype="multipart/form-data">
                    <input type="hidden" id="modalTaskId" />
                    <div class="modal-body">
                        <!-- Task Info -->
                        <div class="alert alert-info">
                            <strong>Nhiệm vụ:</strong> <span id="modalTaskNumber"></span><br>
                            <strong>Mô tả:</strong> <span id="modalTaskDesc"></span>
                        </div>
                        
                        <!-- Thông tin cơ bản -->
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Số giờ thực tế <span class="text-danger">*</span></label>
                                    <input type="number" step="0.5" min="0" max="999" 
                                           class="form-control" id="actualHours" required 
                                           placeholder="VD: 3.5">
                                    <small class="text-muted">Số giờ đã làm việc thực tế</small>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Phần trăm hoàn thành <span class="text-danger">*</span></label>
                                    <input type="range" class="form-control-range" 
                                           id="completionPercentage" min="0" max="100" value="0" 
                                           style="width: 100%; margin-top: 8px;">
                                    <div class="text-center" style="margin-top: 5px;">
                                        <strong style="font-size: 18px; color: #00a65a;">
                                            <span id="percentageValue">0</span>%
                                        </strong>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Mô tả công việc -->
                        <div class="form-group">
                            <label>Mô tả công việc đã thực hiện <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="workDescription" 
                                      rows="3" required 
                                      placeholder="VD: Đã kiểm tra hệ thống điện, thay thế bộ lọc không khí, bảo dưỡng máy phát điện..."></textarea>
                            <small class="text-muted">Mô tả chi tiết những gì đã thực hiện</small>
                        </div>
                        
                        <!-- Vấn đề phát sinh -->
                        <div class="form-group">
                            <label>Vấn đề phát sinh (nếu có)</label>
                            <textarea class="form-control" id="issuesFound" 
                                      rows="2" 
                                      placeholder="VD: Phát hiện dây dẫn bị mòn, cần thay thế trong lần bảo trì tiếp theo..."></textarea>
                            <small class="text-muted">Ghi chú các vấn đề phát hiện trong quá trình làm việc</small>
                        </div>
                        
                        <!-- Ghi chú -->
                        <div class="form-group">
                            <label>Ghi chú bổ sung</label>
                            <textarea class="form-control" id="notes" 
                                      rows="2" 
                                      placeholder="Thông tin khác cần lưu ý..."></textarea>
                        </div>
                        
                        <!-- Upload hình ảnh -->
                        <div class="form-group">
                            <label>
                                <i class="fa fa-camera"></i> Hình ảnh đính kèm (tối đa 5 ảnh)
                            </label>
                            <input type="file" class="form-control" id="attachments" 
                                   accept="image/*" multiple>
                            <small class="text-muted">
                                Hình ảnh trước/sau khi thực hiện công việc. Chấp nhận: JPG, PNG, GIF. Tối đa 5MB/ảnh.
                            </small>
                            <div id="imagePreview" class="row" style="margin-top: 10px;"></div>
                        </div>
                    </div>
                    
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">
                            <i class="fa fa-times"></i> Hủy
                        </button>
                        <button type="submit" class="btn btn-success">
                            <i class="fa fa-check"></i> Xác nhận hoàn thành
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal: Từ chối nhiệm vụ -->
    <div class="modal fade" id="rejectTaskModal" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header" style="background-color: #dd4b39; color: white;">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="color: white; opacity: 0.8;">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title"><i class="fa fa-times"></i> Từ chối nhiệm vụ</h4>
                </div>
                <form id="rejectTaskForm">
                    <input type="hidden" id="rejectTaskId" />
                    <div class="modal-body">
                        <div class="form-group">
                            <label>Lý do từ chối <span class="text-danger">*</span></label>
                            <span class="char-counter"><span id="rejectCount">0</span>/300</span>
                            <textarea id="rejectReason" class="form-control" rows="4" maxlength="300" placeholder="Nhập lý do từ chối (tối đa 300 ký tự)" required></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal"><i class="fa fa-times"></i> Hủy</button>
                        <button type="submit" class="btn btn-danger"><i class="fa fa-check"></i> Xác nhận từ chối</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal: Xem chi tiết nhiệm vụ -->
    <div class="modal fade" id="viewTaskDetailModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header" style="background-color: #3c8dbc; color: white;">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="color: white; opacity: 0.8;">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title">
                        <i class="fa fa-info-circle"></i> Chi tiết nhiệm vụ
                    </h4>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <h5><i class="fa fa-file-text-o"></i> Thông tin Work Order</h5>
                            <table class="table table-bordered">
                                <tr>
                                    <th style="width: 40%;">Mã WO:</th>
                                    <td><strong id="detailWorkOrderNumber">-</strong></td>
                                </tr>
                                <tr>
                                    <th>Tiêu đề:</th>
                                    <td id="detailWorkOrderTitle">-</td>
                                </tr>
                                <tr>
                                    <th>Ngày dự kiến:</th>
                                    <td id="detailScheduledDate">-</td>
                                </tr>
                            </table>
                        </div>
                        <div class="col-md-6">
                            <h5><i class="fa fa-tasks"></i> Thông tin Nhiệm vụ</h5>
                            <table class="table table-bordered">
                                <tr>
                                    <th style="width: 40%;">Mã nhiệm vụ:</th>
                                    <td><strong id="detailTaskNumber">-</strong></td>
                                </tr>
                                <tr>
                                    <th>Mô tả:</th>
                                    <td id="detailTaskDescription">-</td>
                                </tr>
                                <tr>
                                    <th>Trạng thái:</th>
                                    <td id="detailTaskStatus">-</td>
                                </tr>
                                <tr>
                                    <th>Ưu tiên:</th>
                                    <td id="detailTaskPriority">-</td>
                                </tr>
                                <tr>
                                    <th>Thời gian dự kiến:</th>
                                    <td id="detailEstimatedHours">-</td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    
                    <div class="row" style="margin-top: 15px;">
                        <div class="col-md-6">
                            <h5><i class="fa fa-calendar"></i> Thời gian</h5>
                            <table class="table table-bordered">
                                <tr>
                                    <th style="width: 40%;">Ngày được giao:</th>
                                    <td id="detailAssignedAt">-</td>
                                </tr>
                                <tr>
                                    <th>Ngày bắt đầu:</th>
                                    <td id="detailStartDate">-</td>
                                </tr>
                                <tr>
                                    <th>Ngày hoàn thành:</th>
                                    <td id="detailCompletionDate">-</td>
                                </tr>
                            </table>
                        </div>
                        <div class="col-md-6">
                            <h5><i class="fa fa-ticket"></i> Thông tin từ Ticket</h5>
                            <div class="well" style="min-height: 100px; max-height: 200px; overflow-y: auto;">
                                <div id="detailTicketDescription" style="white-space: pre-wrap; word-wrap: break-word;">-</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row" style="margin-top: 15px;">
                        <div class="col-md-12">
                            <h5><i class="fa fa-exclamation-triangle"></i> Lý do từ chối</h5>
                            <div class="well" id="detailRejectionReason" style="min-height: 50px;">
                                <span class="text-muted">-</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">
                        <i class="fa fa-times"></i> Đóng
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal: Xem báo cáo chi tiết -->
    <div class="modal fade" id="viewReportModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header" style="background-color: #3c8dbc; color: white;">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="color: white; opacity: 0.8;">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title">
                        <i class="fa fa-file-text"></i> Báo cáo hoàn thành chi tiết
                    </h4>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong>Nhiệm vụ:</strong> <span id="reportTaskNumber"></span></p>
                            <p><strong>Mô tả nhiệm vụ:</strong> <span id="reportTaskDesc"></span></p>
                        </div>
                        <div class="col-md-6">
                            <p><strong>Số giờ thực tế:</strong> <span id="reportHours"></span> giờ</p>
                            <p><strong>% Hoàn thành:</strong> 
                                <span id="reportPercentage" class="label label-success"></span>
                            </p>
                        </div>
                    </div>
                    <hr>
                    <div class="form-group">
                        <label>Công việc đã thực hiện:</label>
                        <div class="well" id="reportWorkDesc" style="min-height: 60px;">-</div>
                    </div>
                    <div class="form-group">
                        <label>Vấn đề phát sinh:</label>
                        <div class="well" id="reportIssues" style="min-height: 50px;">-</div>
                    </div>
                    <div class="form-group">
                        <label>Ghi chú:</label>
                        <div class="well" id="reportNotes" style="min-height: 50px;">-</div>
                    </div>
                    <div class="form-group">
                        <label><i class="fa fa-image"></i> Hình ảnh đính kèm:</label>
                        <div id="reportImages" class="row"></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">
                        <i class="fa fa-times"></i> Đóng
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
    <script src="js/jquery.min.js" type="text/javascript"></script>
    <script src="js/bootstrap.min.js" type="text/javascript"></script>
    <input type="hidden" id="currentUserId" value="<%= session.getAttribute("userId") != null ? session.getAttribute("userId") : 0 %>" />
    <script>
        var currentUserId = parseInt(document.getElementById('currentUserId').value) || 0;
        
        // Toggle filter visibility
        function toggleFilters() {
            var content = document.getElementById('filterContent');
            var icon = document.getElementById('filterToggleIcon');
            var expanded;
            if (content.classList.contains('show')) {
                content.classList.remove('show');
                icon.classList.remove('rotated');
                expanded = false;
            } else {
                content.classList.add('show');
                icon.classList.add('rotated');
                expanded = true;
            }
            saveMyTaskFilterState(expanded);
        }
        // Chuyển đổi trạng thái và độ ưu tiên sang tiếng Việt (giữ nguyên logic giá trị)
        function statusToVietnamese(s) {
            var map = {
                pending: 'Chờ nhận',
                in_progress: 'Đang thực hiện',
                completed: 'Đã hoàn thành',
                cancelled: 'Đã hủy',
                rejected: 'Đã từ chối'
            };
            return map[s] || (s || '');
        }
        function priorityToVietnamese(p) {
            if (!p) return '';
            var key = String(p).toLowerCase();
            var map = {
                urgent: 'Khẩn cấp',
                high: 'Cao',
                medium: 'Trung bình',
                low: 'Thấp'
            };
            return map[key] || p;
        }
        function badgeForStatus(s){
            var classMap = {pending:'label-default', in_progress:'label-warning', completed:'label-success', cancelled:'label-default', rejected:'label-danger'};
            return '<span class="label ' + (classMap[s]||'label-default') + '">' + statusToVietnamese(s) + '</span>';
        }

        var currentPage = 1;
        var currentTasksData = []; // Lưu dữ liệu tasks hiện tại

        // Hàm loại bỏ các phần trong dấu ngoặc vuông và chỉ giữ lại mô tả thực tế
        function extractTicketDescription(text) {
            if(!text) return '';
            // Loại bỏ tất cả các phần trong dấu ngoặc vuông [....]
            var cleaned = text.replace(/\[[^\]]*\]/g, '').trim();
            // Loại bỏ khoảng trắng thừa
            cleaned = cleaned.replace(/\s+/g, ' ').trim();
            return cleaned;
        }

        function loadTasks(){
            var status = document.getElementById('statusFilter').value;
            var priority = document.getElementById('priorityFilter').value;
            var scheduledFrom = document.getElementById('scheduledFrom').value;
            var scheduledTo = document.getElementById('scheduledTo').value;
            var q = document.getElementById('q').value;
            var size = parseInt(document.getElementById('pageSize').value || '10', 10);
            $.getJSON('api/tasks', { action:'listAssigned', userId: currentUserId, status: status, priority: priority, scheduledFrom: scheduledFrom, scheduledTo: scheduledTo, q: q, page: currentPage, size: size }, function(res){
                var tbody = document.getElementById('taskBody');
                tbody.innerHTML = '';
                if(!res.success){ tbody.innerHTML = '<tr><td colspan="10">' + (res.message||'Lỗi tải dữ liệu') + '</td></tr>'; return; }
                if(!res.data || res.data.length === 0){ tbody.innerHTML = '<tr><td colspan="10" class="text-center text-muted">Không có nhiệm vụ</td></tr>'; renderPagination(res.meta); currentTasksData = []; return; }
                renderPagination(res.meta);
                // Lưu dữ liệu để sử dụng cho modal chi tiết
                currentTasksData = res.data;
                function fmt(ts){
                    if(!ts) return '';
                    try{
                        var d;
                        if(typeof ts === 'number') {
                            d = new Date(ts);
                        } else if(typeof ts === 'string') {
                            // Normalize MySQL-like "YYYY-MM-DD HH:mm:ss" to ISO by replacing space with 'T'
                            var norm = ts.indexOf('T') === -1 ? ts.replace(' ', 'T') : ts;
                            d = new Date(norm);
                            if(isNaN(d.getTime())) {
                                // Fallback: parse parts manually (YYYY-MM-DD HH:mm:ss)
                                var parts = ts.split(' ');
                                var datePart = parts[0] || '';
                                var dp = datePart.split('-');
                                if(dp.length === 3) {
                                    d = new Date(parseInt(dp[0],10), parseInt(dp[1],10)-1, parseInt(dp[2],10));
                                }
                            }
                        } else {
                            d = new Date(ts);
                        }
                        if(isNaN(d.getTime())) return '';
                        var dd = String(d.getDate()).padStart(2,'0');
                        var mm = String(d.getMonth()+1).padStart(2,'0');
                        var yyyy = d.getFullYear();
                        return dd + '/' + mm + '/' + yyyy;
                    }catch(e){ return ''; }
                }

                res.data.forEach(function(it){
                    var actions = [];
                    // Nút xem chi tiết - luôn hiển thị
                    actions.push('<button class="btn btn-xs btn-info" onclick="viewTaskDetail(' + it.taskId + ')"><i class="fa fa-info-circle"></i> Chi tiết</button>');
                    
                    if(it.taskStatus === 'pending'){
                        actions.push('<button class="btn btn-xs btn-primary" onclick="ack(' + it.taskId + ')"><i class="fa fa-check"></i> Nhận</button>');
                        actions.push('<button class="btn btn-xs btn-danger" onclick="openRejectModal(' + it.taskId + ')"><i class="fa fa-times"></i> Từ chối</button>');
                    }
                    if(it.taskStatus === 'in_progress'){
                        actions.push('<button class="btn btn-xs btn-success" onclick="openCompleteModal(' + it.taskId + ', \'' + (it.taskNumber||'').replace(/'/g, "\\'") + '\', \'' + (it.taskDescription||'').replace(/'/g, "\\'") + '\')"><i class="fa fa-flag-checkered"></i> Hoàn thành</button>');
                    }
                    if(it.taskStatus === 'completed'){
                        actions.push('<button class="btn btn-xs btn-success" onclick="viewReport(' + it.taskId + ')"><i class="fa fa-file-text"></i> Báo cáo</button>');
                    }
                    
                    // Format thời gian dự kiến
                    var estimatedTimeDisplay = '<span class="text-muted">-</span>';
                    if(it.estimatedHours && parseFloat(it.estimatedHours) > 0) {
                        estimatedTimeDisplay = '<strong>' + parseFloat(it.estimatedHours).toFixed(1) + 'h</strong>';
                    } else if(it.assignedAt) {
                        estimatedTimeDisplay = fmt(it.assignedAt);
                    }
                    
                    // Format mô tả từ ticket - loại bỏ các phần trong dấu ngoặc vuông
                    var ticketDescDisplay = '<span class="text-muted">-</span>';
                    if(it.ticketDescription) {
                        var ticketDesc = String(it.ticketDescription);
                        // Loại bỏ các phần trong dấu ngoặc vuông [....]
                        var cleanedDesc = extractTicketDescription(ticketDesc);
                        
                        if(cleanedDesc) {
                            var escapedTicketDesc = cleanedDesc.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
                            var originalEscaped = ticketDesc.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
                            if(cleanedDesc.length > 100) {
                                ticketDescDisplay = '<span class="ticket-desc-ellipsis" title="' + originalEscaped + '">' + 
                                    escapedTicketDesc.substring(0, 100) + '...</span>';
                            } else {
                                ticketDescDisplay = '<span title="' + originalEscaped + '">' + escapedTicketDesc + '</span>';
                            }
                        }
                    }
                    
                    var tr = document.createElement('tr');
                    tr.innerHTML = 
                        '<td><div><strong>' + (it.workOrderNumber||'') + '</strong></div><div>' + (it.workOrderTitle||'') + '</div></td>' +
                        '<td><div><strong>' + (it.taskNumber||'') + '</strong></div><div>' + (it.taskDescription||'') + '</div></td>' +
                        '<td>' + badgeForStatus(it.taskStatus) + '</td>' +
                        '<td>' + (priorityToVietnamese(it.taskPriority)||'') + '</td>' +
						'<td>' + estimatedTimeDisplay + '</td>' +
						'<td>' + (fmt(it.acknowledgedAt) || '<span class="text-muted">-</span>') + '</td>' +
                        '<td>' + (fmt(it.completionDate) || '<span class="text-muted">-</span>') + '</td>' +
                        '<td class="reason-cell">' + ticketDescDisplay + '</td>' +
                        '<td class="reason-cell">' + (it.rejectionReason ? (function(txt){ var esc = String(txt).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); return '<span class="text-danger reason-ellipsis" title="' + esc + '">' + esc + '</span>'; })(it.rejectionReason) : '<span class="text-muted">-</span>') + '</td>' +
                        '<td>' + actions.join(' ') + '</td>';
                    tbody.appendChild(tr);
                });
            });
        }

        function resetFilters(){
            document.getElementById('statusFilter').value = '';
            document.getElementById('priorityFilter').value = '';
            document.getElementById('scheduledFrom').value = '';
            document.getElementById('scheduledTo').value = '';
            document.getElementById('q').value = '';
            document.getElementById('pageSize').value = '10';
            localStorage.removeItem('myTaskFilterValues');
            currentPage = 1;
            loadTasks();
        }

        function renderPagination(meta){
            var ul = document.getElementById('taskPagination');
            if(!meta){ ul.innerHTML = ''; return; }
            var totalPages = meta.totalPages || 1;
            var page = meta.page || 1;
            var html = '';
            function li(p, text, disabled, active){
                return '<li class="' + (disabled ? 'disabled' : '') + ' ' + (active ? 'active' : '') + '"><a href="#" onclick="return gotoPage(' + p + ');">' + text + '</a></li>';
            }
            html += li(Math.max(1, page-1), '&laquo;', page===1, false);
            for(var i=1;i<=totalPages;i++){
                html += li(i, i, false, i===page);
            }
            html += li(Math.min(totalPages, page+1), '&raquo;', page===totalPages, false);
            ul.innerHTML = html;
        }

        function changePageSize(){
            currentPage = 1;
            loadTasks();
        }

        window.gotoPage = function(p){
            if(p < 1) return false;
            currentPage = p;
            loadTasks();
            return false;
        }

        function ack(id){
            $.post('api/tasks', { action:'acknowledge', id: id }, function(res){
                try{ res = JSON.parse(res); }catch(e){}
                alert(res.message||'');
                if(res.success) loadTasks();
            });
        }

        // Mở modal để báo cáo hoàn thành
        function openCompleteModal(taskId, taskNumber, taskDesc){
            $('#modalTaskId').val(taskId);
            $('#modalTaskNumber').text(taskNumber);
            $('#modalTaskDesc').text(taskDesc);
            
            // Reset form
            $('#completeTaskForm')[0].reset();
            $('#completionPercentage').val('0');
            $('#percentageValue').text('0');
            $('#imagePreview').html('');
            
            $('#completeTaskModal').modal('show');
        }

        // Submit form báo cáo hoàn thành
        $('#completeTaskForm').on('submit', function(e){
            e.preventDefault();
            
            var taskId = $('#modalTaskId').val();
            var formData = new FormData();
            formData.append('action', 'complete');
            formData.append('id', taskId);
            formData.append('actualHours', $('#actualHours').val());
            formData.append('completionPercentage', $('#completionPercentage').val());
            formData.append('workDescription', $('#workDescription').val());
            formData.append('issuesFound', $('#issuesFound').val());
            formData.append('notes', $('#notes').val());
            
            // Thêm files
            var files = $('#attachments')[0].files;
            for(var i = 0; i < files.length; i++){
                formData.append('files', files[i]);
            }
            
            // Disable button to prevent double submit
            var submitBtn = $(this).find('button[type="submit"]');
            submitBtn.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Đang xử lý...');
            
            $.ajax({
                url: 'api/tasks',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(res){
                    try{ 
                        if(typeof res === 'string') res = JSON.parse(res); 
                    }catch(e){}
                    alert(res.message || 'Hoàn thành!');
                    if(res.success){
                        $('#completeTaskModal').modal('hide');
                        loadTasks();
                    }
                },
                error: function(){
                    alert('Lỗi kết nối! Vui lòng thử lại.');
                },
                complete: function(){
                    submitBtn.prop('disabled', false).html('<i class="fa fa-check"></i> Xác nhận hoàn thành');
                }
            });
        });

        // Update percentage value
        $('#completionPercentage').on('input', function(){
            $('#percentageValue').text($(this).val());
        });

        // Preview images
        $('#attachments').on('change', function(){
            var preview = $('#imagePreview');
            preview.html('');
            var files = this.files;
            
            if(files.length > 5){
                alert('Chỉ được tải tối đa 5 ảnh!');
                this.value = '';
                return;
            }
            
            for(var i = 0; i < files.length; i++){
                var file = files[i];
                
                // Check file size (5MB)
                if(file.size > 5242880){
                    alert('File ' + file.name + ' quá lớn! Kích thước tối đa là 5MB.');
                    this.value = '';
                    preview.html('');
                    return;
                }
                
                // Check file type
                if(!file.type.match('image.*')){
                    alert('File ' + file.name + ' không phải là ảnh!');
                    this.value = '';
                    preview.html('');
                    return;
                }
                
                var reader = new FileReader();
                reader.onload = function(e){
                    var col = $('<div class="col-xs-6 col-sm-4 col-md-3" style="margin-bottom: 10px;"></div>');
                    var img = $('<img class="img-thumbnail" style="width:100%; height:120px; object-fit:cover;">');
                    img.attr('src', e.target.result);
                    col.append(img);
                    preview.append(col);
                };
                reader.readAsDataURL(file);
            }
        });

        // Xem chi tiết nhiệm vụ
        function viewTaskDetail(taskId) {
            // Gọi API để lấy chi tiết task
            $.getJSON('api/tasks', {
                action: 'getDetail', 
                id: taskId, 
                userId: currentUserId
            }, function(res) {
                if(res.success && res.data) {
                    displayTaskDetail(res.data);
                } else {
                    // Fallback: tìm trong danh sách hiện tại
                    var taskData = null;
                    for(var i = 0; i < currentTasksData.length; i++) {
                        if(currentTasksData[i].taskId == taskId) {
                            taskData = currentTasksData[i];
                            break;
                        }
                    }
                    if(taskData) {
                        displayTaskDetail(taskData);
                    } else {
                        alert(res.message || 'Không tìm thấy thông tin nhiệm vụ!');
                    }
                }
            }).fail(function(){
                // Fallback: tìm trong danh sách hiện tại nếu API lỗi
                var taskData = null;
                for(var i = 0; i < currentTasksData.length; i++) {
                    if(currentTasksData[i].taskId == taskId) {
                        taskData = currentTasksData[i];
                        break;
                    }
                }
                if(taskData) {
                    displayTaskDetail(taskData);
                } else {
                    alert('Lỗi kết nối! Không thể tải chi tiết nhiệm vụ.');
                }
            });
        }
        
        // Hiển thị chi tiết nhiệm vụ
        function displayTaskDetail(taskData) {
            if(taskData) {
                        // Format ngày tháng
                        function formatDateTime(ts) {
                            if(!ts) return '-';
                            try {
                                var d;
                                if(typeof ts === 'number') {
                                    d = new Date(ts);
                                } else if(typeof ts === 'string') {
                                    var norm = ts.indexOf('T') === -1 ? ts.replace(' ', 'T') : ts;
                                    d = new Date(norm);
                                    if(isNaN(d.getTime())) {
                                        var parts = ts.split(' ');
                                        var datePart = parts[0] || '';
                                        var timePart = parts[1] || '';
                                        var dp = datePart.split('-');
                                        if(dp.length === 3) {
                                            d = new Date(parseInt(dp[0],10), parseInt(dp[1],10)-1, parseInt(dp[2],10));
                                            if(timePart) {
                                                var tp = timePart.split(':');
                                                if(tp.length >= 2) {
                                                    d.setHours(parseInt(tp[0],10), parseInt(tp[1],10), tp[2] ? parseInt(tp[2],10) : 0);
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    d = new Date(ts);
                                }
                                if(isNaN(d.getTime())) return '-';
                                var dd = String(d.getDate()).padStart(2,'0');
                                var mm = String(d.getMonth()+1).padStart(2,'0');
                                var yyyy = d.getFullYear();
                                var hh = String(d.getHours()).padStart(2,'0');
                                var min = String(d.getMinutes()).padStart(2,'0');
                                return dd + '/' + mm + '/' + yyyy + ' ' + hh + ':' + min;
                            } catch(e) { return '-'; }
                        }
                        
                        // Hiển thị thông tin Work Order
                        $('#detailWorkOrderNumber').text(taskData.workOrderNumber || '-');
                        $('#detailWorkOrderTitle').text(taskData.workOrderTitle || '-');
                        $('#detailScheduledDate').text(taskData.scheduledDate ? formatDateTime(taskData.scheduledDate) : '-');
                        
                        // Hiển thị thông tin Nhiệm vụ
                        $('#detailTaskNumber').text(taskData.taskNumber || '-');
                        $('#detailTaskDescription').text(taskData.taskDescription || '-');
                        $('#detailTaskStatus').html(badgeForStatus(taskData.taskStatus));
                        $('#detailTaskPriority').text(priorityToVietnamese(taskData.taskPriority) || '-');
                        
                        // Thời gian dự kiến
                        var estimatedDisplay = '-';
                        if(taskData.estimatedHours && parseFloat(taskData.estimatedHours) > 0) {
                            estimatedDisplay = '<strong>' + parseFloat(taskData.estimatedHours).toFixed(1) + ' giờ</strong>';
                        }
                        $('#detailEstimatedHours').html(estimatedDisplay);
                        
                        // Thời gian
                        $('#detailAssignedAt').text(taskData.assignedAt ? formatDateTime(taskData.assignedAt) : '-');
                        $('#detailStartDate').text(taskData.startDate ? formatDateTime(taskData.startDate) : '-');
                        $('#detailCompletionDate').text(taskData.completionDate ? formatDateTime(taskData.completionDate) : '-');
                        
                        // Mô tả từ ticket (đầy đủ, không cắt)
                        var ticketDesc = taskData.ticketDescription || '';
                        if(ticketDesc) {
                            // Loại bỏ các phần trong dấu ngoặc vuông
                            var cleanedDesc = extractTicketDescription(ticketDesc);
                            $('#detailTicketDescription').text(cleanedDesc || '-');
                        } else {
                            $('#detailTicketDescription').html('<span class="text-muted">-</span>');
                        }
                        
                        // Lý do từ chối
                        if(taskData.rejectionReason) {
                            $('#detailRejectionReason').html('<span class="text-danger">' + 
                                String(taskData.rejectionReason).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + 
                                '</span>');
                        } else {
                            $('#detailRejectionReason').html('<span class="text-muted">-</span>');
                        }
                        
                        $('#viewTaskDetailModal').modal('show');
                    }
        }

        // Xem báo cáo chi tiết
        function viewReport(taskId) {
            $.getJSON('api/tasks', {action: 'get', id: taskId}, function(res) {
                if (res.success && res.data) {
                    var task = res.data;
                    
                    $('#reportTaskNumber').text(task.taskNumber || '-');
                    $('#reportTaskDesc').text(task.taskDescription || '-');
                    $('#reportHours').text(task.actualHours || '-');
                    $('#reportPercentage').text((task.completionPercentage || 100) + '%');
                    $('#reportWorkDesc').text(task.workDescription || '-');
                    $('#reportIssues').text(task.issuesFound || 'Không có vấn đề phát sinh');
                    $('#reportNotes').text(task.notes || '-');
                    
                    // Hiển thị ảnh
                    var attachments = [];
                    try {
                        if(task.attachments) {
                            attachments = JSON.parse(task.attachments);
                        }
                    } catch(e) {}
                    
                    var imgHtml = '';
                    if(attachments.length > 0) {
                        attachments.forEach(function(path) {
                            imgHtml += '<div class="col-xs-6 col-sm-4 col-md-3" style="margin-bottom: 10px;">' +
                                      '<a href="' + path + '" target="_blank">' +
                                      '<img src="' + path + '" class="img-thumbnail" style="width:100%; height:120px; object-fit:cover;">' +
                                      '</a></div>';
                        });
                    } else {
                        imgHtml = '<div class="col-xs-12"><p class="text-muted">Không có ảnh đính kèm</p></div>';
                    }
                    $('#reportImages').html(imgHtml);
                    
                    $('#viewReportModal').modal('show');
                } else {
                    alert('Không thể tải báo cáo!');
                }
            }).fail(function(){
                alert('Lỗi kết nối!');
            });
        }

        // Reject modal logic
        function openRejectModal(id){
            $('#rejectTaskId').val(id);
            $('#rejectReason').val('');
            $('#rejectCount').text('0');
            $('#rejectTaskModal').modal('show');
            setTimeout(function(){ $('#rejectReason').focus(); }, 200);
        }
        $('#rejectReason').on('input', function(){
            $('#rejectCount').text(this.value.length);
        });
        $('#rejectTaskForm').on('submit', function(e){
            e.preventDefault();
            var id = $('#rejectTaskId').val();
            var reason = ($('#rejectReason').val()||'').trim();
            if(reason.length < 3){
                alert('Lý do quá ngắn. Vui lòng nhập tối thiểu 3 ký tự.');
                return;
            }
            var btn = $(this).find('button[type="submit"]');
            btn.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Đang xử lý...');
            $.post('api/tasks', { action:'reject', id: id, rejectionReason: reason }, function(res){
                try{ if(typeof res === 'string') res = JSON.parse(res); }catch(e){}
                alert(res.message||'');
                if(res.success){
                    $('#rejectTaskModal').modal('hide');
                    loadTasks();
                }
            }).fail(function(){
                alert('Lỗi kết nối!');
            }).always(function(){
                btn.prop('disabled', false).html('<i class="fa fa-check"></i> Xác nhận từ chối');
            });
        });

        // ===== LƯU & KHÔI PHỤC TRẠNG THÁI BỘ LỌC + GIÁ TRỊ FILTER =====
        function saveMyTaskFilterState(isExpanded) {
            localStorage.setItem('myTaskFilterExpanded', isExpanded ? '1' : '0');
        }
        function loadMyTaskFilterState() {
            return localStorage.getItem('myTaskFilterExpanded') === '1';
        }
        function saveMyTaskFilterValues() {
            var filterVals = {
                status: document.getElementById('statusFilter').value,
                priority: document.getElementById('priorityFilter').value,
                q: document.getElementById('q').value,
                scheduledFrom: document.getElementById('scheduledFrom').value,
                scheduledTo: document.getElementById('scheduledTo').value,
                pageSize: document.getElementById('pageSize').value
            };
            localStorage.setItem('myTaskFilterValues', JSON.stringify(filterVals));
        }
        function loadMyTaskFilterValues() {
            var vals = localStorage.getItem('myTaskFilterValues');
            if(vals) {
                try {
                    vals = JSON.parse(vals);
                    if(vals.status !== undefined) document.getElementById('statusFilter').value = vals.status;
                    if(vals.priority !== undefined) document.getElementById('priorityFilter').value = vals.priority;
                    if(vals.q !== undefined) document.getElementById('q').value = vals.q;
                    if(vals.scheduledFrom !== undefined) document.getElementById('scheduledFrom').value = vals.scheduledFrom;
                    if(vals.scheduledTo !== undefined) document.getElementById('scheduledTo').value = vals.scheduledTo;
                    if(vals.pageSize !== undefined) document.getElementById('pageSize').value = vals.pageSize;
                } catch(e) {}
            }
        }
        // --- Sửa toggleFilters để lưu trạng thái ---
        function toggleFilters() {
            var content = document.getElementById('filterContent');
            var icon = document.getElementById('filterToggleIcon');
            var expanded;
            if (content.classList.contains('show')) {
                content.classList.remove('show');
                icon.classList.remove('rotated');
                expanded = false;
            } else {
                content.classList.add('show');
                icon.classList.add('rotated');
                expanded = true;
            }
            saveMyTaskFilterState(expanded);
        }
        // --- Gán lại trạng thái expand/collapse + value khi DOM ready ---
        document.addEventListener('DOMContentLoaded', function() {
            var content = document.getElementById('filterContent');
            var icon = document.getElementById('filterToggleIcon');
            if (loadMyTaskFilterState()) {
                content.classList.add('show');
                icon.classList.add('rotated');
            } else {
                content.classList.remove('show');
                icon.classList.remove('rotated');
            }
            loadMyTaskFilterValues();
            // Tải danh sách ngay khi mở trang
            loadTasks();
        });
        // --- Mỗi lần bấm Lọc, chuyển input/select hoặc Xóa lọc thì lưu giá trị ---
        // Lưu giá trị filter trước khi loadTasks
        function myTasksFilterBeforeLoad() {
            saveMyTaskFilterValues();
        }
        // Thay đổi event onsubmit filter form
        var filterForm = document.querySelector('.filter-content form');
        if(filterForm) {
            filterForm.addEventListener('submit', function(){
                myTasksFilterBeforeLoad();
            });
        }
        // Các trường khi change cũng lưu lại giá trị
        ['statusFilter','priorityFilter','q','scheduledFrom','scheduledTo','pageSize'].forEach(function(id){
            var el = document.getElementById(id);
            if(el) {
                el.addEventListener('change', saveMyTaskFilterValues);
                el.addEventListener('input', saveMyTaskFilterValues);
            }
        });
        // --- Sửa luôn hàm resetFilters để xóa input+localStorage về mặc định ---
        function resetFilters(){
            document.getElementById('statusFilter').value = '';
            document.getElementById('priorityFilter').value = '';
            document.getElementById('scheduledFrom').value = '';
            document.getElementById('scheduledTo').value = '';
            document.getElementById('q').value = '';
            document.getElementById('pageSize').value = '10';
            localStorage.removeItem('myTaskFilterValues');
            currentPage = 1;
            loadTasks();
        }
    </script>
</body>
</html>