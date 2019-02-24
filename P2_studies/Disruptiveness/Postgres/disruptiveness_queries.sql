SELECT i_j_sq.*, (j_plus_k_sq.j_plus_k - i_j_sq.j) AS k,
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
-- 10.8s-34.7s (cold-ish)

WITH
  cte AS (
    SELECT *
    FROM (
      VALUES ('WOS:A1990ED16700008')
    ) AS t(focal_paper_uid)
  )
SELECT i_j_sq.*
--, j_plus_k_sq.*, CAST(i_j_sq.i - i_j_sq.j AS FLOAT) / (i_j_sq.i + j_plus_k_sq.j_plus_k) AS disruption
FROM
(
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
