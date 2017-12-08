-- This script creates temp tables for the derwent smokeload.

-- Author: VJ Davey
-- Created: 08/22/2017
SET default_tablespace = ernie_exporter_tbs;

DROP TABLE IF EXISTS reporter_publink;
DROP TABLE IF EXISTS reporter_projects;

CREATE TABLE reporter_publink (
    pmid character varying(10),
    project_number character varying(15)
);
CREATE TABLE reporter_projects (
  APPLICATION_ID character varying(8),
  ACTIVITY character varying(3),
  ADMINISTERING_IC character varying(2),
  APPLICATION_TYPE character varying(3),
  ARRA_FUNDED character varying(3),
  AWARD_NOTICE_DATE character varying(30),
  BUDGET_START character varying(15),
  BUDGET_END character varying(15),
  CFDA_CODE character varying(30),
  CORE_PROJECT_NUM character varying(30),
  ED_INST_TYPE character varying(90),
  FOA_NUMBER character varying(15),
  FULL_PROJECT_NUM character varying(45),
  SUBPROJECT_ID character varying(10),
  FUNDING_ICs character varying(350),
  FY character varying(4),
  IC_NAME character varying(100),
  NIH_SPENDING_CATS character varying(5000),
  ORG_CITY character varying(40),
  ORG_COUNTRY character varying(20),
  ORG_DEPT character varying(40),
  ORG_DISTRICT character varying(4),
  ORG_DUNS character varying(25),
  ORG_FIPS character varying(3),
  ORG_NAME character varying(100),
  ORG_STATE character varying(3),
  ORG_ZIPCODE character varying(12),
  PHR character varying(40000),
  PI_IDS character varying(300),
  PI_NAMEs character varying(1000),
  PROGRAM_OFFICER_NAME character varying(40),
  PROJECT_START character varying(12),
  PROJECT_END character varying(12),
  PROJECT_TERMS character varying(50000),
  PROJECT_TITLE character varying(250),
  SERIAL_NUMBER character varying(7),
  STUDY_SECTION character varying(4),
  STUDY_SECTION_NAME character varying(120),
  SUFFIX character varying(8),
  SUPPORT_YEAR character varying(4),
  TOTAL_COST character varying(20),
  TOTAL_COST_SUB_PROJECT character varying(12)
);

