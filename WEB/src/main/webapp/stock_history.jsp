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
      </style>
    </head>

    <body class="skin-black">
      <header class="header">
        <a href="<%=request.getContextPath()%>/admin.jsp" class="logo">Bảng điều khiển</a>
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
        <aside class="left-side sidebar-offcanvas">
          <!-- sidebar: style can be found in sidebar.less -->
          <section class="sidebar">
            <!-- Sidebar user panel -->
            <div class="user-panel">
              <div class="pull-left image">
                <img src="<%=request.getContextPath()%>/img/26115.jpg" class="img-circle" alt="User Image" />
              </div>
              <div class="pull-left info">
                <p>Xin chào, <%= username %>
                </p>
                <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
              </div>
            </div>
            <!-- search form -->
            <form action="#" method="get" class="sidebar-form">
              <div class="input-group">
                <input type="text" name="q" class="form-control" placeholder="Tìm kiếm..." />
                <span class="input-group-btn">
                  <button type='submit' name='seach' id='search-btn' class="btn btn-flat"><i
                      class="fa fa-search"></i></button>
                </span>
              </div>
            </form>
            <!-- /.search form -->
            <!-- sidebar menu: : style can be found in sidebar.less -->
            <ul class="sidebar-menu">
              <li>
                <a href="<%=request.getContextPath()%>/admin.jsp">
                  <i class="fa fa-dashboard"></i> <span>Bảng điều khiển</span>
                </a>
              </li>
              <li>
                <a href="<%=request.getContextPath()%>/product.jsp">
                  <i class="fa fa-shopping-cart"></i> <span>Quản lý sản phẩm</span>
                </a>
              </li>
              <li>
                <a href="<%=request.getContextPath()%>/supplier">
                  <i class="fa fa-industry"></i> <span>Nhà cung cấp</span>
                </a>
              </li>
              <li>
                <a href="<%=request.getContextPath()%>/inventory.jsp">
                  <i class="fa fa-archive"></i> <span>Quản lý kho</span>
                </a>
              </li>
              <!-- Không hiển thị link lịch sử trong task bar theo yêu cầu -->
            </ul>
          </section>
          <!-- /.sidebar -->
        </aside>
        <aside class="right-side">
          <section class="content">
            <div class="row">
              <div class="col-xs-12">
                <div class="panel">
                   <header class="panel-heading">
                     <ul class="nav nav-tabs" style="border-bottom:none;">
                       <li class="active"><a href="#tab-stock" data-toggle="tab"><i class="fa fa-exchange"></i> Xuất/Nhập kho</a></li>
                       <li><a href="#tab-price" data-toggle="tab"><i class="fa fa-money"></i> Giá mua/bán</a></li>
                     </ul>
                   </header>
                  <div class="panel-body tab-content">
                    <div class="tab-pane active" id="tab-stock">
                    <div class="row filter-bar" style="margin-bottom:10px;">
                      <div class="col-sm-3"><input id="searchKeyword" class="form-control"
                          placeholder="Tìm theo tên/mã sản phẩm" /></div>
                      <div class="col-sm-2"><select id="filterType" class="form-control">
                          <option value="">Tất cả loại</option>
                          <option value="in">Nhập</option>
                          <option value="out">Xuất</option>
                          <option value="adjustment">Điều chỉnh</option>
                        </select></div>
                      <div class="col-sm-3"><select id="filterWarehouse" class="form-control">
                          <option value="">Tất cả kho</option>
                          <option value="Main Warehouse">Kho Chính</option>
                          <option value="Warehouse A">Kho A</option>
                          <option value="Warehouse B">Kho B</option>
                        </select></div>
                      <div class="col-sm-2"><button class="btn btn-primary btn-block" onclick="reloadHistory()"><i
                            class="fa fa-search"></i> Lọc</button></div>
                      <div class="col-sm-2"><button class="btn btn-default btn-block" onclick="resetFilters()"><i
                            class="fa fa-refresh"></i> Reset</button></div>
                    </div>
                    <div id="historyContainer">
                      <div class="text-center"><i class="fa fa-spinner fa-spin"></i> Đang tải...</div>
                    </div>
                    <div class="row" style="margin-top:10px;">
                      <div class="col-sm-6"><span id="historyInfo" class="muted"></span></div>
                      <div class="col-sm-6" style="text-align:right;">
                        <ul class="pagination" id="historyPagination" style="margin:0;"></ul>
                      </div>
                    </div>
                    </div>

                    <div class="tab-pane" id="tab-price">
                      <div class="row filter-bar" style="margin-bottom:10px;">
                        <div class="col-sm-3"><input id="priceSearchKeyword" class="form-control" placeholder="Tìm theo tên/mã sản phẩm" /></div>
                        <div class="col-sm-2"><select id="priceType" class="form-control">
                            <option value="">Tất cả loại giá</option>
                            <option value="purchase">Giá mua</option>
                            <option value="selling">Giá bán</option>
                          </select></div>
                        <div class="col-sm-2"><button class="btn btn-primary btn-block" onclick="reloadPriceHistory()"><i class="fa fa-search"></i> Lọc</button></div>
                        <div class="col-sm-2"><button class="btn btn-default btn-block" onclick="resetPriceFilters()"><i class="fa fa-refresh"></i> Reset</button></div>
                      </div>
                      <div class="table-responsive">
                        <table class="table table-bordered table-striped">
                          <thead>
                            <tr>
                              <th>Thời gian</th>
                              <th>Sản phẩm</th>
                              <th>Loại</th>
                              <th>Giá cũ</th>
                              <th>Giá mới</th>
                              <th>Người cập nhật</th>
                              <th>Lý do</th>
                            </tr>
                          </thead>
                          <tbody id="priceHistoryBody">
                            <tr><td colspan="7" class="text-center"><i class="fa fa-spinner fa-spin"></i> Đang tải...</td></tr>
                          </tbody>
                        </table>
                      </div>
                      <div class="row" style="margin-top:10px;">
                        <div class="col-sm-6"><span id="priceHistoryInfo" class="muted"></span></div>
                        <div class="col-sm-6" style="text-align:right;">
                          <ul class="pagination" id="priceHistoryPagination" style="margin:0;"></ul>
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
        //  Phân trang client-side
        var histAllItems = [];
        var histFilteredItems = [];
        var histPage = 1;
        var histPageSize = 5;

        //  Hàm fetch và hiển thị lịch sử theo bộ lọc
         function reloadHistory() {
           var params = { action: 'getHistory', page: histPage, pageSize: histPageSize };
           var urlParams = new URLSearchParams(window.location.search);
           var productIdParam = urlParams.get('productId');
           var keyword = ($('#searchKeyword').val() || '').trim();
           var type = $('#filterType').val();
           var wh = $('#filterWarehouse').val();
           if (productIdParam) params.productId = productIdParam;
           if (keyword) params.q = keyword;
           if (type) params.type = type;
           if (wh) params.warehouse = wh;
           $.getJSON('<%=request.getContextPath()%>/inventory', params, function (res) {
            var wrap = $('#historyContainer'); wrap.empty();
             if (!res.success) { wrap.html('<div class="alert alert-danger">' + (res.message || 'Lỗi tải lịch sử') + '</div>'); return; }
             histAllItems = res.data || [];
             histFilteredItems = histAllItems;
             // cập nhật info theo backend
             totalCountFromServer = res.totalCount || histFilteredItems.length;
             totalPagesFromServer = res.totalPages || Math.ceil(totalCountFromServer / histPageSize);
             renderHistoryServerPage(totalCountFromServer, totalPagesFromServer);
          }).fail(function (xhr) {
            $('#historyContainer').html('<div class="alert alert-danger">' + (xhr.responseText || 'Lỗi kết nối') + '</div>');
          });
        }

        //  - Hàm render một thẻ lịch sử
        function renderCard(h) {
          var isIn = h.movementType === 'in', isOut = h.movementType === 'out';
          var badge = isIn ? '<span class="history-badge badge-in">Nhập kho</span>' : (isOut ? '<span class="history-badge badge-out">Xuất kho</span>' : '<span class="history-badge badge-adj">Điều chỉnh</span>');
          var qtyCls = isIn ? 'qty-pos' : (isOut ? 'qty-neg' : ''); var sign = isIn ? '+' : (isOut ? '-' : '');
          var priceLabel = (h.movementType === 'in') ? 'Giá nhập' : (h.movementType === 'out' ? 'Giá bán' : 'Đơn giá');
          var unitVal = (h.movementType === 'in') ? (h.unitCost != null ? h.unitCost : null) : (typeof h.unitPrice === 'number' ? h.unitPrice : null);
          var priceVal = unitVal != null ? (formatCurrencyVN(unitVal) + ' đ') : '--';
          var totalVal = (unitVal != null && h.quantity != null) ? (unitVal * h.quantity) : null;
          var totalText = totalVal != null ? (formatCurrencyVN(totalVal) + ' đ') : '--';
          var when = new Date(h.createdAt).toLocaleString('vi-VN');
          var note = h.notes ? ('<div class="muted" style="margin-top:4px;">"' + escapeHtml(h.notes) + '"</div>') : '';
          return '<div class="history-card">'
            + '<div class="row">'
            + '<div class="col-sm-8">'
            + '<h4 style="margin-top:0">' + escapeHtml(h.productName || '') + ' <small class="muted">' + escapeHtml(h.productCode || '') + '</small> ' + badge + '</h4>'
            + '<div>Số lượng: <span class="' + qtyCls + '">' + sign + (h.quantity || 0) + '</span></div>'
            + '<div>' + priceLabel + ': ' + priceVal + '</div>'
            + '<div><strong>Tổng tiền:</strong> ' + totalText + '</div>'
            + note
            + '</div>'
            + '<div class="col-sm-4">'
            + '<div>Kho: ' + escapeHtml(h.warehouseLocation || '--') + '</div>'
            + '<div class="muted">Bởi: ' + escapeHtml(h.createdByName || '--') + ' • ' + when + '</div>'
            + '</div>'
            + '</div>'
            + '</div>';
        }

        //   - Hàm reset bộ lọc về mặc định
        function resetFilters() { $('#searchKeyword').val(''); $('#filterType').val(''); $('#filterWarehouse').val(''); reloadHistory(); }

        //  - Helpers định dạng & escape
        function formatCurrencyVN(n) { try { return Number(n).toLocaleString('vi-VN'); } catch (e) { return n; } }
        function escapeHtml(s) { if (!s) return ''; return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;'); }

        $(function () {
          // Auto-open price tab if tab=price in query
          var qs = new URLSearchParams(window.location.search);
          if (qs.get('tab') === 'price') {
            $('a[href="#tab-price"]').tab('show');
          }
          reloadHistory();
          reloadPriceHistory();
        });

        //  - Render trang hiện tại
         function renderHistoryPage() {
          var wrap = $('#historyContainer'); wrap.empty();
          if (histFilteredItems.length === 0) { wrap.html('<div class="text-center muted">Không có bản ghi</div>'); updateHistoryPagination(); return; }
          var start = (histPage - 1) * histPageSize;
          var end = Math.min(start + histPageSize, histFilteredItems.length);
          for (var i = start; i < end; i++) { wrap.append(renderCard(histFilteredItems[i])); }
          $('#historyInfo').text('Hiển thị ' + (histFilteredItems.length > 0 ? (start + 1) : 0) + ' đến ' + end + ' trong tổng số ' + histFilteredItems.length + ' bản ghi');
          updateHistoryPagination();
        }

        // ================== PRICE HISTORY TAB ==================
        var priceAllItems = [];
        var pricePage = 1;
        var pricePageSize = 10;
        var priceTotal = 0;

        function reloadPriceHistory(){
          var urlParams = new URLSearchParams(window.location.search);
          var productId = urlParams.get('productId');
          var type = $('#priceType').val();
          var q = ($('#priceSearchKeyword').val()||'').trim();
          // Backend priceHistory không hỗ trợ q, ta lọc client theo productCode/Name nếu cần sau này
          var params = { action: 'priceHistory', page: pricePage, pageSize: pricePageSize };
          if (productId) params.productId = productId;
          if (type) params.type = type;
          if (q) params.q = q;
          $.getJSON('<%=request.getContextPath()%>/product', params, function(res){
            var body = $('#priceHistoryBody'); body.empty();
            if (!res || !res.success){ body.html('<tr><td colspan="7" class="text-center">Không tải được dữ liệu</td></tr>'); return; }
            priceAllItems = res.data || [];
            priceTotal = res.totalCount || priceAllItems.length;
            renderPriceHistoryServer(res);
          }).fail(function(){ $('#priceHistoryBody').html('<tr><td colspan="7" class="text-center">Lỗi kết nối</td></tr>'); });
        }

        function renderPriceHistoryServer(meta){
          var body = $('#priceHistoryBody'); body.empty();
          if (priceAllItems.length === 0){ body.html('<tr><td colspan="7" class="text-center">Không có dữ liệu</td></tr>'); updatePricePagination(); $('#priceHistoryInfo').text('0 bản ghi'); return; }
          priceAllItems.forEach(function(h){ body.append(renderPriceRow(h)); });
          var start = (meta.currentPage - 1) * meta.pageSize + (priceAllItems.length>0?1:0);
          var end = (meta.currentPage - 1) * meta.pageSize + priceAllItems.length;
          $('#priceHistoryInfo').text('Hiển thị ' + (priceTotal>0?start:0) + ' đến ' + end + ' trong tổng số ' + priceTotal + ' bản ghi');
          updatePricePagination(meta.totalPages);
        }

        function renderPriceRow(h){
          var when = h.updatedAt ? new Date(h.updatedAt).toLocaleString('vi-VN') : '';
          var typeText = h.priceType === 'purchase' ? 'Giá mua' : (h.priceType === 'selling' ? 'Giá bán' : h.priceType||'');
          return '<tr>'+
            '<td>'+ when +'</td>'+
            '<td>'+ escapeHtml(h.productName||'') + ' <span class="muted">' + escapeHtml(h.productCode||'') + '</span></td>'+
            '<td>'+ typeText +'</td>'+
            '<td>'+ (h.oldPrice==null? '—' : formatCurrencyVN(h.oldPrice)) +'</td>'+
            '<td>'+ (h.newPrice==null? '—' : formatCurrencyVN(h.newPrice)) +'</td>'+
            '<td>'+ escapeHtml(h.updatedByName||'') +'</td>'+
            '<td>'+ escapeHtml(h.reason||'') +'</td>'+
          '</tr>';
        }

        function updatePricePagination(totalPages){
          var ul = $('#priceHistoryPagination'); ul.empty();
          var prev = $('<li class="paginate_button ' + (pricePage <= 1 ? 'disabled' : '') + '"><a href="#">Trước</a></li>');
          prev.on('click', function(e){ e.preventDefault(); if (pricePage > 1) { pricePage--; reloadPriceHistory(); } });
          ul.append(prev);
          var maxVisible = 5;
          var start = Math.max(1, pricePage - Math.floor(maxVisible/2));
          var end = Math.min(totalPages, start + maxVisible - 1);
          if (end - start + 1 < maxVisible) start = Math.max(1, end - maxVisible + 1);
          for (var p = start; p <= end; p++) {
            (function(page){
              var li = $('<li class="paginate_button ' + (page === pricePage ? 'active' : '') + '"><a href="#">' + page + '</a></li>');
              li.on('click', function(e){ e.preventDefault(); pricePage = page; reloadPriceHistory(); });
              ul.append(li);
            })(p);
          }
          var next = $('<li class="paginate_button ' + (pricePage >= totalPages ? 'disabled' : '') + '"><a href="#">Tiếp</a></li>');
          next.on('click', function(e){ e.preventDefault(); if (pricePage < totalPages) { pricePage++; reloadPriceHistory(); } });
          ul.append(next);
        }

        function resetPriceFilters(){ $('#priceSearchKeyword').val(''); $('#priceType').val(''); reloadPriceHistory(); }

         // Render theo dữ liệu phân trang từ server
         function renderHistoryServerPage(totalCount, totalPages){
           var wrap = $('#historyContainer'); wrap.empty();
           if (histFilteredItems.length === 0) { wrap.html('<div class="text-center muted">Không có bản ghi</div>'); updateHistoryPaginationServer(totalCount, totalPages); return; }
           for (var i = 0; i < histFilteredItems.length; i++) { wrap.append(renderCard(histFilteredItems[i])); }
           var start = (histPage - 1) * histPageSize + (histFilteredItems.length>0?1:0);
           var end = (histPage - 1) * histPageSize + histFilteredItems.length;
           $('#historyInfo').text('Hiển thị ' + (totalCount>0?start:0) + ' đến ' + end + ' trong tổng số ' + totalCount + ' bản ghi');
           updateHistoryPaginationServer(totalCount, totalPages);
         }

        //  - Cập nhật nút phân trang
         function updateHistoryPagination() {
          var totalPages = Math.ceil(histFilteredItems.length / histPageSize) || 1;
          var ul = $('#historyPagination'); ul.empty();
          var prev = $('<li class="paginate_button ' + (histPage <= 1 ? 'disabled' : '') + '"><a href="#">Trước</a></li>');
          prev.on('click', function (e) { e.preventDefault(); if (histPage > 1) { histPage--; renderHistoryPage(); } });
          ul.append(prev);
          var maxVisible = 5;
          var start = Math.max(1, histPage - Math.floor(maxVisible / 2));
          var end = Math.min(totalPages, start + maxVisible - 1);
          if (end - start + 1 < maxVisible) start = Math.max(1, end - maxVisible + 1);
          for (var p = start; p <= end; p++) {
            (function (page) {
              var li = $('<li class="paginate_button ' + (page === histPage ? 'active' : '') + '"><a href="#">' + page + '</a></li>');
              li.on('click', function (e) { e.preventDefault(); histPage = page; renderHistoryPage(); });
              ul.append(li);
            })(p);
          }
          var next = $('<li class="paginate_button ' + (histPage >= totalPages ? 'disabled' : '') + '"><a href="#">Tiếp</a></li>');
          next.on('click', function (e) { e.preventDefault(); if (histPage < totalPages) { histPage++; renderHistoryPage(); } });
          ul.append(next);
        }

         function updateHistoryPaginationServer(totalCount, totalPages){
           var ul = $('#historyPagination'); ul.empty();
           var prev = $('<li class="paginate_button ' + (histPage <= 1 ? 'disabled' : '') + '"><a href="#">Trước</a></li>');
           prev.on('click', function (e) { e.preventDefault(); if (histPage > 1) { histPage--; reloadHistory(); } });
           ul.append(prev);
           var maxVisible = 5;
           var start = Math.max(1, histPage - Math.floor(maxVisible / 2));
           var end = Math.min(totalPages, start + maxVisible - 1);
           if (end - start + 1 < maxVisible) start = Math.max(1, end - maxVisible + 1);
           for (var p = start; p <= end; p++) {
             (function (page) {
               var li = $('<li class="paginate_button ' + (page === histPage ? 'active' : '') + '"><a href="#">' + page + '</a></li>');
               li.on('click', function (e) { e.preventDefault(); histPage = page; reloadHistory(); });
               ul.append(li);
             })(p);
           }
           var next = $('<li class="paginate_button ' + (histPage >= totalPages ? 'disabled' : '') + '"><a href="#">Tiếp</a></li>');
           next.on('click', function (e) { e.preventDefault(); if (histPage < totalPages) { histPage++; reloadHistory(); } });
           ul.append(next);
         }
      </script>
    </body>

    </html>