-- Migration: Add password_hash column to users table and copy legacy hashed_password data.
-- This migration preserves existing user data and keeps the legacy hashed_password column.

-- SQLite:
ALTER TABLE users ADD COLUMN password_hash VARCHAR(255) DEFAULT '';
UPDATE users SET password_hash = hashed_password WHERE password_hash IS NULL OR password_hash = '';

-- MySQL/Postgres:
-- ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);
-- UPDATE users SET password_hash = hashed_password WHERE password_hash IS NULL OR password_hash = '';

-- Note: Keep legacy hashed_password column intact until the migration is fully verified.
