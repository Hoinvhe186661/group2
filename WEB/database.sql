USE hlelectric;

-- 1. USERS
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    reset_token VARCHAR(100),
    reset_token_expires_at DATETIME,
    full_name VARCHAR(100),
    phone VARCHAR(20),
    customer_id INT NULL,
    role ENUM('admin', 'customer_support', 'technical_staff', 'head_technician', 'storekeeper', 'customer', 'guest') NOT NULL,
    permissions JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Add index for faster joins on customer_id
CREATE INDEX idx_users_customer_id ON users(customer_id);

-- Add foreign key constraint for customer_id
ALTER TABLE users
    ADD CONSTRAINT fk_users_customer
    FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON DELETE SET NULL;

-- 2. CUSTOMERS
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_code VARCHAR(20) UNIQUE NOT NULL,
    company_name VARCHAR(200),
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    tax_code VARCHAR(20),
    customer_type ENUM('individual', 'company') DEFAULT 'company',
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 3. CONTRACTS
CREATE TABLE contracts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    contract_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    contract_type VARCHAR(50),
    title VARCHAR(200),
    start_date DATE,
    end_date DATE,
    contract_value DECIMAL(15,2),
    status ENUM('draft', 'pending_approval', 'approved', 'active', 'terminated') DEFAULT 'draft',
    terms TEXT,
    signed_date DATE,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- 4. SUPPLIERS
CREATE TABLE suppliers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_code VARCHAR(20) UNIQUE NOT NULL,
    company_name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    bank_info JSON,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. PRODUCTS
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_code VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    description TEXT,
    unit VARCHAR(20) DEFAULT 'pcs',
    unit_price DECIMAL(10,2),
    supplier_id INT,
    specifications TEXT,
    image_url VARCHAR(500),
    warranty_months INT DEFAULT 12,
    status ENUM('active', 'discontinued') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- 6. CONTRACT_PRODUCTS
CREATE TABLE contract_products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    contract_id INT NOT NULL,
    product_id INT NOT NULL,
    description VARCHAR(500),
    quantity DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    line_total DECIMAL(15,2) GENERATED ALWAYS AS (quantity*unit_price) STORED,
    warranty_months INT,
    notes TEXT,
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 7. INVENTORY
CREATE TABLE inventory (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    warehouse_location VARCHAR(100) DEFAULT 'Main Warehouse',
    current_stock INT DEFAULT 0,
    min_stock INT DEFAULT 0,
    max_stock INT DEFAULT 1000,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_product_location (product_id, warehouse_location)
);

-- 8. STOCK_HISTORY
CREATE TABLE stock_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    warehouse_location VARCHAR(100) DEFAULT 'Main Warehouse',
    movement_type ENUM('in', 'out', 'adjustment') NOT NULL,
    quantity INT NOT NULL,
    reference_type VARCHAR(50),
    reference_id INT,
    unit_cost DECIMAL(10,2),
    notes TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- 9. WORK_ORDERS
CREATE TABLE work_orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    work_order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    contract_id INT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    assigned_to INT,
    estimated_hours DECIMAL(5,2),
    actual_hours DECIMAL(5,2),
    scheduled_date DATE,
    completion_date DATE,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    technical_solution TEXT COMMENT 'Giải pháp kỹ thuật để xử lý yêu cầu',
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
    FOREIGN KEY (assigned_to) REFERENCES users(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- 10. TASKS
CREATE TABLE tasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    work_order_id INT NOT NULL,
    task_number VARCHAR(20),
    task_description TEXT NOT NULL,
    status ENUM('pending', 'in_progress', 'completed', 'cancelled', 'rejected') DEFAULT 'pending',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    estimated_hours DECIMAL(5,2),
    acknowledged_at DATETIME COMMENT 'Ngày nhận công việc',
    actual_hours DECIMAL(5,2),
    start_date DATETIME,
    completion_date DATETIME,
    deadline DATETIME COMMENT 'Ngày deadline cho nhân viên thực hiện công việc',
    rejection_reason VARCHAR(500) COMMENT 'Lý do từ chối nhiệm vụ',
    notes TEXT,
    work_description TEXT COMMENT 'Mô tả công việc đã thực hiện',
    issues_found TEXT COMMENT 'Vấn đề phát sinh trong quá trình làm việc',
    completion_percentage DECIMAL(5,2) DEFAULT 100.00 COMMENT 'Phần trăm hoàn thành (0-100)',
    attachments JSON COMMENT 'Danh sách file đính kèm dạng JSON array',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (work_order_id) REFERENCES work_orders(id) ON DELETE CASCADE
);

-- 11. TASK_ASSIGNMENTS
CREATE TABLE task_assignments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT NOT NULL,
    user_id INT NOT NULL,
    role VARCHAR(50),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_task_user (task_id, user_id)
);

-- 12. SUPPORT_REQUESTS
CREATE TABLE support_requests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    subject VARCHAR(200) NOT NULL,
    description TEXT,
    category ENUM('technical', 'billing', 'general', 'complaint') DEFAULT 'general',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    status ENUM('open', 'in_progress', 'processed', 'resolved', 'closed') DEFAULT 'open',
    assigned_to INT,
    history JSON,
    resolution TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME,
    deadline DATE COMMENT 'Ngày mong muốn công việc hoàn thành',
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (assigned_to) REFERENCES users(id)
);

-- 13. INVOICES
CREATE TABLE invoices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    work_order_id INT,
    contract_id INT,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 10.00,
    tax_amount DECIMAL(15,2) NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    payment_status ENUM('unpaid', 'partial', 'paid', 'overdue') DEFAULT 'unpaid',
    payment_method VARCHAR(50),
    payment_date DATE,
    payment_reference VARCHAR(100),
    paid_amount DECIMAL(15,2) DEFAULT 0,
    notes TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (work_order_id) REFERENCES work_orders(id),
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- 14. INVOICE_ITEMS
CREATE TABLE invoice_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    product_id INT,
    item_type ENUM('product', 'service', 'labor') DEFAULT 'product',
    description VARCHAR(500) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    line_total DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 15. ACTIVITY_LOGS
CREATE TABLE activity_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50),
    record_id INT,
    details JSON,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 16. SETTINGS
CREATE TABLE settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    description TEXT,
    updated_by INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Dữ liệu mẫu
INSERT INTO settings (setting_key, setting_value, description) VALUES
('company_name', 'HL Generator Solutions', 'Tên công ty'),
('tax_rate', '10.00', 'Thuế suất mặc định (%)'),
('default_warranty', '24', 'Bảo hành mặc định cho máy phát điện (tháng)'),
('low_stock_alert', '5', 'Cảnh báo tồn kho thấp cho thiết bị');

INSERT INTO users (username, email, password_hash, full_name, phone, role, permissions) VALUES
('admin', 'admin@hlgenerator.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
 'System Administrator', '0123456789', 'admin',
 '["all_permissions"]'),
('technician1', 'tech1@hlgenerator.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
 'Nguyễn Văn Tâm', '0987654321', 'head_technician',
 '["view_work_orders", "manage_tasks", "view_inventory"]'),
('customer1', 'customer1@gmail.com', '123abc',
 'Nguyễn Văn Khách', '0909123456', 'customer',
 '["view_products", "view_orders", "submit_support_request"]');

-- 17. RBAC: ROLES
CREATE TABLE IF NOT EXISTS roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    role_key VARCHAR(50) UNIQUE NOT NULL,
    role_name VARCHAR(100) NOT NULL,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 18. RBAC: PERMISSIONS
CREATE TABLE IF NOT EXISTS permissions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    perm_key VARCHAR(100) UNIQUE NOT NULL,
    perm_name VARCHAR(200) NOT NULL,
    group_name VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 19. RBAC: ROLE_PERMISSIONS
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
);


-- Seed default roles
INSERT INTO roles (role_key, role_name, is_system) VALUES
('admin', 'Quản trị viên', TRUE),
('customer_support', 'Hỗ trợ khách hàng', FALSE),
('technical_staff', 'Nhân viên kỹ thuật', FALSE),
('head_technician', 'Trưởng phòng kỹ thuật', FALSE),
('storekeeper', 'Thủ kho', FALSE),
('customer', 'Khách hàng', FALSE),
('guest', 'Khách', FALSE)
ON DUPLICATE KEY UPDATE role_name = VALUES(role_name);

-- Seed default permissions
INSERT INTO permissions (perm_key, perm_name, group_name) VALUES
-- Nhóm: Quản trị
('manage_permissions', 'Phân quyền', 'Quản trị'),
('manage_users', 'Quản lý người dùng', 'Quản trị'),
('manage_settings', 'Cài đặt hệ thống', 'Quản trị'),
('manage_email', 'Quản lý email', 'Quản trị'),
-- Nhóm: Hỗ trợ khách hàng
('manage_support_requests', 'Quản lý yêu cầu hỗ trợ', 'Hỗ trợ khách hàng'),
('manage_feedback', 'Quản lý feedback', 'Hỗ trợ khách hàng'),
('manage_contracts', 'Quản lý hợp đồng', 'Hỗ trợ khách hàng'),
('manage_contacts', 'Quản lý liên hệ', 'Hỗ trợ khách hàng'),
('manage_customers', 'Quản lý khách hàng', 'Hỗ trợ khách hàng'),
-- Nhóm: Nhân viên kỹ thuật
('view_my_tasks', 'Nhiệm vụ của tôi', 'Kỹ thuật'),
-- Nhóm: Trưởng phòng kỹ thuật
('manage_tech_support_requests', 'Yêu cầu hỗ trợ kỹ thuật', 'Trưởng phòng kỹ thuật'),
('manage_work_orders', 'Đơn hàng công việc', 'Trưởng phòng kỹ thuật'),
('manage_technical_staff', 'Quản lý nhân viên kỹ thuật', 'Trưởng phòng kỹ thuật'),
-- Nhóm: Kho
('manage_products', 'Quản lý sản phẩm', 'Kho'),
('manage_suppliers', 'Nhà cung cấp', 'Kho'),
('manage_inventory', 'Quản lý kho', 'Kho'),
-- Nhóm: Khách hàng/Guest
('submit_support_request', 'Gửi yêu cầu hỗ trợ', 'Khách hàng'),
('submit_contact', 'Gửi liên hệ', 'Khách')
ON DUPLICATE KEY UPDATE perm_name = VALUES(perm_name), group_name = VALUES(group_name);

-- Map default role-permissions
-- Admin: giữ mặc định và không thể xóa các quyền cốt lõi
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.role_key = 'admin' AND p.perm_key IN (
  'manage_permissions','manage_users','manage_settings','manage_email'
)
ON DUPLICATE KEY UPDATE permission_id = permission_id;

-- Customer Support
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r JOIN permissions p ON p.perm_key IN (
  'manage_support_requests','manage_feedback','manage_contracts','manage_contacts','manage_customers'
) WHERE r.role_key = 'customer_support'
ON DUPLICATE KEY UPDATE permission_id = permission_id;

-- Technical Staff
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r JOIN permissions p ON p.perm_key IN ('view_my_tasks')
WHERE r.role_key = 'technical_staff'
ON DUPLICATE KEY UPDATE permission_id = permission_id;

-- Head Technician
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r JOIN permissions p ON p.perm_key IN (
  'manage_tech_support_requests','manage_work_orders','manage_technical_staff'
) WHERE r.role_key = 'head_technician'
ON DUPLICATE KEY UPDATE permission_id = permission_id;

-- Storekeeper
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r JOIN permissions p ON p.perm_key IN (
  'manage_products','manage_suppliers','manage_inventory'
) WHERE r.role_key = 'storekeeper'
ON DUPLICATE KEY UPDATE permission_id = permission_id;

-- Customer
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r JOIN permissions p ON p.perm_key IN ('submit_support_request')
WHERE r.role_key = 'customer'
ON DUPLICATE KEY UPDATE permission_id = permission_id;

-- Guest
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r JOIN permissions p ON p.perm_key IN ('submit_contact')
WHERE r.role_key = 'guest'
ON DUPLICATE KEY UPDATE permission_id = permission_id;

CREATE TABLE contact_messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    status ENUM('new', 'read', 'replied', 'archived') DEFAULT 'new',
    replied_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;