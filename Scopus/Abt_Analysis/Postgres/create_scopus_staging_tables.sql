/*
  Create the SCOPUS staging tables in the public schema for ETL processes.

  Author: VJ Davey
*/

SET search_path TO public;

--Wipe staging tables if they already exist
DROP TABLE IF EXISTS scopus_affiliations_stg CASCADE;
DROP TABLE IF EXISTS scopus_documents_stg CASCADE;
DROP TABLE IF EXISTS scopus_authors_stg CASCADE;
DROP TABLE IF EXISTS scopus_author_affiliations_stg CASCADE;
DROP TABLE IF EXISTS scopus_author_documents_stg CASCADE;
DROP TABLE IF EXISTS scopus_document_affiliations_stg CASCADE;
DROP TABLE IF EXISTS scopus_document_citations_stg CASCADE;

/*
  Create main staging tables
*/
CREATE SEQUENCE scopus_affiliations_stg_seq;
CREATE TABLE scopus_affiliations_stg(
  table_id integer NOT NULL DEFAULT nextval('scopus_aff_stg_seq')
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
ALTER SEQUENCE scopus_affiliations_stg_seq OWNED BY scopus_aff_stg.table_id;

CREATE SEQUENCE scopus_documents_stg_seq;
CREATE TABLE scopus_documents_stg(
  table_id integer NOT NULL DEFAULT nextval('scopus_documents_stg_seq'),
  scopus_id varchar NOT NULL,
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
ALTER SEQUENCE scopus_documents_stg_seq OWNED BY scopus_documents_stg.table_id;

CREATE SEQUENCE scopus_authors_stg_seq;
CREATE TABLE scopus_authors_stg(
  table_id integer NOT NULL DEFAULT nextval('scopus_authors_stg_seq'),
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
ALTER SEQUENCE scopus_authors_stg_seq OWNED BY scopus_authors_stg.table_id;

/*
  Create map staging tables
*/

CREATE SEQUENCE scopus_author_affiliations_stg_seq;
CREATE TABLE scopus_author_affiliations_stg(
  table_id integer NOT NULL DEFAULT nextval('scopus_author_affiliations_stg_seq'),
  author_id varchar NOT NULL,
  affiliation_id varchar NOT NULL,
  PRIMARY KEY(author_id, affiliation_id)
);
ALTER SEQUENCE scopus_author_affiliations_stg_seq OWNED BY scopus_author_affiliations_stg.table_id;

CREATE SEQUENCE scopus_author_documents_stg_seq;
CREATE TABLE scopus_author_documents_stg(
  table_id integer NOT NULL DEFAULT nextval('scopus_author_documents_stg_seq'),
  author_id varchar NOT NULL,
  scopus_id varchar NOT NULL,
  PRIMARY KEY(author_id, scopus_id)
);
ALTER SEQUENCE scopus_author_documents_stg_seq OWNED BY scopus_author_documents_stg.table_id;

CREATE SEQUENCE scopus_document_affiliations_stg_seq;
CREATE TABLE scopus_document_affiliations_stg(
  table_id integer NOT NULL DEFAULT nextval('scopus_document_affiliations_stg_seq'),
  scopus_id varchar NOT NULL,
  affiliation_id varchar NOT NULL,
  PRIMARY KEY(scopus_id, affiliation_id)
);
ALTER SEQUENCE scopus_document_affiliations_stg_seq OWNED BY scopus_document_affiliations_stg.table_id;

CREATE SEQUENCE scopus_document_citations_stg_seq;
CREATE TABLE scopus_document_citations_stg(
  table_id integer NOT NULL DEFAULT nextval('scopus_document_citations_stg_seq'),
  citing_scopus_id varchar NOT NULL,
  cited_scopus_id varchar NOT NULL,
  PRIMARY KEY(citing_scopus_id, cited_scopus_id)
);
ALTER SEQUENCE scopus_document_citations_stg_seq OWNED BY scopus_document_citations_stg.table_id;
