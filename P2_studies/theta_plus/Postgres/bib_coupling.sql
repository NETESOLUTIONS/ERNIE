-- simple script to identify instances of bibliographic
-- coupling between two members of a co-cited pair.
-- George Chacko (with Dmitriy Korobskiy's tutelage
-- April 8, 2020

-- In this case, the source table is t_o_p_final table
-- which contains all co-cited pairs with frequency >=10
-- roughly 4.12 million pairs.

CREATE TABLE chackoge.top_bc TABLESPACE p2_studies_tbs AS
WITH CTE AS (SELECT a1.cited_1,b1.ref_sgr as cr1,b2.ref_sgr as cr2,a1.cited_2
FROM t_o_p_final_table a1
INNER JOIN scopus_references b1 ON a1.cited_1=b1.scp
INNER JOIN scopus_references b2 ON a1.cited_2=b2.scp
AND b1.ref_sgr=b2.ref_sgr)
SELECT cited_1,cited_2, count(cr1) --,count(cr2)
-- cr2 isn't necessary since it is equal to cr1
FROM cte group by cited_1,cited_2;
