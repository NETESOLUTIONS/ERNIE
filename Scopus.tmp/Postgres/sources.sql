SELECT *
FROM scopus_source_publication_details
WHERE publication_year = 1880;
-- 2m:36s

SELECT *
FROM scopus_publications sp
JOIN scopus_publication_groups spg ON sp.sgr = spg.sgr
WHERE scp IN (84960675891,
              84960681706,
              84960640034,
              84960645391,
              84960653710,
              84960656392,
              84960646195,
              84960678793,
              84960656746);
