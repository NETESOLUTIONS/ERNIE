




-- Usage: psql  -d ernie  -f ct_update_tables.sql

-- Author: Lingtian "Lindsay" Wan
-- Create Date: 02/22/2016
-- Modified: 05/19/2016, Lindsay Wan, added documentation
--           11/21/2016, Samet Keserci, revision wrt new schema plan
--           03/29/2017, Samet Keserci, revision wrt dev2 to dev3 migration

-- This script updates the Clinical Trial (CT) tables in the following way:
-- 1. Keep the newest version: new_ct_table_name;
-- 2. Insert rows from the previous version (ct_table_name) that have nct_ids
--   not in the newest version.
-- 3. Drop the oldest backup version tables: old_ct_table_name.
-- 4. Rename tables: ct_table_name to old_ct_table_name;
--                  new_ct_table_name to ct_table_name.
-- 5. Update the log table.
-- The CT tables always have two version: ct_table_name as the current tables,
-- and old_ct_table_name as backup for previous version.


set log_temp_files = 0;
set temp_tablespaces = 'temp';
set search_path to public;


-- Insert old records into new tables.
\echo ***STARTING UPDATING TABLES

\echo ***UPDATING TABLE: ct_clinical_studies
insert into new_ct_clinical_studies
  select a.* from ct_clinical_studies as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_clinical_studies);

\echo ***UPDATING TABLE: ct_secondary_ids
insert into new_ct_secondary_ids
  select a.* from ct_secondary_ids as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_secondary_ids);

\echo ***UPDATING TABLE: ct_collaborators
insert into new_ct_collaborators
  select a.* from ct_collaborators as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_collaborators);

\echo ***UPDATING TABLE: ct_authorities
insert into new_ct_authorities
  select a.* from ct_authorities as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_authorities);

\echo ***UPDATING TABLE: ct_outcomes
insert into new_ct_outcomes
  select a.* from ct_outcomes as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_outcomes);

\echo ***UPDATING TABLE: ct_conditions
insert into new_ct_conditions
  select a.* from ct_conditions as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_conditions);

\echo ***UPDATING TABLE: ct_arm_groups
insert into new_ct_arm_groups
  select a.* from ct_arm_groups as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_arm_groups);

\echo ***UPDATING TABLE: ct_interventions
insert into new_ct_interventions
  select a.* from ct_interventions as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_interventions);

\echo ***UPDATING TABLE: ct_intervention_arm_group_labels
insert into new_ct_intervention_arm_group_labels
  select a.* from ct_intervention_arm_group_labels as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_intervention_arm_group_labels);

\echo ***UPDATING TABLE: ct_intervention_other_names
insert into new_ct_intervention_other_names
  select a.* from ct_intervention_other_names as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_intervention_other_names);

\echo ***UPDATING TABLE: ct_overall_officials
insert into new_ct_overall_officials
  select a.* from ct_overall_officials as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_overall_officials);

\echo ***UPDATING TABLE: ct_overall_contacts
insert into new_ct_overall_contacts
  select a.* from ct_overall_contacts as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_overall_contacts);

\echo ***UPDATING TABLE: ct_locations
insert into new_ct_locations
  select a.* from ct_locations as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_locations);

\echo ***UPDATING TABLE: ct_location_investigators
insert into new_ct_location_investigators
  select a.* from ct_location_investigators as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_location_investigators);

\echo ***UPDATING TABLE: ct_location_countries
insert into new_ct_location_countries
  select a.* from ct_location_countries as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_location_countries);

\echo ***UPDATING TABLE: ct_links
insert into new_ct_links
  select a.* from ct_links as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_links);

\echo ***UPDATING TABLE: ct_condition_browses
insert into new_ct_condition_browses
  select a.* from ct_condition_browses as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_condition_browses);

\echo ***UPDATING TABLE: ct_intervention_browses
insert into new_ct_intervention_browses
  select a.* from ct_intervention_browses as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_intervention_browses);

\echo ***UPDATING TABLE: ct_references
insert into new_ct_references
  select a.* from ct_references as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_references);

\echo ***UPDATING TABLE: ct_publications
insert into new_ct_publications
  select a.* from ct_publications as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_publications);

\echo ***UPDATING TABLE: ct_keywords
insert into new_ct_keywords
  select a.* from ct_keywords as a
  where a.nct_id not in
  (select distinct nct_id from new_ct_keywords);

-- Drop oldest version of tables.
\echo ***DROPPING OLDEST VERSION OF TABLES
drop table if exists old_ct_clinical_studies;
drop table if exists old_ct_secondary_ids;
drop table if exists old_ct_arm_groups;
drop table if exists old_ct_interventions;
drop table if exists old_ct_overall_officials;
drop table if exists old_ct_intervention_other_names;
drop table if exists old_ct_intervention_arm_group_labels;
drop table if exists old_ct_conditions;
drop table if exists old_ct_locations;
drop table if exists old_ct_location_investigators;
drop table if exists old_ct_location_countries;
drop table if exists old_ct_links;
drop table if exists old_ct_condition_browses;
drop table if exists old_ct_intervention_browses;
drop table if exists old_ct_references;
drop table if exists old_ct_publications;
drop table if exists old_ct_keywords;
drop table if exists old_ct_overall_contacts;
drop table if exists old_ct_collaborators;
drop table if exists old_ct_authorities;
drop table if exists old_ct_outcomes;

-- Rename previous version of table (ct_table_name) to oldest version:
-- old_ct_table_name.
\echo ***RENAMING TABLES
alter table ct_clinical_studies rename to old_ct_clinical_studies;
alter table ct_secondary_ids rename to old_ct_secondary_ids;
alter table ct_arm_groups rename to old_ct_arm_groups;
alter table ct_interventions rename to old_ct_interventions;
alter table ct_overall_officials rename to old_ct_overall_officials;
alter table ct_intervention_other_names
  rename to old_ct_intervention_other_names;
alter table ct_intervention_arm_group_labels
  rename to old_ct_intervention_arm_group_labels;
alter table ct_conditions rename to old_ct_conditions;
alter table ct_locations rename to old_ct_locations;
alter table ct_location_investigators rename to old_ct_location_investigators;
alter table ct_location_countries rename to old_ct_location_countries;
alter table ct_links rename to old_ct_links;
alter table ct_condition_browses rename to old_ct_condition_browses;
alter table ct_intervention_browses rename to old_ct_intervention_browses;
alter table ct_references rename to old_ct_references;
alter table ct_publications rename to old_ct_publications;
alter table ct_keywords rename to old_ct_keywords;
alter table ct_overall_contacts rename to old_ct_overall_contacts;
alter table ct_collaborators rename to old_ct_collaborators;
alter table ct_authorities rename to old_ct_authorities;
alter table ct_outcomes rename to old_ct_outcomes;

-- Rename newest version of table (new_ct_table_name) to current_version:
-- ct_table_name.
alter table new_ct_clinical_studies rename to ct_clinical_studies;
alter table new_ct_secondary_ids rename to ct_secondary_ids;
alter table new_ct_arm_groups rename to ct_arm_groups;
alter table new_ct_interventions rename to ct_interventions;
alter table new_ct_overall_officials rename to ct_overall_officials;
alter table new_ct_intervention_other_names
  rename to ct_intervention_other_names;
alter table new_ct_intervention_arm_group_labels
  rename to ct_intervention_arm_group_labels;
alter table new_ct_conditions rename to ct_conditions;
alter table new_ct_locations rename to ct_locations;
alter table new_ct_location_investigators
  rename to ct_location_investigators;
alter table new_ct_location_countries rename to ct_location_countries;
alter table new_ct_links rename to ct_links;
alter table new_ct_condition_browses rename to ct_condition_browses;
alter table new_ct_intervention_browses rename to ct_intervention_browses;
alter table new_ct_references rename to ct_references;
alter table new_ct_publications rename to ct_publications;
alter table new_ct_keywords rename to ct_keywords;
alter table new_ct_overall_contacts rename to ct_overall_contacts;
alter table new_ct_collaborators rename to ct_collaborators;
alter table new_ct_authorities rename to ct_authorities;
alter table new_ct_outcomes rename to ct_outcomes;

-- Update log file.
\echo ***UPDATING LOG TABLE
insert into update_log_ct (last_updated, num_nct)
  select current_timestamp, count(1) from ct_clinical_studies;
