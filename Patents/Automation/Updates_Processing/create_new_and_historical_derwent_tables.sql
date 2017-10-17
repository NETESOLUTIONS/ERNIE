-- This script creates new, historical, and update tables for the derwent weekly update process

-- Author: VJ Davey
-- Created: 08/22/2017
SET default_tablespace = ernie_derwent_tbs;

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
    id integer,
    patent_num character varying(30),
    rep_type character varying(30),
    last_name character varying(200),
    first_name character varying(60),
    organization_name character varying(400),
    country character varying(10)
);
CREATE TABLE new_derwent_assignees (
    id integer,
    patent_num character varying(30),
    assignee_name character varying(400),
    role character varying(30),
    city character varying(300),
    state character varying(200),
    country character varying(60)
);
CREATE TABLE new_derwent_assignors (
    id integer,
    patent_num character varying(30),
    assignor character varying(400)
);
CREATE TABLE new_derwent_examiners (
    id integer,
    patent_num character varying(30),
    full_name character varying(100),
    examiner_type character varying(30)
);
CREATE TABLE new_derwent_familyid (
    id integer,
    patent_num character varying(30),
    family_id character varying(30),
    country_code character varying(10),
    action character varying(10),
    kind_code character varying(10),
    date_published character varying(50),
    key character varying(100),
    appl_id character varying(30),
    pub_id character varying(30),
    source_filename character varying(100)
);
CREATE TABLE new_derwent_inventors (
    id integer,
    patent_num character varying(30),
    inventors character varying(300),
    full_name character varying(500),
    last_name character varying(1000),
    first_name character varying(1000),
    city character varying(100),
    state character varying(100),
    country character varying(60)
);
CREATE TABLE new_derwent_lit_citations (
    id integer,
    patent_num_orig character varying(30),
    cited_literature character varying(5000)
);
CREATE TABLE new_derwent_pat_citations (
    id integer,
    patent_num_orig character varying(30),
    cited_patent_orig character varying(100),
    cited_patent_wila character varying(100),
    cited_patent_tsip character varying(100),
    country character varying(30),
    kind character varying(20),
    cited_inventor character varying(400),
    cited_date character varying(10),
    main_class character varying(40),
    sub_class character varying(40)
);
CREATE TABLE new_derwent_patents (
    id integer,
    patent_num_orig character varying(30),
    patent_num_wila character varying(30),
    patent_num_tsip character varying(30),
    patent_type character varying(20),
    status character varying(30),
    file_name character varying(50),
    country character varying(4),
    date_published character varying(50),
    appl_num_orig character varying(30),
    appl_num_wila character varying(30),
    appl_num_tsip character varying(30),
    appl_date character varying(50),
    appl_year character varying(4),
    appl_type character varying(20),
    appl_country character varying(4),
    appl_series_code character varying(4),
    ipc_classification character varying(20),
    main_classification character varying(20),
    sub_classification character varying(20),
    invention_title character varying(1000),
    claim_text text,
    government_support text,
    summary_of_invention text,
    parent_patent_num_orig character varying(30)
);

--generate historical tables
CREATE TABLE uhs_derwent_agents (
    id integer,
    patent_num character varying(30),
    rep_type character varying(30),
    last_name character varying(200),
    first_name character varying(60),
    organization_name character varying(400),
    country character varying(10)
);
CREATE TABLE uhs_derwent_assignees (
    id integer,
    patent_num character varying(30),
    assignee_name character varying(400),
    role character varying(30),
    city character varying(300),
    state character varying(200),
    country character varying(60)
);
CREATE TABLE uhs_derwent_assignors (
    id integer,
    patent_num character varying(30),
    assignor character varying(400)
);
CREATE TABLE uhs_derwent_examiners (
    id integer,
    patent_num character varying(30),
    full_name character varying(100),
    examiner_type character varying(30)
);
CREATE TABLE uhs_derwent_inventors (
    id integer,
    patent_num character varying(30),
    inventors character varying(300),
    full_name character varying(500),
    last_name character varying(1000),
    first_name character varying(1000),
    city character varying(100),
    state character varying(100),
    country character varying(60)
);
CREATE TABLE uhs_derwent_lit_citations (
    id integer,
    patent_num_orig character varying(30),
    cited_literature character varying(5000)
);
CREATE TABLE uhs_derwent_pat_citations (
    id integer,
    patent_num_orig character varying(30),
    cited_patent_orig character varying(100),
    cited_patent_wila character varying(100),
    cited_patent_tsip character varying(100),
    country character varying(30),
    kind character varying(20),
    cited_inventor character varying(400),
    cited_date character varying(10),
    main_class character varying(40),
    sub_class character varying(40)
);
CREATE TABLE uhs_derwent_patents (
    id integer,
    patent_num_orig character varying(30),
    patent_num_wila character varying(30),
    patent_num_tsip character varying(30),
    patent_type character varying(20),
    status character varying(30),
    file_name character varying(50),
    country character varying(4),
    date_published character varying(50),
    appl_num_orig character varying(30),
    appl_num_wila character varying(30),
    appl_num_tsip character varying(30),
    appl_date character varying(50),
    appl_year character varying(4),
    appl_type character varying(20),
    appl_country character varying(4),
    appl_series_code character varying(4),
    ipc_classification character varying(20),
    main_classification character varying(20),
    sub_classification character varying(20),
    invention_title character varying(1000),
    claim_text text,
    government_support text,
    summary_of_invention text,
    parent_patent_num_orig character varying(30)
);
--create update log table with sequence
CREATE TABLE update_log_derwent (
    id integer NOT NULL,
    last_updated timestamp without time zone,
    num_derwent integer,
    num_new integer,
    num_update integer
);
CREATE SEQUENCE update_log_derwent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE update_log_derwent_id_seq OWNED BY update_log_derwent.id;
ALTER TABLE ONLY update_log_derwent ALTER COLUMN id SET DEFAULT nextval('update_log_derwent_id_seq'::regclass);
