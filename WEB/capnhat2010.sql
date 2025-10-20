-- Migration: add reset token columns to users table
-- Execute on your MySQL server connected to the 'hlelectric' database



USE hlelectric;

-- Add customer_id to users and FK to customers
ALTER TABLE users
    ADD COLUMN customer_id INT NULL AFTER phone;

-- Add index for faster joins
CREATE INDEX idx_users_customer_id ON users(customer_id);

-- Add foreign key constraint (ignore error if already exists)
ALTER TABLE users
    ADD CONSTRAINT fk_users_customer
    FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON DELETE SET NULL;


