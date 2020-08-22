-- Databases and their owners
SELECT
  pd.datname AS db,
  pa.rolname AS db_owner
FROM pg_authid AS pa
JOIN pg_database AS pd
  ON (pd.datdba = pa.oid)
--WHERE pd.datname = current_database()
ORDER BY db
;

CREATE DATABASE root OWNER root;

ALTER DATABASE :db OWNER TO :user;

DROP DATABASE :db;