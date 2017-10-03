
-- Author: Samet Keserci, Lingtian "Lindsay" Wan
-- Create Date: 08/11/2017
-- Modified from serial loading process.

-- Set temporary tablespace for calculation.
set log_temp_files = 0;
SET temp_tablespaces='temp'; -- temporaryly it is being set.


-- Truncate new_wos_tables.
\echo ***TRUNCATING TABLES: new_wos_* all but wos_references
truncate table new_wos_abstracts;
truncate table new_wos_addresses;
truncate table new_wos_authors;
truncate table new_wos_document_identifiers;
truncate table new_wos_grants;
truncate table new_wos_keywords;
truncate table new_wos_publications;
truncate table new_wos_titles;

-- Write date to log.
update update_log_wos
  set num_wos = (select count(1) from wos_publications)
  where id = (select max(id) from update_log_wos);
