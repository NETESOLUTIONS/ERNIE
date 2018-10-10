-- Author: VJ Davey
-- This script is used to generate first generation reference information for a drug

set default_tablespace=ernie_default_tbs;

-- Delete any '00000' entries in our base sql tables
DELETE FROM case_DRUG_NAME_HERE_review_set WHERE pmid='00000';
DELETE FROM case_DRUG_NAME_HERE_seed_set WHERE pmid='00000';

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
drop table if exists case_DRUG_NAME_HERE;
create table case_DRUG_NAME_HERE as
  select distinct pmid
  from (
  select pmid from case_DRUG_NAME_HERE_seed_set
  union
  select gen1_pmid from case_DRUG_NAME_HERE_gen1_review_ref_pmid
) a where pmid is not null;
--clean up review intermediate tables
drop table if exists case_DRUG_NAME_HERE_gen1_review_ref_pmid;
drop table if exists case_DRUG_NAME_HERE_gen1_review_ref;
-------------------------------------------
---- Now we move on to actual analysis ----
-------------------------------------------
--Show the user how many PMIDs we are starting with
\! echo 'Distinct PMID count in adjusted seed set (review first gen + base seed set):'
select count(distinct pmid) as distinct_pmids_in_seed_set from case_DRUG_NAME_HERE;

--Map PMID to WoS IDs and Exporter Projects
\! echo '***Mapping PMIDs to WoS IDs and dropping rows based on user input for YEAR CUTOFF'
drop table if exists case_DRUG_NAME_HERE_pmid_wos_projects;
create table case_DRUG_NAME_HERE_pmid_wos_projects as
select a.pmid, b.wos_id, c.project_number, d.publication_year from
  (select distinct pmid from case_DRUG_NAME_HERE) a left join wos_pmid_mapping b
    on CAST(a.pmid as int)=b.pmid_int
  left join wos_publications d
    on b.wos_id = d.source_id
  left join exporter_publink c
    on b.pmid_int=CAST(c.pmid as int)
  where d.publication_year <= YEAR_CUTOFF_HERE;
-- Show the user loss statistics via mapping
\! echo 'Total Distinct WoS IDs in seed set:'
 select count(distinct wos_id) as distinct_wos_ids_for_seed_set from case_DRUG_NAME_HERE_pmid_wos_projects;
\! echo 'Percent loss when mapping Seed PMIDs (with year cutoff) to WoS IDs (with year cutoff) for seed set:'
select (1-(CAST(count(distinct wos_id) as decimal)/count(distinct pmid))) as percent_PMIDS_without_matching_WoS from case_DRUG_NAME_HERE_pmid_wos_projects;

-- Throw in any supplementing WoS IDs from the supplementary table and create the baseline generational references table
\! echo '***Appending supplementary WoS IDs...'
--Continued generational mapping added to the base table based on the number of iterations the user wants to cover
DROP TABLE IF EXISTS case_DRUG_NAME_HERE_generational_references;
create table case_DRUG_NAME_HERE_generational_references as
select * from case_DRUG_NAME_HERE_pmid_wos_projects;
create table case_DRUG_NAME_HERE_wos_supplement_set_dedupe as
  select distinct * from case_DRUG_NAME_HERE_wos_supplement_set;
DROP TABLE IF EXISTS case_DRUG_NAME_HERE_wos_supplement_set;
ALTER TABLE case_DRUG_NAME_HERE_wos_supplement_set_dedupe RENAME TO case_DRUG_NAME_HERE_wos_supplement_set;
INSERT INTO case_DRUG_NAME_HERE_generational_references(pmid, wos_id, project_number)
select null, source_id, null from case_DRUG_NAME_HERE_wos_supplement_set where source_id not in (select wos_id from case_DRUG_NAME_HERE_generational_references where wos_id is not null);


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
          using btree (wos_id) TABLESPACE index_tbs;
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
          case_DRUG_NAME_HERE_citation_network a left join wos_pmid_mapping b
            on a.citing_wos=b.wos_id
          left join wos_pmid_mapping c
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
             end );');
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_generational_references;
        EXECUTE('DROP TABLE IF EXISTS case_DRUG_NAME_HERE_gen'||X||'_ref;');
        EXECUTE('ALTER TABLE case_DRUG_NAME_HERE_gen'||X||'_ref_pmid
          RENAME TO case_DRUG_NAME_HERE_generational_references;');
        EXECUTE('create index case_DRUG_NAME_HERE_generational_references_wos_index on case_DRUG_NAME_HERE_generational_references
          using btree (gen'||X||'_cited_wos_id) TABLESPACE index_tbs;');
        --create a dummy citation network table for genX references. Merge this into the main table and deduplicate
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_dummy;
        EXECUTE('create table case_DRUG_NAME_HERE_citation_network_dummy as
        select distinct a.citing as citing_wos, b.cited_source_uid as cited_wos from
          ( select distinct gen'||X-1||'_cited_wos_id as citing from case_DRUG_NAME_HERE_generational_references
            union all
            select distinct gen'||X||'_cited_wos_id as citing from case_DRUG_NAME_HERE_generational_references
          ) a
          inner join wos_references b
            on a.citing=b.source_id
          where b.cited_source_uid in (select gen'||X-1||'_cited_wos_id as citing from case_DRUG_NAME_HERE_generational_references)
            or b.cited_source_uid in (select gen'||X||'_cited_wos_id as citing from case_DRUG_NAME_HERE_generational_references) ;');
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_pmid_dummy;
        EXECUTE('create table case_DRUG_NAME_HERE_citation_network_pmid_dummy as
        select distinct b.pmid_int as citing_pmid, a.citing_wos, a.cited_wos, c.pmid_int as cited_pmid
        from
          case_DRUG_NAME_HERE_citation_network_dummy a left join wos_pmid_mapping b
            on a.citing_wos=b.wos_id
          left join wos_pmid_mapping c
            on a.cited_wos=c.wos_id;
        update case_DRUG_NAME_HERE_citation_network_pmid_dummy
          set citing_pmid =
          (    case
                  when citing_wos like ''MEDLINE:%''
                    then CAST(substring(citing_wos,9) as int)
                  else
                    citing_pmid
               end );
        update case_DRUG_NAME_HERE_citation_network_pmid_dummy
          set cited_pmid =
          (    case
                  when cited_wos like ''MEDLINE:%''
                    then CAST(substring(cited_wos,9) as int)
                  else
                    cited_pmid
               end )');
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_dummy;
        CREATE TABLE newtable AS SELECT * FROM (SELECT * FROM case_DRUG_NAME_HERE_citation_network
                                                UNION
                                                SELECT * FROM case_DRUG_NAME_HERE_citation_network_pmid_dummy) a;
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network;
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_pmid_dummy;
        ALTER TABLE newtable RENAME TO case_DRUG_NAME_HERE_citation_network;

      END IF;

      --Alter citation network table, include a column for a flag which indicates if the cited WOS ID is in wos publications.
      ALTER TABLE case_DRUG_NAME_HERE_citation_network
        ADD COLUMN cited_verification_flag INT;
      UPDATE case_DRUG_NAME_HERE_citation_network a
        SET cited_verification_flag = (CASE WHEN a.cited_wos in (select source_id from wos_publications where source_id=a.cited_wos) THEN 1
                                            WHEN a.cited_wos='MEDLINE%' THEN 2
                                           ELSE 0
                                           END);
      --TEMP -- subset the citation network to only retain rows where the cited_verification_flag is 1
      DELETE FROM case_DRUG_NAME_HERE_citation_network
        WHERE cited_verification_flag!=1;

      DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_years;
      EXECUTE('create table case_DRUG_NAME_HERE_citation_network_years as
      select distinct c.pmid_int, a.wos_id, b.publication_year from
      ( select distinct citing_wos as wos_id from case_DRUG_NAME_HERE_citation_network
        union all
        select distinct cited_wos as wos_id from case_DRUG_NAME_HERE_citation_network
      ) a
      left join wos_publications b
        on a.wos_id=b.source_id
      left join wos_pmid_mapping c
        on a.wos_id=c.wos_id
      where a.wos_id is not null;');
      DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_authors;
      EXECUTE('create table case_DRUG_NAME_HERE_citation_network_authors as
      select distinct a.pmid_int, a.wos_id, b.full_name from
      case_DRUG_NAME_HERE_citation_network_years a INNER JOIN wos_authors b
      on a.wos_id=b.source_id;');
      DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_grants_WOS;
      EXECUTE('create table case_DRUG_NAME_HERE_citation_network_grants_WOS as
      select distinct a.pmid_int, a.wos_id, b.grant_number, b.grant_organization from
      case_DRUG_NAME_HERE_citation_network_years a INNER JOIN wos_grants b
      on a.wos_id=b.source_id;');
      DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_locations;
      EXECUTE('create table case_DRUG_NAME_HERE_citation_network_locations as
      select distinct a.pmid_int, a.wos_id, b.organization, b.city, b.country from
      case_DRUG_NAME_HERE_citation_network_years a INNER JOIN wos_addresses b
      on a.wos_id=b.source_id;');
      DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_grants_SPIRES;
      EXECUTE('create table case_DRUG_NAME_HERE_citation_network_grants_SPIRES as
      select distinct a.pmid_int, a.wos_id, b.project_number from
      case_DRUG_NAME_HERE_citation_network_years a INNER JOIN exporter_publink b
      on a.pmid_int=CAST(b.pmid as int);');
      RAISE NOTICE 'Percent loss when mapping cited WoS IDs to PMIDs for Generation %:', X;
      EXECUTE('select (1-(CAST(count(gen'||X||'_cited_wos_id) as decimal)/count(gen'||X||'_pmid))) as
        percent_gen'||X||'_wos_id_with_matching_PMID from case_DRUG_NAME_HERE_generational_references;');
      RAISE NOTICE 'Completed Iteration: %', X;
   END LOOP;
END; $$;

--output tables to CSV format under disk space
COPY case_DRUG_NAME_HERE_citation_network TO '/erniedev_data2/DRUG_NAME_HERE_citation_network.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_years TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_years.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_grants_SPIRES TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_grants_SPIRES.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_grants_WOS TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_grants_WOS.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_locations TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_locations.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_authors TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_authors.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_generational_references TO '/erniedev_data2/DRUG_NAME_HERE_generational_references.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;

--collect some statistics and output to screen
\! echo '***Total distinct PMIDs in seed set:'
select count(distinct pmid) from case_DRUG_NAME_HERE_pmid_wos_projects;
\! echo '***Total distinct WoS IDs in seed set:'
select count(distinct wos_id) from case_DRUG_NAME_HERE_pmid_wos_projects;

\! printf '\n\n\n*** IMPORTANT ***\n\n The following counts are taken from the citation network table.\nSeedset PMIDs without a corresponding WoS ID are not counted in the network as they have droppped out of the network\n\n\n'
\! echo '***Total distinct cited documents:'
select count(distinct cited_wos) from case_DRUG_NAME_HERE_citation_network;
\! echo '***Total distinct cited WoS IDs (cited documents which map back into WoS Publications):'
select count(distinct a.cited_wos) from case_DRUG_NAME_HERE_citation_network a inner join wos_publications b on a.cited_wos=b.source_id;
\! echo '***Total distinct cited PMIDs:'
select count(distinct cited_pmid) from case_ipilimumab_citation_network  where cited_pmid is not null;
\! echo '***Total distinct documents in network (Remember - WoS backbone)' -- can use the years table here as it is a union into what is basically a node list table, left joined on years. As a result, the node listing is preserved even for those entries without years.
select count(distinct wos_id) from case_DRUG_NAME_HERE_citation_network_years;
\! echo '***Total distinct WoS IDs in network (Remember - WoS backbone -seedset pmids with no match are dropped out)'
select count(distinct a.wos_id) from case_DRUG_NAME_HERE_citation_network_years a inner join wos_publications b on a.wos_id=b.source_id;
--TODO\! echo '***Total distinct PMIDs in Network'
--TODO add calculation
