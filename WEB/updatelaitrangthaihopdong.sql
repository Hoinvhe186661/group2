

USE hlelectric;

-- 1) Expand ENUM temporarily to include both old and new values
ALTER TABLE contracts
    MODIFY status ENUM('draft', 'pending_approval', 'approved', 'active', 'terminated', 'completed', 'expired')
    NOT NULL DEFAULT 'draft';

-- 2) Remap existing data from old values to new values
UPDATE contracts SET status = 'active'     WHERE status = 'completed';
UPDATE contracts SET status = 'terminated' WHERE status = 'expired';

-- 3) Restrict ENUM to the final new set of values
ALTER TABLE contracts
    MODIFY status ENUM('draft', 'pending_approval', 'approved', 'active', 'terminated')
    NOT NULL DEFAULT 'draft';

-- 4) Optional: quick report
SELECT status, COUNT(*) AS cnt
FROM contracts
GROUP BY status
ORDER BY status;

