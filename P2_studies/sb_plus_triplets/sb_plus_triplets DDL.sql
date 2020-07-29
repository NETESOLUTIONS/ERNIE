-- sb_plus_triplets DDL


CREATE INDEX triplets_citing_nodes_idx
ON sb_plus_triplets.triplets_citing_nodes(scp)
TABLESPACE index_tbs;

CREATE TABLE sb_plus_triplets.triplets_cited
TABLESPACE sb_plus_tbs AS
SELECT tcn.scp as citing, sr.ref_sgr AS cited
FROM sb_plus_triplets.triplets_citing_nodes tcn
INNER JOIN public.scopus_references sr on tcn.scp = sr.scp;

CREATE INDEX sb_plus_triplets.triplets_cited_idx
ON sb_plus_triplets.triplets_cited(citing,cited)
TABLESPACE index_tbs;
-- clean up Scopus data
DELETE FROM sb_plus_triplets.triplets_cited
WHERE citing=cited; -- there are 5 instances of self-citations

CREATE TABLE sb_plus_triplets.triplets_citing
TABLESPACE sb_plus_tbs AS
SELECT sr.scp as citing,tcn.scp as cited
FROM sb_plus_triplets.triplets_citing_nodes tcn
INNER JOIN public.scopus_references sr on tcn.scp=sr.ref_sgr;

CREATE INDEX sb_plus_triplets.triplets_citing_idx
ON sb_plus_triplets.triplets_citing(citing,cited)
TABLESPACE index_tbs;

-- clean up Scopus data
DELETE FROM sb_plus_triplets.triplets_citing
WHERE citing=cited; -- there are 5 instances of self-citations




