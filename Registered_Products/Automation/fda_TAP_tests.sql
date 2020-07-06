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
\set ECHO all

-- public has to be used in search_path to find pgTAP routines
SET search_path = public;

--DO blocks don't accept any parameters. In order to pass a parameter, use a custom session variable AND current_settings
-- https://github.com/NETESOLUTIONS/tech/wiki/Postgres-Recipes#Passing_psql_variables_to_DO_blocks
--for more:https://stackoverflow.com/questions/24073632/passing-argument-to-a-psql-procedural-script
set script.module_name = :'module_name';


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
              AND table_name LIKE current_setting('script.module_name') || '%'
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
SELECT has_table(:'module_name' || '_patents');
SELECT has_table(:'module_name' || '_exclusivities');
SELECT has_table(:'module_name' || '_products');
SELECT has_table(:'module_name' || '_purple_book');
-- endregion

--region every table should have at least a UNIQUE INDEX
SELECT is_empty($$
 SELECT current_schema || '.' || tablename
  FROM pg_catalog.pg_tables tbls
 WHERE schemaname= current_schema AND tablename LIKE current_setting('script.module_name') || '%'
   AND NOT EXISTS(SELECT *
                    FROM pg_indexes idx
                   WHERE idx.schemaname = current_schema
                     AND idx.tablename = tbls.tablename
                     and idx.indexdef like 'CREATE UNIQUE INDEX%')$$,
                'All FDA tables should have at least a UNIQUE INDEX');
-- endregion

-- region are any tables completely null for every field
SELECT is_empty($$
  SELECT current_schema || '.' || tablename || '.' || attname AS not_populated_column
    FROM pg_stats
  WHERE schemaname = current_schema AND tablename LIKE current_setting('script.module_name') || '%' AND null_frac = 1$$,
                'All FDA table columns should be populated (not 100% NULL)');
-- endregion

-- region are all tables populated
WITH cte AS (
    SELECT parent_pc.relname, sum(coalesce(partition_pc.reltuples, parent_pc.reltuples)) AS total_rows
    FROM pg_class parent_pc
             JOIN pg_namespace pn ON pn.oid = parent_pc.relnamespace AND pn.nspname = current_schema
             LEFT JOIN pg_inherits pi ON pi.inhparent = parent_pc.oid
             LEFT JOIN pg_class partition_pc ON partition_pc.oid = pi.inhrelid
    WHERE parent_pc.relname LIKE :'module_name' || '%'
      AND parent_pc.relkind IN ('r', 'p')
      AND NOT parent_pc.relispartition
    GROUP BY parent_pc.oid, parent_pc.relname
)
SELECT cmp_ok(CAST(cte.total_rows AS BIGINT), '>=', CAST(:min_num_of_records AS BIGINT),
              format('%s.%s table should have at least %s record%s', current_schema, cte.relname, :min_num_of_records,
                     CASE WHEN :min_num_of_records > 1 THEN 's' ELSE '' END))
FROM cte;
-- endregion

--region show update log for patent
SELECT id, num_patent, last_updated
FROM update_log_:module_name
WHERE num_patent IS NOT NULL
ORDER BY id DESC
LIMIT 10;
--endregion

-- region is there a decrease in patents
WITH cte AS (
    SELECT num_patent, lead(num_patent, 1, 0) OVER (ORDER BY id DESC) AS prev_num_patent
    FROM update_log_:module_name
    WHERE num_patent IS NOT NULL
    ORDER BY id DESC
    LIMIT 1
)
SELECT cmp_ok(cte.num_patent, '>=', cte.prev_num_patent,
              'The number of FDA records on patents should not decrease after an update')
FROM cte;
-- endregion

--region show update log for products
SELECT id, num_products, last_updated
FROM update_log_:module_name
WHERE num_products IS NOT NULL
ORDER BY id DESC
LIMIT 10;
--endregion

--region is there a decrease in products
WITH cte AS (
    SELECT num_products, lead(num_products, 1, 0) OVER (ORDER BY id DESC) AS prev_num_products
    FROM update_log_:module_name
    WHERE num_products IS NOT NULL
    ORDER BY id DESC
    LIMIT 1
)
SELECT cmp_ok(cte.num_products, '>=', cte.prev_num_products,
              'The number of FDA records on products should not decrease after an update')
FROM cte;
--endregion

--region show differences between consecutive years
SELECT extract('year' FROM time_series)::int AS approval_year,
       count(appl_no)                        as product_count,
       coalesce(count(appl_no) - lag(count(appl_no)) over (order by extract('year' FROM time_series)::int),
                '0')                         as difference,
       coalesce(round(100.0*(count(appl_no) - lag(count(appl_no)) over (order by extract('year' FROM time_series)::int))/lag(count(appl_no)) over (order by extract('year' FROM time_series)::int),2),
                             '0')                         as percent_difference
FROM fda_products,
     generate_series(
             date_trunc('year', to_date(regexp_replace(approval_date, 'Approved Prior to ', '', 'g'),
                                        'Mon DD YYYY')),
             date_trunc('year', to_date(regexp_replace(approval_date, 'Approved Prior to ', '', 'g'),
                                        'Mon DD YYYY')),
             interval '1 year') time_series
GROUP BY time_series, approval_year
ORDER BY approval_year;
--endregion

--region is there increase year by year in fda products
with cte as (SELECT extract('year' FROM time_series)::int AS approval_year,
            count(appl_no)                        as product_count,
            coalesce(count(appl_no) - lag(count(appl_no)) over (order by extract('year' FROM time_series)::int),
                '0')                         as difference,
            coalesce(round(100.0*(count(appl_no) - lag(count(appl_no)) over (order by extract('year' FROM time_series)::int))/lag(count(appl_no)) over (order by extract('year' FROM time_series)::int),2),
                             '0')                         as percent_difference
            FROM fda_products,
                generate_series(
                  date_trunc('year', to_date(regexp_replace(approval_date, 'Approved Prior to ', '', 'g'),
                                        'Mon DD YYYY')),
                  date_trunc('year', to_date(regexp_replace(approval_date, 'Approved Prior to ', '', 'g'),
                                        'Mon DD YYYY')),
                  interval '1 year') time_series
            GROUP BY time_series, approval_year
            ORDER BY approval_year)
            SELECT cmp_ok(CAST(cte.percent_difference as REAL), '>=',
                          CAST(:min_yearly_difference as REAL),
                           format('FDA Products table should increase by at least %s per cent of records year on year', :min_yearly_difference))
from cte;
-- endregion

-- region are there records in the future
SELECT is_empty($$SELECT extract('year' FROM time_series)::int AS approval_year,
                    coalesce(count(appl_no) - lag(count(appl_no)) over (order by extract('year' FROM time_series)::int),
                             '0')                         as difference
             FROM fda_products,
                  generate_series(
                          date_trunc('year', to_date(regexp_replace(approval_date, 'Approved Prior to ', '', 'g'),
                                                     'Mon DD YYYY')),
                          date_trunc('year', to_date(regexp_replace(approval_date, 'Approved Prior to ', '', 'g'),
                                                     'Mon DD YYYY')),
                          interval '1 year') time_series
             WHERE time_series::date > date_trunc('year', current_date)::date
             GROUP BY time_series, approval_year
             ORDER BY approval_year;$$, 'There should be no FDA records two years from present');
-- endregion


SELECT *
FROM finish();
ROLLBACK;

--END OF SCRIPT
