<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hlgenerator.dao.SettingsDAO" %>
<%@ page import="com.hlgenerator.dao.ProductDAO" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%
    // Luôn load settings mới nhất từ database để đảm bảo hiển thị đúng giá trị đã cập nhật
    String footerPhone = "0989888999";
    String footerDescription = "Chuyên gia giải pháp máy phát điện công nghiệp";
    String footerName = "HOÀ LẠC ELECTRIC";
    String footerEmail = "contact@example.com";
    String footerAddress = "Đại Thanh, Hà Nội";
    
    try {
        SettingsDAO footerSettingsDAO = new SettingsDAO();
        Map<String, String> footerSettings = footerSettingsDAO.getAllSettings();
        
        // Lấy các giá trị settings, nếu không có thì dùng giá trị mặc định
        footerPhone = footerSettings.get("site_phone") != null ? footerSettings.get("site_phone") : footerPhone;
        footerDescription = footerSettings.get("site_description") != null ? footerSettings.get("site_description") : footerDescription;
        footerName = footerSettings.get("site_name") != null ? footerSettings.get("site_name") : footerName;
        footerEmail = footerSettings.get("site_email") != null ? footerSettings.get("site_email") : footerEmail;
        footerAddress = footerSettings.get("site_address") != null ? footerSettings.get("site_address") : footerAddress;
        
        // Cập nhật pageContext để các phần khác có thể dùng
        pageContext.setAttribute("sitePhone", footerPhone);
        pageContext.setAttribute("siteDescription", footerDescription);
        pageContext.setAttribute("siteName", footerName);
        pageContext.setAttribute("siteEmail", footerEmail);
        pageContext.setAttribute("siteAddress", footerAddress);
    } catch (Exception e) {
        // Nếu có lỗi, dùng giá trị từ pageContext hoặc giá trị mặc định
        String tempPhone = (String) pageContext.getAttribute("sitePhone");
        if (tempPhone != null) {
            footerPhone = tempPhone;
        } else {
            pageContext.setAttribute("sitePhone", footerPhone);
        }
        String tempDesc = (String) pageContext.getAttribute("siteDescription");
        if (tempDesc != null) {
            footerDescription = tempDesc;
        } else {
            pageContext.setAttribute("siteDescription", footerDescription);
        }
        // Đảm bảo các giá trị khác cũng được set
        if (pageContext.getAttribute("siteName") == null) {
            pageContext.setAttribute("siteName", footerName);
        }
        if (pageContext.getAttribute("siteEmail") == null) {
            pageContext.setAttribute("siteEmail", footerEmail);
        }
        if (pageContext.getAttribute("siteAddress") == null) {
            pageContext.setAttribute("siteAddress", footerAddress);
        }
    }
    
    // Load danh sách categories từ database để hiển thị trong footer
    List<String> productCategories = new java.util.ArrayList<String>();
    try {
        ProductDAO footerProductDAO = new ProductDAO();
        productCategories = footerProductDAO.getAllCategories();
        // Giới hạn tối đa 4 categories để hiển thị trong footer
        if (productCategories.size() > 4) {
            productCategories = productCategories.subList(0, 4);
        }
    } catch (Exception e) {
        // Nếu có lỗi, dùng danh sách mặc định
        productCategories.add("Máy phát điện Diesel");
        productCategories.add("Máy phát điện 3 pha");
        productCategories.add("Máy phát điện công nghiệp");
        productCategories.add("Phụ kiện máy phát điện");
    }
    
    // Nếu không có categories nào trong database, dùng danh sách mặc định
    if (productCategories.isEmpty()) {
        productCategories.add("Máy phát điện Diesel");
        productCategories.add("Máy phát điện 3 pha");
        productCategories.add("Máy phát điện công nghiệp");
        productCategories.add("Phụ kiện máy phát điện");
    }
    
    // Loại bỏ tất cả ký tự không phải số để dùng cho link Zalo và tel
    String cleanPhone = footerPhone != null ? footerPhone.replaceAll("[^0-9]", "") : "0989888999";
%>
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
                <h5><%= pageContext.getAttribute("siteName") != null ? pageContext.getAttribute("siteName") : "HOÀ LẠC ELECTRIC" %></h5>
                <p><%= pageContext.getAttribute("siteDescription") != null ? pageContext.getAttribute("siteDescription") : "Chuyên gia giải pháp máy phát điện công nghiệp với hơn 20 năm kinh nghiệm. Cam kết mang đến sản phẩm chất lượng cao và dịch vụ chuyên nghiệp." %></p>
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
                    <%
                        // Hiển thị danh sách categories từ database
                        for (String category : productCategories) {
                            if (category != null && !category.trim().isEmpty()) {
                                String encodedCategory = URLEncoder.encode(category, "UTF-8");
                                String displayName = category;
                                // Tạo link tìm kiếm theo category
                                String searchUrl = "guest-products?searchTerm=" + encodedCategory;
                    %>
                    <li><a href="<%= searchUrl %>"><%= displayName %></a></li>
                    <%
                            }
                        }
                    %>
                </ul>
            </div>
           
            <div class="col-lg-4 mb-4">
                <h5>Liên hệ</h5>
                <p><i class="fas fa-map-marker-alt me-2"></i> <%= pageContext.getAttribute("siteAddress") != null ? pageContext.getAttribute("siteAddress") : "Đại Thanh, Hà Nội" %></p>
                <p><i class="fas fa-phone me-2"></i> <%= pageContext.getAttribute("sitePhone") != null ? pageContext.getAttribute("sitePhone") : "0989 888 999" %></p>
                <p><i class="fas fa-envelope me-2"></i> <%= pageContext.getAttribute("siteEmail") != null ? pageContext.getAttribute("siteEmail") : "contact@example.com" %></p>
                <p><i class="fas fa-clock me-2"></i> Thứ 2 - Thứ 6: 08:00 - 17:00</p>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; 2024 <%= pageContext.getAttribute("siteName") != null ? pageContext.getAttribute("siteName") : "HOÀ LẠC ELECTRIC" %>. Tất cả quyền được bảo lưu.</p>
        </div>
    </div>
</footer>

<div class="floating-icons" aria-label="Quick contact actions">
    <a class="facebook" href="https://www.facebook.com/hoang.huy.439761" target="_blank" rel="noopener" aria-label="Facebook">
        <i class="fab fa-facebook-f"></i>
    </a>
    <a class="zalo" href="https://zalo.me/<%= cleanPhone %>" target="_blank" rel="noopener" aria-label="Zalo"><span>Z</span></a>
    <a class="phone" href="tel:<%= cleanPhone %>" aria-label="Gọi hotline">
        <i class="fas fa-phone"></i>
    </a>
    </div>