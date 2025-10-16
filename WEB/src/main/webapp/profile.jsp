
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
      <div class="account-tab" data-tab="settings">Đổi mật khẩu</div>
    </div>
    <div class="account-content">
      <div class="tab-panel" id="tab-info">
        <div class="section-title">Thông tin cơ bản</div>
        <form id="form-profile" method="post" action="#">
          <div class="form-grid">
            <div class="field">
              <label for="lastName">Họ</label>
              <input id="lastName" type="text" />
            </div>
            <div class="field">
              <label for="firstName">Tên</label>
              <input id="firstName" type="text" />
            </div>
            <!-- Hidden combined field to keep compatibility with backend -->
            <input id="fullName" type="hidden" name="fullName" value="${sessionScope.fullName}" />

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

      

      <div class="tab-panel" id="tab-settings" style="display:none;">
        <div class="section-title">Đổi mật khẩu</div>
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
          <button class="save-btn" type="button" id="changePasswordBtn">Đổi mật khẩu</button>
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
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label" for="m_lastName">Họ</label>
              <input type="text" class="form-control" id="m_lastName" required>
            </div>
            <div class="col-md-6">
              <label class="form-label" for="m_firstName">Tên</label>
              <input type="text" class="form-control" id="m_firstName" required>
            </div>
          </div>
          <input type="hidden" id="m_fullName" />
          <div class="mb-3">
            <label for="m_email" class="form-label">Email</label>
            <input type="email" class="form-control" id="m_email" required>
          </div>
          <div class="mb-3">
            <label for="m_phone" class="form-label">Số điện thoại</label>
            <input type="text" class="form-control" id="m_phone" required>
          </div>
          <div class="mb-3">
            <label for="m_companyName" class="form-label">Công ty</label>
            <input type="text" class="form-control" id="m_companyName" required>
          </div>
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label" for="m_addrStreet">Số nhà (xã, thôn)</label>
              <input type="text" class="form-control" id="m_addrStreet" required>
            </div>
            <div class="col-md-3">
              <label class="form-label" for="m_addrDistrict">Huyện</label>
              <input type="text" class="form-control" id="m_addrDistrict" required>
            </div>
            <div class="col-md-3">
              <label class="form-label" for="m_addrCity">Thành phố</label>
              <input type="text" class="form-control" id="m_addrCity" required>
            </div>
          </div>
          <input type="hidden" id="m_address" />
          <div class="mb-3">
            <label class="form-label" for="m_username">Tên đăng nhập</label>
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
    function splitName(fullName){
      if (!fullName) return { lastName: '', firstName: '' };
      var parts = String(fullName).trim().split(/\s+/);
      if (parts.length === 1) return { lastName: '', firstName: parts[0] };
      var firstName = parts.pop();
      return { lastName: parts.join(' '), firstName: firstName };
    }

    function composeName(lastName, firstName){
      return [String(lastName||'').trim(), String(firstName||'').trim()].filter(Boolean).join(' ');
    }

    function splitAddress(address){
      if (!address) return { street:'', district:'', city:'' };
      var parts = String(address).split(',').map(function(s){ return s.trim(); }).filter(Boolean);
      return {
        street: parts[0] || '',
        district: parts[1] || '',
        city: parts[2] || ''
      };
    }

    function composeAddress(street, district, city){
      var segs = [street, district, city].map(function(s){ return String(s||'').trim(); }).filter(Boolean);
      return segs.join(', ');
    }

    function fillForm(data){
      try {
        document.getElementById('fullName').value = data.fullName || '';
        var n = splitName(data.fullName || '');
        if (document.getElementById('lastName')) document.getElementById('lastName').value = n.lastName;
        if (document.getElementById('firstName')) document.getElementById('firstName').value = n.firstName;
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
        // Prefer values already shown on the main form (which come from customer info),
        // then fall back to userData, then customerData
        var formCompany = (document.getElementById('companyName') && document.getElementById('companyName').value) || '';
        var formAddress = (document.getElementById('address') && document.getElementById('address').value) || '';
        var finalCompany = formCompany || (userData.companyName || (customerData && customerData.companyName) || '');
        var finalAddress = formAddress || (userData.address || (customerData && customerData.address) || '');
        var n = splitName(userData.fullName || '');
        document.getElementById('m_lastName').value = n.lastName;
        document.getElementById('m_firstName').value = n.firstName;
        document.getElementById('m_fullName').value = composeName(n.lastName, n.firstName);
        document.getElementById('m_email').value = userData.email || '';
        document.getElementById('m_phone').value = userData.phone || '';
        document.getElementById('m_companyName').value = finalCompany;
        var a = splitAddress(finalAddress);
        document.getElementById('m_addrStreet').value = a.street;
        document.getElementById('m_addrDistrict').value = a.district;
        document.getElementById('m_addrCity').value = a.city;
        document.getElementById('m_address').value = composeAddress(a.street, a.district, a.city);
        document.getElementById('m_username').value = userData.username || '';
        var modal = bootstrap.Modal.getOrCreateInstance(document.getElementById('updateUserModal'));
        modal.show();
      });
    }

    // Confirm update
    var confirmBtn = document.getElementById('confirmUpdateBtn');
    if (confirmBtn) {
      confirmBtn.addEventListener('click', function(){
        var fullName = composeName(
          document.getElementById('m_lastName').value.trim(),
          document.getElementById('m_firstName').value.trim()
        );
        var email = document.getElementById('m_email').value.trim();
        var phone = document.getElementById('m_phone').value.trim();
        var companyName = document.getElementById('m_companyName').value.trim();
        var address = composeAddress(
          document.getElementById('m_addrStreet').value.trim(),
          document.getElementById('m_addrDistrict').value.trim(),
          document.getElementById('m_addrCity').value.trim()
        );
        // Validate required fields to avoid clearing existing data unintentionally
        if (!fullName || !email || !phone || !companyName || !address) {
          alert('Vui lòng nhập đầy đủ Họ và tên, Email, Số điện thoại, Công ty và Địa chỉ!');
          return;
        }
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
              var nameParts = splitName(fullName);
              if (document.getElementById('lastName')) document.getElementById('lastName').value = nameParts.lastName;
              if (document.getElementById('firstName')) document.getElementById('firstName').value = nameParts.firstName;
              document.getElementById('fullName').value = fullName;
              document.getElementById('email').value = email;
              if (document.getElementById('phone')) document.getElementById('phone').value = phone;
              if (document.getElementById('companyName')) document.getElementById('companyName').value = companyName;
              var addrParts = splitAddress(address);
              if (document.getElementById('addrStreet')) document.getElementById('addrStreet').value = addrParts.street;
              if (document.getElementById('addrDistrict')) document.getElementById('addrDistrict').value = addrParts.district;
              if (document.getElementById('addrCity')) document.getElementById('addrCity').value = addrParts.city;
              if (document.getElementById('address')) document.getElementById('address').value = address;
              if (userData){ userData.fullName = fullName; userData.email = email; userData.phone = phone; }
              var m = bootstrap.Modal.getInstance(document.getElementById('updateUserModal'));
              if (m) m.hide();
              // Cập nhật tên hiển thị ở header mà không cần reload
              try {
                var headerUser = document.querySelector('.user-info');
                if (headerUser) {
                  headerUser.innerHTML = '<i class="fas fa-user"></i> ' + (fullName || (userData.username || ''));
                }
              } catch(e) {}
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

    // Change password functionality
    var changePasswordBtn = document.getElementById('changePasswordBtn');
    if (changePasswordBtn) {
      changePasswordBtn.addEventListener('click', function() {
        var currentPassword = document.getElementById('currentPassword').value.trim();
        var newPassword = document.getElementById('newPassword').value.trim();
        var confirmPassword = document.getElementById('confirmPassword').value.trim();
        
        // Validate
        if (!currentPassword || !newPassword || !confirmPassword) {
          alert('Vui lòng nhập đầy đủ thông tin!');
          return;
        }
        
        if (newPassword !== confirmPassword) {
          alert('Mật khẩu mới và xác nhận mật khẩu không khớp!');
          return;
        }
        
        if (newPassword.length < 6) {
          alert('Mật khẩu mới phải có ít nhất 6 ký tự!');
          return;
        }
        
        // Confirm action
        if (!confirm('Bạn có chắc chắn muốn đổi mật khẩu?')) {
          return;
        }
        
        // Send request
        var data = new URLSearchParams();
        data.append('currentPassword', currentPassword);
        data.append('newPassword', newPassword);
        data.append('confirmPassword', confirmPassword);
        
        fetch('<%=request.getContextPath()%>/api/changePassword', {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json' },
          body: data.toString()
        })
        .then(function(r) { return r.json(); })
        .then(function(j) {
          if (j && j.success) {
            alert('Đổi mật khẩu thành công! Vui lòng đăng nhập lại.');
            // Clear inputs
            document.getElementById('currentPassword').value = '';
            document.getElementById('newPassword').value = '';
            document.getElementById('confirmPassword').value = '';
            // Optionally redirect to login
            setTimeout(function() {
              window.location.href = '<%=request.getContextPath()%>/logout';
            }, 1500);
          } else {
            alert(j.message || 'Không thể đổi mật khẩu!');
          }
        })
        .catch(function(err) {
          alert('Lỗi kết nối máy chủ!');
          console.error(err);
        });
      });
    }
  })();
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>


