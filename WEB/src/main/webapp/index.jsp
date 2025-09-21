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
    <style>
        :root {
            --primary-red: #dc3545;
            --primary-yellow: #ffc107;
            --dark-grey: #343a40;
            --light-grey: #f8f9fa;
            --white: #ffffff;
            --black: #000000;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Roboto', sans-serif;
            line-height: 1.6;
            color: var(--dark-grey);
            background: var(--white);
        }

        /* Top Header Styles */
        .top-header {
            background: var(--primary-red);
            color: var(--white);
            padding: 8px 0;
            font-size: 14px;
        }

        .header-text {
            font-weight: 600;
            text-transform: uppercase;
        }

        .contact-info {
            margin-right: 20px;
        }

        .contact-info i {
            margin-right: 8px;
        }

        /* Navigation Styles */
        .navbar {
            background: var(--white);
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 15px 0;
        }

        .logo-container {
            display: flex;
            align-items: center;
        }

        .logo-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            margin-right: 15px;
            overflow: hidden;
        }

        .logo-icon img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .logo-text {
            color: var(--dark-grey);
            font-size: 16px;
            font-weight: 600;
            line-height: 1.2;
        }

        .search-container {
            position: relative;
            margin: 0 20px;
        }

        .search-input {
            width: 300px;
            padding: 12px 45px 12px 15px;
            border: 1px solid #dee2e6;
            border-radius: 25px;
            font-size: 14px;
        }

        .search-icon {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #6c757d;
        }

        .contact-info-nav {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .phone-number {
            color: var(--primary-red);
            font-weight: 600;
            font-size: 16px;
        }

        .phone-number i {
            margin-right: 8px;
        }

        .nav-icons {
            display: flex;
            gap: 15px;
        }

        .nav-icons i {
            font-size: 20px;
            color: var(--dark-grey);
            cursor: pointer;
            transition: color 0.3s ease;
        }

        .nav-icons i:hover {
            color: var(--primary-red);
        }

        .navbar-nav .nav-link {
            color: var(--dark-grey) !important;
            font-weight: 500;
            margin: 0 8px;
            padding: 8px 12px !important;
            transition: all 0.3s ease;
            text-transform: uppercase;
            font-size: 14px;
        }

        .navbar-nav .nav-link:hover {
            color: var(--primary-red) !important;
        }

        .navbar-nav .nav-link.active {
            color: var(--primary-red) !important;
            font-weight: 600;
        }

        /* Hero Banner Styles */
        .hero-banner {
            background: var(--black);
            color: var(--white);
            padding: 60px 0;
            position: relative;
            overflow: hidden;
        }

        .hero-banner::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 200px;
            height: 100%;
            background: var(--primary-red);
            clip-path: polygon(0 0, 100% 0, 80% 100%, 0 100%);
        }

        .hero-banner::after {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            width: 200px;
            height: 100%;
            background: var(--primary-red);
            clip-path: polygon(20% 0, 100% 0, 100% 100%, 0 100%);
        }

        .banner-content {
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            z-index: 2;
            min-height: 300px;
            text-align: center;
        }

        .banner-left {
            position: absolute;
            left: 50px;
            top: 50%;
            transform: translateY(-50%);
        }

        .company-logo-banner {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .logo-circle {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            overflow: hidden;
            border: 4px solid var(--primary-red);
        }

        .logo-circle img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .banner-right {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
        }

        .company-title h1 {
            font-size: 2.5rem;
            font-weight: 700;
            text-align: center;
            line-height: 1.2;
            margin: 0;
            color: var(--white);
        }


        .hotline-info {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
            margin: 20px 0;
        }

        .hotline-label {
            font-size: 18px;
            font-weight: 600;
            letter-spacing: 1px;
            color: var(--white);
        }

        .hotline-number {
            font-size: 24px;
            font-weight: 700;
            color: var(--primary-yellow);
            letter-spacing: 2px;
        }

        .website-info {
            font-size: 16px;
            color: #ccc;
            letter-spacing: 0.5px;
            margin-top: 10px;
        }


        .banner-indicators {
            position: absolute;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            gap: 10px;
        }

        .indicator {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.5);
            cursor: pointer;
        }

        .indicator.active {
            background: var(--white);
        }

        /* Main Content Section */
        .main-content-section {
            padding: 80px 0;
            background: var(--white);
        }

        .main-title {
            color: var(--primary-red);
            font-size: 3rem;
            font-weight: 700;
            text-align: center;
            margin-bottom: 60px;
        }

        .content-row {
            display: flex;
            align-items: center;
            gap: 60px;
        }

        .left-content-block {
            flex: 1;
            position: relative;
        }

        .quote-block {
            background: linear-gradient(135deg, #1a1a2e, #16213e);
            color: var(--white);
            padding: 40px;
            border-radius: 15px;
            position: relative;
            min-height: 400px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .quote-block::before {
            content: '';
            position: absolute;
            top: 20px;
            left: 20px;
            width: 60px;
            height: 60px;
            background: var(--primary-red);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .quote-block::after {
            content: '⚙';
            position: absolute;
            top: 35px;
            left: 35px;
            color: var(--white);
            font-size: 20px;
        }

        .quote-text {
            font-size: 18px;
            line-height: 1.6;
            margin-bottom: 20px;
            font-style: italic;
        }

        .quote-text:first-of-type {
            margin-top: 40px;
        }

        .company-logo-bottom {
            position: absolute;
            bottom: 20px;
            left: 20px;
            color: var(--white);
            font-size: 14px;
            font-weight: 600;
        }

        .quote-indicators {
            position: absolute;
            bottom: 20px;
            right: 20px;
            display: flex;
            gap: 8px;
        }

        .quote-indicator {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.5);
            cursor: pointer;
        }

        .quote-indicator.active {
            background: var(--white);
        }

        .right-content-block {
            flex: 1;
            padding: 20px;
        }

        .info-content p {
            font-size: 16px;
            line-height: 1.8;
            margin-bottom: 25px;
            color: var(--dark-grey);
        }

        .learn-more-btn {
            margin-top: 40px;
        }

        .learn-more-btn .btn {
            background: var(--primary-red);
            border: none;
            color: var(--white);
            padding: 15px 40px;
            border-radius: 30px;
            font-weight: 600;
            font-size: 16px;
            transition: all 0.3s ease;
        }

        .learn-more-btn .btn:hover {
            background: #c82333;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3);
        }

        /* Product Section */
        .product-section {
            padding: 80px 0;
            background: var(--light-grey);
        }

        .product-title {
            color: var(--primary-red);
            font-size: 2.5rem;
            font-weight: 700;
            text-align: center;
            margin-bottom: 60px;
        }

        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 40px;
            max-width: 1400px;
            margin: 0 auto;
        }

        .product-card {
            background: var(--white);
            border-radius: 20px;
            padding: 40px;
            text-align: center;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
            min-height: 500px;
            display: flex;
            flex-direction: column;
        }

        .product-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.2);
        }

        .product-image {
            width: 100%;
            height: 280px;
            border-radius: 15px;
            margin-bottom: 25px;
            overflow: hidden;
            flex-shrink: 0;
        }

        .product-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease;
        }

        .product-card:hover .product-image img {
            transform: scale(1.05);
        }

        .product-title-card {
            font-size: 18px;
            font-weight: 600;
            color: var(--dark-grey);
            margin-bottom: 15px;
        }

        .product-info {
            text-align: left;
            margin-top: 20px;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .product-info p {
            font-size: 15px;
            margin-bottom: 20px;
            color: var(--dark-grey);
            line-height: 1.7;
            text-align: left;
        }

        .product-info strong {
            color: var(--primary-red);
            font-weight: 600;
        }

        .product-info .btn {
            background: transparent;
            border: 2px solid var(--primary-red);
            color: var(--primary-red);
            padding: 12px 30px;
            border-radius: 25px;
            font-size: 15px;
            font-weight: 600;
            transition: all 0.3s ease;
            align-self: flex-start;
            margin-top: auto;
        }

        .product-info .btn:hover {
            background: var(--primary-red);
            color: white;
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3);
        }

        /* Floating Social Icons */
        .floating-icons {
            position: fixed;
            right: 20px;
            bottom: 30px;
            z-index: 1000;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .floating-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-size: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }

        .floating-icon:hover {
            transform: scale(1.1);
        }

        .floating-icon.facebook {
            background: #1877f2;
        }

        .floating-icon.zalo {
            background: #0068ff;
        }

        .floating-icon.phone {
            background: var(--primary-red);
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .banner-content {
                flex-direction: column;
            text-align: center;
            }

            .content-row {
                flex-direction: column;
            }

            .search-input {
                width: 100%;
            }

            .floating-icons {
                right: 15px;
                bottom: 20px;
            }

            .floating-icon {
                width: 45px;
                height: 45px;
                font-size: 18px;
            }

            .main-title {
                font-size: 2rem;
            }

            .company-title h1 {
                font-size: 2rem;
            }

            .product-grid {
                grid-template-columns: 1fr;
                gap: 30px;
                padding: 0 20px;
            }

            .product-card {
                padding: 30px 20px;
                min-height: auto;
            }

            .product-image {
                height: 250px;
            }
        }
    </style>
</head>
<body>
    <!-- Top Header -->
    <div class="top-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <span class="header-text">MÁY PHÁT ĐIỆN CÔNG NGHIỆP</span>
                </div>
                <div class="col-md-6 text-end">
                    <span class="contact-info">
                        <i class="fas fa-envelope"></i> Mayphatdienhoalac@gmail.com
                    </span>
                    <span class="contact-info">
                        <i class="fas fa-clock"></i> 08:00 - 17:00
                    </span>
                </div>
            </div>
        </div>
    </div>

    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-light bg-white">
        <div class="container">
            <a class="navbar-brand" href="#">
                <div class="logo-container">
                    <div class="logo-icon">
                        <img src="images/logo.png" alt="Logo Hoà Lạc" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                        <div style="display:none; width:100%; height:100%; background:var(--primary-red); border-radius:50%; align-items:center; justify-content:center; color:white; font-size:20px;">★</div>
                    </div>
                    <div class="logo-text">
                        <strong>HOÀ LẠC ELECTRIC INDUSTRIAL GENERATOR</strong>
                    </div>
                </div>
            </a>
            
            <div class="search-container">
                <input type="text" class="search-input" placeholder="Tìm kiếm...">
                <i class="fas fa-search search-icon"></i>
            </div>
            
            <div class="contact-info-nav">
                <div class="phone-number">
                    <i class="fas fa-phone"></i> 0989.888.999
                </div>
                <div class="nav-icons">
                    <i class="fas fa-user"></i>
                    <i class="fas fa-shopping-bag"></i>
                </div>
            </div>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav mx-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="#home">TRANG CHỦ</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#about">GIỚI THIỆU</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#products">MÁY PHÁT ĐIỆN</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#services">DỊCH VỤ</a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#projects">DỰ ÁN</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#guide">HƯỚNG DẪN</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#news">TIN TỨC</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#contact">LIÊN HỆ</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Hero Banner Section -->
    <section id="home" class="hero-banner">
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <div class="banner-content">
                        <div class="banner-left">
                            <div class="company-logo-banner">
                                <div class="logo-circle">
                                    <img src="images/logo-banner.png" alt="Logo Banner Hoà Lạc" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                    <div style="display:none; width:100%; height:100%; background:var(--white); border-radius:50%; align-items:center; justify-content:center; color:var(--primary-yellow); font-size:30px;">★</div>
                    </div>
                    </div>
                </div>
                        <div class="banner-right">
                            <div class="company-title">
                                <h1>CÔNG TY CP CHẾ TẠO MÁY HOÀ LẠC</h1>
            </div>
                            <div class="hotline-info">
                                <span class="hotline-label">HOTLINE</span>
                                <span class="hotline-number">0989 888 999</span>
        </div>
                            <div class="website-info">
                                <span>Https://mayphatdienhoalac.com</span>
                </div>
            </div>
                        <div class="banner-indicators">
                            <span class="indicator active"></span>
                            <span class="indicator"></span>
                </div>
                </div>
            </div>
            </div>
        </div>
    </section>

    <!-- Main Content Section -->
    <section class="main-content-section">
        <div class="container">
            <div class="row">
                <div class="col-lg-12 text-center mb-5">
                    <h2 class="main-title">CÔNG TY CP CHẾ TẠO MÁY HOÀ LẠC</h2>
                </div>
            </div>
            
            <div class="content-row">
                <div class="left-content-block">
                    <div class="quote-block">
                        <div class="quote-text">
                            "Chúng tôi chưa là tốt nhất nhưng sẽ nỗ lực cao nhất vì niềm tin của bạn"
                        </div>
                        <div class="quote-text">
                            "Sự hài lòng của bạn là thành công của chúng tôi"
                    </div>
                        <div class="company-logo-bottom">
                            HOÀ LẠC ELECTRIC INDUSTRIAL GENERATOR
                </div>
                        <div class="quote-indicators">
                            <span class="quote-indicator active"></span>
                            <span class="quote-indicator"></span>
                        </div>
                    </div>
                </div>
                
                <div class="right-content-block">
                    <div class="info-content">
                        <p>Máy phát điện Hoà Lạc là nhà nhập khẩu, lắp ráp, phân phối, bảo trì, bảo hành động cơ, đầu phát và tổ máy phát điện chính thức của các hãng sản xuất máy phát điện uy tín trên thế giới như: CUMMINS, DENYO, DOOSAN, MITSUBISHI, KOMATSU, YUCHAI,…</p>
                        
                        <p>Chúng tôi cung cấp máy phát điện phù hợp sử dụng cho các nhà máy, công trường, trang trại chăn nuôi, bệnh viện, khách sạn, khu du lịch nghỉ dưỡng, chung cư cao ốc, tòa nhà văn phòng …</p>
                        
                        <p>Với phương châm: <strong>Chuyên Nghiệp + Kinh Nghiệm => Giải Pháp Hợp Lý.</strong></p>
                        
                        <p>Quý Khách Hàng sẽ hoàn toàn yên tâm khi sử dụng các dịch vụ trọn gói của chúng tôi.</p>
                        
                        <div class="learn-more-btn">
                            <button class="btn">Tìm hiểu thêm</button>
                    </div>
                </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Product Section -->
    <section class="product-section">
        <div class="container">
            <div class="row">
                <div class="col-lg-12 text-center mb-5">
                    <h2 class="product-title">SẢN PHẨM CHÍNH</h2>
                </div>
            </div>
            
            <div class="product-grid">
                <!-- Sản phẩm 1: Máy phát điện nhập khẩu đồng bộ -->
                <div class="product-card">
                    <div class="product-image">
                        <img src="images/sanpham1.jpg" alt="Máy phát điện nhập khẩu đồng bộ" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                        <div style="display:none; width:100%; height:100%; background:var(--light-grey); border-radius:10px; align-items:center; justify-content:center; font-size:48px; color:var(--primary-red);">⚙</div>
                        </div>
                    <h4 class="product-title-card">MÁY PHÁT ĐIỆN NHẬP KHẨU ĐỒNG BỘ</h4>
                    <div class="product-info">
                        <p>Chúng tôi cung cấp tới Quý khách hàng những sản phẩm máy phát điện nhập khẩu đồng bộ từ các hãng máy phát điện lớn trên thế giới: Cummins, Genmac, Denyo... Chất lượng máy, phụ tùng thay thế và chế độ bảo hành theo đúng tiêu chuẩn của hãng.</p>
                        <button class="btn btn-outline-secondary">Xem thêm</button>
                    </div>
                </div>
                
                <!-- Sản phẩm 2: Máy phát điện lắp ráp trong nước -->
                <div class="product-card">
                    <div class="product-image">
                        <img src="images/sanpham2.jpg" alt="Máy phát điện lắp ráp trong nước" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                        <div style="display:none; width:100%; height:100%; background:var(--light-grey); border-radius:10px; align-items:center; justify-content:center; font-size:48px; color:var(--primary-red);">⚙</div>
                        </div>
                    <h4 class="product-title-card">MÁY PHÁT ĐIỆN LẮP RÁP TRONG NƯỚC</h4>
                    <div class="product-info">
                        <p>Dòng sản phẩm máy phát điện lắp ráp trong nước sử dụng động cơ của các hãng nổi tiếng thế giới: Cummins, Denyo, Komatsu, Mitsubishi,... với dải công suất từ 10-2000kVA được cung cấp bởi Hoà Lạc Power luôn đạt chất lượng cao, hoạt động bền bỉ.</p>
                        <button class="btn btn-outline-secondary">Xem thêm</button>
                    </div>
                </div>
                
                <!-- Sản phẩm 3: Máy phát điện cũ (đã qua sử dụng) -->
                <div class="product-card">
                    <div class="product-image">
                        <img src="images/sanpham3.jpg" alt="Máy phát điện cũ" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                        <div style="display:none; width:100%; height:100%; background:var(--light-grey); border-radius:10px; align-items:center; justify-content:center; font-size:48px; color:var(--primary-red);">⚙</div>
                        </div>
                    <h4 class="product-title-card">MÁY PHÁT ĐIỆN CŨ (ĐÃ QUA SỬ DỤNG)</h4>
                    <div class="product-info">
                        <p>Máy phát điện Hoà Lạc chuyên cung cấp dòng sản phẩm máy phát điện cũ với nhiều công suất khác nhau của nhiều hãng hàng đầu thế giới cho Quý khách hàng lựa chọn. Chất lượng máy phát điện cũ đạt chất lượng từ 80% đến 90% so với máy mới.</p>
                        <button class="btn btn-outline-secondary">Xem thêm</button>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Floating Social Icons -->
    <div class="floating-icons">
        <div class="floating-icon facebook">
            <i class="fab fa-facebook-f"></i>
                    </div>
        <div class="floating-icon zalo">
            <i class="fas fa-comments"></i>
                </div>
        <div class="floating-icon phone">
            <i class="fas fa-phone"></i>
                        </div>
                    </div>

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

        // Floating icons functionality
        document.querySelectorAll('.floating-icon').forEach(icon => {
            icon.addEventListener('click', function() {
                if (this.classList.contains('phone')) {
                    window.location.href = 'tel:0989888999';
                } else if (this.classList.contains('facebook')) {
                    window.open('https://facebook.com', '_blank');
                } else if (this.classList.contains('zalo')) {
                    window.open('https://zalo.me/0989888999', '_blank');
                }
            });
        });

        // Learn more button functionality
        document.querySelector('.learn-more-btn .btn').addEventListener('click', function() {
            alert('Cảm ơn bạn đã quan tâm! Chúng tôi sẽ liên hệ lại sớm nhất.');
        });
    </script>
</body>
</html>