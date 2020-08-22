-- sb_plus_triplets DDL
CREATE INDEX triplets_citing_nodes_idx ON sb_plus_triplets.triplets_citing_nodes(scp) TABLESPACE index_tbs;

CREATE TABLE sb_plus_triplets.triplets_cited
TABLESPACE sb_plus_tbs AS
SELECT tcn.scp AS citing, sr.ref_sgr AS cited
  FROM sb_plus_triplets.triplets_citing_nodes tcn
  INNER JOIN public.scopus_references sr
             ON tcn.scp = sr.scp;

CREATE INDEX sb_plus_triplets.triplets_cited_idx ON sb_plus_triplets.triplets_cited(citing, cited) TABLESPACE index_tbs;
-- clean up Scopus data
DELETE
  FROM sb_plus_triplets.triplets_cited
 WHERE citing = cited; -- there are 5 instances of self-citations

CREATE TABLE sb_plus_triplets.triplets_citing
TABLESPACE sb_plus_tbs AS
SELECT sr.scp AS citing, tcn.scp AS cited
  FROM sb_plus_triplets.triplets_citing_nodes tcn
  INNER JOIN public.scopus_references sr
             ON tcn.scp = sr.ref_sgr;

CREATE INDEX sb_plus_triplets.triplets_citing_idx ON sb_plus_triplets.triplets_citing(citing, cited) TABLESPACE index_tbs;

-- clean up Scopus data
DELETE
  FROM sb_plus_triplets.triplets_citing
 WHERE citing = cited;
-- there are 5 instances of self-citations

-- 8m:08s
ALTER TABLE sb_plus_triplets.triplets_unique
  ADD PRIMARY KEY (scp1, scp2, scp3) USING INDEX TABLESPACE index_tbs;

CREATE OR REPLACE VIEW sb_plus_triplets.triplets_direct_citations AS
(
SELECT
  scp1, scp2, scp3, --
  (
    SELECT count(1) FROM scopus_references sr WHERE sr.ref_sgr = scp1 AND sr.scp IN (scp2, scp3)
  ) AS scp1_triplet_citations, --
  (
    SELECT count(1) FROM scopus_references sr WHERE sr.ref_sgr = scp2 AND sr.scp IN (scp1, scp3)
  ) AS scp2_triplet_citations, --
  (
    SELECT count(1) FROM scopus_references sr WHERE sr.ref_sgr = scp3 AND sr.scp IN (scp1, scp2)
  ) AS scp3_triplet_citations
FROM sb_plus_triplets.triplets_unique );

