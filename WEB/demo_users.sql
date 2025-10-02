-- Demo users for testing login functionality
-- Run this after creating the hlelectric database

USE hlelectric;

-- Clear existing demo users if any
DELETE FROM users WHERE username IN ('admin', 'technician1');

-- Insert demo users with simple passwords for testing
INSERT INTO users (username, email, password_hash, full_name, role, permissions, is_active) VALUES
('admin', 'admin@hlgenerator.com', 'password', 'System Administrator', 'admin', '["all_permissions"]', TRUE),
('technician1', 'tech1@hlgenerator.com', 'password', 'Nguyễn Văn Tâm', 'head_technician', '["view_work_orders", "manage_tasks", "view_inventory"]', TRUE);

-- You can also test with these passwords: password, admin123, 123456

SELECT 'Demo users created successfully!' as message;
SELECT username, email, role, is_active FROM users WHERE username IN ('admin', 'technician1');
