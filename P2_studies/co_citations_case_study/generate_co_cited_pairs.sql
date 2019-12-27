\set ON_ERROR_STOP on
\set ECHO all

\set dataset 'dataset':year
\set obs_freq 'obs_freq_':year
\set col_name 'frequency_':year
\set dataset_index 'obs_freq_':year'_i'

SET TIMEZONE = 'US/Eastern';

SET SEARCH_PATH = cc2;

DROP TABLE IF EXISTS :dataset CASCADE;

CREATE TABLE :obs_freq
    TABLESPACE p2_studies_tbs
    AS
    WITH cte AS (
        SELECT source_id, cited_source_uid
        FROM :dataset d
                 JOIN scopus_citation_counts_hazen scch
                      ON d.cited_source_uid = scch.scp
        WHERE scch.hazen_perc >= 99
    )
    SELECT c1.cited_source_uid AS cited_1,
           c2.cited_source_uid AS cited_2,
           count(*)            AS :col_name
    FROM cte c1
    JOIN cte c2
    ON c1.source_id = c2.source_id
    AND c1.cited_source_uid < c2.cited_source_uid
    GROUP BY c1.cited_source_uid, c2.cited_source_uid;

CREATE INDEX IF NOT EXISTS :dataset_index ON :dataset (cited_1,cited_2) TABLESPACE index_tbs;