/*
    1. wos_abstracts
    2. wos_addresses
    3. wos_authors
    4. wos_document_identifiers
    5. wos_grants
    6. wos_keywords
    7. wos_publications
    8. wos_references
    9. wos_titles
    10.wos_publication_subjects
*/

\set ECHO all
\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION update_wos_abstracts_function()
  RETURNS TRIGGER AS $update_wos_abstracts_trigger$
BEGIN IF (tg_op = 'UPDATE')
THEN INSERT INTO uhs_wos_abstracts (source_id, abstract_text, source_filename, last_updated_time)
VALUES (old.source_id, old.abstract_text, old.source_filename, old.last_updated_time); END IF;
  RETURN NULL;
END;
$update_wos_abstracts_trigger$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_wos_abstracts_trigger ON wos_abstracts;
CREATE TRIGGER update_wos_abstracts_trigger
  AFTER UPDATE
  ON wos_abstracts
  FOR EACH ROW EXECUTE PROCEDURE update_wos_abstracts_function();

CREATE OR REPLACE FUNCTION update_wos_addresses_function()
  RETURNS TRIGGER AS $update_wos_addresses_trigger$
BEGIN IF (tg_op = 'UPDATE')
THEN INSERT INTO uhs_wos_addresses VALUES
  (old.id, old.source_id, old.address_name, old.organization, old.sub_organization, old.city, old.country, old.zip_code,
   old.source_filename, old.last_updated_time);

END IF;
  RETURN NULL;
END;
$update_wos_addresses_trigger$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_wos_addresses_trigger ON wos_addresses;
CREATE TRIGGER update_wos_addresses_trigger
  AFTER UPDATE
  ON wos_addresses
  FOR EACH ROW EXECUTE PROCEDURE update_wos_addresses_function();

CREATE OR REPLACE FUNCTION update_wos_authors_function()
  RETURNS TRIGGER AS $update_wos_authors_trigger$
BEGIN IF (tg_op = 'UPDATE')
THEN INSERT INTO uhs_wos_authors VALUES
  (old.id, old.source_id, old.full_name, old.last_name, old.first_name, old.seq_no, old.address_seq, old.address,
           old.email_address, old.address_id, old.dais_id, old.r_id, old.source_filename, old.last_updated_time);

END IF;
  RETURN NULL;
END;
$update_wos_authors_trigger$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_wos_authors_trigger ON wos_authors;
CREATE TRIGGER update_wos_authors_trigger
  AFTER UPDATE
  ON wos_authors
  FOR EACH ROW EXECUTE PROCEDURE update_wos_authors_function();

CREATE OR REPLACE FUNCTION update_wos_document_identifiers_function()
  RETURNS TRIGGER AS $update_wos_document_identifiers_trigger$
BEGIN IF (tg_op = 'UPDATE')
THEN INSERT INTO uhs_wos_document_identifiers
VALUES (old.id, old.source_id, old.document_id, old.document_id_type, old.source_filename, old.last_updated_time);

END IF;
  RETURN NULL;
END;
$update_wos_document_identifiers_trigger$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_wos_document_identifiers_trigger ON wos_document_identifiers;
CREATE TRIGGER update_wos_document_identifiers_trigger
  AFTER UPDATE
  ON wos_document_identifiers
  FOR EACH ROW EXECUTE PROCEDURE update_wos_document_identifiers_function();

CREATE OR REPLACE FUNCTION update_wos_grants_function()
  RETURNS TRIGGER AS $update_wos_grants_trigger$
BEGIN IF (tg_op = 'UPDATE')
THEN INSERT INTO uhs_wos_grants VALUES
  (old.id, old.source_id, old.grant_number, old.grant_organization, old.funding_ack, old.source_filename,
   old.last_updated_time);

END IF;
  RETURN NULL;
END;
$update_wos_grants_trigger$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_wos_grants_trigger ON wos_grants;
CREATE TRIGGER update_wos_grants_trigger
  AFTER UPDATE
  ON wos_grants
  FOR EACH ROW EXECUTE PROCEDURE update_wos_grants_function();

CREATE OR REPLACE FUNCTION update_wos_keywords_function()
  RETURNS TRIGGER AS $update_wos_keywords_trigger$
BEGIN IF (tg_op = 'UPDATE')
THEN INSERT INTO uhs_wos_keywords
VALUES (old.id, old.source_id, old.keyword, old.source_filename, old.last_updated_time);

END IF;
  RETURN NULL;
END;
$update_wos_keywords_trigger$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_wos_keywords_trigger ON wos_keywords;
CREATE TRIGGER update_wos_keywords_trigger
  AFTER UPDATE
  ON wos_keywords
  FOR EACH ROW EXECUTE PROCEDURE update_wos_keywords_function();

CREATE OR REPLACE FUNCTION update_wos_publications_function()
  RETURNS TRIGGER AS $update_wos_publications_trigger$
BEGIN IF (tg_op = 'UPDATE')
THEN INSERT INTO uhs_wos_publications VALUES
  (old.id, old.source_id, old.source_type, old.source_title, old.language, old.document_title, old.document_type,
    old.has_abstract, old.issue, old.volume, old.begin_page, old.end_page, old.publisher_name, old.publisher_address,
    old.publication_year, old.publication_date, old.created_date, old.last_modified_date, old.edition,
    old.source_filename, old.last_updated_time);

END IF;
  RETURN NULL;
END;
$update_wos_publications_trigger$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_wos_publications_trigger ON wos_publications;
CREATE TRIGGER update_wos_publications_trigger
  AFTER UPDATE
  ON wos_publications
  FOR EACH ROW EXECUTE PROCEDURE update_wos_publications_function();

CREATE OR REPLACE FUNCTION update_wos_references_function()
  RETURNS TRIGGER AS $update_wos_references_trigger$
BEGIN IF (tg_op = 'UPDATE')
THEN INSERT INTO uhs_wos_references VALUES
  (old.wos_reference_id, old.source_id, old.cited_source_uid, old.cited_title, old.cited_work, old.cited_author,
                         old.cited_year, old.cited_page, old.created_date, old.last_modified_date, old.source_filename,
   old.last_updated_time);

END IF;
  RETURN NULL;
END;
$update_wos_references_trigger$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_wos_references_trigger ON wos_references;
CREATE TRIGGER update_wos_references_trigger
  AFTER UPDATE
  ON wos_references
  FOR EACH ROW EXECUTE PROCEDURE update_wos_references_function();

CREATE OR REPLACE FUNCTION update_wos_titles_function()
  RETURNS TRIGGER AS $update_wos_titles_trigger$
BEGIN IF (tg_op = 'UPDATE')
THEN INSERT INTO uhs_wos_titles
VALUES (old.id, old.source_id, old.title, old.type, old.source_filename, old.last_updated_time);

END IF;
  RETURN NULL;
END;
$update_wos_titles_trigger$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_wos_titles_trigger ON wos_titles;
CREATE TRIGGER update_wos_titles_trigger
  AFTER UPDATE
  ON wos_titles
  FOR EACH ROW EXECUTE PROCEDURE update_wos_titles_function();

CREATE OR REPLACE FUNCTION update_wos_publication_subjects_function()
  RETURNS TRIGGER AS $update_wos_publication_subjects_trigger$
BEGIN IF (tg_op = 'UPDATE')
THEN INSERT INTO uhs_wos_publication_subjects
VALUES (old.wos_subject_id,old.source_id,old.subject_classification_type,old.subject,old.source_filename, old.last_updated_time);

END IF;
  RETURN NULL;
END;
$update_wos_publication_subjects_trigger$
LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS update_wos_publication_subjects_trigger ON wos_publication_subjects;
CREATE TRIGGER update_wos_publication_subjects_trigger
  AFTER UPDATE
  ON wos_publication_subjects
  FOR EACH ROW EXECUTE PROCEDURE update_wos_publications_function();

/* COMMENTED OUT FOR NOW

CREATE OR REPLACE FUNCTION trg_extract_pmid_int()
  RETURNS TRIGGER AS $block$
--@formatter:off
BEGIN
  NEW.pmid_int := cast(substring(NEW.pmid from 'MEDLINE:(.*)') AS INTEGER);
  RETURN NEW;
END; $block$ LANGUAGE plpgsql;
--@formatter:on

DROP TRIGGER IF EXISTS trg_wos_pmid_mapping_upsert
ON wos_pmid_mapping;

CREATE TRIGGER trg_wos_pmid_mapping_upsert
  BEFORE INSERT OR UPDATE OF pmid
  ON wos_pmid_mapping
  FOR EACH ROW EXECUTE PROCEDURE trg_extract_pmid_int();

CREATE OR REPLACE FUNCTION trg_parse_patent_number()
  RETURNS TRIGGER AS $block$
/*
Parses patent numbers from Clarivate data into component parts, e.g.

For US6051593-A:

patent_country,patent_orig,patent_type
US,06051593,A
*/
/*
--@formatter:off
BEGIN
  NEW.patent_country := left(NEW.patent_num, 2);
  NEW.patent_orig :=
    CASE left(NEW.patent_num, 2)
    WHEN 'US'
      THEN lpad(split_part(substring(NEW.patent_num FROM 3), '-', 1), 8, '0')
    ELSE split_part(substring(NEW.patent_num FROM 3), '-', 1)
    END;
  RETURN NEW;
  NEW.patent_type := split_part(NEW.patent_num, '-', 2);
END; $block$ LANGUAGE plpgsql;
--@formatter:on

DROP TRIGGER IF EXISTS trg_wos_pmid_mapping_upsert
ON wos_pmid_mapping;

CREATE TRIGGER trg_wos_pmid_mapping_upsert
  BEFORE INSERT OR UPDATE OF pmid
  ON wos_pmid_mapping
  FOR EACH ROW EXECUTE PROCEDURE trg_extract_pmid_int();
  */
