-- Dentzy learning content v2 migration
-- Creates new language-specific tables and copies legacy translated rows into separate English/Tamil records.
-- Legacy tables are preserved unchanged.

CREATE TABLE IF NOT EXISTS learning_videos_v2 (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    title TEXT NOT NULL,
    description TEXT NULL,
    video_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500) NULL,
    language VARCHAR(2) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_learning_videos_v2_language (language),
    KEY idx_learning_videos_v2_active_language (is_active, language)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS learning_articles_v2 (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    title TEXT NOT NULL,
    content LONGTEXT NOT NULL,
    summary LONGTEXT NULL,
    language VARCHAR(2) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_learning_articles_v2_language (language),
    KEY idx_learning_articles_v2_active_language (is_active, language)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO learning_videos_v2 (title, description, video_url, thumbnail_url, language, is_active, created_at, updated_at)
SELECT src.title_en, src.description_en, src.video_url, src.thumbnail_url, 'en', src.is_active, src.created_at, src.updated_at
FROM learning_videos src
WHERE NOT EXISTS (SELECT 1 FROM learning_videos_v2 LIMIT 1)
UNION ALL
SELECT src.title_ta, src.description_ta, src.video_url, src.thumbnail_url, 'ta', src.is_active, src.created_at, src.updated_at
FROM learning_videos src
WHERE NOT EXISTS (SELECT 1 FROM learning_videos_v2 LIMIT 1);

INSERT INTO learning_articles_v2 (title, content, summary, language, is_active, created_at, updated_at)
SELECT src.title_en, src.content_en, src.summary_en, 'en', src.is_active, src.created_at, src.updated_at
FROM learning_articles src
WHERE NOT EXISTS (SELECT 1 FROM learning_articles_v2 LIMIT 1)
UNION ALL
SELECT src.title_ta, src.content_ta, src.summary_ta, 'ta', src.is_active, src.created_at, src.updated_at
FROM learning_articles src
WHERE NOT EXISTS (SELECT 1 FROM learning_articles_v2 LIMIT 1);

-- Keep the legacy tables in place until all consumers are switched.
-- The backend now reads from learning_videos_v2 and learning_articles_v2.
