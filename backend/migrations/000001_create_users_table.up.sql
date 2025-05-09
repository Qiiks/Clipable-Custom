CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS "user" (
  id           bigserial                 PRIMARY KEY,
  username     varchar                   NOT NULL UNIQUE,
  "password"   varchar                   NOT NULL,
  joined_at    timestamp with time zone  NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION f_concat_ws(text, VARIADIC text[])
  RETURNS text LANGUAGE sql IMMUTABLE AS 'SELECT array_to_string($2, $1)';

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_trigram ON "user" USING gin (f_concat_ws(' ', username) gin_trgm_ops);

-- Create our system user
INSERT INTO "user"(username, "password") VALUES ('Anonymous', '-');