-- Author: Samet Keserci, Lingtian "Lindsay" Wan
-- Create Date: 08/11/2017
-- Modified from serial loading process.

\set ON_ERROR_STOP on
\set ECHO all

-- Set temporary tablespace for calculation.
SET log_temp_files = 0;
--set enable_seqscan='off';
--set temp_tablespaces = 'temp_tbs';
--set enable_hashjoin = 'off';
--set enable_mergejoin = 'off';

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
  (source_id, source_type, source_title, language, document_title, document_type, has_abstract, issue, volume, begin_page, end_page, publisher_name, publisher_address, publication_year, publication_date, created_date, last_modified_date, edition, source_filename) = (b.source_id, b.source_type, b.source_title, b.language, b.document_title, b.document_type, b.has_abstract, b.issue, b.volume, b.begin_page, b.end_page, b.publisher_name, b.publisher_address, CAST(
    b.publication_year AS
    INT), b.publication_date, b.created_date, b.last_modified_date, b.edition, b.source_filename) FROM
  new_wos_publications b
WHERE a.source_id = b.source_id;

INSERT INTO wos_publications (id, source_id, source_type, source_title, language, document_title, document_type, has_abstract, issue, volume, begin_page, end_page, publisher_name, publisher_address, cast(publication_year AS INT ), publication_date, created_date, last_modified_date, edition, source_filename)
  SELECT *
  FROM new_wos_publications a
  WHERE NOT exists(SELECT *
                   FROM temp_replace_wosid b
                   WHERE a.source_id = b.source_id);
