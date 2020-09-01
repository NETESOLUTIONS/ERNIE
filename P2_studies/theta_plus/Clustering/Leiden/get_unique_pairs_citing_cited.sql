-- Create a new table from citing_cited table where the new
-- table has no reverse-duplicates (unique undirected edges)

\set ON_ERROR_STOP on
\set ECHO all
SET search_path = :schema;

\set unique_pairs_table :citing_cited_table'_unique_pairs'

DROP TABLE IF EXISTS :unique_pairs_table;

CREATE TABLE :unique_pairs_table AS
SELECT * FROM :citing_cited_table;

DELETE FROM :unique_pairs_table a
USING  :unique_pairs_table b
WHERE  (a.citing, a.cited) = (b.cited, b.citing)
    AND a.cited > a.citing;

    
