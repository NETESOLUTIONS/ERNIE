-- This script creates new, historical, and update tables for the derwent weekly update process
-- Author: VJ Davey
-- Created: 08/22/2017

SET default_tablespace = derwent;

DROP TABLE IF EXISTS new_derwent_patents;
DROP TABLE IF EXISTS new_derwent_inventors;
DROP TABLE IF EXISTS new_derwent_examiners;
DROP TABLE IF EXISTS new_derwent_assignees;
DROP TABLE IF EXISTS new_derwent_pat_citations;
DROP TABLE IF EXISTS new_derwent_agents;
DROP TABLE IF EXISTS new_derwent_assignors;
DROP TABLE IF EXISTS new_derwent_lit_citations;

DROP TABLE IF EXISTS uhs_derwent_patents;
DROP TABLE IF EXISTS uhs_derwent_inventors;
DROP TABLE IF EXISTS uhs_derwent_examiners;
DROP TABLE IF EXISTS uhs_derwent_assignees;
DROP TABLE IF EXISTS uhs_derwent_pat_citations;
DROP TABLE IF EXISTS uhs_derwent_agents;
DROP TABLE IF EXISTS uhs_derwent_assignors;
DROP TABLE IF EXISTS uhs_derwent_lit_citations;

DROP TABLE IF EXISTS update_log_derwent;

--generate new tables
CREATE TABLE new_derwent_agents (
  id                INTEGER,
  patent_num        CHARACTER VARYING(30),
  rep_type          CHARACTER VARYING(30),
  last_name         CHARACTER VARYING(200),
  first_name        CHARACTER VARYING(60),
  organization_name CHARACTER VARYING(400),
  country           CHARACTER VARYING(10)
);

CREATE TABLE new_derwent_assignees (
  id            INTEGER,
  patent_num    CHARACTER VARYING(30),
  assignee_name CHARACTER VARYING(400),
  role          CHARACTER VARYING(30),
  city          CHARACTER VARYING(300),
  state         CHARACTER VARYING(200),
  country       CHARACTER VARYING(60)
);

CREATE TABLE new_derwent_assignors (
  id         INTEGER,
  patent_num CHARACTER VARYING(30),
  assignor   CHARACTER VARYING(400)
);

CREATE TABLE new_derwent_examiners (
  id            INTEGER,
  patent_num    CHARACTER VARYING(30),
  full_name     CHARACTER VARYING(100),
  examiner_type CHARACTER VARYING(30)
);

CREATE TABLE new_derwent_familyid (
  id              INTEGER,
  patent_num      CHARACTER VARYING(30),
  family_id       CHARACTER VARYING(30),
  country_code    CHARACTER VARYING(10),
  action          CHARACTER VARYING(10),
  kind_code       CHARACTER VARYING(10),
  date_published  CHARACTER VARYING(50),
  key             CHARACTER VARYING(100),
  appl_id         CHARACTER VARYING(30),
  pub_id          CHARACTER VARYING(30),
  source_filename CHARACTER VARYING(100)
);

CREATE TABLE new_derwent_inventors (
  id         INTEGER,
  patent_num CHARACTER VARYING(30),
  inventors  CHARACTER VARYING(300),
  full_name  CHARACTER VARYING(500),
  last_name  CHARACTER VARYING(1000),
  first_name CHARACTER VARYING(1000),
  city       CHARACTER VARYING(100),
  state      CHARACTER VARYING(100),
  country    CHARACTER VARYING(60)
);

CREATE TABLE new_derwent_lit_citations (
  id               INTEGER,
  patent_num_orig  CHARACTER VARYING(30),
  cited_literature CHARACTER VARYING(5000)
);

CREATE TABLE new_derwent_pat_citations (
  id                INTEGER,
  patent_num_orig   CHARACTER VARYING(30),
  cited_patent_orig CHARACTER VARYING(100),
  cited_patent_wila CHARACTER VARYING(100),
  cited_patent_tsip CHARACTER VARYING(100),
  country           CHARACTER VARYING(30),
  kind              CHARACTER VARYING(20),
  cited_inventor    CHARACTER VARYING(400),
  cited_date        CHARACTER VARYING(10),
  main_class        CHARACTER VARYING(40),
  sub_class         CHARACTER VARYING(40)
);

CREATE TABLE new_derwent_patents (
  id                     INTEGER,
  patent_num_orig        CHARACTER VARYING(30),
  patent_num_wila        CHARACTER VARYING(30),
  patent_num_tsip        CHARACTER VARYING(30),
  patent_type            CHARACTER VARYING(20),
  status                 CHARACTER VARYING(30),
  file_name              CHARACTER VARYING(50),
  country                CHARACTER VARYING(4),
  date_published         CHARACTER VARYING(50),
  appl_num_orig          CHARACTER VARYING(30),
  appl_num_wila          CHARACTER VARYING(30),
  appl_num_tsip          CHARACTER VARYING(30),
  appl_date              CHARACTER VARYING(50),
  appl_year              CHARACTER VARYING(4),
  appl_type              CHARACTER VARYING(20),
  appl_country           CHARACTER VARYING(4),
  appl_series_code       CHARACTER VARYING(4),
  ipc_classification     CHARACTER VARYING(20),
  main_classification    CHARACTER VARYING(20),
  sub_classification     CHARACTER VARYING(20),
  invention_title        CHARACTER VARYING(1000),
  claim_text             TEXT,
  government_support     TEXT,
  summary_of_invention   TEXT,
  parent_patent_num_orig CHARACTER VARYING(30)
);

--generate historical tables
CREATE TABLE uhs_derwent_agents (
  id                INTEGER,
  patent_num        CHARACTER VARYING(30),
  rep_type          CHARACTER VARYING(30),
  last_name         CHARACTER VARYING(200),
  first_name        CHARACTER VARYING(60),
  organization_name CHARACTER VARYING(400),
  country           CHARACTER VARYING(10)
);

CREATE TABLE uhs_derwent_assignees (
  id            INTEGER,
  patent_num    CHARACTER VARYING(30),
  assignee_name CHARACTER VARYING(400),
  role          CHARACTER VARYING(30),
  city          CHARACTER VARYING(300),
  state         CHARACTER VARYING(200),
  country       CHARACTER VARYING(60)
);

CREATE TABLE uhs_derwent_assignors (
  id         INTEGER,
  patent_num CHARACTER VARYING(30),
  assignor   CHARACTER VARYING(400)
);

CREATE TABLE uhs_derwent_examiners (
  id            INTEGER,
  patent_num    CHARACTER VARYING(30),
  full_name     CHARACTER VARYING(100),
  examiner_type CHARACTER VARYING(30)
);

CREATE TABLE uhs_derwent_inventors (
  id         INTEGER,
  patent_num CHARACTER VARYING(30),
  inventors  CHARACTER VARYING(300),
  full_name  CHARACTER VARYING(500),
  last_name  CHARACTER VARYING(1000),
  first_name CHARACTER VARYING(1000),
  city       CHARACTER VARYING(100),
  state      CHARACTER VARYING(100),
  country    CHARACTER VARYING(60)
);

CREATE TABLE uhs_derwent_lit_citations (
  id               INTEGER,
  patent_num_orig  CHARACTER VARYING(30),
  cited_literature CHARACTER VARYING(5000)
);

CREATE TABLE uhs_derwent_pat_citations (
  id                INTEGER,
  patent_num_orig   CHARACTER VARYING(30),
  cited_patent_orig CHARACTER VARYING(100),
  cited_patent_wila CHARACTER VARYING(100),
  cited_patent_tsip CHARACTER VARYING(100),
  country           CHARACTER VARYING(30),
  kind              CHARACTER VARYING(20),
  cited_inventor    CHARACTER VARYING(400),
  cited_date        CHARACTER VARYING(10),
  main_class        CHARACTER VARYING(40),
  sub_class         CHARACTER VARYING(40)
);

CREATE TABLE uhs_derwent_patents (
  id                     INTEGER,
  patent_num_orig        CHARACTER VARYING(30),
  patent_num_wila        CHARACTER VARYING(30),
  patent_num_tsip        CHARACTER VARYING(30),
  patent_type            CHARACTER VARYING(20),
  status                 CHARACTER VARYING(30),
  file_name              CHARACTER VARYING(50),
  country                CHARACTER VARYING(4),
  date_published         CHARACTER VARYING(50),
  appl_num_orig          CHARACTER VARYING(30),
  appl_num_wila          CHARACTER VARYING(30),
  appl_num_tsip          CHARACTER VARYING(30),
  appl_date              CHARACTER VARYING(50),
  appl_year              CHARACTER VARYING(4),
  appl_type              CHARACTER VARYING(20),
  appl_country           CHARACTER VARYING(4),
  appl_series_code       CHARACTER VARYING(4),
  ipc_classification     CHARACTER VARYING(20),
  main_classification    CHARACTER VARYING(20),
  sub_classification     CHARACTER VARYING(20),
  invention_title        CHARACTER VARYING(1000),
  claim_text             TEXT,
  government_support     TEXT,
  summary_of_invention   TEXT,
  parent_patent_num_orig CHARACTER VARYING(30)
);

--create update log table with sequence
CREATE TABLE update_log_derwent (
  id           INTEGER NOT NULL,
  last_updated TIMESTAMP WITHOUT TIME ZONE,
  num_derwent  INTEGER,
  num_new      INTEGER,
  num_update   INTEGER
);

CREATE SEQUENCE update_log_derwent_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE update_log_derwent_id_seq OWNED BY update_log_derwent.id;
ALTER TABLE ONLY update_log_derwent
  ALTER COLUMN id SET DEFAULT nextval('update_log_derwent_id_seq' :: REGCLASS);