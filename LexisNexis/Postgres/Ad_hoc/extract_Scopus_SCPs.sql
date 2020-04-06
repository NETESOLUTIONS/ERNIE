SELECT doc_number, CAST(substring(scopus_url FROM 'eid=2-s2.0-(\d+)') AS BIGINT) AS scp, scopus_url
  FROM lexis_nexis_nonpatent_literature_citations
 LIMIT 50;

SELECT doc_number, scopus_url, REGEXP_MATCHES(scopus_url, '[0-9]{10}')
  FROM lexis_nexis_nonpatent_literature_citations
 LIMIT 50;

SELECT *
  FROM lexis_nexis_nonpatent_literature_citations
  WHERE scp = :scp;
-- 4721759: 0.1s, 2 rows

SELECT *
  FROM lexis_nexis_scopus_citations
 WHERE scp = :scp;
-- 4721759: 0.1s, 2 rows
-- 1501964: 0.1s, 4 rows