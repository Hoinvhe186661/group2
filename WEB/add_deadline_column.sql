-- Câu lệnh thêm trường deadline vào bảng support_requests
-- Chạy câu lệnh này nếu bảng support_requests đã tồn tại trong database

USE hlelectric;

ALTER TABLE support_requests 
ADD COLUMN deadline DATE COMMENT 'Ngày mong muốn công việc hoàn thành' 
AFTER resolved_at;

