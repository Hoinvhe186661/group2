# 🗄️ Hướng dẫn Setup Database - HL Generator Solutions

## 📋 Yêu cầu hệ thống

- **MySQL**: Version 8.0 trở lên
- **Java**: Version 17 trở lên
- **Maven**: Version 3.6 trở lên

## 🚀 Cách 1: Sử dụng Script tự động (Khuyến nghị)

### Windows (Batch):
```bash
# Chạy script setup database
run_database.bat
```

### Windows (PowerShell):
```powershell
# Chạy script setup database
.\run_database.ps1
```

## 🛠️ Cách 2: Setup thủ công

### Bước 1: Khởi động MySQL
```bash
# Windows
net start mysql

# Linux/Mac
sudo systemctl start mysql
# hoặc
sudo service mysql start
```

### Bước 2: Tạo database và import dữ liệu
```bash
# Kết nối MySQL
mysql -u root -p

# Chạy script database
source database.sql
```

### Bước 3: Kiểm tra database
```sql
USE hl_electric;
SHOW TABLES;
SELECT COUNT(*) FROM users;
```

## ⚙️ Cấu hình kết nối

### 1. Cập nhật file `database.properties`:
```properties
# Database Configuration
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/hl_electric?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8
db.username=root
db.password=your_password_here

# Connection Pool Settings
db.pool.maximumPoolSize=20
db.pool.minimumIdle=5
db.pool.connectionTimeout=30000
db.pool.idleTimeout=600000
db.pool.maxLifetime=1800000
```

### 2. Thay đổi thông tin kết nối:
- `db.url`: URL kết nối MySQL
- `db.username`: Tên đăng nhập MySQL
- `db.password`: Mật khẩu MySQL

## 👤 Tài khoản mặc định

Sau khi setup database, bạn có thể sử dụng tài khoản admin mặc định:

- **Username**: `admin`
- **Password**: `admin123`
- **Role**: `admin`

## 🔧 Troubleshooting

### Lỗi kết nối MySQL:
```
Error: Could not connect to MySQL
```
**Giải pháp:**
1. Kiểm tra MySQL service đang chạy
2. Kiểm tra port 3306 có bị chiếm không
3. Kiểm tra username/password

### Lỗi database không tồn tại:
```
Error: Unknown database 'hl_electric'
```
**Giải pháp:**
1. Chạy lại script `database.sql`
2. Kiểm tra quyền của user MySQL

### Lỗi encoding:
```
Error: Incorrect string value
```
**Giải pháp:**
1. Đảm bảo MySQL sử dụng UTF-8
2. Kiểm tra collation của database

## 📊 Cấu trúc Database

Database `hl_electric` bao gồm các bảng chính:

- **users**: Quản lý người dùng hệ thống
- **customers**: Thông tin khách hàng
- **products**: Danh mục sản phẩm
- **inventory**: Quản lý kho
- **work_orders**: Đơn hàng công việc
- **invoices**: Hóa đơn
- **equipment**: Thiết bị
- **settings**: Cài đặt hệ thống

## 🚀 Chạy ứng dụng

Sau khi setup database thành công:

```bash
# Di chuyển vào thư mục WEB
cd WEB

# Chạy ứng dụng
mvn tomcat7:run
```

Truy cập:
- **Trang chủ**: http://localhost:8080/
- **Admin Panel**: http://localhost:8080/admin/login.jsp

## 📝 Ghi chú

- Database sẽ được tạo tự động nếu chưa tồn tại
- Tất cả dữ liệu mẫu sẽ được import
- Connection pool được cấu hình để tối ưu hiệu suất
- Mật khẩu được hash bằng SHA-256

## 🆘 Hỗ trợ

Nếu gặp vấn đề, vui lòng kiểm tra:
1. Logs trong console
2. File `database.properties`
3. Kết nối MySQL
4. Quyền truy cập database
