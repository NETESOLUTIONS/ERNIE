-- Indexed data
SELECT
  a.source_title,
  a.source_id,
  a.publication_year,
  a.publisher_name,
  a.document_title,
  a.volume,
  string_agg(b.full_name, ' ') AS authors
FROM wos_authors b INNER JOIN wos_publications a
  ON a.source_id = b.source_id
WHERE a.source_id = 'WOS:000255407400009'
GROUP BY a.source_id;

SELECT *
FROM kb_data_plus_wos_ids
WHERE wos_id = 'WOS:000255407400009';

-- Cited
SELECT *
FROM wos_references
WHERE source_id = 'WOS:000255407400009'
ORDER BY cited_year;

-- Citing
SELECT wr.wos_reference_id, wp.*
FROM wos_references wr
  JOIN wos_publications wp USING (source_id)
WHERE wr.cited_source_uid = 'WOS:000255407400009'
ORDER BY wp.publication_year;