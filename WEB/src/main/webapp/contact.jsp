<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hlgenerator.dao.SettingsDAO" %>
<%@ page import="java.util.Map" %>
<%
    // Load settings từ database
    SettingsDAO settingsDAO = new SettingsDAO();
    Map<String, String> settings = settingsDAO.getAllSettings();
    
    // Lấy các giá trị settings, nếu không có thì dùng giá trị mặc định từ ảnh
    String siteName = settings.get("site_name") != null ? settings.get("site_name") : "Công ty CP Chế tạo máy Thăng Long";
    String siteEmail = settings.get("site_email") != null ? settings.get("site_email") : "mayphatdienthanglong@gmail.com";
    String sitePhone = settings.get("site_phone") != null ? settings.get("site_phone") : "0979538979";
    String siteAddress = settings.get("site_address") != null ? settings.get("site_address") : "Đội 4, đường Đại Thanh, xã Đại Thanh, Thành phố Hà Nội";
    
    // Địa chỉ cho Google Map (chi tiết hơn)
    String mapAddress = "123 Đường Láng, Đống Đa, Hà Nội";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liên hệ - <%= siteName %></title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-red: #dc3545;
            --dark-grey: #343a40;
            --light-grey: #f8f9fa;
            --white: #ffffff;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body { font-family: 'Roboto', sans-serif; line-height: 1.6; color: var(--dark-grey); background: var(--white); }

        .contact-page { padding: 60px 0; background: var(--white); }
        .contact-header { text-align: center; margin-bottom: 50px; }
        .contact-header h1 { color: var(--primary-red); font-size: 2.5rem; font-weight: 700; margin-bottom: 20px; }

        .contact-container { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; max-width: 1400px; margin: 0 auto; padding: 0 20px; }
        .contact-info-section { display: flex; flex-direction: column; gap: 30px; }

        .company-info { background: var(--white); padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .company-info h2 { color: var(--primary-red); font-size: 1.8rem; font-weight: 700; margin-bottom: 25px; }
        .contact-item { display: flex; align-items: flex-start; gap: 15px; margin-bottom: 20px; }
        .contact-item i { color: var(--primary-red); font-size: 20px; margin-top: 5px; flex-shrink: 0; }
        .contact-item span { color: var(--dark-grey); font-size: 16px; line-height: 1.6; }

        .contact-form-section { background: var(--white); padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .contact-form-section h2 { color: var(--primary-red); font-size: 1.8rem; font-weight: 700; margin-bottom: 25px; }

        .form-group { margin-bottom: 20px; }
        .form-group label { color: var(--dark-grey); font-weight: 500; margin-bottom: 8px; display: block; }
        .form-control { width: 100%; padding: 12px 15px; border: 1px solid #dee2e6; border-radius: 5px; font-size: 16px; transition: border-color 0.3s ease; }
        .form-control:focus { outline: none; border-color: var(--primary-red); box-shadow: 0 0 0 3px rgba(220, 53, 69, 0.1); }
        .form-control::placeholder { color: #adb5bd; }
        textarea.form-control { min-height: 120px; resize: vertical; }

        .submit-btn { background: var(--primary-red); color: var(--white); border: none; padding: 15px 40px; border-radius: 5px; font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.3s ease; width: 100%; }
        .submit-btn:hover { background: #c82333; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3); }
        .submit-btn:disabled { background: #6c757d; cursor: not-allowed; transform: none; }

        .map-section { height: 100%; min-height: 600px; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .map-container { width: 100%; height: 100%; min-height: 600px; }

        .alert { padding: 15px; margin-bottom: 20px; border-radius: 5px; display: none; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-danger { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alert.show { display: block; }

        @media (max-width: 968px) {
            .contact-container { grid-template-columns: 1fr; gap: 30px; }
            .contact-header h1 { font-size: 2rem; }
            .map-section { min-height: 400px; }
            .map-container { min-height: 400px; }
        }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="contact-page">
        <div class="container">
            <div class="contact-header">
                <h1>Liên hệ với chúng tôi</h1>
            </div>

            <div class="contact-container">
                <!-- Left Section: Company Info + Contact Form -->
                <div class="contact-info-section">
                    <!-- Company Information -->
                    <div class="company-info">
                        <h2><%= siteName %></h2>
                        <div class="contact-item">
                            <i class="fas fa-map-marker-alt"></i>
                            <span>Địa chỉ: <%= siteAddress %></span>
                        </div>
                        <div class="contact-item">
                            <i class="fas fa-phone"></i>
                            <span>Số điện thoại: <%= sitePhone %></span>
                        </div>
                        <div class="contact-item">
                            <i class="fas fa-envelope"></i>
                            <span>Email: <%= siteEmail %></span>
                        </div>
                    </div>

                    <!-- Contact Form -->
                    <div class="contact-form-section">
                        <h2>Liên hệ với chúng tôi</h2>
                        <div id="alertContainer"></div>
                        <form id="contactForm">
                            <div class="form-group">
                                <label for="fullName">Họ tên*</label>
                                <input type="text" class="form-control" id="fullName" name="fullName" placeholder="Họ tên*" maxlength="100" required>
                            </div>
                            <div class="form-group">
                                <label for="email">Email*</label>
                                <input type="email" class="form-control" id="email" name="email" placeholder="Email*" maxlength="100" pattern="^[A-Za-z0-9._%+-]+@(gmail\.com|fpt\.edu\.vn)$" title="Email phải thuộc miền gmail.com hoặc fpt.edu.vn" required>
                            </div>
                            <div class="form-group">
                                <label for="phone">Số điện thoại*</label>
                                <input type="tel" class="form-control" id="phone" name="phone" placeholder="Số điện thoại*" maxlength="11" pattern="^[0-9]{10,11}$" title="Số điện thoại phải gồm 10 hoặc 11 chữ số" required>
                            </div>
                            <div class="form-group">
                                <label for="message">Nhập nội dung*</label>
                                <textarea class="form-control" id="message" name="message" placeholder="Nhập nội dung*" maxlength="100" required></textarea>
                            </div>
                            <button type="submit" class="submit-btn" id="submitBtn">
                                <i class="fas fa-paper-plane"></i> Gửi liên hệ của bạn
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Right Section: Google Map -->
                <div class="map-section">
                    <div class="map-container" id="map">
                        <iframe 
                            src="https://www.google.com/maps?q=<%= java.net.URLEncoder.encode(mapAddress, "UTF-8") %>&output=embed&hl=vi"
                            width="100%" 
                            height="100%" 
                            style="border:0; min-height: 600px;" 
                            allowfullscreen="" 
                            loading="lazy" 
                            referrerpolicy="no-referrer-when-downgrade"
                            title="Bản đồ địa chỉ công ty">
                        </iframe>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="footer.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Xử lý form liên hệ
        document.getElementById('contactForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const submitBtn = document.getElementById('submitBtn');
            const originalText = submitBtn.innerHTML;
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang gửi...';

            // Client-side validation (email domain and phone format)
            const fullNameVal = document.getElementById('fullName').value.trim();
            const emailVal = document.getElementById('email').value.trim();
            const phoneVal = document.getElementById('phone').value.trim();
            const messageVal = document.getElementById('message').value.trim();

            // Email must be @gmail.com or @fpt.edu.vn
            const emailRegex = /^[A-Za-z0-9._%+-]+@(gmail\.com|fpt\.edu\.vn)$/i;
            if (!emailRegex.test(emailVal)) {
                showAlert('danger', 'Email phải thuộc miền gmail.com hoặc fpt.edu.vn');
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalText;
                return;
            }

            // Phone must be 10 or 11 digits
            const phoneRegex = /^\d{10,11}$/;
            if (!phoneRegex.test(phoneVal)) {
                showAlert('danger', 'Số điện thoại phải gồm 10 hoặc 11 chữ số và không chứa chữ cái');
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalText;
                return;
            }

            // Enforce maxlength on message and fullName (in case of older browsers)
            if (fullNameVal.length > 100 || messageVal.length > 100) {
                showAlert('danger', 'Họ tên và nội dung chỉ được phép tối đa 100 ký tự');
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalText;
                return;
            }

            const formData = new URLSearchParams();
            formData.append('fullName', fullNameVal);
            formData.append('email', emailVal);
            formData.append('phone', phoneVal);
            formData.append('message', messageVal);

            fetch('contact', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body: formData.toString()
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showAlert('success', 'Cảm ơn bạn đã liên hệ! Chúng tôi sẽ phản hồi sớm nhất có thể.');
                    document.getElementById('contactForm').reset();
                } else {
                    showAlert('danger', 'Có lỗi xảy ra: ' + (data.message || 'Không thể gửi liên hệ. Vui lòng thử lại sau.'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showAlert('danger', 'Có lỗi xảy ra khi gửi liên hệ. Vui lòng thử lại sau.');
            })
            .finally(() => {
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalText;
            });
        });

        function showAlert(type, message) {
            const alertContainer = document.getElementById('alertContainer');
            alertContainer.innerHTML = '<div class="alert alert-' + type + ' show">' + message + '</div>';
            
            // Tự động ẩn alert sau 5 giây
            setTimeout(() => {
                const alert = alertContainer.querySelector('.alert');
                if (alert) {
                    alert.classList.remove('show');
                    setTimeout(() => alert.remove(), 300);
                }
            }, 5000);
        }
    </script>
</body>
</html>

