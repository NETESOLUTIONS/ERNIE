-- This script updates the main WOS table (wos_*) except wos_references with
-- data from newly-downloaded files. Specifically:

-- For all except wos_publications and wos_references:
--     1. Find update records: find WOS IDs that need to be updated, and move
--        current records with these WOS IDs to the update history tables:
--        uhs_wos_*.
--     2. Insert updated/new records: insert all the records from the new
--        tables (new_wos_*) into the main table: wos_*.
--     3. Delete records: move records with specified delete WOS IDs to the
--                        delete tables: del_wos_*.
--     4. Truncate the new tables: new_wos_*.
--     5. Record to log table: update_log_wos.

-- For wos_publications:
--     1. Find update_records: copy current records with WOS IDs in new table
--        to update history table: uhs_wos_publications.
--     2a. Update records: replace records in main table with same WOS IDs in
--         new table.
--     2b. Insert records: insert records with new WOS IDs in new table to main.
--     3,4,5: Same as above.

-- Relevant main tables:
--     1. wos_abstracts
--     2. wos_addresses
--     3. wos_authors
--     4. wos_document_identifiers
--     5. wos_grants
--     6. wos_keywords
--     7. wos_publications
--     8. wos_references not included in this script
--     9. wos_titles
-- Usage: psql -d ernie -f wos_update_tables.sql

-- Author: Lingtian "Lindsay" Wan
-- Create Date: 03/03/2016
-- Modified: 05/17/2016
--           06/06/2016, Lindsay Wan, deleted wos_references to another script
--           06/07/2016, Lindsay Wan, added begin_page, end_page, has_abstract columns to wos_publications
--           08/05/2016, Lindsay Wan, disabled hashjoin & mergejoin, added indexes
--           11/21/2016, Lindsay Wan, set search_path to public and lindsay
--           02/22/2017, Lindsay Wan, set search_path to public and samet
--           08/08/2017, Samet Keserci, index and tablespace are revised according to wos smokeload.

\set ON_ERROR_STOP on
\set ECHO all


-- Set temporary tablespace for calculation.
SET log_temp_files = 0;
SET enable_seqscan = 'off';
--set temp_tablespaces = 'temp_tbs';
SET enable_hashjoin = 'off';
SET enable_mergejoin = 'off';

-- Create a temp table to store WOS IDs from the update file.
DROP TABLE IF EXISTS temp_update_wosid;
CREATE TABLE temp_update_wosid TABLESPACE wos AS
  SELECT source_id
  FROM new_wos_publications;
CREATE INDEX temp_update_wosid_idx
  ON temp_update_wosid USING HASH (source_id) TABLESPACE indexes;

-- Create a temporary table to store update WOS IDs that already exist in WOS
-- tables.
DROP TABLE IF EXISTS temp_replace_wosid;
CREATE TABLE temp_replace_wosid TABLESPACE wos AS
  SELECT a.source_id
  FROM temp_update_wosid a INNER JOIN wos_publications b ON a.source_id = b.source_id;
CREATE INDEX temp_replace_wosid_idx
  ON temp_replace_wosid USING HASH (source_id) TABLESPACE indexes;

-- Update log file.
\echo ***UPDATING LOG TABLE
INSERT INTO update_log_wos (num_update)
  SELECT count(*)
  FROM temp_replace_wosid;
UPDATE update_log_wos
SET num_new = (SELECT count(*)
FROM temp_update_wosid) - num_update
WHERE id = (SELECT max(id)
FROM update_log_wos);

-- Update table: wos_abstracts
\echo ***UPDATING TABLE: wos_abstracts
INSERT INTO uhs_wos_abstracts
  SELECT a.*
  FROM wos_abstracts a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_abstracts a
WHERE exists(SELECT 1
             FROM temp_update_wosid b
             WHERE a.source_id = b.source_id);
INSERT INTO wos_abstracts
  SELECT *
  FROM new_wos_abstracts;

-- Update table: wos_addresses
\echo ***UPDATING TABLE: wos_addresses
INSERT INTO uhs_wos_addresses
  SELECT a.*
  FROM wos_addresses a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_addresses a
WHERE exists(SELECT 1
             FROM temp_update_wosid b
             WHERE a.source_id = b.source_id);
INSERT INTO wos_addresses
  SELECT *
  FROM new_wos_addresses;

-- Update table: wos_authors
\echo ***UPDATING TABLE: wos_authors
INSERT INTO uhs_wos_authors
  SELECT a.*
  FROM wos_authors a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_authors a
WHERE exists(SELECT 1
             FROM temp_update_wosid b
             WHERE a.source_id = b.source_id);
INSERT INTO wos_authors
  SELECT *
  FROM new_wos_authors;

-- Update table: wos_document_identifiers
\echo ***UPDATING TABLE: wos_document_identifiers
INSERT INTO uhs_wos_document_identifiers
  SELECT a.*
  FROM wos_document_identifiers a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_document_identifiers a
WHERE exists(SELECT 1
             FROM temp_update_wosid b
             WHERE a.source_id = b.source_id);
INSERT INTO wos_document_identifiers
  SELECT *
  FROM new_wos_document_identifiers;

-- Update table: wos_grants
\echo ***UPDATING TABLE: wos_grants
INSERT INTO uhs_wos_grants
  SELECT a.*
  FROM wos_grants a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_grants a
WHERE exists(SELECT 1
             FROM temp_update_wosid b
             WHERE a.source_id = b.source_id);
INSERT INTO wos_grants
  SELECT *
  FROM new_wos_grants;

-- Update table: wos_keywords
\echo ***UPDATING TABLE: wos_keywords
INSERT INTO uhs_wos_keywords
  SELECT a.*
  FROM wos_keywords a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_keywords a
WHERE exists(SELECT 1
             FROM temp_update_wosid b
             WHERE a.source_id = b.source_id);
INSERT INTO wos_keywords
  SELECT *
  FROM new_wos_keywords;

-- Update table: wos_publications
\echo ***UPDATING TABLE: wos_publications
INSERT INTO uhs_wos_publications
  SELECT id, source_id, source_type, source_title, language, document_title, document_type, has_abstract, issue, volume,
    begin_page, end_page, publisher_name, publisher_address, publication_year, publication_date, created_date,
    last_modified_date, edition, source_filename
  FROM wos_publications a
  WHERE exists(SELECT 1
               FROM temp_replace_wosid b
               WHERE a.source_id = b.source_id);
UPDATE wos_publications AS a
SET
  (source_id, source_type, source_title, language, document_title, document_type, has_abstract, issue, volume, begin_page, end_page, publisher_name, publisher_address, publication_year, publication_date, created_date, last_modified_date, edition, source_filename) = (b.source_id, b.source_type, b.source_title, b.language, b.document_title, b.document_type, b.has_abstract, b.issue, b.volume, b.begin_page, b.end_page, b.publisher_name, b.publisher_address, b.publication_year, b.publication_date, b.created_date, b.last_modified_date, b.edition, b.source_filename) FROM
  new_wos_publications b
WHERE a.source_id = b.source_id;
INSERT INTO wos_publications (id, source_id, source_type, source_title, language, document_title, document_type, has_abstract, issue, volume, begin_page, end_page, publisher_name, publisher_address, publication_year, publication_date, created_date, last_modified_date, edition, source_filename)
  SELECT *
  FROM new_wos_publications a
  WHERE NOT exists(SELECT *
                   FROM temp_replace_wosid b
                   WHERE a.source_id = b.source_id);

-- Update table: wos_titles
\echo ***UPDATING TABLE: wos_titles
INSERT INTO uhs_wos_titles
  SELECT a.*
  FROM wos_titles a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_titles a
WHERE exists(SELECT 1
             FROM temp_update_wosid b
             WHERE a.source_id = b.source_id);
INSERT INTO wos_titles
  SELECT *
  FROM new_wos_titles;

-- Truncate new_wos_tables.
\echo ***TRUNCATING TABLES: new_wos_*
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
