-- Author: VJ Davey
-- This script is used to generate first generation reference information for a drug

set default_tablespace=ernie_default_tbs;

-- Delete any '00000' entries in our base sql tables
DELETE FROM case_DRUG_NAME_HERE_review_set WHERE pmid='00000';
DELETE FROM case_DRUG_NAME_HERE_seed_set WHERE pmid='00000';

-- List how many seed pmids we are starting with
\! echo '***Count of pmids in seed set:'
select count(*) as seed_set_pmid_count from case_DRUG_NAME_HERE_seed_set;
-- Create base table
drop table if exists case_DRUG_NAME_HERE;
create table case_DRUG_NAME_HERE as
  select distinct pmid
  from (
  select pmid from case_DRUG_NAME_HERE_seed_set
) a where pmid is not null;
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
    on b.pmid_int=CAST(c.pmid as int) where d.publication_year <= YEAR_CUTOFF_HERE;


-- Throw in any supplementing WoS IDs from the supplementary table and create the baseline generational references table
\! echo '***Appending supplementary WoS IDs...'
--Continued generational mapping added to the base table based on the number of iterations the user wants to cover
DROP TABLE IF EXISTS case_DRUG_NAME_HERE_generational_references_forward;
create table case_DRUG_NAME_HERE_generational_references_forward as
select * from case_DRUG_NAME_HERE_pmid_wos_projects;
create table case_DRUG_NAME_HERE_wos_supplement_set_dedupe as
  select distinct * from case_DRUG_NAME_HERE_wos_supplement_set;
DROP TABLE IF EXISTS case_DRUG_NAME_HERE_wos_supplement_set;
ALTER TABLE case_DRUG_NAME_HERE_wos_supplement_set_dedupe RENAME TO case_DRUG_NAME_HERE_wos_supplement_set;
INSERT INTO case_DRUG_NAME_HERE_generational_references_forward(pmid, wos_id, project_number)
select null, source_id, null from case_DRUG_NAME_HERE_wos_supplement_set where source_id not in (select wos_id from case_DRUG_NAME_HERE_generational_references_forward where wos_id is not null);


DO $$
BEGIN
   FOR X IN 1..INSERT_DESIRED_NUMBER_OF_ITERATIONS_HERE LOOP
      IF X=1 THEN
        EXECUTE('create table case_DRUG_NAME_HERE_gen'||X||'_ref_forward as
        select a.*, b.source_id as gen'||X||'_citing_wos_id from
          (select aa.* from
            (select distinct pmid, wos_id
              from case_DRUG_NAME_HERE_generational_references_forward) aa
            where aa.wos_id is not null) a
          left join wos_references b
            on a.wos_id=b.cited_source_uid;');
        --citing will always be a wos_id, no need to perform intermediate alterations to table values
        EXECUTE('drop table if exists case_DRUG_NAME_HERE_gen'||X||'_ref_pmid_forward;
        create table case_DRUG_NAME_HERE_gen'||X||'_ref_pmid_forward as
          select a.*, b.pmid_int as gen'||X||'_citing_pmid
          from case_DRUG_NAME_HERE_gen'||X||'_ref_forward a
          left join wos_pmid_mapping b
          on a.gen'||X||'_citing_wos_id=b.wos_id;');
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_generational_references_forward;
        EXECUTE('DROP TABLE IF EXISTS case_DRUG_NAME_HERE_gen'||X||'_ref_forward;');
        EXECUTE('ALTER TABLE case_DRUG_NAME_HERE_gen'||X||'_ref_pmid_forward
          RENAME TO case_DRUG_NAME_HERE_generational_references_forward;');
        create index case_DRUG_NAME_HERE_generational_references_wos_index_forward on case_DRUG_NAME_HERE_generational_references_forward
          using btree (wos_id) tablespace indexes;
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_forward;
        EXECUTE('create table case_DRUG_NAME_HERE_citation_network_forward as
        select distinct b.source_id as citing_wos, a.cited as cited_wos from
          ( select distinct wos_id as cited from case_DRUG_NAME_HERE_generational_references_forward
            union all
            select distinct gen'||X||'_citing_wos_id as cited from case_DRUG_NAME_HERE_generational_references_forward
          ) a
          inner join wos_references b
            on a.cited=b.cited_source_uid
          where b.source_id in (select wos_id as cited from case_DRUG_NAME_HERE_generational_references_forward)
            or b.source_id in (select gen'||X||'_citing_wos_id as cited from case_DRUG_NAME_HERE_generational_references_forward) ;');
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_pmid_forward;
        EXECUTE('create table case_DRUG_NAME_HERE_citation_network_pmid_forward as
        select distinct b.pmid_int as citing_pmid, a.citing_wos, a.cited_wos, c.pmid_int as cited_pmid
        from
          case_DRUG_NAME_HERE_citation_network_forward a left join wos_pmid_mapping b
            on a.citing_wos=b.wos_id
          left join wos_pmid_mapping c
            on a.cited_wos=c.wos_id;');
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_forward;
        ALTER TABLE case_DRUG_NAME_HERE_citation_network_pmid_forward RENAME TO case_DRUG_NAME_HERE_citation_network_forward;
      ELSE
        EXECUTE('create table case_DRUG_NAME_HERE_gen'||X||'_ref_forward as
        select a.*, b.source_id as gen'||X||'_citing_wos_id from
          case_DRUG_NAME_HERE_generational_references_forward a
          left join wos_references b
            on a.gen'||X-1||'_citing_wos_id=b.cited_source_uid;');
        --no need to make changes to cited wos IDs, all will be proper wos_ids
        EXECUTE('drop table if exists case_DRUG_NAME_HERE_gen'||X||'_ref_pmid_forward;
        create table case_DRUG_NAME_HERE_gen'||X||'_ref_pmid_forward as
          select a.*, b.pmid_int as gen'||X||'_citing_pmid
          from case_DRUG_NAME_HERE_gen'||X||'_ref_forward a
          left join wos_pmid_mapping b
          on a.gen'||X||'_citing_wos_id=b.wos_id;');
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_generational_references_forward;
        EXECUTE('DROP TABLE IF EXISTS case_DRUG_NAME_HERE_gen'||X||'_ref_forward;');
        EXECUTE('ALTER TABLE case_DRUG_NAME_HERE_gen'||X||'_ref_pmid_forward
          RENAME TO case_DRUG_NAME_HERE_generational_references_forward;');
        EXECUTE('create index case_DRUG_NAME_HERE_generational_references_wos_index_forward on case_DRUG_NAME_HERE_generational_references_forward
          using btree (gen'||X||'_citing_wos_id) tablespace indexes;');
        --create a dummy citation network table for genX references. Merge this into the main table and deduplicate
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_dummy_forward;
        EXECUTE('create table case_DRUG_NAME_HERE_citation_network_dummy_forward as
        select distinct b.source_id as citing_wos, a.cited as cited_wos from
          ( select distinct gen'||X-1||'_citing_wos_id as cited from case_DRUG_NAME_HERE_generational_references_forward
            union all
            select distinct gen'||X||'_citing_wos_id as cited from case_DRUG_NAME_HERE_generational_references_forward
          ) a
          inner join wos_references b
            on a.cited=b.cited_source_uid
          where b.source_id in (select gen'||X-1||'_citing_wos_id as cited from case_DRUG_NAME_HERE_generational_references_forward)
            or b.source_id in (select gen'||X||'_citing_wos_id as cited from case_DRUG_NAME_HERE_generational_references_forward) ;');
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_pmid_dummy_forward;
        EXECUTE('create table case_DRUG_NAME_HERE_citation_network_pmid_dummy_forward as
        select distinct b.pmid_int as citing_pmid, a.citing_wos, a.cited_wos, c.pmid_int as cited_pmid
        from
          case_DRUG_NAME_HERE_citation_network_dummy_forward a left join wos_pmid_mapping b
            on a.citing_wos=b.wos_id
          left join wos_pmid_mapping c
            on a.cited_wos=c.wos_id;');
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_dummy_forward;
        CREATE TABLE newtable AS SELECT * FROM (SELECT * FROM case_DRUG_NAME_HERE_citation_network_forward
                                                UNION
                                                SELECT * FROM case_DRUG_NAME_HERE_citation_network_pmid_dummy_forward) a;
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_forward;
        DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_pmid_dummy_forward;
        ALTER TABLE newtable RENAME TO case_DRUG_NAME_HERE_citation_network_forward;

      END IF;

      --Alter citation network table, include a column for a flag which indicates if the cited WOS ID is in wos publications. TODO: No need for this, all IDs will be wos IDs
      --ALTER TABLE case_DRUG_NAME_HERE_citation_network_forward
        --ADD COLUMN cited_verification_flag INT;
      --UPDATE case_DRUG_NAME_HERE_citation_network a
        --SET cited_verification_flag = (CASE WHEN a.cited_wos in (select source_id from wos_publications where source_id=a.cited_wos) THEN 1
        --                                    WHEN a.cited_wos='MEDLINE%' THEN 2
        --                                   ELSE 0
        --                                   END);
      --TEMP -- subset the citation network to only retain rows where the cited_verification_flag is 1
      --DELETE FROM case_DRUG_NAME_HERE_citation_network
        --WHERE cited_verification_flag!=1;

      DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_years_forward;
      EXECUTE('create table case_DRUG_NAME_HERE_citation_network_years_forward as
      select distinct c.pmid_int, a.wos_id, b.publication_year from
      ( select distinct citing_wos as wos_id from case_DRUG_NAME_HERE_citation_network_forward
        union all
        select distinct cited_wos as wos_id from case_DRUG_NAME_HERE_citation_network_forward
      ) a
      left join wos_publications b
        on a.wos_id=b.source_id
      left join wos_pmid_mapping c
        on a.wos_id=c.wos_id
      where a.wos_id is not null;');
      DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_authors_forward;
      EXECUTE('create table case_DRUG_NAME_HERE_citation_network_authors_forward as
      select distinct a.pmid_int, a.wos_id, b.full_name from
      case_DRUG_NAME_HERE_citation_network_years_forward a INNER JOIN wos_authors b
      on a.wos_id=b.source_id;');
      DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_grants_WOS_forward;
      EXECUTE('create table case_DRUG_NAME_HERE_citation_network_grants_WOS_forward as
      select distinct a.pmid_int, a.wos_id, b.grant_number, b.grant_organization from
      case_DRUG_NAME_HERE_citation_network_years_forward a INNER JOIN wos_grants b
      on a.wos_id=b.source_id;');
      DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_locations_forward;
      EXECUTE('create table case_DRUG_NAME_HERE_citation_network_locations as
      select distinct a.pmid_int, a.wos_id, b.organization, b.city, b.country from
      case_DRUG_NAME_HERE_citation_network_years_forward a INNER JOIN wos_addresses b
      on a.wos_id=b.source_id;');
      DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_grants_SPIRES_forward;
      EXECUTE('create table case_DRUG_NAME_HERE_citation_network_grants_SPIRES_forward as
      select distinct a.pmid_int, a.wos_id, b.project_number from
      case_DRUG_NAME_HERE_citation_network_years_forward a INNER JOIN exporter_publink b
      on a.pmid_int=CAST(b.pmid as int);');
      RAISE NOTICE 'Percent loss when mapping citing WoS IDs to PMIDs for Generation %:', X;
      EXECUTE('select (1-(CAST(count(gen'||X||'_citing_wos_id) as decimal)/count(gen'||X||'_citing_pmid))) as
        percent_gen'||X||'_citing_wos_id_with_matching_PMID from case_DRUG_NAME_HERE_generational_references_forward;');
      RAISE NOTICE 'Completed Iteration: %', X;
   END LOOP;
END; $$;

--output tables to CSV format under disk space
COPY case_DRUG_NAME_HERE_citation_network_forward TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_forward.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_years_forward TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_years_forward.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_grants_SPIRES_forward TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_grants_SPIRES_forward.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_grants_WOS_forward TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_grants_WOS_forward.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_locations_forward TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_locations_forward.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_authors_forward TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_authors_forward.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_generational_references_forward TO '/erniedev_data2/DRUG_NAME_HERE_generational_references_forward.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;

--collect some statistics and output to screen
\! echo '***Total distinct PMIDs in seed set:'
select count(distinct pmid) from case_DRUG_NAME_HERE_pmid_wos_projects;
\! echo '***Total distinct WoS IDs in seed set:'
select count(distinct wos_id) from case_DRUG_NAME_HERE_pmid_wos_projects;

\! printf '\n\n\n*** IMPORTANT ***\n\n The following counts are taken from the citation network table.\nSeedset PMIDs without a corresponding WoS ID are not counted in the network as they have droppped out of the network\n\n\n'
\! echo '***Total distinct citing documents:'
select count(distinct citing_wos) from case_DRUG_NAME_HERE_citation_network_forward;
\! echo '***Total distinct citing PMIDs:'
select count(distinct citing_pmid) from case_DRUG_NAME_HERE_citation_network_forward  where citing_pmid is not null;
\! echo '***Total distinct documents in network (Remember - WoS backbone)' -- can use the years table here as it is a union into what is basically a node list table, left joined on years. As a result, the node listing is preserved even for those entries without years.
select count(distinct wos_id) from case_DRUG_NAME_HERE_citation_network_years_forward;
