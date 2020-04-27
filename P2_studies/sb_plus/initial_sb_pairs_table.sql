--- Extract SB pairs with thier individual publication pub_year
--- from 4.12 million pairs table by setting three condition:

-- 1.The minimum total number of co-citation received is 100
-- 2. The minimum number of co-citation received in peak year is 30
-- 4. The first possible co-citation year is later than 1970


CREATE TABLE wenxi.sleep_beauty_static_data TABLESPACE p2_studies_tbs AS
SELECT e.*, f.pub_year AS cited_2_pub_year
  INTO wenxi.sleep_beauty_static_data
  FROM (
    SELECT c.*, d.pub_year AS cited_1_pub_year FROM (
      SELECT a.cited_1, a.cited_2, a.first_co_cited_year, a.first_possible_year, b.first_peak_year, b.co_cited_year, b.frequency, b.peak_frequency
        FROM (
          SELECT cited_1, cited_2, first_co_cited_year, first_possible_year, SUM(frequency) FROM cc2.kinetics_data
           GROUP BY cited_1, cited_2, first_co_cited_year, first_possible_year
          HAVING SUM(frequency) >= 100) a
        INNER JOIN cc2.kinetics_data b
                   ON a.cited_1 = b.cited_1 and a.cited_2 = b.cited_2
       WHERE b.peak_frequency >= 20) c
    INNER JOIN public.scopus_publication_groups d
               ON c.cited_1 = d.sgr
     WHERE d.pub_year >= 1970) e
  INNER JOIN public.scopus_publication_groups f
             ON e.cited_2 = f.sgr
 WHERE f.pub_year >= 1970;