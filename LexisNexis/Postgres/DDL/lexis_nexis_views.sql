CREATE OR REPLACE VIEW lexis_nexis_scopus_citations
AS
SELECT
  country_code, doc_number, kind_code, CAST(substring(scopus_url FROM 'eid=2-s2.0-(\d+)') AS BIGINT) AS scp,
    scopus_url
  FROM lexis_nexis_nonpatent_literature_citations
  WHERE scopus_url IS NOT NULL;

COMMENT ON VIEW lexis_nexis_scopus_citations IS 'Cited scopus publications. SCPs are extracted from Scopus URLs.';