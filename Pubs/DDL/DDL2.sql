create table if not exists wos_abstracts
(
	id serial not null,
	source_id varchar(30) not null
		constraint wos_abstracts_pk
			primary key,
	abstract_text text not null,
	source_filename varchar(200) not null,
	last_updated_time timestamp default now()
);
comment on table wos_abstracts is 'Thomson Reuters: WoS - WoS abstract of publications';
comment on column wos_abstracts.id is ' Example: 16753';
comment on column wos_abstracts.source_id is 'UT. Example: WOS:000362820500006';
comment on column wos_abstracts.abstract_text is 'Publication abstract. Multiple sections are separated by two line feeds (LF).';
comment on column wos_abstracts.source_filename is 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';
alter table wos_abstracts owner to ernie_admin;
create or replace function update_wos_abstracts_function() returns trigger
	language plpgsql
as $$
BEGIN
        IF (TG_OP = 'UPDATE') THEN
            INSERT INTO uhs_wos_abstracts  VALUES(OLD.id,OLD.source_id, OLD.abstract_text, OLD.source_filename, OLD.last_updated_time );
        END IF;
        RETURN NULL;
    END;
$$;
alter function update_wos_abstracts_function() owner to ernie_admin;
create trigger update_wos_abstracts_trigger
	after update
	on wos_abstracts
	for each row
	execute procedure update_wos_abstracts_function();
------------------------------------------------------------------------------------------------------


create table wos_addresses
(
	id serial not null,
	source_id varchar(30) not null,
	address_name varchar(300) not null,
	organization varchar(400),
	sub_organization varchar(400),
	city varchar(100),
	country varchar(100),
	zip_code varchar(20),
	source_filename varchar(200),
	last_updated_time timestamp default now(),
	constraint wos_addresses_pk
		primary key (source_id, address_name)
);
comment on table wos_addresses is 'Thomson Reuters: WoS - WoS address where publications are written';
comment on column wos_addresses.id is ' Example: 1';
comment on column wos_addresses.source_id is 'UT. Example: WOS:000354914100020';
comment on column wos_addresses.address_name is ' Example: Eastern Hlth Clin Sch, Melbourne, Vic, Australia';
comment on column wos_addresses.organization is ' Example: Walter & Eliza Hall Institute';
comment on column wos_addresses.sub_organization is ' Example: Dipartimento Fis';
comment on column wos_addresses.city is ' Example: Cittadella Univ';
comment on column wos_addresses.country is ' Example: Italy';
comment on column wos_addresses.zip_code is ' Example: I-09042';
comment on column wos_addresses.source_filename is 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';
alter table wos_addresses owner to ernie_admin;
create function update_wos_addresses_function() returns trigger
	language plpgsql
as $$
BEGIN
        IF (TG_OP = 'UPDATE') THEN
           INSERT INTO  uhs_wos_addresses VALUES(OLD.id,OLD.source_id, OLD.address_name, OLD.organization,OLD.sub_organization,OLD.city ,OLD.country,OLD.zip_code,OLD.source_filename, OLD.last_updated_time );
        END IF;
        RETURN NULL;
    END;
$$;
alter function update_wos_addresses_function() owner to ernie_admin;
create trigger update_wos_addresses_trigger
	after update
	on wos_addresses
	for each row
	execute procedure update_wos_addresses_function();
------------------------------------------------------------------------------------------------------


create table if not exists wos_authors
(
	id serial not null,
	source_id varchar(30) default ''::character varying not null,
	full_name varchar(200),
	last_name varchar(200),
	first_name varchar(200),
	seq_no integer default 0 not null,
	address_seq integer,
	address varchar(500),
	email_address varchar(300),
	address_id integer default 0 not null,
	dais_id varchar(30),
	r_id varchar(30),
	source_filename varchar(200),
	last_updated_time timestamp default now(),
	constraint wos_authors_pk
		primary key (source_id, seq_no, address_id)
);
comment on table wos_authors is 'Thomson Reuters: WoS - WoS authors of publications';
comment on column wos_authors.id is ' Example: 15135';
comment on column wos_authors.source_id is 'UT. Example: WOS:000078266100010';
comment on column wos_authors.full_name is ' Example: Charmandaris, V';
comment on column wos_authors.last_name is ' Example: Charmandaris';
comment on column wos_authors.first_name is ' Example: V';
comment on column wos_authors.seq_no is ' Example: 6';
comment on column wos_authors.address_seq is ' Example: 1';
comment on column wos_authors.address is ' Example: Univ Birmingham, Sch Psychol, Birmingham B15 2TT, W Midlands, England';
comment on column wos_authors.email_address is ' Example: k.j.linnell@bham.ac.uk';
comment on column wos_authors.address_id is ' Example: 7186';
comment on column wos_authors.dais_id is ' Example: 16011591';
comment on column wos_authors.r_id is ' Example: A-7196-2008';
comment on column wos_authors.source_filename is 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';
alter table wos_authors owner to ernie_admin;
create or replace function update_wos_authors_function() returns trigger
	language plpgsql
as $$
BEGIN
        IF (TG_OP = 'UPDATE') THEN
          INSERT INTO  uhs_wos_authors VALUES(OLD.id,OLD.source_id, OLD.full_name, OLD.last_name,OLD.first_name,OLD.seq_no,OLD.address_seq,OLD.address,OLD.email_address,OLD.address_id,OLD.dais_id,OLD.r_id,OLD.source_filename );
        END IF;
        RETURN NULL;
    END;
$$;
alter function update_wos_authors_function() owner to ernie_admin;
create trigger update_wos_authors_trigger
	after update
	on wos_authors
	for each row
	execute procedure update_wos_authors_function();
------------------------------------------------------------------------------------------------------


create table wos_document_identifiers
(
	id serial not null,
	source_id varchar(30) default ''::character varying not null,
	document_id varchar(100) default ''::character varying not null,
	document_id_type varchar(30) default ''::character varying not null,
	source_filename varchar(200),
	last_updated_time timestamp default now(),
	constraint wos_document_identifiers_pk
		primary key (source_id, document_id_type, document_id)
);
comment on table wos_document_identifiers is 'Thomson Reuters: WoS - WoS document identifiers of publications such as doi';
comment on column wos_document_identifiers.id is ' Example: 1';
comment on column wos_document_identifiers.source_id is 'UT. Example: WOS:000354914100020';
comment on column wos_document_identifiers.document_id is ' Example: CI7AA';
comment on column wos_document_identifiers.document_id_type is 'accession_no/issn/eissn/doi/eisbn/art_no etc.. Example: doi';
comment on column wos_document_identifiers.source_filename is 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';
alter table wos_document_identifiers owner to ernie_admin;
create function update_wos_document_identifiers_function() returns trigger
	language plpgsql
as $$
BEGIN
        IF (TG_OP = 'UPDATE') THEN
           INSERT INTO  uhs_wos_document_identifiers VALUES(OLD.id, OLD.source_id, OLD.document_id, OLD.document_id_type,OLD.source_filename );
        END IF;
        RETURN NULL;
    END;
$$;
alter function update_wos_document_identifiers_function() owner to ernie_admin;
create trigger update_wos_document_identifiers_trigger
	after update
	on wos_document_identifiers
	for each row
	execute procedure update_wos_document_identifiers_function();
------------------------------------------------------------------------------------------------------


create table wos_grants
(
	id serial not null,
	source_id varchar(30) default ''::character varying not null,
	grant_number varchar(500) default ''::character varying not null,
	grant_organization varchar(400) default ''::character varying not null,
	funding_ack varchar(4000),
	source_filename varchar(200),
	last_updated_time timestamp default now(),
	constraint wos_grants_pk
		primary key (source_id, grant_number, grant_organization)
);
comment on table wos_grants is 'Thomson Reuters: WoS - WoS grants that fund publications';
comment on column wos_grants.id is ' Example: 14548';
comment on column wos_grants.source_id is ' Example: WOS:000340028400057';
comment on column wos_grants.grant_number is ' Example: NNG04GC89G';
comment on column wos_grants.grant_organization is ' Example: NASA LTSA grant';
comment on column wos_grants.funding_ack is ' Example: We thank Molly Peeples, Paul Torrey, Manolis Papastergis, and….';
comment on column wos_grants.source_filename is 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';
alter table wos_grants owner to ernie_admin;
create index wos_grant_source_id_index
	on wos_grants (source_id);
create function update_wos_grants_function() returns trigger
	language plpgsql
as $$
BEGIN
        IF (TG_OP = 'UPDATE') THEN
          INSERT INTO  uhs_wos_grants VALUES(OLD.id,OLD.source_id, OLD.grant_number, OLD.grant_organization,OLD.funding_ack,OLD.source_filename );
        END IF;
        RETURN NULL;
    END;
$$;
alter function update_wos_grants_function() owner to ernie_admin;
create trigger update_wos_grants_trigger
	after update
	on wos_grants
	for each row
	execute procedure update_wos_grants_function();
------------------------------------------------------------------------------------------------------


create table wos_keywords
(
	id serial not null,
	source_id varchar(30) not null,
	keyword varchar(200) not null,
	source_filename varchar(200),
	last_updated_time timestamp default now(),
	constraint wos_keywords_pk
		primary key (source_id, keyword)
);
comment on table wos_keywords is 'Thomson Reuters: WoS - WoS keyword of publications';
comment on column wos_keywords.id is ' Example: 62849';
comment on column wos_keywords.source_id is 'UT. Example: WOS:000353971800007';
comment on column wos_keywords.keyword is ' Example: NEONATAL INTRACRANIAL INJURY';
comment on column wos_keywords.source_filename is 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';
alter table wos_keywords owner to ernie_admin;
create function update_wos_keywords_function() returns trigger
	language plpgsql
as $$
BEGIN
        IF (TG_OP = 'UPDATE') THEN
         INSERT INTO  uhs_wos_keywords VALUES(OLD.id,OLD.source_id, OLD.keyword,OLD.source_filename );
        END IF;
        RETURN NULL;
    END;
$$;
alter function update_wos_keywords_function() owner to ernie_admin;
create trigger update_wos_keywords_trigger
	after update
	on wos_keywords
	for each row
	execute procedure update_wos_keywords_function();
------------------------------------------------------------------------------------------------------


create table wos_publications
(
	begin_page varchar(30),
	created_date date not null,
	document_title varchar(2000),
	document_type varchar(50) not null,
	edition varchar(40) not null,
	end_page varchar(30),
	has_abstract varchar(5) not null,
	id serial not null,
	issue varchar(10),
	language varchar(20) not null,
	last_modified_date date not null,
	publication_date date not null,
	publication_year varchar(4) not null,
	publisher_address varchar(300),
	publisher_name varchar(200),
	source_filename varchar(200),
	source_id varchar(30) not null
		constraint wos_publications_pk
			primary key,
	source_title varchar(300),
	source_type varchar(20) not null,
	volume varchar(20),
	last_updated_time timestamp default now()
);
comment on table wos_publications is 'Main Web of Science publication table';
comment on column wos_publications.begin_page is ' Example: 1421';
comment on column wos_publications.created_date is ' Example: 2016-03-18';
comment on column wos_publications.document_title is ' Example: Point-of-care testing for coeliac disease antibodies…';
comment on column wos_publications.document_type is ' Example: Article';
comment on column wos_publications.edition is ' Example: WOS.SCI';
comment on column wos_publications.end_page is ' Example: 1432';
comment on column wos_publications.has_abstract is 'Y or N. Example: Y';
comment on column wos_publications.id is 'id is always an integer- is an internal (PARDI) number. Example: 1';
comment on column wos_publications.issue is ' Example: 8';
comment on column wos_publications.language is ' Example: English';
comment on column wos_publications.last_modified_date is ' Example: 2016-03-18';
comment on column wos_publications.publication_date is ' Example: 2015-05-04';
comment on column wos_publications.publication_year is ' Example: 2015';
comment on column wos_publications.publisher_address is ' Example: LEVEL 2, 26-32 PYRMONT BRIDGE RD, PYRMONT, NSW 2009, AUSTRALIA';
comment on column wos_publications.publisher_name is ' Example: AUSTRALASIAN MED PUBL CO LTD';
comment on column wos_publications.source_filename is 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';
comment on column wos_publications.source_id is 'Paper Id (Web of Science UT). Example: WOS:000354914100020';
comment on column wos_publications.source_title is 'Journal title. Example: MEDICAL JOURNAL OF AUSTRALIA';
comment on column wos_publications.source_type is ' Example: Journal';
comment on column wos_publications.volume is ' Example: 202';
alter table wos_publications owner to akshat;
create index wos_publications_publication_year_i
	on wos_publications (publication_year);
create index wos_publications_last_modified_date_idx
	on wos_publications (last_modified_date);
create function update_wos_publications_function() returns trigger
	language plpgsql
as $$
BEGIN
        IF (TG_OP = 'UPDATE') THEN
        INSERT INTO  uhs_wos_publications VALUES(OLD.id,OLD.source_id, OLD.source_type, OLD.source_title,OLD.language,OLD.document_title,OLD.document_type,OLD.has_abstract,OLD.issue,OLD.volume,OLD.begin_page,OLD.end_page,OLD.publisher_name,OLD.publisher_address,OLD.publication_year,OLD.publication_date,OLD.created_date,OLD.last_modified_date,OLD.edition,OLD.source_filename );
        END IF;
        RETURN NULL;
    END;
$$;
alter function update_wos_publications_function() owner to ernie_admin;
create trigger update_wos_publications_trigger
	after update
	on wos_publications
	for each row
	execute procedure update_wos_publications_function();
------------------------------------------------------------------------------------------------------


create table wos_references
(
	wos_reference_id serial not null,
	source_id varchar(30) not null,
	cited_source_uid varchar(30) not null,
	cited_title varchar(80000),
	cited_work text,
	cited_author varchar(3000),
	cited_year varchar(40),
	cited_page varchar(200),
	created_date date,
	last_modified_date date,
	source_filename varchar(200),
	last_updated_time timestamp default now(),
	constraint wos_references_pk
		primary key (source_id, cited_source_uid)
);
comment on table wos_references is 'Thomson Reuters: WoS - WoS cited references';
comment on column wos_references.wos_reference_id is 'auto-increment integer, serving as a row key in distributed systems. Example: 1';
comment on column wos_references.source_id is 'UT. Example: WOS:000273726900017';
comment on column wos_references.cited_source_uid is 'UT. Example: WOS:000226230700068';
comment on column wos_references.cited_title is ' Example: Cytochrome P450 oxidoreductase gene mutations….';
comment on column wos_references.cited_work is ' Example: JOURNAL OF CLINICAL ENDOCRINOLOGY & METABOLISM';
comment on column wos_references.cited_author is ' Example: Fukami, M';
comment on column wos_references.cited_year is ' Example: 2005';
comment on column wos_references.cited_page is ' Example: 414';
comment on column wos_references.created_date is ' Example: 2016-03-31';
comment on column wos_references.last_modified_date is ' Example: 2016-03-31';
comment on column wos_references.source_filename is 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';
alter table wos_references owner to ernie_admin;
create index wr_cited_source_uid_source_id_i
	on wos_references (cited_source_uid, source_id);
create function update_wos_references_function() returns trigger
	language plpgsql
as $$
BEGIN
        IF (TG_OP = 'UPDATE') THEN
           INSERT INTO  uhs_wos_references VALUES(OLD.wos_reference_id,OLD.source_id,OLD.cited_source_uid,OLD.cited_title,OLD.cited_work,OLD.cited_author,OLD.cited_year,OLD.cited_page,OLD.created_date,OLD.last_modified_date,OLD.source_filename );
        END IF;
        RETURN NULL;
    END;
$$;
alter function update_wos_references_function() owner to ernie_admin;
create trigger update_wos_references_trigger
	after update
	on wos_references
	for each row
	execute procedure update_wos_references_function();
------------------------------------------------------------------------------------------------------


create table wos_titles
(
	id serial not null,
	source_id varchar(30) not null,
	title varchar(2000) not null,
	type varchar(100) not null,
	source_filename varchar(200),
	last_updated_time timestamp default now(),
	constraint wos_titles_pk
		primary key (source_id, type)
);
comment on table wos_titles is 'Thomson Reuters: WoS - WoS title of publications';
comment on column wos_titles.id is ' Example: 1';
comment on column wos_titles.source_id is ' Example: WOS:000354914100020';
comment on column wos_titles.title is ' Example: MEDICAL JOURNAL OF AUSTRALIA';
comment on column wos_titles.type is 'source, item,source_abbrev,abbrev_iso,abbrev_11,abbrev_29, etc.. Example: source';
comment on column wos_titles.source_filename is 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';
alter table wos_titles owner to ernie_admin;
create function update_wos_titles_function() returns trigger
	language plpgsql
as $$
BEGIN
        IF (TG_OP = 'UPDATE') THEN
            INSERT INTO  uhs_wos_titles VALUES(OLD.id,OLD.source_id,OLD.title ,OLD.type,OLD.source_filename );
        END IF;
        RETURN NULL;
    END;
$$;
alter function update_wos_titles_function() owner to ernie_admin;
create trigger update_wos_titles_trigger
	after update
	on wos_titles
	for each row
	execute procedure update_wos_titles_function();
