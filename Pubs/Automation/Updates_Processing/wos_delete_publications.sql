-- Author     : Samet Keserci, (prev version - Lindsay Wan)
-- Aim        : Delete the del.file records from wos tables in parallel. Previous version was in serial and written by Lindsay.
-- Create date: 08/28/2017


-- Set temporary tablespace for calculation.
set log_temp_files = 0;
set enable_seqscan='off';
--set temp_tablespaces = 'temp_tbs';
SET temp_tablespaces='temp'; -- temporaryly it is being set.
--set enable_hashjoin = 'off';
--set enable_mergejoin = 'off';
set search_path = public;

\echo ***DELETING FROM TABLE: wos_publications
insert into del_wos_publications
  select a.id, a.source_id, a.source_type, a.source_title, a.language,
  a.document_title, a.document_type, a.has_abstract, a.issue, a.volume,
  a.begin_page, a.end_page, a.publisher_name, a.publisher_address,
  a.publication_year, a.publication_date, a.created_date, a.last_modified_date,
  a.edition, a.source_filename
  from wos_publications a inner join temp_delete_wosid b
  on a.source_id=b.source_id;
delete from wos_publications a
  where exists
  (select 1 from temp_delete_wosid_6 b
    where a.source_id=b.source_id);
