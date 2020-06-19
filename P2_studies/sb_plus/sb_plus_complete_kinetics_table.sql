--- Generate complete kinetics for table sb_plus_all_kinetics

SET SEARCH_PATH  = sb_plus;

--- Create kinetics table with:
--- cited_1, cited_2, co_cited_year, frequency
--- max_frequency, min_frequency
--- first_co_cited_year (first co_cited_year with frequency > 0), first_possible_year (minimum year in cited_1_pub_year and cited_2_pub_year)
--- peak_year (the year that max_frequency achieved)
--- cited_1_pub_year, cited_2_pub_year (both >= 1970)
--- peak_count (how many peaks does each pair has)

DROP TABLE IF EXISTS sb_plus_complete_kinetics;

CREATE TABLE sb_plus_complete_kinetics TABLESPACE sb_plus_tbs AS

  WITH cte1 AS(
    SELECT cited_1, cited_2, co_cited_year, frequency,
          MAX(frequency) OVER(PARTITION BY cited_1, cited_2) AS max_frequency,
          MIN(frequency) OVER(PARTITION BY cited_1, cited_2) AS min_frequency,
          MIN(co_cited_year) OVER(PARTITION BY cited_1, cited_2) AS first_co_cited_year
      FROM sb_plus_all_kinetics
  )
SELECT cte1.cited_1, cte1.cited_2, cte1.co_cited_year, cte1.frequency,
  cte1.max_frequency, cte1.min_frequency, cte1.first_co_cited_year,
  GREATEST(spg1.pub_year, spg2.pub_year) AS first_possible_year,
  cte2.peak_year, cte2.peak_count,
  spg1.pub_year AS cited_1_pub_year, spg2.pub_year AS cited_2_pub_year
  FROM
    (SELECT cited_1, cited_2, MIN(co_cited_year) AS peak_year, COUNT(frequency) as peak_count
       FROM cte1
      WHERE frequency = cte1.max_frequency
      GROUP BY cited_1, cited_2) cte2
    JOIN cte1 ON cte2.cited_1 = cte1.cited_1 AND cte2.cited_2 = cte1.cited_2
    INNER JOIN public.scopus_publication_groups spg1
               ON cte1.cited_1 = spg1.sgr
    INNER JOIN public.scopus_publication_groups spg2
               ON cte1.cited_2 = spg2.sgr
 WHERE cte1.max_frequency >= 20 AND spg1.pub_year >= 1970 AND spg2.pub_year >= 1970
 ORDER BY cited_1, cited_2, co_cited_year;

--- 1,237,319 rows

--- Delete rows that first_co_cited_year is earlier than first_possible_year
DELETE FROM sb_plus_complete_kinetics
 WHERE co_cited_year < first_possible_year;

--- 1,235,816 rows


--- Recalculate SUM(frequency) and remove records that have SUM(frequency) < 100 and MAX(frequency) < 20
--- after dropping rows that co_cited_year < first_possible_year

DELETE FROM sb_plus_complete_kinetics
 WHERE (cited_1, cited_2)
     IN
   (SELECT cited_1, cited_2
      FROM sb_plus_complete_kinetics
     GROUP BY cited_1, cited_2
    HAVING SUM(frequency) < 100 OR MAX(frequency) < 20);

--- 1,235,573 rows: 13 pairs have been removed 

-- SELECT cited_1, cited_2
-- FROM sb_plus_complete_kinetics
-- GROUP BY cited_1, cited_2;

--- 51,613 distinct pairs in total