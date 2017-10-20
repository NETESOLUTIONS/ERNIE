-- Author: VJ Davey
-- This script is used to generate first generation reference information for the drug ipilimumab based on the values in a table of seeding PMIDs, and existing database information mapping PMIDs to WoS IDs and grants, and WoS IDs to a citation network of WoS IDs.

set default_tablespace=ernie_default_tbs;

--Show how many PMIDs we are starting with
\! echo 'Count of pmids in seed set:'
select count(*) as seed_set_pmid_count from case_ipilimumab;
\! echo 'Distinct pmid count in seed set:'
select count(distinct pmid) as distinct_pmids_in_seed_set from case_ipilimumab;

--Map PMID to WoS IDs and Exporter Projects
\! echo 'Mapping PMIDs to WoS IDs'
drop table if exists case_ipilimumab_pmid_wos_projects;
create table case_ipilimumab_pmid_wos_projects as
select a.pmid, b.wos_id, c.project_number from
  (select distinct pmid from case_ipilimumab) a left join wos_pmid_mapping b
    on CAST(a.pmid as int)=b.pmid_int
  left join exporter_publink c
    on b.pmid_int=CAST(c.pmid as int);
\! echo 'Distinct WoS IDs in seed set:'
 select count(distinct wos_id) as distinct_wos_ids_for_seed_set from case_ipilimumab_pmid_wos_projects;
\! echo 'Percent of seed PMIDs with WoS ID in database:'
select CAST(count(distinct wos_id) as decimal)/count(distinct pmid) as percent_PMIDS_with_matching_WoS from case_ipilimumab_pmid_wos_projects;
--\! echo 'Percent of seed PMIDs with Grant Info in database:'


--Get Gen1 Cited WoS IDs for all the given PMID/WoS IDs
drop table if exists case_ipilimumab_gen1_ref;
create table case_ipilimumab_gen1_ref as
select a.*, b.cited_source_uid as gen1_cited_wos_id from
  (select aa.* from
    (select distinct wos_id, pmid
      from case_ipilimumab_pmid_wos_projects) aa
    where aa.wos_id is not null) a
  left join wos_references b
    on a.wos_id=b.source_id;
update case_ipilimumab_gen1_ref
set gen1_cited_wos_id =
(    case when gen1_cited_wos_id like 'WOS%'
           then gen1_cited_wos_id
         when gen1_cited_wos_id like 'MED%' or gen1_cited_wos_id like 'NON%' or
         gen1_cited_wos_id like 'CSC%' or gen1_cited_wos_id like 'INS%' or
         gen1_cited_wos_id like 'BCI%' or gen1_cited_wos_id like 'CCC%' or
         gen1_cited_wos_id like 'SCI%' or gen1_cited_wos_id=''
           then gen1_cited_wos_id
         else substring('WOS:'||gen1_cited_wos_id, 1)
       end
);
create index case_ipilimumab_gen1_ref_idx on case_ipilimumab_gen1_ref
  using btree (gen1_cited_wos_id) tablespace ernie_index_tbs;

--Get Gen1 PMIDs for all the Cited WoS documents
drop table if exists case_ipilimumab_gen1_ref_pmid;
create table case_ipilimumab_gen1_ref_pmid as
  select a.*, b.pmid_int as gen1_pmid
  from case_ipilimumab_gen1_ref a
  left join wos_pmid_mapping b
  on a.gen1_cited_wos_id=b.wos_id;
create index case_ipilimumab_gen1_ref_pmid_idx on case_ipilimumab_gen1_ref_pmid
  using btree (gen1_pmid) tablespace ernie_index_tbs;
--TODO: add update here that rescues PMID by stripping MEDLINE document identifiers
update case_ipilimumab_gen1_ref_pmid
set gen1_pmid =
(    case
        when gen1_cited_wos_id like 'MEDLINE:%'
          then CAST(substring(gen1_cited_wos_id,9) as int)
        else
          gen1_pmid
     end
);


--Get Gen 1 Grants
drop table if exists case_ipilimumab_gen1_ref_grant;
create table case_ipilimumab_gen1_ref_grant as
  select a.*, b.project_number as gen1_project_num
  from case_ipilimumab_gen1_ref_pmid a
  left join exporter_publink b
  on a.gen1_pmid=CAST(b.pmid as int);
create index case_ipilimumab_gen1_ref_grant_idx on case_ipilimumab_gen1_ref_grant
  using btree (gen1_project_num) tablespace ernie_index_tbs;

\! echo 'Number of Unique Gen1 WoS IDs that dont appear in the seed set:'
select count (distinct gen1_cited_wos_id) as num_g1_wos_in_seed_set from case_ipilimumab_gen1_ref_grant where gen1_cited_wos_id not in (select wos_id from case_ipilimumab_pmid_wos_projects where wos_id is not null);
\! echo 'Number of Unique Gen1 WoS IDs that do appear in the seed set:'
select count (distinct gen1_cited_wos_id) as num_g1_wos_not_in_seed_set from case_ipilimumab_gen1_ref_grant where gen1_cited_wos_id in (select wos_id from case_ipilimumab_pmid_wos_projects where wos_id is not null);
