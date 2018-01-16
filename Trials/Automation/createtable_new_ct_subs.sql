/*
This script creates new children tables for Clinical Trials data.
Tables involved:
1. new_ct_secondary_ids
2. new_ct_collaborators
3. new_ct_authorities
4. new_ct_outcomes
5. new_ct_conditions
6. new_ct_arm_groups
7. new_ct_interventions
8. new_ct_intervention_arm_group_labels
9. new_ct_intervention_other_names
10. new_ct_overall_officials
11. new_ct_overall_contacts
12. new_ct_locations
13. new_ct_location_investigators
14. new_ct_location_countries
15. new_ct_links
16. new_ct_condition_browses
17. new_ct_intervention_browses
18. new_ct_references
19. new_ct_publications
20. new_ct_keywords

Usage: psql -d pardi -f createtable_new_ct_subs

Author: Lingtian "Lindsay" Wan
Create Date: 02/05/2016
Modified: 05/19/2016, Lindsay Wan, added documentation
          21/11/2016, Samet Keserci, revision wrt new schema plan
          03/29/2017, Samet Keserci, revision wrt dev2 to dev3 migration


*/

\set ON_ERROR_STOP on
\set ECHO all


set search_path to public;

drop table if exists new_ct_secondary_ids;
create table new_ct_secondary_ids
(
id int,
nct_id varchar(30) not null,
secondary_id varchar(30)
)
tablespace ct_data_tbs
;

drop table if exists new_ct_collaborators;
create table new_ct_collaborators
(
id int,
nct_id varchar(30) not null,
agency varchar(500),
agency_class varchar(50)
)
tablespace ct_data_tbs
;

drop table if exists new_ct_authorities;
create table new_ct_authorities
  (
    id int,
    nct_id varchar(30) not null,
    authority varchar(5000)
  )
  tablespace ct_data_tbs
  ;

drop table if exists new_ct_outcomes;
create table new_ct_outcomes
(
id int,
nct_id varchar(30) not null,
outcome_type varchar(50),
measure varchar(500),
time_frame varchar(1000),
safety_issue varchar(1000),
description varchar(2000)
)
tablespace ct_data_tbs
;

drop table if exists new_ct_conditions;
create table new_ct_conditions
(
id int,
nct_id varchar(30) not null,
condition varchar(500)
)
tablespace ct_data_tbs
;

drop table if exists new_ct_arm_groups;
create table new_ct_arm_groups
(
id int,
nct_id varchar(30) not null,
arm_group_label varchar(200),
arm_group_type varchar(50),
description varchar(5000)
)
tablespace ct_data_tbs
;

drop table if exists new_ct_interventions;
create table new_ct_interventions
  (
    id int,
    nct_id varchar(30) not null,
    intervention_type varchar(50),
    intervention_name varchar(200),
    description varchar(5000)
  )
  tablespace ct_data_tbs;

-- create table for multiple arm_group_label under ct_intervention.
drop table if exists new_ct_intervention_arm_group_labels;
create table new_ct_intervention_arm_group_labels
  (
    id int,
    nct_id varchar(30) not null,
    intervention_name varchar(500),
    arm_group_label varchar(500)
  )
  tablespace ct_data_tbs;

drop table if exists new_ct_intervention_other_names;
create table new_ct_intervention_other_names
  (
    id int,
    nct_id varchar(30) not null,
    intervention_name varchar(500),
    other_name varchar(500)
  )
  tablespace ct_data_tbs;

drop table if exists new_ct_overall_officials;
create table new_ct_overall_officials

  (
    id int,
    nct_id varchar(30) not null,
    first_name varchar(300),
    middle_name varchar(300),
    last_name varchar(300),
    degrees varchar(300),
    role varchar(1000),
    affiliation varchar(5000)
  )
  tablespace ct_data_tbs;

drop table if exists new_ct_overall_contacts;
create table new_ct_overall_contacts
  (
    id int,
    nct_id varchar(30) not null,
    contact_type varchar(100),
    first_name varchar(300),
    middle_name varchar(300),
    last_name varchar(300),
    degrees varchar(300),
    phone varchar(200),
    phone_ext varchar(100),
    email varchar(500)
  )
  tablespace ct_data_tbs;

drop table if exists new_ct_locations;
create table new_ct_locations
  (
    id int,
    nct_id varchar(30) not null,
    facility_name varchar(500),
    facility_city varchar(200),
    facility_state varchar(200),
    facility_zip varchar(100),
    facility_country varchar(500),
    status varchar(200),
    contact_first_name varchar(300),
    contact_middle_name varchar(300),
    contact_last_name varchar(300),
    contact_degrees varchar(300),
    contact_phone varchar(200),
    contact_phone_ext varchar(100),
    contact_email varchar(500),
    contact_backup_first_name varchar(300),
    contact_backup_middle_name varchar(300),
    contact_backup_last_name varchar(300),
    contact_backup_degrees varchar(300),
    contact_backup_phone varchar(200),
    contact_backup_phone_ext varchar(100),
    contact_backup_email varchar(500)
  )
  tablespace ct_data_tbs;

drop table if exists new_ct_location_investigators;
create table new_ct_location_investigators
  (
    id int,
    nct_id varchar(30) not null,
    investigator_first_name varchar(300),
    investigator_middle_name varchar(300),
    investigator_last_name varchar(300),
    investigator_degrees varchar(300),
    investigator_role varchar(500),
    investigator_affiliation varchar(5000)
  )
  tablespace ct_data_tbs;

drop table if exists new_ct_location_countries;
create table new_ct_location_countries
  (
    id int,
    nct_id varchar(30) not null,
    country varchar(500)
  )
  tablespace ct_data_tbs;

drop table if exists new_ct_links;
create table new_ct_links
  (
    id int,
    nct_id varchar(30) not null,
    url varchar(2000),
    description varchar(5000)
  )
  tablespace ct_data_tbs;

drop table if exists new_ct_condition_browses;
create table new_ct_condition_browses
  (
    id int,
    nct_id varchar(30) not null,
    mesh_term varchar(300)
  )
  tablespace ct_data_tbs;

drop table if exists new_ct_intervention_browses;
create table new_ct_intervention_browses
  (
    id int,
    nct_id varchar(30) not null,
    mesh_term varchar(300)
  )
  tablespace ct_data_tbs;

drop table if exists new_ct_references;
create table new_ct_references
  (
    id int,
    nct_id varchar(30) not null,
    citation varchar(8000),
    pmid int
  )
  tablespace ct_data_tbs;

  drop table if exists new_ct_publications;
  create table new_ct_publications
    (
      id int,
      nct_id varchar(30) not null,
      citation varchar(8000),
      pmid int
    )
    tablespace ct_data_tbs;

drop table if exists new_ct_keywords;
  create table new_ct_keywords
    (
      id int,
      nct_id varchar(30) not null,
      keyword varchar(1000)
    )
    tablespace ct_data_tbs;
