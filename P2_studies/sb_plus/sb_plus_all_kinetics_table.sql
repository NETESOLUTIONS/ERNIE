-- Concatenate all sbp_chop_i_kinetics tables that have kinetics for pairs
-- with frequency >= 100, co_cited_year <= 2019 and IS NOT NULL

SET SEARCH_PATH = sb_plus;

-- 5,113,111 rows for union table

CREATE TABLE sb_plus_all_kinetics TABLESPACE sb_plus_tbs AS
  WITH cte AS (
    SELECT * FROM sbp_1985_kinetics
     UNION
    SELECT * FROM sbp_chop_1_kinetics
     UNION
    SELECT * FROM sbp_chop_2_kinetics
     UNION
    SELECT * FROM sbp_chop_3_kinetics
     UNION
    SELECT * FROM sbp_chop_4_kinetics
     UNION
    SELECT * FROM sbp_chop_5_kinetics
     UNION
    SELECT * FROM sbp_chop_6_kinetics
     UNION
    SELECT * FROM sbp_chop_7_kinetics
     UNION
    SELECT * FROM sbp_chop_8_kinetics
     UNION
    SELECT * FROM sbp_chop_9_kinetics)
SELECT * FROM cte
 WHERE cte.co_cited_year <= 2018 AND cte.co_cited_year IS NOT NULL
 ORDER BY cte.cited_1, cte.cited_2, cte.co_cited_year;

--- Remove pairs that have frequency < 100 after selecting cte.co_cited_year <= 2018 AND cte.co_cited_year IS NOT NULL
DELETE FROM sb_plus_all_kinetics
 WHERE (cited_1, cited_2)
     IN
   (SELECT cited_1, cited_2
      FROM sb_plus_all_kinetics
     GROUP BY cited_1, cited_2
    HAVING SUM(frequency) < 100);

--- SELECT cited_1, cited_2, COUNT(*)
--- FROM sb_plus_all_kinetics
--- GROUP BY cited_1, cited_2;

--- 175,625 distinct pairs


