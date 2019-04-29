\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- scopus_sources has new column pub_date

ALTER TABLE scopus_sources
  ADD COLUMN pub_date DATE;

-- updating column pub_date of scopus_sources

UPDATE scopus_sources
SET pub_date=spg.pub_date
FROM scopus_sources ss
       INNER JOIN scopus_publications sp
                  ON sp.ernie_source_id = ss.ernie_source_id
       INNER JOIN scopus_publication_groups spg
                  ON spg.sgr = sp.sgr;

-- It is assumed that table scopus_issns is already created

INSERT INTO scopus_issns (ernie_source_id, issn, issn_type)
SELECT ernie_source_id, issn, 'print'
FROM scopus_sources
WHERE issn != ''
UNION
SELECT ernie_source_id, issn_electronic, 'electronic'
FROM scopus_sources
WHERE issn_electronic IS NOT NULL;

-- Renaming column issn as per changes
ALTER TABLE scopus_sources
  RENAME COLUMN issn TO issn_main;

-- droping issn_electronic column
ALTER TABLE scopus_sources
  DROP COLUMN issn_electronic;
