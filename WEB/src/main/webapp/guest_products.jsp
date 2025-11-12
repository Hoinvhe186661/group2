<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="com.hlgenerator.dao.SettingsDAO" %>
<%@ page import="java.util.Map" %>
<%
    // Luôn load settings mới nhất từ database để đảm bảo hiển thị đúng giá trị đã cập nhật
    SettingsDAO settingsDAO = new SettingsDAO();
    Map<String, String> settings = settingsDAO.getAllSettings();

    String siteName = settings.get("site_name") != null ? settings.get("site_name") : "HOÀ LẠC ELECTRIC";
    String siteDescription = settings.get("site_description") != null ? settings.get("site_description") : "Chuyên cung cấp máy phát điện chính hãng";
    String siteEmail = settings.get("site_email") != null ? settings.get("site_email") : "contact@example.com";
    String sitePhone = settings.get("site_phone") != null ? settings.get("site_phone") : "0989 888 999";
    String siteAddress = settings.get("site_address") != null ? settings.get("site_address") : "";

    pageContext.setAttribute("siteName", siteName);
    pageContext.setAttribute("siteDescription", siteDescription);
    pageContext.setAttribute("siteEmail", siteEmail);
    pageContext.setAttribute("sitePhone", sitePhone);
    pageContext.setAttribute("siteAddress", siteAddress);

    String pageTitle = "Máy phát điện | " + (String) pageContext.getAttribute("siteName");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %></title>
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

        /* Auto-apply filter when checkbox/radio changes - optional */
        .filter-item input[type="checkbox"]:hover,
        .filter-item input[type="radio"]:hover {
            transform: scale(1.1);
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

        .search-container {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .search-input {
            padding: 8px 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            width: 250px;
            transition: border-color 0.3s;
        }

        .search-input:focus {
            outline: none;
            border-color: var(--primary-red);
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

        .filter-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }

        .filter-btn {
            flex: 1;
            background-color: var(--primary-red);
            color: var(--white);
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            transition: background-color 0.3s;
        }

        .filter-btn:hover {
            background-color: #c82333;
        }

        .filter-btn:active {
            background-color: #bd2130;
        }

        .reset-btn {
            flex: 1;
            background-color: #6c757d;
            color: var(--white);
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            transition: background-color 0.3s;
        }

        .reset-btn:hover {
            background-color: #5a6268;
        }

        .reset-btn:active {
            background-color: #545b62;
        }
    </style>
    
    <!-- Script định nghĩa handleSortClick TRƯỚC khi HTML render -->
    <script>
        // Định nghĩa các biến và function ở global scope TRƯỚC
        var currentPage = 1;
        var currentSort = 'all';
        var currentPriceRange = null;
        var currentSearchTerm = '';
        var contextPath = '${pageContext.request.contextPath}';
        
        // Định nghĩa displayProducts TRƯỚC loadProducts
        window.displayProducts = function displayProducts(products) {
            console.log('displayProducts called with:', products);
            const grid = document.getElementById('productGrid');
            if (!grid) {
                console.error('productGrid element not found');
                return;
            }
            
            if (!products || products.length === 0) {
                grid.innerHTML = `
                    <div class="no-products">
                        <i class="fas fa-box-open"></i>
                        <p>Không tìm thấy sản phẩm nào</p>
                    </div>
                `;
                return;
            }

            grid.innerHTML = products.map((product, index) => {
                console.log('Processing product #' + index + ':', product);
                
                // Đảm bảo product là object hợp lệ
                if (!product || typeof product !== 'object') {
                    console.error('Invalid product:', product);
                    return '';
                }
                // Xử lý image URL - đảm bảo không phải boolean false
                let imgUrl = contextPath + '/images/sanpham1.jpg'; // default
                if (product.imageUrl && product.imageUrl !== 'null' && product.imageUrl !== false && product.imageUrl !== 'false') {
                    const img = String(product.imageUrl);
                    if (img.startsWith('http') || img.startsWith('/')) {
                        imgUrl = img;
                    } else {
                        imgUrl = contextPath + '/' + img;
                    }
                }
                
                // Xử lý description
                let description = 'Sản phẩm chất lượng cao từ ' + (product.supplierName || 'nhà cung cấp uy tín');
                if (product.description && product.description !== 'null' && product.description !== false && product.description !== 'false') {
                    description = String(product.description);
                }
                const shortDesc = description.length > 150 ? description.substring(0, 150) + '...' : description;

                // Xử lý price
                let price = '';
                if (product.unitPrice !== undefined && product.unitPrice !== null && product.unitPrice !== false) {
                    const priceNum = parseFloat(product.unitPrice);
                    if (!isNaN(priceNum) && priceNum > 0) {
                        price = new Intl.NumberFormat('vi-VN').format(priceNum) + ' VNĐ';
                    }
                }
                // Tạo priceHtml trực tiếp, không dùng template string
                let priceHtml = '';
                if (price) {
                    priceHtml = '<div class="product-price">' + price + '</div>';
                }
                
                // Xử lý product name
                const productName = (product.productName && product.productName !== false && product.productName !== 'false') 
                    ? String(product.productName) 
                    : 'Sản phẩm';
                
                // Tạo URL chi tiết sản phẩm
                let productId = '';
                if (product.id !== undefined && product.id !== null && product.id !== false) {
                    const idNum = parseInt(product.id, 10);
                    if (!isNaN(idNum)) {
                        productId = idNum;
                    } else {
                        console.error('Invalid product ID:', product.id);
                    }
                } else {
                    console.error('Product ID is missing:', product);
                }
                const detailUrl = contextPath + '/guest-products?action=detail&id=' + productId;

                // Escape HTML để tránh XSS và đảm bảo hiển thị đúng
                const escapeHtml = (text) => {
                    if (text === null || text === undefined || text === false) return '';
                    const str = String(text);
                    const div = document.createElement('div');
                    div.textContent = str;
                    return div.innerHTML;
                };
                
                // Xây dựng HTML bằng cách nối chuỗi để tránh vấn đề với template string
                let html = '<div class="product-card">';
                html += '<div class="product-image-wrapper">';
                html += '<img src="' + escapeHtml(imgUrl) + '" alt="' + escapeHtml(productName) + '" class="product-image" data-fallback="' + escapeHtml(contextPath) + '/images/sanpham1.jpg">';
                html += '</div>';
                html += '<div class="product-info">';
                html += '<div class="product-title">' + escapeHtml(productName) + '</div>';
                html += priceHtml;
                html += '<div class="product-description">' + escapeHtml(shortDesc) + '</div>';
                html += '<a href="' + escapeHtml(detailUrl) + '" class="product-link">Xem thêm</a>';
                html += '</div>';
                html += '</div>';
                
                return html;
            }).join('');
            
            // Setup image fallbacks for dynamically loaded images
            if (typeof setupImageFallbacks === 'function') {
                setupImageFallbacks();
            }
        };

        // Định nghĩa updatePagination TRƯỚC loadProducts
        window.updatePagination = function updatePagination(currentPageNum, totalPages) {
            const container = document.getElementById('paginationContainer');
            if (!container) {
                console.error('paginationContainer element not found');
                return;
            }
            
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
                    if (typeof window.goToPage === 'function') {
                        window.goToPage(i);
                    }
                };
                if (nextBtn) {
                    container.insertBefore(pageBtn, nextBtn);
                } else {
                    container.appendChild(pageBtn);
                }
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
        };

        // Định nghĩa loadProducts TRƯỚC applyFilters để đảm bảo có sẵn
        window.loadProducts = function loadProducts() {
            console.log('loadProducts called with:', {
                page: currentPage,
                sort: currentSort,
                searchTerm: currentSearchTerm,
                priceRange: currentPriceRange
            });

            const params = new URLSearchParams();
            params.append('action', 'filter');
            params.append('page', currentPage);
            params.append('pageSize', 9);
            params.append('sortBy', currentSort);
            
            // Add search term if exists
            if (currentSearchTerm && currentSearchTerm.trim() !== '') {
                params.append('searchTerm', currentSearchTerm.trim());
            }
            
            if (currentPriceRange) {
                // Xử lý trường hợp "Lớn hơn 35 triệu" (có dạng "35000000-")
                if (currentPriceRange.endsWith('-')) {
                    const min = currentPriceRange.replace('-', '');
                    params.append('priceMin', min);
                    // Không có priceMax, nghĩa là chỉ có min
                } else {
                    const [min, max] = currentPriceRange.split('-');
                    params.append('priceMin', min);
                    params.append('priceMax', max);
                }
            }

            // Đảm bảo contextPath có dấu / ở đầu
            let url = contextPath;
            if (!url.endsWith('/')) {
                url += '/';
            }
            url += 'guest-products?' + params.toString();
            console.log('Fetching:', url);
            console.log('Context path:', contextPath);

            fetch(url)
                .then(response => {
                    console.log('Response status:', response.status);
                    if (!response.ok) {
                        throw new Error('Network response was not ok: ' + response.status);
                    }
                    return response.json();
                })
                .then(data => {
                    console.log('Response data:', data);
                    console.log('Products array:', data.products);
                    console.log('Products type:', typeof data.products);
                    console.log('Products length:', data.products ? data.products.length : 'null');
                    
                    if (data.success) {
                        // Đảm bảo products là array
                        let productsArray = data.products;
                        if (!Array.isArray(productsArray)) {
                            console.error('Products is not an array:', productsArray);
                            productsArray = [];
                        }
                        
                        if (typeof window.displayProducts === 'function') {
                            window.displayProducts(productsArray);
                        } else {
                            console.error('displayProducts function not found');
                        }
                        if (typeof window.updatePagination === 'function') {
                            window.updatePagination(data.currentPage, data.totalPages);
                        } else {
                            console.error('updatePagination function not found');
                        }
                    } else {
                        alert('Lỗi: ' + (data.message || 'Không thể tải sản phẩm'));
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Lỗi khi tải sản phẩm: ' + error.message);
                });
        };

        // Định nghĩa applyFilters sau loadProducts
        window.applyFilters = function applyFilters() {
            console.log('applyFilters called');
            
            // Get selected price range
            const priceRadio = document.querySelector('input[name="priceRange"]:checked');
            currentPriceRange = priceRadio ? priceRadio.value : null;

            // Get search term
            const searchInput = document.getElementById('searchInput');
            currentSearchTerm = searchInput ? searchInput.value.trim() : '';

            // Reset to page 1
            currentPage = 1;
            
            console.log('Filters applied:', {
                priceRange: currentPriceRange,
                searchTerm: currentSearchTerm,
                sort: currentSort
            });
            
            // Load products via AJAX - luôn dùng AJAX, không reload page
            if (typeof window.loadProducts === 'function') {
                window.loadProducts();
            } else {
                console.error('loadProducts function not found!');
                alert('Lỗi: Hệ thống chưa sẵn sàng. Vui lòng reload trang.');
            }
        };

        // Định nghĩa resetFilters để hủy tất cả filters
        window.resetFilters = function resetFilters() {
            console.log('resetFilters called');
            
            // Reset tất cả radio buttons (price range)
            const priceRadios = document.querySelectorAll('input[name="priceRange"]');
            priceRadios.forEach(radio => {
                radio.checked = false;
            });
            currentPriceRange = null;

            // Reset search input
            const searchInput = document.getElementById('searchInput');
            if (searchInput) {
                searchInput.value = '';
            }
            currentSearchTerm = '';

            // Reset sort về "all"
            currentSort = 'all';
            const sortLinks = document.querySelectorAll('.sort-link');
            sortLinks.forEach(link => {
                link.classList.remove('active');
                if (link.dataset.sort === 'all') {
                    link.classList.add('active');
                }
            });

            // Reset về page 1
            currentPage = 1;
            
            console.log('Filters reset. Loading all products...');
            
            // Load products với không có filter nào
            if (typeof window.loadProducts === 'function') {
                window.loadProducts();
            } else {
                console.error('loadProducts function not found!');
                alert('Lỗi: Hệ thống chưa sẵn sàng. Vui lòng reload trang.');
            }
        };

        // Handle search input Enter key press - PHẢI định nghĩa ở đây
        function handleSearchKeyPress(event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                if (typeof window.applyFilters === 'function') {
                    window.applyFilters();
                }
            }
        }
        
        // Handle sort click - PHẢI định nghĩa ở đây để onclick có thể gọi
        function handleSortClick(element, sortValue) {
            console.log('handleSortClick called with:', sortValue);
            
            // Remove active từ tất cả links
            document.querySelectorAll('.sort-link').forEach(function(l) {
                l.classList.remove('active');
            });
            
            // Add active cho link được click
            element.classList.add('active');
            
            // Update currentSort
            currentSort = sortValue || 'all';
            console.log('Current sort set to:', currentSort);
            
            // Reset về trang 1 khi sort
            currentPage = 1;
            
            // Load products trực tiếp - không cần đợi function khác
            function loadProductsNow() {
                // Lấy selected price range và search term nếu có
                var priceRadio = document.querySelector('input[name="priceRange"]:checked');
                var selectedPriceRange = priceRadio ? priceRadio.value : null;
                
                var searchInput = document.getElementById('searchInput');
                var searchTerm = searchInput ? searchInput.value.trim() : '';
                
                // Tạo params
                var params = new URLSearchParams();
                params.append('action', 'filter');
                params.append('page', currentPage);
                params.append('pageSize', 9);
                params.append('sortBy', currentSort);
                
                if (searchTerm) {
                    params.append('searchTerm', searchTerm);
                }
                
                if (selectedPriceRange) {
                    // Xử lý trường hợp "Lớn hơn 35 triệu" (có dạng "35000000-")
                    if (selectedPriceRange.endsWith('-')) {
                        var min = selectedPriceRange.replace('-', '');
                        params.append('priceMin', min);
                    } else {
                        var priceParts = selectedPriceRange.split('-');
                        if (priceParts.length === 2) {
                            params.append('priceMin', priceParts[0]);
                            params.append('priceMax', priceParts[1]);
                        }
                    }
                }
                
                console.log('Loading products with sort:', currentSort);
                
                // Đảm bảo contextPath có dấu / ở đầu
                let fetchUrl = contextPath;
                if (!fetchUrl.endsWith('/')) {
                    fetchUrl += '/';
                }
                fetchUrl += 'guest-products?' + params.toString();
                console.log('Fetching from handleSortClick:', fetchUrl);
                
                // Gọi API
                fetch(fetchUrl)
                    .then(function(response) {
                        return response.json();
                    })
                    .then(function(data) {
                        if (data.success) {
                            // Gọi displayProducts nếu có, nếu không thì reload trang
                            if (typeof window.displayProducts === 'function') {
                                window.displayProducts(data.products);
                            }
                            if (typeof window.updatePagination === 'function') {
                                window.updatePagination(data.currentPage, data.totalPages);
                            }
                            // Nếu không có function, reload trang với sort parameter
                            if (typeof window.displayProducts !== 'function') {
                                window.location.href = contextPath + '/guest-products?sortBy=' + currentSort;
                            }
                        } else {
                            alert('Lỗi: ' + (data.message || 'Không thể tải sản phẩm'));
                        }
                    })
                    .catch(function(error) {
                        console.error('Error:', error);
                        alert('Lỗi khi tải sản phẩm');
                    });
            }
            
            // Gọi ngay nếu đã có contextPath, nếu không đợi DOM ready
            if (contextPath && contextPath !== '') {
                loadProductsNow();
            } else {
                if (document.readyState === 'loading') {
                    document.addEventListener('DOMContentLoaded', loadProductsNow);
                } else {
                    // Đợi một chút để contextPath được set
                    setTimeout(loadProductsNow, 100);
                }
            }
        }
    </script>
    
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
                            <div class="filter-item hidden-price-range">
                                <input type="radio" name="priceRange" id="price6" value="35000000-">
                                <label for="price6">Lớn hơn 35 triệu</label>
                            </div>
                            <a href="javascript:void(0);" class="see-more-link" id="seeMorePrice" onclick="togglePriceRanges()">Xem thêm</a>
                        </div>

                        <!-- Filter Actions -->
                        <div class="filter-actions">
                            <button type="button" class="filter-btn" onclick="applyFilters()">
                                <i class="fas fa-filter"></i> Lọc
                            </button>
                            <button type="button" class="reset-btn" onclick="resetFilters()">
                                <i class="fas fa-times"></i> Hủy lọc
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Main Products Area -->
                <div class="col-lg-9 col-md-8">
                    <div class="products-container">
                        <!-- Sorting Bar -->
                        <div class="sorting-bar">
                            <div class="sorting-links" id="sortingLinks">
                                <c:set var="currentSortValue" value="${currentSort != null ? currentSort : 'all'}" />
                                <a href="javascript:void(0);" class="sort-link <c:if test="${currentSortValue == 'all'}">active</c:if>" data-sort="all" onclick="handleSortClick(this, 'all'); return false;">Toàn bộ sản phẩm</a>
                                <a href="javascript:void(0);" class="sort-link <c:if test="${currentSortValue == 'price_asc'}">active</c:if>" data-sort="price_asc" onclick="handleSortClick(this, 'price_asc'); return false;">Giá tăng dần</a>
                                <a href="javascript:void(0);" class="sort-link <c:if test="${currentSortValue == 'price_desc'}">active</c:if>" data-sort="price_desc" onclick="handleSortClick(this, 'price_desc'); return false;">Giá giảm dần</a>
                            </div>
                            <div class="search-container">
                                <input type="text" id="searchInput" class="search-input" placeholder="Tìm kiếm sản phẩm..." value="${searchTerm != null ? searchTerm : ''}" onkeypress="handleSearchKeyPress(event)">
                                <button class="search-btn" onclick="if(typeof window.applyFilters === 'function') window.applyFilters();">
                                    <i class="fas fa-search"></i> Tìm kiếm
                                </button>
                            </div>
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
                        <c:set var="totalProductsAttr" value="${totalProducts != null ? totalProducts : fn:length(products)}" />
                        <c:set var="totalPagesAttr" value="${totalPages != null ? totalPages : (totalProductsAttr > 9 ? ((totalProductsAttr + 8) / 9) : 1)}" />
                        <c:set var="currentPageAttr" value="${currentPage != null ? currentPage : 1}" />
                        <div class="pagination-container" id="paginationContainer" 
                             data-total-products="${totalProductsAttr}"
                             data-total-pages="${totalPagesAttr}">
                            <button type="button" class="pagination-btn" id="prevBtn" onclick="if(typeof window.changePage === 'function') window.changePage(-1);">
                                Trước
                            </button>
                            <c:if test="${totalPagesAttr > 1}">
                                <c:set var="maxVisiblePages" value="${totalPagesAttr > 5 ? 5 : totalPagesAttr}" />
                                <c:set var="startPage" value="${currentPageAttr > 3 ? (currentPageAttr - 2) : 1}" />
                                <c:set var="endPage" value="${startPage + maxVisiblePages - 1 > totalPagesAttr ? totalPagesAttr : startPage + maxVisiblePages - 1}" />
                                <c:forEach var="i" begin="${startPage}" end="${endPage}">
                                    <button type="button" class="pagination-btn <c:if test="${i == currentPageAttr}">active</c:if>" onclick="if(typeof window.goToPage === 'function') window.goToPage(${i});">${i}</button>
                                </c:forEach>
                            </c:if>
                            <button type="button" class="pagination-btn" id="nextBtn" onclick="if(typeof window.changePage === 'function') window.changePage(1);" <c:if test="${totalPagesAttr <= 1 || currentPageAttr >= totalPagesAttr}">disabled</c:if>>
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

    <!-- Hidden inputs để truyền giá trị từ server sang JavaScript -->
    <input type="hidden" id="serverCurrentPage" value="<c:choose><c:when test="${currentPage != null and currentPage > 0}">${currentPage}</c:when><c:otherwise>1</c:otherwise></c:choose>" />
    <input type="hidden" id="serverCurrentSort" value="<c:choose><c:when test="${currentSort != null and currentSort != ''}"><c:out value="${currentSort}" escapeXml="true" /></c:when><c:otherwise>all</c:otherwise></c:choose>" />
    <input type="hidden" id="serverSearchTerm" value="<c:if test="${searchTerm != null}"><c:out value="${searchTerm}" escapeXml="true" /></c:if>" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Cập nhật giá trị từ server sau khi DOM ready
        document.addEventListener('DOMContentLoaded', function() {
            // Khởi tạo từ server-side values
            var pageInput = document.getElementById('serverCurrentPage');
            var sortInput = document.getElementById('serverCurrentSort');
            if (pageInput) {
                currentPage = parseInt(pageInput.value || '1') || 1;
            }
            if (sortInput) {
                currentSort = sortInput.value || 'all';
            }
            currentPriceRange = null;
            
            // Get search term from input or hidden field
            const searchInput = document.getElementById('searchInput');
            const searchTermInput = document.getElementById('serverSearchTerm');
            if (searchTermInput && searchTermInput.value) {
                currentSearchTerm = searchTermInput.value.trim();
                if (searchInput) {
                    searchInput.value = currentSearchTerm;
                }
            } else if (searchInput) {
                currentSearchTerm = searchInput.value.trim() || '';
            }
            
            console.log('Initialized. Current sort:', currentSort, 'Current page:', currentPage, 'Search term:', currentSearchTerm);
            console.log('Context path:', contextPath);
        });

        // Setup event listeners (backup method)
        function setupSeeMoreLinks() {
            // Các hàm toggle đã được gọi trực tiếp từ onclick trong HTML
            // Hàm này chỉ để đảm bảo compatibility
        }

        // handleSortClick đã được định nghĩa ở trên (window scope)

        // Setup sort links event listeners (backup method)
        function setupSortLinks() {
            console.log('Setting up sort links...');
            const sortingLinksContainer = document.getElementById('sortingLinks');
            const sortLinks = document.querySelectorAll('.sort-link');
            
            console.log('Sorting links container:', sortingLinksContainer);
            console.log('Found sort links:', sortLinks.length);
            
            if (!sortingLinksContainer) {
                console.error('Cannot find sortingLinks container!');
                return;
            }
            
            if (sortLinks.length === 0) {
                console.error('No sort links found!');
                return;
            }
            
            // Remove old listener nếu có
            if (sortingLinksContainer._sortHandler) {
                sortingLinksContainer.removeEventListener('click', sortingLinksContainer._sortHandler);
            }
            
            // Tạo handler mới với event delegation
            sortingLinksContainer._sortHandler = function(e) {
                console.log('Click detected on:', e.target);
                const link = e.target.closest('.sort-link');
                console.log('Closest sort-link:', link);
                
                if (link) {
                    e.preventDefault();
                    e.stopPropagation();
                    
                    // Remove active từ tất cả links
                    document.querySelectorAll('.sort-link').forEach(l => l.classList.remove('active'));
                    
                    // Add active cho link được click
                    link.classList.add('active');
                    
                    // Update currentSort
                    currentSort = link.dataset.sort || 'all';
                    console.log('Sort changed to:', currentSort);
                    
                    // Apply filters
                    console.log('Calling applyFilters...');
                    if (typeof window.applyFilters === 'function') {
                        window.applyFilters();
                    }
                } else {
                    console.log('Clicked element is not a sort link');
                }
            };
            
            // Add event listener
            sortingLinksContainer.addEventListener('click', sortingLinksContainer._sortHandler);
            console.log('Sort links event listener attached successfully');
            
            // Also attach directly to each link as backup
            sortLinks.forEach((link, index) => {
                link.addEventListener('click', function(e) {
                    console.log('Direct click on sort link #' + index);
                    e.preventDefault();
                    e.stopPropagation();
                    
                    document.querySelectorAll('.sort-link').forEach(l => l.classList.remove('active'));
                    this.classList.add('active');
                    currentSort = this.dataset.sort || 'all';
                    console.log('Sort changed to:', currentSort);
                    
                    if (typeof window.applyFilters === 'function') {
                        window.applyFilters();
                    }
                });
            });
        }

        // applyFilters và loadProducts đã được định nghĩa ở trên trong script đầu tiên
        
        // Định nghĩa các hàm pagination
        window.goToPage = function goToPage(page) {
            currentPage = page;
            if (typeof window.loadProducts === 'function') {
                window.loadProducts();
            }
        };

        window.changePage = function changePage(delta) {
            const newPage = currentPage + delta;
            if (newPage >= 1) {
                if (typeof window.goToPage === 'function') {
                    window.goToPage(newPage);
                }
            }
        };

        // displayProducts và updatePagination đã được định nghĩa ở trên trong script đầu tiên

        // changePage và goToPage đã được định nghĩa ở trên

        // Initialize pagination on first load
        function initPagination() {
            const paginationContainer = document.getElementById('paginationContainer');
            if (!paginationContainer) return;
            
            const totalPages = parseInt(paginationContainer.getAttribute('data-total-pages')) || 1;
            const currentPageNum = currentPage || 1;
            if (totalPages > 1) {
                updatePagination(currentPageNum, totalPages);
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
            console.log('DOM Content Loaded');
            
            // Setup sort links FIRST - đảm bảo các link sort hoạt động
            setupSortLinks();
            
            // Setup event listeners cho các nút "Xem thêm"
            setupSeeMoreLinks();
            
            initPagination();
            setupImageFallbacks();
            
            console.log('Initialized. Current sort:', currentSort, 'Current page:', currentPage);
        });
    </script>
</body>
</html>

