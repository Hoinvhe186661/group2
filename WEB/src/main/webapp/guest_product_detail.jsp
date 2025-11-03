<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết sản phẩm | HOÀ LẠC ELECTRIC</title>
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

        /* Product Detail Page Styles */
        .product-detail-page {
            padding: 30px 0;
            background-color: #ffffff;
        }

        .product-detail-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 15px;
        }

        .product-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 1px solid #e0e0e0;
        }

        .product-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--dark-grey);
            margin: 0;
        }

        .back-link {
            color: #28a745;
            text-decoration: none;
            font-weight: 500;
            font-size: 16px;
            transition: color 0.3s;
        }

        .back-link:hover {
            color: #218838;
            text-decoration: underline;
        }

        .product-detail-content {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 40px;
        }

        @media (max-width: 992px) {
            .product-detail-content {
                grid-template-columns: 1fr;
            }
        }

        /* Left Column - Product Image */
        .product-image-section {
            display: flex;
            flex-direction: column;
            gap: 0;
            align-items: flex-start;
        }

        .product-main-image {
            width: 100%;
            border: 2px solid #000000;
            border-bottom: none;
            border-radius: 4px 4px 0 0;
            overflow: hidden;
            background-color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 400px;
        }

        .product-main-image img {
            width: 100%;
            height: auto;
            max-height: 500px;
            object-fit: contain;
            display: block;
        }

        .product-content-placeholder {
            color: #0066cc;
            font-size: 16px;
            padding: 12px 15px;
            background-color: #f8f9fa;
            border: 2px solid #000000;
            border-top: none;
            border-radius: 0 0 4px 4px;
            cursor: pointer;
            user-select: none;
            transition: background-color 0.3s, color 0.3s;
            display: flex;
            align-items: center;
            justify-content: space-between;
            width: 100%;
            margin: 0;
        }

        .product-content-placeholder:hover {
            background-color: #e9ecef;
            color: #0056b3;
        }

        .product-content-placeholder i {
            margin-left: 10px;
            transition: transform 0.3s;
        }

        .product-content-placeholder.expanded i {
            transform: rotate(180deg);
        }

        .product-content-details {
            display: none;
            padding: 15px;
            background-color: #ffffff;
            border: 2px solid #000000;
            border-top: none;
            border-radius: 0 0 4px 4px;
            margin: 0;
            color: #333;
            font-size: 15px;
            line-height: 1.8;
            white-space: pre-wrap;
            word-wrap: break-word;
            width: 100%;
            text-align: left;
        }

        .product-content-details.show {
            display: block;
            animation: fadeIn 0.3s ease-in;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Right Column - Product Details */
        .product-details-section {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .product-detail-item {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .detail-label {
            font-weight: 600;
            color: var(--dark-grey);
            font-size: 15px;
        }

        .detail-value {
            color: #666;
            font-size: 15px;
            padding-left: 10px;
        }

        .product-price {
            font-size: 24px;
            font-weight: 700;
            color: var(--primary-red);
        }

        .specifications {
            white-space: pre-wrap;
            word-wrap: break-word;
            line-height: 1.6;
        }

        /* Service Info Box */
        .service-info-box {
            background-color: #e9ecef;
            border: 1px solid #000000;
            border-radius: 4px;
            padding: 20px;
            margin-top: 20px;
        }

        .service-info-box ul {
            margin: 0;
            padding-left: 20px;
            list-style-type: disc;
        }

        .service-info-box li {
            margin-bottom: 8px;
            color: #333;
            font-size: 14px;
            line-height: 1.6;
        }

        .service-info-box li:last-child {
            margin-bottom: 0;
        }

        .error-message {
            text-align: center;
            padding: 60px 20px;
            color: #dc3545;
            font-size: 18px;
        }
    </style>
</head>
<body>
    <!-- Include Header -->
    <jsp:include page="header.jsp" />

    <!-- Product Detail Page Content -->
    <div class="product-detail-page">
        <div class="product-detail-container">
            <c:choose>
                <c:when test="${not empty product}">
                    <!-- Product Header -->
                    <div class="product-header">
                        <h1 class="product-title">${product.productName}</h1>
                        <a href="${pageContext.request.contextPath}/guest-products" class="back-link">
                            Quay về
                        </a>
                    </div>

                    <!-- Product Detail Content -->
                    <div class="product-detail-content">
                        <!-- Left Column - Product Image -->
                        <div class="product-image-section">
                            <div class="product-main-image">
                                <c:choose>
                                    <c:when test="${not empty product.imageUrl and product.imageUrl != 'null' and product.imageUrl != ''}">
                                        <c:set var="imgUrl" value="${product.imageUrl}" />
                                        <c:if test="${not fn:startsWith(imgUrl, 'http') and not fn:startsWith(imgUrl, '/')}">
                                            <c:set var="imgUrl" value="${pageContext.request.contextPath}/${imgUrl}" />
                                        </c:if>
                                        <c:if test="${fn:startsWith(imgUrl, '/') and not fn:startsWith(imgUrl, pageContext.request.contextPath)}">
                                            <c:set var="imgUrl" value="${pageContext.request.contextPath}${imgUrl}" />
                                        </c:if>
                                        <img src="${imgUrl}" alt="${product.productName}" 
                                             onerror="this.src='${pageContext.request.contextPath}/images/sanpham1.jpg'">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/images/sanpham1.jpg" alt="${product.productName}">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="product-content-placeholder" 
                                 onclick="toggleProductContent()" 
                                 onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();toggleProductContent();}"
                                 role="button"
                                 tabindex="0"
                                 aria-expanded="false"
                                 aria-controls="productContentDetails">
                                <span>Nội dung sản phẩm....</span>
                                <i class="fas fa-chevron-down"></i>
                            </div>
                            <div class="product-content-details" id="productContentDetails">
                                <c:choose>
                                    <c:when test="${not empty product.description and product.description != 'null' and product.description != ''}">
                                        ${product.description}
                                    </c:when>
                                    <c:otherwise>
                                        <p style="color: #999; font-style: italic;">Chưa có mô tả chi tiết cho sản phẩm này.</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Right Column - Product Details -->
                        <div class="product-details-section">
                            <div class="product-detail-item">
                                <span class="detail-label">Mã sản phẩm:</span>
                                <span class="detail-value">
                                    <c:choose>
                                        <c:when test="${not empty product.productCode}">${product.productCode}</c:when>
                                        <c:otherwise>N/A</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <div class="product-detail-item">
                                <span class="detail-label">Loại sản phẩm (danh mục):</span>
                                <span class="detail-value">
                                    <c:choose>
                                        <c:when test="${not empty product.category}">${product.category}</c:when>
                                        <c:otherwise>N/A</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <div class="product-detail-item">
                                <span class="detail-label">Bảo hành:</span>
                                <span class="detail-value">
                                    <c:choose>
                                        <c:when test="${product.warrantyMonths > 0}">${product.warrantyMonths} tháng</c:when>
                                        <c:otherwise>N/A</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <div class="product-detail-item">
                                <span class="detail-label">Giá bán:</span>
                                <c:choose>
                                    <c:when test="${product.unitPrice > 0}">
                                        <span class="detail-value product-price">
                                            <fmt:formatNumber value="${product.unitPrice}" type="number" maxFractionDigits="0"/> VNĐ
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="detail-value">Liên hệ</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="product-detail-item">
                                <span class="detail-label">Thông số kĩ thuật:</span>
                                <span class="detail-value specifications">
                                    <c:choose>
                                        <c:when test="${not empty product.specifications and product.specifications != 'null'}">
                                            ${product.specifications}
                                        </c:when>
                                        <c:otherwise>Đang cập nhật...</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <!-- Service Info Box -->
                            <div class="service-info-box">
                                <ul>
                                    <li>Miễn phí giao hàng trong nội thành Hà Nội và nội thành TP. Hồ Chí Minh.</li>
                                    <li>Được hàng trăm ngàn Doanh nghiệp tại Việt Nam lựa chọn: đầy đủ hóa đơn, hợp đồng, không chi phí ẩn</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="error-message">
                        <i class="fas fa-exclamation-circle"></i>
                        <p>Không tìm thấy sản phẩm hoặc sản phẩm không tồn tại.</p>
                        <a href="${pageContext.request.contextPath}/guest-products" class="back-link">
                            Quay về trang sản phẩm
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Include Footer -->
    <jsp:include page="footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function toggleProductContent() {
            const contentDetails = document.getElementById('productContentDetails');
            const placeholder = document.querySelector('.product-content-placeholder');
            
            if (contentDetails && placeholder) {
                // Toggle hiển thị nội dung
                const isExpanded = contentDetails.classList.toggle('show');
                
                // Toggle icon (xoay mũi tên)
                placeholder.classList.toggle('expanded');
                
                // Cập nhật aria-expanded
                placeholder.setAttribute('aria-expanded', isExpanded ? 'true' : 'false');
                
                // Thay đổi text nếu cần
                const span = placeholder.querySelector('span');
                if (isExpanded) {
                    if (span) {
                        span.textContent = 'Ẩn nội dung sản phẩm';
                    }
                } else {
                    if (span) {
                        span.textContent = 'Nội dung sản phẩm....';
                    }
                }
            }
        }
    </script>
</body>
</html>

