/*
Author: Djamil Lakhdar-Hamina
Date: July 22, 2019

 Title: Scopus-update TAP-test
 Author: Djamil Lakhdar-Hamina
 Date: 07/23/2019
 Purpose: Develop a TAP protocol to test if the scopus_update parser is behaving as intended.
 TAP protocol specifies that you determine a set of assertions with binary-semantics. The assertion is evaluated either true or false.
 The evaluation should allow the client or user to understand what the problem is and to serve as a guide for diagnostics.

 The assertions to test are:
 1. do all tables exist
 2. do all tables have a pk
 3. do all the tables have a lexis_tblspc
 4. do all the tables have an index
 5. do any of the tables have columns that are 100% NULL
 6. For various tables was there an increase?
*/

\timing
\set ON_ERROR_STOP on
\set ECHO all

\echo 'Update process complete!'

\echo 'Synthetic testing will begin....'

-- 1 # Assertion : all scopus tables exist (T/F?)
CREATE OR REPLACE FUNCTION test_that_all_ct_tables_exist()
RETURNS SETOF TEXT
AS $$
BEGIN
RETURN NEXT has_table('ct_clinical_studies' ,'ct_clinical_studies exists');
RETURN NEXT has_table('ct_arm_groups' ,'ct_arm_groups exists');
RETURN NEXT has_table('ct_collaborators' ,'ct_collaborators exists');
RETURN NEXT has_table('ct_condition_browses' ,'ct_condition_browses exists');
RETURN NEXT has_table('ct_conditions' ,'ct_conditions exists');
RETURN NEXT has_table('ct_expanded_access_info' ,'ct_expanded_access_info exists');
RETURN NEXT has_table('ct_intervention_arm_group_labels', 'ct_intervention_arm_group_labels exists');
RETURN NEXT has_table('ct_intervention_browses', 'ct_intervention_browses exists');
RETURN NEXT has_table('ct_intervention_other_names', 'ct_intervention_other_names exists');
RETURN NEXT has_table('ct_interventions', 'ct_interventions exists');
RETURN NEXT has_table('ct_keywords', 'ct_keywords exists');
RETURN NEXT has_table('ct_links', 'ct_links exists');
RETURN NEXT has_table('ct_location_countries', 'ct_location_countries exists');
RETURN NEXT has_table('ct_location_investigators', 'ct_location_investigators exists');
RETURN NEXT has_table('ct_locations', 'ct_locations exists');
RETURN NEXT has_table('ct_outcomes', 'ct_outcomes exists');
RETURN NEXT has_table('ct_overall_contacts', 'ct_overall_contacts exists');
RETURN NEXT has_table('ct_overall_officials', 'ct_overall_officials exists');
RETURN NEXT has_table('ct_publications', 'ct_publications exists');
RETURN NEXT has_table('ct_references', 'ct_references exists');
RETURN NEXT has_table('ct_secondary_ids', 'ct_secondary_ids exists');
RETURN NEXT has_table('ct_study_design_info', 'ct_study_design_info exists');
END;
$$ language plpgsql;

-- 2 # Assertion : all scopus tables have a pk (T/F?)
CREATE OR REPLACE FUNCTION test_that_all_ct_tables_have_pk()
RETURNS SETOF TEXT
AS $$
BEGIN
RETURN NEXT has_pk('ct_clinical_studies' ,'ct_clinical_studies has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_arm_groups' ,'ct_arm_groups has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_collaborators' ,'ct_collaborators has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_condition_browses' ,'ct_condition_browses has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_conditions' ,'ct_conditions has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_expanded_access_info' ,'ct_expanded_access_info has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_intervention_arm_group_labels', 'ct_intervention_arm_group_labels has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_intervention_browses', 'ct_intervention_browses has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_intervention_other_names', 'ct_intervention_other_names has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_interventions', 'ct_interventions has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_keywords', 'ct_keywords has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_links', 'ct_links has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_location_countries', 'ct_location_countries has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_location_investigators', 'ct_location_investigators has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_locations', 'ct_locations has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_outcomes', 'ct_outcomes has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_overall_contacts', 'ct_overall_contacts has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_overall_officials', 'ct_overall_officials has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_publications', 'ct_publications has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_references', 'ct_references has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_secondary_ids', 'ct_secondary_ids has National Clinical Trial # as primary key ');
RETURN NEXT has_pk('ct_study_design_info', 'ct_study_design_info has National Clinical Trial # as primary key ');

END;
$$ language plpgsql;

--  -- 3 # Assertion: are main tables populated (Y/N?)
--
--  CREATE OR REPLACE FUNCTION test_that_all_scopus_tables_are_populated()
-- RETURNS SETOF TEXT
-- AS $$
-- BEGIN
--   DECLARE
--       nrow1 integer;
--       nrow2 integer;
--       nrow3 integer;
--       nrow4 integer;
--       nrow5 integer;
--       nrow6 integer;
--       nrow7 integer;
--       nrow8 integer;
--       nrow9 integer;
--       nrow10 integer;
--       nrow11 integer;
--       nrow12 integer;
--       nrow13 integer;
--       nrow14 integer;
--       nrow15 integer;
--       nrow16 integer;
--       nrow17 integer;
--       nrow18 integer;
--       nrow19 integer;
--       nrow20 integer;
--       nrow21 integer;
--       nrow22 integer;
--       nrow23 integer;
--       nrow24 integer;
--
--   BEGIN
--       SELECT COUNT(1) into nrow1 FROM scopus_abstracts;
--       SELECT COUNT(1) into nrow2 FROM scopus_affiliations;
--       SELECT COUNT(1) into nrow3 FROM scopus_authors;
--       SELECT COUNT(1) into nrow4 FROM scopus_author_affiliations;
--       SELECT COUNT(1) into nrow5 FROM scopus_chemical_groups;
--       SELECT COUNT(1) into nrow6 FROM scopus_classes;
--       SELECT COUNT(1) into nrow7 FROM scopus_classification_lookup;
--       SELECT COUNT(1) into nrow8 FROM scopus_conf_editors;
--       SELECT COUNT(1) into nrow9 FROM scopus_conf_proceedings;
--       SELECT COUNT(1) into nrow10 FROM scopus_conference_events;
--       SELECT COUNT(1) into nrow11 FROM scopus_grant_acknowledgments;
--       SELECT COUNT(1) into nrow12 FROM scopus_grants;
--       SELECT COUNT(1) into nrow13 FROM scopus_isbns;
--       SELECT COUNT(1) into nrow14 FROM scopus_issns;
--       SELECT COUNT(1) into nrow15 FROM scopus_keywords;
--       SELECT COUNT(1) into nrow16 FROM scopus_publication_groups;
--       SELECT COUNT(1) into nrow17 FROM scopus_publication_identifiers;
--       SELECT COUNT(1) into nrow18 FROM scopus_publications;
--       SELECT COUNT(1) into nrow19 FROM scopus_references;
--       SELECT COUNT(1) into nrow20 FROM scopus_publication_details;
--       SELECT COUNT(1) into nrow21 FROM scopus_sources;
--       SELECT COUNT(1) into nrow22 FROM scopus_subject_keywords;
--       SELECT COUNT(1) into nrow23 FROM scopus_subjects;
--       SELECT COUNT(1) into nrow24 FROM scopus_titles;
--
--       return next ok(nrow1 > 10000, 'scopus_abstracts is populated');
--       return next ok(nrow2 > 10000, 'scopus_affiliations is populated');
--       return next ok(nrow3 > 10000, 'scopus_authors is populated');
--       return next ok(nrow4 > 10000, 'scopus_author_affiliations is populated');
--       return next ok(nrow5 > 10000, 'scopus_chemical_groups is populated');
--       return next ok(nrow6 > 10000, 'scopus_classes is populated');
--       return next ok(nrow7 > 10000, 'scopus_classification_lookup is populated');
--       return next ok(nrow8 > 10000, 'scopus_conf_editors is populated');
--       return next ok(nrow9 > 10000, 'scopus_conf_proceedings is populated');
--       return next ok(nrow10 > 10000, 'scopus_conference_events is populated');
--       return next ok(nrow11 > 10000, 'scopus_grant_acknowledgments is populated');
--       return next ok(nrow12 > 10000, 'scopus_grants is populated');
--       return next ok(nrow13 > 10000, 'scopus_isbns is populated');
--       return next ok(nrow14 > 10000, 'scopus_issns is populated');
--       return next ok(nrow15 > 10000, 'scopus_keywords is populated');
--       return next ok(nrow16 > 10000, 'scopus_publication_groups is populated');
--       return next ok(nrow17 > 10000, 'scopus_publication_identifiers is populated');
--       return next ok(nrow18 > 10000, 'scopus_publications is populated');
--       return next ok(nrow19 > 10000, 'scopus_references is populated');
--       return next ok(nrow20 > 10000, 'scopus_publication_details is populated');
--       return next ok(nrow21 > 10000, 'scopus_sources is populated');
--       return next ok(nrow22 > 10000, 'scopus_subject_keywords is populated');
--       return next ok(nrow23 > 10000, 'scopus_subjects is populated');
--       return next ok(nrow24 > 10000, 'scopus_titles is populated');
--   END;
-- END;
-- $$ LANGUAGE plpgsql;

-- #3 Assertion: are tables in lexis_nexis tablespace ?
CREATE OR REPLACE FUNCTION test_that_ct_tablespace_exists()
RETURNS SETOF TEXT
AS $$
BEGIN
RETURN NEXT has_tablespace('ct_tbs' ,'ct_tbs exists');
END;
$$ language plpgsql;

-- #4 Assertion : are any tables completely null for every field  (Y/N?)
CREATE OR REPLACE FUNCTION test_that_there_is_no_100_percent_NULL_column_in_ct_tables()
RETURNS SETOF TEXT
AS $$
DECLARE tab record;
BEGIN
FOR tab IN
 (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'ct%')
 LOOP
   EXECUTE format('ANALYZE verbose %I;',tab.table_name);
 END LOOP;
  RETURN NEXT is_empty( 'select tablename, attname from pg_stats
   where schemaname = ''public'' and tablename in LIKE ''ct%'' and null_frac = 1', 'No 100% null column');
END;
$$ LANGUAGE plpgsql;

-- 5 # Assertion: is there an increase in records ?

CREATE OR REPLACE FUNCTION test_that_publication_number_increase_after_weekly_ct_update()
RETURNS SETOF TEXT
AS $$
DECLARE
  new_num integer;
  old_num integer;
BEGIN
  SELECT num_nct into new_num FROM update_log_ct
  WHERE num_nct IS NOT NULL
  ORDER BY id DESC LIMIT 1;

  SELECT num_nct into old_num FROM update_log_ct
  WHERE num_nct IS NOT NULL AND id != (SELECT id FROM update_log_ct WHERE num_nct IS NOT NULL ORDER BY id DESC LIMIT 1)
  ORDER BY id DESC LIMIT 1;

  return next ok(new_num > old_num, 'The number of clinical trial records has increased from latest update!');

END;
$$ LANGUAGE plpgsql;

/*
--5 # Assertion : did the number of entries in
CREATE OR REPLACE FUNCTION test_that_publication_number_increase_after_weekly_WoS_update()
RETURNS SETOF TEXT
AS $$
DECLARE
 new_num integer;
 old_num integer;
BEGIN
 SELECT num_wos into new_num FROM update_log_wos
 WHERE num_wos IS NOT NULL
 ORDER BY id DESC LIMIT 1;

 SELECT num_wos into old_num FROM update_log_wos
 WHERE num_wos IS NOT NULL AND id != (SELECT id FROM update_log_wos WHERE num_wos IS NOT NULL ORDER BY id DESC LIMIT 1)
 ORDER BY id DESC LIMIT 1;

 return next ok(new_num > old_num, 'WoS number has been increased from latest update');

END;
$$ LANGUAGE plpgsql;

*/

-- Run functions
-- Start transaction and plan the tests.

DO $$DECLARE TOTAL_NUM_ASSERTIONS integer default 60;
BEGIN
SELECT plan(TOTAL_NUM_ASSERTIONS);
select test_that_all_ct_tables_exist();
select test_that_all_ct_tables_have_pk();
select test_that_ct_tablespace_exists();
select test_that_there_is_no_100_percent_NULL_column_in_ct_tables();
select test_that_publication_number_increase_after_weekly_ct_update();
SELECT pass( 'My test passed!');
select * from finish();
ROLLBACK;
END$$;


\echo 'Testing process is over!'

-- END OF SCRIPT
