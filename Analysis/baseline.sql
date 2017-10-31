-- Author: VJ Davey
-- This script is used to generate first generation reference information for a drug

set default_tablespace=ernie_default_tbs;

-- List how many review pmids and seed pmids we are starting with
\! echo '***Count of pmids in review set:'
select count(*) as review_set_pmid_count from case_DRUG_NAME_HERE_review_set;
\! echo '***Count of pmids in seed set:'
select count(*) as seed_set_pmid_count from case_DRUG_NAME_HERE_seed_set;

--collect first generation PMIDs from the review set via WoS mapping
\! echo '***Mapping review PMIDs to WoS IDs'
drop table if exists case_DRUG_NAME_HERE_gen1_review_ref;
create table case_DRUG_NAME_HERE_gen1_review_ref as
select a.pmid, b.wos_id, c.cited_source_uid as gen1_cited_wos_id from
  (select distinct pmid from case_DRUG_NAME_HERE_review_set) a
  left join wos_pmid_mapping b
    on CAST(a.pmid as int)=b.pmid_int
  left join wos_references c
    on b.wos_id=c.source_id;
--recover any mangled citations
update case_DRUG_NAME_HERE_gen1_review_ref
set gen1_cited_wos_id =
(    case when gen1_cited_wos_id like 'WOS%' or gen1_cited_wos_id like 'MED%' or gen1_cited_wos_id like 'NON%' or
         gen1_cited_wos_id like 'CSC%' or gen1_cited_wos_id like 'INS%' or
         gen1_cited_wos_id like 'BCI%' or gen1_cited_wos_id like 'CCC%' or
         gen1_cited_wos_id like 'SCI%' or gen1_cited_wos_id=''
           then gen1_cited_wos_id
         else substring('WOS:'||gen1_cited_wos_id, 1)
       end
);
--pull g1 pmids for review set and feed into seed set, drop the intermediate table, recover any pmids, create new seed set table
drop table if exists case_DRUG_NAME_HERE_gen1_review_ref_pmid;
create table case_DRUG_NAME_HERE_gen1_review_ref_pmid as
  select a.*, b.pmid_int as gen1_pmid
  from case_DRUG_NAME_HERE_gen1_review_ref a
  left join wos_pmid_mapping b
  on a.gen1_cited_wos_id=b.wos_id;
update case_DRUG_NAME_HERE_gen1_review_ref_pmid
set gen1_pmid =
(    case
        when gen1_cited_wos_id like 'MEDLINE:%'
          then CAST(substring(gen1_cited_wos_id,9) as int)
        else
          gen1_pmid
     end
);
drop table if exists case_DRUG_NAME_HERE_adjusted_seed_set;
create table case_DRUG_NAME_HERE_adjusted_seed_set as
  select distinct pmid
  from (
  select pmid from case_DRUG_NAME_HERE_seed_set
  union
  select gen1_pmid from case_DRUG_NAME_HERE_gen1_review_ref_pmid
) a;
--clean up review intermediate tables
drop table if exists case_DRUG_NAME_HERE_gen1_review_ref_pmid;
drop table if exists case_DRUG_NAME_HERE_gen1_review_ref;
-------------------------------------------
---- Now we move on to actual analysis ----
-------------------------------------------
--Show the user how many PMIDs we are starting with
\! echo 'Distinct PMID count in adjusted seed set:'
select count(distinct pmid) as distinct_pmids_in_seed_set from case_DRUG_NAME_HERE_adjusted_seed_set;

--Map PMID to WoS IDs and Exporter Projects
\! echo 'Mapping PMIDs to WoS IDs'
drop table if exists case_DRUG_NAME_HERE_pmid_wos_projects;
create table case_DRUG_NAME_HERE_pmid_wos_projects as
select a.pmid, b.wos_id, c.project_number from
  (select distinct pmid from case_DRUG_NAME_HERE_adjusted_seed_set) a left join wos_pmid_mapping b
    on CAST(a.pmid as int)=b.pmid_int
  left join exporter_publink c
    on b.pmid_int=CAST(c.pmid as int);
-- Show the user loss statistics via mapping
\! echo 'Total Distinct WoS IDs in seed set:'
 select count(distinct wos_id) as distinct_wos_ids_for_seed_set from case_DRUG_NAME_HERE_pmid_wos_projects;
\! echo 'Percent loss when mapping PMID to WoS for seed set:'
select (1-CAST(count(distinct wos_id) as decimal)/count(distinct pmid)) as percent_PMIDS_with_matching_WoS from case_DRUG_NAME_HERE_pmid_wos_projects;

--Continued generational mapping added to the base table based on the number of iterations the user wants to cover
DROP TABLE IF EXISTS case_DRUG_NAME_HERE_generational_references;
create table case_DRUG_NAME_HERE_generational_references as
select * from case_DRUG_NAME_HERE_pmid_wos_projects;

DO $$
BEGIN
   FOR X IN 1..INSERT_DESIRED_NUMBER_OF_ITERATIONS_HERE LOOP
      IF X=1 THEN
        EXECUTE('create table case_DRUG_NAME_HERE_gen'||X||'_ref as
        select a.*, b.cited_source_uid as gen'||X||'_cited_wos_id from
          (select aa.* from
            (select distinct pmid, wos_id
              from case_DRUG_NAME_HERE_generational_references) aa
            where aa.wos_id is not null) a
          left join wos_references b
            on a.wos_id=b.source_id;');
        EXECUTE('update case_DRUG_NAME_HERE_gen'||X||'_ref
          set gen'||X||'_cited_wos_id =
            (    case when gen'||X||'_cited_wos_id like ''MED%'' or gen'||X||'_cited_wos_id like ''NON%'' or gen'||X||'_cited_wos_id like ''WOS%'' or
                     gen'||X||'_cited_wos_id like ''CSC%'' or gen'||X||'_cited_wos_id like ''INS%'' or
                     gen'||X||'_cited_wos_id like ''BCI%'' or gen'||X||'_cited_wos_id like ''CCC%'' or
                     gen'||X||'_cited_wos_id like ''SCI%'' or gen'||X||'_cited_wos_id=''''
                       then gen'||X||'_cited_wos_id
                     else substring(''WOS:''||gen'||X||'_cited_wos_id, 1)
                   end);');
        EXECUTE('drop table if exists case_DRUG_NAME_HERE_gen'||X||'_ref_pmid;
        create table case_DRUG_NAME_HERE_gen'||X||'_ref_pmid as
          select a.*, b.pmid_int as gen'||X||'_pmid
          from case_DRUG_NAME_HERE_gen'||X||'_ref a
          left join wos_pmid_mapping b
          on a.gen'||X||'_cited_wos_id=b.wos_id;
        update case_DRUG_NAME_HERE_gen'||X||'_ref_pmid
        set gen'||X||'_pmid =
        (    case
                when gen'||X||'_cited_wos_id like ''MEDLINE:%''
                  then CAST(substring(gen'||X||'_cited_wos_id,9) as int)
                else
                  gen'||X||'_pmid
             end );');
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_generational_references;
        EXECUTE('DROP TABLE IF EXISTS case_DRUG_NAME_HERE_gen'||X||'_ref;');
        EXECUTE('ALTER TABLE case_DRUG_NAME_HERE_gen'||X||'_ref_pmid
          RENAME TO case_DRUG_NAME_HERE_generational_references;');
        create index case_DRUG_NAME_HERE_generational_references_wos_index on case_DRUG_NAME_HERE_generational_references
          using btree (wos_id) tablespace ernie_index_tbs;
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network;
        EXECUTE('create table case_DRUG_NAME_HERE_citation_network as
        select distinct a.citing as citing_wos, b.cited_source_uid as cited_wos from
          ( select distinct wos_id as citing from case_DRUG_NAME_HERE_generational_references
            union all
            select distinct gen'||X||'_cited_wos_id as citing from case_DRUG_NAME_HERE_generational_references
          ) a
          inner join wos_references b
            on a.citing=b.source_id
          where b.cited_source_uid in (select wos_id as citing from case_DRUG_NAME_HERE_generational_references)
            or b.cited_source_uid in (select gen'||X||'_cited_wos_id as citing from case_DRUG_NAME_HERE_generational_references) ;');
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_pmid;
        EXECUTE('create table case_DRUG_NAME_HERE_citation_network_pmid as
        select distinct b.pmid_int as citing_pmid, a.citing_wos, a.cited_wos, c.pmid_int as cited_pmid
        from
          case_DRUG_NAME_HERE_citation_network_wos a inner join wos_pmid_mapping b
            on a.citing_wos=b.wos_id
          inner join wos_pmid_mapping c
            on a.cited_wos=c.wos_id;
        update case_DRUG_NAME_HERE_citation_network_pmid
          set citing_pmid =
          (    case
                  when citing_wos like ''MEDLINE:%''
                    then CAST(substring(citing_wos,9) as int)
                  else
                    citing_pmid
               end );
        update case_DRUG_NAME_HERE_citation_network_pmid
          set cited_pmid =
          (    case
                  when cited_wos like ''MEDLINE:%''
                    then CAST(substring(cited_wos,9) as int)
                  else
                    cited_pmid
               end )');
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network;
        ALTER TABLE case_DRUG_NAME_HERE_citation_network_pmid RENAME TO case_DRUG_NAME_HERE_citation_network;
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_authors;
        EXECUTE('create table case_DRUG_NAME_HERE_citation_network_authors as
        select distinct a.pmid, a.wos_id, b.full_name from
        ( select distinct citing_wos as wos_id, citing_pmid as pmid from case_DRUG_NAME_HERE_citation_network
          union all
          select distinct cited_wos as wos_id, cited_pmid as pmid from case_DRUG_NAME_HERE_citation_network
        ) a
        left join wos_authors b
          on a.wos_id=b.source_id
        where a.wos_id is not null;');

      ELSE
        EXECUTE('create table case_DRUG_NAME_HERE_gen'||X||'_ref as
        select a.*, b.cited_source_uid as gen'||X||'_cited_wos_id from
          case_DRUG_NAME_HERE_generational_references a
          left join wos_references b
            on a.gen'||X-1||'_cited_wos_id=b.source_id;');
        EXECUTE('update case_DRUG_NAME_HERE_gen'||X||'_ref
          set gen'||X||'_cited_wos_id =
            (    case when gen'||X||'_cited_wos_id like ''MED%'' or gen'||X||'_cited_wos_id like ''NON%'' or gen'||X||'_cited_wos_id like ''WOS%'' or
                     gen'||X||'_cited_wos_id like ''CSC%'' or gen'||X||'_cited_wos_id like ''INS%'' or
                     gen'||X||'_cited_wos_id like ''BCI%'' or gen'||X||'_cited_wos_id like ''CCC%'' or
                     gen'||X||'_cited_wos_id like ''SCI%'' or gen'||X||'_cited_wos_id=''''
                       then gen'||X||'_cited_wos_id
                     else substring(''WOS:''||gen'||X||'_cited_wos_id, 1)
                   end);');
        EXECUTE('drop table if exists case_DRUG_NAME_HERE_gen'||X||'_ref_pmid;
        create table case_DRUG_NAME_HERE_gen'||X||'_ref_pmid as
          select a.*, b.pmid_int as gen'||X||'_pmid
          from case_DRUG_NAME_HERE_gen'||X||'_ref a
          left join wos_pmid_mapping b
          on a.gen'||X||'_cited_wos_id=b.wos_id;
        update case_DRUG_NAME_HERE_gen'||X||'_ref_pmid
        set gen'||X||'_pmid =
        (    case
                when gen'||X||'_cited_wos_id like ''MEDLINE:%''
                  then CAST(substring(gen'||X||'_cited_wos_id,9) as int)
                else
                  gen'||X||'_pmid
             end );
        create table case_DRUG_NAME_HERE_gen'||X||'_ref_pmid_grant as
          select a.*, b.project_number as gen'||X||'_project_number
          from case_DRUG_NAME_HERE_gen'||X||'_ref_pmid a
          left join exporter_publink b
          on a.gen'||X||'_pmid=CAST(b.pmid as int);');
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_generational_references;
        EXECUTE('DROP TABLE IF EXISTS case_DRUG_NAME_HERE_gen'||X||'_ref;');
        EXECUTE('DROP TABLE IF EXISTS case_DRUG_NAME_HERE_gen'||X||'_ref_pmid;');
        EXECUTE('ALTER TABLE case_DRUG_NAME_HERE_gen'||X||'_ref_pmid_grant
          RENAME TO case_DRUG_NAME_HERE_generational_references;');

      END IF;
      RAISE NOTICE 'Completed Iteration: %', X;
   END LOOP;
END; $$;
