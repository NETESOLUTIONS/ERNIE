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
 3. do all the tables have a fda_tblspc
 4. do any of the tables have columns that are 100% NULL
 5. For various tables was there an increase?
*/

\timing
\set ON_ERROR_STOP on
\set ECHO all
\set TOTAL_NUM_ASSERTIONS 14 -- However, Jenkins can run tests without plan,  but serves a good indicator of the number of affirmations

\echo 'Update process complete!'

\echo 'Synthetic testing will begin....'

-- 1 # Assertion : all fda tables exist (T/F?)
CREATE OR REPLACE FUNCTION test_that_all_fda_tables_exist()
RETURNS SETOF TEXT
AS $$
BEGIN
RETURN NEXT has_table('fda_patents' ,'fda_patents exists');
RETURN NEXT has_table('fda_exclusivities' ,'fda_exclusivities exists');
RETURN NEXT has_table('fda_products' ,'fda_products exists');
RETURN NEXT has_table('fda_orange_book' ,'fda_orange_book exists');
END;
$$ language plpgsql;

-- 2 # Assertion : all scopus tables have a pk (T/F?)
CREATE OR REPLACE FUNCTION test_that_all_fda_tables_have_pk()
RETURNS SETOF TEXT
AS $$
BEGIN
RETURN NEXT has_pk('fda_patents' ,'fda_patents has appl_no, product_no, type as primary key ');
RETURN NEXT has_pk('fda_exclusivities' ,'fda_exclusivities has appl_no, product_no, type as primary key ');
RETURN NEXT has_pk('fda_products' ,'fda_products has appl_no, product_no, type as primary key ');
RETURN NEXT has_pk('fda_orange_book' ,'fda_orange_book has BLAST # as primary key ');
END;
$$ language plpgsql;

-- #3 Assertion: are tables in lexis_nexis tablespace ?
CREATE OR REPLACE FUNCTION test_that_fda_tablespace_exists()
RETURNS SETOF TEXT
AS $$
BEGIN
RETURN NEXT has_tablespace('ernie_fda_tbs' ,'ernie_fda_tbs exists');
END;
$$ language plpgsql;

-- #4 Assertion : are any tables completely null for every field  (Y/N?)
CREATE OR REPLACE FUNCTION test_that_there_is_no_100_percent_NULL_column_in_fda_tables()
RETURNS SETOF TEXT
AS $$
DECLARE tab record;
BEGIN
FOR tab IN
 (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'fda%')
 LOOP
   EXECUTE format('ANALYZE verbose %I;',tab.table_name);
 END LOOP;
  RETURN NEXT is_empty( 'select tablename, attname from pg_stats
   where schemaname = ''public'' and tablename LIKE ''fda%'' and null_frac = 1', 'No 100% null column');
END;
$$ LANGUAGE plpgsql;

-- 5.1 # Assertion: is there an increase in products ?

CREATE OR REPLACE FUNCTION test_that_product_number_increase_after_weekly_fda_update()
RETURNS SETOF TEXT
AS $$
DECLARE
  new_num integer;
  old_num integer;
BEGIN
  SELECT num_products into new_num FROM update_log_fda
  WHERE num_products IS NOT NULL
  ORDER BY id DESC LIMIT 1;

  SELECT num_products into old_num FROM update_log_fda
  WHERE num_products IS NOT NULL AND id != (SELECT id FROM update_log_fda WHERE num_products IS NOT NULL ORDER BY id DESC LIMIT 1)
  ORDER BY id DESC LIMIT 1;

  return next ok(new_num > old_num, 'The number of products has increased from latest update!');

END;
$$ LANGUAGE plpgsql;

-- 5.2 # Assertion: is there an increase in patents ?

CREATE OR REPLACE FUNCTION test_that_patent_number_increase_after_weekly_fda_update()
RETURNS SETOF TEXT
AS $$
DECLARE
  new_num integer;
  old_num integer;
BEGIN
  SELECT num_patent into new_num FROM update_log_fda
  WHERE num_patent IS NOT NULL
  ORDER BY id DESC LIMIT 1;

  SELECT num_patent into old_num FROM update_log_fda
  WHERE num_patent IS NOT NULL AND id != (SELECT id FROM update_log_fda WHERE num_patent IS NOT NULL ORDER BY id DESC LIMIT 1)
  ORDER BY id DESC LIMIT 1;

  return next ok(new_num > old_num, 'The number of patents has increased from latest update!');

END;
$$ LANGUAGE plpgsql;

-- 5.3 # Assertion: is there an increase in fda_exclusivities ?

CREATE OR REPLACE FUNCTION test_that_exclusivity_number_increase_after_weekly_fda_update()
RETURNS SETOF TEXT
AS $$
DECLARE
  new_num integer;
  old_num integer;
BEGIN
  SELECT num_exclusivity into new_num FROM update_log_fda
  WHERE num_exclusivity IS NOT NULL
  ORDER BY id DESC LIMIT 1;

  SELECT num_exclusivity into old_num FROM update_log_fda
  WHERE num_exclusivity IS NOT NULL AND id != (SELECT id FROM update_log_fda WHERE num_exclusivity IS NOT NULL ORDER BY id DESC LIMIT 1)
  ORDER BY id DESC LIMIT 1;

  return next ok(new_num > old_num, 'The number of exclusivities has increased from latest update!');

END;
$$ LANGUAGE plpgsql;

-- Run functions
-- Start transaction and plan the tests.

BEGIN;
SELECT plan(:TOTAL_NUM_ASSERTIONS);
select test_that_all_fda_tables_exist();
select test_that_all_fda_tables_have_pk();
select test_that_fda_tablespace_exists();
select test_that_there_is_no_100_percent_NULL_column_in_fda_tables();
select test_that_products_number_increase_after_weekly_fda_update();
select test_that_patent_number_increase_after_weekly_fda_update();
select test_that_exclusivity_number_increase_after_weekly_fda_update();
SELECT pass( 'My test passed!');
select * from finish();
ROLLBACK;

\echo 'Testing process is over!'

-- END OF SCRIPT
