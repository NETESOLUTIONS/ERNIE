--- Create individual publication kinetics of extracted SB pairs

-- DROP TABLE IF EXISTS wenxi.sleep_beauty_1380_individual_kinetics;
CREATE TABLE wenxi.sleep_beauty_1380_individual_kinetics TABLESPACE p2_studies_tbs AS
SELECT c.cited_1, d.pub_year, COUNT(*)
  FROM (
    SELECT a.cited_1, b.scp FROM (
      SELECT cited_1 FROM wenxi.sleep_beauty_1380_pairs_slope
       UNION
      SELECT cited_2 FROM wenxi.sleep_beauty_1380_pairs_slope) a
    INNER JOIN public.scopus_references b
               ON CAST(a.cited_1 AS BIGINT) = b.ref_sgr) c
  INNER JOIN public.scopus_publication_groups d
             ON c.scp = d.sgr
 GROUP BY c.cited_1, d.pub_year;

--- Remove records that scp pub year earlier than ref_sgr pub year, scp pub year later than 2019 and scp pub year is null
CREATE TABLE wenxi.sleep_beauty_1380_individual_kinetics_update TABLESPACE p2_studies_tbs AS
SELECT a.*, b.pub_year AS cited_1_pub_year
  FROM wenxi.sleep_beauty_1380_individual_kinetics a
  INNER JOIN public.scopus_publication_groups b
             ON CAST(a.cited_1 AS BIGINT) = b.sgr
 WHERE a.pub_year >= b.pub_year and a.pub_year <= 2019 and a.pub_year IS NOT NULL;
 
 
