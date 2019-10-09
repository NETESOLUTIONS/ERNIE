\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- TODO JOIN to scopus_publications looks unnecessary
CREATE OR REPLACE PROCEDURE stg_scopus_merge_publication_identifiers()
  LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO scopus_publication_identifiers(scp, document_id, document_id_type)
  SELECT DISTINCT scopus_publications.scp, document_id, document_id_type
    FROM stg_scopus_publication_identifiers, scopus_publications
   WHERE stg_scopus_publication_identifiers.scp = scopus_publications.scp
      ON CONFLICT (scp, document_id, document_id_type) DO UPDATE SET document_id=excluded.document_id,
        document_id_type=excluded.document_id_type;
END; $$