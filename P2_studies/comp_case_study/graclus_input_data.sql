\set ON_ERROR_STOP on
\set ECHO all

\set dataset_graclus_data 'graclus_':dataset
\set dataset_graclus_coded 'graclus_coded':dataset

SET SEARCH_PATH TO public;

CREATE TABLE :dataset_graclus_data TABLESPACE p2_studies_tbs AS
    WITH combined_data AS (
        SELECT source_id, cited_source_uid
        FROM :dataset
        WHERE source_id != cited_source_uid
        UNION
        SELECT cited_source_uid,
               source_id
        FROM :dataset
        WHERE source_id != cited_source_uid
    ),
         combined_rank AS (
             SELECT *,
                    dense_rank() OVER (ORDER BY source_id)        AS s_id,
                    dense_rank() OVER (ORDER BY cited_source_uid) AS csi_id
             FROM combined_data
             ORDER BY source_id,
                      cited_source_uid
         )
    SELECT s_id, string_agg(csi_id::text, E'\t')
    FROM combined_rank
    GROUP BY s_id
    ORDER BY s_id;

CREATE TABLE :dataset_graclus_coded TABLESPACE p2_studies_tbs AS
    WITH combined_data AS (
        SELECT source_id, cited_source_uid
        FROM :dataset
        WHERE source_id != cited_source_uid
        UNION
        SELECT cited_source_uid,
               source_id
        FROM :dataset
        WHERE source_id != cited_source_uid
    )
    SELECT source_id,
           dense_rank() OVER (ORDER BY source_id)        AS s_id,
--            dense_rank() OVER (ORDER BY cited_source_uid) AS csi_id
    FROM combined_data
    ORDER BY source_id;
