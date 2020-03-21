\set ON_ERROR_STOP on
-- \set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE PROCEDURE theta_omega_calculations_main_table(pair_1 bigint, pair_2 bigint, first_cited_year smallint)
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO cc2.theta_omega_delta_results
    WITH co_cited_list AS (
        SELECT scp
        FROM public.scopus_references sr
        WHERE ref_sgr IN (pair_1, pair_2)
        GROUP BY scp
        HAVING count(ref_sgr) = 2
    ),
         cited_1 AS (
             SELECT scp
             FROM public.scopus_references sr
                      JOIN public.scopus_publication_groups sgr
                           ON sr.scp = sgr.sgr
             WHERE ref_sgr = pair_1
               AND pub_year <= first_cited_year
               AND scp NOT IN (SELECT * FROM co_cited_list)
         ),
         cited_2 AS (
             SELECT scp
             FROM public.scopus_references sr
                      JOIN public.scopus_publication_groups sgr
                           ON sr.scp = sgr.sgr
             WHERE ref_sgr = pair_2
               AND pub_year <= first_cited_year
               AND scp NOT IN (SELECT * FROM co_cited_list)
         ),
         edges_a_b AS (
             SELECT scp
             FROM public.scopus_references
             WHERE ref_sgr IN (SELECT * FROM cited_2)
               AND scp IN (SELECT * FROM cited_1)
         ),
         edges_b_a AS (
             SELECT scp
             FROM public.scopus_references
             WHERE ref_sgr IN (SELECT * FROM cited_1)
               AND scp IN (SELECT * FROM cited_2)
         )
    SELECT pair_1,
           pair_2,
           (SELECT count(*) FROM cited_1)   AS N_a,
           (SELECT count(*) FROM cited_2)   AS N_b,
           (SELECT count(*) FROM edges_a_b) AS edges_a_b,
           (SELECT count(*) FROM edges_b_a) AS edges_b_a;
END;


$$;