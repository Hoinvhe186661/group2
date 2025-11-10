<%@ page contentType="text/html; charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Hợp đồng & Sản phẩm của tôi</title>
	<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
	<style>
		:root { --primary-red:#dc3545; --text-dark:#343a40; }
		.page-wrap { padding: 24px; }
		.section-title { font-weight: 700; margin: 0; color: var(--text-dark); letter-spacing:.2px; }
		.card { border: 1px solid #e9ecef; border-radius: 12px; box-shadow: 0 4px 16px rgba(0,0,0,0.04); }
		.card-header { background: #ffffff; border-bottom: 1px solid #eef0f2; border-radius: 12px 12px 0 0; padding: 14px 16px; }
		.header-inline { display:flex; align-items:center; gap:12px; }
		.header-inline .form-control { max-width: 55%; border-radius: 8px; }
		.header-inline .badge { background: var(--primary-red); }
		.empty { color: #9aa0a6; }
		.key { color:#6b7280; width: 180px; display:inline-block; font-weight:500; }
		.value { color:#111827; }
		.contract-list, .items-list { max-height: 320px; overflow: auto; }
		.list-item { cursor: pointer; padding: 12px 14px; border-bottom: 1px solid #f1f3f5; transition: background .15s ease; }
		.list-item:hover { background: #fffafa; }
		.list-item.active { background: #fff0f0; border-left: 3px solid var(--primary-red); }
		.meta { color:#6c757d; font-size: 12px; }
		code.badge { background: #ffe5e7; color: #b91c1c; border-radius: 4px; padding: 2px 6px; }
		.icon-title { color: var(--primary-red); }
	</style>
</head>
<body>
<jsp:include page="header.jsp"/>
<div class="container-fluid page-wrap">
	<div class="d-flex align-items-center justify-content-between mb-3">
		<h3 class="m-0"><i class="fa-solid fa-file-signature icon-title"></i> Hợp đồng & Sản phẩm của tôi</h3>
		<div class="text-muted">Xem danh sách hợp đồng bạn sở hữu, chi tiết và sản phẩm trong từng hợp đồng</div>
	</div>

	<div class="row">
		<div class="col-md-4">
			<div class="card">
				<div class="card-header">
					<div class="header-inline justify-content-between w-100">
						<span class="section-title"><i class="fa-regular fa-rectangle-list"></i> Hợp đồng của tôi</span>
						<input id="searchContracts" type="text" class="form-control form-control-sm" placeholder="Tìm theo số / tiêu đề">
					</div>
				</div>
				<div class="card-body p-0">
					<div id="contractsList" class="contract-list"></div>
				</div>
			</div>
		</div>
		<div class="col-md-8">
			<div class="card mb-3">
				<div class="card-header">
					<span class="section-title"><i class="fa-solid fa-circle-info"></i> Chi tiết hợp đồng</span>
				</div>
				<div class="card-body" id="contractDetail">
					<p class="empty m-0">Chọn một hợp đồng để xem chi tiết.</p>
				</div>
			</div>
			<div class="card">
				<div class="card-header d-flex justify-content-between align-items-center">
					<span class="section-title"><i class="fa-solid fa-boxes-stacked"></i> Sản phẩm trong hợp đồng</span>
					<input id="searchItems" type="text" class="form-control form-control-sm" placeholder="Lọc sản phẩm" style="max-width: 40%;">
				</div>
				<div class="card-body">
					<div id="itemsList" class="items-list"></div>
				</div>
			</div>
			<div class="card mt-3">
				<div class="card-header">
					<span class="section-title"><i class="fa-solid fa-box-open"></i> Chi tiết sản phẩm</span>
				</div>
				<div class="card-body" id="productDetail">
					<p class="empty m-0">Chọn một sản phẩm để xem chi tiết.</p>
				</div>
			</div>
		</div>
	</div>
</div>

<jsp:include page="footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
	(function() {
		let contracts = [];
		let filteredContracts = [];
		let currentContractId = null;
		let contractItems = [];
		let filteredItems = [];

		const $contractsList = $("#contractsList");
		const $contractDetail = $("#contractDetail");
		const $itemsList = $("#itemsList");
		const $productDetail = $("#productDetail");

		function fmtMoney(v) {
			if (v === null || v === undefined) return '';
			try { return Number(v).toLocaleString('vi-VN'); } catch (e) { return v; }
		}
		function htmlEscape(s) {
			if (s == null) return '';
			return String(s)
				.replace(/&/g, "&amp;")
				.replace(/</g, "&lt;")
				.replace(/>/g, "&gt;")
				.replace(/"/g, "&quot;")
				.replace(/'/g, "&#039;");
		}

		function loadContracts() {
			// API đã lọc theo customerId từ session nếu user là customer
			$.getJSON("<c:url value='/api/contracts'/>", function(resp) {
				if (!resp || !resp.success) {
					$contractsList.html('<div class="p-3 text-danger">Không tải được danh sách hợp đồng.</div>');
					return;
				}
				contracts = resp.data || [];
				filteredContracts = contracts.slice();
				renderContracts();
				// Tự chọn hợp đồng đầu tiên nếu có
				if (filteredContracts.length > 0) {
					selectContract(filteredContracts[0].id);
				} else {
					$contractDetail.html('<p class="empty m-0">Bạn chưa có hợp đồng nào.</p>');
					$itemsList.empty();
					$productDetail.html('<p class="empty m-0">Chọn một sản phẩm để xem chi tiết.</p>');
				}
			}).fail(function() {
				$contractsList.html('<div class="p-3 text-danger">Lỗi kết nối tới máy chủ.</div>');
			});
		}

		function renderContracts() {
			if (!filteredContracts.length) {
				$contractsList.html('<div class="p-3 empty">Không có hợp đồng phù hợp.</div>');
				return;
			}
			const html = filteredContracts.map(c => {
				const id = c.id;
				const active = id === currentContractId ? "active" : "";
				return (
					'<div class="list-item ' + active + '" data-id="' + id + '">' +
						'<div><strong>' + htmlEscape(c.contractNumber) + '</strong></div>' +
						'<div class="meta">' + htmlEscape(c.title || '') + '</div>' +
						'<div class="meta">Từ ' + htmlEscape(c.startDate || '') + ' đến ' + htmlEscape(c.endDate || '') + '</div>' +
						'<div class="meta">Trạng thái: <code class="badge">' + htmlEscape(c.status || '') + '</code></div>' +
					'</div>'
				);
			}).join("");
			$contractsList.html(html);
		}

		function selectContract(id) {
			currentContractId = id;
			renderContracts();
			const c = contracts.find(x => x.id === id);
			if (!c) return;
			$contractDetail.html(
				'<div class="row">' +
					'<div class="col-md-6">' +
						'<div><span class="key">Số hợp đồng:</span> <span class="value">' + htmlEscape(c.contractNumber) + '</span></div>' +
						'<div><span class="key">Tiêu đề:</span> <span class="value">' + htmlEscape(c.title || '') + '</span></div>' +
						'<div><span class="key">Loại hợp đồng:</span> <span class="value">' + htmlEscape(c.contractType || '') + '</span></div>' +
						'<div><span class="key">Giá trị:</span> <span class="value">' + fmtMoney(c.contractValue) + ' ₫</span></div>' +
					'</div>' +
					'<div class="col-md-6">' +
						'<div><span class="key">Khách hàng:</span> <span class="value">' + htmlEscape(c.customerName || '') + '</span></div>' +
						'<div><span class="key">Điện thoại:</span> <span class="value">' + htmlEscape(c.customerPhone || '') + '</span></div>' +
						'<div><span class="key">Từ ngày:</span> <span class="value">' + htmlEscape(c.startDate || '') + '</span></div>' +
						'<div><span class="key">Đến ngày:</span> <span class="value">' + htmlEscape(c.endDate || '') + '</span></div>' +
					'</div>' +
				'</div>' +
				'<div class="mt-2"><span class="key">Điều khoản:</span><div class="value">' + (htmlEscape(c.terms || '').replace(/\n/g, '<br>')) + '</div></div>'
			);
			loadContractItems(id);
		}

		function loadContractItems(contractId) {
			$itemsList.html('<div class="p-3">Đang tải sản phẩm...</div>');
			$productDetail.html('<p class="empty m-0">Chọn một sản phẩm để xem chi tiết.</p>');
			$.getJSON("<c:url value='/api/contract-items'/>", { contractId: contractId }, function(resp) {
				if (!resp || !resp.success) {
					$itemsList.html('<div class="p-3 text-danger">Không tải được sản phẩm.</div>');
					return;
				}
				contractItems = resp.data || [];
				filteredItems = contractItems.slice();
				renderItems();
			}).fail(function() {
				$itemsList.html('<div class="p-3 text-danger">Lỗi kết nối tới máy chủ.</div>');
			});
		}

		function renderItems() {
			if (!filteredItems.length) {
				$itemsList.html('<div class="p-3 empty">Không có sản phẩm trong hợp đồng này.</div>');
				return;
			}
			const html = filteredItems.map((it, idx) => {
				const qty = it.quantity != null ? it.quantity : '';
				const price = it.unitPrice != null ? fmtMoney(it.unitPrice) + ' ₫' : '';
				const warranty = (it.warrantyMonths == null || it.warrantyMonths === '') ? '—' : (it.warrantyMonths + ' tháng');
				return (
					'<div class="list-item" data-product-id="' + it.productId + '">' +
						'<div><strong>#' + (idx + 1) + '</strong> - Sản phẩm ID: ' + it.productId + '</div>' +
						'<div class="meta">SL: ' + qty + ' | Giá: ' + price + ' | BH: ' + warranty + '</div>' +
						(it.description ? ('<div class="meta">Mô tả: ' + htmlEscape(it.description) + '</div>') : '') +
					'</div>'
				);
			}).join("");
			$itemsList.html(html);
		}

		function loadProductDetail(productId) {
			$productDetail.html('<div>Đang tải chi tiết sản phẩm...</div>');
			$.getJSON("<c:url value='/product'/>", { action: "view", id: productId }, function(resp) {
				if (!resp || !resp.success || !resp.product) {
					$productDetail.html('<div class="text-danger">Không tải được chi tiết sản phẩm.</div>');
					return;
				}
				const p = resp.product;
				const img = p.imageUrl ? ('<img src="' + htmlEscape(p.imageUrl) + '" alt="" style="max-width:140px;max-height:140px;border:1px solid #eee;border-radius:6px;margin-right:12px;">') : '';
				$productDetail.html(
					'<div class="d-flex">' +
						img +
						'<div>' +
							'<div><span class="key">Mã sản phẩm:</span> <span class="value">' + htmlEscape(p.productCode) + '</span></div>' +
							'<div><span class="key">Tên sản phẩm:</span> <span class="value">' + htmlEscape(p.productName) + '</span></div>' +
							'<div><span class="key">Danh mục:</span> <span class="value">' + htmlEscape(p.category) + '</span></div>' +
							'<div><span class="key">Giá bán:</span> <span class="value">' + fmtMoney(p.unitPrice) + ' ₫</span></div>' +
							'<div><span class="key">Bảo hành:</span> <span class="value">' + (p.warrantyMonths || 0) + ' tháng</span></div>' +
							(p.description ? ('<div class="mt-2"><span class="key">Mô tả:</span><div class="value">' + htmlEscape(p.description).replace(/\n/g, '<br>') + '</div></div>') : '') +
							(p.specifications ? ('<div class="mt-2"><span class="key">Thông số:</span><div class="value">' + htmlEscape(p.specifications).replace(/\n/g, '<br>') + '</div></div>') : '') +
						'</div>' +
					'</div>'
				);
			}).fail(function() {
				$productDetail.html('<div class="text-danger">Lỗi kết nối khi tải chi tiết sản phẩm.</div>');
			});
		}

		// Events
		$contractsList.on("click", ".list-item", function() {
			const id = parseInt($(this).attr("data-id"), 10);
			if (!isNaN(id)) selectContract(id);
		});
		$itemsList.on("click", ".list-item", function() {
			const productId = parseInt($(this).attr("data-product-id"), 10);
			if (!isNaN(productId)) loadProductDetail(productId);
		});
		$("#searchContracts").on("input", function() {
			const q = $(this).val().toLowerCase();
			filteredContracts = contracts.filter(c => {
				const number = (c.contractNumber || '').toLowerCase();
				const title = (c.title || '').toLowerCase();
				return number.includes(q) || title.includes(q);
			});
			renderContracts();
		});
		$("#searchItems").on("input", function() {
			const q = $(this).val().toLowerCase();
			filteredItems = contractItems.filter(it => {
				const d = (it.description || '').toLowerCase();
				const n = String(it.productId || '').toLowerCase();
				return d.includes(q) || n.includes(q);
			});
			renderItems();
		});

		// Init
		loadContracts();
	})();
</script>
</body>
</html>


