SELECT
    ddi.source_id, ddi.document_id, dp.document_title, dp.document_type, dp.publication_year, dp.source_title,
    dp.source_type
  FROM
      dblp_document_identifiers ddi
          JOIN dblp_publications dp ON dp.source_id = ddi.source_id
 WHERE document_id LIKE '%10.1093/bioinformatics%' AND document_id_type = 'ee';

-- AND-query
  WITH cte AS (
      SELECT
          ddi.source_id, ddi.document_id, dp.document_title, length(dp.document_title), dp.document_type,
          dp.publication_year, dp.source_title, dp.source_type
        FROM
            dblp_document_identifiers ddi
                JOIN dblp_publications dp ON dp.source_id = ddi.source_id
       WHERE ddi.document_id LIKE '%10.1093/bioinformatics%' AND ddi.document_id_type = 'ee'
         AND length(dp.document_title) > 30 -- Filter out junk
       ORDER BY ddi.source_id
       LIMIT 20
  )
SELECT
    cte.source_id, cte.document_title AS dblp_title, st.scp, st.title AS scopus_title,
    ts_rank(to_tsvector('english', st.title), plainto_tsquery('english', cte.document_title)) AS rank
  FROM
      cte
          LEFT JOIN scopus_titles st
      ON to_tsvector('english', st.title) @@ plainto_tsquery('english', cte.document_title)
 ORDER BY cte.source_id, rank DESC;

-- OR-query
  WITH cte AS (
      SELECT
          ddi.source_id, ddi.document_id, dp.document_title, length(dp.document_title), dp.document_type,
          dp.publication_year, dp.source_title, dp.source_type,
          to_tsquery(array_to_string(tsvector_to_array(to_tsvector('english', dp.document_title)), ' | ')) AS ts_query
        FROM
            dblp_document_identifiers ddi
                JOIN dblp_publications dp ON dp.source_id = ddi.source_id
       WHERE ddi.document_id LIKE '%10.1093/bioinformatics%' AND ddi.document_id_type = 'ee'
         AND length(dp.document_title) > 30 -- Filter out junk
       ORDER BY ddi.source_id
       LIMIT 20
  )
SELECT
    cte.source_id, cte.document_title AS dblp_title, st.scp, st.title AS scopus_title,
    ts_rank(to_tsvector('english', st.title), ts_query) AS rank
  FROM
      cte
          LEFT JOIN scopus_titles st
      ON to_tsvector('english', st.title) @@ ts_query AND ts_rank(to_tsvector('english', st.title), ts_query) > 0.1
 LIMIT 200;