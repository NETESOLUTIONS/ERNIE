
\set ON_ERROR_STOP on
-- \set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path to public;


SELECT :'pub_id' AS focal_paper_id, sq.*
FROM (
         WITH cited_cte AS (
             SELECT sr.ref_sgr AS fp_cited
             FROM scopus_references sr
             WHERE sr.scp = :'pub_id'
         ),
              citing_cte AS (
                  SELECT sr.scp AS ij_set
                  FROM scopus_references sr
                  WHERE sr.ref_sgr = :'pub_id'
              ),
              cites_cited AS (
                  SELECT DISTINCT sr.scp AS k_set
                  FROM scopus_references sr
                           INNER JOIN cited_cte b ON sr.ref_sgr = b.fp_cited
                  WHERE sr.scp <> :'pub_id'
              )
         SELECT (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set NOT IN (
                        SELECT k_set
                        FROM cites_cited
                    )
                ) AS i,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set NOT IN (
                        SELECT scp
                        FROM :table_name
                    )
                ) AS new_i
     ) sq;