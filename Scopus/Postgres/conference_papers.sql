-- Conference papers + additional publications with the same title
  WITH cte AS (
      SELECT sspd.conf_name, st.title, sp.*
        FROM
            scopus_source_publication_details sspd
                JOIN scopus_publications sp ON sp.scp = sspd.scp
                JOIN scopus_titles st ON st.scp = sp.scp
       WHERE to_tsvector('english', sspd.conf_name) @@ plainto_tsquery('RECOMB')
  )
SELECT *
  FROM cte
 UNION ALL
SELECT sspd.conf_name, st.title, sp.*
  FROM
      cte
          JOIN scopus_titles st ON to_tsvector('english', st.title) @@ phraseto_tsquery(cte.title) AND st.scp <> cte.scp
          JOIN scopus_publications sp ON sp.scp = st.scp AND sp.citation_type = 'cp'
          JOIN scopus_source_publication_details sspd ON sspd.scp = sp.scp
 WHERE length(cte.title) > 30 -- Filter out 'Preface' and other potential junk or common titles
;
-- 6.7s

-- Conference papers + additional publications with the same title
  WITH cte AS (
      SELECT sspd.conf_name, st.title, sp.*
        FROM
            scopus_source_publication_details sspd
                JOIN scopus_publications sp ON sp.scp = sspd.scp
                JOIN scopus_titles st ON st.scp = sp.scp
       WHERE to_tsvector('english', sspd.conf_name) @@ plainto_tsquery('RECOMB') AND to_tsvector('english', st.title)
               @@ phraseto_tsquery('An algorithmic framework for predicting side effects of drugs')
  )
SELECT *
  FROM cte
 UNION ALL
SELECT sspd.conf_name, st.title, sp.*
  FROM
      cte
          JOIN scopus_titles st ON to_tsvector('english', st.title) @@ plainto_tsquery(cte.title) AND st.scp <> cte.scp
          JOIN scopus_publications sp ON sp.scp = st.scp AND sp.citation_type = 'cp'
          JOIN scopus_source_publication_details sspd ON sspd.scp = sp.scp
 WHERE length(cte.title) > 30 -- Filter out 'Preface' and other potential junk or common titles
;

-- Conference papers
SELECT sspd.conf_name, st.title, sp.*
  FROM
      scopus_source_publication_details sspd
          JOIN scopus_publications sp ON sp.scp = sspd.scp
          JOIN scopus_titles st ON st.scp = sp.scp
 WHERE to_tsvector('english', sspd.conf_name) @@ phraseto_tsquery(
         'Annual International Conference on Research in Computational Molecular Biology');
-- 3.6s

-- Conferences
SELECT DISTINCT sspd.conf_name
  FROM scopus_source_publication_details sspd
 WHERE to_tsvector('english', sspd.conf_name) @@ plainto_tsquery('RECOMB')
 ORDER BY conf_name;
-- 1m:32s

-- Conference papers
SELECT sspd.conf_name, st.title, sp.*
  FROM
      scopus_source_publication_details sspd
          JOIN scopus_publications sp ON sp.scp = sspd.scp
          JOIN scopus_titles st ON st.scp = sp.scp
 WHERE to_tsvector('english', sspd.conf_name) @@ plainto_tsquery('RECOMB');
-- 1m:32s-2m:29

-- Multiple conference papers with the same title
SELECT st.title, sp.*, ss.*, sspd.*, sce.*
  FROM
      scopus_titles st
          JOIN scopus_publications sp ON sp.scp = st.scp
          JOIN scopus_sources ss ON ss.ernie_source_id = sp.ernie_source_id
          JOIN scopus_source_publication_details sspd ON sspd.scp = sp.scp
          JOIN scopus_conference_events sce ON sce.conf_code = sspd.conf_code AND sce.conf_name = sspd.conf_name
--  WHERE to_tsvector('english', st.title) @@ plainto_tsquery('An algorithmic framework for predicting side-effects of drugs')
 WHERE to_tsvector('english', st.title) @@ to_tsquery('algorithmic & framework & predicting & drug & side');

SELECT plainto_tsquery('An algorithmic framework for predicting side-effects of drugs');