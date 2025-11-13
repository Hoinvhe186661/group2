-- Migration: Thêm cột delivery_status vào contract_products
-- Thực hiện: Thêm trạng thái bàn giao cho sản phẩm trong hợp đồng

USE hlelectric;

-- Thêm cột delivery_status vào bảng contract_products
ALTER TABLE contract_products 
ADD COLUMN delivery_status ENUM('not_delivered', 'delivered') DEFAULT 'not_delivered' 
AFTER notes;


-- Cập nhật ENUM để chỉ còn 3 trạng thái
ALTER TABLE contracts
    MODIFY status ENUM('draft', 'active', 'terminated', 'deleted')
    NOT NULL DEFAULT 'draft';


-- Thêm trạng thái 'completed_late' vào ENUM status của bảng tasks
USE hlelectric;

-- Kiểm tra và cập nhật ENUM status để bao gồm 'completed_late'
ALTER TABLE tasks 
MODIFY COLUMN status ENUM('pending', 'in_progress', 'completed', 'completed_late', 'cancelled', 'rejected') DEFAULT 'pending';

-- Kiểm tra kết quả
SELECT COLUMN_NAME, COLUMN_TYPE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'hlelectric' 
  AND TABLE_NAME = 'tasks' 
  AND COLUMN_NAME = 'status';

SELECT 'Migration completed successfully! Status ENUM now includes completed_late' AS status;

