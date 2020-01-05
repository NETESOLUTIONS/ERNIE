-- Extracted duplicate DOIs
SELECT *
FROM duplicate_scp_doi
ORDER BY count DESC;

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
-- 10.1093/bioinformatics/btq386: 2 scps - 84983122778, 77956496698
-- 10.1001/archderm.100.4.501
-- 10.1201/9780203504086: 42 scps
SELECT
  spi.document_id AS doi, sp.scp, sp.date_sort, sp.correspondence_person_indexed_name, sp.correspondence_orgs,
  sp.pub_type, sp.citation_type, sp.process_stage, sp.state, sp.ernie_source_id, sp.citation_language
  FROM scopus_publication_identifiers spi
  JOIN scopus_publications sp USING (scp)
 WHERE spi.document_id_type = 'DOI' AND spi.document_id = :'doi';
