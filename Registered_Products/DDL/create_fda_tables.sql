-- This script creates new tables for FDA Orange book data.

-- Usage: psql -d ernie -f createtable_new_fda.sql

-- Author: Djamil Lakhdar-Hamina, Lingtian "Lindsay" Wan
-- Create Date: 09/22/2017
-- Refactored: 10/11/2019

\set ON_ERROR_STOP on
\set ECHO all

set search_path to public;

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- Drop existing tables manually before executing

create table if not exists fda_patents
(
--   ernie_id serial,
    appl_type               varchar(10) NOT NULL,
    appl_no                 varchar(15) NOT NULL DEFAULT '',
    product_no              varchar(15) NOT NULL DEFAULT '',
    patent_no               varchar(15) NOT NULL DEFAULT '',
    patent_expire_date_text varchar(50),
    drug_substance_flag     varchar(10),
    drug_product_flag       varchar(10),
    patent_use_code         varchar(20) NOT NULL DEFAULT '',
    delist_flag             varchar(10),
    CONSTRAINT fda_patents_pk PRIMARY KEY (appl_no, product_no, patent_no, patent_use_code) USING INDEX TABLESPACE index_tbs
)
    tablespace ernie_fda_tbs;

CREATE UNIQUE INDEX IF NOT EXISTS fda_patents_uk
    ON fda_patents (appl_no, product_no, patent_no, patent_use_code) TABLESPACE index_tbs;

create table if not exists fda_products
(
--   ernie_id serial,
    ingredient          varchar(500),
    df_route            varchar(500),
    trade_name          varchar(500),
    applicant           varchar(30),
    strength            varchar(500),
    appl_type           varchar(10),
    appl_no             varchar(15) NOT NULL DEFAULT '',
    product_no          varchar(15) NOT NULL DEFAULT '',
    te_code             varchar(50),
    approval_date       varchar(50),
    rld                 varchar(10),
    rs                  varchar(10),
    type                varchar(10) NOT NULL DEFAULT '',
    applicant_full_name varchar(500),
    CONSTRAINT fda_products_pk PRIMARY KEY (appl_no, product_no, type) USING INDEX TABLESPACE index_tbs

)
    tablespace ernie_fda_tbs;

CREATE UNIQUE INDEX IF NOT EXISTS fda_patents_uk
    ON fda_products (appl_no, product_no, type) TABLESPACE index_tbs;

create table if not exists fda_exclusivities
(
--     ernie_id         serial,
    appl_type        varchar(10),
    appl_no          varchar(15) NOT NULL DEFAULT '',
    product_no       varchar(15) NOT NULL DEFAULT '',
    exclusivity_code varchar(20) NOT NULL DEFAULT '',
    exclusivity_date varchar(50),
    CONSTRAINT fda_exclusivities_pk PRIMARY KEY (appl_no, product_no, exclusivity_code) USING INDEX TABLESPACE index_tbs

)
    tablespace ernie_fda_tbs;

CREATE UNIQUE INDEX IF NOT EXISTS fda_exclusivities_uk
    ON fda_exclusivities (appl_no, product_no, exclusivity_code) TABLESPACE index_tbs;

create table if not exists fda_purple_book
(
    bla_stn                                         varchar(20) not null
        constraint fda_purple_book_pk
            primary key,
    product_name                                    varchar(300),
    proprietary_name                                varchar(300),
    date_of_licensure_m_d_y                         varchar(20),
    date_of_first_licensure_m_d_y                   varchar(20),
    reference_product_exclusivity_expiry_date_m_d_y varchar(20),
    interchangable_biosimilar                       varchar(20),
    withdrawn                                       varchar(20),
    CONSTRAINT fda_purple_book_pk PRIMARY KEY (bla_stn) USING INDEX TABLESPACE index_tbs
);

create unique index fda_purple_book_pk
    on fda_purple_book (bla_stn);
