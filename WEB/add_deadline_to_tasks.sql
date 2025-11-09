-- Câu lệnh thêm trường deadline vào bảng tasks
-- Chạy câu lệnh này nếu bảng tasks đã tồn tại trong database

USE hlelectric;

ALTER TABLE tasks 
ADD COLUMN deadline DATETIME COMMENT 'Ngày deadline cho nhân viên thực hiện công việc' 
AFTER completion_date;

