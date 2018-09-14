/*

  Create the Abt search result staging tables in the public schema for Abt related ETL processes.

  Author: VJ Davey
*/

SET search_path TO public;

DROP TABLE IF EXISTS cci_s_author_search_results_stg CASCADE;
DROP TABLE IF EXISTS cci_s_document_search_results_stg CASCADE;

CREATE SEQUENCE cci_s_author_search_results_stg_seq;
CREATE TABLE cci_s_author_search_results_stg(
  table_id integer NOT NULL DEFAULT nextval('cci_s_author_search_results_stg_seq'),
  surname varchar,
  given_name varchar,
  author_id varchar NOT NULL,
  award_number varchar NOT NULL,
  phase varchar NOT NULL,
  first_year integer NOT NULL,
  manual_selection integer NOT NULL,
  query_string varchar
);
ALTER SEQUENCE cci_s_author_search_results_stg_seq OWNED BY cci_s_author_search_results_stg.table_id;


CREATE SEQUENCE cci_s_document_search_results_stg_seq;
CREATE TABLE cci_s_document_search_results_stg(
  table_id integer NOT NULL DEFAULT nextval('cci_s_document_search_results_stg_seq'),
  submitted_title varchar,
  submitted_doi varchar,
  document_type varchar,
  scopus_id varchar NOT NULL,
  award_number varchar NOT NULL,
  phase varchar NOT NULL,
  first_year integer NOT NULL,
  manual_selection integer NOT NULL,
  query_string varchar
);
ALTER SEQUENCE cci_s_document_search_results_stg_seq OWNED BY cci_s_document_search_results_stg.table_id;
