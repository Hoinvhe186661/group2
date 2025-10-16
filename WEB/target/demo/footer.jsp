<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Shared Footer --%>
<style>
    .footer { background: #2c3e50; color: #ecf0f1; padding: 50px 0 20px; }
    .footer h5 { color: #e74c3c; font-weight: 700; margin-bottom: 20px; text-transform: uppercase; }
    .footer p, .footer li { color: #bdc3c7; line-height: 1.8; }
    .footer a { color: #bdc3c7; text-decoration: none; transition: color 0.3s; }
    .footer a:hover { color: #e74c3c; }
    .footer-bottom { border-top: 1px solid #34495e; padding-top: 20px; margin-top: 30px; text-align: center; }
    .social-icons { display: flex; gap: 15px; margin-top: 15px; }
    .social-icons a { display: inline-block; width: 40px; height: 40px; background: #34495e; border-radius: 50%; text-align: center; line-height: 40px; transition: background 0.3s; }
    .social-icons a:hover { background: #e74c3c; }

    /* Floating action buttons (FB, Zalo, Call) */
    .floating-icons { position: fixed; right: 18px; bottom: 22px; z-index: 9999; display: flex; flex-direction: column; gap: 12px; }
    .floating-icons a { width: 52px; height: 52px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #fff; box-shadow: 0 8px 20px rgba(0,0,0,.25); transition: transform .15s ease, box-shadow .15s ease; text-decoration: none; }
    .floating-icons a:hover { transform: translateY(-2px); box-shadow: 0 10px 26px rgba(0,0,0,.3); }
    .floating-icons .facebook { background: #1877f2; }
    .floating-icons .zalo { background: #0068ff; font-weight: 700; }
    .floating-icons .phone { background: #dc3545; }
    .floating-icons .zalo span { font-size: 14px; letter-spacing: .5px; }
    @media (max-width: 768px) { .floating-icons a { width: 46px; height: 46px; } }
</style>

<footer class="footer">
    <div class="container">
        <div class="row">
            <div class="col-lg-4 mb-4">
                <h5>HOÀ LẠC ELECTRIC</h5>
                <p>Chuyên gia giải pháp máy phát điện công nghiệp với hơn 20 năm kinh nghiệm. Cam kết mang đến sản phẩm chất lượng cao và dịch vụ chuyên nghiệp.</p>
                <div class="social-icons">
                    <a href="#"><i class="fab fa-facebook-f"></i></a>
                    <a href="#"><i class="fab fa-youtube"></i></a>
                    <a href="#"><i class="fab fa-linkedin-in"></i></a>
                    <a href="#"><i class="fab fa-instagram"></i></a>
                </div>
            </div>
            <div class="col-lg-2 col-md-6 mb-4">
                <h5>Sản phẩm</h5>
                <ul class="list-unstyled">
                    <li><a href="#">Máy phát điện Diesel</a></li>
                    <li><a href="#">Máy phát điện 3 pha</a></li>
                    <li><a href="#">Máy phát điện công nghiệp</a></li>
                    <li><a href="#">Phụ kiện máy phát điện</a></li>
                </ul>
            </div>
            <div class="col-lg-2 col-md-6 mb-4">
                <h5>Dịch vụ</h5>
                <ul class="list-unstyled">
                    <li><a href="#">Cho thuê máy phát điện</a></li>
                    <li><a href="#">Sửa chữa & bảo trì</a></li>
                    <li><a href="#">Tư vấn kỹ thuật</a></li>
                    <li><a href="#">Lắp đặt hệ thống</a></li>
                </ul>
            </div>
            <div class="col-lg-4 mb-4">
                <h5>Liên hệ</h5>
                <p><i class="fas fa-map-marker-alt me-2"></i> Đại Thanh, Hà Nội</p>
                <p><i class="fas fa-phone me-2"></i> 0989.888.999</p>
                <p><i class="fas fa-envelope me-2"></i> Mayphatdienhoalac@gmail.com</p>
                <p><i class="fas fa-clock me-2"></i> Thứ 2 - Thứ 6: 08:00 - 17:00</p>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; 2024 HOÀ LẠC ELECTRIC. Tất cả quyền được bảo lưu.</p>
        </div>
    </div>
</footer>

<!-- Floating action buttons: Facebook, Zalo, Call -->
<div class="floating-icons" aria-label="Quick contact actions">
    <a class="facebook" href="https://facebook.com" target="_blank" rel="noopener" aria-label="Facebook">
        <i class="fab fa-facebook-f"></i>
    </a>
    <a class="zalo" href="https://zalo.me/0989888999" target="_blank" rel="noopener" aria-label="Zalo"><span>Z</span></a>
    <a class="phone" href="tel:0989888999" aria-label="Gọi hotline">
        <i class="fas fa-phone"></i>
    </a>
    </div>