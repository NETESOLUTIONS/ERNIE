
-- Author: Samet Keserci, Lingtian "Lindsay" Wan
-- Create Date: 08/11/2017
-- Modified from serial loading process.



-- Set temporary tablespace for calculation.
set log_temp_files = 0;
set enable_seqscan='off';
--set temp_tablespaces = 'temp_tbs';
SET temp_tablespaces='pardi_private_tbs'; -- temporaryly it is being set.
--set enable_hashjoin = 'off';
--set enable_mergejoin = 'off';
set search_path = public;


-- Update table: wos_publications
\echo ***UPDATING TABLE: wos_publications
--insert into uhs_wos_publications
--  select
--    id, source_id, source_type, source_title, language, document_title,
--    document_type, has_abstract, issue, volume, begin_page, end_page,
--    publisher_name, publisher_address, publication_year, publication_date,
--    created_date, last_modified_date, edition, source_filename
--  from wos_publications a
--  where exists
--  (select 1 from temp_replace_wosid b where a.source_id=b.source_id);

update wos_publications as a
  set (source_id, source_type, source_title, language, document_title,
    document_type, has_abstract, issue, volume, begin_page, end_page,
    publisher_name, publisher_address, publication_year, publication_date,
    created_date, last_modified_date, edition, source_filename) =
    (b.source_id, b.source_type, b.source_title, b.language, b.document_title,
    b.document_type, b.has_abstract, b.issue, b.volume, b.begin_page,
    b.end_page, b.publisher_name, b.publisher_address, b.publication_year,
    b.publication_date, b.created_date, b.last_modified_date, b.edition,
    b.source_filename)
  from new_wos_publications b where a.source_id=b.source_id;
insert into wos_publications
  (id, source_id, source_type, source_title, language, document_title,
   document_type, has_abstract, issue, volume, begin_page, end_page,
   publisher_name, publisher_address, publication_year, publication_date,
   created_date, last_modified_date, edition, source_filename)
  select * from new_wos_publications a
  where not exists
  (select * from temp_replace_wosid b where a.source_id=b.source_id);
