SET default_tablespace = wos;

DROP TABLE IF EXISTS new_wos_abstracts;
DROP TABLE IF EXISTS new_wos_addresses;
DROP TABLE IF EXISTS new_wos_authors;
DROP TABLE IF EXISTS new_wos_document_identifiers;
DROP TABLE IF EXISTS new_wos_grants;
DROP TABLE IF EXISTS new_wos_keywords;
DROP TABLE IF EXISTS new_wos_publications;
DROP TABLE IF EXISTS new_wos_references;
DROP TABLE IF EXISTS new_wos_titles;

CREATE TABLE new_wos_abstracts
  AS
    SELECT *
    FROM wos_abstracts WITH NO DATA;

CREATE TABLE new_wos_addresses
  AS
    SELECT *
    FROM wos_addresses WITH NO DATA;

CREATE TABLE new_wos_authors
  AS
    SELECT *
    FROM wos_authors WITH NO DATA;

CREATE TABLE new_wos_document_identifiers
  AS
    SELECT *
    FROM wos_document_identifiers WITH NO DATA;

CREATE TABLE new_wos_grants
  AS
    SELECT *
    FROM wos_grants WITH NO DATA;

CREATE TABLE new_wos_keywords
  AS
    SELECT *
    FROM wos_keywords WITH NO DATA;

CREATE TABLE new_wos_publications
  AS
    SELECT *
    FROM wos_publications WITH NO DATA;

CREATE TABLE new_wos_references
  AS
    SELECT *
    FROM wos_references WITH NO DATA;

CREATE TABLE new_wos_titles
  AS
    SELECT *
    FROM wos_titles WITH NO DATA;