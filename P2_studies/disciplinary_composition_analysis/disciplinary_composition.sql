\set ON_ERROR_STOP on
\set ECHO all

SET SEARCH_PATH TO public;

SET DEFAULT_TABLESPACE = 'p2_studies';

CREATE TABLE :temp_cited_source_uid AS
SELECT a.cited_source_uid, b.subject_classification_type, b.subject
FROM (SELECT DISTINCT cited_source_uid FROM : subject_table) a
       INNER JOIN public.wos_publication_subjects b
                  ON a.cited_source_uid = b.source_id AND b.subject_classification_type = 'extended';

CREATE TABLE :temp_source_id AS
SELECT a.source_id, b.subject_classification_type, b.subject
FROM (SELECT DISTINCT source_id FROM : subject_table) a
       INNER JOIN public.wos_publication_subjects b
                  ON a.source_id = b.source_id AND b.subject_classification_type = 'extended';


ALTER TABLE :temp_cited_source_uid
  ADD COLUMN research_area text;

ALTER TABLE :temp_source_id
  ADD COLUMN research_area text;

UPDATE :temp_cited_source_uid a
SET research_area=(SELECT research_area FROM wos_research_areas WHERE category = a.subject);

UPDATE :temp_source_id a
SET research_area=(SELECT research_area FROM wos_research_areas WHERE category = a.subject);
