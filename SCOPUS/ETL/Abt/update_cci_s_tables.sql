/*
  This script updates the main SCOPUS tables per the Abt ETL
*/
INSERT INTO cci_s_affiliations
  SELECT DISTINCT a.affiliation_id, a.parent_affiliation_id, a.scopus_author_count, a.scopus_document_count,
   a.affiliation_name, a.address, a.city, a.state, a.country, a.postal_code, a.organization_type
  FROM
  (cci_s_affiliations_staging a
   INNER JOIN
      (select affiliation_id, max(table_id) as table_id
      from cci_s_affiliations_staging group by affiliation_id) b
   ON a.affiliation_id=b.affiliation_id and a.table_id=b.table_id
    )
ON CONFLICT (affiliation_id)
  DO UPDATE SET  affiliation_id = excluded.affiliation_id, parent_affiliation_id=excluded.parent_affiliation_id, scopus_author_count = excluded.scopus_author_count,
  scopus_document_count = excluded.scopus_document_count,
  affiliation_name = excluded.affiliation_name, address = excluded.address, city = excluded.city, state = excluded.state,
  country = excluded.country, postal_code = excluded.postal_code, organization_type = excluded.organization_type;

INSERT INTO cci_s_documents
  SELECT DISTINCT a.scopus_id, a.title, a.document_type, a.scopus_cited_by_count, a.process_cited_by_count,
   a.publication_name, a.publisher, a.issn, a.volume, a.page_range, a.cover_date, a.publication_year, a.publication_month,
   a.publication_day, a.pubmed_id, a.doi, a.description, a.scopus_first_author_id, a.subject_areas, a.keywords
  FROM
  (cci_s_documents_staging a
    INNER JOIN
    (select scopus_id,max(table_id) as table_id
              from cci_s_documents_staging group by scopus_id) b
  ON a.scopus_id=b.scopus_id and a.table_id=b.table_id
 )
ON CONFLICT (scopus_id)
  DO UPDATE SET  scopus_id = excluded.scopus_id, title = excluded.title,document_type = excluded.document_type,
  scopus_cited_by_count = excluded.scopus_cited_by_count, process_cited_by_count = excluded.process_cited_by_count,
  publication_name = excluded.publication_name,publisher = excluded.publisher, issn = excluded.issn, volume = excluded.volume,
  page_range = excluded.page_range, cover_date = excluded.cover_date, publication_year = excluded.publication_year,
  publication_month = excluded.publication_month, publication_day = excluded.publication_day,
  pubmed_id = excluded.pubmed_id, doi = excluded.doi,
  description = excluded.description, scopus_first_author_id = excluded.scopus_first_author_id, subject_areas = excluded.subject_areas,
  keywords = excluded.keywords;

INSERT INTO cci_s_authors
  SELECT DISTINCT a.author_id, a.indexed_name, a.surname, a.given_name, a.initials, a.scopus_co_author_count, a.process_co_author_count,
   a.scopus_document_count, a.process_document_count, a.scopus_citation_count, a.scopus_cited_by_count, a.alias_author_id
  FROM
  (cci_s_authors_staging a
  INNER JOIN (select author_id, max(table_id) as table_id
  from cci_s_authors_staging group by author_id) b
  ON a.author_id=b.author_id and a.table_id=b.table_id
)
ON CONFLICT (author_id)
  DO UPDATE SET  author_id = excluded.author_id, indexed_name = excluded.indexed_name,surname = excluded.surname,
  given_name = excluded.given_name, initials = excluded.initials,
  scopus_co_author_count = excluded.scopus_co_author_count,process_co_author_count = excluded.process_co_author_count,
  scopus_document_count = excluded.scopus_document_count, process_document_count = excluded.process_document_count,
  scopus_citation_count = excluded.scopus_citation_count, scopus_cited_by_count = excluded.scopus_cited_by_count,
  alias_author_id = excluded.alias_author_id;

INSERT INTO cci_s_author_affiliation_mappings
  SELECT DISTINCT author_id, affiliation_id
  FROM cci_s_author_affiliation_mappings_staging
ON CONFLICT (author_id, affiliation_id)
  DO UPDATE SET  author_id = excluded.author_id, affiliation_id = excluded.affiliation_id;

INSERT INTO cci_s_author_document_mappings
  SELECT DISTINCT author_id,scopus_id
  FROM cci_s_author_document_mappings_staging
ON CONFLICT (author_id, scopus_id)
  DO UPDATE SET  author_id = excluded.author_id, scopus_id = excluded.scopus_id;

INSERT INTO cci_s_document_affiliation_mappings
  SELECT DISTINCT scopus_id,affiliation_id
  FROM cci_s_document_affiliation_mappings_staging
ON CONFLICT (scopus_id, affiliation_id)
  DO UPDATE SET  scopus_id = excluded.scopus_id, affiliation_id = excluded.affiliation_id;

INSERT INTO cci_s_documents_citations
  SELECT DISTINCT citing_scopus_id,cited_scopus_id
  FROM cci_s_documents_citations_staging
ON CONFLICT (citing_scopus_id, cited_scopus_id)
  DO UPDATE SET  citing_scopus_id = excluded.citing_scopus_id, cited_scopus_id = excluded.cited_scopus_id;

INSERT INTO cci_s_author_search_results
  SELECT DISTINCT a.surname, a.given_name, a.author_id, a.award_number,
    a.first_year, a.manual_selection, a.query_string
  FROM cci_s_author_search_results_staging a
ON CONFLICT (author_id, award_number, surname, given_name)
  DO UPDATE SET  surname = excluded.surname, given_name = excluded.given_name,
  author_id = excluded.author_id, award_number = excluded.award_number, first_year = excluded.first_year,
  manual_selection = excluded.manual_selection,query_string = excluded.query_string;

INSERT INTO cci_s_document_search_results
  SELECT DISTINCT a.submitted_title, a.submitted_doi, a.document_type,
    a.scopus_id, a.award_number, a.phase, a.first_year, a.manual_selection,
    a.query_string
  FROM
  (cci_s_document_search_results_stg a
    INNER JOIN
    (select scopus_id, award_number, submitted_title,max(table_id) as table_id
              from cci_s_document_search_results_stg group by scopus_id, award_number, submitted_title) b
    ON a.table_id=b.table_id
)
WJERE a.submitted_doi!=''
ON CONFLICT (scopus_id, award_number, submitted_title)
  DO UPDATE SET  submitted_title = excluded.submitted_title, submitted_doi = excluded.submitted_doi,
  document_type = excluded.document_type, award_number = excluded.award_number,
  phase=excluded.phase, first_year = excluded.first_year, manual_selection = excluded.manual_selection,
  query_string = excluded.query_string;
