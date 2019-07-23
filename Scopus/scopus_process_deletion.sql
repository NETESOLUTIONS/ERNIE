/*
Title: Scopus_process_deletion
Function: Delete records in the main scopus tables with source_id from scopus*.del files.
Date: 07/22/2019
Author: Djamil Lakhdar-Hamina - reduced to only perform delete on scopus_publications. Downstream deletes should be automatically handled with FK constraints.
*/

-- Set temporary tablespace for calculation.
SET log_temp_files = 0;

\set ECHO all
\set ON_ERROR_STOP on

CREATE TEMPORARY TABLE stg_deleted_scopus_publications (
  source_id VARCHAR(30)
) TABLESPACE temp_tbs;
\copy stg_deleted_scopus_publications from 'del_scopusid.csv' (FORMAT csv);

-- Delete wos_publications to del_wos_publications.
\echo ***DELETING FROM TABLE: scopus_publications
DELETE FROM scopus_publications a
WHERE exists(SELECT 1
             FROM stg_deleted_scopus_publications b
             WHERE a.source_id = b.source_id);
