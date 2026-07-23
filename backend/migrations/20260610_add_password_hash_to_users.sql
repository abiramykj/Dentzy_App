-- Migration: Add password_hash column to users table and copy legacy values
-- Applies to MySQL/Postgres and SQLite (SQLite Add Column limitations considered)

-- MySQL/Postgres (recommended for production DBs):
-- Add new column and copy values from legacy `hashed_password` if present.
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);

-- If `hashed_password` exists, copy values
-- UPDATE users SET password_hash = hashed_password WHERE password_hash IS NULL OR password_hash = '';

-- SQLite (run only on SQLite):
-- SQLite doesn't support IF NOT EXISTS for ALTER prior to 3.35; safe approach:
-- ALTER TABLE users ADD COLUMN password_hash VARCHAR(255) DEFAULT '';
-- UPDATE users SET password_hash = hashed_password WHERE password_hash IS NULL OR password_hash = ''; 

-- NOTE: This migration keeps the legacy `hashed_password` column intact to preserve history.
-- After verification you may schedule a follow-up migration to remove `hashed_password` once all systems use `password_hash`.
