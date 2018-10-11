-- region ct_arm_groups
ALTER TABLE ct_arm_groups
  ALTER COLUMN arm_group_label SET NOT NULL;
-- 5.4

CREATE UNIQUE INDEX ct_arm_groups_uk
  ON ct_arm_groups (nct_id, arm_group_label, arm_group_type, description)
TABLESPACE index_tbs;
-- 4.9s
-- endregion

-- region ct_authorities
ALTER TABLE ct_authorities
  ADD CONSTRAINT ct_authorities_pk PRIMARY KEY (nct_id) USING INDEX TABLESPACE index_tbs;
-- endregion

-- region ct_collaborators
ALTER TABLE ct_collaborators
  ADD CONSTRAINT ct_collaborators_pk PRIMARY KEY (nct_id, agency) USING INDEX TABLESPACE index_tbs;
-- 1.3s
-- endregion

-- region ct_conditions
ALTER TABLE ct_conditions
  ADD CONSTRAINT ct_conditions_pk PRIMARY KEY (nct_id, condition) USING INDEX TABLESPACE index_tbs;
-- 6.4s
-- endregion

-- region ct_condition_browses
ALTER TABLE ct_condition_browses
  ADD CONSTRAINT ct_condition_browses_pk PRIMARY KEY (nct_id, mesh_term) USING INDEX TABLESPACE index_tbs;
-- 7.6s
-- endregion

-- region ct_interventions
DELETE
FROM
  ct_interventions ct1
WHERE EXISTS(SELECT 1
             FROM ct_interventions ct2
             WHERE ct2.nct_id = ct1.nct_id
               AND ct2.intervention_type = ct1.intervention_type
               AND ct2.intervention_name = ct1.intervention_name
               AND coalesce(ct2.description, '') = coalesce(ct1.description, '')
               AND ct2.ctid > ct1.ctid);
--

ALTER TABLE ct_interventions
  ALTER COLUMN intervention_type SET NOT NULL,
  ALTER COLUMN intervention_name SET NOT NULL;
--

CREATE UNIQUE INDEX ct_interventions_uk
  ON ct_interventions (nct_id, intervention_type, intervention_name, description)
TABLESPACE index_tbs;
-- 4.9s
-- endregion

-- region ct_intervention_other_names
ALTER TABLE ct_intervention_other_names
  ALTER COLUMN intervention_name SET NOT NULL,
  ALTER COLUMN other_name SET NOT NULL;
--

DELETE
FROM
  ct_intervention_other_names ction1
WHERE EXISTS(SELECT 1
             FROM ct_intervention_other_names ction2
             WHERE ction2.nct_id = ction1.nct_id
               AND ction2.intervention_name = ction1.intervention_name
               AND ction2.other_name = ction1.other_name
               AND ction2.ctid > ction1.ctid);
-- 3.2s

ALTER TABLE ct_intervention_other_names
  ADD CONSTRAINT ct_intervention_other_names_pk PRIMARY KEY (nct_id, intervention_name, other_name)
USING INDEX TABLESPACE index_tbs;
-- 1.8s
-- endregion

-- region ct_intervention_browses
ALTER TABLE ct_intervention_browses
  ALTER COLUMN mesh_term SET NOT NULL;
-- 3.1s

ALTER TABLE ct_intervention_browses
  ADD CONSTRAINT ct_intervention_browses_pk PRIMARY KEY (nct_id, mesh_term)
USING INDEX TABLESPACE index_tbs;
-- 1.9s
-- endregion

-- region ct_intervention_arm_group_labels
ALTER TABLE ct_intervention_arm_group_labels
  ALTER COLUMN intervention_name SET NOT NULL,
  ALTER COLUMN arm_group_label SET NOT NULL;

DELETE
FROM
  ct_intervention_arm_group_labels ctiagl1
WHERE EXISTS(SELECT 1
             FROM ct_intervention_arm_group_labels ctiagl2
             WHERE ctiagl2.nct_id = ctiagl1.nct_id
               AND ctiagl2.intervention_name = ctiagl1.intervention_name
               AND ctiagl2.arm_group_label = ctiagl1.arm_group_label
               AND ctiagl2.ctid > ctiagl1.ctid);
-- 8.3s

ALTER TABLE ct_intervention_arm_group_labels
  ADD CONSTRAINT ct_intervention_arm_group_labels_pk PRIMARY KEY (nct_id, intervention_name, arm_group_label)
USING INDEX TABLESPACE index_tbs;
-- 4.3s
-- endregion

-- region ct_keywords
ALTER TABLE ct_keywords
  ALTER COLUMN keyword SET NOT NULL;
-- 4.5s

ALTER TABLE ct_keywords
  ADD CONSTRAINT ct_keywords_pk PRIMARY KEY (nct_id, keyword)
USING INDEX TABLESPACE index_tbs;
-- 5.2s
-- endregion

-- region ct_links
ALTER TABLE ct_links
  ALTER COLUMN url SET NOT NULL;
-- 2.2s

CREATE UNIQUE INDEX ct_links_uk
  ON ct_links (nct_id, url, description)
TABLESPACE index_tbs;
-- 0.4s
-- endregion

-- region ct_locations
DELETE
FROM
  ct_locations ctl1
WHERE EXISTS(SELECT 1
             FROM ct_locations ctl2
             WHERE ctl2.nct_id = ctl1.nct_id
               AND ctl2.facility_country = ctl1.facility_country
               AND ctl2.facility_city = ctl1.facility_city
               AND ctl2.facility_zip = ctl1.facility_zip
               AND ctl2.facility_name = ctl1.facility_name
               AND ctl2.ctid > ctl1.ctid);
-- 2.8s

CREATE UNIQUE INDEX ct_locations_uk
  ON ct_locations (nct_id, facility_country, facility_city, facility_zip, facility_name)
TABLESPACE index_tbs;
-- 14.7s
-- endregion

-- region ct_location_countries
ALTER TABLE ct_location_countries
  ALTER COLUMN country SET NOT NULL;
-- 3.4s

ALTER TABLE ct_location_countries
  ADD CONSTRAINT ct_location_countries_pk PRIMARY KEY (nct_id, country)
USING INDEX TABLESPACE index_tbs;
-- 2.7s
-- endregion

-- region ct_location_investigators
ALTER TABLE ct_location_investigators
  -- full names are stored in investigator_last_name
  ALTER COLUMN investigator_last_name SET NOT NULL;
-- 2.4s

DELETE
FROM
  ct_location_investigators ctli1
WHERE EXISTS(SELECT 1
             FROM ct_location_investigators ctli2
             WHERE ctli2.nct_id = ctli1.nct_id
               AND ctli2.investigator_last_name = ctli1.investigator_last_name
               AND ctli2.ctid > ctli1.ctid);
-- 0.4s

ALTER TABLE ct_location_investigators
  ADD CONSTRAINT ct_location_investigators_pk PRIMARY KEY (nct_id, investigator_last_name)
USING INDEX TABLESPACE index_tbs;
-- 0.9s
-- endregion

-- region ct_outcomes
ALTER TABLE ct_outcomes
  ALTER COLUMN outcome_type SET NOT NULL,
  ALTER COLUMN measure SET NOT NULL;
-- 8.7s

DELETE
FROM
  ct_outcomes cto1
WHERE EXISTS(SELECT 1
             FROM ct_outcomes cto2
             WHERE cto2.nct_id = cto1.nct_id
               AND cto2.outcome_type = cto1.outcome_type
               AND cto2.measure = cto1.measure
               AND cto2.time_frame = cto1.time_frame
               AND cto2.ctid > cto1.ctid);
-- 20.6s

CREATE UNIQUE INDEX ct_outcomes_uk
  ON ct_outcomes (nct_id, outcome_type, measure, time_frame)
TABLESPACE index_tbs;
-- 12.4s
-- endregion

-- region ct_overall_contacts
ALTER TABLE ct_overall_contacts
  ALTER COLUMN contact_type SET NOT NULL,
  -- full names are stored in last_name
  ALTER COLUMN last_name SET NOT NULL;
-- 2.3s

ALTER TABLE ct_overall_contacts
  ADD CONSTRAINT ct_overall_contacts_pk PRIMARY KEY (nct_id, contact_type)
USING INDEX TABLESPACE index_tbs;
-- 0.8s
-- endregion

-- region ct_overall_officials
ALTER TABLE ct_overall_officials
  -- full names are stored in last_name
  ALTER COLUMN last_name SET NOT NULL;

DELETE
FROM
  ct_overall_officials ctoo1
WHERE EXISTS(SELECT 1
             FROM ct_overall_officials ctoo2
             WHERE ctoo2.nct_id = ctoo1.nct_id
               AND ctoo2.role = ctoo1.role
               AND ctoo2.last_name = ctoo1.last_name
               AND ctoo2.ctid > ctoo1.ctid);
-- 0.4s

CREATE UNIQUE INDEX ct_overall_officials_uk
  ON ct_overall_officials (nct_id, role, last_name)
TABLESPACE index_tbs;
-- 2.4s
-- endregion

-- region ct_publications
ALTER TABLE ct_publications
  ALTER COLUMN citation SET NOT NULL;
-- 2.2s

ALTER TABLE ct_publications
  ADD CONSTRAINT ct_publications_pk PRIMARY KEY (nct_id, citation)
USING INDEX TABLESPACE index_tbs;
-- 0.8s
-- endregion

-- region ct_references
ALTER TABLE ct_references
  ALTER COLUMN citation SET NOT NULL;
-- 5.0s

-- Values larger than 1/3 of a buffer page cannot be indexed
CREATE UNIQUE INDEX ct_references_uk
  ON ct_references (nct_id, md5(citation))
TABLESPACE index_tbs;
-- 1.6s
-- endregion

-- region ct_secondary_ids
ALTER TABLE ct_secondary_ids
  ALTER COLUMN secondary_id SET NOT NULL;
-- 1.5s

DELETE
FROM
  ct_secondary_ids ctsi1
WHERE EXISTS(SELECT 1
             FROM ct_secondary_ids ctsi2
             WHERE ctsi2.nct_id = ctsi1.nct_id
               AND ctsi2.secondary_id = ctsi1.secondary_id
               AND ctsi2.ctid > ctsi1.ctid);
-- 0.2s

ALTER TABLE ct_secondary_ids
  ADD CONSTRAINT ct_secondary_ids_pk PRIMARY KEY (nct_id, secondary_id)
USING INDEX TABLESPACE index_tbs;
-- 0.7s
-- endregion