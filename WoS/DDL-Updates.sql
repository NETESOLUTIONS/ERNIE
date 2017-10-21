-- ### wos_publications ###

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
  ALTER COLUMN source_id SET NOT NULL;
-- 5m:07s

ALTER TABLE wos_publications
  ADD CONSTRAINT wos_publications_pk PRIMARY KEY (source_id);
-- 23m:17s

DROP INDEX IF EXISTS ssd_wos_pub_source_id_index CASCADE;

-- ### wos_references ###

DELETE
FROM wos_references wr1
WHERE EXISTS(SELECT 1
             FROM wos_references wr2
             WHERE wr2.source_id = wr1.source_id
               AND wr2.cited_source_uid = wr1.cited_source_uid
               AND wr2.ctid > wr1.ctid);
-- ... 10h-18h

ALTER TABLE wos_references
  ADD CONSTRAINT wos_references_pk PRIMARY KEY (source_id, cited_source_uid) USING INDEX TABLESPACE ernie_index_tbs;
-- ? 6h-15h

DROP INDEX ssd_ref_sourceid_index;

-- ### wos_authors ###

DELETE
FROM wos_authors wa1
WHERE EXISTS(SELECT 1
             FROM wos_authors wa2
             WHERE wa2.source_id = wa1.source_id
               AND wa2.seq_no = wa1.seq_no
               AND coalesce(wa2.address_id, -1) = coalesce(wa1.address_id, -1)
               AND wa2.ctid > wa1.ctid);
-- ...

ALTER TABLE wos_authors
  ADD CONSTRAINT wos_authors_pk PRIMARY KEY (source_id, seq_no) USING INDEX TABLESPACE ernie_index_tbs;

-- ### wos_addresses ###

DELETE
FROM wos_addresses wa1
WHERE EXISTS(SELECT 1
             FROM wos_addresses wa2
             WHERE wa2.source_id = wa1.source_id
               AND wa2.address_name = wa1.address_name
               AND wa2.ctid > wa1.ctid);
--- ...

ALTER TABLE wos_addresses
  ADD CONSTRAINT wos_addresses_pk PRIMARY KEY (source_id, address_name) USING INDEX TABLESPACE ernie_index_tbs;

-- ### wos_addresses ###

ALTER TABLE wos_grants
  ADD CONSTRAINT wos_grants_pk
PRIMARY KEY (source_id, grant_organization, grant_number)
USING INDEX TABLESPACE ernie_index_tbs;

-- ### wos_pmid_mapping ###

-- ALTER TABLE wos_pmid_mapping DROP CONSTRAINT new_wos_pmid_mapping_pkey1;
DROP INDEX IF EXISTS wos_pmid_mapping_pmid_idx;
DROP INDEX IF EXISTS wos_pmid_mapping_wos_id_idx;

ALTER TABLE wos_pmid_mapping
  ALTER COLUMN wos_id SET NOT NULL;
-- 50.389s

ALTER TABLE wos_pmid_mapping
  ALTER COLUMN pmid SET NOT NULL;
-- 2.65s

ALTER TABLE wos_pmid_mapping
  ALTER COLUMN pmid_int SET NOT NULL;
-- 2.65s

ALTER TABLE wos_pmid_mapping
  ADD CONSTRAINT wos_pmid_mapping_pk PRIMARY KEY (wos_id);
-- 2.65s

CREATE UNIQUE INDEX wpm_pmid_int_uk
  ON wos_pmid_mapping (pmid_int);
-- 1m:27s