-- script to create a four column dataset for graph analysis from 
-- dresselhaus base, cited, and citing 

-- assemble all pubs authored by Dresselhaus using her auid
DROP TABLE IF EXISTS kavli_mdressel_base;
CREATE TABLE public.kavli_mdressel_base AS
SELECT DISTINCT scp FROM scopus_authors
WHERE auid =35416802700 OR auid=16026240300;

-- assemble pubs cited by Dresselhaus papers
DROP TABLE IF EXISTS kavli_mdressel_cited;
CREATE TABLE public.kavli_mdressel_cited AS
SELECT scp AS base, ref_sgr AS cited
FROM scopus_references
WHERE scp IN (
SELECT scp FROM kavli_mdressel_base);

-- assemble pubs that cite the Dresselhaus papers
DROP TABLE IF EXISTS kavli_mdressel_citing;
CREATE TABLE public.kavli_mdressel_citing AS
SELECT scp as citing, ref_sgr AS base
FROM scopus_references
WHERE ref_sgr IN(
SELECT scp FROM kavli_mdressel_base);

--assemble all cited references from the pubs that cite the Dresselhaus papers
DROP TABLE IF EXISTS kavli_mdressel_citing_cited_all;
CREATE TABLE kavli_mdressel_citing_cited_all AS
SELECT scp AS mdressel_citing, ref_sgr AS cited
FROM scopus_references
WHERE scp IN(
SELECT citing FROM kavli_mdressel_citing);

-- reformat kavli_mdressel_cited as an edge list
DROP TABLE IF EXISTS kavli_mdressel_cited_4col;
CREATE TABLE public.kavli_mdressel_cited_4col AS
SELECT base AS source, 'seed' AS stype, cited AS target, 'cited' AS ttype
FROM kavli_mdressel_cited;

UPDATE kavli_mdressel_cited_4col
SET  ttype='seed' WHERE target IN (
SELECT scp FROM kavli_mdressel_base);

-- reformat kavli_mdressel_citing as an edge list
DROP TABLE IF EXISTS kavli_mdressel_citing_4col;
CREATE TABLE public.kavli_mdressel_citing_4col AS
SELECT citing AS source, 'citing' AS stype, base as target, 'seed' as ttype
FROM kavli_mdressel_citing;

UPDATE kavli_mdressel_citing_4col
SET stype='seed' WHERE source IN (
SELECT scp FROM kavli_mdressel_base);

--reformat kavli_mdressel_citing_cited_all as an edge list
DROP TABLE IF EXISTS kavli_mdressel_citing_cited_all_4col;
CREATE TABLE kavli_mdressel_citing_cited_all_4col AS
SELECT mdressel_citing AS source, 'citing' AS stype,
cited AS target, 'cited' AS ttype
FROM kavli_mdressel_citing_cited_all;

UPDATE kavli_mdressel_citing_cited_all_4col
SET ttype='seed' WHERE target IN (
SELECT scp FROM kavli_mdressel_base);

UPDATE kavli_mdressel_citing_cited_all_4col
SET stype='seed' WHERE source in (
SELECT scp FROM kavli_mdressel_base);
DROP TABLE IF EXISTS kavli_mdressel_combined_4col_temp;
CREATE TABLE public.kavli_mdressel_combined_4col_temp AS
(SELECT * FROM kavli_mdressel_cited_4col)
UNION (SELECT * FROM kavli_mdressel_citing_4col)
UNION (SELECT * FROM kavli_mdressel_citing_cited_all_4col);
CREATE INDEX kavli_mdressel_combined_4col_temp_idx ON kavli_mdressel_combined_4col_temp(source,target);
DROP TABLE IF EXISTS kavli_mdressel_combined_4col;
CREATE TABLE PUBLIC.kavli_mdressel_combined_4col
AS SELECT DISTINCT * FROM kavli_mdressel_combined_4col_temp;
