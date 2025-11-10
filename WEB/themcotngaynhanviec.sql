
USE hlelectric;
ALTER TABLE tasks
ADD COLUMN acknowledged_at TIMESTAMP NULL DEFAULT NULL
AFTER estimated_hours; 