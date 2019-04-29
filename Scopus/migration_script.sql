\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- scopus_sources has new column pub_date

ALTER TABLE scopus_sources
  ADD COLUMN pub_date DATE;

-- updating column pub_date of scopus_sources

UPDATE scopus_sources
SET pub_date=scopus_temp.pub_date
FROM (SELECT sp.ernie_source_id, max(spg.pub_date) AS pub_date
      FROM scopus_publications sp
             INNER JOIN scopus_publication_groups spg ON sp.sgr = spg.sgr
      GROUP BY sp.ernie_source_id) scopus_temp
WHERE scopus_sources.ernie_source_id = scopus_temp.ernie_source_id;

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
