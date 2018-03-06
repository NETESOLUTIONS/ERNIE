-- Author: VJ Davey
-- This script is used to generate first generation reference information for a drug

SET default_tablespace=ernie_default_tbs;

DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_fb_union;
CREATE TABLE case_DRUG_NAME_HERE_citation_network_fb_union AS
    SELECT distinct * FROM (SELECT citing_pmid,citing_wos,cited_wos,cited_pmid FROM case_DRUG_NAME_HERE_citation_network_forward
                              UNION
                             SELECT citing_pmid,citing_wos,cited_wos,cited_pmid FROM case_DRUG_NAME_HERE_citation_network) a;

DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_years_fb_union;
CREATE TABLE case_DRUG_NAME_HERE_citation_network_years_fb_union AS
  SELECT DISTINCT c.pmid_int, a.wos_id, b.publication_year FROM
    ( SELECT DISTINCT citing_wos AS wos_id FROM case_DRUG_NAME_HERE_citation_network_fb_union
      UNION ALL
      SELECT DISTINCT cited_wos AS wos_id FROM case_DRUG_NAME_HERE_citation_network_fb_union
    ) a
  LEFT JOIN wos_publications b
  ON a.wos_id=b.source_id
  LEFT JOIN wos_pmid_mapping c
  ON a.wos_id=c.wos_id
  WHERE a.wos_id IS NOT NULL;

DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_authors_fb_union;
CREATE TABLE case_DRUG_NAME_HERE_citation_network_authors_fb_union AS
SELECT DISTINCT a.pmid_int, a.wos_id, b.full_name FROM
case_DRUG_NAME_HERE_citation_network_years_fb_union a INNER JOIN wos_authors b
ON a.wos_id=b.source_id;

DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_grants_WOS_fb_union;
CREATE TABLE case_DRUG_NAME_HERE_citation_network_grants_WOS_fb_union AS
SELECT DISTINCT a.pmid_int, a.wos_id, b.grant_number, b.grant_organization FROM
case_DRUG_NAME_HERE_citation_network_years_fb_union a INNER JOIN wos_grants b
ON a.wos_id=b.source_id;

DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_locations_fb_union;
CREATE TABLE case_DRUG_NAME_HERE_citation_network_locations_fb_union AS
SELECT DISTINCT a.pmid_int, a.wos_id, b.organization, b.city, b.country FROM
case_DRUG_NAME_HERE_citation_network_years_fb_union a INNER JOIN wos_addresses b
ON a.wos_id=b.source_id;

DROP TABLE IF EXISTS case_DRUG_NAME_HERE_citation_network_grants_SPIRES_fb_union;
CREATE TABLE case_DRUG_NAME_HERE_citation_network_grants_SPIRES_fb_union as
SELECT DISTINCT a.pmid_int, a.wos_id, b.project_number FROM
case_DRUG_NAME_HERE_citation_network_years_fb_union a INNER JOIN exporter_publink b
ON a.pmid_int=CAST(b.pmid AS int);

--output tables to CSV format under disk space
COPY case_DRUG_NAME_HERE_citation_network_fb_union TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_forward.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_years_fb_union TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_years_forward.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_grants_SPIRES_fb_union TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_grants_SPIRES_forward.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_grants_WOS_fb_union TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_grants_WOS_forward.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_locations_fb_union TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_locations_forward.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;
COPY case_DRUG_NAME_HERE_citation_network_authors_fb_union TO '/erniedev_data2/DRUG_NAME_HERE_citation_network_authors_forward.txt' WITH NULL as 'NA' DELIMITER E'\t' CSV HEADER;

--collect some statistics and output to screen
\! printf '\n\n\n*** IMPORTANT ***\n\n The following counts are taken from the citation network table.\nSeedset PMIDs without a corresponding WoS ID are not counted in the network as they have droppped out of the network\n\n\n'
\! echo '***Total distinct citing documents:'
SELECT count(distinct citing_wos) FROM case_DRUG_NAME_HERE_citation_network_fb_union;
\! echo '***Total distinct citing PMIDs:'
SELECT count(distinct citing_pmid) FROM case_DRUG_NAME_HERE_citation_network_fb_union  WHERE citing_pmid IS NOT NULL;
\! echo '***Total distinct documents in network (Remember - WoS backbone)' -- can use the years table here as it is a union into what is basically a node list table, left joined on years. As a result, the node listing is preserved even for those entries without years.
SELECT count(distinct wos_id) FROM case_DRUG_NAME_HERE_citation_network_years_fb_union;
