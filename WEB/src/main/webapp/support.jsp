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
    
    // Kiểm tra quyền truy cập - tất cả role đều có thể gửi yêu cầu hỗ trợ
    // Nhưng chỉ customer, customer_support, admin mới có thể xem trang này
    boolean canAccessSupport = "admin".equals(userRole) || "customer_support".equals(userRole) || 
                              "customer".equals(userRole) || "guest".equals(userRole);
    if (!canAccessSupport) {
        response.sendRedirect(request.getContextPath() + "/403.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Công ty CP Chế tạo máy Hoà Lạc - Chuyên cung cấp máy phát điện chính hãng</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css"/>
    <style>
        :root { --primary-red:#dc3545; --text-dark:#343a40; }
        .top-header { background: var(--primary-red); color:#ffffff; padding:8px 0; font-size:14px; }
        .header-text { font-weight:600; text-transform:uppercase; }
        .contact-info { margin-right:20px; }

        /* Navbar tweaks */
        .navbar { box-shadow:0 2px 10px rgba(0,0,0,0.06); }
        .navbar .nav-link { color: var(--text-dark); font-weight:500; text-transform:uppercase; }
        .navbar .nav-link:hover, .navbar .nav-link.active { color: var(--primary-red); }

        /* Search */
        .search-container { position:relative; margin:0 20px; }
        .search-input { width:300px; max-width:42vw; padding:12px 45px 12px 15px; border:1px solid #dee2e6; border-radius:25px; font-size:14px; }
        .search-icon { position:absolute; right:15px; top:50%; transform:translateY(-50%); color:#6c757d; }
        .phone-number { color:var(--primary-red); font-weight:600; }

        /* Support header */
        .support-header { background:#ffffff; border:1px solid #eee; border-radius:12px; padding:14px 16px; box-shadow:0 4px 16px rgba(0,0,0,0.05); }
        .support-title { margin:0; color:var(--text-dark); font-weight:700; letter-spacing:.2px; }
        .create-request-link { color:var(--primary-red); text-decoration:none; font-weight:500; }
        .create-request-link:hover { text-decoration:underline; }

        /* Table style */
        .support-table thead th { background:#f8f9fa; color:#495057; font-weight:600; border-bottom:2px solid #e9ecef; }
        .support-table tbody tr:hover { background:#fffafa; }

        /* Pagination */
        .custom-pagination .page-link { color:var(--text-dark); border:none; border-radius:8px; margin:0 3px; }
        .custom-pagination .page-item.active .page-link, .custom-pagination .page-link:hover { background:var(--primary-red); color:#fff; }

        /* Floating icons */
        .floating-icons { position:fixed; right:18px; bottom:18px; z-index:1030; }
        .floating-icon { width:44px; height:44px; border-radius:50%; display:flex; align-items:center; justify-content:center; background:#ffffff; color:var(--text-dark); box-shadow:0 6px 20px rgba(0,0,0,0.12); margin:8px 0; cursor:pointer; transition:transform .2s ease, box-shadow .2s ease, color .2s ease; }
        .floating-icon:hover { transform:translateY(-2px); box-shadow:0 8px 24px rgba(0,0,0,0.16); color:var(--primary-red); }

        /* Modal header */
        .modal-header { background:#f8f9fa; }
        .btn-success { background:#28a745; border-color:#28a745; }
        .btn-danger { background:#dc3545; border-color:#dc3545; }
        
        /* Khung cho các trường thông tin */
        .form-control-plaintext { 
            background: #ffffff; 
            border: 1px solid #ced4da; 
            border-radius: 6px; 
            padding: 0.75rem; 
            margin-bottom: 0.5rem;
            min-height: 2.5rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        /* Khung cho textarea */
        .form-control { 
            border: 1px solid #ced4da; 
            border-radius: 6px; 
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        /* Khung cho modal */
        .modal-content { 
            border: 2px solid #dee2e6; 
            box-shadow: 0 8px 32px rgba(0,0,0,0.1); 
        }
        
        /* Padding cho modal body */
        .modal-body { 
            padding: 2rem; 
        }
        
        /* Styling cho labels */
        .modal-body label { 
            font-weight: 600; 
            color: #495057; 
            margin-bottom: 0.5rem; 
        }
        
        /* Focus state */
        .form-control:focus { 
            border-color: #80bdff; 
            box-shadow: 0 0 0 0.2rem rgba(0,123,255,.25); 
        }
    </style>
    </head>
    <body>
    <!-- Top Header -->
    <%@ include file="header.jsp" %>
    
    

    
    

    <div class="container mt-4">
    <div class="support-header mb-3 d-flex justify-content-between align-items-center">
        <div>
            <h4 class="support-title">Yêu cầu hỗ trợ</h4>
            <a href="#" class="create-request-link" data-bs-toggle="modal" data-bs-target="#supportModal">Tạo yêu cầu mới +</a>
        </div>
        <div class="d-flex align-items-center gap-2 support-search" style="min-width:580px;">
            <input type="text" class="form-control" placeholder="Tìm kiếm..." style="max-width:200px;" id="searchInput">
            <select id="filterStatus" class="form-select" style="max-width:140px;">
              <option value="">Tất cả trạng thái</option>
              <option value="waiting">Chờ xử lý</option>
              <option value="in_progress">Đang xử lý</option>
              <option value="resolved">Đã giải quyết</option>
              <option value="cancelled">Đã hủy</option>
              <option value="closed">Đã đóng</option>
            </select>
            <select id="filterCategory" class="form-select" style="max-width:140px;">
              <option value="">Tất cả loại</option>
              <option value="technical">Kỹ thuật</option>
              <option value="billing">Thanh toán</option>
              <option value="general">Chung</option>
              <option value="complaint">Khiếu nại</option>
            </select>
            <button type="button" class="btn btn-primary btn-sm" id="filterBtn" style="min-width:60px;">
              <i class="fas fa-filter"></i> Lọc
            </button>
            <button type="button" class="btn btn-secondary btn-sm" id="clearFilterBtn" style="min-width:60px;">
              <i class="fas fa-times"></i> Xóa
            </button>
        </div>
    </div>
    <div class="table-responsive">
        <table class="table support-table align-middle">
            <thead>
                <tr>
                  <th style="cursor: pointer;">ID <span id="sortIdArrow">↕</span></th>
                    <th>Loại yêu cầu</th>
                    <th>Tiêu đề</th>
                    <th style="cursor: pointer;">Ngày tạo <span id="sortDateArrow">↕</span></th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody id="supportRows"></tbody>
        </table>
    </div>
    <div class="d-flex justify-content-end mt-2">
        <nav>
            <ul class="pagination custom-pagination mb-0">
                <li class="page-item"><a class="page-link" href="#">Trước</a></li>
                <li class="page-item active"><a class="page-link" href="#">1</a></li>
                <li class="page-item"><a class="page-link" href="#">Tiếp</a></li>
            </ul>
        </nav>
    </div>
</div>

    <!-- Modal Yêu cầu hỗ trợ -->
<div class="modal fade" id="supportModal" tabindex="-1" aria-labelledby="supportModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content" style="border-radius:30px;">
      <div class="modal-header">
        <h5 class="modal-title" id="supportModalLabel">Yêu cầu hỗ trợ</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
      </div>
      <div class="modal-body">
        <form id="supportForm">
          <div class="row mb-2">
            <div class="col-6">
              <label>Họ tên</label>
              <input type="text" class="form-control" id="displayName" readonly>
            </div>
            <div class="col-6">
              <label>Email</label>
              <input type="email" class="form-control" id="email" readonly>
            </div>
          </div>
          <div class="row mb-2">
            <div class="col-12">
              <label>Hợp đồng</label>
              <select class="form-control" id="contractSelect">
                <option value="">-- Chọn hợp đồng --</option>
              </select>
            </div>
          </div>
          <div class="row mb-2">
            <div class="col-12">
              <label>Sản phẩm trong hợp đồng</label>
              <select class="form-control" id="contractProductSelect" disabled>
                <option value="">-- Chọn sản phẩm --</option>
              </select>
            </div>
          </div>
          <div class="mb-2">
            <label>Tiêu đề:</label>
            <input type="text" class="form-control" id="subject" placeholder="Nhập tiêu đề">
          </div>
          <div class="mb-2">
            <label>Loại yêu cầu :</label>
            <select class="form-control" id="category">
                <option value="technical">Kỹ thuật</option>
                <option value="billing">Thanh toán</option>
                <option value="general" selected>Chung</option>
                <option value="complaint">Khiếu nại</option>
            </select>
          </div>
          <div class="mb-2">
            <label>Ngày tạo :</label>
            <input type="date" class="form-control" id="createdDate" readonly>
            <small class="text-muted" id="createdDateText"></small>
          </div>
          <div class="mb-2">
            <label>Chi tiết vấn đề :</label>
            <textarea class="form-control" id="description"></textarea>
          </div>
          <div class="text-end mt-3">
            <button type="submit" class="btn btn-success" id="submitBtn">Xác nhận</button>
            <button type="button" class="btn btn-danger" data-bs-dismiss="modal">Hủy bỏ</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<!-- Modal xem chi tiết yêu cầu -->
<div class="modal fade" id="viewModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content" style="border-radius:20px;">
      <div class="modal-header">
        <h5 class="modal-title">Chi tiết yêu cầu hỗ trợ</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
      </div>
      <div class="modal-body">
        <div class="row g-3">
          <div class="col-md-6"><label>Mã ticket</label><div id="v_ticket" class="form-control-plaintext"></div></div>
          <div class="col-md-6"><label>Trạng thái</label><div id="v_status" class="form-control-plaintext"></div></div>
          <div class="col-md-6"><label>Loại yêu cầu</label>
            <select id="v_category_inp" class="form-control" disabled>
              <option value="technical">Kỹ thuật</option>
              <option value="billing">Thanh toán</option>
              <option value="general">Chung</option>
              <option value="complaint">Khiếu nại</option>
            </select>
          </div>
          <div class="col-md-6">
            <label>Hợp đồng</label>
            <select id="v_contract_select" class="form-control" disabled>
              <option value="">-- Chọn hợp đồng --</option>
            </select>
          </div>
          <div class="col-md-6"><label>Ưu tiên</label>
            <select id="v_priority_inp" class="form-control" disabled>
              <option value="">--</option>
              <option value="urgent">Cao</option>
              <option value="high">Trung bình</option>
              <option value="medium">Thường</option>
              <option value="low">Thấp</option>
            </select>
          </div>
          <div class="col-md-6">
            <label>Sản phẩm trong hợp đồng</label>
            <select id="v_product_select" class="form-control" disabled>
              <option value="">-- Chọn sản phẩm --</option>
            </select>
          </div>
          <div class="col-12"><label>Tiêu đề</label><input id="v_subject_inp" class="form-control" disabled/></div>
          <div class="col-12"><label>Chi tiết vấn đề</label><textarea id="v_description_inp" class="form-control" rows="4" disabled></textarea></div>
          <div class="col-md-6"><label>Ngày tạo</label><div id="v_created" class="form-control-plaintext"></div></div>
          <div class="col-md-6"><label>Ngày xử lý xong</label><div id="v_resolved" class="form-control-plaintext"></div></div>
          <div class="col-md-6"><label>Người được phân công</label><div id="v_assigned_to" class="form-control-plaintext"></div></div>
          <div class="col-md-6"><label>Lịch sử xử lý</label><div id="v_history" class="form-control-plaintext"></div></div>
          <div class="col-12"><label>Giải pháp</label><textarea id="v_resolution" class="form-control" rows="3" readonly></textarea></div>
          <div class="col-12 d-flex align-items-center justify-content-between">
            <div class="form-check">
              <input class="form-check-input" type="checkbox" id="v_enable_edit">
              <label class="form-check-label" for="v_enable_edit">Chỉnh sửa </label>
            </div>
            <button type="button" id="v_save_btn" class="btn btn-success" disabled>Lưu thành yêu cầu mới</button>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
      </div>
    </div>
  </div>
</div>
<script>
  // Tự động set ngày hiện tại cho trường "Ngày tạo"
  document.addEventListener('DOMContentLoaded', function() {
    // Set date using local timezone to avoid UTC offset (+/-1 day) issues
    var now = new Date();
    var yyyyLocal = now.getFullYear();
    var mmLocal = String(now.getMonth() + 1).padStart(2, '0');
    var ddLocal = String(now.getDate()).padStart(2, '0');
    var todayLocal = yyyyLocal + '-' + mmLocal + '-' + ddLocal;
    var createdInput = document.getElementById('createdDate');
    var createdText = document.getElementById('createdDateText');
    if (createdInput) createdInput.value = todayLocal;
    try {
      var d = new Date();
      var dd = String(d.getDate()).padStart(2,'0');
      var mm = String(d.getMonth()+1).padStart(2,'0');
      var yyyy = d.getFullYear();
      if (createdText) createdText.textContent = dd + '/' + mm + '/' + yyyy;
    } catch(e) {}
    
    const ctx = '<%=request.getContextPath()%>';
    // Prefill name/email: first from live API, fallback to session variables
    try {
      const sessionEmail = '<%= String.valueOf(session.getAttribute("email")) %>';
      const sessionUsername = '<%= String.valueOf(session.getAttribute("username")) %>';
      const sessionFullName = '<%= String.valueOf(session.getAttribute("fullName")) %>';
      const sessionCustomerId = '<%= String.valueOf(session.getAttribute("customerId")) %>';
      const sessionUserId = '<%= String.valueOf(session.getAttribute("userId")) %>';
      const emailInp = document.getElementById('email');
      const nameInp = document.getElementById('displayName');
      // Fill from session immediately
      if (emailInp && sessionEmail && sessionEmail !== 'null') emailInp.value = sessionEmail;
      if (nameInp) {
        const name = (sessionFullName && sessionFullName !== 'null') ? sessionFullName : (sessionUsername && sessionUsername !== 'null' ? sessionUsername : '');
        nameInp.value = name;
      }
      // Then fetch fresh user info to reflect any recent changes and update header too
      if (sessionUserId && sessionUserId !== 'null') {
        fetch(ctx + '/api/users?action=get&id=' + encodeURIComponent(sessionUserId), { headers: { 'Accept': 'application/json' } })
          .then(function(r){ return r.json(); })
          .then(function(j){
            if (j && j.success && j.data) {
              const u = j.data;
              if (emailInp && u.email) emailInp.value = u.email;
              if (nameInp && (u.fullName || u.username)) nameInp.value = (u.fullName || u.username);
              try {
                var headerUser = document.querySelector('.user-info');
                if (headerUser) headerUser.innerHTML = '<i class="fas fa-user"></i> ' + (u.fullName || u.username || '');
              } catch(e) {}
            }
          }).catch(function(){});
      }

      // Load contracts (already filtered by backend based on session customerId)
      const contractSelect = document.getElementById('contractSelect');
      const productSelect = document.getElementById('contractProductSelect');
      // ctx already defined above; avoid redeclaration that breaks script execution
      fetch(ctx + '/api/contracts', { headers: { 'Accept': 'application/json' } })
        .then(r => r.json())
        .then(j => {
          if (!j || !j.success) return;
          const list = Array.isArray(j.data) ? j.data : [];
          list.forEach(it => {
            const opt = document.createElement('option');
            opt.value = it.id;
            opt.textContent = (it.contractNumber ? (it.contractNumber + ' - ') : '') + (it.title || ('HĐ #' + it.id));
            contractSelect.appendChild(opt);
          });
        });

      // Luôn prefill lại thông tin người dùng mỗi khi mở modal (tránh bị xoá bởi reset)
      try {
        const modalEl = document.getElementById('supportModal');
        if (modalEl) {
          modalEl.addEventListener('show.bs.modal', function(){
            if (emailInp && sessionEmail && sessionEmail !== 'null') emailInp.value = sessionEmail;
            if (nameInp) {
              const name = (sessionFullName && sessionFullName !== 'null') ? sessionFullName : (sessionUsername && sessionUsername !== 'null' ? sessionUsername : '');
              nameInp.value = name;
            }
          });
        }
      } catch(e) {}

      contractSelect.addEventListener('change', function(){
        const id = this.value;
        productSelect.innerHTML = '<option value="">-- Chọn sản phẩm --</option>';
        productSelect.disabled = !id;
        if (!id) return;
        fetch(ctx + '/api/contract-items?contractId=' + encodeURIComponent(id), { headers: { 'Accept': 'application/json' } })
          .then(r => r.json())
          .then(j => {
            if (!j || !j.success) return;
            const arr = Array.isArray(j.data) ? j.data : [];
            arr.forEach(item => {
              const opt = document.createElement('option');
              opt.value = item.productId;
              const name = item.description ? item.description : ('Sản phẩm #' + item.productId);
              opt.textContent = name;
              opt.dataset.quantity = item.quantity != null ? String(item.quantity) : '';
              opt.dataset.unitPrice = item.unitPrice != null ? String(item.unitPrice) : '';
              productSelect.appendChild(opt);
            });
          });
      });
    } catch (e) {}
    const tbody = document.getElementById('supportRows');
    const pagerContainer = document.querySelector('.pagination.custom-pagination');
    let allItems = [];
    let filteredItems = [];
    let currentPage = 1;
    const pageSize = 9;
    let cancelledItems = new Set(); // Lưu trữ các ID đã hủy trên frontend
    let searchTerm = ''; // Lưu từ khóa tìm kiếm
    let filterStatus = ''; // Lọc theo trạng thái
    let filterCategory = ''; // Lọc theo loại yêu cầu
    let sortDirectionId = true; // true = tăng dần, false = giảm dần
    let sortDirectionDate = true; // true = tăng dần, false = giảm dần
    function formatDate(it){
      if (it.createdDate && typeof it.createdDate === 'string' && it.createdDate.includes('-')) {
        var parts = it.createdDate.split('-');
        if (parts.length === 3) return parts[2] + '/' + parts[1] + '/' + parts[0];
      }
      if (it.createdAt) {
        try {
          return new Intl.DateTimeFormat('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' }).format(new Date(it.createdAt));
        } catch (e) {}
      }
      return '';
    }
    
    function getStatusText(status) {
      const statusMap = {
        'pending': 'Chờ xử lý',
        'open': 'Chờ xử lý',
        'in_progress': 'Đang xử lý',
        'resolved': 'Đã giải quyết',
        'cancelled': 'Đã hủy',
        'closed': 'Đã đóng'
      };
      return statusMap[status] || 'Chờ xử lý';
    }
    
    function getStatusClass(status) {
      const classMap = {
        'pending': 'bg-warning',
        'open': 'bg-warning',
        'in_progress': 'bg-info',
        'resolved': 'bg-success',
        'cancelled': 'bg-danger',
        'closed': 'bg-secondary'
      };
      return classMap[status] || 'bg-warning';
    }
    
    function filterItems() {
      const term = searchTerm.trim().toLowerCase();
      filteredItems = allItems.filter(function(item){
        // text match
        const textOk = !term || (
          (item.subject && item.subject.toLowerCase().includes(term)) ||
          (item.description && item.description.toLowerCase().includes(term)) ||
          (item.category && item.category.toLowerCase().includes(term)) ||
          (item.ticketNumber && item.ticketNumber.toLowerCase().includes(term))
        );
        // status match (use final status considering cancelled set)
        const st = (cancelledItems.has(String(item.id)) ? 'cancelled' : (item.status || 'pending'));
        const statusOk = !filterStatus || (filterStatus === 'waiting' ? (st === 'open' || st === 'pending') : st === filterStatus);
        // category match
        const categoryOk = !filterCategory || (item.category||'').toLowerCase() === filterCategory;
        return textOk && statusOk && categoryOk;
      });
    }
    
    function rows(items){
      tbody.innerHTML = '';
      if(!items || !items.length){
        tbody.innerHTML = '<tr><td colspan="6" class="text-center">Chưa có yêu cầu nào</td></tr>';
        return;
      }
      items.forEach(function(it, idx){
        const created = formatDate(it);
        // Ưu tiên trạng thái đã hủy trên frontend
        const finalStatus = cancelledItems.has(String(it.id)) ? 'cancelled' : (it.status || 'pending');
        const status = getStatusText(finalStatus);
        const statusClass = getStatusClass(finalStatus);
        const tr = document.createElement('tr');
        // Chỉ hiển thị nút hủy khi có thể hủy (pending hoặc open)
        const canCancel = finalStatus === 'pending' || finalStatus === 'open';
        const cancelButton = canCancel ? '<a href="#" class="cancel-link text-danger" data-id="'+ (it.id||'') +'">Hủy</a>' : '';
        // Tính số thứ tự theo thời gian tạo (mới nhất = 1)
        const sequenceNumber = (currentPage - 1) * pageSize + idx + 1;
        var displaySubject = (it.subject||'');
        tr.innerHTML = '<td>'+ sequenceNumber +'</td><td>'+ (it.category||'') +'</td><td>'+ displaySubject +'</td><td>'+ created +'</td><td><span class="badge ' + statusClass + '">' + status + '</span></td><td><a href="#" class="view-link me-2" data-id="'+ (it.id||'') +'">Xem</a> ' + cancelButton + '</td>';
        tbody.appendChild(tr);
      });
    }

    function renderPagination(totalItems){
      if(!pagerContainer) return;
      const totalPages = Math.max(1, Math.ceil(totalItems / pageSize));
      let html = '';
      html += '<li class="page-item'+(currentPage===1?' disabled':'')+'"><a class="page-link" href="#" data-page="prev">Trước</a></li>';
      // show only current page number
      html += '<li class="page-item active"><a class="page-link" href="#" data-page="'+currentPage+'">'+currentPage+'</a></li>';
      html += '<li class="page-item'+(currentPage===totalPages?' disabled':'')+'"><a class="page-link" href="#" data-page="next">Tiếp</a></li>';
      pagerContainer.innerHTML = html;
    }

    function renderPage(page){
      const total = filteredItems.length;
      const totalPages = Math.max(1, Math.ceil(total / pageSize));
      if(page === 'prev') page = Math.max(1, currentPage - 1);
      if(page === 'next') page = Math.min(totalPages, currentPage + 1);
      page = Math.min(Math.max(1, parseInt(page||1,10)), totalPages);
      currentPage = page;
      const start = (page - 1) * pageSize;
      const end = start + pageSize;
      const pageItems = filteredItems.slice(start, end);
      rows(pageItems);
      renderPagination(total);
    }
    
    // Hàm sắp xếp theo ID
    function sortById(ascending) {
      filteredItems.sort((a, b) => {
        const idA = parseInt(a.id) || 0;
        const idB = parseInt(b.id) || 0;
        return ascending ? idA - idB : idB - idA;
      });
      renderPage(1);
    }
    
    // Hàm sắp xếp theo ngày tạo
    function sortByDate(ascending) {
      filteredItems.sort((a, b) => {
        const dateA = new Date(a.createdDate || a.createdAt || 0);
        const dateB = new Date(b.createdDate || b.createdAt || 0);
        return ascending ? dateA - dateB : dateB - dateA;
      });
      renderPage(1);
    }
    function load(){
      fetch(ctx + '/api/support-stats?action=list', {headers:{'Accept':'application/json'}})
        .then(r=>r.json()).then(j=>{ 
          allItems = Array.isArray(j.data)? j.data : []; 
          filterItems();
          renderPage(1); 
        })
        .catch(()=>{tbody.innerHTML='<tr><td colspan="7" class="text-center text-danger">Lỗi tải dữ liệu</td></tr>';});
    }
    load();

    // Thêm event listener cho sắp xếp
    document.querySelector('th:nth-child(1)').addEventListener('click', function() {
      sortDirectionId = !sortDirectionId;
      sortById(sortDirectionId);
      document.getElementById('sortIdArrow').textContent = sortDirectionId ? ' ↑' : ' ↓';
    });
    
    document.querySelector('th:nth-child(4)').addEventListener('click', function() {
      sortDirectionDate = !sortDirectionDate;
      sortByDate(sortDirectionDate);
      document.getElementById('sortDateArrow').textContent = sortDirectionDate ? ' ↑' : ' ↓';
    });

    // Thêm chức năng tìm kiếm và lọc
    const searchInput = document.getElementById('searchInput');
    const statusSelect = document.getElementById('filterStatus');
    const categorySelect = document.getElementById('filterCategory');
    const filterBtn = document.getElementById('filterBtn');
    const clearFilterBtn = document.getElementById('clearFilterBtn');
    
    // Hàm áp dụng bộ lọc
    function applyFilters() {
      searchTerm = searchInput ? searchInput.value.trim() : '';
      filterStatus = statusSelect ? statusSelect.value : '';
      filterCategory = categorySelect ? categorySelect.value : '';
      filterItems();
      renderPage(1);
    }
    
    // Hàm xóa bộ lọc
    function clearFilters() {
      if (searchInput) searchInput.value = '';
      if (statusSelect) statusSelect.selectedIndex = 0;
      if (categorySelect) categorySelect.selectedIndex = 0;
      searchTerm = '';
      filterStatus = '';
      filterCategory = '';
      filterItems();
      renderPage(1);
    }
    
    // Event listeners
    if (filterBtn) {
      filterBtn.addEventListener('click', applyFilters);
    }
    
    if (clearFilterBtn) {
      clearFilterBtn.addEventListener('click', clearFilters);
    }
    
    // Cho phép Enter để lọc
    if (searchInput) {
      searchInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
          applyFilters();
        }
      });
    }

    if (pagerContainer) {
      pagerContainer.addEventListener('click', function(e){
        const a = e.target.closest('a[data-page]');
        if(!a) return;
        e.preventDefault();
        const p = a.getAttribute('data-page');
        renderPage(p === 'prev' || p === 'next' ? p : parseInt(p,10));
      });
    }

    // Handle submit
    document.getElementById('supportForm').addEventListener('submit', function(e){
      e.preventDefault();
      const form = e.target;
      const data = new URLSearchParams();
      const subject = document.getElementById('subject').value || '';
      const baseDesc = document.getElementById('description').value || '';
      // Lưu hợp đồng/sản phẩm vào mô tả để hiển thị lại ở chi tiết (danh sách sẽ ẩn các tiền tố này)
      const cSel = document.getElementById('contractSelect');
      const pSel = document.getElementById('contractProductSelect');
      const cHas = cSel && cSel.value;
      const pHas = pSel && pSel.value;
      let composed = baseDesc;
      if (cHas) {
        const cText = cSel.options[cSel.selectedIndex].textContent;
        composed = '[Hợp đồng: ' + cText + '] ' + composed;
      }
      if (pHas) {
        const pText = pSel.options[pSel.selectedIndex].textContent;
        composed = '[Sản phẩm: ' + pText + '] ' + composed;
      }
      data.append('action', 'createSupportRequest');
      data.append('subject', subject);
      data.append('description', composed);
      data.append('category', document.getElementById('category').value || 'general');
      data.append('priority', 'medium'); // Set priority mặc định
      // backend tự xác định người dùng theo session; không gửi priority/customer/email
      fetch(ctx + '/api/support-stats', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json' },
        body: data.toString()
      }).then(r=>r.json())
        .then(j=>{
          if(j && j.success){
            // Chỉ làm sạch các trường nhập liệu, giữ nguyên Họ tên/Email
            const subjInp = document.getElementById('subject');
            const descInp = document.getElementById('description');
            const catSel = document.getElementById('category');
            const cSel2 = document.getElementById('contractSelect');
            const pSel2 = document.getElementById('contractProductSelect');
            if (subjInp) subjInp.value = '';
            if (descInp) descInp.value = '';
            if (catSel) catSel.value = 'general';
            if (cSel2) cSel2.selectedIndex = 0;
            if (pSel2) { pSel2.innerHTML = '<option value="">-- Chọn sản phẩm --</option>'; pSel2.disabled = true; }

            const modalEl = document.getElementById('supportModal');
            const modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
            modal.hide();
            load();
          } else {
            alert(j && j.message ? j.message : 'Không thể tạo yêu cầu');
          }
        })
        .catch(()=> alert('Lỗi kết nối máy chủ'));
    });

    
   
     // View detail handler
    tbody.addEventListener('click', function(e){
      const viewLink = e.target.closest('a.view-link');
      const cancelLink = e.target.closest('a.cancel-link');
      
      if(viewLink) {
        e.preventDefault();
        const id = viewLink.getAttribute('data-id');
        const it = allItems.find(function(x){ return String(x.id) === String(id); });
        if(!it) return;
      document.getElementById('v_ticket').textContent = it.ticketNumber || '';
      document.getElementById('v_status').textContent = it.status || '';
      // fill editable inputs
      var catInp = document.getElementById('v_category_inp');
      var priInp = document.getElementById('v_priority_inp');
      var subInp = document.getElementById('v_subject_inp');
      var desInp = document.getElementById('v_description_inp');
      var vContract = document.getElementById('v_contract_select');
      var vProduct = document.getElementById('v_product_select');
      if (catInp) catInp.value = (it.category||'general');
      if (priInp) priInp.value = (it.priority ? it.priority : '');
      if (subInp) subInp.value = (it.subject||'');
      if (desInp) desInp.value = (it.description||'');
      const created = formatDate(it);
      const resolved = (it.resolvedAt ? new Intl.DateTimeFormat('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' }).format(new Date(it.resolvedAt)) : '');
      document.getElementById('v_created').textContent = created;
      document.getElementById('v_resolved').textContent = resolved;
      
      // Hiển thị các trường mới
      document.getElementById('v_assigned_to').textContent = it.assignedTo || 'Chưa phân công';
      document.getElementById('v_history').textContent = it.history || 'Chưa có lịch sử';
      document.getElementById('v_resolution').value = it.resolution || '';
      // Load contracts for view (read-only)
      try {
        // reset
        if (vContract) { vContract.innerHTML = '<option value="">-- Chọn hợp đồng --</option>'; }
        if (vProduct) { vProduct.innerHTML = '<option value="">-- Chọn sản phẩm --</option>'; vProduct.disabled = true; }
        fetch(ctx + '/api/contracts', { headers: { 'Accept': 'application/json' } })
          .then(r=>r.json()).then(function(j){
            if (!j || !j.success) return;
            const list = Array.isArray(j.data)? j.data: [];
            list.forEach(function(c){
              var opt = document.createElement('option');
              opt.value = c.id;
              opt.textContent = (c.contractNumber ? (c.contractNumber + ' - ') : '') + (c.title || ('HĐ #' + c.id));
              vContract.appendChild(opt);
            });
            // Try detect from description pattern [Hợp đồng: ...] [Sản phẩm: ...]
            var desc = desInp ? desInp.value : '';
            var contractLabel = (desc.match(/\[Hợp đồng:([^\]]+)\]/) || [])[1];
            var productLabel = (desc.match(/\[Sản phẩm:([^\]]+)\]/) || [])[1];
            if (contractLabel) {
              for (var i=0;i<vContract.options.length;i++) {
                if (vContract.options[i].textContent.indexOf(contractLabel.trim()) !== -1) {
                  vContract.selectedIndex = i; break;
                }
              }
              if (vContract.value) {
                vProduct.disabled = false;
                fetch(ctx + '/api/contract-items?contractId=' + encodeURIComponent(vContract.value), { headers: { 'Accept': 'application/json' } })
                  .then(r=>r.json()).then(function(j2){
                    if (!j2 || !j2.success) return;
                    (Array.isArray(j2.data)? j2.data: []).forEach(function(item){
                      var opt = document.createElement('option');
                      opt.value = item.productId;
                      var name = item.description ? item.description : ('Sản phẩm #' + item.productId);
                      opt.textContent = name;
                      vProduct.appendChild(opt);
                    });
                    if (productLabel) {
                      for (var k=0;k<vProduct.options.length;k++) {
                        if (vProduct.options[k].textContent.indexOf(productLabel.trim()) !== -1) {
                          vProduct.selectedIndex = k; break;
                        }
                      }
                    }
                  });
              }
            }
          });
      } catch(e) {}
      const vm = bootstrap.Modal.getOrCreateInstance(document.getElementById('viewModal'));
      vm.show();
      // reset edit state
      const enable = document.getElementById('v_enable_edit');
      const saveBtn = document.getElementById('v_save_btn');
      [catInp, priInp, subInp, desInp].forEach(function(el){ if(el){ el.disabled = true; }});
      if (enable) enable.checked = false;
      if (saveBtn) saveBtn.disabled = true;
      
      // Kiểm tra trạng thái để quyết định có cho phép chỉnh sửa không
      const finalStatus = cancelledItems.has(String(id)) ? 'cancelled' : (it.status || 'pending');
      const canEdit = finalStatus === 'pending' || finalStatus === 'open';
      
      // Disable checkbox nếu không thể chỉnh sửa
      if (enable) {
        enable.disabled = !canEdit;
        if (!canEdit) {
          enable.title = 'Yêu cầu đang được thực hiện - không thể chỉnh sửa';
          enable.parentElement.style.color = '#dc3545';
          enable.parentElement.innerHTML = '<input class="form-check-input" type="checkbox" id="v_enable_edit" disabled><label class="form-check-label" for="v_enable_edit" style="color: #dc3545;">Chỉnh sửa (Yêu cầu đang được thực hiện)</label>';
        } else {
          enable.parentElement.style.color = '';
        }
      }
      
      // attach handlers
      if (enable) {
        enable.onchange = function(){
          if (!canEdit) {
            alert('Yêu cầu đang được thực hiện - không thể chỉnh sửa!');
            enable.checked = false;
            return;
          }
          var on = !!enable.checked;
          // chỉnh sửa loại yêu cầu, tiêu đề, mô tả
          [catInp, subInp, desInp].forEach(function(el){ if(el){ el.disabled = !on; }});
          if (priInp) priInp.disabled = true;
          if (saveBtn) saveBtn.disabled = !on;
          // Cho phép chọn hợp đồng/sản phẩm khi bật chỉnh sửa
          if (vContract) vContract.disabled = !on;
          if (vProduct) vProduct.disabled = !on || !vContract || !vContract.value;
          // Nạp lại danh sách sản phẩm khi đổi hợp đồng
          if (on && vContract) {
            vContract.onchange = function(){
              if (!vProduct) return;
              var id = vContract.value;
              vProduct.innerHTML = '<option value="">-- Chọn sản phẩm --</option>';
              vProduct.disabled = !id;
              if (!id) return;
              fetch(ctx + '/api/contract-items?contractId=' + encodeURIComponent(id), { headers: { 'Accept': 'application/json' } })
                .then(function(r){ return r.json(); })
                .then(function(j2){
                  if (!j2 || !j2.success) return;
                  (Array.isArray(j2.data) ? j2.data : []).forEach(function(item){
                    var opt = document.createElement('option');
                    opt.value = item.productId;
                    var name = item.description ? item.description : ('Sản phẩm #' + item.productId);
                    opt.textContent = name;
                    vProduct.appendChild(opt);
                  });
                });
            };
          }
        };
      }
      if (saveBtn) {
        saveBtn.onclick = function(){
          // Validate: require both contract and product selections when editing
          if (!vContract || !vProduct) return;
          var hasContract = vContract.value && vContract.value.trim() !== '';
          var hasProduct = vProduct.value && vProduct.value.trim() !== '';
          if (!hasContract || !hasProduct) {
            alert('Vui lòng chọn Hợp đồng và Sản phẩm trong hợp đồng trước khi lưu.');
            return;
          }
          const data = new URLSearchParams();
          // Ghép thông tin hợp đồng/sản phẩm vào mô tả giống form tạo mới
          var baseDesc = desInp.value || '';
          try {
            baseDesc = baseDesc.replace(/\[Hợp đồng:[^\]]+\]\s*/,'').replace(/\[Sản phẩm:[^\]]+\]\s*/,'').trim();
          } catch(e) {}
          var composed = baseDesc;
          if (vContract && vContract.value) {
            var cText = vContract.options[vContract.selectedIndex].textContent;
            composed = '[Hợp đồng: ' + cText + '] ' + composed;
          }
          if (vProduct && vProduct.value) {
            var pText = vProduct.options[vProduct.selectedIndex].textContent;
            composed = '[Sản phẩm: ' + pText + '] ' + composed;
          }
          data.append('action', 'createSupportRequest');
          data.append('subject', subInp.value || '');
          data.append('description', composed);
          data.append('category', catInp.value || 'general');
          data.append('priority', 'medium');
          data.append('delete_old_id', id); // thêm ID để xóa bản cũ
          fetch(ctx + '/api/support-stats', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json' },
            body: data.toString()
          }).then(r=>r.json()).then(function(j){
            if(j && j.success){
              vm.hide();
              load();
              renderPage(1);
            } else {
              alert(j && j.message ? j.message : 'Không thể cập nhật');
            }
          }).catch(function(){ alert('Lỗi kết nối máy chủ'); });
        };
      }
      }
      
      if(cancelLink) {
        e.preventDefault();
        const id = cancelLink.getAttribute('data-id');
        const it = allItems.find(function(x){ return String(x.id) === String(id); });
        if(!it) return;
        
        // Kiểm tra trạng thái trước khi hủy
        const finalStatus = cancelledItems.has(String(id)) ? 'cancelled' : (it.status || 'pending');
        if(finalStatus === 'cancelled') {
          alert('Yêu cầu này đã được hủy rồi!');
          return;
        }
        if(finalStatus !== 'pending' && finalStatus !== 'open') {
          alert('Chỉ có thể hủy yêu cầu đang chờ xử lý!');
          return;
        }
        
        if(confirm('Bạn có chắc chắn muốn hủy yêu cầu này?')) {
          // Đánh dấu item đã hủy và cập nhật hiển thị
          cancelledItems.add(String(id));
          renderPage(currentPage); // Cập nhật hiển thị ngay lập tức
          
          // Gửi request hủy yêu cầu đến server
          const data = new URLSearchParams();
          data.append('action', 'cancel');
          data.append('id', id);
          
          console.log('DEBUG: Sending cancel request with:', data.toString());
          fetch(ctx + '/api/support-stats', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json' },
            body: data.toString()
          }).then(r=>r.json())
            .then(j=>{
              if(j && j.success){
                alert('Đã hủy yêu cầu thành công!');
                load(); // Reload danh sách từ server
              } else {
                // Nếu server từ chối, revert lại trạng thái
                cancelledItems.delete(String(id));
                renderPage(currentPage);
                alert(j && j.message ? j.message : 'Không thể hủy yêu cầu');
              }
            })
            .catch(()=> {
              // Nếu có lỗi kết nối, revert lại trạng thái
              cancelledItems.delete(String(id));
              renderPage(currentPage);
              alert('Lỗi kết nối máy chủ');
            });
        }
      }
    });
  });
</script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Smooth scrolling for navigation links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Add scroll effect to navbar
        window.addEventListener('scroll', function() {
            const navbar = document.querySelector('.navbar');
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        });

        // Banner indicators functionality
        const bannerIndicators = document.querySelectorAll('.banner-indicators .indicator');
        bannerIndicators.forEach((indicator, index) => {
            indicator.addEventListener('click', function() {
                bannerIndicators.forEach(ind => ind.classList.remove('active'));
                this.classList.add('active');
            });
        });

        // Quote indicators functionality
        const quoteIndicators = document.querySelectorAll('.quote-indicators .quote-indicator');
        quoteIndicators.forEach((indicator, index) => {
            indicator.addEventListener('click', function() {
                quoteIndicators.forEach(ind => ind.classList.remove('active'));
                this.classList.add('active');
            });
        });
        

        

      

        
    
    </script>
   <div class="mt-5"></div>
    <%@ include file="footer.jsp" %>
</body>
</html>