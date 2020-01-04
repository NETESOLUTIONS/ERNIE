\set ON_ERROR_STOP on

SET TIMEZONE = 'US/Eastern';
SET search_path TO cc2;


WITH cited_1 AS (
    SELECT scp
    FROM public.scopus_references sr
             JOIN public.scopus_publication_groups sgr
                  ON sr.scp = sgr.sgr
    WHERE ref_sgr = :cited_1
      AND pub_year <= :first_cited_year
),
     cited_2 AS (
         SELECT scp
         FROM public.scopus_references sr
                  JOIN public.scopus_publication_groups sgr
                       ON sr.scp = sgr.sgr
         WHERE ref_sgr = :cited_2
           AND pub_year <= :first_cited_year
     ),
     pair_edges AS (
         SELECT ((SELECT count(sr.scp)
                  FROM public.scopus_references sr
                           JOIN cited_2 ON cited_2.scp = sr.scp
                  WHERE ref_sgr IN (SELECT * FROM cited_1))
             + (SELECT count(sr2.scp)
                FROM public.scopus_references sr2
                         JOIN cited_1 ON cited_1.scp = sr2.scp
                WHERE ref_sgr IN (SELECT * FROM cited_2))) AS edge_count
     ),
     union_t AS (
         SELECT count(*)
         FROM (SELECT scp
               FROM public.scopus_references
               WHERE ref_sgr = :cited_1
               UNION
               SELECT scp
               FROM public.scopus_references
               WHERE ref_sgr = :cited_2
              ) t
     ),
     intersect_t AS (
         SELECT count(*)
         FROM (
                  SELECT scp
                  FROM public.scopus_references
                  WHERE ref_sgr = :cited_1
                  INTERSECT
                  SELECT scp
                  FROM public.scopus_references
                  WHERE ref_sgr = :cited_2) t
     ),
     union_t1 AS (
         SELECT count(*)
         FROM (SELECT scp
               FROM public.scopus_references
               WHERE ref_sgr = :cited_1
               UNION
               SELECT scp
               FROM public.scopus_references
               WHERE ref_sgr = :cited_2
               UNION
               SELECT :cited_1 AS scp
               UNION
               SELECT :cited_2 AS scp
              ) t
     ),
     intersect_t1 AS (
         SELECT count(*)
         FROM (
                  (SELECT scp
                   FROM public.scopus_references
                   WHERE ref_sgr = :cited_1
                   UNION
                   SELECT :cited_1
                  )
                  INTERSECT
                  (SELECT scp
                   FROM public.scopus_references
                   WHERE ref_sgr = :cited_2
                   UNION
                   SELECT :cited_2
                  )) t
     )
SELECT :cited_1                                                          AS cited_1,
       :cited_2                                                          AS cited_2,
       :first_cited_year                                                 AS first_cited_year,
       (SELECT count(*) FROM cited_1)                                    AS cited_1_count,
       (SELECT count(*) FROM cited_2)                                    AS cited_2_count,
       (SELECT * FROM pair_edges)                                        AS pair_edges,
       (SELECT * FROM pair_edges)::DECIMAL /
       ((SELECT count(*) FROM cited_1) * (SELECT count(*) FROM cited_2)) AS exy,
       (SELECT * FROM intersect_t)                                       AS intersection_count,
       (SELECT * FROM union_t)                                           AS union_count,
       (SELECT * FROM intersect_t)::DECIMAL / (SELECT * FROM union_t)    AS union_xy,
       (SELECT * FROM intersect_t1)                                      AS intersection_count2,
       (SELECT * FROM union_t1)                                          AS union_count2,
       (SELECT * FROM intersect_t1)::DECIMAL / (SELECT * FROM union_t1)  AS union_xy2;