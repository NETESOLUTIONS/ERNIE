\set ON_ERROR_STOP on
\set ECHO all

SET default_tablespace = index_tbs;

-- region new_ct_arm_groups
ALTER TABLE new_ct_arm_groups
  ALTER COLUMN arm_group_label SET NOT NULL;
-- 5.4s

DELETE FROM new_ct_arm_groups ctag1
WHERE EXISTS(SELECT 1
             FROM new_ct_arm_groups ctag2
             WHERE ctag2.nct_id = ctag1.nct_id AND ctag2.arm_group_label = ctag1.arm_group_label AND
               ctag2.arm_group_type = ctag1.arm_group_type AND
               coalesce(ctag2.description, '') = coalesce(ctag1.description, '') AND ctag2.ctid > ctag1.ctid);
-- 1.4s

CREATE UNIQUE INDEX IF NOT EXISTS new_ct_arm_groups_uk
  ON new_ct_arm_groups (nct_id, arm_group_label, arm_group_type, description);
-- 4.9s
-- endregion

-- region new_ct_authorities
ALTER TABLE new_ct_authorities
  ADD CONSTRAINT new_ct_authorities_pk PRIMARY KEY (nct_id);
-- endregion

-- region new_ct_collaborators
ALTER TABLE new_ct_collaborators
  ALTER COLUMN agency SET NOT NULL;
-- 0.1s

/*
SELECT *
FROM new_ct_collaborators
WHERE (nct_id, agency) = ('NCT02863601', 'Northwestern University');
*/

DELETE FROM new_ct_collaborators cc1
WHERE EXISTS(SELECT 1
             FROM new_ct_collaborators cc2
             WHERE cc2.nct_id = cc1.nct_id AND cc2.agency = cc1.agency AND cc2.ctid > cc1.ctid);
-- 0.3s

ALTER TABLE new_ct_collaborators
  ADD CONSTRAINT new_ct_collaborators_pk PRIMARY KEY (nct_id, agency);
-- 1.3s
-- endregion

-- region new_ct_conditions
ALTER TABLE new_ct_conditions
  ALTER COLUMN condition SET NOT NULL;
-- 0.1s

/*
SELECT *
FROM new_ct_conditions
WHERE (nct_id, condition) = ('NCT03362892', 'Pancreatic Cancer');
*/

DELETE FROM new_ct_conditions cc1
WHERE EXISTS(SELECT 1
             FROM new_ct_conditions cc2
             WHERE cc2.nct_id = cc1.nct_id AND cc2.condition = cc1.condition AND cc2.ctid > cc1.ctid);

ALTER TABLE new_ct_conditions
  ADD CONSTRAINT new_ct_conditions_pk PRIMARY KEY (nct_id, condition);
-- 6.4s
-- endregion

-- region new_ct_condition_browses
ALTER TABLE new_ct_condition_browses
  ALTER COLUMN mesh_term SET NOT NULL;
-- 0.1s

/*
SELECT *
FROM new_ct_condition_browses
WHERE (nct_id, mesh_term)=('NCT01480986', 'Disease Progression');
*/

DELETE FROM new_ct_condition_browses ccb1
WHERE EXISTS(SELECT 1
             FROM new_ct_condition_browses ccb2
             WHERE ccb2.nct_id = ccb1.nct_id AND ccb2.mesh_term = ccb1.mesh_term AND ccb2.ctid > ccb1.ctid);

ALTER TABLE new_ct_condition_browses
  ADD CONSTRAINT new_ct_condition_browses_pk PRIMARY KEY (nct_id, mesh_term);
-- 7.6s
-- endregion

-- region new_ct_interventions
DELETE FROM new_ct_interventions ct1
WHERE EXISTS(SELECT 1
             FROM new_ct_interventions ct2
             WHERE ct2.nct_id = ct1.nct_id AND ct2.intervention_type = ct1.intervention_type AND
               ct2.intervention_name = ct1.intervention_name AND
               coalesce(ct2.description, '') = coalesce(ct1.description, '') AND ct2.ctid > ct1.ctid);
--

ALTER TABLE new_ct_interventions
  ALTER COLUMN intervention_type SET NOT NULL,
  ALTER COLUMN intervention_name SET NOT NULL;
--

CREATE UNIQUE INDEX IF NOT EXISTS new_ct_interventions_uk
  ON new_ct_interventions (nct_id, intervention_type, intervention_name, description);
-- 4.9s
-- endregion

-- region new_ct_intervention_other_names
ALTER TABLE new_ct_intervention_other_names
  ALTER COLUMN intervention_name SET NOT NULL,
  ALTER COLUMN other_name SET NOT NULL;
--

DELETE FROM new_ct_intervention_other_names ction1
WHERE EXISTS(SELECT 1
             FROM new_ct_intervention_other_names ction2
             WHERE ction2.nct_id = ction1.nct_id AND ction2.intervention_name = ction1.intervention_name AND
               ction2.other_name = ction1.other_name AND ction2.ctid > ction1.ctid);
-- 3.2s

--@formatter:off
DO $block$ BEGIN
  IF NOT EXISTS(SELECT 1
                FROM information_schema.constraint_column_usage
                WHERE constraint_schema = 'public'
                  AND constraint_name = 'new_ct_intervention_other_names_pk')
  THEN
    ALTER TABLE new_ct_intervention_other_names
      ADD CONSTRAINT new_ct_intervention_other_names_pk PRIMARY KEY (nct_id, intervention_name, other_name);
  END IF;
END $block$;
--@formatter:on
-- endregion

-- region new_ct_intervention_browses
ALTER TABLE new_ct_intervention_browses
  ALTER COLUMN mesh_term SET NOT NULL;
-- 3.1s

DELETE FROM new_ct_intervention_browses ctib1
WHERE EXISTS(SELECT 1
             FROM new_ct_intervention_browses ctib2
             WHERE ctib2.nct_id = ctib1.nct_id AND ctib2.mesh_term = ctib1.mesh_term AND ctib2.ctid > ctib1.ctid);
-- 0.5s

ALTER TABLE new_ct_intervention_browses
  ADD CONSTRAINT new_ct_intervention_browses_pk PRIMARY KEY (nct_id, mesh_term);
-- 1.9s
-- endregion

-- region new_ct_intervention_arm_group_labels
ALTER TABLE new_ct_intervention_arm_group_labels
  ALTER COLUMN intervention_name SET NOT NULL,
  ALTER COLUMN arm_group_label SET NOT NULL;

DELETE FROM new_ct_intervention_arm_group_labels ctiagl1
WHERE EXISTS(SELECT 1
             FROM new_ct_intervention_arm_group_labels ctiagl2
             WHERE ctiagl2.nct_id = ctiagl1.nct_id AND ctiagl2.intervention_name = ctiagl1.intervention_name AND
               ctiagl2.arm_group_label = ctiagl1.arm_group_label AND ctiagl2.ctid > ctiagl1.ctid);
-- 8.3s

--@formatter:off
DO $block$ BEGIN
  IF NOT EXISTS(SELECT 1
                FROM information_schema.constraint_column_usage
                WHERE constraint_schema = 'public'
                  AND constraint_name = 'new_ct_intervention_arm_group_labels_pk')
  THEN
    ALTER TABLE new_ct_intervention_arm_group_labels
      ADD CONSTRAINT new_ct_intervention_arm_group_labels_pk PRIMARY KEY (nct_id, intervention_name, arm_group_label);
    -- 4.3s
  END IF;
END $block$;
--@formatter:on
-- endregion

-- region new_ct_keywords
ALTER TABLE new_ct_keywords
  ALTER COLUMN keyword SET NOT NULL;
-- 4.5s

/*
SELECT *
FROM new_ct_keywords
WHERE (nct_id, keyword)=('NCT00003526', 'recurrent carcinoma of unknown primary');
*/

DELETE FROM new_ct_keywords ctk1
WHERE EXISTS(SELECT 1
             FROM new_ct_keywords ctk2
             WHERE ctk2.nct_id = ctk1.nct_id AND ctk2.keyword = ctk1.keyword AND ctk2.ctid > ctk1.ctid);
-- 16.5s

ALTER TABLE new_ct_keywords
  ADD CONSTRAINT new_ct_keywords_pk PRIMARY KEY (nct_id, keyword);
-- 5.2s
-- endregion

-- region new_ct_links
ALTER TABLE new_ct_links
  ALTER COLUMN url SET NOT NULL;
-- 2.2s

/*
SELECT *
FROM new_ct_links
WHERE (nct_id, url, description) =
  ('NCT02846532', 'http://pam.sylogent.com/cr/CR108075', 'To learn how to participate in this trial please click here.')
;
*/

DELETE FROM new_ct_links cl1
WHERE EXISTS(SELECT 1
             FROM new_ct_links cl2
             WHERE cl2.nct_id = cl1.nct_id AND cl2.url = cl1.url AND
               coalesce(cl2.description, '') = coalesce(cl1.description, '') AND cl2.ctid > cl1.ctid);
-- 0.3s

CREATE UNIQUE INDEX IF NOT EXISTS new_ct_links_uk
  ON new_ct_links (nct_id, url, description);
-- 0.4s
-- endregion

-- region new_ct_locations
DELETE FROM new_ct_locations ctl1
WHERE EXISTS(SELECT 1
             FROM new_ct_locations ctl2
             WHERE ctl2.nct_id = ctl1.nct_id AND ctl2.facility_country = ctl1.facility_country AND
               ctl2.facility_city = ctl1.facility_city AND ctl2.facility_zip = ctl1.facility_zip AND
               ctl2.facility_name = ctl1.facility_name AND ctl2.ctid > ctl1.ctid);
-- 2.8s


CREATE UNIQUE INDEX IF NOT EXISTS new_ct_locations_uk
  ON new_ct_locations (nct_id, facility_country, facility_city, facility_zip, facility_name);
-- 14.7s
-- endregion

-- region new_ct_location_countries
ALTER TABLE new_ct_location_countries
  ALTER COLUMN country SET NOT NULL;
-- 3.4s

/*
SELECT *
FROM new_ct_location_countries
WHERE (nct_id, country)=('NCT02582632', 'Canada');
*/

DELETE FROM new_ct_location_countries t1
WHERE EXISTS(SELECT 1
             FROM new_ct_location_countries t2
             WHERE t2.nct_id = t1.nct_id AND t2.country = t1.country AND t2.ctid > t1.ctid);
-- 1.1s

ALTER TABLE new_ct_location_countries
  ADD CONSTRAINT new_ct_location_countries_pk PRIMARY KEY (nct_id, country);
-- 2.7s
-- endregion

-- region new_ct_location_investigators
ALTER TABLE new_ct_location_investigators
-- full names are stored in investigator_last_name
  ALTER COLUMN investigator_last_name SET NOT NULL;
-- 2.4s

DELETE FROM new_ct_location_investigators ctli1
WHERE EXISTS(SELECT 1
             FROM new_ct_location_investigators ctli2
             WHERE ctli2.nct_id = ctli1.nct_id AND ctli2.investigator_last_name = ctli1.investigator_last_name AND
               ctli2.ctid > ctli1.ctid);
-- 0.4s

--@formatter:off
DO $block$ BEGIN
  IF NOT EXISTS(SELECT 1
                FROM information_schema.constraint_column_usage
                WHERE constraint_schema = 'public'
                  AND constraint_name = 'new_ct_location_investigators_pk')
  THEN
    ALTER TABLE new_ct_location_investigators
      ADD CONSTRAINT new_ct_location_investigators_pk PRIMARY KEY (nct_id, investigator_last_name);
  END IF;
END $block$;
--@formatter:on
-- 0.9s
-- endregion

-- region new_ct_outcomes
ALTER TABLE new_ct_outcomes
  ALTER COLUMN outcome_type SET NOT NULL,
  ALTER COLUMN measure SET NOT NULL;
-- 8.7s

DELETE FROM new_ct_outcomes cto1
WHERE EXISTS(SELECT 1
             FROM new_ct_outcomes cto2
             WHERE
               cto2.nct_id = cto1.nct_id AND cto2.outcome_type = cto1.outcome_type AND cto2.measure = cto1.measure AND
                 cto2.time_frame = cto1.time_frame AND cto2.ctid > cto1.ctid);
-- 20.6s

CREATE UNIQUE INDEX new_ct_outcomes_uk
  ON new_ct_outcomes (nct_id, outcome_type, measure, time_frame);
-- 12.4s
-- endregion

-- region new_ct_overall_contacts
ALTER TABLE new_ct_overall_contacts
  ALTER COLUMN contact_type SET NOT NULL, -- full names are stored in last_name
  ALTER COLUMN last_name SET NOT NULL;
-- 2.3s

/*
SELECT *
FROM new_ct_overall_contacts
WHERE (nct_id, contact_type)=('NCT02514343', 'overall_contact_backup');
*/

DELETE FROM new_ct_overall_contacts t1
WHERE EXISTS(SELECT 1
             FROM new_ct_overall_contacts t2
             WHERE t2.nct_id = t1.nct_id AND t2.contact_type = t1.contact_type AND t2.ctid > t1.ctid);
-- 0.4s

ALTER TABLE new_ct_overall_contacts
  ADD CONSTRAINT new_ct_overall_contacts_pk PRIMARY KEY (nct_id, contact_type);
-- 0.8s
-- endregion

-- region new_ct_overall_officials
ALTER TABLE new_ct_overall_officials
-- full names are stored in last_name
  ALTER COLUMN last_name SET NOT NULL;

DELETE FROM new_ct_overall_officials ctoo1
WHERE EXISTS(SELECT 1
             FROM new_ct_overall_officials ctoo2
             WHERE ctoo2.nct_id = ctoo1.nct_id AND ctoo2.role = ctoo1.role AND ctoo2.last_name = ctoo1.last_name AND
               ctoo2.ctid > ctoo1.ctid);
-- 0.4s

CREATE UNIQUE INDEX new_ct_overall_officials_uk
  ON new_ct_overall_officials (nct_id, role, last_name);
-- 2.4s
-- endregion

-- region new_ct_publications
ALTER TABLE new_ct_publications
  ALTER COLUMN citation SET NOT NULL;
-- 2.2s

DELETE FROM new_ct_publications t1
WHERE EXISTS(SELECT 1
             FROM new_ct_publications t2
             WHERE t2.nct_id = t1.nct_id AND t2.citation = t1.citation AND t2.ctid > t1.ctid);
-- 0.2s

ALTER TABLE new_ct_publications
  ADD CONSTRAINT new_ct_publications_pk PRIMARY KEY (nct_id, citation);
-- 0.8s
-- endregion

-- region new_ct_references
ALTER TABLE new_ct_references
  ALTER COLUMN citation SET NOT NULL;
-- 5.0s

DELETE FROM new_ct_references t1
WHERE EXISTS(SELECT 1
             FROM new_ct_references t2
             WHERE t2.nct_id = t1.nct_id AND t2.citation = t1.citation AND t2.ctid > t1.ctid);
-- 0.7s

-- Values larger than 1/3 of a buffer page cannot be indexed
CREATE UNIQUE INDEX IF NOT EXISTS new_ct_references_uk
  ON new_ct_references (nct_id, md5(citation));
-- 1.6s
-- endregion

-- region new_ct_secondary_ids
ALTER TABLE new_ct_secondary_ids
  ALTER COLUMN secondary_id SET NOT NULL;
-- 1.5s

DELETE FROM new_ct_secondary_ids ctsi1
WHERE EXISTS(SELECT 1
             FROM new_ct_secondary_ids ctsi2
             WHERE ctsi2.nct_id = ctsi1.nct_id AND ctsi2.secondary_id = ctsi1.secondary_id AND ctsi2.ctid > ctsi1.ctid);
-- 0.2s

--@formatter:off
DO $block$ BEGIN
  IF NOT EXISTS(SELECT 1
                FROM information_schema.constraint_column_usage
                WHERE constraint_schema = 'public'
                  AND constraint_name = 'new_ct_secondary_ids_pk')
  THEN
    ALTER TABLE new_ct_secondary_ids
      ADD CONSTRAINT new_ct_secondary_ids_pk PRIMARY KEY (nct_id, secondary_id);
  END IF;
END $block$;
--@formatter:on-- 0.7s
-- endregion
