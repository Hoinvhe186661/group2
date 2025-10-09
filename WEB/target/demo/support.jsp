<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
        <div class="support-search">
            <input type="text" class="form-control" placeholder="Tìm kiếm...">
        </div>
    </div>
    <div class="table-responsive">
        <table class="table support-table align-middle">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Loại yêu cầu</th>
                    <th>Độ ưu tiên</th>
                    <th>Chi tiết vấn đề</th>
                    <th>Ngày tạo</th>
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
              <label>Tên/Code khách hàng :</label>
              <input type="text" class="form-control" id="customerId" placeholder="Nhập ID khách hàng">
            </div>
            <div class="col-6">
              <label>Email:</label>
              <input type="email" class="form-control" id="email">
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
            <label>Mức độ ưu tiên :</label>
            <select class="form-control" id="priority">
              <option value="urgent">Cao</option>
              <option value="high">Trung bình</option>
              <option value="medium" selected>Thường</option>
              <option value="low">Thấp</option>
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
          <div class="col-md-6"><label>Ưu tiên</label>
            <select id="v_priority_inp" class="form-control" disabled>
              <option value="urgent">Cao</option>
              <option value="high">Trung bình</option>
              <option value="medium">Thường</option>
              <option value="low">Thấp</option>
            </select>
          </div>
          <div class="col-12"><label>Tiêu đề</label><input id="v_subject_inp" class="form-control" disabled/></div>
          <div class="col-12"><label>Chi tiết vấn đề</label><textarea id="v_description_inp" class="form-control" rows="4" disabled></textarea></div>
          <div class="col-md-6"><label>Ngày tạo</label><div id="v_created" class="form-control-plaintext"></div></div>
          <div class="col-md-6"><label>Ngày xử lý xong</label><div id="v_resolved" class="form-control-plaintext"></div></div>
          <div class="col-12 d-flex align-items-center justify-content-between">
            <div class="form-check">
              <input class="form-check-input" type="checkbox" id="v_enable_edit">
              <label class="form-check-label" for="v_enable_edit">Cho phép chỉnh sửa (ủy quyền)</label>
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
    var today = new Date().toISOString().split('T')[0];
    var createdInput = document.getElementById('createdDate');
    var createdText = document.getElementById('createdDateText');
    if (createdInput) createdInput.value = today;
    try {
      var d = new Date();
      var dd = String(d.getDate()).padStart(2,'0');
      var mm = String(d.getMonth()+1).padStart(2,'0');
      var yyyy = d.getFullYear();
      if (createdText) createdText.textContent = dd + '/' + mm + '/' + yyyy;
    } catch(e) {}
    
    const ctx = '<%=request.getContextPath()%>';
    // Prefill and lock email from session; hint customer field
    try {
      const sessionEmail = '<%= String.valueOf(session.getAttribute("email")) %>';
      const sessionUsername = '<%= String.valueOf(session.getAttribute("username")) %>';
      const emailInp = document.getElementById('email');
      const customerInp = document.getElementById('customerId');
      if (emailInp && sessionEmail && sessionEmail !== 'null') {
        emailInp.value = sessionEmail;
        emailInp.readOnly = true;
      }
      if (customerInp && sessionUsername && sessionUsername !== 'null') {
        customerInp.placeholder = 'Nhập tên/Code đúng với tài khoản: ' + sessionUsername;
      }
    } catch (e) {}
    const tbody = document.getElementById('supportRows');
    const pagerContainer = document.querySelector('.pagination.custom-pagination');
    let allItems = [];
    let filteredItems = [];
    let currentPage = 1;
    const pageSize = 9;
    let cancelledItems = new Set(); // Lưu trữ các ID đã hủy trên frontend
    let searchTerm = ''; // Lưu từ khóa tìm kiếm
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
      if (!searchTerm.trim()) {
        filteredItems = [...allItems];
      } else {
        const term = searchTerm.toLowerCase();
        filteredItems = allItems.filter(function(item) {
          return (
            (item.subject && item.subject.toLowerCase().includes(term)) ||
            (item.description && item.description.toLowerCase().includes(term)) ||
            (item.category && item.category.toLowerCase().includes(term)) ||
            (item.priority && item.priority.toLowerCase().includes(term)) ||
            (item.ticketNumber && item.ticketNumber.toLowerCase().includes(term))
          );
        });
      }
    }
    
    function rows(items){
      tbody.innerHTML = '';
      if(!items || !items.length){
        tbody.innerHTML = '<tr><td colspan="7" class="text-center">Chưa có yêu cầu nào</td></tr>';
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
        tr.innerHTML = '<td>'+ sequenceNumber +'</td><td>'+ (it.category||'') +'</td><td>'+ (it.priority||'') +'</td><td>'+ (it.description||'') +'</td><td>'+ created +'</td><td><span class="badge ' + statusClass + '">' + status + '</span></td><td><a href="#" class="view-link me-2" data-id="'+ (it.id||'') +'">Xem</a> ' + cancelButton + '</td>';
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
    function load(){
      fetch(ctx + '/api/support-requests?action=list', {headers:{'Accept':'application/json'}})
        .then(r=>r.json()).then(j=>{ 
          allItems = Array.isArray(j.data)? j.data : []; 
          filterItems();
          renderPage(1); 
        })
        .catch(()=>{tbody.innerHTML='<tr><td colspan="7" class="text-center text-danger">Lỗi tải dữ liệu</td></tr>';});
    }
    load();

    // Thêm chức năng tìm kiếm
    const searchInput = document.querySelector('.support-search input');
    if (searchInput) {
      searchInput.addEventListener('input', function(e) {
        searchTerm = e.target.value;
        filterItems();
        renderPage(1);
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
      data.append('subject', document.getElementById('subject').value || '');
      data.append('description', document.getElementById('description').value || '');
      data.append('category', document.getElementById('category').value || 'general');
      data.append('priority', document.getElementById('priority').value || 'medium');
      data.append('customerId', document.getElementById('customerId').value || '');
      data.append('email', document.getElementById('email').value || '');
      fetch(ctx + '/api/support-requests', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json' },
        body: data.toString()
      }).then(r=>r.json())
        .then(j=>{
          if(j && j.success){
            form.reset();
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
      if (catInp) catInp.value = (it.category||'general');
      if (priInp) priInp.value = (it.priority||'medium');
      if (subInp) subInp.value = (it.subject||'');
      if (desInp) desInp.value = (it.description||'');
      const created = formatDate(it);
      const resolved = (it.resolvedAt ? new Intl.DateTimeFormat('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' }).format(new Date(it.resolvedAt)) : '');
      document.getElementById('v_created').textContent = created;
      document.getElementById('v_resolved').textContent = resolved;
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
          enable.title = 'Chỉ có thể chỉnh sửa yêu cầu đang chờ xử lý';
        }
      }
      
      // attach handlers
      if (enable) {
        enable.onchange = function(){
          if (!canEdit) {
            alert('Chỉ có thể chỉnh sửa yêu cầu đang chờ xử lý!');
            enable.checked = false;
            return;
          }
          var on = !!enable.checked;
          [catInp, priInp, subInp, desInp].forEach(function(el){ if(el){ el.disabled = !on; }});
          if (saveBtn) saveBtn.disabled = !on;
        };
      }
      if (saveBtn) {
        saveBtn.onclick = function(){
          const data = new URLSearchParams();
          data.append('subject', subInp.value || '');
          data.append('description', desInp.value || '');
          data.append('category', catInp.value || 'general');
          data.append('priority', priInp.value || 'medium');
          data.append('delete_old_id', id); // thêm ID để xóa bản cũ
          fetch(ctx + '/api/support-requests', {
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
          fetch(ctx + '/api/support-requests', {
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