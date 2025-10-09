
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
    .account-wrapper { max-width: 1100px; margin: 30px auto; }
    .account-card { background: #fff; border-radius: 8px; box-shadow: 0 4px 16px rgba(0,0,0,.06); }
    .account-tabs { border-bottom: 1px solid #eee; display: flex; gap: 8px; padding: 12px; }
    .account-tab { padding: 10px 14px; border-radius: 6px; cursor: pointer; font-weight: 600; color: #495057; }
    .account-tab.active { background: #dc3545; color: #fff; }
    .account-content { padding: 20px; }
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
    .form-grid .field { display: flex; flex-direction: column; }
    .field label { font-weight: 600; margin-bottom: 6px; }
    .field input { padding: 10px 12px; border: 1px solid #dee2e6; border-radius: 6px; }
    .section-title { font-size: 16px; font-weight: 700; margin-bottom: 16px; }
    .product-list { border: 1px solid #eee; border-radius: 6px; }
    .product-list table { width: 100%; border-collapse: collapse; }
    .product-list th, .product-list td { padding: 10px 12px; border-bottom: 1px solid #f1f1f1; text-align: left; }
    .save-btn { background: #dc3545; color: #fff; border: none; padding: 10px 16px; border-radius: 6px; font-weight: 700; }
</style>
</head>

<body>
  <%@ include file="header.jsp" %>
<div class="account-wrapper">
  <div class="account-card">
    <div class="account-tabs">
      <div class="account-tab active" data-tab="info">Thông tin người dùng</div>
      <div class="account-tab" data-tab="products">Sản phẩm sở hữu</div>
      <div class="account-tab" data-tab="settings">Cài đặt</div>
    </div>
    <div class="account-content">
      <div class="tab-panel" id="tab-info">
        <div class="section-title">Thông tin cơ bản</div>
        <form id="form-profile" method="post" action="#">
          <div class="form-grid">
            <div class="field">
              <label for="fullName">Họ và tên</label>
              <input id="fullName" type="text" name="fullName" value="${sessionScope.fullName}" />
            </div>
            <div class="field">
              <label for="address">Địa chỉ</label>
              <input id="address" type="text" name="address" value="" />
            </div>
            <div class="field">
              <label for="email">Email</label>
              <input id="email" type="email" name="email" value="${sessionScope.email}" />
            </div>
            <div class="field">
              <label for="phone">Số điện thoại</label>
              <input id="phone" type="text" name="phone" value="${sessionScope.phone}" />
            </div>
            <div class="field">
              <label for="companyName">Công ty</label>
              <input id="companyName" type="text" name="companyName" value="" />
            </div>
            
          </div>
          <div style="margin-top:16px;">
            <button class="save-btn" type="button" id="openUpdateModalBtn">Cập nhật</button>
          </div>
        </form>
      </div>

      <div class="tab-panel" id="tab-products" style="display:none;">
        <div class="section-title">Sản phẩm sở hữu</div>
        <div class="product-list">
          <table>
            <thead>
              <tr>
                <th>Mã</th>
                <th>Tên sản phẩm</th>
                <th>Ngày kích hoạt</th>
                <th>Trạng thái</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td colspan="4">Chưa có dữ liệu sản phẩm. Sẽ hiển thị sau khi kết nối cơ sở dữ liệu.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="tab-panel" id="tab-settings" style="display:none;">
        <div class="section-title">Cài đặt tài khoản</div>
        <div class="form-grid">
          <div class="field">
            <label for="currentPassword">Mật khẩu hiện tại</label>
            <input id="currentPassword" type="password" placeholder="••••••••" />
          </div>
          <div class="field">
            <label for="newPassword">Mật khẩu mới</label>
            <input id="newPassword" type="password" placeholder="Mật khẩu mới" />
          </div>
          <div class="field">
            <label for="confirmPassword">Nhập lại mật khẩu mới</label>
            <input id="confirmPassword" type="password" placeholder="Nhập lại mật khẩu mới" />
          </div>
        </div>
        <div style="margin-top:16px;">
          <button class="save-btn" type="button" onclick="alert('Chức năng đổi mật khẩu sẽ được kết nối API sau');">Đổi mật khẩu</button>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="footer.jsp"/>

<!-- Modal cập nhật thông tin -->
<div class="modal fade" id="updateUserModal" tabindex="-1" aria-labelledby="updateUserModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content" style="border-radius: 12px;">
      <div class="modal-header">
        <h5 class="modal-title" id="updateUserModalLabel">Cập nhật thông tin tài khoản</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
      </div>
      <div class="modal-body">
        <form id="updateUserForm">
          <div class="mb-3">
            <label for="m_fullName" class="form-label">Họ và tên</label>
            <input type="text" class="form-control" id="m_fullName" required>
          </div>
          <div class="mb-3">
            <label for="m_email" class="form-label">Email</label>
            <input type="email" class="form-control" id="m_email" required>
          </div>
          <div class="mb-3">
            <label for="m_phone" class="form-label">Số điện thoại</label>
            <input type="text" class="form-control" id="m_phone">
          </div>
          <div class="mb-3">
            <label for="m_companyName" class="form-label">Công ty</label>
            <input type="text" class="form-control" id="m_companyName">
          </div>
          <div class="mb-3">
            <label for="m_address" class="form-label">Địa chỉ</label>
            <input type="text" class="form-control" id="m_address">
          </div>
          <div class="mb-3">
            <label class="form-label">Tên đăng nhập</label>
            <input type="text" class="form-control" id="m_username" disabled>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
        <button type="button" class="btn btn-danger" id="confirmUpdateBtn">Xác nhận</button>
      </div>
    </div>
  </div>
 </div>

<script>
  (function(){
    var tabs = document.querySelectorAll('.account-tab');
    var panels = {
      info: document.getElementById('tab-info'),
      products: document.getElementById('tab-products'),
      settings: document.getElementById('tab-settings')
    };
    function activate(name){
      tabs.forEach(function(t){ t.classList.toggle('active', t.getAttribute('data-tab')===name); });
      Object.keys(panels).forEach(function(k){ panels[k].style.display = (k===name)?'block':'none'; });
    }
    tabs.forEach(function(t){ t.addEventListener('click', function(){ activate(t.getAttribute('data-tab')); }); });

    // Load current user info from API
    var sessionUserId = '<%= String.valueOf(session.getAttribute("userId")) %>';
    var userData = null;
    var customerData = null;
    function fillForm(data){
      try {
        document.getElementById('fullName').value = data.fullName || '';
        document.getElementById('email').value = data.email || '';
        if (document.getElementById('phone')) document.getElementById('phone').value = data.phone || '';
        if (document.getElementById('companyName')) document.getElementById('companyName').value = (data.companyName || '');
        if (document.getElementById('address')) document.getElementById('address').value = (data.address || '');
      } catch(e) {}
    }
    if (sessionUserId && sessionUserId !== 'null') {
      fetch('<%=request.getContextPath()%>/api/users?action=get&id=' + encodeURIComponent(sessionUserId), {headers:{'Accept':'application/json'}})
        .then(function(r){return r.json();})
        .then(function(j){ if (j && j.success && j.data){ userData = j.data; fillForm(userData); } })
        .catch(function(){});
    }

    // Try load customer info by email to fill company/address
    var sessionEmail = '<%= String.valueOf(session.getAttribute("email")) %>';
    if (sessionEmail && sessionEmail !== 'null') {
      fetch('<%=request.getContextPath()%>/api/customers?action=search&search=' + encodeURIComponent(sessionEmail), {headers:{'Accept':'application/json'}})
        .then(function(r){return r.json();})
        .then(function(j){
          if (j && j.success && Array.isArray(j.data) && j.data.length) {
            // pick the first matching customer
            customerData = j.data[0];
            if (document.getElementById('companyName')) document.getElementById('companyName').value = customerData.companyName || '';
            if (document.getElementById('address')) document.getElementById('address').value = customerData.address || '';
          }
        })
        .catch(function(){});
    }

    // Open modal and prefill
    var openBtn = document.getElementById('openUpdateModalBtn');
    if (openBtn) {
      openBtn.addEventListener('click', function(){
        if (!userData) {
          userData = {
            id: sessionUserId,
            username: '<%= String.valueOf(session.getAttribute("username")) %>',
            email: document.getElementById('email').value,
            fullName: document.getElementById('fullName').value,
            phone: document.getElementById('phone').value,
            companyName: document.getElementById('companyName') ? document.getElementById('companyName').value : '',
            address: document.getElementById('address') ? document.getElementById('address').value : '',
            role: '<%= String.valueOf(session.getAttribute("userRole")) %>'
          };
        }
        document.getElementById('m_fullName').value = userData.fullName || '';
        document.getElementById('m_email').value = userData.email || '';
        document.getElementById('m_phone').value = userData.phone || '';
        document.getElementById('m_companyName').value = userData.companyName || '';
        document.getElementById('m_address').value = userData.address || '';
        document.getElementById('m_username').value = userData.username || '';
        var modal = bootstrap.Modal.getOrCreateInstance(document.getElementById('updateUserModal'));
        modal.show();
      });
    }

    // Confirm update
    var confirmBtn = document.getElementById('confirmUpdateBtn');
    if (confirmBtn) {
      confirmBtn.addEventListener('click', function(){
        var fullName = document.getElementById('m_fullName').value.trim();
        var email = document.getElementById('m_email').value.trim();
        var phone = document.getElementById('m_phone').value.trim();
        var companyName = document.getElementById('m_companyName').value.trim();
        var address = document.getElementById('m_address').value.trim();
        if (!userData) return;
        var data = new URLSearchParams();
        data.append('id', userData.id);
        data.append('username', userData.username || '');
        data.append('email', email);
        data.append('fullName', fullName);
        data.append('phone', phone);
        data.append('companyName', companyName);
        data.append('address', address);
        data.append('role', userData.role || 'customer');
        if (userData.permissions != null) data.append('permissions', String(userData.permissions));
        if (typeof userData.isActive !== 'undefined') data.append('isActive', String(!!userData.isActive));
        fetch('<%=request.getContextPath()%>/api/users?action=update', {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json' },
          body: data.toString()
        }).then(function(r){ return r.json(); })
          .then(function(j){
            if (j && j.success){
              // update UI
              document.getElementById('fullName').value = fullName;
              document.getElementById('email').value = email;
              if (document.getElementById('phone')) document.getElementById('phone').value = phone;
              if (document.getElementById('companyName')) document.getElementById('companyName').value = companyName;
              if (document.getElementById('address')) document.getElementById('address').value = address;
              if (userData){ userData.fullName = fullName; userData.email = email; userData.phone = phone; }
              var m = bootstrap.Modal.getInstance(document.getElementById('updateUserModal'));
              if (m) m.hide();
              // Additionally update customer info if we have it
              if (customerData && customerData.id) {
                var cdata = new URLSearchParams();
                cdata.append('id', customerData.id);
                cdata.append('customerCode', customerData.customerCode || '');
                cdata.append('companyName', companyName || customerData.companyName || '');
                cdata.append('userContract', customerData.contactPerson || (fullName || ''));
                cdata.append('customerEmail', email || customerData.email || '');
                cdata.append('customerPhone', phone || customerData.phone || '');
                cdata.append('customerAddress', address || customerData.address || '');
                cdata.append('taxCode', customerData.taxCode || '');
                cdata.append('customerType', customerData.customerType || 'individual');
                fetch('<%=request.getContextPath()%>/api/customers?action=update', {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json' },
                  body: cdata.toString()
                }).then(function(rr){ return rr.json(); }).then(function(){
                  alert('Cập nhật thành công');
                }).catch(function(){ alert('Cập nhật tài khoản thành công, nhưng cập nhật khách hàng thất bại'); });
              } else {
                alert('Cập nhật thành công');
              }
            } else {
              alert((j && j.message) ? j.message : 'Không thể cập nhật');
            }
          })
          .catch(function(){ alert('Lỗi kết nối máy chủ'); });
      });
    }
  })();
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>


