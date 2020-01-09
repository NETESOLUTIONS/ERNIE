-- Test data bins
-- 5.9s
SELECT cited_1, cited_2
  FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
 WHERE bin = 1
 ORDER BY cited_1, cited_2 LIMIT 100 OFFSET 25000;

SELECT count(1)
  FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
 WHERE bin = 1;
-- 33,642

-- 6.0s
SELECT cited_1, cited_2
  FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
 WHERE bin = 1
 ORDER BY random()
 LIMIT 100;

SELECT cited_1, cited_2
  FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
 WHERE bin = 1
 ORDER BY cited_1, cited_2
 LIMIT 1000;

ALTER TABLE cc2.ten_year_cocit_union_freq11_freqsum_bins
  ADD CONSTRAINT ten_year_cocit_union_freq11_freqsum_bins_pk PRIMARY KEY (cited_1, cited_2) USING INDEX TABLESPACE index_tbs;

-- 1m:16s
CREATE UNIQUE INDEX IF NOT EXISTS ten_year_cocit_union_freq11_freqsum_bins_uk --
  ON cc2.ten_year_cocit_union_freq11_freqsum_bins(bin, cited_1, cited_2) TABLESPACE index_tbs;

SELECT cited_1, cited_2
  FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
 WHERE bin = 1;

-- Test data bins
SELECT DISTINCT bin
  FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
 ORDER BY bin;

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
  FROM
    scopus_publication_groups spg
      JOIN scopus_references sr ON sr.scp = spg.sgr AND sr.ref_sgr = 18983824
 WHERE spg.sgr = 19609776;