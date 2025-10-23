<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Shared Header: Top bar + Logo/Search + Menu --%>
<style>
    .top-header { background: #dc3545; color: #ffffff; padding: 8px 0; font-size: 14px; }
    .header-text { font-weight: 600; text-transform: uppercase; }
    .contact-info { margin-right: 20px; }
    .header-navbar { background: #ffffff; box-shadow: 0 2px 10px rgba(0,0,0,0.1); padding: 15px 0; }
    .menu-navbar { background: #eeeeee; border-top: 1px solid #e5e5e5; border-bottom: 1px solid #e5e5e5; padding: 8px 0; }
    .logo-container { display:flex; align-items:center; }
    .logo-icon { width:60px; height:60px; border-radius:50%; margin-right:15px; overflow:hidden; }
    .logo-icon img { width:100%; height:100%; object-fit:cover; }
    .logo-text { color:#343a40; font-size:16px; font-weight:600; line-height:1.2; }
    .search-container { position:relative; margin:0 20px; }
    .search-input { width:300px; padding:12px 45px 12px 15px; border:1px solid #dee2e6; border-radius:25px; font-size:14px; }
    .search-icon { position:absolute; right:15px; top:50%; transform:translateY(-50%); color:#6c757d; }
    .contact-info-nav { display:flex; align-items:center; gap:20px; }
    .phone-number { color:#dc3545; font-weight:600; font-size:16px; }
    .nav-icons { display:flex; gap:15px; }
    .nav-icons i { font-size:20px; color:#343a40; cursor:pointer; }
    .nav-icons a { color: inherit; text-decoration: none; transition: color 0.3s ease; }
    .nav-icons a:hover { color: #dc3545; }
    .management-icon-link { 
        position: relative; 
        display: inline-flex; 
        align-items: center;
        justify-content: center;
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: linear-gradient(135deg, #dc3545, #c82333);
        color: white !important;
        margin-right: 10px;
        transition: all 0.3s ease;
        box-shadow: 0 2px 8px rgba(220, 53, 69, 0.3);
    }
    .management-icon-link:hover { 
        color: white !important; 
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(220, 53, 69, 0.5);
    }
    .management-icon-link i { 
        font-size: 15px; 
        color: white;
    }
    .navbar-nav .nav-link { color:#343a40 !important; font-weight:500; margin:0 8px; padding:8px 12px !important; text-transform:uppercase; font-size:14px; }
    .navbar-nav .nav-link:hover { color:#dc3545 !important; }
    .navbar-nav .nav-link.active { color:#dc3545 !important; font-weight:700; }
</style>

<div class="top-header" data-logged-in="${sessionScope.isLoggedIn eq true}">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-md-6"><span class="header-text">MÁY PHÁT ĐIỆN CÔNG NGHIỆP</span></div>
            <div class="col-md-6 text-end">
                <span class="contact-info"><i class="fas fa-envelope"></i> Mayphatdienhoalac@gmail.com</span>
                <span class="contact-info"><i class="fas fa-clock"></i> 08:00 - 17:00</span>
            </div>
        </div>
    </div>
</div>

<nav class="navbar header-navbar navbar-expand-lg navbar-light bg-white" aria-label="Thanh điều hướng logo, tìm kiếm và tài khoản">
    <div class="container">
        <a class="navbar-brand" href="index.jsp">
            <div class="logo-container">
                <div class="logo-icon">
                    <img src="images/logo.png" alt="Logo Hoà Lạc" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                    <div style="display:none; width:100%; height:100%; background:#dc3545; border-radius:50%; align-items:center; justify-content:center; color:white; font-size:20px;">★</div>
                </div>
                <div class="logo-text"><strong>HOÀ LẠC ELECTRIC INDUSTRIAL GENERATOR</strong></div>
            </div>
        </a>
        <div class="search-container" role="search">
            <input type="text" class="search-input" placeholder="Tìm kiếm...">
            <i class="fas fa-search search-icon"></i>
        </div>
        <div class="contact-info-nav">
            <div class="phone-number"><i class="fas fa-phone"></i> 0989.888.999</div>
            <div class="nav-icons">
                <c:choose>
                    <c:when test="${sessionScope.isLoggedIn eq true}">
                        <%-- Icon quản lý cho staff/admin --%>
                        <c:choose>
                            <c:when test="${sessionScope.userRole eq 'admin'}">
                                <a href="${pageContext.request.contextPath}/admin.jsp" class="management-icon-link" title="Trang quản trị">
                                    <i class="fas fa-user-cog"></i>
                                </a>
                            </c:when>
                            <c:when test="${sessionScope.userRole eq 'customer_support'}">
                                <a href="${pageContext.request.contextPath}/customersupport.jsp" class="management-icon-link" title="Trang quản lý">
                                    <i class="fas fa-headset"></i>
                                </a>
                            </c:when>
                            <c:when test="${sessionScope.userRole eq 'head_technician'}">
                                <a href="${pageContext.request.contextPath}/headtech.jsp" class="management-icon-link" title="Trang quản lý">
                                    <i class="fas fa-user-tie"></i>
                                </a>
                            </c:when>
                            <c:when test="${sessionScope.userRole eq 'technical_staff'}">
                                <a href="${pageContext.request.contextPath}/technical_staff.jsp" class="management-icon-link" title="Trang quản lý">
                                    <i class="fas fa-tools"></i>
                                </a>
                            </c:when>
                            <c:when test="${sessionScope.userRole eq 'storekeeper'}">
                                <a href="${pageContext.request.contextPath}/product" class="management-icon-link" title="Trang quản lý">
                                    <i class="fas fa-warehouse"></i>
                                </a>
                            </c:when>
                        </c:choose>
                        
                        <a href="profile.jsp" class="user-info" style="color: #dc3545; font-weight: 600; margin-right: 15px; text-decoration:none;">
                            <i class="fas fa-user"></i>
                            <c:out value="${empty sessionScope.fullName ? sessionScope.username : sessionScope.fullName}"/>
                        </a>
                        <a href="logout" style="color: inherit; text-decoration: none;" title="Đăng xuất">
                            <i class="fas fa-sign-out-alt"></i>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="login.jsp" style="color: inherit; text-decoration: none;" title="Đăng nhập">
                            <i class="fas fa-user"></i>
                        </a>
                    </c:otherwise>
                </c:choose>
                <i class="fas fa-shopping-bag"></i>
            </div>
        </div>
    </div>
</nav>

<nav class="menu-navbar" aria-label="Thanh menu chính">
    <div class="container">
        <ul class="navbar-nav flex-row justify-content-center w-100">
            <li class="nav-item"><a class="nav-link" href="index.jsp" id="nav-home">TRANG CHỦ</a></li>
            <li class="nav-item"><a class="nav-link" href="about.jsp" id="nav-about">GIỚI THIỆU</a></li>
            <li class="nav-item"><a class="nav-link" href="#products">MÁY PHÁT ĐIỆN</a></li>
            <li class="nav-item"><a class="nav-link" href="#services">DỊCH VỤ</a></li>
            <li class="nav-item"><a class="nav-link" href="#projects">DỰ ÁN</a></li>
            <li class="nav-item"><a class="nav-link" href="#guide">HƯỚNG DẪN</a></li>
            <li class="nav-item"><a class="nav-link" href="#news">TIN TỨC</a></li>
            <li class="nav-item"><a class="nav-link" href="#contact">LIÊN HỆ</a></li>
            <c:if test="${sessionScope.isLoggedIn eq true}">
                <li class="nav-item"><a class="nav-link" href="support.jsp" id="nav-support">HỖ TRỢ</a></li>
            </c:if>
        </ul>
    </div>
</nav>

<script>
// Auto-set active menu item based on current page
document.addEventListener('DOMContentLoaded', function() {
    const currentPage = window.location.pathname.split('/').pop();
    const navLinks = document.querySelectorAll('.navbar-nav .nav-link');
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        const href = link.getAttribute('href');
        
        if (href === 'index.jsp' && (currentPage === 'index.jsp' || currentPage === '')) {
            link.classList.add('active');
        } else if (href === 'about.jsp' && currentPage === 'about.jsp') {
            link.classList.add('active');
        } else if (href === 'support.jsp' && currentPage === 'support.jsp') {
            link.classList.add('active');
        }
    });
});

// Note: auto-logout on tab close was removed to avoid logging out on refresh
</script>