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
     )
SELECT :cited_1                                                          AS cited_1,
       :cited_2                                                          AS cited_2,
       :first_cited_year                                                 AS first_cited_year,
       ((SELECT count(sr.scp)
         FROM public.scopus_references sr
                  JOIN cited_2 ON cited_2.scp = sr.scp
         WHERE ref_sgr IN (SELECT * FROM cited_1))
           + (SELECT count(sr2.scp)
              FROM public.scopus_references sr2
                       JOIN cited_1 ON cited_1.scp = sr2.scp
              WHERE ref_sgr IN (SELECT * FROM cited_2)))::DECIMAL /
       ((SELECT count(*) FROM cited_1) * (SELECT count(*) FROM cited_2)) AS exy,
       (SELECT * FROM intersect_t)::DECIMAL / (SELECT * FROM union_t)    AS interset_union,
       ((SELECT * FROM intersect_t)+2)::DECIMAL / ((SELECT * FROM union_t)+2)    AS interset_union_2;