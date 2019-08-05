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
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                    )
                ) AS orig_j,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                ) AS orig_k,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name)
                ) AS new_j,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count = 1)
                ) AS new_j1_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count = 2)
                ) AS new_j2_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count = 3)
                ) AS new_j3_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count = 4)
                ) AS new_j4_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count = 5)
                ) AS new_j5_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count = 6)
                ) AS new_j6_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count = 7)
                ) AS new_j7_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count = 8)
                ) AS new_j8_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count = 9)
                ) AS new_j9_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count = 10)
                ) AS new_j10_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count = 11)
                ) AS new_j11_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count >= 1)
                ) AS new_j1_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count >= 2)
                ) AS new_j2_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count >= 3)
                ) AS new_j3_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count >= 4)
                ) AS new_j4_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count >= 5)
                ) AS new_j5_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count >= 6)
                ) AS new_j6_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count >= 7)
                ) AS new_j7_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count >= 8)
                ) AS new_j8_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count >= 9)
                ) AS new_j9_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count >= 10)
                ) AS new_j10_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (SELECT scp FROM :table_name WHERE count >= 11)
                ) AS new_j11_2,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                ) AS new_k,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count = 1
                ) AS new_k1_1,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count = 2
                ) AS new_k2_1,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count = 3
                ) AS new_k3_1,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count = 4
                ) AS new_k4_1,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count = 5
                ) AS new_k5_1,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count = 6
                ) AS new_k6_1,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count = 7
                ) AS new_k7_1,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count = 8
                ) AS new_k8_1,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count = 9
                ) AS new_k9_1,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count = 10
                ) AS new_k10_1,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count = 11
                ) AS new_k11_1,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count >= 1
                ) AS new_k1_2,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count >= 2
                ) AS new_k2_2,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count >= 3
                ) AS new_k3_2,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count >= 4
                ) AS new_k4_2,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count >= 5
                ) AS new_k5_2,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count >= 6
                ) AS new_k6_2,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count >= 7
                ) AS new_k7_2,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count >= 8
                ) AS new_k8_2,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count >= 9
                ) AS new_k9_2,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count >= 10
                ) AS new_k10_2,
                (
                    SELECT count(1)
                    FROM :table_name
                    WHERE scp NOT IN (SELECT ij_set
                                      FROM citing_cte)
                      AND count >= 11
                ) AS new_k11_2
     ) sq;