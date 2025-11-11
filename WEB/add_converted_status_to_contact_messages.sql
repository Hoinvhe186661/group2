-- Thêm giá trị 'converted' vào ENUM của cột status trong bảng contact_messages
ALTER TABLE contact_messages 
MODIFY COLUMN status ENUM('new', 'read', 'replied', 'archived', 'converted') DEFAULT 'new';

