/*
This script updates the Clinical Trial (CT) tables and the log table.

Author: Lingtian "Lindsay" Wan
Created: 02/22/2016
Modified:
* 05/19/2016, Lindsay Wan, added documentation
* 11/21/2016, Samet Keserci, revision wrt new schema plan
* 03/29/2017, Samet Keserci, revision wrt dev2 to dev3 migration
* 12/20/2017, Samet Keserci and DK, complete revision to make persistent tables.
*/

\set ON_ERROR_STOP on
\set ECHO all

/* log_temp_files controls logging of temporary file names and sizes. Temporary files can be created for sorts, hashes,
and temporary query results. A log entry is made for each temporary file when it is deleted.
A value of zero logs all temporary file information. The default setting is -1, which disables such logging. */
SET log_temp_files = 0;

-- Insert old records into new tables.
\echo ***STARTING UPDATING TABLES

\echo ***UPDATING TABLE: ct_clinical_studies
INSERT INTO ct_clinical_studies
  SELECT *
  FROM new_ct_clinical_studies
ON CONFLICT(nct_id) DO UPDATE
  SET id                                 = EXCLUDED.id,
    rank                                 = EXCLUDED.rank,
    download_date                        = EXCLUDED.download_date,
    link_text                            = EXCLUDED.link_text,
    url                                  = EXCLUDED.url,
    org_study_id                         = EXCLUDED.org_study_id,
    nct_alias                            = EXCLUDED.nct_alias,
    brief_title                          = EXCLUDED.brief_title,
    acronym                              = EXCLUDED.acronym,
    official_title                       = EXCLUDED.official_title,
    lead_sponsor_agency                  = EXCLUDED.lead_sponsor_agency,
    lead_sponsor_agency_class            = EXCLUDED.lead_sponsor_agency_class,
    source                               = EXCLUDED.source,
    has_dmc                              = EXCLUDED.has_dmc,
    brief_summary                        = EXCLUDED.brief_summary,
    detailed_description                 = EXCLUDED.detailed_description,
    overall_status                       = EXCLUDED.overall_status,
    why_stopped                          = EXCLUDED.why_stopped,
    start_date                           = EXCLUDED.start_date,
    completion_date                      = EXCLUDED.completion_date,
    completion_date_type                 = EXCLUDED.completion_date_type,
    primary_completion_date              = EXCLUDED.primary_completion_date,
    primary_completion_date_type         = EXCLUDED.primary_completion_date_type,
    phase                                = EXCLUDED.phase,
    study_type                           = EXCLUDED.study_type,
    study_design                         = EXCLUDED.study_design,
    target_duration                      = EXCLUDED.target_duration,
    number_of_arms                       = EXCLUDED.number_of_arms,
    number_of_groups                     = EXCLUDED.number_of_groups,
    enrollment                           = EXCLUDED.enrollment,
    enrollment_type                      = EXCLUDED.enrollment_type,
    biospec_retention                    = EXCLUDED.biospec_retention,
    biospec_descr                        = EXCLUDED.biospec_descr,
    study_pop                            = EXCLUDED.study_pop,
    sampling_method                      = EXCLUDED.sampling_method,
    criteria                             = EXCLUDED.criteria,
    gender                               = EXCLUDED.gender,
    minimum_age                          = EXCLUDED.minimum_age,
    maximum_age                          = EXCLUDED.maximum_age,
    healthy_volunteers                   = EXCLUDED.healthy_volunteers,
    verification_date                    = EXCLUDED.verification_date,
    lastchanged_date                     = EXCLUDED.lastchanged_date,
    firstreceived_date                   = EXCLUDED.firstreceived_date,
    firstreceived_results_date           = EXCLUDED.firstreceived_results_date,
    responsible_party_type               = EXCLUDED.responsible_party_type,
    responsible_investigator_affiliation = EXCLUDED.responsible_investigator_affiliation,
    responsible_investigator_full_name   = EXCLUDED.responsible_investigator_full_name,
    responsible_investigator_title       = EXCLUDED.responsible_investigator_title,
    is_fda_regulated                     = EXCLUDED.is_fda_regulated,
    is_section_801                       = EXCLUDED.is_section_801,
    has_expanded_access                  = EXCLUDED.has_expanded_access;


----! NEW VERSION IN PROGRESSS

\echo ***UPDATING TABLE: ct_secondary_ids
INSERT INTO ct_secondary_ids
  SELECT *
  FROM new_ct_secondary_ids
  ON CONFLICT(nct_id,secondary_id) DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    secondary_id = EXCLUDED.secondary_id;


\echo ***UPDATING TABLE: ct_collaborators
INSERT INTO ct_collaborators
  SELECT *
  FROM new_ct_collaborators
  ON CONFLICT(nct_id, agency) DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    agency = EXCLUDED.agency,
    agency_class = EXCLUDED.agency_class;



\echo ***UPDATING TABLE: ct_authorities
INSERT INTO ct_authorities
  SELECT *
  FROM new_ct_authorities
  ON CONFLICT(nct_id) DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    authority = EXCLUDED.authority;


\echo ***UPDATING TABLE: ct_outcomes
INSERT INTO ct_outcomes
  SELECT *
  FROM new_ct_outcomes
  ON CONFLICT(nct_id, outcome_type, measure, time_frame) DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    outcome_type = EXCLUDED.outcome_type,
    measure = EXCLUDED.measure,
    time_frame = EXCLUDED.time_frame,
    safety_issue = EXCLUDED.safety_issue,
    description = EXCLUDED.description ;


\echo ***UPDATING TABLE: ct_conditions
INSERT INTO ct_conditions
  SELECT *
  FROM new_ct_conditions
  ON CONFLICT(nct_id, condition)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    condition = EXCLUDED.condition;




\echo ***UPDATING TABLE: ct_arm_groups
INSERT INTO ct_arm_groups
  SELECT *
  FROM new_ct_arm_groups
  ON CONFLICT(nct_id, arm_group_label, arm_group_type, description)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    arm_group_label = EXCLUDED.arm_group_label,
    arm_group_type = EXCLUDED.arm_group_type,
    description = EXCLUDED.description;


\echo ***UPDATING TABLE: ct_interventions
INSERT INTO ct_interventions
  SELECT *
  FROM new_ct_interventions
  ON CONFLICT(nct_id, intervention_type, intervention_name, description)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    intervention_type = EXCLUDED.intervention_type,
    intervention_name = EXCLUDED.intervention_name,
    description = EXCLUDED.description;

\echo ***UPDATING TABLE: ct_intervention_arm_group_labels
INSERT INTO ct_intervention_arm_group_labels
  SELECT *
  FROM new_ct_intervention_arm_group_labels
  ON CONFLICT(nct_id, intervention_name, arm_group_label)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    intervention_name = EXCLUDED.intervention_name,
    arm_group_label = EXCLUDED.arm_group_label;


\echo ***UPDATING TABLE: ct_intervention_other_names
INSERT INTO ct_intervention_other_names
  SELECT *
  FROM new_ct_intervention_other_names
  ON CONFLICT(nct_id, intervention_name, other_name)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    intervention_name = EXCLUDED.intervention_name,
    other_name = EXCLUDED.other_name;




\echo ***UPDATING TABLE: ct_overall_officials
INSERT INTO ct_overall_officials
  SELECT *
  FROM new_ct_overall_officials
  ON CONFLICT (nct_id, role, last_name)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    first_name = EXCLUDED.first_name,
    middle_name = EXCLUDED.middle_name,
    last_name = EXCLUDED.last_name,
    degrees = EXCLUDED.degrees,
    role = EXCLUDED.role,
    affiliation = EXCLUDED.affiliation;


\echo ***UPDATING TABLE: ct_overall_contacts
INSERT INTO ct_overall_contacts
  SELECT *
  FROM new_ct_overall_contacts
  ON CONFLICT (nct_id, contact_type)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    contact_type = EXCLUDED.contact_type,
    first_name = EXCLUDED.first_name,
    middle_name = EXCLUDED.middle_name,
    last_name = EXCLUDED.last_name,
    degrees = EXCLUDED.degrees,
    phone = EXCLUDED.phone,
    phone_ext = EXCLUDED.phone_ext,
    email = EXCLUDED.email;



\echo ***UPDATING TABLE: ct_locations
INSERT INTO ct_locations
  SELECT *
  FROM new_ct_locations
  ON CONFLICT (nct_id, facility_country, facility_city, facility_zip, facility_name)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    facility_name = EXCLUDED.facility_name,
    facility_city = EXCLUDED.facility_city,
    facility_state = EXCLUDED.facility_state,
    facility_zip = EXCLUDED.facility_zip,
    facility_country = EXCLUDED.facility_country,
    status = EXCLUDED.status,
    contact_first_name = EXCLUDED.contact_first_name,
    contact_middle_name = EXCLUDED.contact_middle_name,
    contact_last_name = EXCLUDED.contact_last_name,
    contact_degrees = EXCLUDED.contact_degrees,
    contact_phone = EXCLUDED.contact_phone,
    contact_phone_ext = EXCLUDED.contact_phone_ext,
    contact_email = EXCLUDED.contact_email,
    contact_backup_first_name = EXCLUDED.contact_backup_first_name,
    contact_backup_middle_name = EXCLUDED.contact_backup_middle_name,
    contact_backup_last_name = EXCLUDED.contact_backup_last_name,
    contact_backup_degrees = EXCLUDED.contact_backup_degrees,
    contact_backup_phone = EXCLUDED.contact_backup_phone,
    contact_backup_phone_ext = EXCLUDED.contact_backup_phone_ext,
    contact_backup_email = EXCLUDED.contact_backup_email;



\echo ***UPDATING TABLE: ct_location_investigators
INSERT INTO ct_location_investigators
  SELECT *
  FROM new_ct_location_investigators
  ON CONFLICT (nct_id, investigator_last_name)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    investigator_first_name = EXCLUDED.investigator_first_name,
    investigator_middle_name = EXCLUDED.investigator_middle_name,
    investigator_last_name = EXCLUDED.investigator_last_name,
    investigator_degrees = EXCLUDED.investigator_degrees,
    investigator_role = EXCLUDED.investigator_role,
    investigator_affiliation = EXCLUDED.investigator_affiliation;


\echo ***UPDATING TABLE: ct_location_countries
INSERT INTO ct_location_countries
  SELECT *
  FROM new_ct_location_countries
  ON CONFLICT (nct_id, country)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    country = EXCLUDED.country;



\echo ***UPDATING TABLE: ct_links
INSERT INTO ct_links
  SELECT *
  FROM new_ct_links
  ON CONFLICT (nct_id, url, description)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    url = EXCLUDED.url,
    description = EXCLUDED.description ;


\echo ***UPDATING TABLE: ct_condition_browses
INSERT INTO ct_condition_browses
  SELECT *
  FROM new_ct_condition_browses
  ON CONFLICT (nct_id, mesh_term)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    mesh_term = EXCLUDED.mesh_term ;




\echo ***UPDATING TABLE: ct_intervention_browses
INSERT INTO ct_intervention_browses
  SELECT *
  FROM new_ct_intervention_browses
  ON CONFLICT (nct_id, mesh_term)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    mesh_term = EXCLUDED.mesh_term ;



\echo ***UPDATING TABLE: ct_references
INSERT INTO ct_references
  SELECT *
  FROM new_ct_references
  ON CONFLICT (nct_id, md5(citation))  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    citation = EXCLUDED.citation,
    pmid = EXCLUDED.pmid;



\echo ***UPDATING TABLE: ct_publications
INSERT INTO ct_publications
  SELECT *
  FROM new_ct_publications
  ON CONFLICT (nct_id, citation)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    citation = EXCLUDED.citation,
    pmid = EXCLUDED.pmid;


\echo ***UPDATING TABLE: ct_keywords
INSERT INTO ct_keywords
  SELECT *
  FROM new_ct_keywords
  ON CONFLICT (nct_id, keyword)  DO
  UPDATE
    SET
    id = EXCLUDED.id,
    nct_id = EXCLUDED.nct_id,
    keyword = EXCLUDED.keyword;


-- Update log file.
\echo ***UPDATING LOG TABLE
INSERT INTO update_log_ct (last_updated, num_nct)
  SELECT
    current_timestamp,
    count(1)
  FROM ct_clinical_studies;



---- ***  END OF THE NEW SCRIPT  *************************************



-- OLD VERSION IS BELOW

/*

\echo ***UPDATING TABLE: ct_clinical_studies
INSERT INTO new_ct_clinical_studies
  SELECT a.*
  FROM ct_clinical_studies AS a
  WHERE a.nct_id NOT IN
            (SELECT DISTINCT nct_id
             FROM new_ct_clinical_studies);

 \echo ***UPDATING TABLE: ct_secondary_ids

 INSERT INTO new_ct_secondary_ids
   SELECT a.*
   FROM ct_secondary_ids AS a
   WHERE a.nct_id NOT IN
             (SELECT DISTINCT nct_id
              FROM new_ct_secondary_ids);


\echo ***UPDATING TABLE: ct_collaborators
INSERT INTO new_ct_collaborators
  SELECT a.*
  FROM ct_collaborators AS a
  WHERE a.nct_id NOT IN
        (SELECT DISTINCT nct_id
         FROM new_ct_collaborators);



\echo ***UPDATING TABLE: ct_authorities
INSERT INTO new_ct_authorities
 SELECT a.*
 FROM ct_authorities AS a
 WHERE a.nct_id NOT IN
       (SELECT DISTINCT nct_id
        FROM new_ct_authorities);


\echo ***UPDATING TABLE: ct_outcomes
INSERT INTO new_ct_outcomes
  SELECT a.*
  FROM ct_outcomes AS a
  WHERE a.nct_id NOT IN
        (SELECT DISTINCT nct_id
         FROM new_ct_outcomes);



\echo ***UPDATING TABLE: ct_conditions
INSERT INTO new_ct_conditions
 SELECT a.*
 FROM ct_conditions AS a
 WHERE a.nct_id NOT IN
       (SELECT DISTINCT nct_id
        FROM new_ct_conditions);



\echo ***UPDATING TABLE: ct_arm_groups
INSERT INTO new_ct_arm_groups
  SELECT a.*
  FROM ct_arm_groups AS a
  WHERE a.nct_id NOT IN
        (SELECT DISTINCT nct_id
         FROM new_ct_arm_groups);



\echo ***UPDATING TABLE: ct_interventions
INSERT INTO new_ct_interventions
 SELECT a.*
 FROM ct_interventions AS a
 WHERE a.nct_id NOT IN
       (SELECT DISTINCT nct_id
        FROM new_ct_interventions);


\echo ***UPDATING TABLE: ct_intervention_arm_group_labels
INSERT INTO new_ct_intervention_arm_group_labels
  SELECT a.*
  FROM ct_intervention_arm_group_labels AS a
  WHERE a.nct_id NOT IN
        (SELECT DISTINCT nct_id
         FROM new_ct_intervention_arm_group_labels);



\echo ***UPDATING TABLE: ct_intervention_other_names
INSERT INTO new_ct_intervention_other_names
 SELECT a.*
 FROM ct_intervention_other_names AS a
 WHERE a.nct_id NOT IN
       (SELECT DISTINCT nct_id
        FROM new_ct_intervention_other_names);



\echo ***UPDATING TABLE: ct_overall_officials
INSERT INTO new_ct_overall_officials
  SELECT a.*
  FROM ct_overall_officials AS a
  WHERE a.nct_id NOT IN
        (SELECT DISTINCT nct_id
         FROM new_ct_overall_officials);



\echo ***UPDATING TABLE: ct_overall_contacts
INSERT INTO new_ct_overall_contacts
 SELECT a.*
 FROM ct_overall_contacts AS a
 WHERE a.nct_id NOT IN
       (SELECT DISTINCT nct_id
        FROM new_ct_overall_contacts);



\echo ***UPDATING TABLE: ct_locations
INSERT INTO new_ct_locations
  SELECT a.*
  FROM ct_locations AS a
  WHERE a.nct_id NOT IN
        (SELECT DISTINCT nct_id
         FROM new_ct_locations);

\echo ***UPDATING TABLE: ct_location_investigators
INSERT INTO new_ct_location_investigators
 SELECT a.*
 FROM ct_location_investigators AS a
 WHERE a.nct_id NOT IN
       (SELECT DISTINCT nct_id
        FROM new_ct_location_investigators);






\echo ***UPDATING TABLE: ct_location_countries
INSERT INTO new_ct_location_countries
  SELECT a.*
  FROM ct_location_countries AS a
  WHERE a.nct_id NOT IN
        (SELECT DISTINCT nct_id
         FROM new_ct_location_countries);



\echo ***UPDATING TABLE: ct_links
INSERT INTO new_ct_links
 SELECT a.*
 FROM ct_links AS a
 WHERE a.nct_id NOT IN
       (SELECT DISTINCT nct_id
        FROM new_ct_links);



\echo ***UPDATING TABLE: ct_condition_browses
INSERT INTO new_ct_condition_browses
  SELECT a.*
  FROM ct_condition_browses AS a
  WHERE a.nct_id NOT IN
        (SELECT DISTINCT nct_id
         FROM new_ct_condition_browses);



\echo ***UPDATING TABLE: ct_intervention_browses
INSERT INTO new_ct_intervention_browses
 SELECT a.*
 FROM ct_intervention_browses AS a
 WHERE a.nct_id NOT IN
       (SELECT DISTINCT nct_id
        FROM new_ct_intervention_browses);



\echo ***UPDATING TABLE: ct_publications
INSERT INTO new_ct_publications
  SELECT a.*
  FROM ct_publications AS a
  WHERE a.nct_id NOT IN
        (SELECT DISTINCT nct_id
         FROM new_ct_publications);


\echo ***UPDATING TABLE: ct_keywords
INSERT INTO new_ct_keywords
 SELECT *
 FROM ct_keywords
 WHERE a.nct_id NOT IN
       (SELECT DISTINCT nct_id
        FROM new_ct_keywords);



*/




/*-- Drop oldest version of tables. --*/
--\echo ***DROPPING OLDEST VERSION OF TABLES
--DROP TABLE IF EXISTS old_ct_clinical_studies;
--DROP TABLE IF EXISTS old_ct_secondary_ids;
--DROP TABLE IF EXISTS old_ct_arm_groups;
--DROP TABLE IF EXISTS old_ct_interventions;
--DROP TABLE IF EXISTS old_ct_overall_officials;
--DROP TABLE IF EXISTS old_ct_intervention_other_names;
--DROP TABLE IF EXISTS old_ct_intervention_arm_group_labels;
--DROP TABLE IF EXISTS old_ct_conditions;
--DROP TABLE IF EXISTS old_ct_locations;
--DROP TABLE IF EXISTS old_ct_location_investigators;
--DROP TABLE IF EXISTS old_ct_location_countries;
--DROP TABLE IF EXISTS old_ct_links;
--DROP TABLE IF EXISTS old_ct_condition_browses;
--DROP TABLE IF EXISTS old_ct_intervention_browses;
--DROP TABLE IF EXISTS old_ct_references;
--DROP TABLE IF EXISTS old_ct_publications;
--DROP TABLE IF EXISTS old_ct_keywords;
--DROP TABLE IF EXISTS old_ct_overall_contacts;
--DROP TABLE IF EXISTS old_ct_collaborators;
--DROP TABLE IF EXISTS old_ct_authorities;
--DROP TABLE IF EXISTS old_ct_outcomes;

-- Rename previous version of table (ct_table_name) to oldest version:
-- old_ct_table_name.
--\echo ***RENAMING TABLES
--ALTER TABLE ct_clinical_studies RENAME TO old_ct_clinical_studies;
--ALTER TABLE ct_secondary_ids RENAME TO old_ct_secondary_ids;
--ALTER TABLE ct_arm_groups RENAME TO old_ct_arm_groups;
--ALTER TABLE ct_interventions RENAME TO old_ct_interventions;
--ALTER TABLE ct_overall_officials RENAME TO old_ct_overall_officials;
--ALTER TABLE ct_intervention_other_names RENAME TO old_ct_intervention_other_names;
--ALTER TABLE ct_intervention_arm_group_labels RENAME TO old_ct_intervention_arm_group_labels;
--ALTER TABLE ct_conditions RENAME TO old_ct_conditions;
--ALTER TABLE ct_locations RENAME TO old_ct_locations;
--ALTER TABLE ct_location_investigators RENAME TO old_ct_location_investigators;
--ALTER TABLE ct_location_countries RENAME TO old_ct_location_countries;
--ALTER TABLE ct_links RENAME TO old_ct_links;
--ALTER TABLE ct_condition_browses RENAME TO old_ct_condition_browses;
--ALTER TABLE ct_intervention_browses RENAME TO old_ct_intervention_browses;
--ALTER TABLE ct_references RENAME TO old_ct_references;
--ALTER TABLE ct_publications RENAME TO old_ct_publications;
--ALTER TABLE ct_keywords RENAME TO old_ct_keywords;
--ALTER TABLE ct_overall_contacts RENAME TO old_ct_overall_contacts;
--ALTER TABLE ct_collaborators RENAME TO old_ct_collaborators;
--ALTER TABLE ct_authorities RENAME TO old_ct_authorities;
--ALTER TABLE ct_outcomes RENAME TO old_ct_outcomes;

-- Rename newest version of table (new_ct_table_name) to current_version:
-- ct_table_name.
--ALTER TABLE new_ct_clinical_studies RENAME TO ct_clinical_studies;
--ALTER TABLE new_ct_secondary_ids RENAME TO ct_secondary_ids;
--ALTER TABLE new_ct_arm_groups RENAME TO ct_arm_groups;
--ALTER TABLE new_ct_interventions RENAME TO ct_interventions;
--ALTER TABLE new_ct_overall_officials RENAME TO ct_overall_officials;
--ALTER TABLE new_ct_intervention_other_names RENAME TO ct_intervention_other_names;
--ALTER TABLE new_ct_intervention_arm_group_labels RENAME TO ct_intervention_arm_group_labels;
--ALTER TABLE new_ct_conditions RENAME TO ct_conditions;
--ALTER TABLE new_ct_locations RENAME TO ct_locations;
--ALTER TABLE new_ct_location_investigators RENAME TO ct_location_investigators;
--ALTER TABLE new_ct_location_countries RENAME TO ct_location_countries;
--ALTER TABLE new_ct_links RENAME TO ct_links;
--ALTER TABLE new_ct_condition_browses RENAME TO ct_condition_browses;
--ALTER TABLE new_ct_intervention_browses RENAME TO ct_intervention_browses;
--ALTER TABLE new_ct_references RENAME TO ct_references;
--ALTER TABLE new_ct_publications RENAME TO ct_publications;
--ALTER TABLE new_ct_keywords RENAME TO ct_keywords;
--ALTER TABLE new_ct_overall_contacts RENAME TO ct_overall_contacts;
--ALTER TABLE new_ct_collaborators RENAME TO ct_collaborators;
--ALTER TABLE new_ct_authorities RENAME TO ct_authorities;
--ALTER TABLE new_ct_outcomes RENAME TO ct_outcomes;
