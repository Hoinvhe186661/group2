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
        
        /* Success notification modal - Compact alert style */
        .success-modal .modal-dialog {
            max-width: 320px;
            width: 90%;
            margin: 2% auto;
        }
        
        .success-modal .modal-content {
            border: 1px solid #ccc;
            border-radius: 6px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
            background: white;
        }
        
        .success-modal .modal-header {
            background: #f8f9fa;
            border-bottom: 1px solid #dee2e6;
            border-radius: 6px 6px 0 0;
            padding: 0.5rem 0.75rem;
            font-size: 0.85rem;
            font-weight: 500;
        }
        
        .success-modal .modal-body {
            padding: 0.75rem;
            text-align: left;
            font-size: 0.85rem;
            line-height: 1.3;
        }
        
        .success-modal .modal-footer {
            border-top: 1px solid #dee2e6;
            padding: 0.4rem 0.75rem;
            justify-content: flex-end;
            gap: 0.4rem;
        }
        
        .success-btn {
            background: #007bff;
            border: 1px solid #007bff;
            color: white;
            padding: 0.3rem 0.6rem;
            border-radius: 3px;
            font-size: 0.8rem;
            font-weight: 400;
            cursor: pointer;
            transition: background-color 0.15s ease-in-out;
        }
        
        .success-btn:hover {
            background: #0056b3;
            border-color: #0056b3;
        }
        
        .success-btn:focus {
            outline: none;
            box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
        }
        
        /* Cancel button style */
        .cancel-btn {
            background: #6c757d;
            border: 1px solid #6c757d;
            color: white;
            padding: 0.3rem 0.6rem;
            border-radius: 3px;
            font-size: 0.8rem;
            font-weight: 400;
            cursor: pointer;
            transition: background-color 0.15s ease-in-out;
        }
        
        .cancel-btn:hover {
            background: #545b62;
            border-color: #545b62;
        }
        
        .cancel-btn:focus {
            outline: none;
            box-shadow: 0 0 0 0.2rem rgba(108, 117, 125, 0.25);
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
              <option value="urgent">Khẩn cấp</option>
              <option value="high">Cao</option>
              <option value="medium">Trung bình</option>
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

<!-- Modal Feedback (riêng biệt) -->
<div class="modal fade" id="feedbackModal" tabindex="-1" aria-labelledby="feedbackModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content" style="border-radius:20px;">
      <div class="modal-header">
        <h5 class="modal-title" id="feedbackModalLabel">
          <i class="fas fa-star"></i> Đánh giá dịch vụ
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
      </div>
      <div class="modal-body">
        <div id="feedbackModalContent">
          <div class="mb-3">
            <label><strong>Ticket:</strong> <span id="feedbackTicketNumber"></span></label>
          </div>
          <div id="feedbackDisplayInModal" style="display: none;">
            <div class="alert alert-info">
              <strong>Đánh giá của bạn:</strong>
              <div id="feedbackRatingDisplayModal" style="font-size: 20px; color: #ffc107; margin: 10px 0;"></div>
              <div id="feedbackCommentDisplayModal" style="margin-top: 10px;"></div>
              <div id="feedbackImageDisplayModal" style="margin-top: 10px;"></div>
              <div style="margin-top: 10px; font-size: 12px; color: #666;">
                <small>Ngày đánh giá: <span id="feedbackDateDisplayModal"></span></small>
              </div>
              <button type="button" class="btn btn-sm btn-secondary mt-2" id="editFeedbackBtnModal" onclick="showFeedbackFormInModal()">Chỉnh sửa đánh giá</button>
            </div>
          </div>
          <div id="feedbackFormInModal" style="display: none;">
            <div class="mb-3">
              <label>Mức độ hài lòng (1-5 sao):</label>
              <div class="rating-input-modal" style="font-size: 30px; cursor: pointer; user-select: none;">
                <span class="star-modal" data-rating="1">☆</span>
                <span class="star-modal" data-rating="2">☆</span>
                <span class="star-modal" data-rating="3">☆</span>
                <span class="star-modal" data-rating="4">☆</span>
                <span class="star-modal" data-rating="5">☆</span>
              </div>
              <input type="hidden" id="feedbackRatingModal" value="0">
              <div id="ratingTextModal" style="margin-top: 5px; color: #666; font-size: 14px;"></div>
            </div>
            <div class="mb-3">
              <label>Nhận xét của bạn:</label>
              <textarea id="feedbackCommentModal" class="form-control" rows="3" placeholder="Chia sẻ cảm nhận của bạn về dịch vụ hỗ trợ..."></textarea>
            </div>
            <div class="mb-3">
              <label>Ảnh minh chứng (tùy chọn, tối đa 10MB):</label>
              <input type="file" id="feedbackImageModal" class="form-control" accept="image/jpeg,image/jpg,image/png,image/gif,image/webp" onchange="previewImageModal(this)">
              <small class="text-muted">Chỉ chấp nhận file ảnh: JPG, PNG, GIF, WEBP (tối đa 10MB)</small>
              <div id="imagePreviewModal" style="margin-top: 10px; display: none;">
                <img id="previewImgModal" src="" alt="Preview" style="max-width: 300px; max-height: 300px; border-radius: 5px; border: 1px solid #ddd;">
                <button type="button" class="btn btn-sm btn-danger mt-2" onclick="removeImageModal()">Xóa ảnh</button>
              </div>
              <div id="imageSizeErrorModal" class="text-danger" style="display: none; margin-top: 5px;"></div>
            </div>
            <div class="d-flex gap-2">
              <button type="button" class="btn btn-primary" id="submitFeedbackBtnModal" onclick="submitFeedbackFromModal()">Gửi đánh giá</button>
              <button type="button" class="btn btn-secondary" id="cancelFeedbackBtnModal" onclick="hideFeedbackFormInModal()" style="display: none;">Hủy</button>
            </div>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
      </div>
    </div>
  </div>
</div>

<!-- Modal thông báo thành công - Simple alert style -->
<div class="modal fade success-modal" id="successModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="successTitle">Thông báo</h5>
      </div>
      <div class="modal-body">
        <div id="successMessage">Thao tác đã được thực hiện thành công.</div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn success-btn" data-bs-dismiss="modal">OK</button>
      </div>
    </div>
  </div>
</div>

<!-- Modal xác nhận hủy yêu cầu -->
<div class="modal fade success-modal" id="confirmModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Xác nhận</h5>
      </div>
      <div class="modal-body">
        <div id="confirmMessage">Bạn có chắc chắn muốn hủy yêu cầu này?</div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn cancel-btn" data-bs-dismiss="modal">Hủy</button>
        <button type="button" class="btn success-btn" id="confirmCancelBtn">OK</button>
      </div>
    </div>
  </div>
</div>

<script>
  // Context path - global scope để các hàm có thể truy cập
  var ctx = '<%=request.getContextPath()%>';
  
  // ========== Feedback Modal Functions (Global scope) ==========
  
  // Open feedback modal
  function openFeedbackModal(ticketId, ticketNumber) {
    document.getElementById('feedbackTicketNumber').textContent = ticketNumber || '#' + ticketId;
    document.getElementById('feedbackModal').setAttribute('data-current-ticket-id', ticketId);
    
    // Load existing feedback
    loadFeedbackForModal(ticketId);
    
    // Show modal
    const feedbackModal = bootstrap.Modal.getOrCreateInstance(document.getElementById('feedbackModal'));
    feedbackModal.show();
  }
  
  // Load feedback for modal
  function loadFeedbackForModal(ticketId) {
    fetch(ctx + '/api/feedback?action=getByTicketId&ticketId=' + encodeURIComponent(ticketId), {
      headers: { 'Accept': 'application/json' }
    })
    .then(r => r.json())
    .then(j => {
      if (j && j.success) {
        if (j.data) {
          // Có feedback - hiển thị
          displayFeedbackInModal(j.data);
        } else {
          // Chưa có feedback - hiển thị form
          showFeedbackFormInModal();
        }
      } else {
        // Lỗi hoặc chưa có feedback - hiển thị form
        showFeedbackFormInModal();
      }
    })
    .catch(error => {
      console.error('Error loading feedback:', error);
      showFeedbackFormInModal();
    });
  }
  
  // Display existing feedback in modal
  function displayFeedbackInModal(feedback) {
    document.getElementById('feedbackDisplayInModal').style.display = 'block';
    document.getElementById('feedbackFormInModal').style.display = 'none';
    
    // Hiển thị rating
    var ratingDisplay = document.getElementById('feedbackRatingDisplayModal');
    if (ratingDisplay) {
      ratingDisplay.textContent = feedback.ratingStars || '';
      ratingDisplay.title = feedback.ratingDisplay || '';
    }
    
    // Hiển thị comment
    var commentDisplay = document.getElementById('feedbackCommentDisplayModal');
    if (commentDisplay) {
      commentDisplay.textContent = feedback.comment || '(Không có nhận xét)';
    }
    
    // Hiển thị ảnh
    var imageDisplay = document.getElementById('feedbackImageDisplayModal');
    if (imageDisplay) {
      if (feedback.imagePath) {
        imageDisplay.innerHTML = '<img src="' + ctx + '/' + feedback.imagePath + '" alt="Feedback image" style="max-width: 300px; max-height: 300px; border-radius: 5px; border: 1px solid #ddd; margin-top: 10px;">';
      } else {
        imageDisplay.innerHTML = '';
      }
    }
    
    // Hiển thị ngày
    var dateDisplay = document.getElementById('feedbackDateDisplayModal');
    if (dateDisplay && feedback.createdAt) {
      var date = new Date(feedback.createdAt);
      dateDisplay.textContent = date.toLocaleDateString('vi-VN') + ' ' + date.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
    }
    
    // Lưu feedback ID để có thể cập nhật
    document.getElementById('feedbackFormInModal').setAttribute('data-feedback-id', feedback.id || '');
  }
  
  // Show feedback form in modal
  function showFeedbackFormInModal() {
    document.getElementById('feedbackDisplayInModal').style.display = 'none';
    document.getElementById('feedbackFormInModal').style.display = 'block';
    document.getElementById('cancelFeedbackBtnModal').style.display = 'none';
    
    // Reset form
    document.getElementById('feedbackRatingModal').value = '0';
    document.getElementById('feedbackCommentModal').value = '';
    document.getElementById('feedbackImageModal').value = '';
    document.getElementById('imagePreviewModal').style.display = 'none';
    document.getElementById('imageSizeErrorModal').style.display = 'none';
    updateRatingDisplayModal(0);
    
    // Initialize rating stars for modal
    initRatingStarsModal();
  }
  
  // Preview image
  function previewImageModal(input) {
    var errorDiv = document.getElementById('imageSizeErrorModal');
    var previewDiv = document.getElementById('imagePreviewModal');
    var previewImg = document.getElementById('previewImgModal');
    
    if (input.files && input.files[0]) {
      var file = input.files[0];
      
      // Validate file size (10MB)
      if (file.size > 10 * 1024 * 1024) {
        errorDiv.textContent = 'Kích thước ảnh quá lớn. Tối đa 10MB.';
        errorDiv.style.display = 'block';
        input.value = '';
        previewDiv.style.display = 'none';
        return;
      }
      
      // Validate file type
      var validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
      if (!validTypes.includes(file.type)) {
        errorDiv.textContent = 'Định dạng ảnh không hợp lệ. Chỉ chấp nhận JPG, PNG, GIF, WEBP.';
        errorDiv.style.display = 'block';
        input.value = '';
        previewDiv.style.display = 'none';
        return;
      }
      
      errorDiv.style.display = 'none';
      
      var reader = new FileReader();
      reader.onload = function(e) {
        previewImg.src = e.target.result;
        previewDiv.style.display = 'block';
      };
      reader.readAsDataURL(file);
    } else {
      previewDiv.style.display = 'none';
      errorDiv.style.display = 'none';
    }
  }
  
  // Remove image
  function removeImageModal() {
    document.getElementById('feedbackImageModal').value = '';
    document.getElementById('imagePreviewModal').style.display = 'none';
    document.getElementById('imageSizeErrorModal').style.display = 'none';
  }
  
  // Hide feedback form in modal
  function hideFeedbackFormInModal() {
    var ticketId = document.getElementById('feedbackModal').getAttribute('data-current-ticket-id');
    if (ticketId) {
      loadFeedbackForModal(ticketId);
    }
  }
  
  // Initialize rating stars for modal
  function initRatingStarsModal() {
    var stars = document.querySelectorAll('.rating-input-modal .star-modal');
    stars.forEach(function(star) {
      star.addEventListener('click', function() {
        var rating = parseInt(this.getAttribute('data-rating'));
        setRatingModal(rating);
      });
      star.addEventListener('mouseenter', function() {
        var rating = parseInt(this.getAttribute('data-rating'));
        highlightStarsModal(rating);
      });
    });
    
    var ratingInput = document.querySelector('.rating-input-modal');
    if (ratingInput) {
      ratingInput.addEventListener('mouseleave', function() {
        var currentRating = parseInt(document.getElementById('feedbackRatingModal').value) || 0;
        highlightStarsModal(currentRating);
      });
    }
  }
  
  // Set rating in modal
  function setRatingModal(rating) {
    document.getElementById('feedbackRatingModal').value = rating;
    updateRatingDisplayModal(rating);
  }
  
  // Highlight stars in modal
  function highlightStarsModal(rating) {
    var stars = document.querySelectorAll('.rating-input-modal .star-modal');
    stars.forEach(function(star) {
      var starRating = parseInt(star.getAttribute('data-rating'));
      if (starRating <= rating) {
        star.textContent = '★';
        star.style.color = '#ffc107';
      } else {
        star.textContent = '☆';
        star.style.color = '#ccc';
      }
    });
  }
  
  // Update rating display text in modal
  function updateRatingDisplayModal(rating) {
    var ratingText = document.getElementById('ratingTextModal');
    if (!ratingText) return;
    
    var textMap = {
      0: 'Vui lòng chọn đánh giá',
      1: 'Rất không hài lòng',
      2: 'Không hài lòng',
      3: 'Bình thường',
      4: 'Hài lòng',
      5: 'Rất hài lòng'
    };
    
    ratingText.textContent = textMap[rating] || '';
    highlightStarsModal(rating);
  }
  
  // Submit feedback from modal
  function submitFeedbackFromModal() {
    console.log('submitFeedbackFromModal called');
    var ticketId = document.getElementById('feedbackModal').getAttribute('data-current-ticket-id');
    if (!ticketId) {
      alert('Không tìm thấy ticket ID');
      console.error('Ticket ID not found');
      return;
    }
    
    var rating = parseInt(document.getElementById('feedbackRatingModal').value);
    if (rating < 1 || rating > 5) {
      alert('Vui lòng chọn đánh giá từ 1 đến 5 sao');
      console.error('Invalid rating:', rating);
      return;
    }
    
    var comment = document.getElementById('feedbackCommentModal').value || '';
    var feedbackId = document.getElementById('feedbackFormInModal').getAttribute('data-feedback-id');
    var imageInput = document.getElementById('feedbackImageModal');
    var hasImage = imageInput && imageInput.files && imageInput.files[0];
    
    var submitBtn = document.getElementById('submitFeedbackBtnModal');
    if (!submitBtn) {
      alert('Không tìm thấy nút submit');
      console.error('Submit button not found');
      return;
    }
    
    submitBtn.disabled = true;
    submitBtn.textContent = 'Đang gửi...';
    
    // Nếu có ảnh, sử dụng FormData (multipart)
    if (hasImage) {
      console.log('Submitting with image');
      var formData = new FormData();
      formData.append('action', feedbackId ? 'update' : 'create');
      if (feedbackId) {
        formData.append('feedbackId', feedbackId);
      } else {
        formData.append('ticketId', ticketId);
      }
      formData.append('rating', rating);
      formData.append('comment', comment);
      formData.append('image', imageInput.files[0]);
      
      console.log('Sending request to:', ctx + '/api/feedback');
      
      fetch(ctx + '/api/feedback', {
        method: 'POST',
        body: formData
      })
      .then(r => {
        console.log('Response status:', r.status);
        if (!r.ok) {
          throw new Error('HTTP ' + r.status);
        }
        return r.text().then(text => {
          console.log('Raw response text:', text);
          try {
            return JSON.parse(text);
          } catch (e) {
            console.error('JSON parse error:', e);
            throw new Error('Invalid JSON response: ' + text.substring(0, 100));
          }
        });
      })
      .then(j => {
        console.log('Parsed response:', j);
        submitBtn.disabled = false;
        submitBtn.textContent = 'Gửi đánh giá';
        
        if (j && j.success) {
          alert('✓ ' + (j.message || 'Cảm ơn bạn đã gửi feedback!'));
          // Redirect to feedback management page
          setTimeout(function() {
            window.location.href = ctx + '/feedback_management.jsp';
          }, 500);
        } else {
          alert('✗ ' + (j && j.message ? j.message : 'Lỗi khi gửi feedback'));
        }
      })
      .catch(error => {
        submitBtn.disabled = false;
        submitBtn.textContent = 'Gửi đánh giá';
        console.error('Error submitting feedback:', error);
        alert('✗ Lỗi kết nối: ' + error.message);
      });
    } else {
      // Không có ảnh, sử dụng URLSearchParams
      console.log('Submitting without image');
      var formData = new URLSearchParams();
      formData.append('action', feedbackId ? 'update' : 'create');
      if (feedbackId) {
        formData.append('feedbackId', feedbackId);
      } else {
        formData.append('ticketId', ticketId);
      }
      formData.append('rating', rating);
      formData.append('comment', comment);
      
      console.log('Form data:', formData.toString());
      console.log('Sending request to:', ctx + '/api/feedback');
      
      fetch(ctx + '/api/feedback', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json'
        },
        body: formData.toString()
      })
      .then(r => {
        console.log('Response status:', r.status);
        if (!r.ok) {
          throw new Error('HTTP ' + r.status);
        }
        return r.text().then(text => {
          console.log('Raw response text:', text);
          try {
            return JSON.parse(text);
          } catch (e) {
            console.error('JSON parse error:', e);
            throw new Error('Invalid JSON response: ' + text.substring(0, 100));
          }
        });
      })
      .then(j => {
        console.log('Parsed response:', j);
        submitBtn.disabled = false;
        submitBtn.textContent = 'Gửi đánh giá';
        
        if (j && j.success) {
          alert('✓ ' + (j.message || 'Cảm ơn bạn đã gửi feedback!'));
          // Redirect to feedback management page
          setTimeout(function() {
            window.location.href = ctx + '/feedback_management.jsp';
          }, 500);
        } else {
          alert('✗ ' + (j && j.message ? j.message : 'Lỗi khi gửi feedback'));
        }
      })
      .catch(error => {
        submitBtn.disabled = false;
        submitBtn.textContent = 'Gửi đánh giá';
        console.error('Error submitting feedback:', error);
        alert('✗ Lỗi kết nối: ' + error.message);
      });
    }
  }
  
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
    
    // Hàm hiển thị thông báo thành công - Simple alert style
    function showSuccessModal(title, message) {
      const successModal = document.getElementById('successModal');
      const successTitle = document.getElementById('successTitle');
      const successMessage = document.getElementById('successMessage');
      
      if (successTitle) successTitle.textContent = title || 'Thông báo';
      if (successMessage) successMessage.textContent = message;
      
      const modal = bootstrap.Modal.getOrCreateInstance(successModal);
      modal.show();
    }
    
    // Hàm hiển thị modal xác nhận hủy yêu cầu
    function showConfirmModal(message, onConfirm) {
      const confirmModal = document.getElementById('confirmModal');
      const confirmMessage = document.getElementById('confirmMessage');
      const confirmBtn = document.getElementById('confirmCancelBtn');
      
      if (confirmMessage) confirmMessage.textContent = message;
      
      // Xóa event listener cũ nếu có
      const newConfirmBtn = confirmBtn.cloneNode(true);
      confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);
      
      // Thêm event listener mới
      newConfirmBtn.addEventListener('click', function() {
        const modal = bootstrap.Modal.getInstance(confirmModal);
        modal.hide();
        if (onConfirm) onConfirm();
      });
      
      const modal = bootstrap.Modal.getOrCreateInstance(confirmModal);
      modal.show();
    }
    
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
    let allItems = []; // Cache để xử lý cancel ở frontend
    let currentPage = 1;
    const pageSize = 9;
    let totalRecords = 0;
    let totalPages = 1;
    let cancelledItems = new Set(); // Lưu trữ các ID đã hủy trên frontend
    let searchTerm = ''; // Lưu từ khóa tìm kiếm
    let filterStatus = ''; // Lọc theo trạng thái
    let filterCategory = ''; // Lọc theo loại yêu cầu
    let sortField = ''; // Field để sắp xếp
    let sortDirection = 'desc'; // 'asc' hoặc 'desc'
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
    
    // Hàm filterItems đã được chuyển sang backend, không cần nữa
    
    function rows(items){
      console.log('rows() called with', items ? items.length : 0, 'items');
      if (!tbody) {
        console.error('tbody element not found!');
        return;
      }
      tbody.innerHTML = '';
      if(!items || !items.length){
        tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted"><i class="fas fa-info-circle"></i> Bạn chưa có yêu cầu hỗ trợ nào. <a href="#" data-bs-toggle="modal" data-bs-target="#supportModal" class="text-primary">Tạo yêu cầu mới</a></td></tr>';
        return;
      }
      items.forEach(function(it, idx){
        const created = formatDate(it);
        // Ưu tiên trạng thái đã hủy trên frontend
        const finalStatus = cancelledItems.has(String(it.id)) ? 'cancelled' : (it.status || 'pending');
        const status = getStatusText(finalStatus);
        const statusClass = getStatusClass(finalStatus);
        const tr = document.createElement('tr');
        // Hiển thị nút hủy cho pending, open, cancelled, closed
        const canCancel = finalStatus === 'pending' || finalStatus === 'open' || finalStatus === 'cancelled' || finalStatus === 'closed';
        const cancelButton = canCancel ? '<a href="#" class="cancel-link text-danger" data-id="'+ (it.id||'') +'">Hủy</a>' : '';
        // Hiển thị nút feedback cho resolved hoặc closed
        const canFeedback = finalStatus === 'resolved' || finalStatus === 'closed';
        const feedbackButton = canFeedback ? '<a href="#" class="feedback-link text-success ms-2" data-id="'+ (it.id||'') +'" data-ticket-number="'+ (it.ticketNumber||'') +'" title="Đánh giá dịch vụ"><i class="fas fa-star"></i> Feedback</a>' : '';
        // Tính số thứ tự theo trang hiện tại
        const sequenceNumber = (currentPage - 1) * pageSize + idx + 1;
        var displaySubject = (it.subject||'');
        tr.innerHTML = '<td>'+ sequenceNumber +'</td><td>'+ (it.category||'') +'</td><td>'+ displaySubject +'</td><td>'+ created +'</td><td><span class="badge ' + statusClass + '">' + status + '</span></td><td><a href="#" class="view-link me-2" data-id="'+ (it.id||'') +'">Xem</a> ' + cancelButton + feedbackButton + '</td>';
        tbody.appendChild(tr);
      });
      console.log('rows() completed, added', items.length, 'rows to tbody');
    }

    function renderPagination(){
      if(!pagerContainer) {
        console.warn('pagerContainer not found!');
        return;
      }
      console.log('renderPagination() - currentPage:', currentPage, 'totalPages:', totalPages);
      let html = '';
      html += '<li class="page-item'+(currentPage===1?' disabled':'')+'"><a class="page-link" href="#" data-page="prev">Trước</a></li>';
      // show only current page number
      html += '<li class="page-item active"><a class="page-link" href="#" data-page="'+currentPage+'">'+currentPage+'</a></li>';
      html += '<li class="page-item'+(currentPage>=totalPages?' disabled':'')+'"><a class="page-link" href="#" data-page="next">Tiếp</a></li>';
      pagerContainer.innerHTML = html;
      console.log('Pagination HTML:', html);
    }

    function renderPage(page){
      // Validate page
      console.log('renderPage called with:', page, 'currentPage:', currentPage, 'totalPages:', totalPages);
      if(page === 'prev') page = Math.max(1, currentPage - 1);
      if(page === 'next') page = Math.min(totalPages, currentPage + 1);
      page = Math.min(Math.max(1, parseInt(page||1,10)), totalPages);
      console.log('Setting currentPage to:', page);
      currentPage = page;
      // Load data từ backend với page mới
      load();
    }
    function load(){
      console.log('Loading support requests...');
      console.log('Current filters - searchTerm:', searchTerm, 'filterStatus:', filterStatus, 'filterCategory:', filterCategory);
      console.log('Pagination - currentPage:', currentPage, 'pageSize:', pageSize, 'sortField:', sortField, 'sortDirection:', sortDirection);
      
      // Xây dựng URL với các tham số - sử dụng endpoint mới với logic backend
      let url = ctx + '/api/support-customer?action=list&page=' + currentPage + '&pageSize=' + pageSize;
      if (searchTerm) url += '&search=' + encodeURIComponent(searchTerm);
      if (filterStatus) url += '&filterStatus=' + encodeURIComponent(filterStatus);
      if (filterCategory) url += '&filterCategory=' + encodeURIComponent(filterCategory);
      if (sortField) url += '&sortField=' + encodeURIComponent(sortField);
      if (sortDirection) url += '&sortDirection=' + encodeURIComponent(sortDirection);
      
      console.log('Request URL:', url);
      
      fetch(url, {headers:{'Accept':'application/json'}})
        .then(r => {
          console.log('Load response status:', r.status);
          if (!r.ok) {
            throw new Error('HTTP ' + r.status);
          }
          return r.json();
        })
        .then(j => { 
          console.log('Load response data (full):', JSON.stringify(j, null, 2));
          console.log('Response details - totalRecords:', j.totalRecords, 'totalPages:', j.totalPages, 'currentPage:', j.currentPage, 'pageSize:', j.pageSize);
          console.log('Response has data?', Array.isArray(j.data), 'data length:', j.data ? j.data.length : 0);
          if (j && j.success) {
            allItems = Array.isArray(j.data)? j.data : [];
            
            // Lấy thông tin phân trang từ response
            if (j.totalRecords !== undefined && j.totalRecords !== null) {
              totalRecords = parseInt(j.totalRecords);
            }
            if (j.totalPages !== undefined && j.totalPages !== null) {
              totalPages = Math.max(1, parseInt(j.totalPages));
            } else if (totalRecords > 0) {
              // Tính toán nếu backend không trả về
              totalPages = Math.max(1, Math.ceil(totalRecords / pageSize));
            }
            if (j.currentPage !== undefined && j.currentPage !== null) {
              currentPage = Math.max(1, parseInt(j.currentPage));
            }
            
            console.log('Updating UI - allItems:', allItems.length, 'totalRecords:', totalRecords, 'totalPages:', totalPages, 'currentPage:', currentPage);
            
            // Đảm bảo render cả table và pagination
            if (tbody) {
              rows(allItems);
            } else {
              console.error('tbody is null!');
            }
            renderPagination();
          } else {
            console.error('Load server error:', j);
            if (tbody) {
              tbody.innerHTML='<tr><td colspan="6" class="text-center text-danger"><i class="fas fa-exclamation-triangle"></i> ' + (j && j.message ? j.message : 'Lỗi tải dữ liệu') + '</td></tr>';
            }
          }
        })
        .catch(error => {
          console.error('Load request failed:', error);
          tbody.innerHTML='<tr><td colspan="6" class="text-center text-danger"><i class="fas fa-exclamation-triangle"></i> Lỗi kết nối máy chủ: ' + error.message + '</td></tr>';
        });
    }
    load();

    // Thêm event listener cho sắp xếp
    document.querySelector('th:nth-child(1)').addEventListener('click', function(e) {
      e.preventDefault();
      console.log('Sort by ID clicked, current sortField:', sortField, 'sortDirection:', sortDirection);
      if (sortField === 'id') {
        sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
      } else {
        sortField = 'id';
        sortDirection = 'asc';
      }
      const arrowEl = document.getElementById('sortIdArrow');
      if (arrowEl) arrowEl.textContent = sortDirection === 'asc' ? ' ↑' : ' ↓';
      currentPage = 1; // Reset về trang đầu khi sắp xếp
      console.log('Loading with sortField:', sortField, 'sortDirection:', sortDirection);
      load();
    });
    
    document.querySelector('th:nth-child(4)').addEventListener('click', function(e) {
      e.preventDefault();
      console.log('Sort by Date clicked, current sortField:', sortField, 'sortDirection:', sortDirection);
      if (sortField === 'date' || sortField === 'created_at') {
        sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
      } else {
        sortField = 'date';
        sortDirection = 'desc';
      }
      const arrowEl = document.getElementById('sortDateArrow');
      if (arrowEl) arrowEl.textContent = sortDirection === 'asc' ? ' ↑' : ' ↓';
      currentPage = 1; // Reset về trang đầu khi sắp xếp
      console.log('Loading with sortField:', sortField, 'sortDirection:', sortDirection);
      load();
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
      currentPage = 1; // Reset về trang đầu khi lọc
      console.log('Applying filters - searchTerm:', searchTerm, 'filterStatus:', filterStatus, 'filterCategory:', filterCategory);
      load();
    }
    
    // Hàm xóa bộ lọc
    function clearFilters() {
      if (searchInput) searchInput.value = '';
      if (statusSelect) statusSelect.selectedIndex = 0;
      if (categorySelect) categorySelect.selectedIndex = 0;
      searchTerm = '';
      filterStatus = '';
      filterCategory = '';
      currentPage = 1; // Reset về trang đầu khi xóa lọc
      console.log('Clearing filters');
      load();
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
        console.log('Pagination clicked, page:', p);
        renderPage(p === 'prev' || p === 'next' ? p : parseInt(p,10));
      });
    } else {
      console.warn('pagerContainer not found for event listener!');
    }

    // Handle submit
    document.getElementById('supportForm').addEventListener('submit', function(e){
      e.preventDefault();
      const form = e.target;
      
      // Validation: Kiểm tra hợp đồng và sản phẩm
      const cSel = document.getElementById('contractSelect');
      const pSel = document.getElementById('contractProductSelect');
      const subject = document.getElementById('subject').value || '';
      const description = document.getElementById('description').value || '';
      
      // Kiểm tra các trường bắt buộc
      if (!cSel || !cSel.value || cSel.value.trim() === '') {
        showSuccessModal('Lỗi', 'Vui lòng chọn hợp đồng trước khi tạo yêu cầu hỗ trợ!');
        return;
      }
      
      if (!pSel || !pSel.value || pSel.value.trim() === '') {
        showSuccessModal('Lỗi', 'Vui lòng chọn sản phẩm trong hợp đồng trước khi tạo yêu cầu hỗ trợ!');
        return;
      }
      
      if (!subject || subject.trim() === '') {
        showSuccessModal('Lỗi', 'Vui lòng nhập tiêu đề yêu cầu hỗ trợ!');
        return;
      }
      
      if (!description || description.trim() === '') {
        showSuccessModal('Lỗi', 'Vui lòng nhập chi tiết vấn đề!');
        return;
      }
      
      const data = new URLSearchParams();
      const baseDesc = description;
      // Lưu hợp đồng/sản phẩm vào mô tả để hiển thị lại ở chi tiết (danh sách sẽ ẩn các tiền tố này)
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
      fetch(ctx + '/api/support-customer', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json' },
        body: data.toString()
      }).then(r => {
        console.log('Response status:', r.status);
        console.log('Response headers:', r.headers);
        if (!r.ok) {
          throw new Error('HTTP ' + r.status);
        }
        return r.text().then(text => {
          console.log('Raw response text:', text);
          try {
            return JSON.parse(text);
          } catch (e) {
            console.error('JSON parse error:', e);
            throw new Error('Invalid JSON response: ' + text.substring(0, 100));
          }
        });
      })
        .then(j => {
          console.log('Parsed response data:', j);
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
            
              // Hiển thị thông báo thành công bằng modal
              showSuccessModal('Tạo yêu cầu thành công!', j.message || 'Yêu cầu hỗ trợ đã được tạo thành công!');
            
            // Tải lại dữ liệu - reset về trang đầu
            currentPage = 1;
            load();
          } else {
            console.error('Server error:', j);
            alert(j && j.message ? j.message : 'Không thể tạo yêu cầu');
          }
        })
        .catch(error => {
          console.error('Request failed:', error);
          alert('Lỗi kết nối máy chủ: ' + error.message);
        });
    });

    
   
     // View detail handler
    tbody.addEventListener('click', function(e){
      const viewLink = e.target.closest('a.view-link');
      const cancelLink = e.target.closest('a.cancel-link');
      const feedbackLink = e.target.closest('a.feedback-link');
      
      if(feedbackLink) {
        e.preventDefault();
        const id = feedbackLink.getAttribute('data-id');
        const ticketNumber = feedbackLink.getAttribute('data-ticket-number');
        openFeedbackModal(id, ticketNumber);
        return;
      }
      
      if(viewLink) {
        e.preventDefault();
        const id = viewLink.getAttribute('data-id');
        const it = allItems.find(function(x){ return String(x.id) === String(id); });
        if(!it) return;
        
        // Load fresh data from server for this specific ticket
        fetch(ctx + '/api/support-stats?action=getById&id=' + encodeURIComponent(id), { headers: { 'Accept': 'application/json' } })
          .then(r => r.json())
          .then(j => {
            if (j && j.success && j.data) {
              // Use fresh data from server instead of cached data
              const freshData = j.data;
              displayTicketDetail(freshData);
            } else {
              // Fallback to cached data if API fails
              displayTicketDetail(it);
            }
          })
          .catch(error => {
            console.error('Failed to load fresh ticket data:', error);
            // Fallback to cached data
            displayTicketDetail(it);
          });
      }
      
      function displayTicketDetail(ticketData) {
      document.getElementById('v_ticket').textContent = ticketData.ticketNumber || '';
      document.getElementById('v_status').textContent = ticketData.status || '';
      // fill editable inputs
      var catInp = document.getElementById('v_category_inp');
      var priInp = document.getElementById('v_priority_inp');
      var subInp = document.getElementById('v_subject_inp');
      var desInp = document.getElementById('v_description_inp');
      var vContract = document.getElementById('v_contract_select');
      var vProduct = document.getElementById('v_product_select');
      if (catInp) catInp.value = (ticketData.category||'general');
      if (priInp) priInp.value = (ticketData.priority ? ticketData.priority : '');
      if (subInp) subInp.value = (ticketData.subject||'');
      if (desInp) desInp.value = (ticketData.description||'');
      const created = formatDate(ticketData);
      const resolved = (ticketData.resolvedAt ? new Intl.DateTimeFormat('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' }).format(new Date(ticketData.resolvedAt)) : '');
      document.getElementById('v_created').textContent = created;
      document.getElementById('v_resolved').textContent = resolved;
      
      // Hiển thị các trường mới
      document.getElementById('v_assigned_to').textContent = ticketData.assignedTo || 'Chưa phân công';
      document.getElementById('v_history').textContent = ticketData.history || 'Chưa có lịch sử';
      document.getElementById('v_resolution').value = ticketData.resolution || '';
      
      // Store ticket ID in modal for feedback
      document.getElementById('viewModal').setAttribute('data-current-ticket-id', ticketData.id);
      
      // Show the modal
      const vm = bootstrap.Modal.getOrCreateInstance(document.getElementById('viewModal'));
      vm.show();
      
      // reset edit state
      const enable = document.getElementById('v_enable_edit');
      const saveBtn = document.getElementById('v_save_btn');
      [catInp, priInp, subInp, desInp].forEach(function(el){ if(el){ el.disabled = true; }});
      if (enable) enable.checked = false;
      if (saveBtn) saveBtn.disabled = true;
      
      // Kiểm tra trạng thái để quyết định có cho phép chỉnh sửa không
      const finalStatus = cancelledItems.has(String(ticketData.id)) ? 'cancelled' : (ticketData.status || 'pending');
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
      
      // Attach handlers for edit functionality
      attachEditHandlers(ticketData.id, ticketData.status, catInp, priInp, subInp, desInp, vContract, vProduct, enable, saveBtn);
      }
      
      function attachEditHandlers(ticketId, ticketStatus, catInp, priInp, subInp, desInp, vContract, vProduct, enable, saveBtn) {
      // Kiểm tra trạng thái để quyết định có cho phép chỉnh sửa không
      const finalStatus = cancelledItems.has(String(ticketId)) ? 'cancelled' : (ticketStatus || 'pending');
      const canEdit = finalStatus === 'pending' || finalStatus === 'open';
      
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
          data.append('delete_old_id', ticketId); // thêm ID để xóa bản cũ
          fetch(ctx + '/api/support-customer', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json' },
            body: data.toString()
          }).then(r => {
            console.log('Update response status:', r.status);
            if (!r.ok) {
              throw new Error('HTTP ' + r.status);
            }
            return r.json();
          }).then(function(j){
            console.log('Update response data:', j);
            if(j && j.success){
              vm.hide();
              
              // Hiển thị thông báo thành công bằng modal
              showSuccessModal('Cập nhật thành công!', 'Yêu cầu hỗ trợ đã được cập nhật thành công!');
              
              // Tải lại dữ liệu
              load();
            } else {
              console.error('Update server error:', j);
              alert(j && j.message ? j.message : 'Không thể cập nhật');
            }
          }).catch(function(error){ 
            console.error('Update request failed:', error);
            alert('Lỗi kết nối máy chủ: ' + error.message); 
          });
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
        if(finalStatus !== 'pending' && finalStatus !== 'open' && finalStatus !== 'cancelled' && finalStatus !== 'closed') {
          alert('Chỉ có thể hủy yêu cầu đang chờ xử lý, đã hủy hoặc đã đóng!');
          return;
        }
        
        
        // Hiển thị modal xác nhận thay vì confirm()
        showConfirmModal('Bạn có chắc chắn muốn hủy yêu cầu này?', function() {
          // Đánh dấu item đã hủy và cập nhật hiển thị
          cancelledItems.add(String(id));
          renderPage(currentPage); // Cập nhật hiển thị ngay lập tức
          
          // Gửi request hủy yêu cầu đến server
          const data = new URLSearchParams();
          data.append('action', 'cancel');
          data.append('id', id);
          
          console.log('DEBUG: Sending cancel request with:', data.toString());
          fetch(ctx + '/api/support-customer', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json' },
            body: data.toString()
          }).then(r => {
            console.log('Cancel response status:', r.status);
            if (!r.ok) {
              throw new Error('HTTP ' + r.status);
            }
            return r.json();
          })
            .then(j => {
              console.log('Cancel response data:', j);
              if(j && j.success){
                // Hiển thị thông báo thành công bằng modal
                showSuccessModal('Hủy yêu cầu thành công!', 'Đã hủy yêu cầu thành công!');
                
                // Tải lại dữ liệu
                load(); // Reload danh sách từ server
              } else {
                // Nếu server từ chối, revert lại trạng thái
                cancelledItems.delete(String(id));
                load(); // Reload để cập nhật UI
                showSuccessModal('Lỗi', j && j.message ? j.message : 'Không thể hủy yêu cầu');
              }
            })
            .catch(error => {
              console.error('Cancel request failed:', error);
              // Nếu có lỗi kết nối, revert lại trạng thái
              cancelledItems.delete(String(id));
              load(); // Reload để cập nhật UI
              showSuccessModal('Lỗi', 'Lỗi kết nối máy chủ: ' + error.message);
            });
        });
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