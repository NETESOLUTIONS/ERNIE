\set ON_ERROR_STOP on
\set ECHO all

TRUNCATE TABLE new_wos_abstracts;
TRUNCATE TABLE new_wos_addresses;
TRUNCATE TABLE new_wos_authors;
TRUNCATE TABLE new_wos_document_identifiers;
TRUNCATE TABLE new_wos_grants;
TRUNCATE TABLE new_wos_keywords;
TRUNCATE TABLE new_wos_publications;
TRUNCATE TABLE new_wos_references;
TRUNCATE TABLE new_wos_titles;
DELETE FROM wos_abstracts
WHERE source_filename LIKE '%RAW%';
DELETE FROM wos_addresses
WHERE source_filename LIKE '%RAW%';
DELETE FROM wos_authors
WHERE source_filename LIKE '%RAW%';
DELETE FROM wos_document_identifiers
WHERE source_filename LIKE '%RAW%';
DELETE FROM wos_grants
WHERE source_filename LIKE '%RAW%';
DELETE FROM wos_keywords
WHERE source_filename LIKE '%RAW%';
DELETE FROM wos_publications
WHERE source_filename LIKE '%RAW%';
DELETE FROM wos_references
WHERE source_filename LIKE '%RAW%';
DELETE FROM wos_titles
WHERE source_filename LIKE '%RAW%';
  

