\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create table if not exists stg_scopus_publication_groups
(
	sgr bigint,
	pub_year smallint
);


create table if not exists stg_scopus_sources
(   ernie_source_id int,
	source_id text,
	issn_main text,
	isbn_main text,
	source_type text,
	source_title text,
	coden_code text,
	website text,
	publisher_name text,
	publisher_e_address text,
	pub_date date,
	last_updated_time timestamp default now()
);


create table if not exists stg_scopus_isbns
(   ernie_source_id int,
	isbn text,
	isbn_length text,
	isbn_type text,
	isbn_level text,
	last_updated_time timestamp default now()
);


create table if not exists stg_scopus_issns
(   ernie_source_id int,
	issn text,
	issn_type text,
	last_updated_time timestamp default now()
);


create table if not exists stg_scopus_conference_events
(
	conf_code text,
	conf_name text,
	conf_address text,
	conf_city text,
	conf_postal_code text,
	conf_start_date date,
	conf_end_date date,
	conf_number text,
	conf_catalog_number text,
	conf_sponsor text,
	last_updated_time timestamp default now()
);


create table if not exists stg_scopus_publications
(   scp bigint,
	sgr bigint,
	correspondence_person_indexed_name text,
	correspondence_orgs text,
	correspondence_city text,
	correspondence_country text,
	correspondence_e_address text,
	pub_type text,
	citation_type text,
	citation_language text,
	process_stage text,
	state text,
	ernie_source_id int,
	date_sort date);

create table if not exists stg_scopus_authors
(
	scp bigint,
	author_seq smallint,
	auid bigint,
	author_indexed_name text,
	author_surname text,
	author_given_name text,
	author_initials text,
	author_e_address text,
	author_rank text,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_affiliations
(
	scp bigint,
	affiliation_no smallint,
	afid bigint,
	dptid bigint,
	organization text,
	city_group text,
	state text,
	postal_code text,
	country_code text,
	country text,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_author_affiliations
(
	scp bigint,
	author_seq smallint,
	affiliation_no smallint,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_source_publication_details
(
	scp bigint,
	issue text,
	volume text,
	first_page text,
	last_page text,
	publication_year smallint,
	publication_date date,
	indexed_terms text,
	conf_code text,
	conf_name text,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_subjects
(
	scp bigint,
	subj_abbr scopus_subject_abbre_type,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_subject_keywords
(
	scp bigint,
	subject text,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_classification_lookup
(
	class_type text,
	class_code text,
	description text,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_classes
(
	scp bigint,
	class_type text,
	class_code text,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_conf_proceedings
(   ernie_source_id int,
	conf_code text,
	conf_name text,
	proc_part_no text,
	proc_page_range text,
	proc_page_count smallint,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_conf_editors
(   ernie_source_id int,
	conf_code text,
	conf_name text,
	indexed_name text,
	role_type text,
	initials text,
	surname text,
	given_name text,
	degree text,
	suffix text,
	address text,
	organization text,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_references
(
	scp bigint,
	ref_sgr bigint,
	citation_text text
);

create table if not exists stg_scopus_publication_identifiers
(
	scp bigint,
	document_id text not null,
	document_id_type text not null,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_abstracts
(
	scp bigint,
	abstract_text text,
	abstract_language text not null,
	abstract_source text,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_titles
(
	scp bigint,
	title text not null,
	language text not null,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_keywords
(
	scp bigint,
	keyword text not null,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_chemical_groups
(
	scp bigint,
	chemicals_source text not null,
	chemical_name text not null,
	cas_registry_number text default ' '::text not null,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_grants
(
	scp bigint,
	grant_id text,
	grantor_acronym text,
	grantor text not null,
	grantor_country_code char(3),
	grantor_funder_registry_id text,
	last_updated_time timestamp default now()
);

create table if not exists stg_scopus_grant_acknowledgements
(
	scp bigint,
	grant_text text,
	last_updated_time timestamp default now()
);

