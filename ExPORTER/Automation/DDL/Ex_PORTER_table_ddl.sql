-- This script creates new tables for ExPORTER data

-- Author: Djamil Lakhdar-Hamina
-- Refactored: 10/11/2019

\set ON_ERROR_STOP on
\set ECHO all

SET search_path = public;

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- Drop existing tables manually before executing


create table if not exists exporter_publink
(
	pmid integer not null,
	project_number varchar(15) not null,
	admin_ic char(2) not null,
	constraint exp_publink_pk
		primary key (pmid, project_number) USING INDEX TABLESPACE index_tbs
) TABLESPACE ernie_exporter_tbs ;

CREATE UNIQUE INDEX IF NOT EXISTS exporter_publink_uk
    ON exporter_publink (pmid, project_number) TABLESPACE index_tbs;


create index if not exists ep_pmid_admin_ic_i
	on exporter_publink (pmid, admin_ic);

create index if not exists exporter_publink_idx
	on exporter_publink (project_number, pmid);

create table if not exists exporter_projects
(
	application_id integer not null,
	activity varchar(3),
	administering_ic varchar(2),
	application_type varchar(3),
	arra_funded varchar(3),
	award_notice_date varchar(30),
	budget_start varchar(15),
	budget_end varchar(15),
	cfda_code varchar(30),
	core_project_num varchar(30),
	ed_inst_type varchar(90),
	foa_number varchar(15),
	full_project_num varchar(45),
	subproject_id varchar(10),
	funding_ics varchar(350),
	fy varchar(4),
	ic_name varchar(100),
	nih_spending_cats varchar(5000),
	org_city varchar(40),
	org_country varchar(20),
	org_dept varchar(40),
	org_district varchar(4),
	org_duns varchar(35),
	org_fips varchar(3),
	org_name varchar(100),
	org_state varchar(3),
	org_zipcode varchar(12),
	phr varchar(40000),
	pi_ids varchar(300),
	pi_names varchar(1000),
	program_officer_name varchar(40),
	project_start varchar(12),
	project_end varchar(12),
	project_terms varchar(50000),
	project_title varchar(250),
	serial_number varchar(7),
	study_section varchar(4),
	study_section_name varchar(120),
	suffix varchar(8),
	support_year varchar(4),
	total_cost varchar(20),
	total_cost_sub_project varchar(12),
	CONSTRAINT exporter_projects_pk PRIMARY KEY (application_id) USING INDEX TABLESPACE index_tbs
) TABLESPACE ernie_exporter_tbs;

CREATE UNIQUE INDEX IF NOT EXISTS exporter_project_uk
    ON exporter_projects (application_id) TABLESPACE index_tbs;

create index if not exists exporter_core_project_num_i
	on exporter_projects (core_project_num);

create table if not exists exporter_project_abstracts
(
	application_id integer not null,
	abstract_text text
) TABLESPACE ernie_exporter_tbs;

CREATE UNIQUE INDEX IF NOT EXISTS exporter_project_abstracts_uk
    ON exporter_project_abstracts (application_id) TABLESPACE index_tbs;