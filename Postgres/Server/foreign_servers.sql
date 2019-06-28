-- Foreign servers
SELECT *
FROM information_schema.foreign_servers;

CREATE SERVER ernie1
  FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'ernie1', dbname 'ernie', PORT '5432');

-- region User mappings
CREATE USER MAPPING FOR dk
  SERVER ernie1 OPTIONS (USER 'dk', PASSWORD :password);
-- endregion

-- Create schema
DROP SCHEMA IF EXISTS ernie1_public CASCADE;
CREATE SCHEMA ernie1_public
  AUTHORIZATION dk;

-- Import foreign schema
IMPORT FOREIGN SCHEMA public FROM SERVER ernie1 INTO ernie1_public;
-- 1.6s
