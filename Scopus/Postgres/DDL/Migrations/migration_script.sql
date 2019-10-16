\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- region scopus_sources has new column pub_date
-- Done
-- ALTER TABLE scopus_sources
--   ADD COLUMN pub_date DATE;

-- updating column pub_date of scopus_sources

-- UPDATE scopus_sources
-- SET pub_date=scopus_temp.pub_date
-- FROM (SELECT sp.ernie_source_id, max(spg.pub_date) AS pub_date
--       FROM scopus_publications sp
--              INNER JOIN scopus_publication_groups spg ON sp.sgr = spg.sgr
--       GROUP BY sp.ernie_source_id) scopus_temp
-- WHERE scopus_sources.ernie_source_id = scopus_temp.ernie_source_id;
-- endregion

-- It is assumed that table scopus_issns is already created
ALTER TABLE scopus_issns
DROP CONSTRAINT scopus_issns_pk;

INSERT INTO scopus_issns (ernie_source_id, issn, issn_type)
SELECT ernie_source_id, issn, 'print'
FROM scopus_sources
WHERE issn != ''
UNION
SELECT ernie_source_id, issn_electronic, 'electronic'
FROM scopus_sources
WHERE issn_electronic IS NOT NULL;

ALTER TABLE scopus_issns
    ADD CONSTRAINT scopus_issns_pk PRIMARY KEY (ernie_source_id,issn,issn_type) USING INDEX TABLESPACE index_tbs;

-- Renaming column issn as per changes
ALTER TABLE scopus_sources
  RENAME COLUMN issn TO issn_main;

-- droping issn_electronic column
ALTER TABLE scopus_sources
  DROP COLUMN issn_electronic;

-- Updating scopus_sources.issn_main with missing issns from scopus_issns
-- First step updating with issn_type print, 2nd step with type electronic
-- Dropping unique index for scopus_sources which will be added later
DROP INDEX scopus_sources_source_id_issn_isbn_uk;


UPDATE scopus_sources ss
SET issn_main=scopus_temp.issn
FROM (SELECT * FROM scopus_issns WHERE issn_type = 'print') scopus_temp
WHERE ss.ernie_source_id = scopus_temp.ernie_source_id
  AND (ss.issn_main = ''
    OR ss.issn_main = ' ');

UPDATE scopus_sources ss
SET issn_main=scopus_temp.issn
FROM (SELECT * FROM scopus_issns WHERE issn_type = 'electronic') scopus_temp
WHERE ss.ernie_source_id = scopus_temp.ernie_source_id
  AND (ss.issn_main = ''
    OR ss.issn_main = ' ');
    
-- updating missing isbns in scopus_sources from scopus_isbns

UPDATE public.scopus_sources ss
SET isbn_main=scopus_temp.isbn
FROM (SELECT * FROM scopus_isbns WHERE isbn_type ISNULL) scopus_temp
WHERE ss.ernie_source_id = scopus_temp.ernie_source_id
  AND (ss.isbn_main = '' OR ss.isbn_main = ' ');

--fix the class_type asjc code where not 4 digit integer but e.g. 100 or 100.445df//dd


create table temp_class_code as
select *, CASE
      WHEN class_type = 'ASJC' AND class_code ~ '([0-9];)'
        THEN substring(class_code, 1, 4) -- special case e.g. 1004; removal of ; preserves code
      WHEN class_type = 'ASJC' AND length(class_code) != 4
          AND -- any value which is not a 4-digit integer and is an alphanumeric must be nulled
        class_code ~ '([0-9a-zA-Z\.\,\;\:\/])'
        THEN '' END as modified_class_code
from scopus_classes
where class_type='ASJC' and length(class_code) != 4 ; -- 3


update scopus_classes scp_classes
set class_code= temp.modified_class_code
     from temp_class_code temp
where scp_classes.scp=temp.scp and
      scp_classes.class_type=temp.class_type and
      scp_classes.class_code=temp.class_code;