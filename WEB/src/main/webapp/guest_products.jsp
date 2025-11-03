<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Máy phát điện | HOÀ LẠC ELECTRIC</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-red: #dc3545;
            --primary-yellow: #ffc107;
            --dark-grey: #343a40;
            --light-grey: #f8f9fa;
            --white: #ffffff;
        }

        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f5f5f5;
        }

        /* Product Page Styles */
        .products-page {
            padding: 30px 0;
            background-color: #f5f5f5;
        }

        .filter-sidebar {
            background: #ffffff;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .filter-section {
            margin-bottom: 25px;
        }

        .filter-section:last-child {
            margin-bottom: 0;
        }
        
        .filter-section-content {
            max-height: 400px;
            overflow-y: auto;
        }
        
        .filter-section-content::-webkit-scrollbar {
            width: 6px;
        }
        
        .filter-section-content::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 10px;
        }
        
        .filter-section-content::-webkit-scrollbar-thumb {
            background: #dc3545;
            border-radius: 10px;
        }
        
        .filter-section-content::-webkit-scrollbar-thumb:hover {
            background: #c82333;
        }

        .filter-title {
            background-color: var(--primary-red);
            color: var(--white);
            padding: 10px 15px;
            font-weight: 600;
            font-size: 16px;
            margin: -20px -20px 15px -20px;
            border-radius: 8px 8px 0 0;
        }

        .filter-item {
            padding: 8px 0;
            cursor: pointer;
            color: #333;
            transition: color 0.3s;
        }

        .filter-item:hover {
            color: var(--primary-red);
        }

        .filter-item input[type="checkbox"],
        .filter-item input[type="radio"] {
            margin-right: 8px;
            cursor: pointer;
        }
        
        .filter-item label {
            cursor: pointer;
            user-select: none;
        }

        .see-more-link {
            color: var(--primary-red);
            text-decoration: none;
            font-size: 14px;
            display: block;
            margin-top: 10px;
            cursor: pointer;
            font-weight: 500;
        }

        .see-more-link:hover {
            text-decoration: underline;
            color: #c82333;
        }
        
        .see-more-link:active {
            color: #bd2130;
        }

        /* Product Cards */
        .products-container {
            background: #ffffff;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .sorting-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }

        .sorting-links {
            display: flex;
            gap: 20px;
        }

        .sorting-links a {
            color: #666;
            text-decoration: none;
            font-size: 14px;
            cursor: pointer;
            transition: color 0.3s;
        }

        .sorting-links a:hover,
        .sorting-links a.active {
            color: var(--primary-red);
            font-weight: 600;
        }

        .search-btn {
            background-color: var(--primary-red);
            color: var(--white);
            border: none;
            padding: 8px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
            transition: background-color 0.3s;
        }

        .search-btn:hover {
            background-color: #c82333;
        }

        .product-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        @media (max-width: 992px) {
            .product-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .product-grid {
                grid-template-columns: 1fr;
            }
        }

        .product-card {
            background: #ffffff;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .product-image {
            width: 100%;
            height: 250px;
            object-fit: cover;
            background-color: #f0f0f0;
            display: block;
        }
        
        .product-image-wrapper {
            width: 100%;
            height: 250px;
            overflow: hidden;
            background-color: #f8f9fa;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .product-info {
            padding: 15px;
        }

        .product-title {
            font-size: 16px;
            font-weight: 600;
            color: var(--dark-grey);
            margin-bottom: 10px;
            min-height: 48px;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            line-clamp: 2;
            -webkit-box-orient: vertical;
        }

        .product-description {
            font-size: 14px;
            color: #666;
            margin-bottom: 15px;
            min-height: 60px;
            max-height: 80px;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            line-clamp: 3;
            -webkit-box-orient: vertical;
            line-height: 1.5;
        }
        
        .product-price {
            font-size: 18px;
            font-weight: 700;
            color: var(--primary-red);
            margin-bottom: 10px;
        }

        .product-link {
            color: var(--primary-red);
            text-decoration: none;
            font-weight: 500;
            font-size: 14px;
        }

        .product-link:hover {
            text-decoration: underline;
        }

        /* Pagination */
        .pagination-container {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            margin-top: 30px;
        }

        .pagination-btn {
            padding: 8px 16px;
            border: 1px solid #ddd;
            background: #ffffff;
            color: #333;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s;
            font-family: inherit;
            font-size: inherit;
        }

        .pagination-btn:hover:not(.disabled) {
            background-color: var(--primary-red);
            color: var(--white);
            border-color: var(--primary-red);
        }

        .pagination-btn.disabled,
        .pagination-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .pagination-btn.active {
            background-color: var(--primary-red);
            color: var(--white);
            border-color: var(--primary-red);
        }

        .no-products {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }

        .no-products i {
            font-size: 64px;
            color: #ccc;
            margin-bottom: 20px;
        }

        .price-range-input {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-bottom: 10px;
        }

        .hidden-price-range {
            display: none;
        }
        
        .hidden-supplier {
            display: none;
        }
    </style>
    <script>
        // Định nghĩa các hàm toggle trước để có thể gọi từ onclick trong HTML
        // Toggle price ranges visibility
        function togglePriceRanges() {
            const hiddenPriceRanges = document.querySelectorAll('.hidden-price-range');
            if (hiddenPriceRanges.length === 0) {
                console.log('No hidden price ranges found');
                return;
            }
            
            const isHidden = hiddenPriceRanges[0].style.display === 'none' || 
                            window.getComputedStyle(hiddenPriceRanges[0]).display === 'none';
            hiddenPriceRanges.forEach(function(item) {
                item.style.display = isHidden ? 'block' : 'none';
            });
            
            const seeMoreLink = document.getElementById('seeMorePrice');
            if (seeMoreLink) {
                seeMoreLink.textContent = isHidden ? 'Thu gọn' : 'Xem thêm';
            }
        }
        
        // Toggle suppliers visibility
        function toggleSuppliers() {
            const hidden = document.querySelectorAll('.hidden-supplier');
            if (hidden.length === 0) {
                console.log('No hidden suppliers found');
                return;
            }
            
            const isHidden = window.getComputedStyle(hidden[0]).display === 'none';
            hidden.forEach(function(item) {
                item.style.display = isHidden ? 'block' : 'none';
            });
            
            const seeMoreLink = document.getElementById('seeMoreSupplier');
            if (seeMoreLink) {
                seeMoreLink.textContent = isHidden ? 'Thu gọn' : 'Xem thêm';
            }
        }
    </script>
</head>
<body>
    <!-- Include Header -->
    <jsp:include page="header.jsp" />

    <!-- Products Page Content -->
    <div class="products-page">
        <div class="container">
            <div class="row">
                <!-- Left Sidebar Filters -->
                <div class="col-lg-3 col-md-4">
                    <div class="filter-sidebar">
                        <!-- Price Range Filter -->
                        <div class="filter-section">
                            <div class="filter-title">KHOẢNG GIÁ</div>
                            <div class="filter-item">
                                <input type="radio" name="priceRange" id="price1" value="8000000-10000000">
                                <label for="price1">8-10 triệu</label>
                            </div>
                            <div class="filter-item">
                                <input type="radio" name="priceRange" id="price2" value="10000000-15000000">
                                <label for="price2">10-15 triệu</label>
                            </div>
                            <div class="filter-item hidden-price-range">
                                <input type="radio" name="priceRange" id="price3" value="15000000-20000000">
                                <label for="price3">15-20 triệu</label>
                            </div>
                            <div class="filter-item hidden-price-range">
                                <input type="radio" name="priceRange" id="price4" value="20000000-25000000">
                                <label for="price4">20-25 triệu</label>
                            </div>
                            <div class="filter-item hidden-price-range">
                                <input type="radio" name="priceRange" id="price5" value="25000000-30000000">
                                <label for="price5">25-30 triệu</label>
                            </div>
                            <a href="javascript:void(0);" class="see-more-link" id="seeMorePrice" onclick="togglePriceRanges()">Xem thêm</a>
                        </div>

                        <!-- Supplier Filter -->
                        <div class="filter-section">
                            <div class="filter-title">NHÀ CUNG CẤP</div>
                            <div class="filter-section-content" id="supplierFilters" data-suppliers='<c:choose><c:when test="${not empty suppliers}"><c:forEach var="supplier" items="${suppliers}" varStatus="status">{&quot;id&quot;:${supplier.id},&quot;name&quot;:&quot;<c:out value="${fn:escapeXml(supplier.companyName)}" />&quot;}<c:if test="${!status.last}">,</c:if></c:forEach></c:when></c:choose>'>
                                <c:choose>
                                    <c:when test="${not empty suppliers}">
                                        <c:forEach var="supplier" items="${suppliers}" varStatus="status">
                                            <div class="filter-item <c:if test="${status.index >= 5}">hidden-supplier</c:if>">
                                                <input type="checkbox" name="supplier" id="supplier${supplier.id}" value="${supplier.id}">
                                                <label for="supplier${supplier.id}"><c:out value="${supplier.companyName}" /></label>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="filter-item" style="color: #999; font-style: italic;">Chưa có nhà cung cấp nào</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <c:if test="${fn:length(suppliers) > 5}">
                                <a href="javascript:void(0);" class="see-more-link" id="seeMoreSupplier" onclick="toggleSuppliers()">Xem thêm</a>
                            </c:if>
                        </div>
                    </div>
                </div>

                <!-- Main Products Area -->
                <div class="col-lg-9 col-md-8">
                    <div class="products-container">
                        <!-- Sorting Bar -->
                        <div class="sorting-bar">
                            <div class="sorting-links">
                                <a href="#" class="sort-link active" data-sort="all">Toàn bộ sản phẩm</a>
                                <a href="#" class="sort-link" data-sort="price_asc">Giá tăng dần</a>
                                <a href="#" class="sort-link" data-sort="price_desc">Giá giảm dần</a>
                            </div>
                            <button class="search-btn" onclick="applyFilters()">
                                <i class="fas fa-search"></i> Tìm kiếm
                            </button>
                        </div>

                        <!-- Product Grid -->
                        <div class="product-grid" id="productGrid">
                            <c:choose>
                                <c:when test="${not empty products}">
                                    <c:forEach var="product" items="${products}" varStatus="status" begin="0" end="8">
                                        <div class="product-card">
                                            <div class="product-image-wrapper">
                                                <c:choose>
                                                    <c:when test="${not empty product.imageUrl and product.imageUrl != 'null' and product.imageUrl != ''}">
                                                        <c:set var="imgUrl" value="${product.imageUrl}" />
                                                        <c:if test="${not fn:startsWith(imgUrl, 'http') and not fn:startsWith(imgUrl, '/')}">
                                                            <c:set var="imgUrl" value="${pageContext.request.contextPath}/${imgUrl}" />
                                                        </c:if>
                                                        <c:if test="${fn:startsWith(imgUrl, '/') and not fn:startsWith(imgUrl, pageContext.request.contextPath)}">
                                                            <c:set var="imgUrl" value="${pageContext.request.contextPath}${imgUrl}" />
                                                        </c:if>
                                                        <img src="${imgUrl}" alt="${product.productName}" class="product-image" data-fallback="${pageContext.request.contextPath}/images/sanpham1.jpg">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="${pageContext.request.contextPath}/images/sanpham1.jpg" alt="${product.productName}" class="product-image">
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="product-info">
                                                <div class="product-title">${product.productName}</div>
                                                <c:if test="${product.unitPrice > 0}">
                                                    <div class="product-price">
                                                        <fmt:formatNumber value="${product.unitPrice}" type="number" maxFractionDigits="0"/> VNĐ
                                                    </div>
                                                </c:if>
                                                <div class="product-description">
                                                    <c:choose>
                                                        <c:when test="${not empty product.description and product.description != 'null'}">
                                                            ${fn:substring(product.description, 0, 150)}${fn:length(product.description) > 150 ? '...' : ''}
                                                        </c:when>
                                                        <c:otherwise>
                                                            Sản phẩm chất lượng cao từ ${not empty product.supplierName ? product.supplierName : 'nhà cung cấp uy tín'}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <a href="${pageContext.request.contextPath}/guest-products?action=detail&id=${product.id}" class="product-link">Xem thêm</a>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="no-products">
                                        <i class="fas fa-box-open"></i>
                                        <p>Không có sản phẩm nào</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Pagination -->
                        <div class="pagination-container" id="paginationContainer" 
                             data-total-products="${fn:length(products)}"
                             data-total-pages="${totalProducts > 9 ? ((totalProducts + 8) / 9) : 1}">
                            <button type="button" class="pagination-btn" id="prevBtn" onclick="changePage(-1)">
                                Trước
                            </button>
                            <c:set var="totalProducts" value="${fn:length(products)}" />
                            <c:set var="totalPages" value="${totalProducts > 9 ? ((totalProducts + 8) / 9) : 1}" />
                            <c:if test="${totalPages > 1}">
                                <c:forEach var="i" begin="1" end="${totalPages > 5 ? 5 : totalPages}">
                                    <button type="button" class="pagination-btn <c:if test="${i == 1}">active</c:if>" onclick="goToPage(${i})">${i}</button>
                                </c:forEach>
                            </c:if>
                            <button type="button" class="pagination-btn" id="nextBtn" onclick="changePage(1)" <c:if test="${totalPages <= 1}">disabled</c:if>>
                                Tiếp
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Include Footer -->
    <jsp:include page="footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Lấy context path từ JSP
        const contextPath = '${pageContext.request.contextPath}';
        
        let currentPage = 1;
        let currentSort = 'all';
        let currentPriceRange = null;
        let currentSuppliers = [];

        // Load all suppliers for filter
        function loadAllSuppliers() {
            const supplierFilters = document.getElementById('supplierFilters');
            if (!supplierFilters) return;
            
            // Kiểm tra xem đã có suppliers trong HTML chưa (từ server render)
            const existingSuppliers = supplierFilters.querySelectorAll('.filter-item input[type="checkbox"]');
            if (existingSuppliers.length > 0) {
                // Đã có suppliers từ server, chỉ cần đảm bảo "Xem thêm" link hiển thị đúng
                const hiddenSuppliers = supplierFilters.querySelectorAll('.hidden-supplier');
                const seeMoreLink = document.getElementById('seeMoreSupplier');
                if (seeMoreLink && hiddenSuppliers.length > 0) {
                    seeMoreLink.style.display = 'block';
                }
                return; // Không cần làm gì thêm
            }
            
            // Nếu không có suppliers trong HTML, thử load từ data attribute
            const suppliersData = supplierFilters.getAttribute('data-suppliers');
            if (!suppliersData || suppliersData.trim() === '') {
                console.warn('No supplier data found');
                return;
            }
            
            try {
                const suppliers = JSON.parse('[' + suppliersData + ']');
                
                if (!suppliers || suppliers.length === 0) {
                    supplierFilters.innerHTML = '<div class="filter-item" style="color: #999; font-style: italic;">Chưa có nhà cung cấp nào</div>';
                    return;
                }
                
                // Clear existing content
                supplierFilters.innerHTML = '';
                
                // Hiển thị tất cả nhà cung cấp, ẩn những cái sau 5
                suppliers.forEach((supplier, index) => {
                    const div = document.createElement('div');
                    div.className = 'filter-item';
                    if (index >= 5) {
                        div.classList.add('hidden-supplier');
                    }
                    div.innerHTML = `
                        <input type="checkbox" name="supplier" id="supplier${supplier.id}" value="${supplier.id}">
                        <label for="supplier${supplier.id}">${supplier.name || 'Nhà cung cấp ' + supplier.id}</label>
                    `;
                    supplierFilters.appendChild(div);
                });
                
                // Update "Xem thêm" link visibility và onclick
                const seeMoreLink = document.getElementById('seeMoreSupplier');
                if (seeMoreLink) {
                    seeMoreLink.style.display = suppliers.length > 5 ? 'block' : 'none';
                    if (suppliers.length > 5) {
                        seeMoreLink.setAttribute('onclick', 'toggleSuppliers()');
                        seeMoreLink.href = 'javascript:void(0);';
                    }
                }
            } catch (e) {
                console.error('Error parsing supplier data:', e);
                console.log('Supplier data:', suppliersData);
                // Giữ nguyên HTML hiện tại nếu có lỗi parse
            }
        }

        // Setup event listeners (backup method)
        function setupSeeMoreLinks() {
            // Các hàm toggle đã được gọi trực tiếp từ onclick trong HTML
            // Hàm này chỉ để đảm bảo compatibility
        }

        // Sorting
        document.querySelectorAll('.sort-link').forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                document.querySelectorAll('.sort-link').forEach(l => l.classList.remove('active'));
                this.classList.add('active');
                currentSort = this.dataset.sort;
                applyFilters();
            });
        });

        // Apply filters
        function applyFilters() {
            // Get selected price range
            const priceRadio = document.querySelector('input[name="priceRange"]:checked');
            currentPriceRange = priceRadio ? priceRadio.value : null;

            // Get selected suppliers
            currentSuppliers = Array.from(document.querySelectorAll('input[name="supplier"]:checked'))
                .map(cb => cb.value);

            // Reset to page 1
            currentPage = 1;
            
            // Load products via AJAX
            loadProducts();
        }

        // Load products via AJAX
        function loadProducts() {
            const params = new URLSearchParams();
            params.append('action', 'filter');
            params.append('page', currentPage);
            params.append('pageSize', 9);
            params.append('sortBy', currentSort);
            
            if (currentPriceRange) {
                const [min, max] = currentPriceRange.split('-');
                params.append('priceMin', min);
                params.append('priceMax', max);
            }
            
            // Gửi tất cả suppliers đã chọn, nếu có nhiều thì lấy tất cả
            currentSuppliers.forEach(supplierId => {
                params.append('supplierId', supplierId);
            });

            fetch(contextPath + '/guest-products?' + params.toString())
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        displayProducts(data.products);
                        updatePagination(data.currentPage, data.totalPages);
                    } else {
                        alert('Lỗi: ' + data.message);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Lỗi khi tải sản phẩm');
                });
        }

        // Display products
        function displayProducts(products) {
            const grid = document.getElementById('productGrid');
            
            if (products.length === 0) {
                grid.innerHTML = `
                    <div class="no-products">
                        <i class="fas fa-box-open"></i>
                        <p>Không tìm thấy sản phẩm nào</p>
                    </div>
                `;
                return;
            }

            grid.innerHTML = products.map(product => {
                const imgUrl = product.imageUrl && product.imageUrl !== 'null' 
                    ? (product.imageUrl.startsWith('http') || product.imageUrl.startsWith('/')
                        ? product.imageUrl
                        : contextPath + '/' + product.imageUrl)
                    : contextPath + '/images/sanpham1.jpg';
                
                const description = product.description && product.description !== 'null' ? product.description : 
                    ('Sản phẩm chất lượng cao từ ' + (product.supplierName || 'nhà cung cấp uy tín'));
                const shortDesc = description.length > 150 ? description.substring(0, 150) + '...' : description;

                const price = product.unitPrice && product.unitPrice > 0 
                    ? new Intl.NumberFormat('vi-VN').format(product.unitPrice) + ' VNĐ' 
                    : '';
                
                const priceHtml = price ? `<div class="product-price">${price}</div>` : '';
                
                // Tạo URL chi tiết sản phẩm - đảm bảo product.id là số nguyên
                let productId = '';
                if (product.id !== undefined && product.id !== null) {
                    // Chuyển đổi thành số nguyên để tránh lỗi
                    productId = parseInt(product.id, 10);
                    if (isNaN(productId)) {
                        console.error('Invalid product ID:', product.id);
                        productId = '';
                    }
                } else {
                    console.error('Product ID is missing:', product);
                }
                const detailUrl = contextPath + '/guest-products?action=detail&id=' + productId;
                
                // Debug log
                if (detailUrl.includes(':') && !detailUrl.startsWith('http')) {
                    console.warn('URL contains colon:', detailUrl, 'Product:', product);
                }

                return `
                    <div class="product-card">
                        <div class="product-image-wrapper">
                            <img src="${imgUrl}" alt="${product.productName || ''}" class="product-image" data-fallback="${contextPath}/images/sanpham1.jpg">
                        </div>
                        <div class="product-info">
                            <div class="product-title">${product.productName || ''}</div>
                            ${priceHtml}
                            <div class="product-description">${shortDesc}</div>
                            <a href="${detailUrl}" class="product-link">Xem thêm</a>
                        </div>
                    </div>
                `;
            }).join('');
            
            // Setup image fallbacks for dynamically loaded images
            setupImageFallbacks();
        }

        // Update pagination
        function updatePagination(currentPageNum, totalPages) {
            const container = document.getElementById('paginationContainer');
            currentPage = currentPageNum;
            
            // Store prev and next buttons
            const prevBtn = document.getElementById('prevBtn');
            const nextBtn = document.getElementById('nextBtn');
            
            // Remove all page number buttons (but keep prev/next)
            const pageButtons = container.querySelectorAll('.pagination-btn:not(#prevBtn):not(#nextBtn)');
            pageButtons.forEach(btn => btn.remove());
            
            // Add page numbers between prev and next
            const maxVisible = 5;
            let startPage = Math.max(1, currentPageNum - Math.floor(maxVisible / 2));
            let endPage = Math.min(totalPages, startPage + maxVisible - 1);
            
            if (endPage - startPage + 1 < maxVisible) {
                startPage = Math.max(1, endPage - maxVisible + 1);
            }
            
            // Insert page buttons before next button
            for (let i = startPage; i <= endPage; i++) {
                const pageBtn = document.createElement('button');
                pageBtn.type = 'button';
                pageBtn.className = 'pagination-btn' + (i === currentPageNum ? ' active' : '');
                pageBtn.textContent = i;
                pageBtn.onclick = function() {
                    goToPage(i);
                };
                container.insertBefore(pageBtn, nextBtn);
            }
            
            // Update prev/next buttons
            if (prevBtn) {
                prevBtn.classList.toggle('disabled', currentPageNum <= 1);
                prevBtn.disabled = currentPageNum <= 1;
            }
            if (nextBtn) {
                nextBtn.classList.toggle('disabled', currentPageNum >= totalPages);
                nextBtn.disabled = currentPageNum >= totalPages;
            }
        }

        // Change page
        function changePage(delta) {
            const newPage = currentPage + delta;
            if (newPage >= 1) {
                goToPage(newPage);
            }
        }

        // Go to specific page
        function goToPage(page) {
            currentPage = page;
            loadProducts();
        }

        // Initialize pagination on first load
        function initPagination() {
            const paginationContainer = document.getElementById('paginationContainer');
            if (!paginationContainer) return;
            
            const totalProducts = parseInt(paginationContainer.getAttribute('data-total-products')) || 0;
            const pageSize = 9;
            const totalPages = Math.ceil(totalProducts / pageSize);
            if (totalPages > 1) {
                updatePagination(1, totalPages);
            }
        }

        // Handle image fallback
        function setupImageFallbacks() {
            document.querySelectorAll('.product-image[data-fallback]').forEach(img => {
                img.addEventListener('error', function() {
                    const fallback = this.getAttribute('data-fallback');
                    if (this.src !== fallback) {
                        this.src = fallback;
                    }
                });
            });
        }

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            // Kiểm tra và đảm bảo suppliers được hiển thị
            const supplierFilters = document.getElementById('supplierFilters');
            if (supplierFilters) {
                const existingSuppliers = supplierFilters.querySelectorAll('.filter-item');
                console.log('Existing suppliers count:', existingSuppliers.length);
                if (existingSuppliers.length === 0) {
                    // Nếu không có suppliers, thử load từ data attribute
                    loadAllSuppliers();
                } else {
                    // Đã có suppliers từ server, chỉ cần update UI
                    const hiddenSuppliers = supplierFilters.querySelectorAll('.hidden-supplier');
                    const seeMoreLink = document.getElementById('seeMoreSupplier');
                    if (seeMoreLink) {
                        seeMoreLink.style.display = hiddenSuppliers.length > 0 ? 'block' : 'none';
                    }
                }
            }
            
            // Setup event listeners cho các nút "Xem thêm"
            setupSeeMoreLinks();
            
            initPagination();
            setupImageFallbacks();
        });
    </script>
</body>
</html>

