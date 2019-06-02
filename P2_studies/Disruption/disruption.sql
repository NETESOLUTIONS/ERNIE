\set ON_ERROR_STOP on
-- \set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- Assuming there are no double references
SELECT :'pub_id' AS focal_paper_id, sq.*, CAST(sq.i - sq.j AS FLOAT) / (sq.i + sq.j + sq.k) AS disruption
FROM (
       WITH cited_cte AS (
         SELECT cited_source_uid AS fp_cited
         FROM wos_references
         WHERE source_id = :'pub_id'
       ),
            citing_cte AS (
              SELECT source_id AS ij_set
              FROM wos_references
              WHERE cited_source_uid = :'pub_id'
            ),
            cites_cited AS (
              SELECT a.source_id AS k_set, count(a.source_id) AS count
              FROM wos_references a
                     JOIN cited_cte b ON a.cited_source_uid = b.fp_cited
              WHERE a.source_id <> :'pub_id'
              GROUP BY a.source_id
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
              ) AS j,
              (
                SELECT count(1)
                FROM citing_cte
                WHERE ij_set IN (
                  SELECT k_set
                  FROM cites_cited
                  WHERE count = 1
                )
              ) AS j1,
              (
                SELECT count(1)
                FROM citing_cte
                WHERE ij_set IN (
                  SELECT k_set
                  FROM cites_cited
                  WHERE count = 2
                )
              ) AS j2,
              (
                SELECT count(1)
                FROM citing_cte
                WHERE ij_set IN (
                  SELECT k_set
                  FROM cites_cited
                  WHERE count = 3
                )
              ) AS j3,
              (
                SELECT count(1)
                FROM citing_cte
                WHERE ij_set IN (
                  SELECT k_set
                  FROM cites_cited
                  WHERE count = 4
                )
              ) AS j4,
              (
                SELECT count(1)
                FROM citing_cte
                WHERE ij_set IN (
                  SELECT k_set
                  FROM cites_cited
                  WHERE count = 5
                )
              ) AS j5,
              (
                SELECT count(1)
                FROM citing_cte
                WHERE ij_set IN (
                  SELECT k_set
                  FROM cites_cited
                  WHERE count = 6
                )
              ) AS j6,
              (
                SELECT count(1)
                FROM citing_cte
                WHERE ij_set IN (
                  SELECT k_set
                  FROM cites_cited
                  WHERE count = 7
                )
              ) AS j7,
              (
                SELECT count(1)
                FROM citing_cte
                WHERE ij_set IN (
                  SELECT k_set
                  FROM cites_cited
                  WHERE count = 8
                )
              ) AS j8,
              (
                SELECT count(1)
                FROM citing_cte
                WHERE ij_set IN (
                  SELECT k_set
                  FROM cites_cited
                  WHERE count = 9
                )
              ) AS j9,
              (
                SELECT count(1)
                FROM citing_cte
                WHERE ij_set IN (
                  SELECT k_set
                  FROM cites_cited
                  WHERE count = 10
                )
              ) AS j10,
              (
                SELECT count(1)
                FROM citing_cte
                WHERE ij_set IN (
                  SELECT k_set
                  FROM cites_cited
                  WHERE count = 11
                )
              ) AS j11,
              (
                SELECT count(1)
                FROM cites_cited
                WHERE k_set NOT IN (
                  SELECT ij_set
                  FROM citing_cte
                )
              ) AS k
     ) sq
WHERE sq.j > 0
  AND sq.k > 0;
-- 10.8s-34.7s (cold-ish)
