<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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

    String pageTitle = (String) pageContext.getAttribute("siteName") + " - " + (String) pageContext.getAttribute("siteDescription");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %></title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-red: #dc3545;
            --primary-yellow: #ffc107;
            --dark-grey: #2f3440;
            --muted-grey: #6b7280;
            --body-text: #444a57;
            --light-grey: #f8f9fa;
            --white: #ffffff;
            --black: #000000;
        }

        body { font-family: 'Roboto', sans-serif; color: var(--body-text); line-height: 1.75; }

        .top-header { background: var(--primary-red); color: var(--white); padding: 8px 0; font-size: 14px; }
        .header-text { font-weight: 600; text-transform: uppercase; }
        .contact-info { margin-right: 20px; }

        .header-navbar { background: var(--white); box-shadow: 0 2px 10px rgba(0,0,0,0.1); padding: 15px 0; }
        .menu-navbar { background: #eeeeee; border-top: 1px solid #e5e5e5; border-bottom: 1px solid #e5e5e5; padding: 8px 0; }
        .logo-container { display:flex; align-items:center; }
        .logo-icon { width:60px; height:60px; border-radius:50%; margin-right:15px; overflow:hidden; }
        .logo-icon img { width:100%; height:100%; object-fit:cover; }
        .logo-text { color: var(--dark-grey); font-size:16px; font-weight:600; line-height:1.2; }
        .search-container { position:relative; margin:0 20px; }
        .search-input { width:300px; padding:12px 45px 12px 15px; border:1px solid #dee2e6; border-radius:25px; font-size:14px; }
        .search-icon { position:absolute; right:15px; top:50%; transform:translateY(-50%); color:#6c757d; }
        .contact-info-nav { display:flex; align-items:center; gap:20px; }
        .phone-number { color:var(--primary-red); font-weight:600; font-size:16px; }
        .nav-icons { display:flex; gap:15px; }
        .nav-icons i { font-size:20px; color:var(--dark-grey); cursor:pointer; }
        .navbar-nav .nav-link { color:var(--dark-grey) !important; font-weight:500; margin:0 8px; padding:8px 12px !important; text-transform:uppercase; font-size:14px; }
        .navbar-nav .nav-link:hover { color:var(--primary-red) !important; }
        .navbar-nav .nav-link.active { color:var(--primary-red) !important; font-weight:700; }

        .about-hero { background: linear-gradient(135deg, #1a1a2e, #16213e); color: var(--white); padding: 60px 0; position: relative; overflow: hidden; }
        .about-hero::after { content:''; position:absolute; bottom:-40px; right:-60px; width:240px; height:240px; border-radius:50%; background: rgba(220,53,69,0.2); filter: blur(2px); z-index: 0; }
        .about-hero h1 { font-weight:800; letter-spacing:.5px; text-transform: uppercase; }
        .about-hero p { color: rgba(255,255,255,.9); }
        .about-hero .col-lg-7, .about-hero .col-lg-5 { position: relative; z-index: 1; }
        .about-hero .hero-img { max-width: 440px; width: 100%; height: auto; border-radius: 16px; box-shadow: 0 12px 28px rgba(0,0,0,.25); }
        .about-hero .breadcrumb { background: transparent; padding: 0; margin: 0; }
        .breadcrumb a { color:#ddd; text-decoration:none; }
        .breadcrumb .active { color: var(--primary-yellow); }

        .about-section { padding: 70px 0; }
        .about-section h2 { color: var(--primary-red); font-weight:800; margin-bottom:16px; letter-spacing:.4px; text-transform: uppercase; }
        .about-section p { font-size:16px; color: var(--body-text); margin-bottom:14px; }
        .about-section ul { padding-left: 1.15rem; margin-bottom: 14px; }
        .about-section li { margin-bottom: 8px; }
        .about-section li::marker { color: var(--primary-red); }
        .about-section strong, .about-section b { color: var(--dark-grey); font-weight: 800; }
        .muted { color: var(--muted-grey) !important; }

        .feature-card { background: var(--white); border-radius:16px; padding:24px; box-shadow: 0 8px 24px rgba(0,0,0,.08); height:100%; transition: transform .2s ease, box-shadow .2s ease; }
        .feature-card:hover { transform: translateY(-4px); box-shadow: 0 12px 32px rgba(0,0,0,.12); }
        .feature-card i { color: var(--primary-red); font-size:26px; margin-right:12px; min-width: 28px; }
        .feature-card h5 { font-weight: 700; }

        .stats { background: var(--light-grey); padding: 40px 0; border-radius: 12px; }
        .stat { text-align:center; padding: 10px 0; }
        .stat h3 { color: var(--primary-red); font-size: 34px; font-weight:800; margin-bottom: 2px; }
        .stat p { margin:0; color: var(--muted-grey); text-transform:uppercase; font-weight:700; letter-spacing:.5px; font-size: 12px; }

        .brand-logos img { height: 42px; margin: 8px 18px; opacity:.9; filter: grayscale(30%); }

        .cta { background: var(--primary-red); color: var(--white); padding: 50px 0; border-radius: 16px; }
        .cta .btn { background: var(--white); color: var(--primary-red); border:none; font-weight:700; padding:12px 28px; border-radius:30px; }

        /* New layout helpers to match provided designs */
        .section-title { color: var(--primary-red); font-weight: 800; }
        .section-title.center { text-align: center; }
        .promo-image { width: 100%; height: auto; border-radius: 12px; box-shadow: 0 10px 28px rgba(0,0,0,.15); }
        .hotline-banner { background: var(--primary-red); color: var(--white); font-weight: 900; text-align: center; border-radius: 8px; padding: 12px 16px; margin-top: 14px; letter-spacing:.6px; font-size: 18px; }

        @media (max-width: 992px) {
            .about-hero { padding: 40px 0; }
            .about-hero .col-lg-5 { text-align: center; margin-top: 18px; }
            .about-hero h1 { font-size: 28px; }
        }

        @media (max-width: 768px) {
            .search-input { width: 100%; }
            .brand-logos { text-align:center; }
            .about-section { padding: 44px 0; }
            .feature-card { padding: 18px; }
        }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>



    <section class="about-section">
        <div class="container">
            <div class="row g-5 align-items-center">
                <div class="col-lg-6">
                    <img src="images/sanpham2.jpg" alt="About" class="promo-image" loading="lazy" onerror="this.style.display='none'">
                </div>
                <div class="col-lg-6">
                    <h2 class="section-title center">VỀ CHÚNG TÔI</h2>
                    <p>Trước tiên, chúng tôi xin gửi lời cảm ơn chân thành và lời chúc sức khỏe đến Quý khách hàng đã tin tưởng và đồng hành cùng <%= pageContext.getAttribute("siteName") != null ? pageContext.getAttribute("siteName") : "HOÀ LẠC ELECTRIC" %> trong suốt thời gian qua.</p>
                    <p>Chúng tôi là đơn vị chuyên cung cấp, bảo dưỡng, sửa chữa máy phát điện công nghiệp, đặc biệt là máy phát điện 3 pha chạy dầu Diesel, với đội ngũ gần 20 kỹ sư và công nhân lành nghề. Nhà máy đặt tại Đại Thanh – Hà Nội.</p>
                    <p>Doanh nghiệp được thành lập bởi các chuyên gia đầu ngành với nhiều năm kinh nghiệm trong tư vấn – thiết kế – giám sát – thi công lắp đặt hệ thống điện và tổ máy phát điện. Ngay từ những ngày đầu, <%= pageContext.getAttribute("siteName") != null ? pageContext.getAttribute("siteName") : "HOÀ LẠC ELECTRIC" %> đã trở thành địa chỉ uy tín cho khách hàng cần máy phát điện công suất lớn phục vụ sản xuất và dự phòng.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="about-section" style="background: var(--light-grey);">
        <div class="container">
            <div class="row g-4 align-items-start">
                <div class="col-lg-7">
                    <h2 class="section-title">CHUYÊN GIA MÁY PHÁT ĐIỆN</h2>
                    <p><%= pageContext.getAttribute("siteName") != null ? pageContext.getAttribute("siteName") : "HOÀ LẠC ELECTRIC" %> là đơn vị chuyên nhập khẩu – sản xuất – phân phối máy phát điện công nghiệp, với danh mục sản phẩm và dịch vụ đa dạng:</p>
                    <ul>
                        <li>Máy phát điện Diesel, máy phát điện 3 pha, công suất từ 20kVA – 3000kVA</li>
                        <li>Cho thuê, sửa chữa, bảo trì máy phát điện theo yêu cầu</li>
                        <li>Cam kết 100% sản phẩm mới, chính hãng, chưa qua sử dụng</li>
                    </ul>
                    <p>Với đội ngũ kỹ sư giàu kinh nghiệm, am hiểu kỹ thuật và thực tế vận hành, HOÀ LẠC ELECTRIC luôn đưa ra giải pháp hiệu quả, tối ưu chi phí cho khách hàng. Tất cả các dự án thi công đều đúng tiến độ – đạt chuẩn kỹ thuật – được khách hàng tin tưởng.</p>
                    <p>Được thành lập từ tâm huyết của các kỹ sư đầu ngành trong cơ khí, điện, tự động hóa, viễn thông, chúng tôi không ngừng phát triển và trở thành đối tác tin cậy của nhiều công trình lớn.</p>
                    <p>Chúng tôi tự hào hợp tác với các thương hiệu uy tín toàn cầu như Doosan, Cummins, Perkins, Mitsubishi, Denyo, Volvo Penta, Yuchai… cùng các hãng đầu phát nổi tiếng Stamford, Mecc Alte, Leroy Somer…</p>
                </div>
                <div class="col-lg-5">
                    <img src="images/sanpham1.jpg" alt="Promo" class="promo-image" loading="lazy" onerror="this.style.display='none'">
                    <div class="hotline-banner">HOTLINE: <%= pageContext.getAttribute("sitePhone") != null ? pageContext.getAttribute("sitePhone") : "0989.888.999" %></div>
                </div>
            </div>

            <div class="row stats text-center mt-4">
                <div class="col-6 col-md-3 stat">
                    <h3>20+</h3>
                    <p>KỸ SƯ & THỢ</p>
                </div>
                <div class="col-6 col-md-3 stat">
                    <h3>3000kVA</h3>
                    <p>DẢI CÔNG SUẤT</p>
                </div>
                <div class="col-6 col-md-3 stat">
                    <h3>100%</h3>
                    <p>CHÍNH HÃNG</p>
                </div>
                <div class="col-6 col-md-3 stat">
                    <h3>24/7</h3>
                    <p>HỖ TRỢ</p>
                </div>
            </div>
        </div>
    </section>

    <section class="about-section">
        <div class="container">
            <div class="row align-items-start g-4">
                <div class="col-lg-6">
                    <img src="images/sanpham3.jpg" alt="Denyo" class="promo-image" loading="lazy" onerror="this.style.display='none'">
                </div>
                <div class="col-lg-6">
                    <h2 class="section-title center">KHẲNG ĐỊNH VỊ THẾ – CAM KẾT CHẤT LƯỢNG</h2>
                    <p>Với mạng lưới khách hàng trải dài khắp cả nước cùng sự tín nhiệm từ nhiều công trình lớn, <%= pageContext.getAttribute("siteName") != null ? pageContext.getAttribute("siteName") : "HOÀ LẠC ELECTRIC" %> đang từng bước khẳng định vị thế vững chắc trên thị trường máy phát điện công nghiệp.</p>
                    <p>Chúng tôi quy tụ đội ngũ kỹ sư giỏi, công nhân lành nghề và ban lãnh đạo trẻ – năng động, luôn thấu hiểu nhu cầu thực tế để mang đến giải pháp kỹ thuật tối ưu, tiết kiệm, hiệu quả cho Quý khách hàng.</p>
                    <h5>Chất lượng là kim chỉ nam</h5>
                    <ul>
                        <li>Sản phẩm đạt chuẩn kỹ thuật, công nghệ, pháp lý, an toàn và hiệu quả</li>
                        <li>Nhân lực chất lượng tạo nên sản phẩm chất lượng</li>
                        <li>Tư duy phục vụ tận tâm là nền tảng phát triển bền vững</li>
                    </ul>
                    <h5>Dịch vụ cam kết 3-3-30</h5>
                    <ul>
                        <li>Phản hồi sau 30 phút khi có sự cố</li>
                        <li>Có mặt trong 3 giờ, xử lý xong trong 3 ngày</li>
                    </ul>
                    <h5>Hỗ trợ toàn diện</h5>
                    <ul>
                        <li>Tư vấn miễn phí trước khi bán</li>
                        <li>Đề xuất giải pháp tối ưu</li>
                        <li>Chăm sóc sau bán hàng chuyên nghiệp</li>
                    </ul>
                </div>
            </div>
        </div>
    </section>

    <div class="container mb-5">
        <div class="cta text-center">
            <div class="row align-items-center">
                <div class="col-lg-8">
                    <h3 class="mb-2">Cần tư vấn giải pháp máy phát điện cho dự án của bạn?</h3>
                    <p class="mb-0">Gọi ngay Hotline <%= pageContext.getAttribute("sitePhone") != null ? pageContext.getAttribute("sitePhone") : "0989.888.999" %> hoặc để lại thông tin để được hỗ trợ nhanh nhất.</p>
                </div>
                <div class="col-lg-4 mt-3 mt-lg-0">
                    <a href="tel:<%= (pageContext.getAttribute("sitePhone") != null ? ((String)pageContext.getAttribute("sitePhone")).replaceAll("\\s+|\\.|-", "") : "0989888999") %>" class="btn">Gọi ngay</a>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="footer.jsp" %>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>


