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

-- \timing
\set ON_ERROR_STOP on
\set MIN_NUM_OF_RECORDS 3

SET search_path = :schema,public;

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- Analyze tables

DO
$block$
    DECLARE
        tab RECORD;
    BEGIN
        FOR tab IN (
            SELECT table_name
            FROM information_schema.tables --
            WHERE table_schema = current_schema
              AND table_name LIKE 'fda%'
        )
            LOOP
                EXECUTE format('ANALYZE VERBOSE %I;', tab.table_name);
            END LOOP;
    END
$block$;

BEGIN;
SELECT *
FROM no_plan();

-- region all fda tables exist
SELECT has_table('fda_patents');
SELECT has_table('fda_exclusivities');
SELECT has_table('fda_products');
SELECT has_table('fda_purple_book');
-- endregion

-- region all scopus tables have a PK
SELECT is_empty($$
 SELECT current_schema || '.' || table_name
  FROM information_schema.tables t
 WHERE table_schema = current_schema AND table_name LIKE 'fda%'
   AND NOT EXISTS(SELECT 1
                    FROM information_schema.table_constraints tc
                   WHERE tc.table_schema = current_schema
                     AND tc.table_name = t.table_name
                     AND tc.constraint_type = 'PRIMARY KEY')$$, 'All FDA tables should have a PK');
-- endregion

-- region Are any tables completely null for every field
SELECT is_empty($$
  SELECT current_schema || '.' || tablename || '.' || attname AS not_populated_column
    FROM pg_stats
  WHERE schemaname = current_schema AND tablename LIKE 'fda%' AND null_frac = 1$$,
                'All FDA table columns should be populated (not 100% NULL)');
-- endregion

-- region are all tables populated
WITH cte AS (
    SELECT parent_pc.relname, sum(coalesce(partition_pc.reltuples, parent_pc.reltuples)) AS total_rows
    FROM pg_class parent_pc
             JOIN pg_namespace pn ON pn.oid = parent_pc.relnamespace AND pn.nspname = current_schema
             LEFT JOIN pg_inherits pi ON pi.inhparent = parent_pc.oid
             LEFT JOIN pg_class partition_pc ON partition_pc.oid = pi.inhrelid
    WHERE parent_pc.relname LIKE 'fda%'
      AND parent_pc.relkind IN ('r', 'p')
      AND NOT parent_pc.relispartition
    GROUP BY parent_pc.oid, parent_pc.relname
)
SELECT cmp_ok(CAST(cte.total_rows AS BIGINT), '>=', CAST(:MIN_NUM_OF_RECORDS AS BIGINT),
              format('%s.%s table should have at least %s record%s', current_schema, cte.relname, :MIN_NUM_OF_RECORDS,
                     CASE WHEN :MIN_NUM_OF_RECORDS > 1 THEN 's' ELSE '' END))
FROM cte;
-- endregion

-- region is there a decrease in records
WITH cte AS (
    SELECT num_scopus_pub, lead(num_scopus_pub, 1, 0) OVER (ORDER BY id DESC) AS prev_num_scopus_pub
    FROM update_log_scopus
    WHERE num_scopus_pub IS NOT NULL
    ORDER BY id DESC
    LIMIT 1
)
SELECT cmp_ok(cte.num_scopus_pub, '>=', cte.prev_num_scopus_pub,
              'The number of FDA records should not decrease after an update')
FROM cte;
-- endregion
END;

SELECT *
FROM finish();
ROLLBACK;

-- END OF SCRIPT