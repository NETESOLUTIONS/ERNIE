-- region wos_pub_core
DROP TABLE IF EXISTS solr_5k_out_temp;
CREATE TABLE solr_5k_out_temp AS
  SELECT
    a.source_id, concat(a.publication_year, ' ', a.document_title, ' ', a.source_title) AS pub_data
  FROM wos_publications a
  WHERE random() < 0.3
  LIMIT 5000;

DROP TABLE IF EXISTS solr_5k_out;
CREATE TABLE solr_5k_out AS
  SELECT
    a.source_id, 0 AS label, concat(string_agg(a.full_name, ' '), ' ', b.pub_data) AS citation
  FROM wos_authors a
    INNER JOIN solr_5k_out_temp b ON a.source_id = b.source_id
  GROUP BY a.source_id, b.pub_data;

DROP TABLE IF EXISTS solr_65m_temp;
CREATE TABLE solr_65m_temp TABLESPACE ernie_wos_tbs AS
  SELECT
    source_id, concat(publication_year, ' ', document_title, ' ', source_title) AS pub_data
  FROM wos_publications
  WHERE source_id NOT IN (
    SELECT source_id
    FROM solr_5k_out);

CREATE INDEX solr_test_wos_ind
  ON solr_65m_temp USING HASH (source_id) TABLESPACE indexes;

DROP TABLE IF EXISTS solr_65m_with_vol;
CREATE TABLE solr_65m_with_vol TABLESPACE ernie_wos_tbs AS
  SELECT
    a.source_id, concat(string_agg(a.full_name, ' '), ' ', b.pub_data) AS citation
  FROM wos_authors a
    INNER JOIN solr_65m_temp b ON a.source_id = b.source_id
  GROUP BY a.source_id, b.pub_data;

DROP TABLE IF EXISTS solr_5k_in;
CREATE TABLE solr_5k_in AS
  SELECT
    source_id, 1 AS label, citation
  FROM solr_65m_with_vol
  WHERE random() < 0.01
  LIMIT 5000;

DROP TABLE IF EXISTS solr_10k_inout;
CREATE TABLE solr_10k_inout AS SELECT *
                               FROM solr_5k_in
                               UNION
                               SELECT *
                               FROM solr_5k_out;
-- endregion

-- region wos_pub_with_vol_core
DROP TABLE IF EXISTS solr_5k_out_with_vol;
CREATE TABLE solr_5k_out_with_vol AS --
  WITH cte AS
  (
    SELECT
      source_id, concat(publication_year, ' ', document_title, ' ', source_title, ' ', volume) AS pub_details
    FROM wos_publications
    WHERE random() < 0.3
    LIMIT 5000
  )
  SELECT
    source_id, 0 AS label, concat(string_agg(wa.full_name, ' '
                                  ORDER BY wa.seq_no), ' ', cte.pub_details) AS citation
  FROM cte
    JOIN wos_authors wa USING (source_id)
  GROUP BY source_id, cte.pub_details;
-- 10m:21s
-- Version with HAVING/LIMIT took 49m:07s

ALTER TABLE solr_5k_out_with_vol
  ADD CONSTRAINT solr_5k_out_with_vol_pk PRIMARY KEY (source_id) USING INDEX TABLESPACE indexes;

DROP TABLE IF EXISTS solr_65m_with_vol;
CREATE TABLE solr_65m_with_vol TABLESPACE ernie_wos_tbs AS --
  WITH cte AS
  (
    SELECT
      source_id, concat(publication_year, ' ', document_title, ' ', source_title, ' ', volume) AS pub_details
    FROM wos_publications
    WHERE source_id NOT IN (
      SELECT source_id
      FROM solr_5k_out_with_vol)
  )
  SELECT
    source_id, 0 AS label, concat(string_agg(wa.full_name, ' ' ORDER BY wa.seq_no), ' ', cte.pub_details) AS citation
  FROM cte
    JOIN wos_authors wa USING (source_id)
  GROUP BY source_id, cte.pub_details;
-- 1h:50m+
-- endregion