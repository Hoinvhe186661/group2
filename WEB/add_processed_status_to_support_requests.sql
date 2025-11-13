-- Migration script: Thêm status 'processed' (đã xử lý) vào bảng support_requests
-- Chạy script này nếu bảng support_requests đã tồn tại

-- Thêm giá trị 'processed' vào ENUM status
ALTER TABLE support_requests 
MODIFY COLUMN status ENUM('open', 'in_progress', 'processed', 'resolved', 'closed') DEFAULT 'open';



