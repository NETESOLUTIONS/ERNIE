-- This script counts the CG related statistics.

-- Author: Lingtian "Lindsay" Wan
-- Create Date: 09/20/2016
-- Modified : 11/20/2016, Samet Keserci, search_path revised for schema
--            03/20/2017, Samet Keserci, revised according to migration from dev2 to dev3


-- Change the search_path for the schema
SET search_path to public;

set log_temp_files = 0;
set enable_seqscan='off';
set temp_tablespaces = 'temp_tbs';
set enable_hashjoin = 'off';
set enable_mergejoin = 'off';

-- CG statistics

-- Get number of all CGs
\echo All CG in database:
insert into cg_ref_counts (all_cg)
  select count(1) from cg_uids;

-- Get number of current CGs
\echo Current CG:
update cg_ref_counts
  set current_cg =
  (select count(1) from cg_uids where status='current')
  where id = (select max(id) from cg_ref_counts);

-- Get number of current CGs with pmid
\echo Current CG with PMID:
update cg_ref_counts
  set current_pmid =
  (select count(1) from cg_uid_pmid_mapping a
   inner join cg_uids b
   on a.uid=b.uid
   where status='current')
  where id = (select max(id) from cg_ref_counts);

-- Get number of current CG-pmids with WoS ids
drop table if exists cg_pmid_wos;
create table cg_pmid_wos tablespace cgdata_tbs as
select a.uid, a.pmid, b.wos_uid from cg_uid_pmid_mapping a
  inner join wos_pmid_mapping b
  on cast(a.pmid as int)=b.pmid_int;
\echo Current CG-PMID with WoS:
update cg_ref_counts
  set current_wos =
  (select count(1) from cg_pmid_wos)
  where id = (select max(id) from cg_ref_counts);

-- Gen1 statistics

-- Get number of gen1 unique WoS ids
drop table if exists cg_gen1_ref;
create table cg_gen1_ref tablespace cgdata_tbs as
  select a.*, b.cited_source_uid from cg_pmid_wos a
  inner join wos_references b
  on a.wos_uid=b.source_id;
update cg_gen1_ref
set cited_source_uid =
(    case when cited_source_uid like 'WOS%'
           then cited_source_uid
         when cited_source_uid like 'MED%' or cited_source_uid like 'NON%' or
         cited_source_uid like 'CSC%' or cited_source_uid like 'INS%' or
         cited_source_uid like 'BCI%' or cited_source_uid like 'CCC%' or
         cited_source_uid like 'SCI%' or cited_source_uid=''
           then cited_source_uid
         else substring('WOS:'||cited_source_uid, 1)
       end
);
create index cg_gen1_ref_idx on cg_gen1_ref
  using btree (cited_source_uid) tablespace cgindex_tbs;
\echo Gen1 WoS:
update cg_ref_counts
  set gen1_wos =
  (select count(distinct cited_source_uid) from cg_gen1_ref)
  where id = (select max(id) from cg_ref_counts);

-- Get number of gen1 unique pmids
drop table if exists cg_gen1_ref_pmid;
create table cg_gen1_ref_pmid tablespace cgdata_tbs as
  select a.*, b.pmid_int
  from cg_gen1_ref a
  inner join wos_pmid_mapping b
  on a.cited_source_uid=b.wos_uid;
create index cg_gen1_ref_pmid_idx on cg_gen1_ref_pmid
  using btree (pmid_int) tablespace cgindex_tbs;
\echo Gen1 PMID:
update cg_ref_counts
  set gen1_pmid =
  (select count(distinct pmid_int) from cg_gen1_ref_pmid)
  where id = (select max(id) from cg_ref_counts);

-- Get number of gen1 unique grant numbers
drop table if exists cg_gen1_ref_grant;
create table cg_gen1_ref_grant tablespace cgdata_tbs as
  select a.*, b.full_project_num_dc
  from cg_gen1_ref_pmid a
  inner join spires_pub_projects b
  on a.pmid_int=b.pmid;
create index cg_gen1_ref_grant_idx on cg_gen1_ref_grant
  using btree (full_project_num_dc) tablespace cgindex_tbs;
\echo Gen1 Grant:
update cg_ref_counts
  set gen1_grant =
  (select count(distinct full_project_num_dc) from cg_gen1_ref_grant)
  where id = (select max(id) from cg_ref_counts);

-- Gen2 statistics

-- Get number of gen2 unique WoS ids
drop table if exists cg_gen2_ref;
create table cg_gen2_ref tablespace cgdata_tbs as
  select a.cited_source_uid as wos_uid, b.cited_source_uid
  from cg_gen1_ref a
  inner join wos_references b
  on a.cited_source_uid=b.source_id;
update cg_gen2_ref
set cited_source_uid =
(    case when cited_source_uid like 'WOS%'
           then cited_source_uid
         when cited_source_uid like 'MED%' or cited_source_uid like 'NON%' or
         cited_source_uid like 'CSC%' or cited_source_uid like 'INS%' or
         cited_source_uid like 'BCI%' or cited_source_uid like 'CCC%' or
         cited_source_uid like 'SCI%' or cited_source_uid=''
           then cited_source_uid
         else substring('WOS:'||cited_source_uid, 1)
       end
);
create index cg_gen2_ref_idx on cg_gen2_ref
  using btree (cited_source_uid) tablespace cgindex_tbs;
\echo Gen2 WoS:
update cg_ref_counts
  set gen2_wos =
  (select count(distinct cited_source_uid) from cg_gen2_ref)
  where id = (select max(id) from cg_ref_counts);

-- Get number of gen2 unique pmids
drop table if exists cg_gen2_ref_pmid;
create table cg_gen2_ref_pmid tablespace cgdata_tbs as
  select a.wos_uid, a.cited_source_uid, b.pmid_int
  from cg_gen2_ref a
  inner join wos_pmid_mapping b
  on a.cited_source_uid=b.wos_uid;
create index cg_gen2_ref_pmid_idx on cg_gen2_ref_pmid
  using btree (pmid_int) tablespace cgindex_tbs;
\echo Gen2 PMID:
update cg_ref_counts
  set gen2_pmid =
  (select count(distinct pmid_int) from cg_gen2_ref_pmid)
  where id = (select max(id) from cg_ref_counts);

-- Get number of gen2 unique grant numbers
drop table if exists cg_gen2_ref_grant;
create table cg_gen2_ref_grant tablespace cgdata_tbs as
  select a.*, b.full_project_num_dc
  from cg_gen2_ref_pmid a
  inner join spires_pub_projects b
  on a.pmid_int=b.pmid;
create index cg_gen2_ref_grant_idx on cg_gen2_ref_grant
  using btree (full_project_num_dc) tablespace cgindex_tbs;
\echo Gen2 Grant:
update cg_ref_counts
  set gen2_grant =
  (select count(distinct full_project_num_dc) from cg_gen2_ref_grant),
  last_updated = current_timestamp
  where id = (select max(id) from cg_ref_counts);
