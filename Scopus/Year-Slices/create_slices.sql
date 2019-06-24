\set ON_ERROR_STOP on
\set ECHO all

\set slice_table 'scopus_year_slice_':year
\set slice_index 'scopus_year_slice_':year'_i'

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

DROP TABLE IF EXISTS :slice_table;

-- restrict to year 1985, restrict to valid references (ref_sgr has corresponding sgr in scopus_publication_groups)
-- restrict to publications with at least two valid references
CREATE TABLE :slice_table AS
SELECT scp, ref_sgr
FROM
  (
    SELECT sp.scp, sr.ref_sgr, COUNT(1) OVER (PARTITION BY sp.scp) AS ref_count
    FROM
      scopus_publication_groups spg
        JOIN scopus_publications sp ON sp.sgr = spg.sgr
        JOIN scopus_references sr ON sr.scp = sp.scp
        JOIN scopus_publication_groups ref_spg ON ref_spg.sgr = sr.ref_sgr
    WHERE spg.pub_year = :year
  ) sq
WHERE ref_count > 1;

CREATE INDEX :slice_index ON :slice_table(scp, ref_sgr);