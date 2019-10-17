--
--

DROP TABLE IF EXISTS rigoutsos_doi_scp_1;
CREATE TABLE rigoutsos_doi_scp_1 AS SELECT scp AS citing_1, ref_sgr AS cited_1
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT scp FROM rigoutsos_doi_scp_0);

DROP TABLE IF EXISTS rigoutsos_doi_scp_2;
CREATE TABLE rigoutsos_doi_scp_2 AS SELECT scp AS citing_2 ,ref_sgr AS cited_2
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_1 FROM rigoutsos_doi_scp_1);

DROP TABLE IF EXISTS rigoutsos_doi_scp_3;
CREATE TABLE rigoutsos_doi_scp_3 AS SELECT scp AS citing_3 ,ref_sgr AS cited_3
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_2 FROM rigoutsos_doi_scp_2);

DROP TABLE IF EXISTS rigoutsos_doi_scp_4;
CREATE TABLE rigoutsos_doi_scp_4 AS SELECT scp AS citing_4 ,ref_sgr AS cited_4
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_3 FROM rigoutsos_doi_scp_3);

DROP TABLE IF EXISTS rigoutsos_doi_scp_5;
CREATE TABLE rigoutsos_doi_scp_5 AS SELECT scp AS citing_5 ,ref_sgr AS cited_5
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_4 FROM rigoutsos_doi_scp_4);
CREATE INDEX rigoutsos_doi_scp_5_idx ON rigoutsos_doi_scp_5(citing_5,cited_5) tablespace index_tbs;

DROP TABLE IF EXISTS rigoutsos_doi_scp_6;
CREATE TABLE rigoutsos_doi_scp_6 AS SELECT scp AS citing_6 ,ref_sgr AS cited_6
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_5 FROM rigoutsos_doi_scp_5);
CREATE INDEX rigoutsos_doi_scp_6_idx ON rigoutsos_doi_scp_6(citing_6,cited_6) tablespace index_tbs;

DROP TABLE IF EXISTS rigoutsos_doi_scp_7;
CREATE TABLE rigoutsos_doi_scp_7 AS SELECT scp AS citing_7 ,ref_sgr AS cited_7
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_6 FROM rigoutsos_doi_scp_6);
CREATE INDEX rigoutsos_doi_scp_7_idx ON rigoutsos_doi_scp_7(citing_7,cited_7) tablespace index_tbs;

DROP TABLE IF EXISTS rigoutsos_doi_scp_8;
CREATE TABLE rigoutsos_doi_scp_8 tablespace p2_studies_tbs AS SELECT scp AS citing_8 ,ref_sgr AS cited_8
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_7 FROM rigoutsos_doi_scp_7);
CREATE INDEX rigoutsos_doi_scp_8_idx ON rigoutsos_doi_scp_8(citing_8,cited_8) tablespace index_tbs;

DROP TABLE IF EXISTS rigoutsos_doi_scp_9;
CREATE TABLE rigoutsos_doi_scp_9 tablespace p2_studies_tbs AS SELECT scp AS citing_9, ref_sgr AS cited_9
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_8 FROM rigoutsos_doi_scp_8);
CREATE INDEX rigoutsos_doi_scp_9_idx ON rigoutsos_doi_scp_9(citing_9,cited_9) tablespace index_tbs;

DROP TABLE IF EXISTS rigoutsos_doi_scp_10;
CREATE TABLE rigoutsos_doi_scp_10 tablespace p2_studies_tbs AS SELECT scp AS citing_10, ref_sgr AS cited_10
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_9 FROM rigoutsos_doi_scp_9);
CREATE INDEX rigoutsos_doi_scp_10_idx ON rigoutsos_doi_scp_10(citing_10,cited_10) tablespace index_tbs;

DROP TABLE IF EXISTS rigoutsos_doi_scp_11;
CREATE TABLE rigoutsos_doi_scp_11 tablespace p2_studies_tbs AS SELECT scp AS citing_11, ref_sgr AS cited_11
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_10 FROM rigoutsos_doi_scp_10);
CREATE INDEX rigoutsos_doi_scp_11_idx ON rigoutsos_doi_scp_11(citing_11, cited_11) tablespace index_tbs;

DROP TABLE IF EXISTS rigoutsos_doi_scp_12;
CREATE TABLE rigoutsos_doi_scp_12 tablespace p2_studies_tbs AS SELECT scp AS citing_12, ref_sgr AS cited_12
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_11 FROM rigoutsos_doi_scp_11);
CREATE INDEX rigoutsos_doi_scp_12_idx ON rigoutsos_doi_scp_12(citing_12, cited_12) tablespace index_tbs;

DROP TABLE IF EXISTS rigoutsos_doi_scp_13;
CREATE TABLE rigoutsos_doi_scp_13 tablespace p2_studies_tbs AS SELECT scp AS citing_13, ref_sgr AS cited_13
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_12 FROM rigoutsos_doi_scp_12);
CREATE INDEX rigoutsos_doi_scp_13_idx ON rigoutsos_doi_scp_13(citing_13, cited_13) tablespace index_tbs;

DROP TABLE IF EXISTS rigoutsos_doi_scp_14;
CREATE TABLE rigoutsos_doi_scp_14 tablespace p2_studies_tbs AS SELECT scp AS citing_14, ref_sgr AS cited_14
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_13 FROM rigoutsos_doi_scp_13);
CREATE INDEX rigoutsos_doi_scp_14_idx ON rigoutsos_doi_scp_14(citing_14, cited_14) tablespace index_tbs;

DROP TABLE IF EXISTS rigoutsos_doi_scp_15;
CREATE TABLE rigoutsos_doi_scp_15 tablespace p2_studies_tbs AS SELECT scp AS citing_15, ref_sgr AS cited_15
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_14 FROM rigoutsos_doi_scp_14);
CREATE INDEX rigoutsos_doi_scp_15_idx ON rigoutsos_doi_scp_15(citing_15A, cited_15) tablespace index_tbs;

