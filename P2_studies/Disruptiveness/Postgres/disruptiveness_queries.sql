-- Single focal paper query, simplified
--@formatter:off
SELECT sq.*, CAST(sq.i - sq.j AS FLOAT) / (sq.i + sq.j + sq.k) AS disruption
FROM (
  WITH
  cited_cte AS (
    SELECT cited_source_uid AS fp_cited
    FROM wos_references
    WHERE source_id = :pub_id
  ),
  citing_cte AS (
    SELECT source_id AS ij_set
    FROM wos_references
    WHERE cited_source_uid = :pub_id
  ),
  cites_cited AS (
    SELECT DISTINCT a.source_id AS k_set
    FROM wos_references a
    JOIN cited_cte b ON a.cited_source_uid = b.fp_cited
    WHERE a.source_id <> :pub_id
  )
  SELECT
    (
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
      FROM cites_cited
      WHERE k_set NOT IN (
        SELECT ij_set
        FROM citing_cte
      )
    ) AS k
) sq;
--@formatter:on
-- 676,811,11714
-- 7.2s
-- 0.1s (warm)

-- Query with an input table
--@formatter:off
SELECT sq.*, CAST(sq.i - sq.j AS FLOAT) / (sq.i + sq.j + sq.k) AS disruption
FROM (
  WITH
  focal_papers_cte AS (
    SELECT wps.source_id AS fp_id
    FROM wos_publication_stats wps
  ),
  cited_cte AS (
    SELECT focal_papers_cte.fp_id, cited_source_uid AS fp_cited
    FROM wos_references wr
    JOIN focal_papers_cte ON wr.source_id = focal_papers_cte.fp_id
  ),
  citing_cte AS (
    SELECT focal_papers_cte.fp_id, wr.source_id AS ij_set
    FROM wos_references wr
    JOIN focal_papers_cte ON wr.cited_source_uid = focal_papers_cte.fp_id
  ),
  cites_cited AS (
    SELECT DISTINCT cited_cte.fp_id, wr.source_id AS k_set
    FROM cited_cte
    JOIN wos_references wr ON wr.cited_source_uid = cited_cte.fp_cited
    WHERE wr.source_id <> cited_cte.fp_id
  )
  SELECT
    focal_papers_cte.fp_id,
    (
      SELECT count(1)
      FROM citing_cte
      WHERE fp_id = focal_papers_cte.fp_id
      AND ij_set NOT IN (
        SELECT k_set
        FROM cites_cited
        WHERE fp_id = focal_papers_cte.fp_id
      )
    ) AS i,
    (
      SELECT count(1)
      FROM citing_cte
      WHERE fp_id = focal_papers_cte.fp_id
      AND ij_set IN (
        SELECT k_set
        FROM cites_cited
        WHERE fp_id = focal_papers_cte.fp_id
      )
    ) AS j,
    (
      SELECT count(1)
      FROM cites_cited
      WHERE fp_id = focal_papers_cte.fp_id
      AND k_set NOT IN (
        SELECT ij_set
        FROM citing_cte
        WHERE fp_id = focal_papers_cte.fp_id
      )
    ) AS k
  FROM focal_papers_cte
) sq;
--@formatter:on
-- *runaway*

-- Query with a one-row focal papers CTE
--@formatter:off
SELECT sq.*, CAST(sq.i - sq.j AS FLOAT) / (sq.i + sq.j + sq.k) AS disruption
FROM (
  WITH
  focal_papers_cte AS (
    SELECT CAST(:pub_id AS TEXT) AS fp_id
  ),
  cited_cte AS (
    SELECT focal_papers_cte.fp_id, cited_source_uid AS fp_cited
    FROM wos_references wr
    JOIN focal_papers_cte ON wr.source_id = focal_papers_cte.fp_id
  ),
  citing_cte AS (
    SELECT focal_papers_cte.fp_id, wr.source_id AS ij_set
    FROM wos_references wr
    JOIN focal_papers_cte ON wr.cited_source_uid = focal_papers_cte.fp_id
  ),
  cites_cited AS (
    SELECT DISTINCT cited_cte.fp_id, wr.source_id AS k_set
    FROM cited_cte
    JOIN wos_references wr ON wr.cited_source_uid = cited_cte.fp_cited
    WHERE wr.source_id <> cited_cte.fp_id
  )
  SELECT
    focal_papers_cte.fp_id,
    (
      SELECT count(1)
      FROM citing_cte
      WHERE fp_id = focal_papers_cte.fp_id
      AND ij_set NOT IN (
        SELECT k_set
        FROM cites_cited
        WHERE fp_id = focal_papers_cte.fp_id
      )
    ) AS i,
    (
      SELECT count(1)
      FROM citing_cte
      WHERE fp_id = focal_papers_cte.fp_id
      AND ij_set IN (
        SELECT k_set
        FROM cites_cited
        WHERE fp_id = focal_papers_cte.fp_id
      )
    ) AS j,
    (
      SELECT count(1)
      FROM cites_cited
      WHERE fp_id = focal_papers_cte.fp_id
      AND k_set NOT IN (
        SELECT ij_set
        FROM citing_cte
        WHERE fp_id = focal_papers_cte.fp_id
      )
    ) AS k
  FROM focal_papers_cte
) sq;
--@formatter:on
-- 676,811,11714
-- 2.9s (coldish)
-- 0.1s (warm)

-- Single focal paper query
SELECT
  i_j_sq.*,
  (j_plus_k_sq.j_plus_k - i_j_sq.j) AS k,
  CAST(i_j_sq.i - i_j_sq.j AS FLOAT) / (i_j_sq.i + j_plus_k_sq.j_plus_k) AS disruption
FROM (
       SELECT
         sum(CASE
               WHEN NOT EXISTS(SELECT 1
                               FROM wos_references wr
                               JOIN wos_references focal_cited_wr
                                    ON focal_cited_wr.source_id = citing_focal_wr.cited_source_uid -- focal
                                      AND focal_cited_wr.cited_source_uid = wr.cited_source_uid
                               WHERE wr.source_id = citing_focal_wr.source_id) THEN 1
               ELSE 0
             END) AS i,
         sum(CASE
               WHEN EXISTS(SELECT 1
                           FROM wos_references wr
                           JOIN wos_references focal_cited_wr
                                ON focal_cited_wr.source_id = citing_focal_wr.cited_source_uid -- focal
                                  AND focal_cited_wr.cited_source_uid = wr.cited_source_uid
                           WHERE wr.source_id = citing_focal_wr.source_id) THEN 1
               ELSE 0
             END) AS j
       FROM wos_references citing_focal_wr
       WHERE citing_focal_wr.cited_source_uid = :pub_id -- focal paper
     ) i_j_sq, (
       SELECT count(DISTINCT source_id) AS j_plus_k
       FROM wos_references citing_wr
       WHERE EXISTS(SELECT 1
                    FROM wos_references focal_cited_wr
                    WHERE focal_cited_wr.source_id = :pub_id -- focal paper
                      AND focal_cited_wr.cited_source_uid = citing_wr.cited_source_uid)
         AND source_id <> :pub_id -- focal paper
     ) j_plus_k_sq;
-- 676,811,11714
-- 10.8s-34.7s (cold-ish)
-- 0.4s (warm)

WITH
  cte AS (
    SELECT *
    FROM (
      VALUES ('WOS:A1990ED16700008')
    ) AS t(focal_paper_uid)
  )
SELECT
  i_j_sq.*
  --, j_plus_k_sq.*, CAST(i_j_sq.i - i_j_sq.j AS FLOAT) / (i_j_sq.i + j_plus_k_sq.j_plus_k) AS disruption
FROM (
  SELECT
    cte.focal_paper_uid,
    sum(CASE
          WHEN NOT EXISTS(SELECT 1
                          FROM wos_references wr
                          JOIN wos_references focal_cited_wr
                               ON focal_cited_wr.source_id = citing_focal_wr.cited_source_uid -- focal
                                 AND focal_cited_wr.cited_source_uid = wr.cited_source_uid
                          WHERE wr.source_id = citing_focal_wr.source_id) THEN 1
          ELSE 0
        END) AS i,
    sum(CASE
          WHEN EXISTS(SELECT 1
                      FROM wos_references wr
                      JOIN wos_references focal_cited_wr
                           ON focal_cited_wr.source_id = citing_focal_wr.cited_source_uid -- focal
                             AND focal_cited_wr.cited_source_uid = wr.cited_source_uid
                      WHERE wr.source_id = citing_focal_wr.source_id) THEN 1
          ELSE 0
        END) AS j
  FROM wos_references citing_focal_wr
  JOIN cte ON cte.focal_paper_uid = citing_focal_wr.cited_source_uid
  GROUP BY cte.focal_paper_uid
) i_j_sq/*, (
       SELECT count(DISTINCT source_id) AS j_plus_k
       FROM wos_references citing_wr
       WHERE EXISTS(SELECT 1
                    FROM wos_references focal_cited_wr
                    WHERE focal_cited_wr.source_id = cte.focal_paper_uid
                      AND focal_cited_wr.cited_source_uid = citing_wr.cited_source_uid)
     ) j_plus_k_sq*/
;
-- runaway query

SELECT count(1) AS i
FROM wos_references citing_focal_wr
WHERE cited_source_uid = 'WOS:A1990ED16700008' -- focal paper
  AND NOT EXISTS(SELECT 1
                 FROM wos_references wr
                 JOIN wos_references focal_cited_wr ON focal_cited_wr.source_id = citing_focal_wr.cited_source_uid
                   AND focal_cited_wr.cited_source_uid = wr.cited_source_uid
                 WHERE wr.source_id = citing_focal_wr.source_id);
-- 47563
-- 1m:03s (cold)

SELECT count(1) AS j
FROM wos_references citing_focal_wr
WHERE cited_source_uid = 'WOS:A1990ED16700008' -- focal paper
  AND EXISTS(SELECT 1
             FROM wos_references wr
             JOIN wos_references focal_cited_wr ON focal_cited_wr.source_id = citing_focal_wr.cited_source_uid -- focal
               AND focal_cited_wr.cited_source_uid = wr.cited_source_uid
             WHERE wr.source_id = citing_focal_wr.source_id);
-- 3843
-- 1m:51s-12m:44s (cold)

SELECT count(DISTINCT source_id) AS j_plus_k
FROM wos_references citing_wr
WHERE EXISTS(SELECT 1
             FROM wos_references focal_cited_wr
             WHERE focal_cited_wr.source_id = 'WOS:A1990ED16700008' -- focal paper
               AND focal_cited_wr.cited_source_uid = citing_wr.cited_source_uid);
-- 19969
-- 0.4s-5.4s (cold)
