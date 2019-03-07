/*
  Create the SCOPUS tables in the public schema for ETL processes. Include comments.

  Author: VJ Davey
*/

SET search_path TO public;

--Wipe tables if they already exist
DROP TABLE IF EXISTS scopus_affiliations CASCADE;
DROP TABLE IF EXISTS scopus_documents CASCADE;
DROP TABLE IF EXISTS scopus_authors CASCADE;
DROP TABLE IF EXISTS scopus_author_affiliations CASCADE;
DROP TABLE IF EXISTS scopus_author_documents CASCADE;
DROP TABLE IF EXISTS scopus_document_affiliations CASCADE;
DROP TABLE IF EXISTS scopus_document_citations CASCADE;

/*
  Create main tables
*/
CREATE TABLE scopus_affiliations(
  affiliation_id varchar NOT NULL,
  parent_affiliation_id varchar,
  scopus_author_count integer,
  scopus_document_count integer,
  affiliation_name varchar,
  address varchar,
  city varchar,
  state varchar,
  country varchar,
  postal_code varchar,
  organization_type varchar,
  PRIMARY KEY(affiliation_id)
);

CREATE TABLE scopus_documents(
  scopus_id bigint NOT NULL,
  title varchar,
  document_type varchar,
  scopus_cited_by_count integer,
  process_cited_by_count integer,
  publication_name varchar,
  publisher varchar,
  issn varchar,
  volume varchar,
  page_range varchar,
  cover_date varchar,
  publication_year integer,
  publication_month integer,
  publication_day integer,
  pubmed_id integer,
  doi varchar,
  description varchar,
  scopus_first_author_id varchar,
  subject_areas varchar,
  keywords varchar,
  PRIMARY KEY(scopus_id)
);

CREATE SEQUENCE scopus_authors_seq;
CREATE TABLE scopus_authors(
  table_id integer NOT NULL DEFAULT nextval('scopus_authors_seq'),
  author_id varchar NOT NULL,
  indexed_name varchar,
  surname varchar,
  given_name varchar,
  initials varchar,
  scopus_co_author_count integer,
  process_co_author_count integer,
  scopus_document_count integer,
  process_document_count integer,
  scopus_citation_count integer,
  scopus_cited_by_count integer,
  alias_author_id varchar,
  PRIMARY KEY(author_id)
);

/*
  Create map tables
*/

CREATE TABLE scopus_author_affiliations(
  author_id varchar NOT NULL,
  affiliation_id varchar NOT NULL,
  PRIMARY KEY(author_id, affiliation_id)
);

CREATE TABLE scopus_author_documents(
  author_id varchar NOT NULL,
  scopus_id bigint NOT NULL,
  PRIMARY KEY(author_id, scopus_id)
);

CREATE TABLE scopus_document_affiliations(
  scopus_id bigint NOT NULL,
  affiliation_id varchar NOT NULL,
  PRIMARY KEY(scopus_id, affiliation_id)
);

CREATE TABLE scopus_document_citations(
  citing_scopus_id bigint NOT NULL,
  cited_scopus_id bigint NOT NULL,
  PRIMARY KEY(citing_scopus_id, cited_scopus_id)
);
