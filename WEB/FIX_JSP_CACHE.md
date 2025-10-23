# 🔧 ĐÃ FIX LỖI JSP CACHE

## ❌ **LỖI TRƯỚC:**

```
Cannot switch on a value of type String for source level below 1.7
```

**Nguyên nhân:** Tomcat đang dùng **compiled JSP cũ từ cache**, không compile lại file mới.

---

## ✅ **ĐÃ FIX:**

### **1. Xóa Tomcat cache**
```bash
Remove-Item -Recurse -Force "group2\WEB\target\tomcat"
```

### **2. Rebuild & Restart**
```bash
mvn clean package tomcat7:run
```

---

## 🚀 **CÁCH TEST:**

### **1. Đợi server start xong**
Chờ thấy dòng:
```
INFO: Starting ProtocolHandler ["http-bio-8080"]
```

### **2. Login**
```
URL: http://localhost:8080/demo/login.jsp
Username: cussp
Password: 123
```

### **3. Kiểm tra redirect**
Sau khi login → Tự động chuyển đến:
```
http://localhost:8080/demo/support-management
```

**HOẶC** (nếu URL vẫn cũ):
```
http://localhost:8080/demo/support_management.jsp
```

---

## 🎯 **KẾT QUẢ MONG ĐỢI:**

✅ Trang load thành công  
✅ Hiển thị danh sách tickets  
✅ Filters hoạt động  
✅ KHÔNG còn lỗi "switch"  
✅ Tiếng Việt hiển thị đúng  

---

## ⚠️ **NẾU VẪN LỖI:**

### **Lỗi 1: Vẫn thấy switch error**
**Fix:**
```bash
# Stop server (Ctrl + C)
# Xóa toàn bộ target
Remove-Item -Recurse -Force "target"
# Build lại
mvn clean package tomcat7:run
```

### **Lỗi 2: 404 Not Found**
**Fix:** Đổi URL từ:
```
http://localhost:8080/demo/support_management.jsp
```
Thành:
```
http://localhost:8080/demo/support-management
```

### **Lỗi 3: Login redirect sai**
**Kiểm tra:** File `LoginServlet.java` có dòng:
```java
case "customer_support":
    redirectUrl = "/support-management";  // ← Phải là đúng
    break;
```

---

## 📂 **CẤU TRÚC URL:**

| URL Cũ (JSP trực tiếp) | URL Mới (MVC) |
|------------------------|---------------|
| `/support_management.jsp` | `/support-management` |
| `/customersupport.jsp` | - (không dùng) |

**→ BÂY GIỜ DÙNG SERVLET, KHÔNG TRUY CẬP JSP TRỰC TIẾP!**

---

## 🔄 **FLOW MỚI:**

```
User login với customer_support
    ↓
LoginServlet redirect → /support-management
    ↓
SupportManagementServlet.doGet()
    ├── Load tickets từ database
    ├── Áp dụng filters
    ├── Set attributes
    └── Forward → support_management.jsp
         ↓
    JSP render HTML (JSTL/EL)
         ↓
    Browser hiển thị
```

---

## 💡 **LƯU Ý:**

1. **JSP được compile lần đầu truy cập** → Lần đầu hơi chậm, lần sau nhanh hơn
2. **Sửa JSP → Tự động recompile** khi reload browser (nếu server đang chạy)
3. **Sửa Servlet → Phải restart server** (vì đã compiled thành .class)
4. **Clear cache browser:** Ctrl + Shift + R (Windows) hoặc Cmd + Shift + R (Mac)

---

## 🎉 **HOÀN TẤT!**

Server đang chạy background. Hãy:
1. Đợi server start xong
2. Mở browser → http://localhost:8080/demo/login.jsp
3. Login với `cussp / 123`
4. Tự động chuyển đến trang quản lý tickets!

