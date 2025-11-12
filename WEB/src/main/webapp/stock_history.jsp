<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <% String username=(String) session.getAttribute("username"); Boolean isLoggedIn=(Boolean)
    session.getAttribute("isLoggedIn"); String userRole=(String) session.getAttribute("userRole"); if (username==null ||
    isLoggedIn==null || !isLoggedIn) { response.sendRedirect(request.getContextPath() + "/login.jsp" ); return; } %>
    <!DOCTYPE html>
    <html>

    <head>
      <meta charset="UTF-8">
      <title>Lịch sử xuất nhập kho</title>
      <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
      <link href="<%=request.getContextPath()%>/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
      <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
      <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet" type="text/css" />
      <style>
        .history-card {
          border: 1px solid #eee;
          border-radius: 6px;
          padding: 16px;
          margin-bottom: 12px;
          background: #fff
        }

        .history-badge {
          padding: 4px 8px;
          border-radius: 12px;
          font-size: 12px
        }

        .badge-in {
          background: #e8f5e9;
          color: #2e7d32
        }

        .badge-out {
          background: #fdecea;
          color: #c62828
        }

        .badge-adj {
          background: #e8f0fe;
          color: #1a73e8
        }

        .qty-pos {
          color: #2e7d32;
          font-weight: 600
        }

        .qty-neg {
          color: #c62828;
          font-weight: 600
        }

        .muted {
          color: #777
        }

        .filter-bar .form-control {
          height: 36px
        }

        body {
          background: #f5f6f8
        }

      .table-responsive {
        margin-top: 10px;
      }
      </style>
    </head>

    <body class="skin-black">
      <header class="header">
        <a href="<%=request.getContextPath()%>/admin.jsp" class="logo">Quản lý kho</a>
        <nav class="navbar navbar-static-top" role="navigation">
          <a href="#" class="navbar-btn sidebar-toggle" data-toggle="offcanvas" role="button">
            <span class="icon-bar"></span><span class="icon-bar"></span><span class="icon-bar"></span>
          </a>
          <div class="navbar-right">
            <ul class="nav navbar-nav">
              <li class="dropdown user user-menu"><a class="dropdown-toggle" data-toggle="dropdown" href="#"><i
                    class="fa fa-user"></i><span>
                    <%= username %> <i class="caret"></i>
                  </span></a>
                <ul class="dropdown-menu">
                  <li class="dropdown-header text-center">Tài khoản</li>
                  <li><a href="profile.jsp">Hồ sơ</a><a href="<%=request.getContextPath()%>/logout">Đăng xuất</a></li>
                </ul>
              </li>
            </ul>
          </div>
        </nav>
      </header>
      <div class="wrapper row-offcanvas row-offcanvas-left">
        <jsp:include page="partials/sidebar.jsp"/>
        <aside class="right-side">
          <section class="content">
            <div class="row">
              <div class="col-xs-12">
                <div class="panel">
                   <header class="panel-heading">
                  <h3 style="display: inline-block; margin: 0 0 15px 0;"><i class="fa fa-history"></i> Lịch sử Xuất, Nhập, Tồn</h3>
                  <div class="panel-tools" style="float: right; margin-bottom: 15px;">
                    <a class="btn btn-default btn-sm" href="<%=request.getContextPath()%>/inventory.jsp">
                      <i class="fa fa-arrow-left"></i> Quay lại
                    </a>
                  </div>
                  <ul class="nav nav-tabs" style="border-bottom:none; clear: both;">
                    <li class="active"><a href="#tab-in" data-toggle="tab"><i class="fa fa-arrow-down"></i> Lịch sử nhập kho</a></li>
                    <li><a href="#tab-out" data-toggle="tab"><i class="fa fa-arrow-up"></i> Lịch sử xuất kho</a></li>
                    <li><a href="#tab-balance" data-toggle="tab"><i class="fa fa-cubes"></i> Lịch sử tồn kho</a></li>
                     </ul>
                   </header>
                  <div class="panel-body tab-content">
                  <!-- TAB 1: LỊCH SỬ NHẬP KHO -->
                  <div class="tab-pane active" id="tab-in">
                    <div class="row filter-bar" style="margin-bottom:10px;">
                      <div class="col-sm-4"><input id="inSearchKeyword" class="form-control"
                          placeholder="Tìm theo tên/mã sản phẩm" /></div>
                      <div class="col-sm-3"><input type="date" id="inDateFrom" class="form-control" placeholder="Từ ngày" /></div>
                      <div class="col-sm-3"><input type="date" id="inDateTo" class="form-control" placeholder="Đến ngày" /></div>
                      <div class="col-sm-1">
                        <div class="form-group">
                          <label style="color: transparent; margin-bottom: 5px;">Lọc</label>
                          <button type="button" class="btn btn-primary btn-sm" style="width: 100%;" onclick="reloadInHistory(true)" title="Áp dụng bộ lọc">
                            <i class="fa fa-search"></i>
                          </button>
                        </div>
                      </div>
                      <div class="col-sm-1">
                        <div class="form-group">
                          <label style="color: transparent; margin-bottom: 5px;">Reset</label>
                          <button type="button" class="btn btn-warning btn-sm" style="width: 100%;" onclick="resetInFilters()" title="Xóa tất cả bộ lọc">
                            <i class="fa fa-refresh"></i>
                          </button>
                        </div>
                      </div>
                    </div>
                    <div class="table-responsive">
                      <table class="table table-bordered table-striped">
                        <thead>
                          <tr>
                            <th>Thời gian</th>
                            <th>Sản phẩm</th>
                            <th>Số lượng nhập</th>
                            <th>Đơn giá nhập</th>
                            <th>Tổng tiền</th>
                            <th>Kho</th>
                            <th>Nhà cung cấp</th>
                            <th>Người thực hiện</th>
                            <th>Ghi chú</th>
                          </tr>
                        </thead>
                        <tbody id="inHistoryBody">
                          <tr><td colspan="9" class="text-center"><i class="fa fa-spinner fa-spin"></i> Đang tải...</td></tr>
                        </tbody>
                      </table>
                    </div>
                    <div class="row" style="margin-top:10px;">
                      <div class="col-sm-6"><span id="inHistoryInfo" class="muted"></span></div>
                      <div class="col-sm-6" style="text-align:right;">
                        <ul class="pagination" id="inHistoryPagination" style="margin:0;"></ul>
                      </div>
                    </div>
                  </div>

                  <!-- TAB 2: LỊCH SỬ XUẤT KHO -->
                  <div class="tab-pane" id="tab-out">
                    <div class="row filter-bar" style="margin-bottom:10px;">
                      <div class="col-sm-4"><input id="outSearchKeyword" class="form-control"
                          placeholder="Tìm theo tên/mã sản phẩm" /></div>
                      <div class="col-sm-3"><input type="date" id="outDateFrom" class="form-control" placeholder="Từ ngày" /></div>
                      <div class="col-sm-3"><input type="date" id="outDateTo" class="form-control" placeholder="Đến ngày" /></div>
                      <div class="col-sm-1">
                        <div class="form-group">
                          <label style="color: transparent; margin-bottom: 5px;">Lọc</label>
                          <button type="button" class="btn btn-primary btn-sm" style="width: 100%;" onclick="reloadOutHistory(true)" title="Áp dụng bộ lọc">
                            <i class="fa fa-search"></i>
                          </button>
                        </div>
                      </div>
                      <div class="col-sm-1">
                        <div class="form-group">
                          <label style="color: transparent; margin-bottom: 5px;">Reset</label>
                          <button type="button" class="btn btn-warning btn-sm" style="width: 100%;" onclick="resetOutFilters()" title="Xóa tất cả bộ lọc">
                            <i class="fa fa-refresh"></i>
                          </button>
                        </div>
                      </div>
                    </div>
                    <div class="table-responsive">
                      <table class="table table-bordered table-striped">
                        <thead>
                          <tr>
                            <th>Thời gian</th>
                            <th>Sản phẩm</th>
                            <th>Số lượng xuất</th>
                            <th>Giá bán</th>
                            <th>Kho</th>
                            <th>Lý do xuất</th>
                            <th>Người thực hiện</th>
                            <th>Ghi chú</th>
                          </tr>
                        </thead>
                        <tbody id="outHistoryBody">
                          <tr><td colspan="8" class="text-center"><i class="fa fa-spinner fa-spin"></i> Đang tải...</td></tr>
                        </tbody>
                      </table>
                    </div>
                    <div class="row" style="margin-top:10px;">
                      <div class="col-sm-6"><span id="outHistoryInfo" class="muted"></span></div>
                      <div class="col-sm-6" style="text-align:right;">
                        <ul class="pagination" id="outHistoryPagination" style="margin:0;"></ul>
                      </div>
                    </div>
                    </div>

                  <!-- TAB 3: LỊCH SỬ TỒN KHO -->
                  <div class="tab-pane" id="tab-balance">
                      <div class="row filter-bar" style="margin-bottom:10px;">
                      <div class="col-sm-4"><input id="balanceSearchKeyword" class="form-control"
                          placeholder="Tìm theo tên/mã sản phẩm" /></div>
                      <div class="col-sm-3"><input type="date" id="balanceDateFrom" class="form-control" placeholder="Từ ngày" /></div>
                      <div class="col-sm-3"><input type="date" id="balanceDateTo" class="form-control" placeholder="Đến ngày" /></div>
                      <div class="col-sm-1">
                        <div class="form-group">
                          <label style="color: transparent; margin-bottom: 5px;">Lọc</label>
                          <button type="button" class="btn btn-primary btn-sm" style="width: 100%;" onclick="reloadBalanceHistory(true)" title="Áp dụng bộ lọc">
                            <i class="fa fa-search"></i>
                          </button>
                        </div>
                      </div>
                      <div class="col-sm-1">
                        <div class="form-group">
                          <label style="color: transparent; margin-bottom: 5px;">Reset</label>
                          <button type="button" class="btn btn-warning btn-sm" style="width: 100%;" onclick="resetBalanceFilters()" title="Xóa tất cả bộ lọc">
                            <i class="fa fa-refresh"></i>
                          </button>
                        </div>
                      </div>
                      </div>
                      <div class="table-responsive">
                        <table class="table table-bordered table-striped">
                          <thead>
                            <tr>
                              <th>Thời gian</th>
                              <th>Sản phẩm</th>
                              <th>Tồn kho</th>
                              <th>Tồn thực tế (hiện tại)</th>
                              <th>Đã giữ chỗ (hiện tại)</th>
                              <th>Khả dụng (hiện tại)</th>
                              <th>Kho</th>
                            </tr>
                          </thead>
                        <tbody id="balanceHistoryBody">
                          <tr><td colspan="6" class="text-center"><i class="fa fa-spinner fa-spin"></i> Đang tải...</td></tr>
                          </tbody>
                        </table>
                      </div>
                      <div class="row" style="margin-top:10px;">
                      <div class="col-sm-6"><span id="balanceHistoryInfo" class="muted"></span></div>
                        <div class="col-sm-6" style="text-align:right;">
                        <ul class="pagination" id="balanceHistoryPagination" style="margin:0;"></ul>
                      </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </section>
        </aside>
      </div>

      <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
      <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
      <script>
      // ================== TAB NHẬP KHO ==================
      var inPage = 1;
      var inPageSize = 10;

      function reloadInHistory(resetPage) {
        if (resetPage) inPage = 1;
        var params = { action: 'getHistory', type: 'in', page: inPage, pageSize: inPageSize };
        var urlParams = new URLSearchParams(window.location.search);
        var productIdParam = urlParams.get('productId');
        var keyword = ($('#inSearchKeyword').val() || '').trim();
        var dateFrom = $('#inDateFrom').val();
        var dateTo = $('#inDateTo').val();
        if (productIdParam) params.productId = productIdParam;
        if (keyword) params.q = keyword;
        if (dateFrom) params.dateFrom = dateFrom;
        if (dateTo) params.dateTo = dateTo;
        $.getJSON('<%=request.getContextPath()%>/inventory', params, function (res) {
          if (!res.success) {
            $('#inHistoryBody').html('<tr><td colspan="9" class="text-center alert alert-danger">' + (res.message || 'Lỗi tải lịch sử') + '</td></tr>');
            return;
          }
          renderInHistory(res);
          }).fail(function (xhr) {
          $('#inHistoryBody').html('<tr><td colspan="9" class="text-center alert alert-danger">' + (xhr.responseText || 'Lỗi kết nối') + '</td></tr>');
        });
      }

      function renderInHistory(res) {
        if (res.currentPage) inPage = res.currentPage;
        var body = $('#inHistoryBody');
        body.empty();
        if (!res.data || res.data.length === 0) {
          body.html('<tr><td colspan="9" class="text-center muted">Không có dữ liệu</td></tr>');
          updateInPagination(res.totalCount || 0, res.totalPages || 1);
          $('#inHistoryInfo').text('0 bản ghi');
          return;
        }
        var totalQuantity = 0;
        var totalAmount = 0;
        res.data.forEach(function(h) {
          var when = new Date(h.createdAt).toLocaleString('vi-VN');
          var unitCost = h.unitCost != null ? formatCurrencyVN(h.unitCost) + ' đ' : '';
          var qty = h.quantity || 0;
          var amount = (h.unitCost != null && h.quantity != null) ? h.unitCost * h.quantity : 0;
          var total = amount > 0 ? formatCurrencyVN(amount) + ' đ' : '';
          var supplier = extractSupplierFromNotes(h.notes);
          totalQuantity += qty;
          totalAmount += amount;
          var row = '<tr>' +
            '<td>' + when + '</td>' +
            '<td>' + escapeHtml(h.productName || '') + ' <span class="muted">(' + escapeHtml(h.productCode || '') + ')</span></td>' +
            '<td class="qty-pos">+' + qty + '</td>' +
            '<td>' + unitCost + '</td>' +
            '<td><strong>' + total + '</strong></td>' +
            '<td>' + escapeHtml(h.warehouseLocation || '') + '</td>' +
            '<td>' + escapeHtml(supplier) + '</td>' +
            '<td>' + escapeHtml(h.createdByName || '') + '</td>' +
            '<td>' + escapeHtml(h.notes || '') + '</td>' +
            '</tr>';
          body.append(row);
        });
        // Thêm hàng tổng
        var totalRow = '<tr style="background-color: #f5f5f5; font-weight: bold;">' +
          '<td colspan="2" style="text-align: right;"><strong>TỔNG:</strong></td>' +
          '<td class="qty-pos"><strong>+' + totalQuantity + '</strong></td>' +
          '<td></td>' +
          '<td><strong>' + (totalAmount > 0 ? formatCurrencyVN(totalAmount) + ' đ' : '') + '</strong></td>' +
          '<td colspan="4"></td>' +
          '</tr>';
        body.append(totalRow);
        var start = (res.currentPage - 1) * res.pageSize + (res.data.length > 0 ? 1 : 0);
        var end = (res.currentPage - 1) * res.pageSize + res.data.length;
        $('#inHistoryInfo').text('Hiển thị ' + (res.totalCount > 0 ? start : 0) + ' đến ' + end + ' trong tổng số ' + res.totalCount + ' bản ghi');
        updateInPagination(res.totalCount || 0, res.totalPages || 1);
      }

      function updateInPagination(totalCount, totalPages) {
        var ul = $('#inHistoryPagination');
        ul.empty();
        var prev = $('<li class="paginate_button ' + (inPage <= 1 ? 'disabled' : '') + '"><a href="#">Trước</a></li>');
        prev.on('click', function (e) { e.preventDefault(); if (inPage > 1) { inPage--; reloadInHistory(false); } });
        ul.append(prev);
        var maxVisible = 5;
        var start = Math.max(1, inPage - Math.floor(maxVisible / 2));
        var end = Math.min(totalPages, start + maxVisible - 1);
        if (end - start + 1 < maxVisible) start = Math.max(1, end - maxVisible + 1);
        for (var p = start; p <= end; p++) {
          (function (page) {
            var li = $('<li class="paginate_button ' + (page === inPage ? 'active' : '') + '"><a href="#">' + page + '</a></li>');
            li.on('click', function (e) { e.preventDefault(); inPage = page; reloadInHistory(false); });
            ul.append(li);
          })(p);
        }
        var next = $('<li class="paginate_button ' + (inPage >= totalPages ? 'disabled' : '') + '"><a href="#">Tiếp</a></li>');
        next.on('click', function (e) { e.preventDefault(); if (inPage < totalPages) { inPage++; reloadInHistory(false); } });
        ul.append(next);
      }

      function resetInFilters() {
        $('#inSearchKeyword').val('');
        $('#inDateFrom').val('');
        $('#inDateTo').val('');
        inPage = 1;
        reloadInHistory(false);
      }

      // ================== TAB XUẤT KHO ==================
      var outPage = 1;
      var outPageSize = 8;

      function reloadOutHistory(resetPage) {
        if (resetPage) outPage = 1;
        var params = { action: 'getHistory', type: 'out', page: outPage, pageSize: outPageSize };
        var urlParams = new URLSearchParams(window.location.search);
        var productIdParam = urlParams.get('productId');
        var keyword = ($('#outSearchKeyword').val() || '').trim();
        var dateFrom = $('#outDateFrom').val();
        var dateTo = $('#outDateTo').val();
        if (productIdParam) params.productId = productIdParam;
        if (keyword) params.q = keyword;
        if (dateFrom) params.dateFrom = dateFrom;
        if (dateTo) params.dateTo = dateTo;
        $.getJSON('<%=request.getContextPath()%>/inventory', params, function (res) {
          if (!res.success) {
            $('#outHistoryBody').html('<tr><td colspan="8" class="text-center alert alert-danger">' + (res.message || 'Lỗi tải lịch sử') + '</td></tr>');
            return;
          }
          renderOutHistory(res);
        }).fail(function (xhr) {
          $('#outHistoryBody').html('<tr><td colspan="8" class="text-center alert alert-danger">' + (xhr.responseText || 'Lỗi kết nối') + '</td></tr>');
        });
      }

      function renderOutHistory(res) {
        if (res.currentPage) outPage = res.currentPage;
        var body = $('#outHistoryBody');
        body.empty();
        if (!res.data || res.data.length === 0) {
          body.html('<tr><td colspan="8" class="text-center muted">Không có dữ liệu</td></tr>');
          updateOutPagination(res.totalCount || 0, res.totalPages || 1);
          $('#outHistoryInfo').text('0 bản ghi');
          return;
        }
        var totalQuantity = 0;
        res.data.forEach(function(h) {
          var when = new Date(h.createdAt).toLocaleString('vi-VN');
          var unitPrice = h.unitPrice != null ? formatCurrencyVN(h.unitPrice) + ' đ' : '';
          var reason = extractReasonFromNotes(h.notes);
          var qty = h.quantity || 0;
          totalQuantity += qty;
          var row = '<tr>' +
            '<td>' + when + '</td>' +
            '<td>' + escapeHtml(h.productName || '') + ' <span class="muted">(' + escapeHtml(h.productCode || '') + ')</span></td>' +
            '<td class="qty-neg">-' + qty + '</td>' +
            '<td>' + unitPrice + '</td>' +
            '<td>' + escapeHtml(h.warehouseLocation || '') + '</td>' +
            '<td>' + escapeHtml(reason) + '</td>' +
            '<td>' + escapeHtml(h.createdByName || '') + '</td>' +
            '<td>' + escapeHtml(h.notes || '') + '</td>' +
          '</tr>';
          body.append(row);
        });
        // Thêm hàng tổng
        var totalRow = '<tr style="background-color: #f5f5f5; font-weight: bold;">' +
          '<td colspan="2" style="text-align: right;"><strong>TỔNG:</strong></td>' +
          '<td class="qty-neg"><strong>-' + totalQuantity + '</strong></td>' +
          '<td colspan="5"></td>' +
          '</tr>';
        body.append(totalRow);
        var start = (res.currentPage - 1) * res.pageSize + (res.data.length > 0 ? 1 : 0);
        var end = (res.currentPage - 1) * res.pageSize + res.data.length;
        $('#outHistoryInfo').text('Hiển thị ' + (res.totalCount > 0 ? start : 0) + ' đến ' + end + ' trong tổng số ' + res.totalCount + ' bản ghi');
        updateOutPagination(res.totalCount || 0, res.totalPages || 1);
      }

      function updateOutPagination(totalCount, totalPages) {
        var ul = $('#outHistoryPagination');
        ul.empty();
        var prev = $('<li class="paginate_button ' + (outPage <= 1 ? 'disabled' : '') + '"><a href="#">Trước</a></li>');
        prev.on('click', function (e) { e.preventDefault(); if (outPage > 1) { outPage--; reloadOutHistory(false); } });
          ul.append(prev);
          var maxVisible = 5;
        var start = Math.max(1, outPage - Math.floor(maxVisible / 2));
          var end = Math.min(totalPages, start + maxVisible - 1);
          if (end - start + 1 < maxVisible) start = Math.max(1, end - maxVisible + 1);
          for (var p = start; p <= end; p++) {
          (function (page) {
            var li = $('<li class="paginate_button ' + (page === outPage ? 'active' : '') + '"><a href="#">' + page + '</a></li>');
            li.on('click', function (e) { e.preventDefault(); outPage = page; reloadOutHistory(false); });
              ul.append(li);
            })(p);
          }
        var next = $('<li class="paginate_button ' + (outPage >= totalPages ? 'disabled' : '') + '"><a href="#">Tiếp</a></li>');
        next.on('click', function (e) { e.preventDefault(); if (outPage < totalPages) { outPage++; reloadOutHistory(false); } });
          ul.append(next);
        }

      function resetOutFilters() {
        $('#outSearchKeyword').val('');
        $('#outDateFrom').val('');
        $('#outDateTo').val('');
        outPage = 1;
        reloadOutHistory(false);
      }

      // ================== TAB TỒN KHO ==================
      var balancePage = 1;
      var balancePageSize = 10;

      function reloadBalanceHistory(resetPage) {
        if (resetPage) balancePage = 1;
        var params = { action: 'getStockBalance', page: balancePage, pageSize: balancePageSize };
        var urlParams = new URLSearchParams(window.location.search);
        var productIdParam = urlParams.get('productId');
        var keyword = ($('#balanceSearchKeyword').val() || '').trim();
        var dateFrom = $('#balanceDateFrom').val();
        var dateTo = $('#balanceDateTo').val();
        if (productIdParam) params.productId = productIdParam;
        if (keyword) params.q = keyword;
        if (dateFrom) params.dateFrom = dateFrom;
        if (dateTo) params.dateTo = dateTo;
        $.getJSON('<%=request.getContextPath()%>/inventory', params, function (res) {
          if (!res.success) {
            $('#balanceHistoryBody').html('<tr><td colspan="7" class="text-center alert alert-danger">' + (res.message || 'Lỗi tải lịch sử') + '</td></tr>');
            return;
          }
          renderBalanceHistory(res);
        }).fail(function (xhr) {
          $('#balanceHistoryBody').html('<tr><td colspan="7" class="text-center alert alert-danger">' + (xhr.responseText || 'Lỗi kết nối') + '</td></tr>');
        });
      }

      function renderBalanceHistory(res) {
        if (res.currentPage) balancePage = res.currentPage;
        var body = $('#balanceHistoryBody');
        body.empty();
        if (!res.data || res.data.length === 0) {
          body.html('<tr><td colspan="7" class="text-center muted">Không có dữ liệu</td></tr>');
          updateBalancePagination(res.totalCount || 0, res.totalPages || 1);
          $('#balanceHistoryInfo').text('0 bản ghi');
          return;
        }
        var totalStockBefore = 0;
        var totalCurrentStock = 0;
        var totalReservedStock = 0;
        var totalAvailableStock = 0;
        res.data.forEach(function(h) {
          var when = new Date(h.createdAt).toLocaleString('vi-VN');
          var stockOriginal = h.stockBefore != null ? h.stockBefore : 0;
          var stockBefore = Math.max(stockOriginal, 0);
          var currentStockNow = h.currentStock != null ? h.currentStock : 0;
          var reservedStockNow = h.reservedStock != null ? h.reservedStock : 0;
          var availableStockNow = h.availableStock != null ? h.availableStock : Math.max(currentStockNow - reservedStockNow, 0);
          totalStockBefore += stockBefore;
          totalCurrentStock += currentStockNow;
          totalReservedStock += reservedStockNow;
          totalAvailableStock += availableStockNow;
          var row = '<tr>' +
            '<td>' + when + '</td>' +
            '<td>' + escapeHtml(h.productName || '') + ' <span class="muted">(' + escapeHtml(h.productCode || '') + ')</span></td>' +
            '<td>' + stockBefore + '</td>' +
            '<td>' + currentStockNow + '</td>' +
            '<td>' + reservedStockNow + '</td>' +
            '<td>' + availableStockNow + '</td>' +
            '<td>' + escapeHtml(h.warehouseLocation || '') + '</td>' +
            '</tr>';
          body.append(row);
        });
        // Thêm hàng tổng
        var totalRow = '<tr style="background-color: #f5f5f5; font-weight: bold;">' +
          '<td colspan="2" style="text-align: right;"><strong>TỔNG:</strong></td>' +
          '<td><strong>' + totalStockBefore + '</strong></td>' +
          '<td><strong>' + totalCurrentStock + '</strong></td>' +
          '<td><strong>' + totalReservedStock + '</strong></td>' +
          '<td><strong>' + totalAvailableStock + '</strong></td>' +
          '<td></td>' +
          '</tr>';
        body.append(totalRow);
        var start = (res.currentPage - 1) * res.pageSize + (res.data.length > 0 ? 1 : 0);
        var end = (res.currentPage - 1) * res.pageSize + res.data.length;
        $('#balanceHistoryInfo').text('Hiển thị ' + (res.totalCount > 0 ? start : 0) + ' đến ' + end + ' trong tổng số ' + res.totalCount + ' bản ghi');
        updateBalancePagination(res.totalCount || 0, res.totalPages || 1);
      }

      function updateBalancePagination(totalCount, totalPages) {
        var ul = $('#balanceHistoryPagination');
        ul.empty();
        var prev = $('<li class="paginate_button ' + (balancePage <= 1 ? 'disabled' : '') + '"><a href="#">Trước</a></li>');
        prev.on('click', function (e) { e.preventDefault(); if (balancePage > 1) { balancePage--; reloadBalanceHistory(false); } });
           ul.append(prev);
           var maxVisible = 5;
        var start = Math.max(1, balancePage - Math.floor(maxVisible / 2));
           var end = Math.min(totalPages, start + maxVisible - 1);
           if (end - start + 1 < maxVisible) start = Math.max(1, end - maxVisible + 1);
           for (var p = start; p <= end; p++) {
             (function (page) {
            var li = $('<li class="paginate_button ' + (page === balancePage ? 'active' : '') + '"><a href="#">' + page + '</a></li>');
            li.on('click', function (e) { e.preventDefault(); balancePage = page; reloadBalanceHistory(false); });
               ul.append(li);
             })(p);
           }
        var next = $('<li class="paginate_button ' + (balancePage >= totalPages ? 'disabled' : '') + '"><a href="#">Tiếp</a></li>');
        next.on('click', function (e) { e.preventDefault(); if (balancePage < totalPages) { balancePage++; reloadBalanceHistory(false); } });
           ul.append(next);
         }

      function resetBalanceFilters() {
        $('#balanceSearchKeyword').val('');
        $('#balanceDateFrom').val('');
        $('#balanceDateTo').val('');
        balancePage = 1;
        reloadBalanceHistory(false);
      }

      // ================== HELPER FUNCTIONS ==================
      function formatCurrencyVN(n) {
        try {
          return Number(n).toLocaleString('vi-VN');
        } catch (e) {
          return n;
        }
      }

      function escapeHtml(s) {
        if (!s) return '';
        return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
      }

      function extractSupplierFromNotes(notes) {
        if (!notes) return '';
        // Thử nhiều pattern để tìm nhà cung cấp
        var patterns = [
          /Nhà cung cấp:\s*([^\n|]+)/i,
          /Nhà cung cấp[:\s]+([^\n|]+)/i,
          /NCC[:\s]+([^\n|]+)/i,
          /Supplier[:\s]+([^\n|]+)/i,
          /Nhà cung cấp\s+([^\n|]+)/i
        ];
        for (var i = 0; i < patterns.length; i++) {
          var match = notes.match(patterns[i]);
          if (match && match[1]) {
            var supplier = match[1].trim();
            // Loại bỏ các ký tự không cần thiết ở cuối
            supplier = supplier.replace(/[|\n\r].*$/, '').trim();
            if (supplier.length > 0) {
              return supplier;
            }
          }
        }
        return '';
      }

      function extractReasonFromNotes(notes) {
        if (!notes) return '';
        var match = notes.match(/Lý do:\s*([^\n]+)/);
        return match ? match[1].trim() : '';
      }

      // ================== INITIALIZE ==================
      $(function () {
        reloadInHistory(false);
        reloadOutHistory(false);
        reloadBalanceHistory(false);
      });
      </script>
    </body>

    </html>
