/*
This script will create all the needed historical update and delete tables for WoS.
Ensure this script has been ran and these tables exist for the weekly update process
Note: If you need to run this script, run it as ernie_admin
Author: VJ Davey
Date : 10/05/2017
*/

\set ON_ERROR_STOP on
\set ECHO all

--set tablespace
SET default_tablespace = wos;

--DROP THE SPECIFIC TABLES IF THEY EXIST
DROP TABLE IF EXISTS uhs_wos_abstracts;
DROP TABLE IF EXISTS uhs_wos_addresses;
DROP TABLE IF EXISTS uhs_wos_authors;
DROP TABLE IF EXISTS uhs_wos_document_identifiers;
DROP TABLE IF EXISTS uhs_wos_grants;
DROP TABLE IF EXISTS uhs_wos_keywords;
DROP TABLE IF EXISTS uhs_wos_publications;
DROP TABLE IF EXISTS uhs_wos_references;
DROP TABLE IF EXISTS uhs_wos_titles;
DROP TABLE IF EXISTS del_wos_abstracts;
DROP TABLE IF EXISTS del_wos_addresses;
DROP TABLE IF EXISTS del_wos_authors;
DROP TABLE IF EXISTS del_wos_document_identifiers;
DROP TABLE IF EXISTS del_wos_grants;
DROP TABLE IF EXISTS del_wos_keywords;
DROP TABLE IF EXISTS del_wos_publications;
DROP TABLE IF EXISTS del_wos_references;
DROP TABLE IF EXISTS del_wos_titles;

-- Build update tables
CREATE TABLE uhs_wos_abstracts (
  id              INTEGER,
  source_id       CHARACTER VARYING(30),
  abstract_text   CHARACTER VARYING(4000),
  source_filename CHARACTER VARYING(200)
);
CREATE TABLE uhs_wos_addresses (
  id               INTEGER,
  source_id        CHARACTER VARYING(30),
  address_name     CHARACTER VARYING(300),
  organization     CHARACTER VARYING(400),
  sub_organization CHARACTER VARYING(400),
  city             CHARACTER VARYING(100),
  country          CHARACTER VARYING(100),
  zip_code         CHARACTER VARYING(20),
  source_filename  CHARACTER VARYING(200)
);
CREATE TABLE uhs_wos_authors (
  id              INTEGER,
  source_id       CHARACTER VARYING(30),
  full_name       CHARACTER VARYING(200),
  last_name       CHARACTER VARYING(200),
  first_name      CHARACTER VARYING(200),
  seq_no          INTEGER,
  address_seq     INTEGER,
  address         CHARACTER VARYING(500),
  email_address   CHARACTER VARYING(300),
  address_id      INTEGER,
  dais_id         CHARACTER VARYING(30),
  r_id            CHARACTER VARYING(30),
  source_filename CHARACTER VARYING(200)
);
CREATE TABLE uhs_wos_document_identifiers (
  id               INTEGER,
  source_id        CHARACTER VARYING(30),
  document_id      CHARACTER VARYING(100),
  document_id_type CHARACTER VARYING(30),
  source_filename  CHARACTER VARYING(200)
);
CREATE TABLE uhs_wos_grants (
  id                 INTEGER,
  source_id          CHARACTER VARYING(30),
  grant_number       CHARACTER VARYING(500),
  grant_organization CHARACTER VARYING(400),
  funding_ack        CHARACTER VARYING(4000),
  source_filename    CHARACTER VARYING(200)
);
CREATE TABLE uhs_wos_keywords (
  id              INTEGER,
  source_id       CHARACTER VARYING(30),
  keyword         CHARACTER VARYING(200),
  source_filename CHARACTER VARYING(200)
);
CREATE TABLE uhs_wos_publications (
  id                 INTEGER,
  source_id          CHARACTER VARYING(30),
  source_type        CHARACTER VARYING(20),
  source_title       CHARACTER VARYING(300),
  language           CHARACTER VARYING(20),
  document_title     CHARACTER VARYING(2000),
  document_type      CHARACTER VARYING(50),
  has_abstract       CHARACTER VARYING(5),
  issue              CHARACTER VARYING(10),
  volume             CHARACTER VARYING(20),
  begin_page         CHARACTER VARYING(30),
  end_page           CHARACTER VARYING(30),
  publisher_name     CHARACTER VARYING(200),
  publisher_address  CHARACTER VARYING(300),
  publication_year   INTEGER,
  publication_date   DATE,
  created_date       DATE,
  last_modified_date DATE,
  edition            CHARACTER VARYING(40),
  source_filename    CHARACTER VARYING(200)
);
CREATE TABLE uhs_wos_references (
  id                 INTEGER,
  source_id          CHARACTER VARYING(30),
  cited_source_uid   CHARACTER VARYING(30),
  cited_title        CHARACTER VARYING(8000),
  cited_work         CHARACTER VARYING(4000),
  cited_author       CHARACTER VARYING(1000),
  cited_year         CHARACTER VARYING(40),
  cited_page         CHARACTER VARYING(200),
  created_date       DATE,
  last_modified_date DATE,
  source_filename    CHARACTER VARYING(200)
);
CREATE TABLE uhs_wos_titles (
  id              INTEGER,
  source_id       CHARACTER VARYING(30),
  title           CHARACTER VARYING(2000),
  type            CHARACTER VARYING(100),
  source_filename CHARACTER VARYING(200)
);

-- Build delete tables
CREATE TABLE del_wos_abstracts (
  id              INTEGER,
  source_id       CHARACTER VARYING(30),
  abstract_text   CHARACTER VARYING(4000),
  source_filename CHARACTER VARYING(200)
);
CREATE TABLE del_wos_addresses (
  id               INTEGER,
  source_id        CHARACTER VARYING(30),
  address_name     CHARACTER VARYING(300),
  organization     CHARACTER VARYING(400),
  sub_organization CHARACTER VARYING(400),
  city             CHARACTER VARYING(100),
  country          CHARACTER VARYING(100),
  zip_code         CHARACTER VARYING(20),
  source_filename  CHARACTER VARYING(200)
);
CREATE TABLE del_wos_authors (
  id              INTEGER,
  source_id       CHARACTER VARYING(30),
  full_name       CHARACTER VARYING(200),
  last_name       CHARACTER VARYING(200),
  first_name      CHARACTER VARYING(200),
  seq_no          INTEGER,
  address_seq     INTEGER,
  address         CHARACTER VARYING(500),
  email_address   CHARACTER VARYING(300),
  address_id      INTEGER,
  dais_id         CHARACTER VARYING(30),
  r_id            CHARACTER VARYING(30),
  source_filename CHARACTER VARYING(200)
);
CREATE TABLE del_wos_document_identifiers (
  id               INTEGER,
  source_id        CHARACTER VARYING(30),
  document_id      CHARACTER VARYING(100),
  document_id_type CHARACTER VARYING(30),
  source_filename  CHARACTER VARYING(200)
);
CREATE TABLE del_wos_grants (
  id                 INTEGER,
  source_id          CHARACTER VARYING(30),
  grant_number       CHARACTER VARYING(500),
  grant_organization CHARACTER VARYING(400),
  funding_ack        CHARACTER VARYING(4000),
  source_filename    CHARACTER VARYING(200)
);
CREATE TABLE del_wos_keywords (
  id              INTEGER,
  source_id       CHARACTER VARYING(30),
  keyword         CHARACTER VARYING(200),
  source_filename CHARACTER VARYING(200)
);
CREATE TABLE del_wos_publications (
  id                 INTEGER,
  source_id          CHARACTER VARYING(30),
  source_type        CHARACTER VARYING(20),
  source_title       CHARACTER VARYING(300),
  language           CHARACTER VARYING(20),
  document_title     CHARACTER VARYING(2000),
  document_type      CHARACTER VARYING(50),
  has_abstract       CHARACTER VARYING(5),
  issue              CHARACTER VARYING(10),
  volume             CHARACTER VARYING(20),
  begin_page         CHARACTER VARYING(30),
  end_page           CHARACTER VARYING(30),
  publisher_name     CHARACTER VARYING(200),
  publisher_address  CHARACTER VARYING(300),
  publication_year   INTEGER,
  publication_date   DATE,
  created_date       DATE,
  last_modified_date DATE,
  edition            CHARACTER VARYING(40),
  source_filename    CHARACTER VARYING(200)
);
CREATE TABLE del_wos_references (
  id                 INTEGER,
  source_id          CHARACTER VARYING(30),
  cited_source_uid   CHARACTER VARYING(30),
  cited_title        CHARACTER VARYING(8000),
  cited_work         CHARACTER VARYING(4000),
  cited_author       CHARACTER VARYING(1000),
  cited_year         CHARACTER VARYING(40),
  cited_page         CHARACTER VARYING(200),
  created_date       DATE,
  last_modified_date DATE,
  source_filename    CHARACTER VARYING(200)
);
CREATE TABLE del_wos_titles (
  id              INTEGER,
  source_id       CHARACTER VARYING(30),
  title           CHARACTER VARYING(2000),
  type            CHARACTER VARYING(100),
  source_filename CHARACTER VARYING(200)
);
