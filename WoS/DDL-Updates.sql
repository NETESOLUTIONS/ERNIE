-- ## De-duplication ##

-- ### wos_publications ###

/*
-- 32m+
SELECT COUNT(1)
FROM (SELECT source_id
      FROM wos_publications wp1
      GROUP BY source_id
      HAVING COUNT(1) > 1) main;
-- 71,751
*/

/*
-- 33m:51s              
SELECT COUNT(DISTINCT source_id)
FROM (
  SELECT source_id, ROW_NUMBER() OVER (PARTITION BY source_id ORDER BY id DESC) AS r
  FROM wos_publications
) main
WHERE r > 1;
-- 71,751
*/

/*
SELECT ctid, *
FROM wos_publications
WHERE source_id = 'WOS:000366299500017';
*/

/*
ALTER TABLE wos_publications RENAME TO wos_publications_bak;

-- 23m:24s
CREATE TABLE wos_publications
TABLESPACE wosdata_ssd_tbs
AS
SELECT DISTINCT begin_page, created_date, document_title, document_type, edition,
       end_page, has_abstract, id, issue, language,
       last_modified_date, publication_date, CAST(publication_year AS integer), publisher_address, publisher_name,
       source_filename, source_id, source_title, source_type, volume
FROM wos_publications_bak;*/

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

-- 29m:45s
--ALTER TABLE wos_publications ALTER COLUMN publication_year TYPE integer USING publication_year::integer;

--DROP TABLE wos_publications_bak;

-- ### wos_references ###

-- 10h-18h
DELETE
FROM wos_references wr1
WHERE EXISTS (SELECT 1
              FROM wos_references wr2
              WHERE wr2.source_id = wr1.source_id
              AND   wr2.cited_source_uid = wr1.cited_source_uid
              AND   wr2.ctid > wr1.ctid);

/*
-- 13m:58s
SELECT *
FROM wos_references wr1
WHERE EXISTS (SELECT 1
              FROM wos_references wr2
              WHERE wr2.source_id = wr1.source_id
              AND   wr2.cited_source_uid = wr1.cited_source_uid
              AND   wr2.id > wr1.id)
FETCH FIRST 2 ROWS ONLY;
*/

/*
SELECT *
FROM wos_references wr1
WHERE 
  --(source_id, cited_source_uid) = ('WOS:000178789100019', 'WOS:000078974400030');
-- to delete id > 22958
  (source_id, cited_source_uid) = ('WOS:000178789100019', 'WOS:000080394100027');
-- to delete id > 22965	
*/

-- ## DDL updates ##

-- ### wos_pmid_mapping ###

-- ALTER TABLE wos_pmid_mapping DROP CONSTRAINT new_wos_pmid_mapping_pkey1;
DROP INDEX wos_pmid_mapping_pmid_idx;
DROP INDEX wos_pmid_mapping_wos_id_idx;

-- 50.389s
ALTER TABLE wos_pmid_mapping ALTER COLUMN wos_id SET NOT NULL;

-- 2.65s
ALTER TABLE wos_pmid_mapping ALTER COLUMN pmid SET NOT NULL;

-- 1.747ms
ALTER TABLE wos_pmid_mapping ALTER COLUMN pmid_int SET NOT NULL;

-- 6m:16s
ALTER TABLE wos_pmid_mapping ADD CONSTRAINT wos_pmid_mapping_pk PRIMARY KEY(wos_id);

-- 1m:27s
CREATE UNIQUE INDEX wpm_pmid_int_uk ON wos_pmid_mapping(pmid_int);

-- ### wos_publications ###

-- 5m:07s
ALTER TABLE wos_publications ALTER COLUMN source_id SET NOT NULL;

-- 23m:17s
ALTER TABLE wos_publications ADD CONSTRAINT wos_publications_pk PRIMARY KEY(source_id);

-- ### wos_references ###

-- 6h-15h
ALTER TABLE wos_references ADD CONSTRAINT wos_references_pk PRIMARY KEY(source_id, cited_source_uid)
USING INDEX TABLESPACE ernie_index_tbs;

DROP INDEX ssd_ref_sourceid_index;
