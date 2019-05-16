-- I was asked to test the performance of some queries as a function of input-scale--

-- set up timing--

\timing on

-- 1. For a given scp (unique identifier of paper) list all the works cited --

SELECT ref_sgr FROM scopus_references WHERE scp IN (SELECT scp FROM scopus_references limit 10);

-- 2. Inverse of 1. --

SELECT scp FROM scopus_references WHERE ref_sgr IN (SELECT ref_sgr FROM scopus_references limit 10);

-- 3. Join tables For a given set of scp's generate a table that contains scp, title, author list
--  and author_ids, title, journal, volume, page, publication_year, doi, and pmid if it exists. --

CREATE TABLE djamil_publication_information AS
SELECT a.scp,
       b.title,
       f.source_title,
       c.volume,
       c.first_page,
       c.last_page,
       c.publication_year,
       d.document_id,
       d.document_id_type,
       e.auid,
       concat(e.author_surname, ', ', e.author_given_name) AS full_name
FROM scopus_publications a INNER JOIN scopus_titles b on a.scp = b.scp
INNER JOIN scopus_sources f on a.ernie_source_id=f.ernie_source_id
INNER JOIN scopus_source_publication_details c on a.scp=c.scp
INNER JOIN scopus_publication_identifiers d on a.scp=d.scp
INNER JOIN scopus_authors e on a.scp=e.scp
WHERE a.scp IN ( SELECT scp FROM scopus_publications LIMIT 1000)
and (b.language='English') and (d.document_id_type= 'MEDL' or d.document_id_type='DOI');

CREATE TABLE djamil_author_information AS
SELECT scp,
       string_agg(full_name, '/ ') AS list_of_authors,
       string_agg(auid::text, ', ')
FROM djamil_publication_information
GROUP BY scp;

-- 4. INNER JOIN the two tables --

CREATE TABLE djamil_author_pub_information AS
SELECT DISTINCT a.scp,
       a.title,
       a.source_title,
       a.volume,
       a.first_page,
       a.last_page,
       a.publication_year,
       a.document_id,
       a.document_id_type,
       a.auid,
       b.list_of_authors
FROM djamil_author_information b INNER JOIN djamil_publication_information a on a.scp=b.scp
WHERE a.scp IN ( SELECT scp FROM djamil_author_information);