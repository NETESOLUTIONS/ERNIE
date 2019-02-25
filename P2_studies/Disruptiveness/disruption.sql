\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- Assuming there are no double references
COPY (
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
  ) sq
) TO STDOUT WITH (FORMAT CSV, HEADER OFF);
-- 10.8s-34.7s (cold-ish)
