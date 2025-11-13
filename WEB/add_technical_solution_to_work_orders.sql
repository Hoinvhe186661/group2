-- Migration script to add technical_solution column to work_orders table
-- Run this script to add the technical_solution field to the work_orders table

USE hlelectric;

ALTER TABLE work_orders
ADD COLUMN technical_solution TEXT COMMENT 'Giải pháp kỹ thuật để xử lý yêu cầu';

SELECT 'Migration completed successfully! Column technical_solution added to work_orders table.' AS status;

