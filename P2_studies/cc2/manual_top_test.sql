-- Feb 13, 2020 
-- Author: George Chacko
-- Clunky manual script to evaluate theta-omega_prime for co-cited pairs
-- calculations in Neo4J
-- execute as 'psql -f manual_top_test.sql -v v1=scp1 -v v2=scp2'
-- use the four values at the end to calculate theta-omega_prime

-- get first year of citation (FCY) as cutoff year
WITH cte AS (
SELECT scp FROM scopus_references 
WHERE ref_sgr IN (:v1,:v2) 
GROUP BY scp HAVING COUNT(scp) =2) 
SELECT MIN(b.pub_year) 
FROM cte 
INNER JOIN scopus_publication_groups b 
ON cte.scp=b.sgr;

-- CREATE TABLE OF CITING PUBS WITH FCY CUTOFF
-- FOR FIRST MEMBER OF COCITED PAIR 
DROP TABLE IF EXISTS chackoge.tempa;
CREATE TABLE chackoge.tempa AS 
SELECT a.scp FROM scopus_references a 
INNER JOIN scopus_publication_groups b 
ON a.scp=b.sgr 
WHERE a.ref_sgr=:v1 AND pub_year <= (WITH cte AS (
SELECT scp FROM scopus_references
WHERE ref_sgr IN (:v1,:v2)
GROUP BY scp HAVING COUNT(scp) =2)
SELECT MIN(b.pub_year)
FROM cte
INNER JOIN scopus_publication_groups b
ON cte.scp=b.sgr);

-- CREATE TABLE OF CITING PUBS WITH FCY CUTOFF
-- FOR SECOND  MEMBER OF COCITED PAIR 
DROP TABLE IF EXISTS chackoge.tempb;
CREATE TABLE chackoge.tempb AS
SELECT a.scp FROM scopus_references a
INNER JOIN scopus_publication_groups b
ON a.scp=b.sgr
WHERE a.ref_sgr=:v2 AND pub_year <= (WITH cte AS (
SELECT scp FROM scopus_references
WHERE ref_sgr IN (:v1,:v2)
GROUP BY scp HAVING COUNT(scp) =2)
SELECT MIN(b.pub_year)
FROM cte
INNER JOIN scopus_publication_groups b
ON cte.scp=b.sgr);

-- EXPRESSION TO IDENTIFY COCITING PUBS 
-- WHICH MUST BE REMOVED (INTERSECTION OF 
-- CITING PUBS FOR A AND B)

DROP TABLE IF EXISTS tempc;
CREATE TABLE chackoge.tempc AS
SELECT scp FROM chackoge.tempa
INTERSECT
SELECT scp FROM chackoge.tempb;

--UPDATE TABLES BY DELETING ROWS WITH INTERSECTION VALUES:
DELETE FROM chackoge.tempa WHERE scp in (SELECT * FROM tempc);
DELETE FROM chackoge.tempb WHERE scp in (SELECT * FROM tempc);

--COUNT OF NODES IN A AFTER REMOVAL OF INTERSECTION: N(b)
SELECT COUNT(1) FROM chackoge.tempa;
--COUNT OF NODES in B AFTER REMOVAL OF INTERSECTION: N(b)
SELECT COUNT(1) FROM chackoge.tempb;

-- COUNT OF EDGES FROM A CITING PUBS  to B CITING PUBS: Bcites 
SELECT COUNT(1) FROM scopus_references
WHERE ref_sgr IN (SELECT scp FROM chackoge.tempb) 
AND scp IN (SELECT scp FROM chackoge.tempa);


-- COUNT OF EDGES FROM B CITING PUBS to A CITING PUBS: Bcites
SELECT COUNT(1) FROM scopus_references
WHERE ref_sgr IN (SELECT scp FROM chackoge.tempa) 
AND scp IN (SELECT scp FROM chackoge.tempb);

-- CALCULATE THETA OMEGA PRIME AS
-- (Acites+Bcites)/(N(a)*N(b))



