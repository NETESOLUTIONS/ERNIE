/*
This script converts the old surogate id columns to auto incremental columns in database:
    1. updates the column from simple integer types to not null integers with auto incremental values
Relevant main tables:
    1. wos_addresses
    2. wos_authors
    3. wos_document_identifiers
    4. wos_grants
    5. wos_keywords
    6. wos_publications
    7. wos_references
    8. wos_titles
    9. wos_abstracts
Usage: psql -f Autoincremental.sql

Author: Akshat Maltare
Created: 04/09/2018
Modified:

*/

\set ON_ERROR_STOP on
SET search_path TO akshat;
SET default_tablespace = wos;
SET current_user = akshat;
ALTER TABLE wos_publications OWNER TO current_user;
CREATE SEQUENCE publications_id_seq OWNED BY wos_publications.id;
ALTER TABLE wos_publications ALTER COLUMN id SET NOT NULL;
ALTER TABLE wos_publications ALTER COLUMN id SET DEFAULT nextval('publications_id_seq');
UPDATE wos_publications SET id = DEFAULT;

ALTER TABLE wos_grants OWNER TO current_user;
CREATE SEQUENCE grant_id_seq OWNED BY wos_grants.id;
ALTER TABLE wos_grants ALTER COLUMN id SET NOT NULL;
ALTER TABLE wos_grants ALTER COLUMN id SET DEFAULT nextval('grant_id_seq');
UPDATE wos_grants SET id = DEFAULT;

ALTER TABLE wos_document_identifiers OWNER TO current_user;
CREATE SEQUENCE document_id_seq OWNED BY wos_document_identifiers.id;
ALTER TABLE wos_document_identifiers ALTER COLUMN id SET NOT NULL;
ALTER TABLE wos_document_identifiers ALTER COLUMN id SET DEFAULT nextval('document_id_seq');
UPDATE wos_document_identifiers SET id = DEFAULT;

ALTER TABLE wos_keywords OWNER TO current_user;
CREATE SEQUENCE keyword_id_seq OWNED BY wos_keywords.id;
ALTER TABLE wos_keywords ALTER COLUMN id SET NOT NULL;
ALTER TABLE wos_keywords ALTER COLUMN id SET DEFAULT nextval('keyword_id_seq');
UPDATE wos_keywords SET id = DEFAULT;

ALTER TABLE wos_abstracts OWNER TO current_user;
CREATE SEQUENCE abstract_id_seq OWNED BY wos_abstracts.id;
ALTER TABLE wos_abstracts ALTER COLUMN id SET NOT NULL;
ALTER TABLE wos_abstracts ALTER COLUMN id SET DEFAULT nextval('abstract_id_seq');
UPDATE wos_abstracts SET id = DEFAULT;

ALTER TABLE wos_addresses OWNER TO current_user;
CREATE SEQUENCE address_id_seq OWNED BY wos_addresses.id;
ALTER TABLE wos_addresses ALTER COLUMN id SET NOT NULL;
ALTER TABLE wos_addresses ALTER COLUMN id SET DEFAULT nextval('address_id_seq');
UPDATE wos_addresses SET id = DEFAULT;

ALTER TABLE wos_titles OWNER TO current_user;
CREATE SEQUENCE title_id_seq OWNED BY wos_titles.id;
ALTER TABLE wos_titles ALTER COLUMN id SET NOT NULL;
ALTER TABLE wos_titles ALTER COLUMN id SET DEFAULT nextval('title_id_seq');
UPDATE wos_titles SET id = DEFAULT;

ALTER TABLE wos_authors OWNER TO current_user;
CREATE SEQUENCE author_id_seq OWNED BY wos_authors.id;
ALTER TABLE wos_authors ALTER COLUMN id SET NOT NULL;
ALTER TABLE wos_authors ALTER COLUMN id SET DEFAULT nextval('author_id_seq');
UPDATE wos_authors SET id = DEFAULT;

ALTER TABLE wos_references OWNER TO current_user;
CREATE SEQUENCE reference_id_seq OWNED BY wos_references.id;
ALTER TABLE wos_references ALTER COLUMN id SET NOT NULL;
ALTER TABLE wos_references ALTER COLUMN id SET DEFAULT nextval('reference_id_seq');
UPDATE wos_references SET id = DEFAULT;

