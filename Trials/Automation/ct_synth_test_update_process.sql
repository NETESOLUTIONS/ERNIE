/*
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
 4. do any of the tables have columns that are 100% NULL
 5. For various tables was there an increase?
*/

\timing
\set ON_ERROR_STOP on
\set ECHO all
\set TOTAL_NUM_ASSERTIONS 58

'Update process complete!'

'Synthetic testing will begin....'

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

-- Run functions
-- Start transaction and plan the tests

BEGIN;
SELECT plan(:TOTAL_NUM_ASSERTIONS);
select test_that_all_ct_tables_exist();
select test_that_all_ct_tables_have_pk();
select test_that_ct_tablespace_exists();
select test_that_there_is_no_100_percent_NULL_column_in_ct_tables();
select test_that_publication_number_increase_after_weekly_ct_update();
SELECT pass( 'My test passed!');
select * from finish();
ROLLBACK;
END$$;


'Testing process is over!'

-- END OF SCRIPT
