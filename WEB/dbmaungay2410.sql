-- Script cập nhật database để hỗ trợ soft delete
USE hlelectric;

-- Kiểm tra và thêm cột deleted_by
SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'hlelectric' 
    AND TABLE_NAME = 'contracts' 
    AND COLUMN_NAME = 'deleted_by'
);

SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE contracts ADD COLUMN deleted_by INT NULL',
    'SELECT "Column deleted_by already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Kiểm tra và thêm cột deleted_at
SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'hlelectric' 
    AND TABLE_NAME = 'contracts' 
    AND COLUMN_NAME = 'deleted_at'
);

SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE contracts ADD COLUMN deleted_at TIMESTAMP NULL',
    'SELECT "Column deleted_at already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Kiểm tra và thêm foreign key constraint
SET @constraint_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
    WHERE TABLE_SCHEMA = 'hlelectric' 
    AND TABLE_NAME = 'contracts' 
    AND CONSTRAINT_NAME = 'fk_contracts_deleted_by'
);

SET @sql = IF(@constraint_exists = 0, 
    'ALTER TABLE contracts ADD CONSTRAINT fk_contracts_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id) ON DELETE SET NULL',
    'SELECT "Constraint fk_contracts_deleted_by already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Cập nhật ENUM status để bao gồm 'deleted'
ALTER TABLE contracts 
MODIFY COLUMN status ENUM('draft', 'active', 'completed', 'terminated', 'expired', 'deleted') DEFAULT 'draft';

-- Kiểm tra kết quả
DESCRIBE contracts;

-- Kiểm tra các hợp đồng hiện tại
SELECT id, contract_number, status, deleted_by, deleted_at 
FROM contracts 
ORDER BY id;


-- Kiểm tra và thêm trạng thái 'rejected' vào ENUM status của bảng tasks
SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'hlelectric' 
    AND TABLE_NAME = 'tasks' 
    AND COLUMN_NAME = 'status'
);

-- Cập nhật ENUM status để bao gồm 'rejected'
ALTER TABLE tasks 
MODIFY COLUMN status ENUM('pending', 'in_progress', 'completed', 'cancelled', 'rejected') DEFAULT 'pending';

-- Kiểm tra và thêm cột rejection_reason
SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'hlelectric' 
    AND TABLE_NAME = 'tasks' 
    AND COLUMN_NAME = 'rejection_reason'
);

SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE tasks ADD COLUMN rejection_reason TEXT NULL AFTER completion_date',
    'SELECT "Column rejection_reason already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Kiểm tra kết quả
DESCRIBE tasks;