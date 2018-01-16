/*
This script creates a new main table for Clinical Trials data.

Usage: psql pardi -d pardi -f createtable_new_ct_clinical_studies

Author: Lingtian "Lindsay" Wan
Create Date: 02/06/2016
Modified: 05/19/2016, Lindsay Wan, added documentation
          11/04/2016, Lindsay Wan, changed some data types to text
          11/21/2016, Samet Keserci, revision wrt new schema plan
          03/29/2017, Samet Keserci, revision wrt dev2 to dev3 migration

*/

\set ON_ERROR_STOP on
\set ECHO all


SET search_path TO public;

DROP TABLE IF EXISTS new_ct_clinical_studies;

CREATE TABLE new_ct_clinical_studies
(
  id                                   INT         NOT NULL,
  nct_id                               VARCHAR(30) NOT NULL PRIMARY KEY,
  rank                                 VARCHAR(20), -- enclosed in root
  download_date                        VARCHAR(300),
  link_text                            VARCHAR(500),
  url                                  VARCHAR(1000),
  org_study_id                         VARCHAR(30),
  nct_alias                            VARCHAR(300),
  brief_title                          VARCHAR(1000),
  acronym                              VARCHAR(200),
  official_title                       VARCHAR(1000),
  lead_sponsor_agency                  VARCHAR(500),
  lead_sponsor_agency_class            VARCHAR(100),
  source                               VARCHAR(500),
  has_dmc                              VARCHAR(50),
  brief_summary                        TEXT,
  detailed_description                 TEXT,
  overall_status                       VARCHAR(100),
  why_stopped                          VARCHAR(200),
  start_date                           VARCHAR(100),
  completion_date                      VARCHAR(100),
  completion_date_type                 VARCHAR(100), -- enclosed in completion_date
  primary_completion_date              VARCHAR(100),
  primary_completion_date_type         VARCHAR(100), -- enclosed in primary_completion_date
  phase                                VARCHAR(100),
  study_type                           VARCHAR(100),
  study_design                         VARCHAR(1000),
  target_duration                      VARCHAR(100),
  number_of_arms                       INT,
  number_of_groups                     INT,
  enrollment                           VARCHAR(100),
  enrollment_type                      VARCHAR(50), -- enclosed in enrollment
  biospec_retention                    VARCHAR(1000),
  biospec_descr                        VARCHAR(50000),
  study_pop                            VARCHAR(50000),
  sampling_method                      VARCHAR(500),
  criteria                             TEXT,
  gender                               VARCHAR(50),
  minimum_age                          VARCHAR(300),
  maximum_age                          VARCHAR(300),
  healthy_volunteers                   VARCHAR(300),
  verification_date                    VARCHAR(100),
  lastchanged_date                     VARCHAR(100),
  firstreceived_date                   VARCHAR(100),
  firstreceived_results_date           VARCHAR(100),
  responsible_party_type               VARCHAR(100),
  responsible_investigator_affiliation VARCHAR(5000),
  responsible_investigator_full_name   VARCHAR(1000),
  responsible_investigator_title       VARCHAR(1000),
  is_fda_regulated                     VARCHAR(50),
  is_section_801                       VARCHAR(50),
  has_expanded_access                  VARCHAR(50)
)
TABLESPACE ct_data_tbs;
