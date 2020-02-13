SELECT *
  FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
 WHERE (cited_1, cited_2) = (4532, 320221);

-- 9.3s-1m:07s
SELECT cited_1, cited_2, first_co_cited_year
  FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
 WHERE bin = 1;

-- 8.3s-9.3s-1m:07s
SELECT cited_1, cited_2, first_co_cited_year
  FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
 WHERE bin BETWEEN 4 AND 10 OR scopus_frequency >= 50
 ORDER BY cited_1, cited_2;

-- N(x, fccy) -> N(y, fccy) published <= fccy
SELECT sr.scp, sr.ref_sgr
  FROM
    scopus_references sr
 WHERE sr.scp IN (
   -- N(x, fccy)
   SELECT sr.scp
     FROM scopus_references sr
       JOIN scopus_publication_groups spg ON spg.sgr = sr.scp AND spg.pub_year <= :fccy
    WHERE sr.ref_sgr = :cited_1
 ) AND sr.ref_sgr IN (
   -- N(y, fccy)
   SELECT sr.scp
     FROM scopus_references sr
       JOIN scopus_publication_groups spg ON spg.sgr = sr.scp AND spg.pub_year <= :fccy
    WHERE sr.ref_sgr = :cited_2
 );
-- 738652, 44149093434, 1982: 2
-- scp	                    ref_sgr
-- 33847069350	            738652 (x in N(y))
-- 44149093434	(y in N(x)) 738652 (x in N(y))

-- N(y, fccy) -> N(x, fccy)
SELECT sr.scp, sr.ref_sgr
  FROM
    scopus_references sr
 WHERE sr.scp IN (
   -- N(y, fccy)
   SELECT sr.scp
     FROM scopus_references sr
       JOIN scopus_publication_groups spg ON spg.sgr = sr.scp AND spg.pub_year <= :fccy
    WHERE sr.ref_sgr = 44149093434 --:cited_2
 ) AND sr.ref_sgr IN (
   -- N(x, fccy)
   SELECT sr.scp
     FROM scopus_references sr
       JOIN scopus_publication_groups spg ON spg.sgr = sr.scp AND spg.pub_year <= :fccy
    WHERE sr.ref_sgr = 738652 --:cited_1
 );
-- 738652, 44149093434, 1982: 3
-- scp	        ref_sgr
-- 738652	      44149093434
-- 33847069350	44149093434
-- 738652	      33847069350

-- Conditional citing papers
SELECT sr.scp
  FROM
    scopus_references sr
      JOIN scopus_publication_groups spg ON spg.sgr = sr.scp AND spg.pub_year <= :fccy
 WHERE sr.ref_sgr = :cited;
-- 738652: 2
-- scp
-- 33847069350
-- 44149093434

-- 44149093434: 2
-- scp
-- 33847069350
-- 738652

-- Test data pair
SELECT cited_1, cited_2, first_co_cited_year
  FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
 WHERE bin = 1 AND cited_1 = :cited_1 AND cited_2 = :cited_2;
-- First co-cited year: 320176, 6278248: 1990

-- Test data pair inner citations
SELECT *
  FROM scopus_references sr
WHERE (sr.scp = :cited_1 AND sr.ref_sgr = :cited_2) OR (sr.scp = :cited_2 AND sr.ref_sgr = :cited_1);

-- Citing paper count
SELECT count(1)
  FROM scopus_references
 WHERE ref_sgr = :cited;
-- 320176: 356
-- 6278248: 344

-- Co-citations
-- TODO report problem with 2 bind variables causing 1 prompt
SELECT spg.*
  FROM
    scopus_publication_groups spg
      JOIN scopus_references sr1 ON sr1.ref_sgr = 320176 AND sr1.scp = spg.sgr
      JOIN scopus_references sr2 ON sr2.ref_sgr = 6278248 AND sr2.scp = spg.sgr
 ORDER BY pub_year;
-- 320176,6278248: 164 (1988-2019)

-- Test data bins
-- 5.9s
SELECT cited_1, cited_2
  FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
 WHERE bin = 1
 ORDER BY cited_1, cited_2
 LIMIT 100
OFFSET
 25000;

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