-- Author: Samet Keserci, Lingtian "Lindsay" Wan
-- Create Date: 08/11/2017
-- Modified from serial loading process.

\set ON_ERROR_STOP on
\set ECHO all

-- Set temporary tablespace for calculation.
SET log_temp_files = 0;

-- Truncate new_wos_tables.
\echo ***TRUNCATING TABLES: new_wos_* all but wos_references
TRUNCATE TABLE new_wos_abstracts;
TRUNCATE TABLE new_wos_addresses;
TRUNCATE TABLE new_wos_authors;
TRUNCATE TABLE new_wos_document_identifiers;
TRUNCATE TABLE new_wos_grants;
TRUNCATE TABLE new_wos_keywords;
TRUNCATE TABLE new_wos_publications;
TRUNCATE TABLE new_wos_titles;

-- Write date to log.
UPDATE update_log_wos
SET num_wos = (SELECT count(1)
FROM wos_publications)
WHERE id = (SELECT max(id)
FROM update_log_wos);