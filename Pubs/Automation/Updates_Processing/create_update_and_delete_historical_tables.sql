-- This script will create all the needed historical update and delete tables for WoS. Ensure this script has been ran and these tables exist for the weekly update process
-- Note: If you need to run this script, run it as ernie_admin
-- Author: VJ Davey
-- Date : 10/05/2017

--set tablespace
SET default_tablespace = ernie_wos_tbs;

-- Build update tables
CREATE TABLE uhs_wos_abstracts (
    id integer,
    source_id character varying(30),
    abstract_text character varying(4000),
    source_filename character varying(200)
);
CREATE TABLE uhs_wos_addresses (
    id integer,
    source_id character varying(30),
    address_name character varying(300),
    organization character varying(400),
    sub_organization character varying(400),
    city character varying(100),
    country character varying(100),
    zip_code character varying(20),
    source_filename character varying(200)
);
CREATE TABLE uhs_wos_authors (
    id integer,
    source_id character varying(30),
    full_name character varying(200),
    last_name character varying(200),
    first_name character varying(200),
    seq_no integer,
    address_seq integer,
    address character varying(500),
    email_address character varying(300),
    address_id integer,
    dais_id character varying(30),
    r_id character varying(30),
    source_filename character varying(200)
);
CREATE TABLE uhs_wos_document_identifiers (
    id integer,
    source_id character varying(30),
    document_id character varying(100),
    document_id_type character varying(30),
    source_filename character varying(200)
);
CREATE TABLE uhs_wos_grants (
    id integer,
    source_id character varying(30),
    grant_number character varying(500),
    grant_organization character varying(400),
    funding_ack character varying(4000),
    source_filename character varying(200)
);
CREATE TABLE uhs_wos_keywords (
    id integer,
    source_id character varying(30),
    keyword character varying(200),
    source_filename character varying(200)
);
CREATE TABLE uhs_wos_publications (
    id integer,
    source_id character varying(30),
    source_type character varying(20),
    source_title character varying(300),
    language character varying(20),
    document_title character varying(2000),
    document_type character varying(50),
    has_abstract character varying(5),
    issue character varying(10),
    volume character varying(20),
    begin_page character varying(30),
    end_page character varying(30),
    publisher_name character varying(200),
    publisher_address character varying(300),
    publication_year character varying(4),
    publication_date date,
    created_date date,
    last_modified_date date,
    edition character varying(40),
    source_filename character varying(200)
);
CREATE TABLE uhs_wos_references (
    id integer,
    source_id character varying(30),
    cited_source_uid character varying(30),
    cited_title character varying(8000),
    cited_work character varying(4000),
    cited_author character varying(1000),
    cited_year character varying(40),
    cited_page character varying(200),
    created_date date,
    last_modified_date date,
    source_filename character varying(200)
);
CREATE TABLE uhs_wos_titles (
    id integer,
    source_id character varying(30),
    title character varying(2000),
    type character varying(100),
    source_filename character varying(200)
);

-- Build delete tables
CREATE TABLE del_wos_abstracts (
    id integer,
    source_id character varying(30),
    abstract_text character varying(4000),
    source_filename character varying(200)
);
CREATE TABLE del_wos_addresses (
    id integer,
    source_id character varying(30),
    address_name character varying(300),
    organization character varying(400),
    sub_organization character varying(400),
    city character varying(100),
    country character varying(100),
    zip_code character varying(20),
    source_filename character varying(200)
);
CREATE TABLE del_wos_authors (
    id integer,
    source_id character varying(30),
    full_name character varying(200),
    last_name character varying(200),
    first_name character varying(200),
    seq_no integer,
    address_seq integer,
    address character varying(500),
    email_address character varying(300),
    address_id integer,
    dais_id character varying(30),
    r_id character varying(30),
    source_filename character varying(200)
);
CREATE TABLE del_wos_document_identifiers (
    id integer,
    source_id character varying(30),
    document_id character varying(100),
    document_id_type character varying(30),
    source_filename character varying(200)
);
CREATE TABLE del_wos_grants (
    id integer,
    source_id character varying(30),
    grant_number character varying(500),
    grant_organization character varying(400),
    funding_ack character varying(4000),
    source_filename character varying(200)
);
CREATE TABLE del_wos_keywords (
    id integer,
    source_id character varying(30),
    keyword character varying(200),
    source_filename character varying(200)
);
CREATE TABLE del_wos_publications (
    id integer,
    source_id character varying(30),
    source_type character varying(20),
    source_title character varying(300),
    language character varying(20),
    document_title character varying(2000),
    document_type character varying(50),
    has_abstract character varying(5),
    issue character varying(10),
    volume character varying(20),
    begin_page character varying(30),
    end_page character varying(30),
    publisher_name character varying(200),
    publisher_address character varying(300),
    publication_year character varying(4),
    publication_date date,
    created_date date,
    last_modified_date date,
    edition character varying(40),
    source_filename character varying(200)
);
CREATE TABLE del_wos_references (
    id integer,
    source_id character varying(30),
    cited_source_uid character varying(30),
    cited_title character varying(8000),
    cited_work character varying(4000),
    cited_author character varying(1000),
    cited_year character varying(40),
    cited_page character varying(200),
    created_date date,
    last_modified_date date,
    source_filename character varying(200)
);
CREATE TABLE del_wos_titles (
    id integer,
    source_id character varying(30),
    title character varying(2000),
    type character varying(100),
    source_filename character varying(200)
);
