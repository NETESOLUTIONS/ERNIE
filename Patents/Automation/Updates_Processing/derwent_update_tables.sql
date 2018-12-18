/*
This script updates the main Derwent table (derwent_*) with data from
newly-downloaded files. Specifically:

    1. Find update records: find patent_num_orig that need to be updated,
       and move current records with these patent_num_orig to the
       update history tables: uhs_derwent_*.
    2. Insert updated/new records: insert all the records from the new
       tables (new_derwent_*) into the main table: derwent_*.
    3. Truncate the new tables: new_derwent_*.
    4. Record to log table: update_log_derwent.

Relevant main tables:
    1. derwent_agents
    2. derwent_assignees
    3. derwent_assignors
    4. derwent_examiners
    5. derwent_inventors
    6. derwent_lit_citations
    7. derwent_pat_citations
    8. derwent_patents

Usage: psql -f derwent_update_tables.sql

Author: Lingtian "Lindsay" Wan
Create Date: 04/21/2016
Modified: 05/19/2016, Lindsay Wan, added documentation
        : 11/21/2016, Samet Keserci, revised wrt new schema plan
*/

\set ON_ERROR_STOP on
\set ECHO all

-- set search_path to public, ernie_admin;

-- Set temporary tablespace for calculation.
SET log_temp_files = 0;
SET default_tablespace = derwent;

-- Create a temp table to store patent numbers from the update file.
DROP TABLE IF EXISTS temp_update_patnum;
CREATE TABLE temp_update_patnum AS
  SELECT patent_num_orig
  FROM new_derwent_patents;

-- region derwent_agents
\echo ***UPDATING TABLE: derwent_agents
INSERT INTO uhs_derwent_agents
  SELECT a.*
  FROM derwent_agents a INNER JOIN temp_update_patnum b
    ON a.patent_num = b.patent_num_orig;

DELETE FROM derwent_agents
WHERE patent_num IN (
  SELECT *
  FROM temp_update_patnum);

--@formatter:off
-- De-duplicate new_derwent_agents
DELETE
FROM new_derwent_agents t1
WHERE EXISTS(SELECT 1
             FROM new_derwent_agents t2
             WHERE t2.patent_num = t1.patent_num
               AND t2.organization_name = t1.organization_name
               AND t2.ctid > t1.ctid);
--@formatter:on

INSERT INTO derwent_agents (patent_num, rep_type, last_name, first_name, organization_name, country)
  SELECT
    patent_num,
    rep_type,
    last_name,
    first_name,
    organization_name,
    country
  FROM new_derwent_agents
ON CONFLICT (patent_num, organization_name)
  DO UPDATE SET rep_type = excluded.rep_type, last_name = excluded.last_name,
    first_name = excluded.first_name, country = excluded.country;
-- endregion

-- region derwent_assignees
\echo ***UPDATING TABLE: derwent_assignees
INSERT INTO uhs_derwent_assignees
  SELECT a.*
  FROM derwent_assignees a INNER JOIN temp_update_patnum b
    ON a.patent_num = b.patent_num_orig;

DELETE FROM derwent_assignees
WHERE patent_num IN (
  SELECT *
  FROM temp_update_patnum);

--@formatter:off
-- De-duplicate new_derwent_assignees
DELETE
FROM new_derwent_assignees t1
WHERE EXISTS(SELECT 1
             FROM new_derwent_assignees t2
             WHERE t2.patent_num = t1.patent_num
               AND t2.assignee_name = t1.assignee_name
               AND coalesce(t2.role, '') = coalesce(t1.role, '')
               AND coalesce(t2.city, '') = coalesce(t1.city, '')
               AND coalesce(t2.state, '') = coalesce(t1.state, '')
               AND coalesce(t2.country, '') = coalesce(t1.country, '')
               AND t2.ctid > t1.ctid);
--@formatter:on

INSERT INTO derwent_assignees (patent_num, assignee_name, role, city, state, country)
  SELECT
    coalesce(patent_num,''),
    coalesce(assignee_name,''),
    coalesce(role, ''),
    coalesce(city, ''),
    state,
    country
  FROM new_derwent_assignees --
  -- Filter out junk assignees
  WHERE assignee_name IS NOT NULL
ON CONFLICT (patent_num, assignee_name, role, city)
  DO UPDATE SET state = excluded.state, country = excluded.country;
-- endregion

-- region derwent_assignors
INSERT INTO uhs_derwent_assignors
  SELECT a.*
  FROM derwent_assignors a INNER JOIN temp_update_patnum b
    ON a.patent_num = b.patent_num_orig;

DELETE FROM derwent_assignors
WHERE patent_num IN (
  SELECT *
  FROM temp_update_patnum);

INSERT INTO derwent_assignors (patent_num, assignor)
  SELECT
    patent_num,
    assignor
  FROM new_derwent_assignors
ON CONFLICT DO NOTHING; -- Nothing to update
-- endregion

-- region derwent_examiners
\echo ***UPDATING TABLE: derwent_examiners
INSERT INTO uhs_derwent_examiners
  SELECT a.*
  FROM derwent_examiners a INNER JOIN temp_update_patnum b
    ON a.patent_num = b.patent_num_orig;

DELETE FROM derwent_examiners
WHERE patent_num IN (
  SELECT *
  FROM temp_update_patnum);

--@formatter:off
-- De-duplicate new_derwent_examiners
DELETE
FROM new_derwent_examiners t1
WHERE EXISTS(SELECT 1
             FROM new_derwent_examiners t2
             WHERE t2.patent_num = t1.patent_num
               AND t2.examiner_type = t1.examiner_type
               AND t2.ctid > t1.ctid);
--@formatter:on

INSERT INTO derwent_examiners
  SELECT *
  FROM new_derwent_examiners;
-- endregion

-- region derwent_inventors
\echo ***UPDATING TABLE: derwent_inventors
INSERT INTO uhs_derwent_inventors
  SELECT a.*
  FROM derwent_inventors a INNER JOIN temp_update_patnum b
    ON a.patent_num = b.patent_num_orig;

DELETE FROM derwent_inventors
WHERE patent_num IN (
  SELECT *
  FROM temp_update_patnum);

--@formatter:off
-- De-duplicate new_derwent_inventors
DELETE
FROM new_derwent_inventors t1
WHERE EXISTS(SELECT 1
             FROM new_derwent_inventors t2
             WHERE t2.patent_num = t1.patent_num
               AND t2.inventors = t1.inventors
               AND t2.ctid > t1.ctid);
--@formatter:on

INSERT INTO derwent_inventors
  SELECT *
  FROM new_derwent_inventors;
-- endregion

-- region derwent_lit_citations
\echo ***UPDATING TABLE: derwent_lit_citations
INSERT INTO uhs_derwent_lit_citations
  SELECT a.*
  FROM derwent_lit_citations a INNER JOIN temp_update_patnum b
    ON a.patent_num_orig = b.patent_num_orig;

DELETE FROM derwent_lit_citations
WHERE patent_num_orig IN (
  SELECT *
  FROM temp_update_patnum);

--@formatter:off
-- De-duplicate new_derwent_lit_citations
DELETE
FROM new_derwent_lit_citations t1
WHERE EXISTS(SELECT 1
             FROM new_derwent_lit_citations t2
             WHERE t2.patent_num_orig = t1.patent_num_orig
               AND t2.cited_literature = t1.cited_literature
               AND t2.ctid > t1.ctid);
--@formatter:on

INSERT INTO derwent_lit_citations
  SELECT *
  FROM new_derwent_lit_citations;
-- endregion

-- region derwent_pat_citations
\echo ***UPDATING TABLE: derwent_pat_citations
INSERT INTO uhs_derwent_pat_citations
  SELECT a.*
  FROM derwent_pat_citations a INNER JOIN temp_update_patnum b
    ON a.patent_num_orig = b.patent_num_orig;

DELETE FROM derwent_pat_citations
WHERE patent_num_orig IN (
  SELECT *
  FROM temp_update_patnum);

--@formatter:off
-- De-duplicate new_derwent_pat_citations
DELETE
FROM new_derwent_pat_citations t1
WHERE EXISTS(SELECT 1
             FROM new_derwent_pat_citations t2
             WHERE t2.patent_num_orig = t1.patent_num_orig
               AND t2.country = t1.country
               AND t2.cited_patent_orig = t1.cited_patent_orig
               AND t2.ctid > t1.ctid);
--@formatter:on

INSERT INTO derwent_pat_citations
  SELECT *
  FROM new_derwent_pat_citations;
-- endregion

-- region derwent_patents
\echo ***UPDATING TABLE:
INSERT INTO uhs_derwent_patents
  SELECT a.*
  FROM derwent_patents a INNER JOIN temp_update_patnum b
    ON a.patent_num_orig = b.patent_num_orig;

DELETE FROM derwent_patents
WHERE patent_num_orig IN (
  SELECT *
  FROM temp_update_patnum);

--@formatter:off
-- De-duplicate new_derwent_patents
DELETE
FROM new_derwent_patents t1
WHERE EXISTS(SELECT 1
             FROM new_derwent_patents t2
             WHERE t2.patent_num_orig = t1.patent_num_orig
               AND t2.patent_type = t1.patent_type
               AND t2.ctid > t1.ctid);
--@formatter:on
-- Insert new data into derwent_patents, be mindful that patent_id will correspond to patent_num_tsip (duplicate columns for now)
INSERT INTO derwent_patents(id,patent_num_orig,patent_num_wila,patent_num_tsip,
  patent_type,status,file_name,country,date_published,appl_num_orig,appl_num_wila,
  appl_num_tsip,appl_date,appl_year,appl_type,appl_country,appl_series_code,ipc_classification,
  main_classification,sub_classification,invention_title,claim_text,government_support,
  summary_of_invention,parent_patent_num_orig,patent_id)
  SELECT id,patent_num_orig,patent_num_wila,patent_num_tsip,
    patent_type,status,file_name,country,date_published,appl_num_orig,appl_num_wila,
    appl_num_tsip,appl_date,appl_year,appl_type,appl_country,appl_series_code,ipc_classification,
    main_classification,sub_classification,invention_title,claim_text,government_support,
    summary_of_invention,parent_patent_num_orig,patent_num_tsip
  FROM new_derwent_patents;
-- endregion

-- Truncate new_derwent_tables.
\echo ***TRUNCATING TABLES: new_derwent_*
TRUNCATE TABLE new_derwent_agents;
TRUNCATE TABLE new_derwent_assignees;
TRUNCATE TABLE new_derwent_assignors;
TRUNCATE TABLE new_derwent_examiners;
TRUNCATE TABLE new_derwent_inventors;
TRUNCATE TABLE new_derwent_lit_citations;
TRUNCATE TABLE new_derwent_pat_citations;
TRUNCATE TABLE new_derwent_patents;

-- region Update log file
INSERT INTO update_log_derwent (last_updated, num_update, num_new, num_derwent) VALUES (current_timestamp, --
                                                                                        (
                                                                                          SELECT count(1)
                                                                                          FROM temp_update_patnum), (
                                                                                          SELECT count(1)
                                                                                          FROM temp_update_patnum) - (
    SELECT count(1)
    FROM temp_update_patnum), (
                                                                                          SELECT count(1)
                                                                                          FROM derwent_patents));
-- endregion
