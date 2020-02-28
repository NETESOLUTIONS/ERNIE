-- DataGrip: start execution from here

\set ON_ERROR_STOP on
\set ECHO all


SET TIMEZONE = 'US/Eastern';

SET SEARCH_PATH = wenxi;

-- SELECT NOW();

DROP TABLE If EXISTS wenxi.initial_test;

CREATE TABLE wenxi.initial_test AS (

SELECT c.scp, c.auid AS scp_auid, c.ref_sgr, d.auid AS ref_auid, c.pub_year FROM (
SELECT a.scp, a.ref_sgr, b1.auid, b2.pub_year
FROM public.scopus_references a
INNER JOIN public.scopus_authors b1
ON a.scp = b1.scp
INNER JOIN public.scopus_publication_groups b2
ON a.scp = b2.sgr
WHERE b2.pub_year = 2005) c
INNER JOIN public.scopus_authors d
ON c.ref_sgr = d.scp);


