\set ON_ERROR_STOP on
-- \set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path to public;

SELECT :source_id AS focal_paper_id, dependency_index
FROM (
         WITH cte AS (
             SELECT scp, ref_sgr AS mp
             FROM sitaram.f1000_refs
             WHERE scp = :source_id
         ),
              dte AS (
                  SELECT scp AS cp
                  FROM public.scopus_references
                  WHERE ref_sgr = :source_id
              ),
              mte AS (
                  SELECT scp, ref_sgr AS cp FROM public.scopus_references WHERE scp IN (SELECT * FROM dte)
              )
         SELECT count(*) / (SELECT count(*) FROM dte)::decimal AS dependency_index
         FROM cte
                  JOIN mte ON cte.mp = mte.cp) temp;