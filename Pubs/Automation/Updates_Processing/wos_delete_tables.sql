/*
This script deletes records in the main WOS table (wos_*) with source_id from wos*.del files.
Specifically, it does the following things:
    1. Delete records: move records with specified delete WOS IDs to the
                       delete tables: del_wos_*.
    2. Record to log table: update_log_wos.
Relevant main tables:
    1. wos_abstracts
    2. wos_addresses
    3. wos_authors
    4. wos_document_identifiers
    5. wos_grants
    6. wos_keywords
    7. wos_publications
    8. wos_references
    9. wos_titles
Usage: psql -f wos_delete_tables.sql -v delete_csv={relative filename for a del_wosid.csv file}

Author: Lingtian "Lindsay" Wan
Created: 03/04/2016
Modified:
05/17/2016
08/06/2016, Lindsay Wan, disabled hashjoin & mergerjoin, added column names to wos_publications & wos_references
11/21/2016, Lindsay Wan, set search_path to public and lindsay
02/22/2017, Lindsay Wan, set search_path to public and samet
02/14/2018, Dmitriy "DK" Korobskiy
* Merged delete log to the main log record
* Refactored to a client-side copy
* Formatted
*/


-- Set temporary tablespace for calculation.
SET log_temp_files = 0;

\set ECHO all
\set ON_ERROR_STOP on

-- Create a temporary table to store all delete WOSIDs.
DROP TABLE IF EXISTS temp_delete_wosid;
CREATE TABLE temp_delete_wosid (
  source_id VARCHAR(30)
);
\copy temp_delete_wosid from 'del_wosid.csv' (FORMAT csv)

-- Delete wos_abstracts to del_wos_abstracts.
\echo ***DELETING FROM TABLE: wos_abstracts
INSERT INTO del_wos_abstracts
  SELECT a.*
  FROM wos_abstracts a INNER JOIN temp_delete_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_abstracts a
WHERE exists(SELECT 1
             FROM temp_delete_wosid b
             WHERE a.source_id = b.source_id);

-- Delete wos_addresses to del_wos_addresses.
\echo ***DELETING FROM TABLE: wos_addresses
INSERT INTO del_wos_addresses
  SELECT a.*
  FROM wos_addresses a INNER JOIN temp_delete_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_addresses a
WHERE exists(SELECT 1
             FROM temp_delete_wosid b
             WHERE a.source_id = b.source_id);

-- Delete wos_authors to del_wos_authors.
\echo ***DELETING FROM TABLE: wos_authors
INSERT INTO del_wos_authors
  SELECT a.*
  FROM wos_authors a INNER JOIN temp_delete_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_authors a
WHERE exists(SELECT 1
             FROM temp_delete_wosid b
             WHERE a.source_id = b.source_id);

-- Delete wos_document_identifiers to del_wos_document_identifiers.
\echo ***DELETING FROM TABLE: wos_document_identifiers
INSERT INTO del_wos_document_identifiers
  SELECT a.*
  FROM wos_document_identifiers a INNER JOIN temp_delete_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_document_identifiers a
WHERE exists(SELECT 1
             FROM temp_delete_wosid b
             WHERE a.source_id = b.source_id);

-- Delete wos_grants to del_wos_grants.
\echo ***DELETING FROM TABLE: wos_grants
INSERT INTO del_wos_grants
  SELECT a.*
  FROM wos_grants a INNER JOIN temp_delete_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_grants a
WHERE exists(SELECT 1
             FROM temp_delete_wosid b
             WHERE a.source_id = b.source_id);

-- Delete wos_keywords to del_wos_keywords.
\echo ***DELETING FROM TABLE: wos_keywords
INSERT INTO del_wos_keywords
  SELECT a.*
  FROM wos_keywords a INNER JOIN temp_delete_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_keywords a
WHERE exists(SELECT 1
             FROM temp_delete_wosid b
             WHERE a.source_id = b.source_id);

-- Delete wos_publications to del_wos_publications.
\echo ***DELETING FROM TABLE: wos_publications
INSERT INTO del_wos_publications
  SELECT
    a.id,
    a.source_id,
    a.source_type,
    a.source_title,
    a.language,
    a.document_title,
    a.document_type,
    a.has_abstract,
    a.issue,
    a.volume,
    a.begin_page,
    a.end_page,
    a.publisher_name,
    a.publisher_address,
    a.publication_year,
    a.publication_date,
    a.created_date,
    a.last_modified_date,
    a.edition,
    a.source_filename
  FROM wos_publications a INNER JOIN temp_delete_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_publications a
WHERE exists(SELECT 1
             FROM temp_delete_wosid b
             WHERE a.source_id = b.source_id);

-- Delete wos_references to del_wos_references.
\echo ***DELETING FROM TABLE: wos_references
INSERT INTO del_wos_references
  SELECT
    a.wos_reference_id,
    a.source_id,
    a.cited_source_uid,
    a.cited_title,
    a.cited_work,
    a.cited_author,
    a.cited_year,
    a.cited_page,
    a.created_date,
    a.last_modified_date,
    a.source_filename
  FROM wos_references a INNER JOIN temp_delete_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_references a
WHERE exists(SELECT 1
             FROM temp_delete_wosid b
             WHERE a.source_id = b.source_id);

-- Delete wos_titles to del_wos_titles.
\echo ***DELETING FROM TABLE: wos_titles
INSERT INTO del_wos_titles
  SELECT a.*
  FROM wos_titles a INNER JOIN temp_delete_wosid b ON a.source_id = b.source_id;
DELETE FROM wos_titles a
WHERE exists(SELECT 1
             FROM temp_delete_wosid b
             WHERE a.source_id = b.source_id);

-- Update log table.
UPDATE update_log_wos
SET last_updated = current_timestamp, --
  num_wos = (
    SELECT count(1)
    FROM wos_publications), --
  num_delete = (
    SELECT count(1)
    FROM wos_publications a
    JOIN temp_delete_wosid b USING (source_id))
WHERE id = (
  SELECT max(id)
  FROM update_log_wos);