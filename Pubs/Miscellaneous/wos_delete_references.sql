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

\echo ***DELETING FROM TABLE: wos_references
INSERT INTO del_wos_references
  SELECT a.wos_reference_id, a.source_id, a.cited_source_uid, a.cited_title, a.cited_work, a.cited_author, a.cited_year, a.cited_page,
    a.created_date, a.last_modified_date, a.source_filename
  FROM wos_references a INNER JOIN temp_delete_wosid_7 b ON a.source_id = b.source_id;

DELETE FROM wos_references a
WHERE exists(SELECT 1
             FROM temp_delete_wosid_7 b
             WHERE a.source_id = b.source_id);