/*
 Title: Scopus-update TAP-test
 Author: Djamil Lakhdar-Hamina
 Date: 07/11/2019
 Purpose: Develop a TAP protocol to test if the scopus_update parser is behaving as intended.
 TAP protocol specifies that you determine a set of assertions with binary-semantics. The assertion is evaluated either true or false.
 The evaluation should allow the client or user to understand what the problem is and to serve as a guide for diagnostics.
 */

 -- 1 # Assertion : all scopus tables exist (T/F?)
 CREATE OR REPLACE FUNCTION test_that_all_scopus_tables_exist()
 RETURNS SETOF TEXT
 AS $$
RETURN NEXT has_table('scopus_abstracts' ,'scopus_abstracts exists');
RETURN NEXT has_table('scopus_affiliations' ,'scopus_affiliations exists');
RETURN NEXT has_table('scopus_authors' ,'scopus_authors exists');
RETURN NEXT has_table('scopus_author_affiliations' ,'scopus_author_affiliations exists');
RETURN NEXT has_table('scopus_chemical_groups' ,'scopus_chemical_groups exists');
RETURN NEXT has_table('scopus_classes' ,'scopus_classes exists');
RETURN NEXT has_table('scopus_classification_lookup', 'scopus_classification_lookup exists');
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
 RETURN NEXT has_pk('scopus_abstracts' ,'scopus_abstracts exists');
 RETURN NEXT has_pk('scopus_affiliations' ,'scopus_affiliations exists');
 RETURN NEXT has_pk('scopus_authors' ,'scopus_authors exists');
 RETURN NEXT has_pk('scopus_author_affiliations' ,'scopus_author_affiliations exists');
 RETURN NEXT has_pk('scopus_chemical_groups' ,'scopus_chemical_groups exists');
 RETURN NEXT has_pk('scopus_classes' ,'scopus_classes exists');
 RETURN NEXT has_pk('scopus_classification_lookup', 'scopus_classification_lookup exists');
 RETURN NEXT has_pk('scopus_classification_lookup', 'scopus_classification_lookup exists');
 RETURN NEXT has_pk('scopus_conf_editors', 'scopus_conf_editors exists');
 RETURN NEXT has_pk('scopus_conf_proceedings', 'scopus_conf_proceedings exists');
 RETURN NEXT has_pk('scopus_conference_events', 'scopus_conference_events exists');
 RETURN NEXT has_pk('scopus_grant_acknowledgments', 'scopus_grant_acknowledgments exists');
 RETURN NEXT has_pk('scopus_grants', 'scopus_grants exists');
 RETURN NEXT has_pk('scopus_isbns', 'scopus_isbns exists');
 RETURN NEXT has_pk('scopus_issns', 'scopus_issns exists');
 RETURN NEXT has_pk('scopus_keywords', 'scopus_keywords exists');
 RETURN NEXT has_pk('scopus_publication_groups', 'scopus_publication_groups exists');
 RETURN NEXT has_pk('scopus_publication_identifiers', 'scopus_publication_identifiers exists');
 RETURN NEXT has_pk('scopus_publications', 'scopus_publications exists');
 RETURN NEXT has_pk('scopus_references', 'scopus_references exists');
 RETURN NEXT has_pk('scopus_sources', 'scopus_sources exists');
 RETURN NEXT has_pk('scopus_subject_keywords', 'scopus_subject_keywords exists');
 RETURN NEXT has_pk('scopus_subjects', 'scopus_subjects exists');
 RETURN NEXT has_pk('scopus_titles', 'scopus_titles exists');
 END;
 $$ language plpgsql;

 -- 3 # Assertion: are main tables populated (Y/N?)

 CREATE OR REPLACE FUNCTION test_that_all_scopus_tables_are_populated()
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
      SELECT COUNT(1) into nrow20 FROM scopus_sources;
      SELECT COUNT(1) into nrow21 FROM scopus_subject_keywords;
      SELECT COUNT(1) into nrow21 FROM scopus_subject_keywords;
      SELECT COUNT(1) into nrow22 FROM scopus_subjects;
      SELECT COUNT(1) into nrow23 FROM scopus_titles;

/*
      return next ok(nrow1 > 1000000, 'scopus_abstracts is populated');
      return next ok(nrow2 > 1000000, 'scopus_affiliations is populated');
      return next ok(nrow3 > 1000000, 'scopus_authors is populated');
      return next ok(nrow4 > 1000000, 'scopus_author_affiliations is populated');
      return next ok(nrow5 > 1000000, 'scopus_chemical_groups is populated');
      return next ok(nrow6 > 1000000, 'scopus_classification_lookup is populated');
      return next ok(nrow7 > 0, 'scopus_conf_editors is populated');
      return next ok(nrow8 > 1000000, 'scopus_conference_events is populated');
      return next ok(nrow9 > 1000000, 'wos_pub_author_addresses is populated');
      return next ok(nrow10 > 1000000, 'wos_pub_authors is populated');
      return next ok(nrow11 > 1000000, 'wos_publication_subjects is populated');
      return next ok(nrow12 > 1000000, 'wos_publications is populated');
      return next ok(nrow13 > 1000000, 'wos_references_invalid is populated');
      return next ok(nrow14 > 1000000, 'wos_references_valid is populated');
      return next ok(nrow15 > 1000000, 'wos_titles is populated');
      return next ok(nrow16 > 1000, 'wos_grant_acknowledgements is populated');
      return next ok(nrow17 > 1000, 'wos_journals is populated');
      return next ok(nrow18 > 1000, 'wos_references_possible is populated');
      return next ok(nrow19 > 1000, 'wos_references_possible_publications is populated');
      return next ok(nrow19 > 1000, 'wos_references_possible_publications is populated');
      return next ok(nrow19 > 1000, 'wos_references_possible_publications is populated');
      return next ok(nrow19 > 1000, 'wos_references_possible_publications is populated');
      return next ok(nrow19 > 1000, 'wos_references_possible_publications is populated');
  END;
END;
$$ LANGUAGE plpgsql;

*/

 -- 4 # Assertion : are any tables completely null for every field  (Y/N?)

 -- Test if there is any 100% null columns
 CREATE OR REPLACE FUNCTION test_that_there_is_no_100_percent_NULL_column_in_WoS_tables()
 RETURNS SETOF TEXT
 AS $$
 DECLARE tab record;
 BEGIN
   FOR tab IN
   (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'scopus%')
   LOOP
     EXECUTE format('ANALYZE verbose %I;',tab.table_name);
   END LOOP;

   RETURN NEXT is_empty(
     select distinct tablename, attname from pg_stats
       where schemaname = 'public' and tablename like 'scopus%' and null_frac = '1', 'No 100% null column');
 END;
 $$ LANGUAGE plpgsql;
