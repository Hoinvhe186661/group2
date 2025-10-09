-- Migration: add reset token columns to users table
-- Execute on your MySQL server connected to the 'hlelectric' database

USE hlelectric;

-- Add columns for password reset flow
ALTER TABLE users
  ADD COLUMN reset_token VARCHAR(100) NULL AFTER password_hash,
  ADD COLUMN reset_token_expires_at DATETIME NULL AFTER reset_token;

-- Index for faster lookup by reset token
CREATE INDEX idx_users_reset_token ON users (reset_token);


