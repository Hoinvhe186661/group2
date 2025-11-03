USE hlelectric;

-- Bảng lưu lịch sử email đã gửi
CREATE TABLE email_notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    subject VARCHAR(500) NOT NULL,
    content TEXT NOT NULL,
    email_type ENUM('internal', 'marketing') NOT NULL DEFAULT 'internal',
    recipient_roles JSON COMMENT 'Danh sách các role nhận email (JSON array)',
    recipient_emails JSON COMMENT 'Danh sách email người nhận (JSON array)',
    recipient_count INT DEFAULT 0 COMMENT 'Số lượng người nhận',
    success_count INT DEFAULT 0 COMMENT 'Số email gửi thành công',
    failed_count INT DEFAULT 0 COMMENT 'Số email gửi thất bại',
    failed_recipients JSON COMMENT 'Danh sách email gửi thất bại (JSON array)',
    status ENUM('pending', 'sending', 'completed', 'failed', 'partial') DEFAULT 'pending',
    sent_by INT COMMENT 'ID người gửi (admin)',
    sent_by_name VARCHAR(100) COMMENT 'Tên người gửi',
    scheduled_at DATETIME COMMENT 'Thời gian lên lịch gửi',
    sent_at DATETIME COMMENT 'Thời gian bắt đầu gửi',
    completed_at DATETIME COMMENT 'Thời gian hoàn thành',
    error_message TEXT COMMENT 'Thông báo lỗi nếu có',
    attachments TEXT COMMENT 'Danh sách file đính kèm (JSON array chứa file paths)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sent_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_email_type (email_type),
    INDEX idx_status (status),
    INDEX idx_sent_at (sent_at),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

