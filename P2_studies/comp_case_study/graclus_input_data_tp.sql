-- Generate input dataset for graclus software
-- dataset_graclus_data is the input file
-- dataset_graclus_coded contains the coded values


\set ON_ERROR_STOP on
\set ECHO all

\set dataset_graclus_data 'graclus_':dataset
\set dataset_graclus_coded 'graclus_coded_':dataset

SET SEARCH_PATH TO theta_plus;

DROP TABLE IF EXISTS :dataset_graclus_data;
CREATE TABLE :dataset_graclus_data TABLESPACE theta_plus_tbs AS
    WITH combined_data AS (
        SELECT citing, cited
        FROM :dataset
        WHERE citing != cited
        UNION
        SELECT cited,
               citing
        FROM :dataset
        WHERE citing != cited
    ),
         combined_rank AS (
             SELECT *,
                    dense_rank() OVER (ORDER BY citing)        AS citing_id,
                    dense_rank() OVER (ORDER BY cited) AS cited_id
             FROM combined_data
             ORDER BY citing,
                      cited
         )
    SELECT citing_id, string_agg(cited_id::text, E'\t')
    FROM combined_rank
    GROUP BY citing_id
    ORDER BY citing_id;

DROP TABLE IF EXISTS :dataset_graclus_coded;
CREATE TABLE :dataset_graclus_coded TABLESPACE theta_plus_tbs AS
    WITH combined_data AS (
        SELECT citing, cited
        FROM :dataset
        WHERE citing != cited
        UNION
        SELECT cited,
               citing
        FROM :dataset
        WHERE citing != cited
    )
    SELECT citing,
           dense_rank() OVER (ORDER BY citing)        AS citing_id
--            dense_rank() OVER (ORDER BY cited) AS cited_id
    FROM combined_data
    ORDER BY citing;
