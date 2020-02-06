-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

SET SEARCH_PATH = public;

-- SELECT NOW();

(SELECT DISTINCT scp AS source, 'citing' AS source_type, ref_sgr AS tagret, 'seed' AS tagret_type INTO TableSeed
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

ORDER BY source_type DESC;
