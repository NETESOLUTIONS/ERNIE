-- Conference papers
SELECT sspd.conf_name, st.title, sp.*
  FROM
      scopus_source_publication_details sspd
          JOIN scopus_publications sp ON sp.scp = sspd.scp
          JOIN scopus_titles st ON st.scp = sp.scp
 WHERE to_tsvector('english', sspd.conf_name) @@ phraseto_tsquery(
         'Annual International Conference on Research in Computational Molecular Biology')
 ORDER BY conf_name, sp.scp;
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
 WHERE to_tsvector('english', sspd.conf_name) @@ plainto_tsquery('RECOMB')
 ORDER BY conf_name, sp.scp;
-- 1m:32s