-- Lịch sử cập nhật giá mua/bán cho sản phẩm
-- Chạy file này để tạo bảng nếu chưa có
USE hlelectric
CREATE TABLE IF NOT EXISTS product_price_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    price_type ENUM('purchase','selling') NOT NULL,
    old_price DECIMAL(15,2) NULL,
    new_price DECIMAL(15,2) NOT NULL,
    reason VARCHAR(255) NULL,
    reference_type VARCHAR(50) NULL,
    reference_id INT NULL,
    updated_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product_type_time (product_id, price_type, updated_at),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);


