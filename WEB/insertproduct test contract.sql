
USE hlelectric;


INSERT IGNORE INTO suppliers (supplier_code, company_name, contact_person, email, phone, address, status) VALUES
('SUP001', 'Công ty TNHH Máy phát điện Việt Nam', 'Nguyễn Văn A', 'contact@vietnamgenerator.com', '0901234567', '123 Đường ABC, Quận 1, TP.HCM', 'active'),
('SUP002', 'Công ty CP Thiết bị điện Hà Nội', 'Trần Thị B', 'info@hanoiequipment.com', '0907654321', '456 Đường XYZ, Quận Cầu Giấy, Hà Nội', 'active');

SET @supplier1_id = (SELECT id FROM suppliers WHERE supplier_code = 'SUP001' LIMIT 1);
SET @supplier2_id = (SELECT id FROM suppliers WHERE supplier_code = 'SUP002' LIMIT 1);


INSERT IGNORE INTO products (product_code, product_name, category, description, unit, unit_price, supplier_id, specifications, warranty_months, status) VALUES
('GEN001', 'Máy phát điện Perkins 50KVA', 'Máy phát điện', 
 'Máy phát điện Perkins công suất 50KVA, động cơ Perkins 4 xi-lanh, phù hợp cho công nghiệp và thương mại. Có hệ thống làm mát bằng nước, khởi động tự động, bảng điều khiển kỹ thuật số.',
 'cái', 85000000.00, @supplier1_id,
 '{"engine": "Perkins 4 xi-lanh", "power": "50KVA", "voltage": "380V/220V", "frequency": "50Hz", "fuel": "Diesel", "cooling": "Nước", "startup": "Tự động"}',
 24, 'active'),

('GEN002', 'Máy phát điện Cummins 100KVA', 'Máy phát điện',
 'Máy phát điện Cummins công suất 100KVA, động cơ Cummins 6 xi-lanh turbo, thiết kế cho các ứng dụng công nghiệp lớn. Có hệ thống điều khiển tự động, bảo vệ đa cấp, tiết kiệm nhiên liệu.',
 'cái', 150000000.00, @supplier2_id,
 '{"engine": "Cummins 6 xi-lanh turbo", "power": "100KVA", "voltage": "380V/220V", "frequency": "50Hz", "fuel": "Diesel", "cooling": "Nước", "startup": "Tự động", "protection": "Đa cấp"}',
 36, 'active');


SET @product1_id = (SELECT id FROM products WHERE product_code = 'GEN001' LIMIT 1);
SET @product2_id = (SELECT id FROM products WHERE product_code = 'GEN002' LIMIT 1);


INSERT IGNORE INTO inventory (product_id, warehouse_location, current_stock, min_stock, max_stock) VALUES
(@product1_id, 'Kho chính', 5, 2, 20),
(@product2_id, 'Kho chính', 3, 1, 15);


INSERT IGNORE INTO stock_history (product_id, warehouse_location, movement_type, quantity, reference_type, reference_id, unit_cost, notes, created_by) VALUES
(@product1_id, 'Kho chính', 'in', 5, 'initial_stock', 0, 85000000.00, 'Nhập kho ban đầu', 1),
(@product2_id, 'Kho chính', 'in', 3, 'initial_stock', 0, 150000000.00, 'Nhập kho ban đầu', 1);


SELECT 
    p.id,
    p.product_code,
    p.product_name,
    p.category,
    p.unit_price,
    s.company_name as supplier_name,
    i.current_stock,
    p.warranty_months
FROM products p
LEFT JOIN suppliers s ON p.supplier_id = s.id
LEFT JOIN inventory i ON p.id = i.product_id
WHERE p.product_code IN ('GEN001', 'GEN002');


SELECT 'Dữ liệu sản phẩm mẫu đã được thêm thành công!' as message;
