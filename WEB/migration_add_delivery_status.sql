-- Migration: Thêm cột delivery_status vào contract_products
-- Thực hiện: Thêm trạng thái bàn giao cho sản phẩm trong hợp đồng

USE hlelectric;

-- Thêm cột delivery_status vào bảng contract_products
ALTER TABLE contract_products 
ADD COLUMN delivery_status ENUM('not_delivered', 'delivered') DEFAULT 'not_delivered' 
AFTER notes;

-- Cập nhật tất cả các bản ghi hiện có thành 'not_delivered' (chưa bàn giao)
UPDATE contract_products 
SET delivery_status = 'not_delivered' 
WHERE delivery_status IS NULL AND id > 0;

-- Migration: Cập nhật trạng thái hợp đồng từ 5 trạng thái xuống 3 trạng thái
-- Chuyển pending_approval và approved thành active

-- Chuyển pending_approval -> active
UPDATE contracts 
SET status = 'active' 
WHERE status = 'pending_approval' AND id > 0;

-- Chuyển approved -> active  
UPDATE contracts 
SET status = 'active' 
WHERE status = 'approved' AND id > 0;

-- Cập nhật ENUM để chỉ còn 3 trạng thái
ALTER TABLE contracts
    MODIFY status ENUM('draft', 'active', 'terminated', 'deleted')
    NOT NULL DEFAULT 'draft';

