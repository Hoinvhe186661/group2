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
                                    <form class="form-inline" onsubmit="event.preventDefault(); loadTasks();" style="margin-bottom: 12px;">
                                        <div class="form-group" style="margin-right: 8px;">
                                            <label for="statusFilter">Trạng thái:&nbsp;</label>
                                            <select id="statusFilter" class="form-control">
                                                <option value="">Tất cả</option>
                                                <option value="pending">Chờ nhận</option>
                                                <option value="in_progress">Đang thực hiện</option>
                                                <option value="completed">Đã hoàn thành</option>
                                                <option value="cancelled">Đã hủy</option>
                                            </select>
                                        </div>
                                        <div class="form-group" style="margin-right: 8px;">
                                            <label for="priorityFilter">Ưu tiên:&nbsp;</label>
                                            <select id="priorityFilter" class="form-control">
                                                <option value="">Tất cả</option>
                                                <option value="low">Thấp</option>
                                                <option value="medium">Trung bình</option>
                                                <option value="high">Cao</option>
                                                <option value="urgent">Khẩn cấp</option>
                                            </select>
                                        </div>
                                        <div class="form-group" style="margin-right: 8px;">
                                            <label>Bắt đầu:&nbsp;</label>
                                            <input type="date" id="scheduledFrom" class="form-control">
                                        </div>
                                        <div class="form-group" style="margin-right: 8px;">
                                            <label>Đến:&nbsp;</label>
                                            <input type="date" id="scheduledTo" class="form-control">
                                        </div>
                                        <div class="form-group" style="margin-right: 8px;">
                                            <label for="q">Tìm:&nbsp;</label>
                                            <input type="text" id="q" class="form-control" placeholder="WO/Task/tiêu đề/mô tả">
                                        </div>
                                        <button class="btn btn-default" type="submit"><i class="fa fa-filter"></i> Lọc</button>
                                        <button class="btn btn-link" type="button" onclick="resetFilters()">Xóa lọc</button>
                                        <div class="form-group" style="margin-left: 8px;">
                                            <label for="pageSize">Hiển thị:&nbsp;</label>
                                            <select id="pageSize" class="form-control" onchange="changePageSize()">
                                                <option value="5">5</option>
                                                <option value="10" selected>10</option>
                                                <option value="20">20</option>
                                                <option value="50">50</option>
                                            </select>
                                        </div>
                                    </form>
                                    <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>WO</th>
                                            <th>Nhiệm vụ</th>
                                            <th>Trạng thái</th>
                                            <th>Ưu tiên</th>
                                            <th>Ngày nhận</th>
                                            <th>Ngày hoàn thành</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="taskBody">
                                        <tr><td colspan="5" class="text-center text-muted">Đang tải...</td></tr>
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

    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
    <script src="js/jquery.min.js" type="text/javascript"></script>
    <script src="js/bootstrap.min.js" type="text/javascript"></script>
    <script>
        var currentUserId = <%= session.getAttribute("userId") != null ? session.getAttribute("userId") : 0 %>;

        function badgeForStatus(s){
            var map = {pending:'label-default', in_progress:'label-warning', completed:'label-success', cancelled:'label-default'};
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
                if(!res.success){ tbody.innerHTML = '<tr><td colspan="5">' + (res.message||'Lỗi tải dữ liệu') + '</td></tr>'; return; }
                if(!res.data || res.data.length === 0){ tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">Không có nhiệm vụ</td></tr>'; renderPagination(res.meta); return; }
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
                    }
                    if(it.taskStatus === 'in_progress'){
                        actions.push('<button class="btn btn-xs btn-success" onclick="completeTask(' + it.taskId + ')"><i class="fa fa-flag-checkered"></i> Hoàn thành</button>');
                    }
                    var tr = document.createElement('tr');
                    tr.innerHTML = '' +
                        '<td><div><strong>' + (it.workOrderNumber||'') + '</strong></div><div>' + (it.workOrderTitle||'') + '</div></td>' +
                        '<td><div><strong>' + (it.taskNumber||'') + '</strong></div><div>' + (it.taskDescription||'') + '</div></td>' +
                        '<td>' + badgeForStatus(it.taskStatus) + '</td>' +
                        '<td>' + (it.taskPriority||'') + '</td>' +
                        '<td>' + (fmt(it.startDate) || '<span class="text-muted">-</span>') + '</td>' +
                        '<td>' + (fmt(it.completionDate) || '<span class="text-muted">-</span>') + '</td>' +
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

        function completeTask(id){
            var notes = prompt('Ghi chú hoàn thành (tuỳ chọn):','');
            var actualHours = prompt('Số giờ thực tế (tuỳ chọn):','');
            $.post('api/tasks', { action:'complete', id: id, notes: notes, actualHours: actualHours }, function(res){
                try{ res = JSON.parse(res); }catch(e){}
                alert(res.message||'');
                if(res.success) loadTasks();
            });
        }

        document.addEventListener('DOMContentLoaded', loadTasks);
    </script>
</body>
</html>


