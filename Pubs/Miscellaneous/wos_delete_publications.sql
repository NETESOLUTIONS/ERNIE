-- Author     : Samet Keserci, (prev version - Lindsay Wan)
-- Aim        : Delete the del.file records from wos tables in parallel. Previous version was in serial and written by Lindsay.
-- Create date: 08/28/2017

\set ON_ERROR_STOP on
\set ECHO all

-- Set temporary tablespace for calculation.
SET log_temp_files = 0;
SET enable_seqscan = 'off';
--set temp_tablespaces = 'temp_tbs';
--set enable_hashjoin = 'off';
--set enable_mergejoin = 'off';

\echo ***DELETING FROM TABLE: wos_publications
INSERT INTO del_wos_publications
  SELECT a.id, a.source_id, a.source_type, a.source_title, a.language, a.document_title, a.document_type,
    a.has_abstract, a.issue, a.volume, a.begin_page, a.end_page, a.publisher_name, a.publisher_address,
    a.publication_year, a.publication_date, a.created_date, a.last_modified_date, a.edition, a.source_filename
  FROM wos_publications a INNER JOIN temp_delete_wosid_6 b ON a.source_id = b.source_id;

DELETE FROM wos_publications a
WHERE exists(SELECT 1
             FROM temp_delete_wosid_6 b
             WHERE a.source_id = b.source_id);