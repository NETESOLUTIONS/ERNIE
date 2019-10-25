/*
  CT DDL

  Modified:
    -VJ Davey, 06/22/2018
        -New additions to ct_clinical_studies:
          is_fda_regulated_drug,is_fda_regulated_device, is_unapproved_device, is_ppsd, and is_us_export,gender_based,gender_description
        -New additions to ct_outcomes:
          non_inferiority_type,other_analysis_desc
        -Removed from ct_clinical_studies:
          is_fda_regulated, is_section_801, study_design
        -Removed from ct_outcomes:
          safety_issue
        -Dropped ct_authorities table
        -Created ct_expanded_access_info, ct_study_design_info tables
    -VJ Davey, 04/26/2018
        -Normalization efforts: introduction of FKs, dropping ID field where useless, removed location_countries, and miscellaneous work
*/

DROP TABLE IF EXISTS ct_clinical_studies;
CREATE TABLE ct_clinical_studies (
  nct_id                               TEXT NOT NULL,
  rank                                 TEXT,
  download_date                        TEXT,
  link_text                            TEXT,
  url                                  TEXT,
  org_study_id                         TEXT,
  nct_alias                            TEXT,
  brief_title                          TEXT,
  acronym                              TEXT,
  official_title                       TEXT,
  lead_sponsor_agency                  TEXT,
  lead_sponsor_agency_class            TEXT,
  source                               TEXT,
  has_dmc                              TEXT,
  brief_summary                        TEXT,
  detailed_description                 TEXT,
  overall_status                       TEXT,
  why_stopped                          TEXT,
  start_date                           TEXT,
  completion_date                      TEXT,
  completion_date_type                 TEXT,
  primary_completion_date              TEXT,
  primary_completion_date_type         TEXT,
  phase                                TEXT,
  study_type                           TEXT,
  target_duration                      TEXT,
  number_of_arms                       INTEGER,
  number_of_groups                     INTEGER,
  enrollment                           TEXT,
  enrollment_type                      TEXT,
  biospec_retention                    TEXT,
  biospec_descr                        TEXT,
  study_pop                            TEXT,
  sampling_method                      TEXT,
  criteria                             TEXT,
  gender                               TEXT,
  gender_based                         TEXT,
  gender_description                   TEXT,
  minimum_age                          TEXT,
  maximum_age                          TEXT,
  healthy_volunteers                   TEXT,
  verification_date                    TEXT,
  last_update_submitted                TEXT,
  study_first_submitted                TEXT,
  results_first_submitted              TEXT,
  disposition_first_submitted          TEXT,
  responsible_party_type               TEXT,
  responsible_investigator_affiliation TEXT,
  responsible_investigator_full_name   TEXT,
  responsible_investigator_title       TEXT,
  is_fda_regulated_drug                TEXT,
  is_fda_regulated_device              TEXT,
  is_unapproved_device                 TEXT,
  is_ppsd                              TEXT,
  is_us_export                         TEXT,
  has_expanded_access                  TEXT,
  CONSTRAINT ct_clinical_studies_pk PRIMARY KEY (nct_id) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_clinical_studies IS $$clinical studies detail data$$;
COMMENT ON COLUMN ct_clinical_studies.nct_id IS $$Example:NCT00000265$$;
COMMENT ON COLUMN ct_clinical_studies.rank IS $$Example:289803$$;
COMMENT ON COLUMN ct_clinical_studies.download_date IS $$Example: ClinicalTrials.gov processed this data on November
16, 2018$$;
COMMENT ON COLUMN ct_clinical_studies.link_text IS $$Link to the current ClinicalTrials.gov record$$;
COMMENT ON COLUMN ct_clinical_studies.url IS $$Example: https://clinicaltrials.gov/show/NCT00005691$$;
COMMENT ON COLUMN ct_clinical_studies.org_study_id IS $$Example: 4213$$;
COMMENT ON COLUMN ct_clinical_studies.nct_alias IS $$Example: NCT00001739$$;
COMMENT ON COLUMN ct_clinical_studies.brief_title IS $$Example: Physicians Health Study$$;
COMMENT ON COLUMN ct_clinical_studies.acronym IS $$Example: SILVA$$;
COMMENT ON COLUMN ct_clinical_studies.official_title IS $$study full name$$;
COMMENT ON COLUMN ct_clinical_studies.lead_sponsor_agency IS $$Example: National Heart, Lung, and Blood Institute (NHLBI)$$;
COMMENT ON COLUMN ct_clinical_studies.lead_sponsor_agency_class IS $$Example: NIH$$;
COMMENT ON COLUMN ct_clinical_studies.source IS $$Example: National Heart, Lung, and Blood Institute (NHLBI)$$;
COMMENT ON COLUMN ct_clinical_studies.has_dmc IS $$Yes/No/Null$$;
COMMENT ON COLUMN ct_clinical_studies.brief_summary IS $$Study summary text$$;
COMMENT ON COLUMN ct_clinical_studies.detailed_description IS $$Study detail description text$$;
COMMENT ON COLUMN ct_clinical_studies.overall_status IS $$Example: Completed$$;
COMMENT ON COLUMN ct_clinical_studies.why_stopped IS $$Example: No funding$$;
COMMENT ON COLUMN ct_clinical_studies.start_date IS $$Example: September 1992$$;
COMMENT ON COLUMN ct_clinical_studies.completion_date IS $$Example: August 1996$$;
COMMENT ON COLUMN ct_clinical_studies.completion_date_type IS $$Actual/Anticipated/(null)$$;
COMMENT ON COLUMN ct_clinical_studies.primary_completion_date IS $$Example: December 1995$$;
COMMENT ON COLUMN ct_clinical_studies.primary_completion_date_type IS $$Actual/Anticipated/(null)$$;
COMMENT ON COLUMN ct_clinical_studies.phase IS $$Example: Phase 3$$;
COMMENT ON COLUMN ct_clinical_studies.study_type IS $$Example: Interventional$$;
COMMENT ON COLUMN ct_clinical_studies.study_design IS $$Example: Intervention Model: Parallel Assignment, Masking: Double-Blind, Primary Purpose: Treatment$$;
COMMENT ON COLUMN ct_clinical_studies.target_duration IS $$Example: 100 Years$$;
COMMENT ON COLUMN ct_clinical_studies.number_of_arms IS $$Example: 3$$;
COMMENT ON COLUMN ct_clinical_studies.number_of_groups IS $$Example: 1$$;
COMMENT ON COLUMN ct_clinical_studies.enrollment IS $$Example: 75$$;
COMMENT ON COLUMN ct_clinical_studies.enrollment_type IS $$Actual/Anticipated/(null)$$;
COMMENT ON COLUMN ct_clinical_studies.biospec_retention IS $$Example: Samples With DNA$$;
COMMENT ON COLUMN ct_clinical_studies.biospec_descr IS $$detailed description$$;
COMMENT ON COLUMN ct_clinical_studies.study_pop IS $$long text$$;
COMMENT ON COLUMN ct_clinical_studies.sampling_method IS $$Probability Sample / Non-Probability Sample / (null)$$;
COMMENT ON COLUMN ct_clinical_studies.criteria IS $$fields study$$;
COMMENT ON COLUMN ct_clinical_studies.gender IS $$Both / Female / Male / (null)$$;
COMMENT ON COLUMN ct_clinical_studies.minimum_age IS $$Example: 2 Years$$;
COMMENT ON COLUMN ct_clinical_studies.maximum_age IS $$Example: 100 Years$$;
COMMENT ON COLUMN ct_clinical_studies.healthy_volunteers IS $$No / Accepts Healthy Volunteers / (null)$$;
COMMENT ON COLUMN ct_clinical_studies.verification_date IS $$July 2001$$;
COMMENT ON COLUMN ct_clinical_studies.last_update_submitted IS $$Example: April 13, 2012$$;
COMMENT ON COLUMN ct_clinical_studies.study_first_submitted IS $$Example: March 8, 2008$$;
COMMENT ON COLUMN ct_clinical_studies.results_first_submitted IS $$Example: July 10, 2013$$;
COMMENT ON COLUMN ct_clinical_studies.responsible_party_type IS $$Sponsor / Sponsor - Investigator / Principal Investigator / (null)$$;
COMMENT ON COLUMN ct_clinical_studies.responsible_investigator_affiliation IS $$Example: Joslin Diabetes Center$$;
COMMENT ON COLUMN ct_clinical_studies.responsible_investigator_full_name IS $$Example: Alessandro Doria$$;
COMMENT ON COLUMN ct_clinical_studies.responsible_investigator_title IS $$Example: Investigator$$;
COMMENT ON COLUMN ct_clinical_studies.is_fda_regulated_drug IS $$Example: No / Yes / (null)$$;
COMMENT ON COLUMN ct_clinical_studies.has_expanded_access IS $$Example: No / Yes / (null)$$;

DROP TABLE IF EXISTS ct_study_design_info;
CREATE TABLE ct_study_design_info (
  nct_id                         REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  allocation                     TEXT,
  intervention_model             TEXT,
  intervention_model_description TEXT,
  primary_purpose                TEXT,
  observational_model            TEXT,
  time_perspective               TEXT,
  masking                        TEXT,
  masking_description            TEXT,
  CONSTRAINT ct_study_design_info_pk PRIMARY KEY (nct_id) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

/*TODO: determine how to make this table and parse the information from the XML files
DROP TABLE IF EXISTS ct_reported_events;
CREATE TABLE ct_reported_events (
  id              INTEGER,
  nct_id          TEXT  NOT NULL,
  time_frame   TEXT NOT NULL DEFAULT '',
  title TEXT,
  subjects_affected TEXT,
  subjects_at_risk TEXT,
  description  TEXT
) TABLESPACE ct_tbs;*/

DROP TABLE IF EXISTS ct_expanded_access_info;
CREATE TABLE ct_expanded_access_info (
  nct_id                            REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  expanded_access_type_individual   TEXT,
  expanded_access_type_intermediate TEXT,
  expanded_access_type_treatment    TEXT,
  CONSTRAINT ct_expanded_access_info_pk PRIMARY KEY (nct_id) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

DROP TABLE IF EXISTS ct_arm_groups;
CREATE TABLE ct_arm_groups (
  nct_id          REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  arm_group_label TEXT NOT NULL,
  arm_group_type  TEXT NOT NULL DEFAULT '',
  description     TEXT NOT NULL DEFAULT '',
  CONSTRAINT ct_arm_groups_pk PRIMARY KEY (nct_id, arm_group_label, arm_group_type, description) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_arm_groups IS $$Table of arm group info$$;
COMMENT ON COLUMN ct_arm_groups.nct_id IS $$Example; NCT00000105$$;
COMMENT ON COLUMN ct_arm_groups.arm_group_label IS $$Example: Arm A: Intracel KLH$$;
COMMENT ON COLUMN ct_arm_groups.arm_group_type IS $$Example: Experimental$$;
COMMENT ON COLUMN ct_arm_groups.description IS $$Detailed description text$$;

DROP TABLE IF EXISTS ct_secondary_ids;
CREATE TABLE ct_secondary_ids (
  nct_id       REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  secondary_id TEXT NOT NULL,
  CONSTRAINT ct_secondary_ids_pk PRIMARY KEY (nct_id, secondary_id) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_secondary_ids IS $$Table of id info of clinical trails$$;
COMMENT ON COLUMN ct_secondary_ids.nct_id IS $$Example: NCT00000579$$;
COMMENT ON COLUMN ct_secondary_ids.secondary_id IS $$Example: N01 HR46063$$;


DROP TABLE IF EXISTS ct_collaborators;
CREATE TABLE ct_collaborators (
  nct_id       REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  agency       TEXT NOT NULL,
  agency_class TEXT,
  CONSTRAINT ct_collaborators_pk PRIMARY KEY (nct_id, agency) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_collaborators IS $$Table of clinical trial collaborators info$$;
COMMENT ON COLUMN ct_collaborators.nct_id IS $$Example; NCT00000217$$;
COMMENT ON COLUMN ct_collaborators.agency IS $$Example: US Department of Veterans Affairs$$;
COMMENT ON COLUMN ct_collaborators.agency_class IS $$Example: U.S. Fed / NIH / Industry / Other$$;


DROP TABLE IF EXISTS ct_outcomes;
CREATE TABLE ct_outcomes (
  nct_id       REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  outcome_type TEXT NOT NULL,
  measure      TEXT NOT NULL,
  time_frame   TEXT NOT NULL DEFAULT '',
  population   TEXT,
  description  TEXT,
  CONSTRAINT ct_outcomes_pk PRIMARY KEY (nct_id, outcome_type, measure, time_frame) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_outcomes IS $$Table of clinical trial outcome$$;
COMMENT ON COLUMN ct_outcomes.nct_id IS $$Example: NCT00000113$$;
COMMENT ON COLUMN ct_outcomes.outcome_type IS $$primary_outcome / secondary_outcome / other_outcome$$;
COMMENT ON COLUMN ct_outcomes.measure IS $$Example: Progression of myopia, determined by cycloplegic autorefraction$$;
COMMENT ON COLUMN ct_outcomes.time_frame IS $$Example: 0:00, 0:30, 1:00, 1:30, 2:00, 3:00, 4:00, 6:00, 8:00, 10:00,12:00 h after drug administration on day 8 (DRV/r) and day 16 (BI 201335+DRV/r)$$;
COMMENT ON COLUMN ct_outcomes.description IS $$Outcome description long text$$;


DROP TABLE IF EXISTS ct_conditions;
CREATE TABLE ct_conditions (
  nct_id    REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  condition TEXT NOT NULL,
  CONSTRAINT ct_conditions_pk PRIMARY KEY (nct_id, condition) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_conditions IS $$Table of clinical trials condition$$;
COMMENT ON COLUMN  ct_conditions.nct_id IS $$Example: NCT00000105$$;
COMMENT ON COLUMN ct_conditions.condition IS $$Current condition. Example: Cancer$$;

/*Consider making some hash and FKing all intervention tables*/
DROP TABLE IF EXISTS ct_interventions;
CREATE TABLE ct_interventions (
  nct_id            REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  intervention_type TEXT NOT NULL,
  intervention_name TEXT NOT NULL,
  description       TEXT NOT NULL DEFAULT '',
  CONSTRAINT ct_interventions_pk PRIMARY KEY (nct_id, intervention_type, intervention_name, description) --
  USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_interventions IS $$Table of intervention details$$;
COMMENT ON COLUMN  ct_interventions.nct_id IS $$Example: NCT00000102$$;
COMMENT ON COLUMN ct_interventions.intervention_type IS $$Example: Drug$$;
COMMENT ON COLUMN ct_interventions.intervention_name IS $$Example: Nifedipine$$;
COMMENT ON COLUMN ct_interventions.description IS $$Intervention description text$$;

DROP TABLE IF EXISTS ct_intervention_arm_group_labels;
CREATE TABLE ct_intervention_arm_group_labels (
  nct_id            REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  intervention_name TEXT NOT NULL,
  arm_group_label   TEXT NOT NULL,
  CONSTRAINT ct_intervention_arm_group_labels_pk PRIMARY KEY (nct_id, intervention_name, arm_group_label) --
  USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

DROP TABLE IF EXISTS ct_intervention_other_names;
CREATE TABLE ct_intervention_other_names (
  nct_id            REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  intervention_name TEXT NOT NULL,
  other_name        TEXT NOT NULL,
  CONSTRAINT ct_intervention_other_names_pk PRIMARY KEY (nct_id, intervention_name, other_name) --
  USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_intervention_other_names IS $$Table of intervention names$$;
COMMENT ON COLUMN  ct_intervention_other_names.nct_id IS $$Example: NCT00002816$$;
COMMENT ON COLUMN ct_intervention_other_names.intervention_name IS $$Example: etoposide$$;
COMMENT ON COLUMN ct_intervention_other_names.other_name IS $$Example: VP-16$$;

DROP TABLE IF EXISTS ct_overall_officials;
CREATE TABLE ct_overall_officials (
  nct_id      REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  first_name  TEXT,
  middle_name TEXT,
  last_name   TEXT NOT NULL,
  degrees     TEXT,
  role        TEXT NOT NULL DEFAULT '',
  affiliation TEXT,
  CONSTRAINT ct_overall_officials_pk PRIMARY KEY (nct_id, role, last_name) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_overall_officials IS $$Table of overall official summary$$;
COMMENT ON COLUMN ct_overall_officials.nct_id IS $$Example: NCT00000462$$;
COMMENT ON COLUMN ct_overall_officials.first_name IS $$No records yet$$;
COMMENT ON COLUMN ct_overall_officials.middle_name IS $$No records yet$$;
COMMENT ON COLUMN ct_overall_officials.last_name IS $$Example: Katherine Detre$$;
COMMENT ON COLUMN ct_overall_officials.degrees IS $$No records yet$$;
COMMENT ON COLUMN ct_overall_officials.role IS $$Example: Principal Investigator$$;
COMMENT ON COLUMN ct_overall_officials.affiliation IS $$Example: National Institute of Mental Health (NIMH)$$;


DROP TABLE IF EXISTS ct_overall_contacts;
CREATE TABLE ct_overall_contacts (
  nct_id       REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  contact_type TEXT NOT NULL,
  first_name   TEXT,
  middle_name  TEXT,
  last_name    TEXT NOT NULL,
  degrees      TEXT,
  phone        TEXT,
  phone_ext    TEXT,
  email        TEXT,
  CONSTRAINT ct_overall_contacts_pk PRIMARY KEY (nct_id,last_name) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE  ct_overall_contacts IS $$Table of overall contacts summary$$;
COMMENT ON COLUMN ct_overall_contacts.nct_id IS $$Example: NCT00323089$$;
COMMENT ON COLUMN ct_overall_contacts.contact_type IS $$overall_contact / overall_contact_backup$$;
COMMENT ON COLUMN ct_overall_contacts.first_name IS $$No records yet$$;
COMMENT ON COLUMN ct_overall_contacts.middle_name IS $$No records yet$$;
COMMENT ON COLUMN ct_overall_contacts.last_name IS $$Example: Joanne Clifton, MSc$$;
COMMENT ON COLUMN ct_overall_contacts.degrees IS $$No records yet$$;
COMMENT ON COLUMN ct_overall_contacts.phone IS $$Example: 604-875-5355$$;
COMMENT ON COLUMN ct_overall_contacts.phone_ext IS $$Example: 259$$;
COMMENT ON COLUMN ct_overall_contacts.email IS $$Example: joanne.clifton@vch.ca$$;

/* Find a proper PK here to use as an FK to the child tables, ZIP+Name would be good, but ZIP not always populated. Maybe an coalesce into a hash based on available fields would be viable?*/
CREATE TABLE IF NOT EXISTS ct_locations
(
	id INTEGER,
	nct_id TEXT NOT NULL,
	facility_name TEXT DEFAULT ''::TEXT NOT NULL,
	facility_city TEXT DEFAULT ''::TEXT NOT NULL,
	facility_state TEXT,
	facility_zip TEXT DEFAULT ''::TEXT NOT NULL,
	facility_country TEXT DEFAULT ''::TEXT NOT NULL,
	status TEXT,
	contact_first_name TEXT,
	contact_middle_name TEXT,
	contact_last_name TEXT,
	contact_degrees TEXT,
	contact_phone TEXT,
	contact_phone_ext TEXT,
	contact_email TEXT,
	contact_backup_first_name TEXT,
	contact_backup_middle_name TEXT,
	contact_backup_last_name TEXT,
	contact_backup_degrees TEXT,
	contact_backup_phone TEXT,
	contact_backup_phone_ext TEXT,
	contact_backup_email TEXT,
	CONSTRAINT ct_locations_pk
		PRIMARY KEY (nct_id, facility_city, facility_city, facility_zip, facility_name)
);

COMMENT ON TABLE ct_locations IS 'TABLE OF CLINICAL TRIAL LOCATION SUMMARY';
COMMENT ON COLUMN ct_locations.ID IS 'INTERNAL(PARDI) NUMBER.EXAMPLE: 1';
COMMENT ON COLUMN ct_locations.NCT_ID IS 'EXAMPLE: NCT00000102';
COMMENT ON COLUMN ct_locations.FACILITY_NAME IS 'EXAMPLE: MEDICAL UNIVERSITY OF SOUTH CAROLINA';
COMMENT ON COLUMN ct_locations.FACILITY_CITY IS 'EXAMPLE: CHARLESTON';
COMMENT ON COLUMN ct_locations.FACILITY_STATE IS 'EXAMPLE: SOUTH CAROLINA';
COMMENT ON COLUMN ct_locations.FACILITY_ZIP IS 'EXAMPLE: 27100';
COMMENT ON COLUMN ct_locations.FACILITY_COUNTRY IS 'EXAMPLE: UNITED STATES';
COMMENT ON COLUMN ct_locations.STATUS IS 'EXAMPLE: ACTIVE, NOT RECRUITING';
COMMENT ON COLUMN ct_locations.CONTACT_FIRST_NAME IS 'NO RECORDS YET';\
COMMENT ON COLUMN ct_locations.CONTACT_MIDDLE_NAME IS 'NO RECORDS YET';
COMMENT ON COLUMN ct_locations.CONTACT_LAST_NAME IS 'EXAMPLE: 1134IFNFORMCLL TEAM';
COMMENT ON COLUMN ct_locations.CONTACT_DEGREES IS 'NO RECORDS YET';
COMMENT ON COLUMN ct_locations.CONTACT_PHONE IS 'EXAMPLE: +001 (214) 265-2137';
COMMENT ON COLUMN ct_locations.CONTACT_PHONE_EXT IS 'EXAMPLE: +33';
COMMENT ON COLUMN ct_locations.CONTACT_EMAIL IS 'EXAMPLE: LABAN63@YAHOO.COM';
COMMENT ON COLUMN ct_locations.CONTACT_BACKUP_FIRST_NAME IS 'NO RECORDS YET';
COMMENT ON COLUMN ct_locations.CONTACT_BACKUP_MIDDLE_NAME IS 'NO RECORDS YET';
COMMENT ON COLUMN ct_locations.CONTACT_BACKUP_LAST_NAME IS 'EXAMPLE: ALAA HASSANIN, MD';
COMMENT ON COLUMN ct_locations.CONTACT_BACKUP_DEGREES IS 'NO RECORDS YET';
COMMENT ON COLUMN ct_locations.CONTACT_BACKUP_PHONE IS 'EXAMPLE: 01002554281';
COMMENT ON COLUMN ct_locations.CONTACT_BACKUP_PHONE_EXT IS 'EXAMPLE: 6770';
COMMENT ON COLUMN ct_locations.CONTACT_BACKUP_EMAIL IS 'EXAMPLE: ZHW6216@YAHOO.COM';
COMMENT ON TABLE ct_locations IS $$Table of clinical trial location summary$$;
COMMENT ON COLUMN ct_locations.location_hash IS $$Example: NCT00000102$$;
COMMENT ON COLUMN ct_locations.facility_name IS $$Example: Medical University of South Carolina$$;
COMMENT ON COLUMN ct_locations.facility_city IS $$Example: Charleston$$;
COMMENT ON COLUMN ct_locations.facility_state IS $$Example: South Carolina$$;
COMMENT ON COLUMN ct_locations.facility_zip IS $$Example: 27100$$;
COMMENT ON COLUMN ct_locations.facility_country IS $$Example: United States$$;
COMMENT ON COLUMN ct_locations.status IS $$Example: Active, not recruiting$$;

/* This table should have an FK that ties it to the location table in addition to the NCT ID */
DROP TABLE IF EXISTS ct_location_contacts;
CREATE TABLE ct_location_contacts (
  nct_id                     REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  location_hash              REFERENCES ct_locations(location_hash) ON DELETE CASCADE,
  contact_type               TEXT NOT NULL,
  contact_first_name         TEXT,
  contact_middle_name        TEXT,
  contact_last_name          TEXT,
  contact_degrees            TEXT,
  contact_phone              TEXT,
  contact_phone_ext          TEXT,
  contact_email              TEXT,
  CONSTRAINT ct_location_contacts_pk PRIMARY KEY (nct_id,TODO: FK)
  USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON COLUMN ct_location_contacts.nct_id IS $$Example: NCT00000102$$;
COMMENT ON COLUMN ct_location_contacts.location_hash IS $$Example: NCT00000102$$;
COMMENT ON COLUMN ct_location_contacts.contact_type IS $$overall_contact / overall_contact_backup$$;
COMMENT ON COLUMN ct_location_contacts.contact_first_name IS $$No records yet$$;
COMMENT ON COLUMN ct_location_contacts.contact_middle_name IS $$No records yet$$;
COMMENT ON COLUMN ct_location_contacts.contact_last_name IS $$Example: 1134ifnformCLL Team$$;
COMMENT ON COLUMN ct_location_contacts.contact_degrees IS $$No records yet$$;
COMMENT ON COLUMN ct_location_contacts.contact_phone IS $$Example: +001 (214) 265-2137$$;
COMMENT ON COLUMN ct_location_contacts.contact_phone_ext IS $$Example: +33$$;
COMMENT ON COLUMN ct_location_contacts.contact_email IS $$Example: laban63@yahoo.com$$;

/* This table should have an FK that ties it to the location table*/
DROP TABLE IF EXISTS ct_location_investigators;
CREATE TABLE ct_location_investigators (
  nct_id                   REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  location_hash            REFERENCES ct_locations(location_hash) ON DELETE CASCADE,
  investigator_first_name  TEXT, --currently unused (Raw XML has full names populated into the last_name column)
  investigator_middle_name TEXT, --currently unused (Raw XML has full names populated into the last_name column)
  investigator_last_name   TEXT NOT NULL,
  investigator_degrees     TEXT,
  investigator_role        TEXT,
  investigator_affiliation TEXT, -- This should be replaced with the FK probably
  CONSTRAINT ct_location_investigators_pk PRIMARY KEY (nct_id,location_hash,investigator_last_name) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_location_investigators IS $$Table of clinical trial location (country)$$;
COMMENT ON COLUMN ct_location_investigators.nct_id IS $$Example: NCT00075387$$;
COMMENT ON COLUMN ct_location_investigators.investigator_first_name IS $$investigators first name$$;
COMMENT ON COLUMN ct_location_investigators.investigator_middle_name IS $$investigators last name$$;
COMMENT ON COLUMN ct_location_investigators.investigator_last_name IS $$Example: Glen H. Stevens$$;
COMMENT ON COLUMN ct_location_investigators.investigator_degrees IS $$investigators degree$$;
COMMENT ON COLUMN ct_location_investigators.investigator_role IS $$Example: Principal Investigator$$;
COMMENT ON COLUMN ct_location_investigators.investigator_affiliation IS $$investigators affiliation$$;


DROP TABLE IF EXISTS ct_links;
CREATE TABLE ct_links (
  nct_id      REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  url         TEXT NOT NULL,
  description TEXT,
  CONSTRAINT ct_links_pk PRIMARY KEY (nct_id, url) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_links IS $$Table of clinical trial link address$$;
COMMENT ON COLUMN ct_links.url IS $$Example: http://trials.boehringer-ingelheim.com/$$;
COMMENT ON COLUMN ct_links.description IS $$Description about the link$$;


DROP TABLE IF EXISTS ct_condition_browses;
CREATE TABLE ct_condition_browses (
  nct_id    REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  mesh_term TEXT NOT NULL,
  CONSTRAINT ct_condition_browses_pk PRIMARY KEY (nct_id, mesh_term) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_condition_browses IS $$Table of clinical trials condition$$;
COMMENT ON COLUMN  ct_condition_browses.nct_id IS $$Example: NCT00000352$$;
COMMENT ON COLUMN ct_condition_browses.mesh_term IS $$Disease name. Example: Opioid-Related Disorders$$;


DROP TABLE IF EXISTS ct_intervention_browses;
CREATE TABLE ct_intervention_browses (
  nct_id    REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  mesh_term TEXT NOT NULL,
  CONSTRAINT ct_intervention_browses_pk PRIMARY KEY (nct_id, mesh_term) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_intervention_browses IS $$Table of intervention for clinical trails$$;
COMMENT ON COLUMN  ct_intervention_browses.nct_id IS $$Example: NCT00000105$$;
COMMENT ON COLUMN ct_intervention_browses.mesh_term IS $$Example: Keyhole-limpet hemocyanin$$;

DROP TABLE IF EXISTS ct_references;
CREATE TABLE ct_references (
  id       INTEGER, -- may not be necessary
  nct_id   REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  citation TEXT NOT NULL,
  pmid     INTEGER,
  CONSTRAINT ct_references_pk PRIMARY KEY (nct_id, pmid) USING INDEX TABLESPACE index_tbs -- PMID corresponds to the citation
) TABLESPACE ct_tbs;

CREATE UNIQUE INDEX ct_references_uk
    on ct_references (nct_id, md5(citation));

COMMENT ON TABLE ct_references IS $$Table of reference detail of clinical trails$$;
COMMENT ON COLUMN ct_references.id IS $$Internal(PARDI) number.Example: 1$$;
COMMENT ON COLUMN ct_references.nct_id IS $$Example: NCT00000418$$;
COMMENT ON COLUMN ct_references.citation IS $$Detail citation text$$;
COMMENT ON COLUMN ct_references.pmid IS $$Example: 29408806$$;

DROP TABLE IF EXISTS ct_publications;
CREATE TABLE ct_publications (
  id       INTEGER, -- may not be necessary
  nct_id   REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  citation TEXT NOT NULL,
  pmid     TEXT ,
  CONSTRAINT ct_publications_pk PRIMARY KEY (nct_id, citation) USING INDEX TABLESPACE index_tbs -- PMID corresponds to the citation
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_publications IS $$Table of publication info of clinical trails$$; -- WHAT DOES THIS MEAN COMPARED TO REFERENCES?
COMMENT ON COLUMN ct_publications.id IS $$Internal(PARDI) number.Example: 1$$;
COMMENT ON COLUMN ct_publications.nct_id IS $$Example: NCT00000145$$;
COMMENT ON COLUMN ct_publications.citation IS $$Detail citation text$$;
COMMENT ON COLUMN ct_publications.pmid IS $$Example: 10801969$$;

DROP TABLE IF EXISTS ct_keywords;
CREATE TABLE ct_keywords (
  nct_id  REFERENCES ct_clinical_studies(nct_id) ON DELETE CASCADE,
  keyword TEXT NOT NULL,
  CONSTRAINT ct_keywords_pk PRIMARY KEY (nct_id, keyword) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE ct_keywords IS $$Table of clinical trial keywords$$;
COMMENT ON COLUMN  ct_keywords.nct_id IS $$Example: NCT00000389$$;
COMMENT ON COLUMN ct_keywords.keyword IS $$Example: Fluvoxamine$$;

DROP TABLE IF EXISTS update_log_ct;
CREATE TABLE update_log_ct (
  id           SERIAL,
  last_updated TIMESTAMP,
  num_nct      INTEGER,
  CONSTRAINT update_log_ct_pk PRIMARY KEY (id) USING INDEX TABLESPACE index_tbs
) TABLESPACE ct_tbs;

COMMENT ON TABLE update_log_ct
IS 'CT tables - update log table for CT';
