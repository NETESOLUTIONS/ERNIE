--- Rebuild kinetics of 1380 pairs (add data after first peak year)

CREATE TABLE wenxi.sleep_beauty_pairs_table_incomplete TABLESPACE p2_studies_tbs AS
SELECT d.cited_1, d.cited_2, spg.pub_year AS co_cited_year, COUNT(1) AS co_citations
  FROM wenxi.sleep_beauty_1380_pairs_slope d
  JOIN public.scopus_references sr1
       ON sr1.ref_sgr = CAST(d.cited_1 AS BIGINT)
  JOIN public.scopus_references sr2
       ON sr2.scp = sr1.scp AND sr2.ref_sgr = CAST(d.cited_2 AS BIGINT)
  JOIN public.scopus_publication_groups spg
       ON spg.sgr = sr1.scp
 GROUP BY d.cited_1, d.cited_2, spg.pub_year;

--- Remove records that scp pub year later than 2019 and scp pub year is null, and get pub_year of cited_1 and cited_2

CREATE TABLE wenxi.sleep_beauty_pairs_table_complete TABLESPACE p2_studies_tbs AS
SELECT e.*, f.pub_year AS cited_2_pub_year
  FROM (
    SELECT c.*, d.pub_year AS cited_1_pub_year FROM (
      SELECT * FROM wenxi.sleep_beauty_pairs_table_incomplete
       WHERE co_cited_year <= 2019 and co_cited_year IS NOT NULL) c
    INNER JOIN public.scopus_publication_groups d
               ON CAST(c.cited_1 AS BIGINT)= d.sgr) e
  INNER JOIN public.scopus_publication_groups f
             ON CAST(e.cited_2 AS BIGINT) = f.sgr;