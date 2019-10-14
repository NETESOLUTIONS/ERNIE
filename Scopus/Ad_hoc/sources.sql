-- De-duplication
-- 14h:40m
DELETE
  FROM scopus_sources t1
 WHERE EXISTS(SELECT 1
                FROM scopus_sources t2
               WHERE (coalesce(t2.source_id, ''), coalesce(t2.issn_main, ''), coalesce(t2.isbn_main, ''))
                   = (coalesce(t1.source_id, ''), coalesce(t1.issn_main, ''), coalesce(t1.isbn_main, ''))
                 AND t2.ctid > t1.ctid);

SELECT max(ernie_source_id)
  FROM scopus_sources;
-- 81552478

SELECT *
  FROM stg_scopus_sources
WHERE ernie_source_id = :ernie_source_id;

SELECT *
  FROM scopus_sources
 WHERE ernie_source_id = :ernie_source_id;

SELECT *
  FROM scopus_sources
 WHERE (source_id = '' OR source_id IS NULL) AND issn_main = '01906011' AND (isbn_main = '' OR isbn_main IS NULL);

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
