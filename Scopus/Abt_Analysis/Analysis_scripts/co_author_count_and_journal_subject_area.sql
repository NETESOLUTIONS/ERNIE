SET search_path TO public
-- co-author count for per center
CREATE TABLE abt_sl_sr_pubs AS
  SELECT a.*
  FROM cci_s_author_document_mappings a
  INNER JOIN sl_sr_all_authors_combined b ON a.author_id = b.author_id;

CREATE TABLE abt_valid_pubs AS
  SELECT t2.author_id, t1.scopus_id, t1.award_number, t1.first_year, t1.duration, t3.publication_year
  FROM abt_author_phase_duration t1
  INNER JOIN cci_s_author_document_mappings t2 ON t1.scopus_id = t2.scopus_id
  INNER JOIN cci_s_documents_jeroen_updated t3 ON t2.scopus_id = t3.scopus_id
  WHERE t3.scopus_id IN
          (SELECT DISTINCT scopus_id
           FROM abt_sl_sr_pubs) AND t3.publication_year BETWEEN t1.first_year AND t1.first_year + duration;

DROP TABLE IF EXISTS public.cci_s_co_author_count;
CREATE TABLE cci_s_co_author_count AS
  SELECT a.award_number, b.official_center_name, count(DISTINCT author_id)
  FROM abt_valid_pubs a
  INNER JOIN cci_award_names b ON a.award_number = b.award_number
  GROUP BY a.award_number, b.official_center_name
  ORDER BY count DESC;

-- co-author conut for 596 papers
CREATE TABLE abt_award_papers AS
  SELECT DISTINCT a.scopus_id,
                  b.award_number,
                  b.phase,
                  b.first_year,
                  CASE WHEN b.phase = 'I' THEN 3 ELSE 5 END AS duration
  FROM cci_s_award_paper_matches a
  INNER JOIN cci_phase_awards b ON a.award_number = b.award_number
  WHERE phase IS NOT NULL;

CREATE TABLE abt_valid_award_papers AS
  SELECT t2.author_id, t1.scopus_id, t1.award_number, t1.first_year, t1.duration, t3.publication_year
  FROM abt_award_papers t1
  INNER JOIN cci_s_author_document_mappings t2 ON t1.scopus_id = t2.scopus_id
  INNER JOIN cci_s_documents_jeroen_updated t3 ON t2.scopus_id = t3.scopus_id
  WHERE t3.scopus_id IN
          (SELECT DISTINCT scopus_id
           FROM abt_sl_sr_pubs) AND t3.publication_year BETWEEN t1.first_year AND t1.first_year + duration;

DROP TABLE IF EXISTS cci_s_award_co_author_count;
CREATE TABLE public.cci_s_award_co_author_count AS
  SELECT a.award_number, b.official_center_name, count(DISTINCT author_id)
  FROM abt_valid_award_papers a
  INNER JOIN cci_award_names b ON a.award_number = b.award_number
  GROUP BY a.award_number, b.official_center_name
  ORDER BY count DESC;

-- Journal subject table
CREATE TABLE abt_subject_area_union AS
  SELECT t1.scopus_id, t.*
  FROM cci_s_documents_jeroen_updated t1
  INNER JOIN
    (SELECT issn, string_agg(DISTINCT subject_areas, ',') AS subject_areas
     FROM cci_s_documents_jeroen_updated t
     WHERE t.issn IS NOT NULL AND t.subject_areas IS NOT NULL
     GROUP BY issn) AS t ON t1.issn = t.issn;

DROP TABLE IF EXISTS cci_s_journal_subject;
CREATE TABLE public.cci_s_journal_subject AS
  SELECT DISTINCT c.official_center_name, b.award_number, a.issn, a.subject_areas
  FROM abt_subject_area_union a
  INNER JOIN abt_valid_pubs b ON a.scopus_id = b.scopus_id
  INNER JOIN cci_award_names c ON c.award_number = b.award_number;

DROP TABLE IF EXISTS cci_s_journal_subject_award_paper;
CREATE TABLE public.cci_s_journal_subject_award_paper AS
  SELECT DISTINCT c.official_center_name, b.award_number, a.issn, a.subject_areas
  FROM abt_subject_area_union a
  INNER JOIN abt_award_papers b ON a.scopus_id = b.scopus_id
  INNER JOIN cci_award_names c ON c.award_number = b.award_number;
