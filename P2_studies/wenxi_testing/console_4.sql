-- DataGrip: start execution from here

\set ON_ERROR_STOP on
\set ECHO all


SET TIMEZONE = 'US/Eastern';

SET SEARCH_PATH = wenxi;

-- SELECT NOW();

DROP TABLE If EXISTS wenxi.tableseed;

CREATE TABLE wenxi.tableseed AS


((SELECT DISTINCT scp AS source, 'citing' AS source_type, ref_sgr AS tagret, 'seed' AS tagret_type
 FROM ernie.public.scopus_references
 WHERE scp IN (SELECT c.scp
               FROM ernie.public.scopus_references c LEFT JOIN ernie.public.scopus_publication_groups d
                                                               ON c.scp = d.sgr
               WHERE c.ref_sgr = (
                   SELECT a.scp FROM ernie.public.scopus_publication_identifiers a
                                         LEFT JOIN ernie.public.scopus_publication_groups b
                                                   ON a.scp = b.sgr
                   WHERE a.document_id_type = 'DOI' and a.document_id = '10.1038/227680a0' and b.pub_year IS NOT NULL))

   AND ref_sgr = (SELECT a.scp FROM ernie.public.scopus_publication_identifiers a
                                        LEFT JOIN ernie.public.scopus_publication_groups b
                                                  ON a.scp = b.sgr
                  WHERE a.document_id_type = 'DOI' and a.document_id = '10.1038/227680a0' and b.pub_year IS NOT NULL))

UNION

(SELECT c.scp as source,  'seed' AS source_type,
        c.ref_sgr as target, 'cited' AS target_type
 FROM ernie.public.scopus_references c LEFT JOIN ernie.public.scopus_publication_groups d
                                                 ON c.scp = d.sgr
 WHERE c.scp = (
     SELECT a.scp FROM ernie.public.scopus_publication_identifiers a
                           LEFT JOIN ernie.public.scopus_publication_groups b
                                     ON a.scp = b.sgr
     WHERE a.document_id_type = 'DOI' and a.document_id = '10.1038/227680a0' and b.pub_year IS NOT NULL))

ORDER BY source_type DESC);


DROP TABLE If EXISTS wenxi.tablecount;

CREATE TABLE wenxi.tablecount AS

SELECT pub_year, COUNT(count) FROM (
SELECT pub_year, COUNT(*) as count FROM (SELECT scp, ref_sgr, pub_year
FROM  ernie.public.scopus_references a INNER JOIN ernie.public.scopus_publication_groups b
ON a.scp = b.sgr
WHERE ref_sgr = :ref_sgr1 OR ref_sgr = :ref_sgr2)  a
GROUP BY scp, pub_year
HAVING COUNT(*) > 1) b
GROUP BY pub_year;



DROP TABLE If EXISTS wenxi.tablepair;

CREATE TABLE wenxi.tablepair AS


SELECT ':ref_sgr1, :ref_sgr2' as pair, COUNT(count) as count FROM (
SELECT COUNT(*) FROM (SELECT scp, ref_sgr FROM ernie.public.scopus_references as count
WHERE ref_sgr = :ref_sgr1 OR ref_sgr = :ref_sgr2)  a
GROUP BY scp
HAVING COUNT(*) > 1 ) b;



grant all PRIVILEGES on all tables in schema wenxi to wenxi;


