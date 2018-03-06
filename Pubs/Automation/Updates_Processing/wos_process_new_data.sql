/*
This script updates the main WOS table (wos_*) except wos_references with
data from newly-downloaded files. Specifically:

For all except wos_publications and wos_references:
    1. Find update records: find WOS IDs that need to be updated, and move
       current records with these WOS IDs to the update history tables:
       uhs_wos_*.
    2. Insert updated/new records: insert all the records from the new
       tables (new_wos_*) into the main table: wos_*.
    3. Delete records: move records with specified delete WOS IDs to the
                       delete tables: del_wos_*.
    4. Truncate the new tables: new_wos_*.
    5. Record to log table: update_log_wos.

For wos_publications:
    1. Find update_records: copy current records with WOS IDs in new table
       to update history table: uhs_wos_publications.
    2a. Update records: replace records in main table with same WOS IDs in
        new table.
    2b. Insert records: insert records with new WOS IDs in new table to main.
    3,4,5: Same as above.

Relevant main tables:
    1. wos_abstracts
    2. wos_addresses
    3. wos_authors
    4. wos_document_identifiers
    5. wos_grants
    6. wos_keywords
    7. wos_publications
    8. wos_references not included in this script
    9. wos_titles

Author: Lingtian "Lindsay" Wan
Created: 03/03/2016
Modified:
* 05/17/2016
* 06/06/2016, Lindsay Wan, deleted wos_references to another script
* 06/07/2016, Lindsay Wan, added begin_page, end_page, has_abstract columns to wos_publications
* 08/05/2016, Lindsay Wan, disabled hashjoin & mergejoin, added indexes
* 11/21/2016, Lindsay Wan, set search_path to public and lindsay
* 02/22/2017, Lindsay Wan, set search_path to public and samet
* 08/08/2017, Samet Keserci, index and tablespace are revised according to wos smokeload.
* 03/05/2018, Dmitriy "DK" Korobskiy, moved out table truncation to do it before the script
*/

-- Set temporary tablespace for calculation.
SET log_temp_files = 0;

\set ECHO all
\set ON_ERROR_STOP on

-- Create a temp table to store WOS IDs from the update file.
DROP TABLE IF EXISTS temp_update_wosid;
CREATE TABLE temp_update_wosid AS
  SELECT source_id
  FROM new_wos_publications;
CREATE INDEX temp_update_wosid_idx
  ON temp_update_wosid USING HASH (source_id) TABLESPACE indexes;

-- Create a temporary table to store update WOS IDs that already exist in WOS
-- tables.
DROP TABLE IF EXISTS temp_replace_wosid;
CREATE TABLE temp_replace_wosid AS
  SELECT a.source_id
  FROM temp_update_wosid a INNER JOIN wos_publications b ON a.source_id = b.source_id;
CREATE INDEX temp_replace_wosid_idx
  ON temp_replace_wosid USING HASH (source_id) TABLESPACE indexes;

-- Update log file.
-------------------------------
\echo ***UPDATING LOG TABLE
-------------------------------
INSERT INTO update_log_wos (num_update)
  SELECT count(*)
  FROM temp_replace_wosid;
UPDATE update_log_wos
SET num_new = (
  SELECT count(*)
  FROM temp_update_wosid) - num_update
WHERE id = (
  SELECT max(id)
  FROM update_log_wos);

-- Update table: wos_abstracts
-------------------------------
\echo ***UPDATING TABLE: wos_abstracts
-------------------------------
INSERT INTO uhs_wos_abstracts
  SELECT a.*
  FROM wos_abstracts a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;

INSERT INTO wos_abstracts
  SELECT *
  FROM new_wos_abstracts
ON CONFLICT DO NOTHING;
--TODO: set primary key on wos_abstracts
--ON CONFLICT (source_id)
--DO UPDATE
--SET
--id = EXCLUDED.id,
--source_id = EXCLUDED.source_id,
--abstract_text = EXCLUDED.abstract_text,
--source_filename = EXCLUDED.source_filename;

-- Update table: wos_addresses
-------------------------------
\echo ***UPDATING TABLE: wos_addresses
-------------------------------
INSERT INTO uhs_wos_addresses
  SELECT a.*
  FROM wos_addresses a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;

INSERT INTO wos_addresses
  SELECT *
  FROM new_wos_addresses
ON CONFLICT (source_id, address_name)
  DO UPDATE SET id = excluded.id, source_id = excluded.source_id, address_name = excluded.address_name,
    organization = excluded.organization, sub_organization = excluded.sub_organization, city = excluded.city,
    country = excluded.country, zip_code = excluded.zip_code, source_filename = excluded.source_filename;

-- Update table: wos_authors
-------------------------------
\echo ***UPDATING TABLE: wos_authors
-------------------------------
INSERT INTO uhs_wos_authors
  SELECT a.*
  FROM wos_authors a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;

INSERT INTO wos_authors
  SELECT *
  FROM new_wos_authors
ON CONFLICT (source_id, seq_no, address_id)
  DO UPDATE SET id = excluded.id, source_id = excluded.source_id, full_name = excluded.full_name,
    last_name = excluded.last_name, first_name = excluded.first_name, seq_no = excluded.seq_no,
    address_seq = excluded.address_seq, address = excluded.address, email_address = excluded.email_address,
    address_id = excluded.address_id, dais_id = excluded.dais_id, r_id = excluded.r_id,
    source_filename = excluded.source_filename;

-- Update table: wos_document_identifiers
-------------------------------
\echo ***UPDATING TABLE: wos_document_identifiers
-------------------------------
INSERT INTO uhs_wos_document_identifiers
  SELECT a.*
  FROM wos_document_identifiers a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;

INSERT INTO wos_document_identifiers
  SELECT *
  FROM new_wos_document_identifiers
ON CONFLICT (source_id, document_id_type, document_id)
  DO UPDATE SET id = excluded.id, source_id = excluded.source_id, document_id = excluded.document_id,
    document_id_type = excluded.document_id_type, source_filename = excluded.source_filename;

-- Update table: wos_grants
-------------------------------
\echo ***UPDATING TABLE: wos_grants
-------------------------------
INSERT INTO uhs_wos_grants
  SELECT a.*
  FROM wos_grants a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;

INSERT INTO wos_grants
  SELECT *
  FROM new_wos_grants
ON CONFLICT (source_id, grant_number, grant_organization)
  DO UPDATE SET id = excluded.id, source_id = excluded.source_id, grant_number = excluded.grant_number,
    grant_organization = excluded.grant_organization, funding_ack = excluded.funding_ack,
    source_filename = excluded.source_filename;

-- Update table: wos_keywords
-------------------------------
\echo ***UPDATING TABLE: wos_keywords
-------------------------------
INSERT INTO uhs_wos_keywords
  SELECT a.*
  FROM wos_keywords a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;

INSERT INTO wos_keywords
  SELECT *
  FROM new_wos_keywords
ON CONFLICT (source_id, keyword)
  DO UPDATE SET id = excluded.id, source_id = excluded.source_id, keyword = excluded.keyword,
    source_filename = excluded.source_filename;

-- Update table: wos_publications
-------------------------------
\echo ***UPDATING TABLE: wos_publications
-------------------------------
INSERT INTO uhs_wos_publications
  SELECT
    id,
    source_id,
    source_type,
    source_title,
    language,
    document_title,
    document_type,
    has_abstract,
    issue,
    volume,
    begin_page,
    end_page,
    publisher_name,
    publisher_address,
    publication_year,
    publication_date,
    created_date,
    last_modified_date,
    edition,
    source_filename
  FROM wos_publications a
  WHERE exists(SELECT 1
               FROM temp_replace_wosid b
               WHERE a.source_id = b.source_id);

-- Upsert VERSION
INSERT INTO wos_publications (id, source_id, source_type, source_title, language, document_title, document_type, has_abstract, issue, volume, begin_page, end_page, publisher_name, publisher_address, publication_year, publication_date, created_date, last_modified_date, edition, source_filename)
  SELECT *
  FROM new_wos_publications a
ON CONFLICT (source_id)
  DO UPDATE SET begin_page = excluded.begin_page, created_date = excluded.created_date,
    document_title = excluded.document_title, document_type = excluded.document_type, edition = excluded.edition,
    end_page = excluded.end_page, has_abstract = excluded.has_abstract, id = excluded.id, issue = excluded.issue,
    language = excluded.language, last_modified_date = excluded.last_modified_date,
    publication_date = excluded.publication_date, publication_year = excluded.publication_year,
    publisher_address = excluded.publisher_address, publisher_name = excluded.publisher_name,
    source_filename = excluded.source_filename, source_id = excluded.source_id, source_title = excluded.source_title,
    source_type = excluded.source_type, volume = excluded.volume;

-- Update table: wos_titles
-------------------------------
\echo ***UPDATING TABLE: wos_titles
-------------------------------
INSERT INTO uhs_wos_titles
  SELECT a.*
  FROM wos_titles a INNER JOIN temp_update_wosid b ON a.source_id = b.source_id;

INSERT INTO wos_titles
  SELECT *
  FROM new_wos_titles
ON CONFLICT (source_id, type)
  DO UPDATE SET id = excluded.id, source_id = excluded.source_id, title = excluded.title, type = excluded.type,
    source_filename = excluded.source_filename;

-- Truncate new_wos_tables.
-- \echo ***TRUNCATING TABLES: new_wos_*
-- TRUNCATE TABLE new_wos_abstracts;
-- TRUNCATE TABLE new_wos_addresses;
-- TRUNCATE TABLE new_wos_authors;
-- TRUNCATE TABLE new_wos_document_identifiers;
-- TRUNCATE TABLE new_wos_grants;
-- TRUNCATE TABLE new_wos_keywords;
-- TRUNCATE TABLE new_wos_publications;
-- TRUNCATE TABLE new_wos_titles;

-- Write date to log.
UPDATE update_log_wos
SET num_wos = (
  SELECT count(1)
  FROM wos_publications)
WHERE id = (
  SELECT max(id)
  FROM update_log_wos);
