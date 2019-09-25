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
                      JOIN scopus_publications sp ON sr.ref_sgr = sp.scp
             WHERE sr.scp = :'pub_id'
         ),
              citing_cte AS (
                  SELECT sr.scp AS ij_set
                  FROM scopus_references sr
                  WHERE sr.ref_sgr = :'pub_id'
              ),
              cites_cited AS (
                  SELECT sr.scp AS k_set, count(sr.scp) AS count
                  FROM scopus_references sr
                           INNER JOIN cited_cte b ON sr.ref_sgr = b.fp_cited
                  WHERE sr.scp <> :'pub_id'
                  GROUP BY sr.scp
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
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count = 1
                ) AS k1_1,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count = 2
                ) AS k2_1,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count = 3
                ) AS k3_1,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count = 4
                ) AS k4_1,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count = 5
                ) AS k5_1,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count = 6
                ) AS k6_1,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count = 7
                ) AS k7_1,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count = 8
                ) AS k8_1,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count = 9
                ) AS k9_1,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count = 10
                ) AS k10_1,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count = 11
                ) AS k11_1,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count >= 1
                ) AS k1_2,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count >= 2
                ) AS k2_2,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count >= 3
                ) AS k3_2,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count >= 4
                ) AS k4_2,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count >= 5
                ) AS k5_2,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count >= 6
                ) AS k6_2,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count >= 7
                ) AS k7_2,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count >= 8
                ) AS k8_2,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count >= 9
                ) AS k9_2,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count >= 10
                ) AS k10_2,
                (
                    SELECT count(1)
                    FROM cites_cited
                    WHERE k_set NOT IN (
                        SELECT ij_set
                        FROM citing_cte
                    )
                      AND count >= 11
                ) AS k11_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count = 1
                    )
                ) AS j1_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count = 2
                    )
                ) AS j2_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count = 3
                    )
                ) AS j3_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count = 4
                    )
                ) AS j4_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count = 5
                    )
                ) AS j5_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count = 6
                    )
                ) AS j6_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count = 7
                    )
                ) AS j7_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count = 8
                    )
                ) AS j8_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count = 9
                    )
                ) AS j9_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count = 10
                    )
                ) AS j10_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count = 11
                    )
                ) AS j11_1,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count >= 1
                    )
                ) AS j1_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count >= 2
                    )
                ) AS j2_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count >= 3
                    )
                ) AS j3_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count >= 4
                    )
                ) AS j4_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count >= 5
                    )
                ) AS j5_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count >= 6
                    )
                ) AS j6_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count >= 7
                    )
                ) AS j7_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count >= 8
                    )
                ) AS j8_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count >= 9
                    )
                ) AS j9_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count >= 10
                    )
                ) AS j10_2,
                (
                    SELECT count(1)
                    FROM citing_cte
                    WHERE ij_set IN (
                        SELECT k_set
                        FROM cites_cited
                        WHERE count >= 11
                    )
                ) AS j11_2
     ) sq;