-- Sample seed data for "Nhiệm vụ của tôi"
-- Assumes database name is hlelectric
USE hlelectric;

-- 1) Ensure technical staff user exists
INSERT INTO users (username, email, password_hash, full_name, phone, role, permissions, is_active)
SELECT 'nhanvienkithuat', 'nhanvienkithuat@example.com',
       -- bcrypt placeholder (same as admin seed in database.sql); change later if needed
       '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
       'Nhân Viên Kỹ Thuật', '0909000000', 'technical_staff', '[]', TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'nhanvienkithuat');

-- Fetch user id into variable (works in MySQL client/session)
SET @tech_user_id = (SELECT id FROM users WHERE username = 'nhanvienkithuat');

-- 2) Ensure a demo customer exists (for work order context)
INSERT INTO customers (customer_code, company_name, contact_person, email, phone, address, status)
SELECT 'CUST-DEMO-001', 'Công ty Khách Hàng Demo', 'Anh Demo', 'demo.customer@example.com', '0912000000', '123 Demo Street, HN', 'active'
WHERE NOT EXISTS (SELECT 1 FROM customers WHERE customer_code = 'CUST-DEMO-001');

SET @cust_id = (SELECT id FROM customers WHERE customer_code = 'CUST-DEMO-001');

-- 3) Insert a demo work order assigned to the technical user
INSERT INTO work_orders (
    work_order_number, customer_id, contract_id, title, description, priority, status,
    assigned_to, estimated_hours, actual_hours, scheduled_date, created_by
) VALUES (
    'WO-TEST-001', @cust_id, NULL,
    'Bảo trì máy phát điện',
    'Kiểm tra định kỳ và vệ sinh bộ lọc, đo điện áp đầu ra.',
    'high', 'pending',
    @tech_user_id,
    8.00, NULL, CURDATE(), @tech_user_id
)
ON DUPLICATE KEY UPDATE title = VALUES(title), description = VALUES(description), assigned_to = VALUES(assigned_to);

SET @wo_id = (SELECT id FROM work_orders WHERE work_order_number = 'WO-TEST-001');

-- 4) Insert demo tasks under that work order
INSERT INTO tasks (
    work_order_id, task_number, task_description, status, priority, estimated_hours, notes
) VALUES
    (@wo_id, 'T-001', 'Vệ sinh lọc gió và kiểm tra dây cu-roa', 'pending', 'medium', 2.0, NULL),
    (@wo_id, 'T-002', 'Đo điện áp đầu ra và kiểm tra bộ điều tốc', 'pending', 'high', 3.0, NULL),
    (@wo_id, 'T-003', 'Cập nhật biên bản bảo trì', 'pending', 'low', 1.0, NULL)
ON DUPLICATE KEY UPDATE task_description = VALUES(task_description), priority = VALUES(priority);

-- Capture task ids (first 2 by numbers) for assignment
SET @t1 = (SELECT id FROM tasks WHERE work_order_id = @wo_id AND task_number = 'T-001');
SET @t2 = (SELECT id FROM tasks WHERE work_order_id = @wo_id AND task_number = 'T-002');
SET @t3 = (SELECT id FROM tasks WHERE work_order_id = @wo_id AND task_number = 'T-003');

-- 5) Assign tasks to the technical user
INSERT INTO task_assignments (task_id, user_id, role)
SELECT @t1, @tech_user_id, 'assignee'
WHERE NOT EXISTS (SELECT 1 FROM task_assignments WHERE task_id = @t1 AND user_id = @tech_user_id);

INSERT INTO task_assignments (task_id, user_id, role)
SELECT @t2, @tech_user_id, 'assignee'
WHERE NOT EXISTS (SELECT 1 FROM task_assignments WHERE task_id = @t2 AND user_id = @tech_user_id);

INSERT INTO task_assignments (task_id, user_id, role)
SELECT @t3, @tech_user_id, 'assignee'
WHERE NOT EXISTS (SELECT 1 FROM task_assignments WHERE task_id = @t3 AND user_id = @tech_user_id);

-- Done.

