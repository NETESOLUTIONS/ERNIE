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

\set ON_ERROR_STOP on
\set ECHO all
\set MIN_NUM_OF_RECORDS 2

-- public has to be used in search_path to find pgTAP routines
SET search_path = public;

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

DO
$block$
    DECLARE
        tab RECORD;
    BEGIN
        FOR tab IN (
            SELECT table_name
            FROM information_schema.tables --
            WHERE table_schema = current_schema
              AND table_name LIKE 'ct_%'
        )
            LOOP
                EXECUTE format('ANALYZE VERBOSE %I;', tab.table_name);
            END LOOP;
    END
$block$;


-- region all ct_ tables exist
SELECT has_table('ct_clinical_studies');
SELECT has_table('ct_arm_groups');
SELECT has_table('ct_collaborators');
SELECT has_table('ct_condition_browses');
SELECT has_table('ct_conditions');
SELECT has_table('ct_expanded_access_info');
SELECT has_table('ct_intervention_arm_group_labels');
SELECT has_table('ct_intervention_browses');
SELECT has_table('ct_intervention_other_names');
SELECT has_table('ct_interventions');
SELECT has_table('ct_keywords');
SELECT has_table('ct_links');
SELECT has_table('ct_location_countries');
SELECT has_table('ct_location_investigators');
SELECT has_table('ct_locations');
SELECT has_table('ct_outcomes');
SELECT has_table('ct_overall_contacts');
SELECT has_table('ct_overall_officials');
SELECT has_table('ct_publications');
SELECT has_table('ct_references');
BEGIN;
SELECT *
FROM no_plan();
SELECT has_table('ct_secondary_ids');
SELECT has_table('ct_study_design_info');-- endregion

-- region all scopus tables have a PK
SELECT is_empty($$
 SELECT current_schema || '.' || table_name
  FROM information_schema.tables t
 WHERE table_schema = current_schema AND table_name LIKE 'ct_%'
   AND NOT EXISTS(SELECT 1
                    FROM information_schema.table_constraints tc
                   WHERE tc.table_schema = current_schema
                     AND tc.table_name = t.table_name
                     AND tc.constraint_type = 'PRIMARY KEY')$$, 'All CT tables should have a PK');
-- endregion

-- region Are any tables completely null for every field
SELECT is_empty($$
  SELECT current_schema || '.' || tablename || '.' || attname AS not_populated_column
    FROM pg_stats
  WHERE schemaname = current_schema AND tablename LIKE 'ct_%' AND null_frac = 1$$,
                'All CT table columns should be populated (not 100% NULL)');
-- endregion


-- region Are all tables populated?
WITH cte AS (
    SELECT parent_pc.relname, sum(coalesce(partition_pc.reltuples, parent_pc.reltuples)) AS total_rows
    FROM pg_class parent_pc
             JOIN pg_namespace pn ON pn.oid = parent_pc.relnamespace AND pn.nspname = current_schema
             LEFT JOIN pg_inherits pi ON pi.inhparent = parent_pc.oid
             LEFT JOIN pg_class partition_pc ON partition_pc.oid = pi.inhrelid
    WHERE parent_pc.relname LIKE 'ct_%'
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
              'The number of CT records should not decrease after an update')
FROM cte;
-- endregion
END;

SELECT *
FROM finish();
ROLLBACK;

-- END OF SCRIPT
