-- region wos_publications
DELETE
FROM
  wos_publications wp1
WHERE
  EXISTS(SELECT 1
         FROM
           wos_publications wp2
         WHERE
           wp2.source_id = wp1.source_id
             AND wp2.ctid > wp1.ctid);

ALTER TABLE wos_publications
  ALTER COLUMN publication_year TYPE INTEGER USING cast(publication_year AS INTEGER);
-- 29m:45s

ALTER TABLE wos_publications
  ALTER COLUMN source_id SET NOT NULL,
  -- Nullable: begin_page
  ALTER COLUMN created_date SET NOT NULL,
  ALTER COLUMN document_type SET NOT NULL,
  -- Nullable: document_title
  ALTER COLUMN edition SET NOT NULL,
  -- Nullable: end_page
  ALTER COLUMN has_abstract SET NOT NULL,
  ALTER COLUMN "language" SET NOT NULL,
  ALTER COLUMN last_modified_date SET NOT NULL,
  -- Nullable: publisher_address
  ALTER COLUMN publication_date SET NOT NULL,
  -- Nullable: publisher_name
  ALTER COLUMN publication_year SET NOT NULL,
  -- Nullable: source_title
  ALTER COLUMN source_type SET NOT NULL;
-- 5m:07s

ALTER TABLE wos_publications
  ADD CONSTRAINT wos_publications_pk PRIMARY KEY (source_id);
-- 23m:17s

DROP INDEX IF EXISTS ssd_wos_pub_source_id_index CASCADE;
-- endregion

-- region wos_references
DELETE
FROM wos_references wr1
WHERE EXISTS(SELECT 1
             FROM wos_references wr2
             WHERE wr2.source_id = wr1.source_id
               AND wr2.cited_source_uid = wr1.cited_source_uid
               AND wr2.ctid > wr1.ctid);
-- 17h:15m

ALTER TABLE wos_references
  ADD CONSTRAINT wos_references_pk PRIMARY KEY (source_id, cited_source_uid) USING INDEX TABLESPACE indexes;
-- 11h:49m

DROP INDEX IF EXISTS ssd_ref_sourceid_index;
-- endregion

--region wos_abstracts
-- 6m:18s
ALTER TABLE wos_abstracts
  ALTER COLUMN abstract_text SET NOT NULL;

DELETE
FROM wos_abstracts t1
WHERE EXISTS(SELECT 1
             FROM wos_abstracts t2
             WHERE t2.source_id = t1.source_id
               AND t2.abstract_text = t1.abstract_text
               AND t2.ctid > t1.ctid);
-- endregion

-- region wos_authors
DELETE
FROM wos_authors wa1
WHERE EXISTS(SELECT 1
             FROM wos_authors wa2
             WHERE wa2.source_id = wa1.source_id
               AND wa2.seq_no = wa1.seq_no
               AND coalesce(wa2.address_id, -1) = coalesce(wa1.address_id, -1)
               AND wa2.ctid > wa1.ctid);
-- ?

ALTER TABLE wos_authors
  ALTER COLUMN source_id SET NOT NULL,
  ALTER COLUMN seq_no SET NOT NULL;
-- 14m:12s

CREATE UNIQUE INDEX wos_authors_uk
  ON wos_authors (source_id, seq_no, address_id) TABLESPACE indexes;
-- 1h:45m

DROP INDEX IF EXISTS ssd_wos_auth_source_id_index;
--
-- endregion

-- region wos_addresses
DELETE
FROM wos_addresses wa1
WHERE EXISTS(SELECT 1
             FROM wos_addresses wa2
             WHERE wa2.source_id = wa1.source_id
               AND wa2.address_name = wa1.address_name
               AND wa2.ctid > wa1.ctid);
--

ALTER TABLE wos_addresses
  ALTER COLUMN source_id SET NOT NULL,
  ALTER COLUMN address_name SET NOT NULL;
-- 0.1s

ALTER TABLE wos_addresses
  ADD CONSTRAINT wos_addresses_pk PRIMARY KEY (source_id, address_name) USING INDEX TABLESPACE indexes;
--

DROP INDEX IF EXISTS wos_addresses_sourceid_index CASCADE;
--
-- endregion

-- region wos_grants
DELETE
FROM wos_grants wg1
WHERE EXISTS(SELECT 1
             FROM wos_grants wg2
             WHERE wg2.source_id = wg1.source_id
               AND wg2.grant_number = wg1.grant_number
               AND coalesce(wg2.grant_organization, '') = coalesce(wg1.grant_organization, '')
               AND wg2.ctid > wg1.ctid);
-- 20m:21s

ALTER TABLE wos_grants
  ALTER COLUMN source_id SET NOT NULL,
  ALTER COLUMN grant_number SET NOT NULL;
--  3m:54s

CREATE UNIQUE INDEX wos_grants_uk
  ON wos_grants (source_id, grant_number, grant_organization)
TABLESPACE indexes;
-- 7m:54s

DROP INDEX IF EXISTS wos_grants_sourceid_index;
--
-- endregion

-- region wos_titles
DELETE
FROM wos_titles wt1
WHERE EXISTS(SELECT 1
             FROM wos_titles wt2
             WHERE wt2.source_id = wt1.source_id
               AND wt2.type = wt1.type
               AND wt2.ctid > wt1.ctid);
-- 47m:53s

ALTER TABLE wos_titles
  ALTER COLUMN source_id SET NOT NULL,
  ALTER COLUMN type SET NOT NULL,
  ALTER COLUMN title SET NOT NULL;
-- 33m:09s

ALTER TABLE wos_titles
  ADD CONSTRAINT wos_titles_pk PRIMARY KEY (source_id, type) USING INDEX TABLESPACE indexes;
-- 2h:58m

DROP INDEX IF EXISTS wos_titles_sourceid_index;
--
-- endregion

-- region wos_document_identifiers
DELETE
FROM wos_document_identifiers wdi1
WHERE EXISTS(SELECT 1
             FROM wos_document_identifiers wdi2
             WHERE wdi2.source_id = wdi1.source_id
               AND wdi2.document_id_type = wdi1.document_id_type
               AND coalesce(wdi2.document_id, '') = coalesce(wdi1.document_id, '')
               AND wdi2.ctid > wdi1.ctid);
-- 2h:11m

ALTER TABLE wos_document_identifiers
  ALTER COLUMN source_id SET NOT NULL,
  ALTER COLUMN document_id_type SET NOT NULL;
-- 10m:30s

CREATE UNIQUE INDEX wos_document_identifiers_uk
  ON wos_document_identifiers (source_id, document_id_type, document_id)
TABLESPACE indexes;
-- ?

DROP INDEX IF EXISTS wos_dois_sourceid_index;
-- 0.6s
-- endregion

-- region wos_keywords
DELETE
FROM wos_keywords wk1
WHERE EXISTS(SELECT 1
             FROM wos_keywords wk2
             WHERE wk2.source_id = wk1.source_id
               AND wk2.keyword = wk1.keyword
               AND wk2.ctid > wk1.ctid);
-- 1h:38m

ALTER TABLE wos_keywords
  ALTER COLUMN source_id SET NOT NULL,
  ALTER COLUMN keyword SET NOT NULL;
-- 5m:25s

ALTER TABLE wos_keywords
  ADD CONSTRAINT wos_keywords_pk PRIMARY KEY (source_id, keyword) USING INDEX TABLESPACE indexes;
-- 1h:03m

DROP INDEX IF EXISTS wos_keywords_sourceid_index;
--
-- endregion

-- region wos_pmid_mapping
ALTER TABLE wos_pmid_mapping
  ALTER COLUMN wos_id SET NOT NULL,
  ALTER COLUMN pmid SET NOT NULL,
  ALTER COLUMN pmid_int SET NOT NULL;
-- 50.389s

ALTER TABLE wos_pmid_mapping
  ADD CONSTRAINT wos_pmid_mapping_pk PRIMARY KEY (wos_id);
-- 2.65s

CREATE UNIQUE INDEX wpm_pmid_int_uk
  ON wos_pmid_mapping (pmid_int);
-- 1m:27s

-- ALTER TABLE wos_pmid_mapping DROP CONSTRAINT new_wos_pmid_mapping_pkey1;
DROP INDEX IF EXISTS wos_pmid_mapping_pmid_idx;
DROP INDEX IF EXISTS wos_pmid_mapping_wos_id_idx;
-- endregion

-- region wos_patent_mapping
ALTER TABLE wos_patent_mapping
  ALTER COLUMN wos_id SET NOT NULL,
  ALTER COLUMN patent_no SET NOT NULL;
-- 14.7s

ALTER TABLE wos_patent_mapping
  ADD CONSTRAINT wos_patent_mapping_pk PRIMARY KEY (patent_no, wos_id) USING INDEX TABLESPACE indexes;
-- 2m:27s

DROP INDEX IF EXISTS wos_patent_mapping_patent_no_idx;
DROP INDEX IF EXISTS wos_patent_mapping_wos_id_idx;
-- endregion