\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_merge_abstracts_and_titles()
  LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO scopus_abstracts(scp, abstract_language, abstract_text)
  SELECT DISTINCT scopus_publications.scp, abstract_language, abstract_text
    FROM stg_scopus_abstracts, scopus_publications
   WHERE stg_scopus_abstracts.scp = scopus_publications.scp
      ON CONFLICT (scp,abstract_language) DO --
        UPDATE SET abstract_text=excluded.abstract_text;

  INSERT INTO scopus_titles(scp, title, language)
  SELECT scopus_publications.scp, max(title) AS title, max(language) AS language
    FROM stg_scopus_titles stg, scopus_publications
   WHERE stg.scp = scopus_publications.scp
   GROUP BY scopus_publications.scp
      ON CONFLICT (scp, language) DO UPDATE SET title=excluded.title;
END $$;