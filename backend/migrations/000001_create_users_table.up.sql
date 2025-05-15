CREATE TABLE IF NOT EXISTS users (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username     VARCHAR(255) NOT NULL UNIQUE,
  password     VARCHAR(255) NOT NULL,
  joined_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE FULLTEXT INDEX idx_user_trigram ON users (username);

INSERT INTO users (username, password) VALUES ('Anonymous', '-');