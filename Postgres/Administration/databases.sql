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

ALTER DATABASE pardi OWNER TO pardi_admin;

-- Import selected object(s) into a (foreign) schema
IMPORT FOREIGN SCHEMA "LINK_OD_PARDI" LIMIT TO (ct_clinical_studies) FROM SERVER irdb INTO foreign_irdb;