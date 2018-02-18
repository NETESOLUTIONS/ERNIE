-- Author: Samet Keserci, revised from DK's De-Duplication.sql
-- Create Date: 12/26/2017

\set ECHO all
\set ON_ERROR_STOP on

-- region new_wos_abstracts
DELETE
FROM new_wos_abstracts wa1
WHERE EXISTS(SELECT 1
             FROM new_wos_abstracts wa2
             WHERE wa2.source_id = wa1.source_id
               AND wa2.abstract_text = wa1.abstract_text
               AND wa2.source_filename = wa1.source_filename
               AND wa2.ctid > wa1.ctid);





-- region new_wos_addresses
DELETE
FROM new_wos_addresses wa1
WHERE EXISTS(SELECT 1
             FROM new_wos_addresses wa2
             WHERE wa2.source_id = wa1.source_id
               AND wa2.address_name = wa1.address_name
               AND wa2.ctid > wa1.ctid);



 -- region wos_authors
 DELETE
 FROM new_wos_authors wa1
 WHERE EXISTS(SELECT 1
              FROM new_wos_authors wa2
              WHERE wa2.source_id = wa1.source_id
                AND wa2.seq_no = wa1.seq_no
                AND coalesce(wa2.address_id, -1) = coalesce(wa1.address_id, -1)
                AND wa2.ctid > wa1.ctid);

-- region wos_document_identifiers
DELETE
FROM new_wos_document_identifiers wdi1
WHERE EXISTS(SELECT 1
             FROM new_wos_document_identifiers wdi2
             WHERE wdi2.source_id = wdi1.source_id
               AND wdi2.document_id_type = wdi1.document_id_type
               AND coalesce(wdi2.document_id, '') = coalesce(wdi1.document_id, '')
               AND wdi2.ctid > wdi1.ctid);


DELETE
FROM new_wos_grants wg1
WHERE EXISTS(SELECT 1
            FROM new_wos_grants wg2
            WHERE wg2.source_id = wg1.source_id
              AND wg2.grant_number = wg1.grant_number
              AND coalesce(wg2.grant_organization, '') = coalesce(wg1.grant_organization, '')
              AND wg2.ctid > wg1.ctid);


-- region wos_keywords
DELETE
FROM new_wos_keywords wk1
WHERE EXISTS(SELECT 1
             FROM new_wos_keywords wk2
             WHERE wk2.source_id = wk1.source_id
               AND wk2.keyword = wk1.keyword
               AND wk2.ctid > wk1.ctid);

-- region wos_publications
DELETE
FROM new_wos_publications wp1
WHERE EXISTS(SELECT 1
        FROM new_wos_publications wp2
        WHERE wp2.source_id = wp1.source_id
          AND wp2.ctid > wp1.ctid);


-- region wos_titles
DELETE
FROM new_wos_titles wt1
WHERE EXISTS(SELECT 1
             FROM new_wos_titles wt2
             WHERE wt2.source_id = wt1.source_id
               AND wt2.type = wt1.type
               AND wt2.ctid > wt1.ctid);

-- De-duplication of new_wos_ref_tables.
DELETE
FROM new_wos_references wr1
WHERE EXISTS(SELECT 1
            FROM new_wos_references wr2
            WHERE wr2.source_id = wr1.source_id
              AND wr2.cited_source_uid = wr1.cited_source_uid
              AND wr2.ctid > wr1.ctid);
