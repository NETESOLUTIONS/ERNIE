-- 1/11/2019
-- adds a column of citation counts 8 years out to public.dataset1995

-- assembled citing references for source_ids in dataset1990
\set ON_ERROR_STOP on
\set ECHO all

\set number_of_years :count
\set temp_table_1 'dataset':year'_temp1'
\set temp_table_pk_1 :temp_table_1'_pk'

\set temp_table_2 'dataset':year'_cit_counts_temp1'
\set temp_table_pk_2 :temp_table_2'_pk'

\set output_table 'dataset':year'_cit_counts'
\set output_table_pk :output_table'_pk'

\set input_table 'dataset':year
-- Column name
\set column_name 'd':year'_source_id'


-- Start execution from here
SET TIMEZONE = 'US/Eastern';

SET SEARCH_PATH = public;

SELECT NOW();

DROP TABLE IF EXISTS :temp_table_1;
CREATE TABLE :temp_table_1 tablespace p2_studies AS
SELECT cited_source_uid AS :column_name,source_id AS citing_pub_id 
FROM wos_references 
WHERE cited_source_uid IN (SELECT DISTINCT source_id FROM :input_table);
CREATE INDEX :temp_table_pk_1 ON :temp_table_1(:column_name,citing_pub_id);

-- restrict citing references to <= 8 years
DROP TABLE IF EXISTS :temp_table_2;
CREATE TABLE :temp_table_2 tablespace p2_studies AS
SELECT a.*,b.publication_year 
FROM :temp_table_1 a 
INNER JOIN wos_publications b
ON a.citing_pub_id=b.source_id
WHERE b.publication_year::int <= CAST(:year AS INT) + CAST(:number_of_years as INT);
CREATE INDEX :temp_table_pk_2 ON :temp_table_2(:column_name,citing_pub_id);

-- convert to count of citing references 
DROP TABLE IF EXISTS :output_table;
CREATE TABLE :output_table tablespace p2_studies AS
SELECT :column_name AS source_id,count(citing_pub_id) AS citation_count
FROM :temp_table_2
GROUP BY source_id;
CREATE INDEX :output_table_pk ON :output_table(source_id);

DROP TABLE :temp_table_1;
DROP TABLE :temp_table_2;
