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

SET default_tablespace TO ct;

DROP TABLE IF EXISTS new_ct_secondary_ids;
CREATE TABLE new_ct_secondary_ids (
  id           INT,
  nct_id       VARCHAR(30) NOT NULL,
  secondary_id VARCHAR(30)
);

DROP TABLE IF EXISTS new_ct_collaborators;
CREATE TABLE new_ct_collaborators (
  id           INT,
  nct_id       VARCHAR(30) NOT NULL,
  agency       VARCHAR(500),
  agency_class VARCHAR(50)
);

DROP TABLE IF EXISTS new_ct_authorities;
CREATE TABLE new_ct_authorities (
  id        INT,
  nct_id    VARCHAR(30) NOT NULL,
  authority VARCHAR(5000)
);

DROP TABLE IF EXISTS new_ct_outcomes;
CREATE TABLE new_ct_outcomes (
  id           INT,
  nct_id       VARCHAR(30) NOT NULL,
  outcome_type VARCHAR(50),
  measure      VARCHAR(500),
  time_frame   VARCHAR(1000),
  safety_issue VARCHAR(1000),
  description  VARCHAR(2000)
);

DROP TABLE IF EXISTS new_ct_conditions;
CREATE TABLE new_ct_conditions (
  id        INT,
  nct_id    VARCHAR(30) NOT NULL,
  condition VARCHAR(500)
);

DROP TABLE IF EXISTS new_ct_arm_groups;
CREATE TABLE new_ct_arm_groups (
  id              INT,
  nct_id          VARCHAR(30) NOT NULL,
  arm_group_label VARCHAR(200),
  arm_group_type  VARCHAR(50),
  description     VARCHAR(5000)
);

DROP TABLE IF EXISTS new_ct_interventions;
CREATE TABLE new_ct_interventions (
  id                INT,
  nct_id            VARCHAR(30) NOT NULL,
  intervention_type VARCHAR(50),
  intervention_name VARCHAR(200),
  description       VARCHAR(5000)
);

-- create table for multiple arm_group_label under ct_intervention.
DROP TABLE IF EXISTS new_ct_intervention_arm_group_labels;
CREATE TABLE new_ct_intervention_arm_group_labels (
  id                INT,
  nct_id            VARCHAR(30) NOT NULL,
  intervention_name VARCHAR(500),
  arm_group_label   VARCHAR(500)
);

DROP TABLE IF EXISTS new_ct_intervention_other_names;
CREATE TABLE new_ct_intervention_other_names (
  id                INT,
  nct_id            VARCHAR(30) NOT NULL,
  intervention_name VARCHAR(500),
  other_name        VARCHAR(500)
);

DROP TABLE IF EXISTS new_ct_overall_officials;
CREATE TABLE new_ct_overall_officials

(
  id          INT,
  nct_id      VARCHAR(30) NOT NULL,
  first_name  VARCHAR(300),
  middle_name VARCHAR(300),
  last_name   VARCHAR(300),
  degrees     VARCHAR(300),
  role        VARCHAR(1000),
  affiliation VARCHAR(5000)
);

DROP TABLE IF EXISTS new_ct_overall_contacts;
CREATE TABLE new_ct_overall_contacts (
  id           INT,
  nct_id       VARCHAR(30) NOT NULL,
  contact_type VARCHAR(100),
  first_name   VARCHAR(300),
  middle_name  VARCHAR(300),
  last_name    VARCHAR(300),
  degrees      VARCHAR(300),
  phone        VARCHAR(200),
  phone_ext    VARCHAR(100),
  email        VARCHAR(500)
);

DROP TABLE IF EXISTS new_ct_locations;
CREATE TABLE new_ct_locations (
  id                         INT,
  nct_id                     VARCHAR(30) NOT NULL,
  facility_name              VARCHAR(500),
  facility_city              VARCHAR(200),
  facility_state             VARCHAR(200),
  facility_zip               VARCHAR(100),
  facility_country           VARCHAR(500),
  status                     VARCHAR(200),
  contact_first_name         VARCHAR(300),
  contact_middle_name        VARCHAR(300),
  contact_last_name          VARCHAR(300),
  contact_degrees            VARCHAR(300),
  contact_phone              VARCHAR(200),
  contact_phone_ext          VARCHAR(100),
  contact_email              VARCHAR(500),
  contact_backup_first_name  VARCHAR(300),
  contact_backup_middle_name VARCHAR(300),
  contact_backup_last_name   VARCHAR(300),
  contact_backup_degrees     VARCHAR(300),
  contact_backup_phone       VARCHAR(200),
  contact_backup_phone_ext   VARCHAR(100),
  contact_backup_email       VARCHAR(500)
);

DROP TABLE IF EXISTS new_ct_location_investigators;
CREATE TABLE new_ct_location_investigators (
  id                       INT,
  nct_id                   VARCHAR(30) NOT NULL,
  investigator_first_name  VARCHAR(300),
  investigator_middle_name VARCHAR(300),
  investigator_last_name   VARCHAR(300),
  investigator_degrees     VARCHAR(300),
  investigator_role        VARCHAR(500),
  investigator_affiliation VARCHAR(5000)
);

DROP TABLE IF EXISTS new_ct_location_countries;
CREATE TABLE new_ct_location_countries (
  id      INT,
  nct_id  VARCHAR(30) NOT NULL,
  country VARCHAR(500)
);

DROP TABLE IF EXISTS new_ct_links;
CREATE TABLE new_ct_links (
  id          INT,
  nct_id      VARCHAR(30) NOT NULL,
  url         VARCHAR(2000),
  description VARCHAR(5000)
);

DROP TABLE IF EXISTS new_ct_condition_browses;
CREATE TABLE new_ct_condition_browses (
  id        INT,
  nct_id    VARCHAR(30) NOT NULL,
  mesh_term VARCHAR(300)
);

DROP TABLE IF EXISTS new_ct_intervention_browses;
CREATE TABLE new_ct_intervention_browses (
  id        INT,
  nct_id    VARCHAR(30) NOT NULL,
  mesh_term VARCHAR(300)
);

DROP TABLE IF EXISTS new_ct_references;
CREATE TABLE new_ct_references (
  id       INT,
  nct_id   VARCHAR(30) NOT NULL,
  citation VARCHAR(8000),
  pmid     INT
);

DROP TABLE IF EXISTS new_ct_publications;
CREATE TABLE new_ct_publications (
  id       INT,
  nct_id   VARCHAR(30) NOT NULL,
  citation VARCHAR(8000),
  pmid     INT
);

DROP TABLE IF EXISTS new_ct_keywords;
CREATE TABLE new_ct_keywords (
  id      INT,
  nct_id  VARCHAR(30) NOT NULL,
  keyword VARCHAR(1000)
);