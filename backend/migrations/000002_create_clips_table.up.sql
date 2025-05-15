CREATE TABLE IF NOT EXISTS clips (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title         VARCHAR(255) NOT NULL,
  description   TEXT,
  creator_id    BIGINT UNSIGNED NOT NULL,
  processing    BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  views         BIGINT UNSIGNED NOT NULL DEFAULT 0,
  unlisted      BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (creator_id) REFERENCES users(id)
);

CREATE FULLTEXT INDEX idx_clip_trigram ON clips (title, description);
