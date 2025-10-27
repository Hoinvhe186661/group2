<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    </style>
</head>
<body class="skin-black">
    <header class="header">
        <a href="technical_staff.jsp" class="logo">
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
                <ul class="sidebar-menu">
                    <li class="active">
                        <a href="my_tasks.jsp"><i class="fa fa-wrench"></i> <span>Nhiệm vụ của tôi</span></a>
                    </li>
                </ul>
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
                                                        <input type="text" id="q" class="form-control" placeholder="Mã nhiệm vụ (vd: T-002)">
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
                                            <th>Ngày nhận</th>
                                            <th>Ngày hoàn thành</th>
                                            <th>Lý do từ chối</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="taskBody">
                                        <tr><td colspan="8" class="text-center text-muted">Đang tải...</td></tr>
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
                                           id="completionPercentage" min="0" max="100" value="100" 
                                           style="width: 100%; margin-top: 8px;">
                                    <div class="text-center" style="margin-top: 5px;">
                                        <strong style="font-size: 18px; color: #00a65a;">
                                            <span id="percentageValue">100</span>%
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
            if (content.classList.contains('show')) {
                content.classList.remove('show');
                icon.classList.remove('rotated');
            } else {
                content.classList.add('show');
                icon.classList.add('rotated');
            }
        }

        function badgeForStatus(s){
            var map = {pending:'label-default', in_progress:'label-warning', completed:'label-success', cancelled:'label-default', rejected:'label-danger'};
            return '<span class="label ' + (map[s]||'label-default') + '">' + (s||'') + '</span>';
        }

        var currentPage = 1;

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
                if(!res.success){ tbody.innerHTML = '<tr><td colspan="8">' + (res.message||'Lỗi tải dữ liệu') + '</td></tr>'; return; }
                if(!res.data || res.data.length === 0){ tbody.innerHTML = '<tr><td colspan="8" class="text-center text-muted">Không có nhiệm vụ</td></tr>'; renderPagination(res.meta); return; }
                renderPagination(res.meta);
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
                    if(it.taskStatus === 'pending'){
                        actions.push('<button class="btn btn-xs btn-primary" onclick="ack(' + it.taskId + ')"><i class="fa fa-check"></i> Nhận</button>');
                        actions.push('<button class="btn btn-xs btn-danger" onclick="rejectTask(' + it.taskId + ')"><i class="fa fa-times"></i> Từ chối</button>');
                    }
                    if(it.taskStatus === 'in_progress'){
                        actions.push('<button class="btn btn-xs btn-success" onclick="openCompleteModal(' + it.taskId + ', \'' + (it.taskNumber||'').replace(/'/g, "\\'") + '\', \'' + (it.taskDescription||'').replace(/'/g, "\\'") + '\')"><i class="fa fa-flag-checkered"></i> Hoàn thành</button>');
                    }
                    if(it.taskStatus === 'completed'){
                        actions.push('<button class="btn btn-xs btn-info" onclick="viewReport(' + it.taskId + ')"><i class="fa fa-eye"></i> Xem báo cáo</button>');
                    }
                    
                    var tr = document.createElement('tr');
                    tr.innerHTML = 
                        '<td><div><strong>' + (it.workOrderNumber||'') + '</strong></div><div>' + (it.workOrderTitle||'') + '</div></td>' +
                        '<td><div><strong>' + (it.taskNumber||'') + '</strong></div><div>' + (it.taskDescription||'') + '</div></td>' +
                        '<td>' + badgeForStatus(it.taskStatus) + '</td>' +
                        '<td>' + (it.taskPriority||'') + '</td>' +
                        '<td>' + (fmt(it.startDate) || '<span class="text-muted">-</span>') + '</td>' +
                        '<td>' + (fmt(it.completionDate) || '<span class="text-muted">-</span>') + '</td>' +
                        '<td>' + (it.rejectionReason ? '<span class="text-danger">' + it.rejectionReason + '</span>' : '<span class="text-muted">-</span>') + '</td>' +
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
            $('#percentageValue').text('100');
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

        function rejectTask(id){
            var reason = prompt('Lý do từ chối (bắt buộc):', '');
            if(reason === null) return; // User cancelled
            if(reason.trim() === ''){
                alert('Vui lòng nhập lý do từ chối');
                return;
            }
            $.post('api/tasks', { action:'reject', id: id, rejectionReason: reason.trim() }, function(res){
                try{ res = JSON.parse(res); }catch(e){}
                alert(res.message||'');
                if(res.success) loadTasks();
            });
        }

        document.addEventListener('DOMContentLoaded', loadTasks);
    </script>
</body>
</html>