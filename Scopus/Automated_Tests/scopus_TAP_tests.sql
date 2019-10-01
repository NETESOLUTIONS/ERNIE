/*
 Title: Scopus-update TAP-test
 Author: Djamil Lakhdar-Hamina
 Date: 07/11/2019
 Purpose: Develop a TAP protocol to test if the scopus_update parser is behaving as intended.
 TAP protocol specifies that you determine a set of assertions with binary-semantics. The assertion is evaluated either true or false.
 The evaluation should allow the client or user to understand what the problem is and to serve as a guide for diagnostics.

 The tests are:
 1. do all tables exist
 2. do all tables have a pk
 3. do any of the tables have columns that are 100% NULL
 4. For various tables was there an increases ?
 */

-- \timing
\set ON_ERROR_STOP on
\set ECHO all

\if :{?schema}
-- public has to be used in search_path to find pgTAP routines
SET search_path = :schema,public;
\endif

-- However, Jenkins can run tests without plan,  but serves a good indicator of the number of affirmations
\echo 'Synthetic testing will begin....'

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- 3 # Assertion: are main tables populated (Y/N?)

/*CREATE OR REPLACE FUNCTION test_that_all_scopus_tables_are_populated()
RETURNS SETOF TEXT
AS $$
BEGIN
  DECLARE
      nrow1 integer;
      nrow2 integer;
      nrow3 integer;
      nrow4 integer;
      nrow5 integer;
      nrow6 integer;
      nrow7 integer;
      nrow8 integer;
      nrow9 integer;
      nrow10 integer;
      nrow11 integer;
      nrow12 integer;
      nrow13 integer;
      nrow14 integer;
      nrow15 integer;
      nrow16 integer;
      nrow17 integer;
      nrow18 integer;
      nrow19 integer;
      nrow20 integer;
      nrow21 integer;
      nrow22 integer;
      nrow23 integer;
      nrow24 integer;

  BEGIN
      SELECT COUNT(1) into nrow1 FROM scopus_abstracts;
      SELECT COUNT(1) into nrow2 FROM scopus_affiliations;
      SELECT COUNT(1) into nrow3 FROM scopus_authors;
      SELECT COUNT(1) into nrow4 FROM scopus_author_affiliations;
      SELECT COUNT(1) into nrow5 FROM scopus_chemical_groups;
      SELECT COUNT(1) into nrow6 FROM scopus_classes;
      SELECT COUNT(1) into nrow7 FROM scopus_classification_lookup;
      SELECT COUNT(1) into nrow8 FROM scopus_conf_editors;
      SELECT COUNT(1) into nrow9 FROM scopus_conf_proceedings;
      SELECT COUNT(1) into nrow10 FROM scopus_conference_events;
      SELECT COUNT(1) into nrow11 FROM scopus_grant_acknowledgments;
      SELECT COUNT(1) into nrow12 FROM scopus_grants;
      SELECT COUNT(1) into nrow13 FROM scopus_isbns;
      SELECT COUNT(1) into nrow14 FROM scopus_issns;
      SELECT COUNT(1) into nrow15 FROM scopus_keywords;
      SELECT COUNT(1) into nrow16 FROM scopus_publication_groups;
      SELECT COUNT(1) into nrow17 FROM scopus_publication_identifiers;
      SELECT COUNT(1) into nrow18 FROM scopus_publications;
      SELECT COUNT(1) into nrow19 FROM scopus_references;
      SELECT COUNT(1) into nrow20 FROM scopus_publication_details;
      SELECT COUNT(1) into nrow21 FROM scopus_sources;
      SELECT COUNT(1) into nrow22 FROM scopus_subject_keywords;
      SELECT COUNT(1) into nrow23 FROM scopus_subjects;
      SELECT COUNT(1) into nrow24 FROM scopus_titles;

      return next ok(nrow1 > 10000, 'scopus_abstracts is populated');
      return next ok(nrow2 > 10000, 'scopus_affiliations is populated');
      return next ok(nrow3 > 10000, 'scopus_authors is populated');
      return next ok(nrow4 > 10000, 'scopus_author_affiliations is populated');
      return next ok(nrow5 > 10000, 'scopus_chemical_groups is populated');
      return next ok(nrow6 > 10000, 'scopus_classes is populated');
      return next ok(nrow7 > 10000, 'scopus_classification_lookup is populated');
      return next ok(nrow8 > 10000, 'scopus_conf_editors is populated');
      return next ok(nrow9 > 10000, 'scopus_conf_proceedings is populated');
      return next ok(nrow10 > 10000, 'scopus_conference_events is populated');
      return next ok(nrow11 > 10000, 'scopus_grant_acknowledgments is populated');
      return next ok(nrow12 > 10000, 'scopus_grants is populated');
      return next ok(nrow13 > 10000, 'scopus_isbns is populated');
      return next ok(nrow14 > 10000, 'scopus_issns is populated');
      return next ok(nrow15 > 10000, 'scopus_keywords is populated');
      return next ok(nrow16 > 10000, 'scopus_publication_groups is populated');
      return next ok(nrow17 > 10000, 'scopus_publication_identifiers is populated');
      return next ok(nrow18 > 10000, 'scopus_publications is populated');
      return next ok(nrow19 > 10000, 'scopus_references is populated');
      return next ok(nrow20 > 10000, 'scopus_publication_details is populated');
      return next ok(nrow21 > 10000, 'scopus_sources is populated');
      return next ok(nrow22 > 10000, 'scopus_subject_keywords is populated');
      return next ok(nrow23 > 10000, 'scopus_subjects is populated');
      return next ok(nrow24 > 10000, 'scopus_titles is populated');
  END;
END;
$$ LANGUAGE plpgsql;*/

-- 4 # Assertion: is there an increase in records ?

CREATE OR REPLACE FUNCTION test_that_publication_number_increase_after_weekly_scopus_update() RETURNS SETOF TEXT AS $$
DECLARE new_num INTEGER; old_num INTEGER;
BEGIN
  SELECT num_scopus_pub INTO new_num FROM update_log_scopus WHERE num_scopus_pub IS NOT NULL ORDER BY id DESC LIMIT 1;

  SELECT num_scopus_pub
    INTO old_num
    FROM update_log_scopus
   WHERE num_scopus_pub IS NOT NULL AND id != (
     SELECT id FROM update_log_scopus WHERE num_scopus_pub IS NOT NULL ORDER BY id DESC LIMIT 1
   )
   ORDER BY id DESC
   LIMIT 1;

  RETURN NEXT ok(new_num >= old_num, 'The number of scopus records should not decrease with an update');

END; $$ LANGUAGE plpgsql;

-- Run functions
-- Start transaction and plan the tests.

DO $block$
  DECLARE tab RECORD;
  BEGIN
    -- Analyze tables
    FOR tab IN (
      SELECT table_name FROM information_schema.tables --
      WHERE table_schema = current_schema AND table_name LIKE 'scopus%'
    ) LOOP
      EXECUTE format('ANALYZE VERBOSE %I;', tab.table_name);
    END LOOP;
  END $block$;

BEGIN;
SELECT *
  FROM no_plan();

-- region all scopus tables exist (T/F?)
SELECT has_table('scopus_abstracts');
SELECT has_table('scopus_affiliations');
SELECT has_table('scopus_authors');
SELECT has_table('scopus_author_affiliations');
SELECT has_table('scopus_chemical_groups');
SELECT has_table('scopus_classes');
SELECT has_table('scopus_classification_lookup');
SELECT has_table('scopus_conf_editors');
SELECT has_table('scopus_conf_proceedings');
SELECT has_table('scopus_conference_events');
SELECT has_table('scopus_grant_acknowledgments');
SELECT has_table('scopus_grants');
SELECT has_table('scopus_isbns');
SELECT has_table('scopus_issns');
SELECT has_table('scopus_keywords');
SELECT has_table('scopus_publication_groups');
SELECT has_table('scopus_publication_identifiers');
SELECT has_table('scopus_publications');
SELECT has_table('scopus_references');
SELECT has_table('scopus_source_publication_details');
SELECT has_table('scopus_sources');
SELECT has_table('scopus_subject_keywords');
SELECT has_table('scopus_subjects');
SELECT has_table('scopus_titles');
-- endregion

-- region all tables should have a PK
SELECT is_empty($$
 SELECT current_schema || '.' || table_name
  FROM information_schema.tables t
 WHERE table_schema = current_schema AND table_name LIKE 'scopus%'
   AND NOT EXISTS(SELECT 1
                    FROM information_schema.table_constraints tc
                   WHERE tc.table_schema = current_schema
                     AND tc.table_name = t.table_name
                     AND tc.constraint_type = 'PRIMARY KEY')$$);
-- endregion

-- region are any tables completely null for every field (Y/N?)
SELECT is_empty($$
  SELECT current_schema || '.' || tablename || '.' || attname AS not_populated_column
    FROM pg_stats
  WHERE schemaname = current_schema AND tablename LIKE 'scopus%' AND null_frac = 1$$,
                       'All columns should be populated (not 100% NULL)');
-- endregion

SELECT test_that_publication_number_increase_after_weekly_scopus_update();

SELECT *
  FROM finish();
ROLLBACK;
