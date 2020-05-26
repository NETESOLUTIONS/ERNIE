--SQL query for generating publications that published in 1985, type "ar" and has at least 5 references, and then unique co-cited pairs:
---------------------------------------------------------------------
SET SEARCH_PATH = public;

DROP TABLE IF EXISTS wenxi.test1_scopus_data_1985;

SELECT source_id,
  source_year,
  source_citation_type,
  source_have_issn,
  cited_source_uid,
  reference_year,
  reference_have_issn
  INTO wenxi.test1_scopus_data_1985
  FROM (
    SELECT source_sp.scp                         AS source_id,
      source_spg.pub_year                        AS source_year,
      source_sp.citation_type                    AS source_citation_type,
      ref_sp.scp                                 AS cited_source_uid,
      ref_spg.pub_year                           AS reference_year,
      (source_ss.issn_main != '') AS source_have_issn,
      (ref_ss.issn_main != '') AS reference_have_issn,
          count(1) OVER (PARTITION BY source_sp.scp) AS ref_count
      FROM scopus_publications source_sp
      JOIN scopus_publication_groups source_spg
           ON source_spg.sgr = source_sp.sgr AND source_spg.pub_year = 1985
      LEFT JOIN scopus_sources source_ss
                ON source_ss.ernie_source_id = source_sp.ernie_source_id
      JOIN scopus_references sr USING (scp)
      JOIN scopus_publications ref_sp ON ref_sp.sgr = sr.ref_sgr
      JOIN scopus_publication_groups ref_spg ON ref_spg.sgr = ref_sp.sgr AND ref_spg.pub_year <= 1985
      LEFT JOIN scopus_sources ref_ss
                ON ref_ss.ernie_source_id = ref_sp.ernie_source_id
     WHERE source_sp.citation_type = 'ar'
  ) sq
 WHERE ref_count >= 5;
--- about 4 hours to finish

--- Remove paper cite itself
DELETE
  FROM wenxi.test1_scopus_data_1985
 WHERE source_id = cited_source_uid;
DELETE FROM wenxi.test1_scopus_data_1985 WHERE source_id IN (
  SELECT source_id FROM wenxi.test1_scopus_data_1985 GROUP BY source_id HAVING count(cited_source_uid) < 5);
  
--- Find distinct pairs
DROP TABLE IF EXISTS wenxi.test1_scopus_data_1985_no_duplicates;
SELECT c1.source_id , c1.cited_source_uid AS cited_1,
  c2.cited_source_uid AS cited_2
  INTO wenxi.test1_scopus_data_1985_no_duplicates
  FROM wenxi.test1_scopus_data_1985 c1
  JOIN wenxi.test1_scopus_data_1985 c2
       ON c1.source_id = c2.source_id
           AND c1.cited_source_uid < c2.cited_source_uid
 GROUP BY c1.source_id, c1.cited_source_uid, c2.cited_source_uid;
---------------------------------------------------------------------
