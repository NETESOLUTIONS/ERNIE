/*
 Title: Scopus-update TAP-test
 Author: Djamil Lakhdar-Hamina
 Date: 07/23/2019
 Purpose: Develop a TAP protocol to test if the scopus_update parser is behaving as intended.
 TAP protocol specifies that you determine a set of assertions with binary-semantics. The assertion is evaluated either true or false.
 The evaluation should allow the client or user to understand what the problem is and to serve as a guide for diagnostics.

 The assertions to test are:
 1. do expected tables exist
 2. do all tables have at least a UNIQUE INDEX
 3. do any of the tables have columns that are 100% NULL
 4. for various tables was there an increase (based on a threshold of minimum record)
*/

-- \timing
\set ON_ERROR_STOP on
\set MIN_NUM_OF_RECORDS 3
\set MIN_YEARLY_DIFFERENCE 0
\set ECHO all

-- public has to be used in search_path to find pgTAP routines
SET search_path = public;
SET script.module_name = :'module_name';

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
              AND table_name LIKE 'script.module_name%'
        )
            LOOP
                EXECUTE format('ANALYZE VERBOSE %I;', tab.table_name);
            END LOOP;
    END
$block$;

-- BEGIN;
-- SELECT *
-- FROM no_plan();
--
-- -- region all fda tables exist
-- SELECT has_table('fda_patents');
-- SELECT has_table('fda_exclusivities');
-- SELECT has_table('fda_products');
-- SELECT has_table('fda_purple_book');
-- -- endregion
--
-- --region every table should have at least a UNIQUE INDEX
-- SELECT is_empty($$
--  SELECT current_schema || '.' || tablename
--   FROM pg_catalog.pg_tables tbls
--  WHERE schemaname= current_schema AND tablename LIKE 'fda%'
--    AND NOT EXISTS(SELECT *
--                     FROM pg_indexes idx
--                    WHERE idx.schemaname = current_schema
--                      AND idx.tablename = tbls.tablename
--                      and idx.indexdef like 'CREATE UNIQUE INDEX%')$$,
--                 'All FDA tables should have at least a UNIQUE INDEX');
-- -- endregion
--
-- -- region are any tables completely null for every field
-- SELECT is_empty($$
--   SELECT current_schema || '.' || tablename || '.' || attname AS not_populated_column
--     FROM pg_stats
--   WHERE schemaname = current_schema AND tablename LIKE 'fda%' AND null_frac = 1$$,
--                 'All FDA table columns should be populated (not 100% NULL)');
-- -- endregion
--
-- -- region are all tables populated
-- WITH cte AS (
--     SELECT parent_pc.relname, sum(coalesce(partition_pc.reltuples, parent_pc.reltuples)) AS total_rows
--     FROM pg_class parent_pc
--              JOIN pg_namespace pn ON pn.oid = parent_pc.relnamespace AND pn.nspname = current_schema
--              LEFT JOIN pg_inherits pi ON pi.inhparent = parent_pc.oid
--              LEFT JOIN pg_class partition_pc ON partition_pc.oid = pi.inhrelid
--     WHERE parent_pc.relname LIKE 'fda%'
--       AND parent_pc.relkind IN ('r', 'p')
--       AND NOT parent_pc.relispartition
--     GROUP BY parent_pc.oid, parent_pc.relname
-- )
-- SELECT cmp_ok(CAST(cte.total_rows AS BIGINT), '>=', CAST(:MIN_NUM_OF_RECORDS AS BIGINT),
--               format('%s.%s table should have at least %s record%s', current_schema, cte.relname, :MIN_NUM_OF_RECORDS,
--                      CASE WHEN :MIN_NUM_OF_RECORDS > 1 THEN 's' ELSE '' END))
-- FROM cte;
-- -- endregion
--
-- -- region is there a decrease in patents
-- WITH cte AS (
--     SELECT num_patent, lead(num_patent, 1, 0) OVER (ORDER BY id DESC) AS prev_num_patent
--     FROM update_log_fda
--     WHERE num_patent IS NOT NULL
--     ORDER BY id DESC
--     LIMIT 1
-- )
-- SELECT cmp_ok(cte.num_patent, '>=', cte.prev_num_patent,
--               'The number of FDA records on patents should not decrease after an update')
-- FROM cte;
-- -- endregion
--
-- --region is there a decrease in products
-- WITH cte AS (
--     SELECT num_products, lead(num_products, 1, 0) OVER (ORDER BY id DESC) AS prev_num_products
--     FROM update_log_fda
--     WHERE num_products IS NOT NULL
--     ORDER BY id DESC
--     LIMIT 1
-- )
-- SELECT cmp_ok(cte.num_products, '>=', cte.prev_num_products,
--               'The number of FDA records on products should not decrease after an update')
-- FROM cte;
-- --endregion
--
-- --region is there increase year by year in fda products
-- with cte as (SELECT extract('year' FROM time_series)::int AS approval_year,
--                     coalesce(count(appl_no) - lag(count(appl_no)) over (order by extract('year' FROM time_series)::int),
--                              '0')                         as difference
--              FROM fda_products,
--                   generate_series(
--                           date_trunc('year', to_date(regexp_replace(approval_date, 'Approved Prior to ', '', 'g'),
--                                                      'Mon DD YYYY')),
--                           date_trunc('year', to_date(regexp_replace(approval_date, 'Approved Prior to ', '', 'g'),
--                                                      'Mon DD YYYY')),
--                           interval '1 year') time_series
--              GROUP BY time_series, approval_year
--              ORDER BY approval_year)
-- SELECT cmp_ok(CAST(cte.difference as BIGINT), '>=',
--               CAST(:MIN_YEARLY_DIFFERENCE as BIGINT),
--               format('%s.tables should increase at least %s record', 'FDA', :MIN_YEARLY_DIFFERENCE))
-- from cte;
-- -- endregion
--
--
-- SELECT *
-- FROM finish();
-- ROLLBACK;
--
-- -- END OF SCRIPT
