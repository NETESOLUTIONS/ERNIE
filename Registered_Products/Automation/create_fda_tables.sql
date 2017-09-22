-- This script creates new tables for FDA Orange book data.

-- Usage: psql -d ernie -f createtable_new_fda.sql

-- Author: Lingtian "Lindsay" Wan
-- Create Date: 09/22/2017

set search_path to public;

create table new_fda_patents (
  ernie_id serial,
  appl_type varchar(10),
  appl_no varchar(15),
  product_no varchar(15),
  patent_no varchar(15),
  patent_expire_date_text varchar(50),
  drug_substance_flag varchar(10),
  drug_product_flag varchar(10),
  patent_use_code varchar(20),
  delist_flag varchar(10)
  )
  tablespace ernie_fda_tbs;

create table new_fda_products (
  ernie_id serial,
  ingredient varchar(500),
  df_route varchar(500),
  trade_name varchar(500),
  applicant varchar(30),
  strength varchar(500),
  appl_type varchar(10),
  appl_no varchar(15),
  product_no varchar(15),
  te_code varchar(50),
  approval_date varchar(50),
  rld varchar(10),
  rs varchar(10),
  type varchar(10),
  applicant_full_name varchar(500)
  )
  tablespace ernie_fda_tbs;

create table new_fda_exclusivities (
  ernie_id serial,
  appl_type varchar(10),
  appl_no varchar(15),
  product_no varchar(15),
  exclusivity_code varchar(20),
  exclusivity_date varchar(50)
  )
  tablespace ernie_fda_tbs;
