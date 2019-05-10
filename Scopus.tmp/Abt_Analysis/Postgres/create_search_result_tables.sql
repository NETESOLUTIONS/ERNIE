/*

  Create the Abt search result tables in the public schema for Abt related ETL processes.

  Author: VJ Davey
*/

SET search_path TO public;

CREATE TABLE cci_s_author_search_results(
  surname varchar,
  given_name varchar,
  author_id varchar NOT NULL,
  award_number varchar NOT NULL,
  phase varchar NOT NULL,
  first_year integer NOT NULL,
  manual_selection integer NOT NULL,
  query_string varchar,
  PRIMARY KEY(author_id,award_number,surname,given_name)
);

CREATE TABLE cci_s_document_search_results(
  submitted_title varchar,
  submitted_doi varchar,
  document_type varchar,
  scopus_id varchar NOT NULL,
  award_number varchar NOT NULL,
  phase varchar NOT NULL,
  first_year integer NOT NULL,
  manual_selection integer NOT NULL,
  query_string varchar,
  PRIMARY KEY(scopus_id,award_number,submitted_title)
);

CREATE TABLE cci_s_award_search_results(
  award_number TEXT NOT NULL,
  official_center_name TEXT NOT NULL,
  scopus_id BIGINT NOT NULL,
  eid TEXT,
  doi TEXT,
  title TEXT,
  fund_acr TEXT,
  fund_no TEXT,
  fund_sponsor TEXT,
  PRIMARY KEY(award_number,scopus_id)
);
