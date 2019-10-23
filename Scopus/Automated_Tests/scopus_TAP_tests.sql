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

-- This could be schema-dependent
\set MIN_NUM_OF_RECORDS 5
\set MIN_YEARLY_DIFFERENCE -50000

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
              AND table_name LIKE 'scopus%'
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

-- region all tables should have at least a UNIQUE INDEX
SELECT is_empty($$
 SELECT current_schema || '.' || tablename
  FROM pg_catalog.pg_tables tbls
 WHERE schemaname= current_schema AND tablename LIKE 'scopus_%'
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
  WHERE schemaname = current_schema AND tablename LIKE 'scopus%' AND null_frac = 1$$,
                'All Scopus table columns should be populated (not 100% NULL)');
-- endregion

-- region are all tables populated
WITH cte AS (
    SELECT parent_pc.relname, sum(coalesce(partition_pc.reltuples, parent_pc.reltuples)) AS total_rows
    FROM pg_class parent_pc
             JOIN pg_namespace pn ON pn.oid = parent_pc.relnamespace AND pn.nspname = current_schema
             LEFT JOIN pg_inherits pi ON pi.inhparent = parent_pc.oid
             LEFT JOIN pg_class partition_pc ON partition_pc.oid = pi.inhrelid
    WHERE parent_pc.relname LIKE 'scopus%'
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
              'The number of Scopus records should not decrease after an update')
FROM cte;
-- endregion

--region is there increase year by year in scopus pubs
WITH cte AS (SELECT extract('year' FROM time_series)::int                                                             AS pub_year,
                    coalesce(count(sgr) - lag(count(sgr)) over (order by extract('year' FROM time_series)::int),
                             '0')                                                                                     as difference -- difference between count year 2 and year 1
             FROM scopus_publication_groups,
                  generate_series(to_date(pub_year::text, 'YYYY')::timestamp,
                                  to_date(pub_year::text, 'YYYY')::timestamp,
                                  interval '1 year') time_series
             WHERE pub_year >= '1930'
               and pub_year <= '2019'
             GROUP BY time_series, pub_year
             ORDER BY pub_year)
SELECT cmp_ok(CAST(cte.difference as BIGINT), '>=',
              CAST(:MIN_YEARLY_DIFFERENCE as BIGINT),
              format('%s.tables should increase at least %s record', 'FDA', :MIN_YEARLY_DIFFERENCE))
from cte;
--endregion

SELECT *
FROM finish();
ROLLBACK;
