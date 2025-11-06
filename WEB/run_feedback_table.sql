-- Script tạo bảng ticket_feedback
-- Chạy script này trong MySQL để tạo bảng feedback

USE hlelectric;

-- Tạo bảng ticket_feedback để lưu feedback từ khách hàng
CREATE TABLE IF NOT EXISTS ticket_feedback (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL COMMENT 'Đánh giá từ 1-5 sao',
    comment TEXT COMMENT 'Nhận xét của khách hàng',
    image_path VARCHAR(500) COMMENT 'Đường dẫn đến ảnh feedback',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES support_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    UNIQUE KEY unique_ticket_feedback (ticket_id) COMMENT 'Mỗi ticket chỉ có thể có 1 feedback'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Thêm index để tìm kiếm nhanh
CREATE INDEX IF NOT EXISTS idx_ticket_feedback_ticket_id ON ticket_feedback(ticket_id);
CREATE INDEX IF NOT EXISTS idx_ticket_feedback_customer_id ON ticket_feedback(customer_id);
CREATE INDEX IF NOT EXISTS idx_ticket_feedback_rating ON ticket_feedback(rating);

