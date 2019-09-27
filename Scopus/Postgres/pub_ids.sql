-- Duplicate DOIs
  WITH cte AS (
    SELECT a.doi, b.scp
      FROM
        ismb_eccb_2018_2009_dois a
          INNER JOIN scopus_publication_identifiers b ON a.doi = b.document_id
     WHERE b.document_id_type = 'DOI'
  )
SELECT doi
  FROM cte
 GROUP BY doi
HAVING count(cte.scp) > 1;

-- Pubs per a dupe DOI
-- 10.1093/bioinformatics/btq386
-- 10.1001/archderm.100.4.501
SELECT *
  FROM scopus_publication_identifiers
 WHERE document_id_type = 'DOI' AND document_id = :'doi';

SELECT *
FROM scopus_publications
WHERE scp IN ('84983122778', '77956496698');
