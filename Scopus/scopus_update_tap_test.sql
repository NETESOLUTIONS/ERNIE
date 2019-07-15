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
 3.
 */

 \timing

\echo 'Update process complete!';
\echo 'Synthetic testing will begin....';

 -- 1 # Assertion : all scopus tables exist (T/F?)
 CREATE OR REPLACE FUNCTION test_that_all_scopus_tables_exist()
 RETURNS SETOF TEXT
 AS $$
 BEGIN
RETURN NEXT has_table('scopus_abstracts' ,'scopus_abstracts exists');
RETURN NEXT has_table('scopus_affiliations' ,'scopus_affiliations exists');
RETURN NEXT has_table('scopus_authors' ,'scopus_authors exists');
RETURN NEXT has_table('scopus_author_affiliations' ,'scopus_author_affiliations exists');
RETURN NEXT has_table('scopus_chemical_groups' ,'scopus_chemical_groups exists');
RETURN NEXT has_table('scopus_classes' ,'scopus_classes exists');
RETURN NEXT has_table('scopus_classification_lookup', 'scopus_classification_lookup exists');
RETURN NEXT has_table('scopus_conf_editors', 'scopus_conf_editors exists');
RETURN NEXT has_table('scopus_conf_proceedings', 'scopus_conf_proceedings exists');
RETURN NEXT has_table('scopus_conference_events', 'scopus_conference_events exists');
RETURN NEXT has_table('scopus_grant_acknowledgments', 'scopus_grant_acknowledgments exists');
RETURN NEXT has_table('scopus_grants', 'scopus_grants exists');
RETURN NEXT has_table('scopus_isbns', 'scopus_isbns exists');
RETURN NEXT has_table('scopus_issns', 'scopus_issns exists');
RETURN NEXT has_table('scopus_keywords', 'scopus_keywords exists');
RETURN NEXT has_table('scopus_publication_groups', 'scopus_publication_groups exists');
RETURN NEXT has_table('scopus_publication_identifiers', 'scopus_publication_identifiers exists');
RETURN NEXT has_table('scopus_publications', 'scopus_publications exists');
RETURN NEXT has_table('scopus_references', 'scopus_references exists');
RETURN NEXT has_table('scopus_publication_details', 'scopus_publication_details exists');
RETURN NEXT has_table('scopus_sources', 'scopus_sources exists');
RETURN NEXT has_table('scopus_subject_keywords', 'scopus_subject_keywords exists');
RETURN NEXT has_table('scopus_subjects', 'scopus_subjects exists');
RETURN NEXT has_table('scopus_titles', 'scopus_titles exists');
END;
$$ language plpgsql;

 -- 2 # Assertion : all scopus tables have a pk (T/F?)
 CREATE OR REPLACE FUNCTION test_that_all_scopus_tables_have_pk()
 RETURNS SETOF TEXT
 AS $$
 BEGIN
 RETURN NEXT has_pk('scopus_abstracts' ,'scopus_abstracts pk exists');
 RETURN NEXT has_pk('scopus_affiliations' ,'scopus_affiliations pk exists');
 RETURN NEXT has_pk('scopus_authors' ,'scopus_authors pk exists');
 RETURN NEXT has_pk('scopus_author_affiliations' ,'scopus_author_affiliations pk exists');
 RETURN NEXT has_pk('scopus_chemical_groups' ,'scopus_chemical_groups pk exists');
 RETURN NEXT has_pk('scopus_classes' ,'scopus_classes pk exists');
 RETURN NEXT has_pk('scopus_classification_lookup', 'scopus_classification_lookup pk exists');
 RETURN NEXT has_pk('scopus_conf_editors', 'scopus_conf_editors pk exists');
 RETURN NEXT has_pk('scopus_conf_proceedings', 'scopus_conf_proceedings pk exists');
 RETURN NEXT has_pk('scopus_conference_events', 'scopus_conference_events pk exists');
 RETURN NEXT has_pk('scopus_grant_acknowledgments', 'scopus_grant_acknowledgments pk exists');
 RETURN NEXT has_pk('scopus_grants', 'scopus_grants pk exists');
 RETURN NEXT has_pk('scopus_isbns', 'scopus_isbns pk exists');
 RETURN NEXT has_pk('scopus_issns', 'scopus_issns pk exists');
 RETURN NEXT has_pk('scopus_keywords', 'scopus_keywords pk exists');
 RETURN NEXT has_pk('scopus_publication_groups', 'scopus_publication_groups pk exists');
 RETURN NEXT has_pk('scopus_publication_identifiers', 'scopus_publication_identifiers pk exists');
 RETURN NEXT has_pk('scopus_publications', 'scopus_publications pk exists');
 RETURN NEXT has_pk('scopus_references', 'scopus_references pk exists');
 RETURN NEXT has_pk('scopus_publication_details', 'scopus_publication_details pk exists');
 RETURN NEXT has_pk('scopus_sources', 'scopus_sources pk exists');
 RETURN NEXT has_pk('scopus_subject_keywords', 'scopus_subject_keywords exists');
 RETURN NEXT has_pk('scopus_subjects', 'scopus_subjects exists');
 RETURN NEXT has_pk('scopus_titles', 'scopus_titles exists');
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

 -- 3 # Assertion : are any tables completely null for every field  (Y/N?)

 -- Test if there is any 100% null columns
 CREATE OR REPLACE FUNCTION test_that_there_is_no_100_percent_NULL_column_in_scopus_tables()
 RETURNS SETOF TEXT
 AS $$
 DECLARE tab record;
 BEGIN
   RETURN NEXT is_empty( 'select distinct tablename, attname from pg_stats
    where schemaname = ''public'' and tablename like ''scopus%'' and null_frac = 1', 'No 100% null column');
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
--end of script

-- Run functions
-- Start transaction and plan the tests.
BEGIN;
SELECT plan(50);
select test_that_all_scopus_tables_exist();
select test_that_all_scopus_tables_have_pk();
-- select test_that_all_scopus_tables_are_populated();
select test_that_there_is_no_100_percent_NULL_column_in_WoS_tables();
SELECT pass( 'My test passed!');
select * from finish();
ROLLBACK;

-- 4 # Pseudo-Assertion: is there an increase in records ?

CREATE OR REPLACE TABLE test_table_record_number_increased_after_update AS
select
schemaname as schema_name,
relname as table_name,
n_live_tup as n_live_records,
n_dead_tup as n_dead_records,
n_tup_upd as n_updates,
n_tup_del as n_deletions
from pg_stat_all_tables
where schemaname='public'
and relname in ('scopus_abstracts','scopus_authors','scopus_grants',
                                          'scopus_grant_acknowledgments','scopus_keywords','scopus_publications',
                                          'scopus_publication_groups','scopus_references','scopus_sources','scopus_subjects','scopus_titles')
ORDER BY n_live_tup DESC;

SELECT n_updates, n_deletions
CASE WHEN n_updates > n_deletions THEN \echo 'There was an increase!'
WHEN n_updates < n_deletions THEN \echo 'There was a decrease!'
ELSE \echo 'Nothing happened'
END
FROM test_table_record_number_increased_after_update;

DROP TABLE test_that_record_number_increased_after_update;

\echo 'Synthetic testing is over.'
-
