// Clean DB
MATCH (n)
DETACH DELETE n;

WITH 'jdbc:postgresql://ernie1/ernie?user=ernie_admin&password=branch_H3A7_drawing' AS db,
     '-- Limited deterministic sample of publication references
     SELECT
       d.source_id,
       source_wp.document_title,
       d.source_year,
       d.source_document_id_type,
       d.source_issn,
       d.cited_source_uid,
       reference_wp.document_title AS reference_title,
       d.reference_year,
       d.reference_document_id_type,
       d.reference_issn
     FROM dataset1980 d
     JOIN wos_publications source_wp ON source_wp.source_id = d.source_id
     JOIN wos_publications reference_wp ON reference_wp.source_id = d.cited_source_uid
     ORDER BY d.source_id DESC
     LIMIT 100' AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
MERGE (p:Publication {source_id: row.source_id, title: row.document_title, year: row.source_year,
                      issn_type: row.source_document_id_type, issn: row.source_issn})
MERGE (r:Publication {source_id: row.cited_source_uid, title: row.reference_title, year: row.reference_year,
                      issn_type: row.reference_document_id_type, issn: row.reference_issn})
MERGE (p)-[:CITES]->(r);