/*
  This script is used to (re)create the Derwent tables on the ERNIE server
*/
SET search_path TO public;
SET default_tablespace = derwent;

DROP TABLE IF EXISTS derwent_patents;
DROP TABLE IF EXISTS derwent_inventors;
DROP TABLE IF EXISTS derwent_examiners;
DROP TABLE IF EXISTS derwent_assignees;
DROP TABLE IF EXISTS derwent_pat_citations;
DROP TABLE IF EXISTS derwent_agents;
DROP TABLE IF EXISTS derwent_assignors;
DROP TABLE IF EXISTS derwent_lit_citations;



-- region derwent_patents
CREATE TABLE IF NOT EXISTS derwent_patents (
  id                     INTEGER,
  patent_num_orig        VARCHAR(30) NOT NULL,
  patent_num_wila        VARCHAR(30),
  patent_num_tsip        VARCHAR(30),
  patent_type            VARCHAR(20) NOT NULL,
  status                 VARCHAR(30),
  file_name              VARCHAR(50),
  country                VARCHAR(4),
  date_published         VARCHAR(50),
  appl_num_orig          VARCHAR(30),
  appl_num_wila          VARCHAR(30),
  appl_num_tsip          VARCHAR(30),
  appl_date              VARCHAR(50),
  appl_year              VARCHAR(4),
  appl_type              VARCHAR(20),
  appl_country           VARCHAR(4),
  appl_series_code       VARCHAR(4),
  ipc_classification     VARCHAR(20),
  main_classification    VARCHAR(20),
  sub_classification     VARCHAR(20),
  invention_title        VARCHAR(1000),
  claim_text             TEXT,
  government_support     TEXT,
  summary_of_invention   TEXT,
  parent_patent_num_orig VARCHAR(30),
  CONSTRAINT derwent_patents_pk PRIMARY KEY (patent_num_orig, patent_type) USING INDEX TABLESPACE index_tbs
) TABLESPACE derwent;

CREATE INDEX IF NOT EXISTS patent_num_wila_index
  ON derwent_patents (patent_num_wila);

CREATE INDEX IF NOT EXISTS derwent_appl_idx
  ON derwent_patents (appl_num_orig);

COMMENT ON TABLE derwent_patents
IS 'Published US Patents from Clarivate Derwent Data Feed';

COMMENT ON COLUMN derwent_patents.id
IS 'Surrogate PARDI id. Example: 1';

COMMENT ON COLUMN derwent_patents.patent_num_orig
IS 'Format originally provided in the original source data (form=”original”). Example: 03849915';

COMMENT ON COLUMN derwent_patents.patent_num_wila
IS 'Numbers in the legacy Wila format (form=”wila”) should be ignored as this format is supposed to expire.'
' Example: 3849915';

COMMENT ON COLUMN derwent_patents.patent_num_tsip
IS 'Patent number in a "dwpi" form or any other than "original" or "wila". Example: 3849915';

COMMENT ON COLUMN derwent_patents.patent_type
IS ' Example: A';

COMMENT ON COLUMN derwent_patents.status
IS '"new" when it''s the first entry of the record, "replace" when loaded from an update feed even when data hasn''t changed.'
' Provenance: <documentId action=...>.';

COMMENT ON COLUMN derwent_patents.file_name
IS ' Example: US_5_A_197448.xml';

COMMENT ON COLUMN derwent_patents.country
IS 'Two-letter country code. Example: US';

COMMENT ON COLUMN derwent_patents.date_published
IS 'Date of publication for patents. Provenance: <date>. Example: 1974-11-26';

COMMENT ON COLUMN derwent_patents.appl_num_orig
IS ' Example: 05383800';

COMMENT ON COLUMN derwent_patents.appl_num_wila
IS ' Example: 05-383800';

COMMENT ON COLUMN derwent_patents.appl_num_tsip
IS ' Example: 000383800';

COMMENT ON COLUMN derwent_patents.appl_date
IS ' Example: 1973-07-30';

COMMENT ON COLUMN derwent_patents.appl_year
IS ' Example: 1973';

COMMENT ON COLUMN derwent_patents.appl_type
IS ' Example: A';

COMMENT ON COLUMN derwent_patents.appl_country
IS ' Example: US';

COMMENT ON COLUMN derwent_patents.appl_series_code
IS ' Example: 05';

COMMENT ON COLUMN derwent_patents.ipc_classification
IS ' Example: A43C-15/00';

COMMENT ON COLUMN derwent_patents.main_classification
IS ' Example: 036';

COMMENT ON COLUMN derwent_patents.sub_classification
IS ' Example: 06700B';

COMMENT ON COLUMN derwent_patents.invention_title
IS ' Example: SPORT SHOE';

COMMENT ON COLUMN derwent_patents.claim_text
IS ' Example: A sport shoe comprises a sole and an upper mounted on said sole, wherein a plurality of recesses each'
' with a rounded inner wall surface are provided on the lower surface of said sole for trapping water thereinto and'
' producing anti-slipping effect, whereby an athlete is prevented from falling down on an all-weather track in the rain'
' or after the rain, and his running speed and jumping force are increased.';

COMMENT ON COLUMN derwent_patents.government_support
IS 'Government support citation text. Example: The Government of the United States of America has rights in this invention pursuant to Contract No. DEN3-32 awarded by U.S. Department of Energy.';

COMMENT ON COLUMN derwent_patents.summary_of_invention
IS 'long text.';

COMMENT ON COLUMN derwent_patents.parent_patent_num_orig
IS ' Example: 6284347';
-- endregion

-- region derwent_inventors
CREATE TABLE IF NOT EXISTS derwent_inventors (
  id         INTEGER,
  patent_num VARCHAR(30)  NOT NULL,
  inventors  VARCHAR(300) NOT NULL,
  full_name  VARCHAR(500),
  last_name  VARCHAR(1000),
  first_name VARCHAR(1000),
  city       VARCHAR(100),
  state      VARCHAR(100),
  country    VARCHAR(60),
  CONSTRAINT derwent_inventors_pk PRIMARY KEY (patent_num, inventors) USING INDEX TABLESPACE index_tbs
) TABLESPACE derwent;

COMMENT ON TABLE derwent_inventors
IS 'Thomson Reuters: Derwent - Name and location (country,city) infromation of the patent Inventors';

COMMENT ON COLUMN derwent_inventors.id
IS ' Example: 1';

COMMENT ON COLUMN derwent_inventors.patent_num
IS ' Example: 05857154';

COMMENT ON COLUMN derwent_inventors.inventors
IS ' Example: Laborde, Enrique, Gaithersburg, MD, US';

COMMENT ON COLUMN derwent_inventors.full_name
IS ' Example: Laborde, Enrique';

COMMENT ON COLUMN derwent_inventors.last_name
IS ' Example: Laborde';

COMMENT ON COLUMN derwent_inventors.first_name
IS ' Example: Enrique';

COMMENT ON COLUMN derwent_inventors.city
IS ' Example: Gaithersburg';

COMMENT ON COLUMN derwent_inventors.state
IS ' Example: MD';

COMMENT ON COLUMN derwent_inventors.country
IS ' Example: US';
-- endregion

-- region derwent_examiners
CREATE TABLE IF NOT EXISTS derwent_examiners (
  id            INTEGER,
  patent_num    VARCHAR(30)  NOT NULL,
  full_name     VARCHAR(100) NOT NULL,
  examiner_type VARCHAR(30)  NOT NULL,
  CONSTRAINT derwent_examiners_pk PRIMARY KEY (patent_num, examiner_type) USING INDEX TABLESPACE index_tbs
) TABLESPACE derwent;

COMMENT ON TABLE derwent_examiners
IS 'Thomson Reuters: Derwent - Patent examiners and examiner type';

COMMENT ON COLUMN derwent_examiners.id
IS ' Example: 1';

COMMENT ON COLUMN derwent_examiners.patent_num
IS ' Example: 04890722';

COMMENT ON COLUMN derwent_examiners.full_name
IS ' Example: Spar, Robert J.';

COMMENT ON COLUMN derwent_examiners.examiner_type
IS 'primary/secondary. Example: primary';
-- endregion


-- region derwent_assignees
CREATE TABLE IF NOT EXISTS derwent_assignees (
  id            INTEGER      NOT NULL,
  patent_num    VARCHAR(30)  NOT NULL DEFAULT '',
  assignee_name VARCHAR(400) NOT NULL DEFAULT '',
  role          VARCHAR(30)  NOT NULL DEFAULT '',
  city          VARCHAR(300) NOT NULL DEFAULT '',
  state         VARCHAR(200),
  country       VARCHAR(60),
  CONSTRAINT derwent_assignees_pk PRIMARY KEY (patent_num, assignee_name, role, city) USING INDEX TABLESPACE index_tbs
) TABLESPACE derwent;

COMMENT ON TABLE derwent_assignees
IS 'Thomson Reuters: Derwent - Assignee  of the patents';

COMMENT ON COLUMN derwent_assignees.id
IS ' Example: 1';

COMMENT ON COLUMN derwent_assignees.patent_num
IS ' Example: 05857186';

COMMENT ON COLUMN derwent_assignees.assignee_name
IS ' Example: Nippon Steel Corporation';

COMMENT ON COLUMN derwent_assignees.role
IS 'assignee/applicant/applicant-inventor. Example: assignee';

COMMENT ON COLUMN derwent_assignees.city
IS ' Example: Tokyo';

COMMENT ON COLUMN derwent_assignees.state
IS ' Example: CA';

COMMENT ON COLUMN derwent_assignees.country
IS ' Example: JP';
-- endregion

-- region derwent_pat_citations
CREATE TABLE IF NOT EXISTS derwent_pat_citations (
  id                INTEGER,
  patent_num_orig   VARCHAR(30)  NOT NULL,
  cited_patent_orig VARCHAR(100) NOT NULL,
  cited_patent_wila VARCHAR(100),
  cited_patent_tsip VARCHAR(100),
  country           VARCHAR(30)  NOT NULL,
  kind              VARCHAR(20),
  cited_inventor    VARCHAR(400),
  cited_date        VARCHAR(10),
  main_class        VARCHAR(40),
  sub_class         VARCHAR(40),
  CONSTRAINT derwent_pat_citations_pk PRIMARY KEY (patent_num_orig, country, cited_patent_orig) --
  USING INDEX TABLESPACE index_tbs
) TABLESPACE derwent;

COMMENT ON TABLE derwent_pat_citations
IS 'Thomson Reuters: Derwent - cited patent list of the patents';

COMMENT ON COLUMN derwent_pat_citations.id
IS ' Example: 1';

COMMENT ON COLUMN derwent_pat_citations.patent_num_orig
IS ' Example: 05857186';

COMMENT ON COLUMN derwent_pat_citations.cited_patent_orig
IS ' Example: 05142687';

COMMENT ON COLUMN derwent_pat_citations.cited_patent_wila
IS ' Example: 5142687';

COMMENT ON COLUMN derwent_pat_citations.cited_patent_tsip
IS ' Example: 5142687';

COMMENT ON COLUMN derwent_pat_citations.country
IS ' Example: US';

COMMENT ON COLUMN derwent_pat_citations.kind
IS ' Example: A';

COMMENT ON COLUMN derwent_pat_citations.cited_inventor
IS ' Example: Lary';

COMMENT ON COLUMN derwent_pat_citations.cited_date
IS 'No records yet.';

COMMENT ON COLUMN derwent_pat_citations.main_class
IS ' Example: 707';

COMMENT ON COLUMN derwent_pat_citations.sub_class
IS ' Example: 007000';
-- endregion

-- region derwent_agents
CREATE TABLE IF NOT EXISTS derwent_agents (
  id                INTEGER,
  patent_num        VARCHAR(30)  NOT NULL,
  rep_type          VARCHAR(30),
  last_name         VARCHAR(200),
  first_name        VARCHAR(60),
  organization_name VARCHAR(400) NOT NULL,
  country           VARCHAR(10),
  CONSTRAINT derwent_agents_pk PRIMARY KEY (patent_num, organization_name) USING INDEX TABLESPACE index_tbs
) TABLESPACE derwent;

COMMENT ON TABLE derwent_agents
IS 'Thomson Reuters: Derwent - patents: patent and agents information';

COMMENT ON COLUMN derwent_agents.id
IS 'id is always an integer- is an internal (PARDI) number. Example: 1';

COMMENT ON COLUMN derwent_agents.patent_num
IS ' Example: 05857186';

COMMENT ON COLUMN derwent_agents.rep_type
IS ' Example: agent';

COMMENT ON COLUMN derwent_agents.last_name
IS ' Example: Whelan';

COMMENT ON COLUMN derwent_agents.first_name
IS 'No records yet.';

COMMENT ON COLUMN derwent_agents.organization_name
IS ' Example: Whelan, John T.';

COMMENT ON COLUMN derwent_agents.country
IS 'No records yet.';
-- endregion

-- region derwent_assignors
CREATE TABLE IF NOT EXISTS derwent_assignors (
  id         INTEGER,
  patent_num VARCHAR(30)  NOT NULL,
  assignor   VARCHAR(400) NOT NULL,
  CONSTRAINT derwent_assignors_pk PRIMARY KEY (patent_num, assignor) USING INDEX TABLESPACE index_tbs
) TABLESPACE derwent;

COMMENT ON TABLE derwent_assignors
IS 'Thomson Reuters: Derwent - Assignor of the patents';

COMMENT ON COLUMN derwent_assignors.id
IS ' Example: 2';

COMMENT ON COLUMN derwent_assignors.patent_num
IS ' Example: 05857160';

COMMENT ON COLUMN derwent_assignors.assignor
IS ' Example: BROWN, TODD';
-- endregion

-- region derwent_lit_citations
CREATE TABLE IF NOT EXISTS derwent_lit_citations (
  id               INTEGER,
  patent_num_orig  VARCHAR(30)   NOT NULL,
  cited_literature VARCHAR(5000) NOT NULL
) TABLESPACE derwent;

CREATE UNIQUE INDEX IF NOT EXISTS derwent_lit_citations_uk
  ON derwent_lit_citations (patent_num_orig, md5(cited_literature :: TEXT)) TABLESPACE index_tbs;

COMMENT ON TABLE derwent_lit_citations
IS 'Thomson Reuters: Derwent - cited literature of the patents';

COMMENT ON COLUMN derwent_lit_citations.id
IS ' Example: 1';

COMMENT ON COLUMN derwent_lit_citations.patent_num_orig
IS ' Example: 05857186';

COMMENT ON COLUMN derwent_lit_citations.cited_literature
IS ' Example: Kruse, Data Structures and Program Design, Prentice-Hall, 1984, p. 139-145.';
-- endregion
