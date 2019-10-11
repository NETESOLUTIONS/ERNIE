-- De-duplication
DELETE
  FROM scopus_sources t1
 WHERE EXISTS(SELECT 1
                FROM scopus_sources t2
               WHERE (t2.source_id, t2.issn_main, t2.isbn_main)
                   IS NOT DISTINCT FROM (t1.source_id, t1.issn_main, t1.isbn_main) AND t2.ctid > t1.ctid);

SELECT max(ernie_source_id)
  FROM scopus_sources;
-- 81552478

/*
CREATE SEQUENCE scopus_sources_ernie_source_id_seq AS INTEGER START 81552479
OWNED BY scopus_sources.ernie_source_id;
*/

ALTER TABLE scopus_sources
  ALTER COLUMN ernie_source_id SET DEFAULT nextval('scopus_sources_ernie_source_id_seq');

SELECT *
  FROM scopus_sources_ernie_source_id_seq;

INSERT INTO scopus_sources
  (source_id, issn_main, isbn_main)
VALUES
  (21100256101, 23029293, '')
    ON CONFLICT(source_id, issn_main, isbn_main) DO UPDATE SET source_id=excluded.source_id,
      issn_main=excluded.issn_main,
      isbn_main=excluded.isbn_main;

SELECT *
  FROM scopus_source_publication_details
 WHERE publication_year = 1880;
-- 2m:36s

SELECT *
  FROM
    scopus_publications sp
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
