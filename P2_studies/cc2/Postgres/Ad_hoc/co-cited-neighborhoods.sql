SELECT a.scp AS n_of_x
  FROM
    scopus_references a
      INNER JOIN scopus_publication_groups b ON a.scp = b.sgr
 WHERE ref_sgr = 17538003 AND b.pub_year <= 1982;

SELECT a.scp AS n_of_y
  FROM
    scopus_references a
      INNER JOIN scopus_publication_groups b ON a.scp = b.sgr
 WHERE ref_sgr = 18983824 AND b.pub_year <= 1982;

  WITH t1 AS (
    SELECT a.scp AS n_of_x
      FROM
        scopus_references a
          INNER JOIN scopus_publication_groups b ON a.scp = b.sgr
     WHERE a.ref_sgr = 17538003 AND b.pub_year <= 1982
  ),
    t2 AS (
      SELECT a.scp AS n_of_y
        FROM
          scopus_references a
            INNER JOIN scopus_publication_groups b ON a.scp = b.sgr
       WHERE a.ref_sgr = 18983824 AND b.pub_year <= 1982
    )
SELECT scp, ref_sgr
  FROM scopus_references
 WHERE ref_sgr IN (
   SELECT *
     FROM t1
 ) AND scp IN (
   SELECT *
     FROM t2
 )
 UNION ALL
SELECT scp, ref_sgr
  FROM scopus_references
 WHERE ref_sgr IN (
   SELECT *
     FROM t2
 ) AND scp IN (
   SELECT *
     FROM t1
 )
ORDER BY scp, ref_sgr;

SELECT spg.sgr, spg.pub_year, sr.ref_sgr
FROM scopus_publication_groups spg
JOIN scopus_references sr ON sr.scp = spg.sgr AND sr.ref_sgr = 18983824
WHERE spg.sgr = 19609776;