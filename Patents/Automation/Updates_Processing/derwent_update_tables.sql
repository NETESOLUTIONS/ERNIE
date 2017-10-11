-- This script updates the main Derwent table (derwent_*) with data from
-- newly-downloaded files. Specifically:

--     1. Find update records: find patent_num_orig that need to be updated,
--        and move current records with these patent_num_orig to the
--        update history tables: uhs_derwent_*.
--     2. Insert updated/new records: insert all the records from the new
--        tables (new_derwent_*) into the main table: derwent_*.
--     3. Truncate the new tables: new_derwent_*.
--     4. Record to log table: update_log_derwent.

-- Relevant main tables:
--     1. derwent_agents
--     2. derwent_assignees
--     3. derwent_assignors
--     4. derwent_examiners
--     5. derwent_inventors
--     6. derwent_lit_citations
--     7. derwent_pat_citations
--     8. derwent_patents

-- Usage: psql -d pardi -f derwent_update_tables.sql

-- Author: Lingtian "Lindsay" Wan
-- Create Date: 04/21/2016
-- Modified: 05/19/2016, Lindsay Wan, added documentation
--         : 11/21/2016, Samet Keserci, revised wrt new schema plan

set search_path to public, samet;

-- Set temporary tablespace for calculation.
set log_temp_files = 0;
set temp_tablespaces = 'temp_tbs';

-- Create a temp table to store patent numbers from the update file.
drop table if exists temp_update_patnum;
create table temp_update_patnum as
  select patent_num_orig from new_derwent_patents;

-- Create a temp table to store update patent numbers that already exist in
-- derwent tables.
drop table if exists temp_replace_patnum;
create table temp_replace_patnum as
  select a.patent_num_orig from temp_update_patnum a
  inner join derwent_patents b
  on a.patent_num_orig=b.patent_num_orig;

-- Update log file.
insert into update_log_derwent (num_update)
  select count(*) from temp_replace_patnum;
update update_log_derwent set num_new =
  (select count(*) from temp_update_patnum) - num_update
  where id = (select max(id) from update_log_derwent);

-- Update table: derwent_agents
\echo ***UPDATING TABLE: derwent_agents
insert into uhs_derwent_agents
  select a.* from derwent_agents a inner join temp_update_patnum b
  on a.patent_num=b.patent_num_orig;
delete from derwent_agents
  where patent_num in (select * from temp_replace_patnum);
insert into derwent_agents
  select * from new_derwent_agents;

-- Update table: derwent_assignees
\echo ***UPDATING TABLE: derwent_assignees
insert into uhs_derwent_assignees
  select a.* from derwent_assignees a inner join temp_update_patnum b
  on a.patent_num=b.patent_num_orig;
delete from derwent_assignees
  where patent_num in (select * from temp_replace_patnum);
insert into derwent_assignees
  select * from new_derwent_assignees;

-- Update table: derwent_assignors
\echo ***UPDATING TABLE: derwent_assignors
insert into uhs_derwent_assignors
  select a.* from derwent_assignors a inner join temp_update_patnum b
  on a.patent_num=b.patent_num_orig;
delete from derwent_assignors
  where patent_num in (select * from temp_replace_patnum);
insert into derwent_assignors
  select * from new_derwent_assignors;

-- Update table: derwent_examiners
\echo ***UPDATING TABLE: derwent_examiners
insert into uhs_derwent_examiners
  select a.* from derwent_examiners a inner join temp_update_patnum b
  on a.patent_num=b.patent_num_orig;
delete from derwent_examiners
  where patent_num in (select * from temp_replace_patnum);
insert into derwent_examiners
  select * from new_derwent_examiners;

-- Update table: derwent_inventors
\echo ***UPDATING TABLE: derwent_inventors
insert into uhs_derwent_inventors
  select a.* from derwent_inventors a inner join temp_update_patnum b
  on a.patent_num=b.patent_num_orig;
delete from derwent_inventors
  where patent_num in (select * from temp_replace_patnum);
insert into derwent_inventors
  select * from new_derwent_inventors;

-- Update table: derwent_lit_citations
\echo ***UPDATING TABLE: derwent_lit_citations
insert into uhs_derwent_lit_citations
  select a.* from derwent_lit_citations a inner join temp_update_patnum b
  on a.patent_num_orig=b.patent_num_orig;
delete from derwent_lit_citations
  where patent_num_orig in (select * from temp_replace_patnum);
insert into derwent_lit_citations
  select * from new_derwent_lit_citations;

-- Update table: derwent_pat_citations
\echo ***UPDATING TABLE: derwent_pat_citations
insert into uhs_derwent_pat_citations
  select a.* from derwent_pat_citations a inner join temp_update_patnum b
  on a.patent_num_orig=b.patent_num_orig;
delete from derwent_pat_citations
  where patent_num_orig in (select * from temp_replace_patnum);
insert into derwent_pat_citations
  select * from new_derwent_pat_citations;

-- Update table: derwent_patents
\echo ***UPDATING TABLE: derwent_patents
insert into uhs_derwent_patents
  select a.* from derwent_patents a inner join temp_update_patnum b
  on a.patent_num_orig=b.patent_num_orig;
delete from derwent_patents
  where patent_num_orig in (select * from temp_replace_patnum);
insert into derwent_patents
  select * from new_derwent_patents;

-- Truncate new_derwent_tables.
\echo ***TRUNCATING TABLES: new_derwent_*
truncate table new_derwent_agents;
truncate table new_derwent_assignees;
truncate table new_derwent_assignors;
truncate table new_derwent_examiners;
truncate table new_derwent_inventors;
truncate table new_derwent_lit_citations;
truncate table new_derwent_pat_citations;
truncate table new_derwent_patents;

-- Update log table.
update update_log_derwent
  set last_updated = current_timestamp,
  num_derwent = (select count(*) from derwent_patents)
  where id = (select max(id) from update_log_derwent);
