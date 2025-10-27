USE hlelectric;

ALTER TABLE tasks 
ADD COLUMN work_description TEXT COMMENT 'Mô tả công việc đã thực hiện';

ALTER TABLE tasks 
ADD COLUMN issues_found TEXT COMMENT 'Vấn đề phát sinh trong quá trình làm việc';

ALTER TABLE tasks 
ADD COLUMN completion_percentage DECIMAL(5,2) DEFAULT 100.00 COMMENT 'Phần trăm hoàn thành (0-100)';

ALTER TABLE tasks 
ADD COLUMN attachments JSON COMMENT 'Danh sách file đính kèm dạng JSON array';

ALTER TABLE tasks 
MODIFY COLUMN status ENUM('pending', 'in_progress', 'completed', 'cancelled', 'rejected') DEFAULT 'pending';

ALTER TABLE tasks 
ADD COLUMN rejection_reason VARCHAR(500) COMMENT 'Lý do từ chối nhiệm vụ';

SELECT COLUMN_NAME, DATA_TYPE, COLUMN_COMMENT 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'hlelectric' 
  AND TABLE_NAME = 'tasks' 
  AND COLUMN_NAME IN ('work_description', 'issues_found', 'completion_percentage', 'attachments', 'rejection_reason')
ORDER BY COLUMN_NAME;

SELECT 'Migration completed successfully!' AS status;
