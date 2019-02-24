\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- Assuming there are no double references
SELECT i_j_sq.*, j_plus_k_sq.*, CAST(i_j_sq.i - i_j_sq.j AS FLOAT) / (i_j_sq.i + j_plus_k_sq.j_plus_k) AS disruption
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
       WHERE cited_source_uid = :pub_uid -- focal paper
     ) i_j_sq, (
       SELECT count(DISTINCT source_id) AS j_plus_k
       FROM wos_references citing_wr
       WHERE EXISTS(SELECT 1
                    FROM wos_references focal_cited_wr
                    WHERE focal_cited_wr.source_id = :pub_uid -- focal paper
                      AND focal_cited_wr.cited_source_uid = citing_wr.cited_source_uid)
     ) j_plus_k_sq;
-- 10.8s-34.7s (cold-ish)
