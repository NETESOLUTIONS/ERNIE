/*
  The following tables are directly populated with XLSX data from the `Copy of All Report Info_v3.xlsx` sheet

  Author: VJ Davey
*/
*/
SET search_path TO public;

DROP TABLE IF EXISTS cci_award_center_xwalk;
CREATE TABLE cci_award_center_xwalk(
  Award_Number integer,
  Title character varying,
  Official_Center_Name character varying,
  Acronym character varying,
  Organization character varying,
  State character varying,
  Program_Manager character varying,
  Amount character varying
);

DROP TABLE IF EXISTS cci_organizations;
CREATE TABLE cci_organizations(
  phase character varying,
  award_number integer,
  official_center_name character varying,
  reporting_period character varying,
  first_year integer,
  year_number character varying,
  name character varying,
  type character varying,
  location character varying,
  partners_contribution_to_project character varying,
  addl_detail_on_partner_and_contribution character varying
);

DROP TABLE IF EXISTS cci_participants;
CREATE TABLE cci_participants (
  Phase character varying,
  Award_Number integer,
  Official_Center_Name character varying,
  Organization character varying,
  PI_Name character varying,
  Reporting_Period character varying,
  First_Year integer,
  Year_Number character varying,
  Name character varying,
  First_Last character varying,
  Email character varying,
  Most_Senior_Project_Role character varying,
  Is_Investigator_Survey_Sample character varying,
  Is_Student_Survey_Sample character varying,
  Is_Bibliometric_Sample character varying,
  Nearest_Person_Month_Worked character varying,
  Contribution_to_the_Project character varying,
  Funding_Support character varying,
  International_Collaboration character varying,
  International_Travel character varying,
  Worked_for_more_than_160_Hours character varying,
  Years_of_schooling_completed character varying,
  Home_Institution character varying,
  Home_Institution_if_other character varying,
  Home_Institution_Highest_Degree_Granted character varying,
  Fiscal_years_REU_Participant_supported character varying,
  REU_Funding character varying,
  URL character varying,
  IS_OLD_NEW character varying,
  Center_Name character varying,
  unknown_number integer -- figure out what this is
);

DROP TABLE IF EXISTS cci_products;
CREATE TABLE cci_products (
  phase character varying,
  award_number integer,
  official_center_name character varying,
  reporting_period character varying,
  first_year integer,
  year_number character varying,
  citation character varying,
  type character varying,
  is_peer_reviewed character varying,
  status character varying,
  acknowledgement_of_federal_support character varying,
  URL character varying
);
