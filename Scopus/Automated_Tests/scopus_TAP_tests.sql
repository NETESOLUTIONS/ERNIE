/*
 Title: Scopus TAP tests
 Author: Djamil Lakhdar-Hamina
 Author: Dmitriy "DK" Korobskiy
 Date: 07/11/2019
 Purpose: Develop a TAP protocol to test if the scopus_update parser is behaving as intended.
 TAP protocol specifies that you determine a set of assertions with binary-semantics. The assertion is evaluated either true or false.
 The evaluation should allow the client or user to understand what the problem is and to serve as a guide for diagnostics.

 The assertions to test are:
 1. do expected tables exist
 2. do all tables have at least a UNIQUE INDEX
 3. do any of the tables have columns that are 100% NULL
 4. for various tables was there an increase
 */

-- \timing
\set ON_ERROR_STOP on
\set ECHO all

\if :{?schema}
-- public has to be used in search_path to find pgTAP routines
SET search_path = :schema,public;
\endif

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

-- region all scopus tables exist
SELECT has_table(:'module_name' || '_abstracts');
SELECT has_table(:'module_name' || '_affiliations');
SELECT has_table(:'module_name' || '_authors');
SELECT has_table(:'module_name' || '_author_affiliations');
SELECT has_table(:'module_name' || '_chemical_groups');
SELECT has_table(:'module_name' || '_classes');
SELECT has_table(:'module_name' || '_classification_lookup');
SELECT has_table(:'module_name' || '_conf_editors');
SELECT has_table(:'module_name' || '_conf_proceedings');
SELECT has_table(:'module_name' || '_conference_events');
SELECT has_table(:'module_name' || '_grant_acknowledgments');
SELECT has_table(:'module_name' || '_grants');
SELECT has_table(:'module_name' || '_isbns');
SELECT has_table(:'module_name' || '_issns');
SELECT has_table(:'module_name' || '_keywords');
SELECT has_table(:'module_name' || '_publication_groups');
SELECT has_table(:'module_name' || '_publication_identifiers');
SELECT has_table(:'module_name' || '_publications');
SELECT has_table(:'module_name' || '_references');
SELECT has_table(:'module_name' || '_source_publication_details');
SELECT has_table(:'module_name' || '_sources');
SELECT has_table(:'module_name' || '_subject_keywords');
SELECT has_table(:'module_name' || '_subjects');
SELECT has_table(:'module_name' || '_titles');
-- endregion

-- region all tables should have at least a UNIQUE INDEX
SELECT is_empty($$
 SELECT current_schema || '.' || tablename
  FROM pg_catalog.pg_tables tbls
 WHERE schemaname= current_schema AND tablename LIKE current_setting('script.module_name') || '%'
   AND NOT EXISTS(SELECT *
                    FROM pg_indexes idx
                   WHERE idx.schemaname = current_schema
                     AND idx.tablename = tbls.tablename
                     and idx.indexdef like 'CREATE UNIQUE INDEX%')$$,
                'All Scopus tables should have at least a UNIQUE INDEX');
-- endregion

-- region are any tables completely null for every field
SELECT is_empty($$
  SELECT current_schema || '.' || tablename || '.' || attname AS not_populated_column
    FROM pg_stats
  WHERE schemaname = current_schema AND tablename LIKE current_setting('script.module_name') || '%' AND null_frac = 1$$,
                'All Scopus table columns should be populated (not 100% NULL)');
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

--region check update log
SELECT id, num_scopus_pub, update_time
FROM update_log_:module_name
WHERE num_scopus_pub IS NOT NULL
ORDER BY id DESC
LIMIT 10;
--endregiom

-- region is there a decrease in records
WITH cte AS (
    SELECT num_scopus_pub, lead(num_scopus_pub, 1, 0) OVER (ORDER BY id DESC) AS prev_num_scopus_pub
    FROM update_log_:module_name
    WHERE num_scopus_pub IS NOT NULL
    ORDER BY id DESC
    LIMIT 1
)
SELECT cmp_ok(cte.num_scopus_pub, '>=', cte.prev_num_scopus_pub,
              'The number of Scopus records should not decrease after an update')
FROM cte;
-- endregion

--region check number of pubs per year 
SELECT extract('year' FROM time_series)::int AS pub_year,
       count(sgr)                            as pub_count,
       coalesce(count(sgr) - lag(count(sgr)) over (order by extract('year' FROM time_series)::int),
                '0')                         as difference -- difference between count year 2 and year 1
FROM scopus_publication_groups,
     generate_series(to_date(pub_year::text, 'YYYY')::timestamp,
                     to_date(pub_year::text, 'YYYY')::timestamp,
                     interval '1 year') time_series
WHERE pub_year >= '1930'
  and pub_year <= '2019'
GROUP BY time_series, pub_year
ORDER BY pub_year;
--endregion 

--region is there increase year by year in scopus pubs
WITH cte AS (SELECT extract('year' FROM time_series)::int AS pub_year,
                    coalesce(count(sgr) - lag(count(sgr)) over (order by extract('year' FROM time_series)::int),
                             '0')                         as difference -- difference between count year 2 and year 1
             FROM scopus_publication_groups,
                  generate_series(to_date(pub_year::text, 'YYYY')::timestamp,
                                  to_date(pub_year::text, 'YYYY')::timestamp,
                                  interval '1 year') time_series
             WHERE pub_year >= '1930'
               and pub_year <= '2019'
             GROUP BY time_series, pub_year
             ORDER BY pub_year)
SELECT cmp_ok(CAST(cte.difference as BIGINT), '>=',
              CAST(:min_yearly_difference as BIGINT),
              format('%s.tables should increase at least %s record', 'FDA', :min_yearly_difference))
from cte;
--endregion

-- region are there records in the future
select is_empty($$SELECT extract('year' FROM time_series)::int AS pub_year,
       count(sgr)                            as pub_count,
       coalesce(count(sgr) - lag(count(sgr)) over (order by extract('year' FROM time_series)::int),
                '0')                         as difference -- difference between count year 2 and year 1
FROM scopus_publication_groups,
     generate_series(to_date(pub_year::text, 'YYYY')::timestamp,
                     to_date(pub_year::text, 'YYYY')::timestamp,
                     interval '1 year') time_series
WHERE pub_year >= '2021'
GROUP BY time_series, pub_year
ORDER BY pub_year;$$,'There should be no Scopus records two years from present');
-- endregion


SELECT *
FROM finish();
ROLLBACK;

--END OF SCRIPT