-- Script để thêm permission send_marketing_email vào hệ thống
-- Chạy script này để thêm quyền gửi email marketing

-- Thêm permission mới
INSERT INTO permissions (perm_key, perm_name, group_name) VALUES
('send_marketing_email', 'Gửi email marketing', 'Quản trị')
ON DUPLICATE KEY UPDATE perm_name = VALUES(perm_name), group_name = VALUES(group_name);

-- Gán quyền send_marketing_email cho role customer_support (Hỗ trợ khách hàng)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.role_key = 'customer_support' AND p.perm_key = 'send_marketing_email'
ON DUPLICATE KEY UPDATE permission_id = permission_id;

-- Lưu ý: Admin đã có quyền manage_email nên có thể gửi cả email nội bộ và marketing
-- Nếu muốn gán quyền send_marketing_email cho các role khác, chạy các câu lệnh tương tự:
-- Ví dụ: Gán cho role khác (thay 'role_key' bằng role muốn gán)
-- INSERT INTO role_permissions (role_id, permission_id)
-- SELECT r.id, p.id FROM roles r, permissions p
-- WHERE r.role_key = 'role_key' AND p.perm_key = 'send_marketing_email'
-- ON DUPLICATE KEY UPDATE permission_id = permission_id;

