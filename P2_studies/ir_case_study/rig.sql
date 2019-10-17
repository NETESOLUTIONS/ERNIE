CREATE TABLE rigoutsos_doi_scp_1 AS SELECT scp AS citing_1 ,ref_sgr AS cited_1
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT scp FROM rigoutsos_doi_scp_0);

CREATE TABLE rigoutsos_doi_scp_2 AS SELECT scp AS citing_2 ,ref_sgr AS cited_2
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_1 FROM rigoutsos_doi_scp_1);

CREATE TABLE rigoutsos_doi_scp_3 AS SELECT scp AS citing_3 ,ref_sgr AS cited_3
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_2 FROM rigoutsos_doi_scp_2);

CREATE TABLE rigoutsos_doi_scp_4 AS SELECT scp AS citing_4 ,ref_sgr AS cited_4
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_3 FROM rigoutsos_doi_scp_3);

CREATE TABLE rigoutsos_doi_scp_5 AS SELECT scp AS citing_5 ,ref_sgr AS cited_5
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_4 FROM rigoutsos_doi_scp_4);
CREATE INDEX rigoutsos_doi_scp_5_idx ON rigoutsos_doi_scp_5(citing_5,cited_5) tablespace index_tbs;

CREATE TABLE rigoutsos_doi_scp_6 AS SELECT scp AS citing_6 ,ref_sgr AS cited_6
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_5 FROM rigoutsos_doi_scp_5);
CREATE INDEX rigoutsos_doi_scp_6_idx ON rigoutsos_doi_scp_6(citing_6,cited_6) tablespace index_tbs;

CREATE TABLE rigoutsos_doi_scp_7 AS SELECT scp AS citing_7 ,ref_sgr AS cited_7
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_6 FROM rigoutsos_doi_scp_6);
CREATE INDEX rigoutsos_doi_scp_7_idx ON rigoutsos_doi_scp_7(citing_7,cited_7) tablespace index_tbs;

CREATE TABLE rigoutsos_doi_scp_8 tablespace p2_studies_tbs AS SELECT scp AS citing_8 ,ref_sgr AS cited_8
FROM scopus_references WHERE ref_sgr IN (SELECT DISTINCT citing_7 FROM rigoutsos_doi_scp_7);
CREATE INDEX rigoutsos_doi_scp_8_idx ON rigoutsos_doi_scp_8(citing_7,cited_7) tablespace index_tbs;
