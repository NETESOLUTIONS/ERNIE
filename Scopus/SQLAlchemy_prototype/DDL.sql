create table scopus_documents(
  scopus_id VARCHAR not null,
  pmid varchar,
  title varchar,
  publication_name varchar,
  document_type varchar,
  issn varchar,
  volume varchar,
  first_page varchar,
  last_page varchar,
  publication_year varchar,
  publication_month varchar,
  publication_day varchar,
  doi varchar,
  primary key(scopus_id)
);

create table scopus_authors(
  scopus_id VARCHAR not null,
  author_id varchar not null,
  author_initial varchar,
  author_surname varchar,
  author_indexed_name varchar,
  seq=varchar,
  primary key(scopus_id,author_id)
);

create table scopus_references(
  scopus_id VARCHAR not null,
  ref_id varchar,
  source_title varchar,
  publication_year varchar,
  primary key (scopus_id,ref_id)
);

create table scopus_addresses(
  scopus_id VARCHAR not null,
  afid varchar,
  organization varchar,
  city varchar,
  country varchar,
  primary key (scopus_id,afid)
);