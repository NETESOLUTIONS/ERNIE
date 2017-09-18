/*




Author: Samet Keserci
Create Date: 09/18/2017
Usage: psql -d ernie -f createtable_ct_tables.sql

This script creates children tables for Clinical Trials data.
Tables involved:
1. ct_secondary_ids
2. ct_collaborators
3. ct_authorities
4. ct_outcomes
5. ct_conditions
6. ct_arm_groups
7. ct_interventions
8. ct_intervention_arm_group_labels
9. ct_intervention_other_names
10. ct_overall_officials
11. ct_overall_contacts
12. ct_locations
13. ct_location_investigators
14. ct_location_countries
15. ct_links
16. ct_condition_browses
17. ct_intervention_browses
18. ct_references
19. ct_publications
20. ct_keywords
21. ct_clinical_studies
*/


create table ct_clinical_studies
(
id int not null,
nct_id varchar(30) not null primary key,
rank varchar(20), -- enclosed in root
download_date varchar(300),
link_text varchar(500),
url varchar(1000),
org_study_id varchar(30),
nct_alias varchar(300),
brief_title varchar(1000),
acronym varchar(200),
official_title varchar(1000),
lead_sponsor_agency varchar(500),
lead_sponsor_agency_class varchar(100),
source varchar(500),
has_dmc varchar(50),
brief_summary text,
detailed_description text,
overall_status varchar(100),
why_stopped varchar(200),
start_date varchar(100),
completion_date varchar(100),
completion_date_type varchar(100), -- enclosed in completion_date
primary_completion_date varchar(100),
primary_completion_date_type varchar(100), -- enclosed in primary_completion_date
phase varchar(100),
study_type varchar(100),
study_design varchar(1000),
target_duration varchar(100),
number_of_arms int,
number_of_groups int,
enrollment varchar(100),
enrollment_type varchar(50), -- enclosed in enrollment
biospec_retention varchar(1000),
biospec_descr varchar(50000),
study_pop varchar(50000),
sampling_method varchar(500),
criteria text,
gender varchar(50),
minimum_age varchar(300),
maximum_age varchar(300),
healthy_volunteers varchar(300),
verification_date varchar(100),
lastchanged_date varchar(100),
firstreceived_date varchar(100),
firstreceived_results_date varchar(100),
responsible_party_type varchar(100),
responsible_investigator_affiliation varchar(5000),
responsible_investigator_full_name varchar(1000),
responsible_investigator_title varchar(1000),
is_fda_regulated varchar(50),
is_section_801 varchar(50),
has_expanded_access varchar(50)
)
tablespace ernie_ct_tbs
;


create table ct_secondary_ids
(
id int,
nct_id varchar(30) not null,
secondary_id varchar(30)
)
tablespace ernie_ct_tbs
;

create table ct_collaborators
(
id int,
nct_id varchar(30) not null,
agency varchar(500),
agency_class varchar(50)
)
tablespace ernie_ct_tbs
;

create table ct_authorities
  (
    id int,
    nct_id varchar(30) not null,
    authority varchar(5000)
  )
  tablespace ernie_ct_tbs
  ;

create table ct_outcomes
(
id int,
nct_id varchar(30) not null,
outcome_type varchar(50),
measure varchar(500),
time_frame varchar(1000),
safety_issue varchar(1000),
description varchar(2000)
)
tablespace ernie_ct_tbs
;

create table ct_conditions
(
id int,
nct_id varchar(30) not null,
condition varchar(500)
)
tablespace ernie_ct_tbs
;

create table ct_arm_groups
(
id int,
nct_id varchar(30) not null,
arm_group_label varchar(200),
arm_group_type varchar(50),
description varchar(5000)
)
tablespace ernie_ct_tbs
;

create table ct_interventions
  (
    id int,
    nct_id varchar(30) not null,
    intervention_type varchar(50),
    intervention_name varchar(200),
    description varchar(5000)
  )
  tablespace ernie_ct_tbs;

-- create table for multiple arm_group_label under ct_intervention.
create table ct_intervention_arm_group_labels
  (
    id int,
    nct_id varchar(30) not null,
    intervention_name varchar(500),
    arm_group_label varchar(500)
  )
  tablespace ernie_ct_tbs;

create table ct_intervention_other_names
  (
    id int,
    nct_id varchar(30) not null,
    intervention_name varchar(500),
    other_name varchar(500)
  )
  tablespace ernie_ct_tbs;

create table ct_overall_officials

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
  tablespace ernie_ct_tbs;

create table ct_overall_contacts
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
  tablespace ernie_ct_tbs;

create table ct_locations
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
  tablespace ernie_ct_tbs;

create table ct_location_investigators
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
  tablespace ernie_ct_tbs;

create table ct_location_countries
  (
    id int,
    nct_id varchar(30) not null,
    country varchar(500)
  )
  tablespace ernie_ct_tbs;

create table ct_links
  (
    id int,
    nct_id varchar(30) not null,
    url varchar(2000),
    description varchar(5000)
  )
  tablespace ernie_ct_tbs;

create table ct_condition_browses
  (
    id int,
    nct_id varchar(30) not null,
    mesh_term varchar(300)
  )
  tablespace ernie_ct_tbs;

create table ct_intervention_browses
  (
    id int,
    nct_id varchar(30) not null,
    mesh_term varchar(300)
  )
  tablespace ernie_ct_tbs;

create table ct_references
  (
    id int,
    nct_id varchar(30) not null,
    citation varchar(8000),
    pmid int
  )
  tablespace ernie_ct_tbs;

  create table ct_publications
    (
      id int,
      nct_id varchar(30) not null,
      citation varchar(8000),
      pmid int
    )
    tablespace ernie_ct_tbs;

  create table ct_keywords
    (
      id int,
      nct_id varchar(30) not null,
      keyword varchar(1000)
    )
    tablespace ernie_ct_tbs;


    create table update_log_ct (
      id serial,
      last_updated timestamp,
      num_nct integer)
    tablespace ernie_ct_tbs;
