-- SQl ad-hoc script
SET SEARCH_PATH = theta_plus;

ALTER TABLE theta_plus.imm1985_1995_all_merged_unshuffled
ADD COLUMN int_edge_density_ratio DOUBLE PRECISION;

UPDATE theta_plus.imm1985_1995_all_merged_unshuffled amu
SET int_edge_density_ratio = amu2.density_ratio
FROM (SELECT cluster_no, (1.0 * int_edges/cluster_size) density_ratio
      FROM theta_plus.imm1985_1995_all_merged_unshuffled)  amu2
WHERE amu2.cluster_no = amu.cluster_no;

-- imm2000_2004
-- add cluster number to full graph degrees table
ALTER TABLE theta_plus.imm1985_1995_full_graph_degrees
ADD COLUMN mcl_cluster_no BIGINT,
ADD COLUMN leiden_cluster_no BIGINT;

UPDATE theta_plus.imm1985_1995_full_graph_degrees
SET mcl_cluster_no = cslu.cluster_no
FROM theta_plus.imm1985_1995_cluster_scp_list_unshuffled cslu
WHERE cslu.scp = theta_plus.imm1985_1995_full_graph_degrees.scp;

UPDATE theta_plus.imm1985_1995_full_graph_degrees
SET leiden_cluster_no = csll.cluster_no
FROM theta_plus.imm1985_1995_cluster_scp_list_leiden_cpm_r0002 csll
WHERE csll.scp = theta_plus.imm1985_1995_full_graph_degrees.scp;

CREATE TABLE theta_plus.imm1985_1995_all_authors_full_graph AS
    SELECT fgd.*, sa.auid
    FROM theta_plus.imm1985_1995_full_graph_degrees fgd
    JOIN public.scopus_authors sa
        ON fgd.scp = sa.scp;

ALTER TABLE theta_plus.imm1985_1995_all_authors_full_graph
ADD COLUMN leiden_cluster_no BIGINT;

UPDATE theta_plus.imm1985_1995_all_authors_full_graph aafg
SET leiden_cluster_no = fgd.leiden_cluster_no
FROM theta_plus.imm1985_1995_full_graph_degrees fgd
WHERE fgd.scp = aafg.scp ;

-- Get cluster number and number of articles per cluster for each author

CREATE TABLE theta_plus.imm1985_1995_authors_clusters AS
    SELECT auid, mcl_cluster_no, count(scp) mcl_count_articles
    FROM
        (SELECT DISTINCT scp, mcl_cluster_no, auid
        FROM theta_plus.imm1985_1995_all_authors_full_graph ac) distinct_authors
    GROUP BY auid, mcl_cluster_no
    ORDER BY auid ASC;

ALTER TABLE imm1985_1995_authors_clusters_mcl
ADD COLUMN mcl_count_cited_articles BIGINT;

UPDATE imm1985_1995_authors_clusters_mcl
   SET mcl_count_cited_articles = cited_articles.count_cited_articles
FROM (SELECT cluster_no, auid, count(cluster_in_degrees) count_cited_articles
      FROM
    (SELECT DISTINCT *
    FROM theta_plus.imm1985_1995_all_authors_internal
    WHERE cluster_in_degrees > 0) aai
    GROUP BY cluster_no, auid) cited_articles
 WHERE imm1985_1995_authors_clusters_mcl.auid = cited_articles.auid
   AND imm1985_1995_authors_clusters_mcl.mcl_cluster_no =cited_articles.cluster_no;



CREATE TABLE theta_plus.imm1985_1995_authors_clusters_leiden AS
    SELECT auid, leiden_cluster_no, count(scp) leiden_count_articles
    FROM
        (SELECT DISTINCT scp, leiden_cluster_no, auid
        FROM theta_plus.imm1985_1995_all_authors_full_graph ac) distinct_authors
    GROUP BY auid, leiden_cluster_no
    ORDER BY auid ASC;

ALTER TABLE imm1985_1995_authors_clusters_leiden
ADD COLUMN leiden_count_cited_articles BIGINT;

UPDATE imm1985_1995_authors_clusters_leiden
   SET leiden_count_cited_articles = cited_articles.count_cited_articles
FROM (SELECT cluster_no, auid, count(cluster_in_degrees) count_cited_articles
      FROM
    (SELECT DISTINCT *
    FROM theta_plus.imm1985_1995_all_authors_internal_leiden
    WHERE cluster_in_degrees > 0) aai
    GROUP BY cluster_no, auid) cited_articles
 WHERE imm1985_1995_authors_clusters_leiden.auid = cited_articles.auid
   AND imm1985_1995_authors_clusters_leiden.leiden_cluster_no =cited_articles.cluster_no;




-- Get proportion of tier 1 articles per cluster

CREATE TABLE  tier_1_proportions AS
(SELECT cluster_no,
  1.0*sum(case WHEN tier = 1 then 1 ELSE 0 END )/ count(cluster_no) as tier_1_prop
FROM
(SELECT cluster_no,scp, max(tier) as tier
  FROM imm1985_1995_article_tiers
group by cluster_no, scp) total
GROUP BY cluster_no
ORDER BY cluster_no);


-- Get author tiers

DROP VIEW IF EXISTS imm1985_1995_author_tiers_view;
CREATE VIEW author_tiers_view
  (auid, cluster_no, tier) AS
    WITH cte AS (SELECT cluster_no, auid, min(tier) as tier
                 FROM imm1985_1995_article_tiers
                 GROUP BY cluster_no, auid)
    SELECT auid, cluster_no, CASE
        WHEN tier = 1 THEN 'tier_1'
        WHEN tier = 2 THEN 'tier_2'
        WHEN tier = 3 THEN 'tier_3' END AS tier
    FROM cte
    ORDER BY tier ASC;

-- Add count of clusters to author tiers
DROP TABLE IF EXISTS imm1985_1995_author_tiers;
CREATE TABLE imm1985_1995_author_tiers AS
  SELECT cc.auid, cc.total_num_clusters, icc.num_clusters_int_edges, aut.tier_1, aut.tier_2, aut.tier_3
  FROM
     (SELECT auid, count(mcl_cluster_no) as total_num_clusters                    -- total number of clusters
      FROM imm1985_1995_authors_clusters_mcl
      GROUP BY auid
      ORDER BY total_num_clusters DESC) cc

  LEFT JOIN (SELECT aai.auid, count(aai.cluster_no) as num_clusters_int_edges -- clusters with internal edges
             FROM (SELECT DISTINCT auid, cluster_no                           -- based on which article tiers were
                   FROM imm1985_1995_all_authors_internal) aai                -- computed
                   GROUP BY aai.auid) icc ON cc.auid = icc.auid

  LEFT JOIN (SELECT auid,
             count(CASE WHEN tier = 'tier_1' THEN 1 END) AS tier_1,
             count(CASE WHEN tier = 'tier_2' THEN 1 END) AS tier_2,
             count(CASE WHEN tier = 'tier_3' THEN 1 END) AS tier_3
             FROM imm1985_1995_author_tiers_view
             GROUP BY auid) aut ON cc.auid = aut.auid;


-- count of authors by tier in each cluster

DROP TABLE IF EXISTS theta_plus.imm1985_1995_cluster_author_tier_counts;
CREATE TABLE theta_plus.imm1985_1995_cluster_author_tier_counts AS
  SELECT cluster_no,
             count(CASE WHEN tier = 'tier_1' THEN 1 END) AS tier_1,
             count(CASE WHEN tier = 'tier_2' THEN 1 END) AS tier_2,
             count(CASE WHEN tier = 'tier_3' THEN 1 END) AS tier_3
 FROM imm1985_1995_author_tiers_view
 GROUP BY cluster_no
 ORDER BY cluster_no
  ;

ALTER TABLE theta_plus.imm1985_1995_cluster_author_tier_counts
ADD COLUMN cluster_size BIGINT,
ADD COLUMN num_authors BIGINT;

UPDATE theta_plus.imm1985_1995_cluster_author_tier_counts atc
SET cluster_size = amu.cluster_size
FROM theta_plus.imm1985_1995_all_merged_unshuffled amu
WHERE amu.cluster_no = atc.cluster_no;

UPDATE theta_plus.imm1985_1995_cluster_author_tier_counts atc
SET num_authors = amu.num_authors
FROM theta_plus.imm1985_1995_all_merged_unshuffled amu
WHERE amu.cluster_no = atc.cluster_no;



DROP TABLE IF EXISTS theta_plus.imm1985_1995_author_tiers_mcl_leiden;
CREATE TABLE theta_plus.imm1985_1995_author_tiers_mcl_leiden AS
  SELECT cc.auid, cc.total_num_clusters, icc.num_clusters_int_edges, aut.tier_1, aut.tier_2, aut.tier_3
  FROM
     (SELECT auid, count(mcl_cluster_no) as total_num_clusters                    -- total number of clusters
      FROM theta_plus.imm1985_1995_authors_clusters_mcl
      WHERE mcl_cluster_no IN (SELECT amu.cluster_no
                            FROM theta_plus.superset_30_350_match_to_leiden_cpm_r0002 mtl
                          JOIN theta_plus.imm1985_1995_all_merged_unshuffled amu
                              ON amu.cluster_no=mtl.mcl_cluster_number
                          WHERE mtl.intersect_union_ratio >= 0.9)
      GROUP BY auid
      ORDER BY total_num_clusters DESC) cc

  LEFT JOIN (SELECT aai.auid, count(aai.cluster_no) as num_clusters_int_edges -- clusters with internal edges
             FROM (SELECT DISTINCT auid, cluster_no                           -- based on which article tiers were
                   FROM theta_plus.imm1985_1995_all_authors_internal
                   WHERE cluster_no IN (SELECT amu.cluster_no
                                      FROM theta_plus.superset_30_350_match_to_leiden_cpm_r0002 mtl
                                    JOIN theta_plus.imm1985_1995_all_merged_unshuffled amu
                                        ON amu.cluster_no=mtl.mcl_cluster_number
                                    WHERE mtl.intersect_union_ratio >= 0.9)) aai                -- computed
                   GROUP BY aai.auid) icc ON cc.auid = icc.auid

  LEFT JOIN (SELECT auid,
             count(CASE WHEN tier = 'tier_1' THEN 1 END) AS tier_1,
             count(CASE WHEN tier = 'tier_2' THEN 1 END) AS tier_2,
             count(CASE WHEN tier = 'tier_3' THEN 1 END) AS tier_3
            FROM
            (SELECT *
             FROM theta_plus.imm1985_1995_author_tiers_view
             WHERE cluster_no IN (SELECT amu.cluster_no
                                  FROM theta_plus.superset_30_350_match_to_leiden_cpm_r0002 mtl
                                JOIN theta_plus.imm1985_1995_all_merged_unshuffled amu
                                    ON amu.cluster_no=mtl.mcl_cluster_number
                                WHERE mtl.intersect_union_ratio >= 0.9)) clusters_30_350
             GROUP BY auid) aut ON cc.auid = aut.auid;





DROP TABLE IF EXISTS theta_plus.imm1985_1995_author_tiers_30_350;
CREATE TABLE theta_plus.imm1985_1995_author_tiers_30_350 AS
  SELECT cc.auid, cc.total_num_clusters, icc.num_clusters_int_edges, aut.tier_1, aut.tier_2, aut.tier_3
  FROM
     (SELECT auid, count(mcl_cluster_no) as total_num_clusters                    -- total number of clusters
      FROM theta_plus.imm1985_1995_authors_clusters_mcl
      WHERE mcl_cluster_size BETWEEN 30 and 350
      GROUP BY auid
      ORDER BY total_num_clusters DESC) cc

  LEFT JOIN (SELECT aai.auid, count(aai.cluster_no) as num_clusters_int_edges -- clusters with internal edges
             FROM (SELECT DISTINCT auid, cluster_no                           -- based on which article tiers were
                   FROM theta_plus.imm1985_1995_all_authors_internal
                   WHERE cluster_no IN (SELECT cluster_no
                                  FROM theta_plus.imm1985_1995_all_merged_unshuffled
                                  WHERE cluster_size BETWEEN 30 AND 350)) aai                -- computed
                   GROUP BY aai.auid) icc ON cc.auid = icc.auid

  LEFT JOIN (SELECT auid,
             count(CASE WHEN tier = 'tier_1' THEN 1 END) AS tier_1,
             count(CASE WHEN tier = 'tier_2' THEN 1 END) AS tier_2,
             count(CASE WHEN tier = 'tier_3' THEN 1 END) AS tier_3
            FROM
            (SELECT *
             FROM theta_plus.imm1985_1995_author_tiers_view
             WHERE cluster_no IN (SELECT cluster_no
                                  FROM theta_plus.imm1985_1995_all_merged_unshuffled
                                  WHERE cluster_size BETWEEN 30 AND 350)) clusters_30_350
             GROUP BY auid) aut ON cc.auid = aut.auid;

-- External degrees by authors table with cluster sizes -

CREATE TABLE imm1985_1995_all_authors_external AS
SELECT ecd.*, aafg.auid, amu.cluster_size
FROM imm1985_1995_external_cluster_degrees ecd
JOIN imm1985_1995_all_authors_full_graph aafg ON ecd.scp = aafg.scp
    AND ecd.cluster_no = aafg.mcl_cluster_no
JOIN imm1985_1995_all_merged_unshuffled amu ON ecd.cluster_no = amu.cluster_no
ORDER BY cluster_no ASC, ext_cluster_total_degrees DESC , scp ASC;

-- Add cluster size to imm1985_1995_author_clusters

ALTER TABLE imm1985_1995_authors_clusters_mcl
ADD COLUMN cluster_size BIGINT;
UPDATE imm1985_1995_authors_clusters_mcl
SET mcl_cluster_size = amu.cluster_size
FROM imm1985_1995_all_merged_unshuffled amu
WHERE amu.cluster_no = imm1985_1995_authors_clusters_mcl.mcl_cluster_no;

-- Add cluster size and cluster size tiers to imm1985_1995_article_tiers

ALTER TABLE imm1985_1995_article_tiers
ADD COLUMN cluster_size BIGINT,
ADD COLUMN cluster_size_groups text;

UPDATE imm1985_1995_article_tiers
SET cluster_size = amu.cluster_size
FROM imm1985_1995_all_merged_unshuffled amu
WHERE amu.cluster_no = imm1985_1995_article_tiers.cluster_no;

UPDATE imm1985_1995_article_tiers
SET cluster_size_groups = cluster_tiers.cluster_size_groups
FROM (SELECT cluster_no, scp, cluster_total_degrees, cluster_in_degrees, cluster_out_degrees, auid, tier, cluster_size,
  CASE
    WHEN cluster_size < 30 THEN 3
    WHEN cluster_size >= 30 AND cluster_size < 300 THEN 2
    WHEN cluster_size >= 300 THEN 1 END AS cluster_size_groups
FROM imm1985_1995_article_tiers
GROUP BY cluster_no, scp, cluster_total_degrees,
         cluster_in_degrees, cluster_out_degrees, auid, tier, cluster_size) cluster_tiers
WHERE cluster_tiers.scp = imm1985_1995_article_tiers.scp AND
      cluster_tiers.auid = imm1985_1995_article_tiers.auid AND
      cluster_tiers.cluster_no = cluster_tiers.cluster_no;



-- author tiers venn diagram

ALTER TABLE imm1985_1995_author_tiers
ADD COLUMN venn_tiers text;

UPDATE imm1985_1995_author_tiers
SET venn_tiers = venn.venn_tiers_column
FROM
(WITH cte AS  (SELECT *, CASE
                      WHEN tier_1 > 0 AND tier_2 > 0 AND tier_3 > 0 THEN 'all_3_tiers'
                      WHEN tier_1 > 0 AND tier_2 > 0 AND tier_3 = 0 THEN 'tiers_1_2'
                      WHEN tier_1 > 0 AND tier_2 = 0 AND tier_3 > 0 THEN 'tiers_1_3'
                      WHEN tier_1 = 0 AND tier_2 > 0 AND tier_3 > 0 THEN 'tiers_2_3'
                      WHEN tier_1 > 0 AND tier_2 = 0 AND tier_3 = 0 THEN 'tier_1_only'
                      WHEN tier_1 = 0 AND tier_2 > 0 AND tier_3 = 0 THEN 'tier_2_only'
                      WHEN tier_1 = 0 AND tier_2 = 0 AND tier_3 > 0 THEN 'tier_3_only'
                      WHEN tier_1 IS NULL AND tier_2 IS NULL AND tier_3 IS NULL THEN NULL
                      END AS venn_tiers_column
          FROM theta_plus.imm1985_1995_author_tiers)

SELECT at.*, cte.venn_tiers_column
FROM theta_plus.imm1985_1995_article_tiers at
LEFT JOIN cte on cte.auid = at.auid) venn
WHERE venn.auid = imm1985_1995_author_tiers.auid;


-- imm2000_2004
-- add cluster number to full graph degrees table
ALTER TABLE theta_plus.imm2000_2004_full_graph_degrees
ADD COLUMN mcl_cluster_no BIGINT;

UPDATE theta_plus.imm2000_2004_full_graph_degrees
SET mcl_cluster_no = cslu.cluster_no
FROM theta_plus.imm2000_2004_cluster_scp_list_unshuffled cslu
WHERE cslu.scp = theta_plus.imm2000_2004_full_graph_degrees.scp;

-- add AUID to graph degrees tables

CREATE TABLE theta_plus.imm2000_2004_all_authors_full_graph AS
    SELECT fgd.*, sa.auid
    FROM theta_plus.imm2000_2004_full_graph_degrees fgd
    JOIN public.scopus_authors sa
        ON fgd.scp = sa.scp;


CREATE TABLE theta_plus.imm2000_2004_all_authors_internal AS
    SELECT icd.*, sa.auid
    FROM theta_plus.imm2000_2004_internal_cluster_degrees icd
    JOIN public.scopus_authors sa
        ON icd.scp = sa.scp;

-- Get cluster number and number of articles per cluster for each author
CREATE TABLE theta_plus.imm2000_2004_authors_clusters AS
    SELECT auid, mcl_cluster_no, count(scp) count_articles
    FROM
        (SELECT DISTINCT scp, mcl_cluster_no, auid
        FROM theta_plus.imm2000_2004_all_authors_full_graph ac) distinct_authors
    GROUP BY auid, mcl_cluster_no
    ORDER BY auid ASC;

ALTER TABLE imm2000_2004_authors_clusters
ADD COLUMN count_cited_articles BIGINT;

-- Add cluster size to imm2000_2004_author_clusters

ALTER TABLE imm2000_2004_authors_clusters
ADD COLUMN cluster_size BIGINT;
UPDATE imm2000_2004_authors_clusters
SET cluster_size = amu.cluster_size
FROM imm2000_2004_all_merged_unshuffled amu
WHERE amu.cluster_no = imm2000_2004_authors_clusters.mcl_cluster_no;

UPDATE theta_plus.imm2000_2004_authors_clusters
   SET count_cited_articles = cited_articles.count_cited_articles
FROM (SELECT cluster_no, auid, count(int_cluster_in_degrees) count_cited_articles
      FROM
    (SELECT DISTINCT *
    FROM theta_plus.imm2000_2004_all_authors_internal
    WHERE int_cluster_in_degrees > 0) aai
    GROUP BY cluster_no, auid) cited_articles
 WHERE theta_plus.imm2000_2004_authors_clusters.auid = cited_articles.auid
   AND theta_plus.imm2000_2004_authors_clusters.mcl_cluster_no=cited_articles.cluster_no;



-- eco2000_2010
-- add cluster number to full graph degrees table
ALTER TABLE theta_plus_ecology.eco2000_2010_full_graph_degrees
ADD COLUMN mcl_cluster_no BIGINT;

UPDATE theta_plus_ecology.eco2000_2010_full_graph_degrees
SET mcl_cluster_no = cslu.cluster_no
FROM theta_plus_ecology.eco2000_2010_cluster_scp_list_unshuffled cslu
WHERE cslu.scp = theta_plus_ecology.eco2000_2010_full_graph_degrees.scp;

-- add AUID to full graph degrees table

CREATE TABLE theta_plus_ecology.eco2000_2010_all_authors_full_graph AS
    SELECT fgd.*, sa.auid
    FROM theta_plus_ecology.eco2000_2010_full_graph_degrees fgd
    JOIN public.scopus_authors sa
        ON fgd.scp = sa.scp;

-- Get cluster number and number of articles per cluster for each author
CREATE TABLE theta_plus_ecology.eco2000_2010_authors_clusters AS
    SELECT auid, mcl_cluster_no, count(scp) count_articles
    FROM
        (SELECT DISTINCT scp, mcl_cluster_no, auid
        FROM theta_plus_ecology.eco2000_2010_all_authors_full_graph ac) distinct_authors
    GROUP BY auid, mcl_cluster_no
    ORDER BY auid ASC;




--------------------------------------------------------


CREATE VIEW theta_plus.imm2000_2004_author_tiers_view
  (auid, cluster_no, tier) AS
    WITH cte AS (SELECT cluster_no, auid, min(tier) as tier
                 FROM theta_plus.imm2000_2004_article_tiers
                 GROUP BY cluster_no, auid)
    SELECT auid, cluster_no, CASE
        WHEN tier = 1 THEN 'tier_1'
        WHEN tier = 2 THEN 'tier_2'
        WHEN tier = 3 THEN 'tier_3' END AS tier
    FROM cte
    ORDER BY tier ASC;

-- Add count of clusters to author tiers
DROP TABLE IF EXISTS theta_plus.imm2000_2004_author_tiers;
CREATE TABLE theta_plus.imm2000_2004_author_tiers AS
  SELECT cc.auid, cc.total_num_clusters, icc.num_clusters_int_edges, aut.tier_1, aut.tier_2, aut.tier_3
  FROM
     (SELECT auid, count(mcl_cluster_no) as total_num_clusters                    -- total number of clusters
      FROM theta_plus.imm2000_2004_authors_clusters
      GROUP BY auid
      ORDER BY total_num_clusters DESC) cc

  LEFT JOIN (SELECT aai.auid, count(aai.cluster_no) as num_clusters_int_edges -- clusters with internal edges
             FROM (SELECT DISTINCT auid, cluster_no                           -- based on which article tiers were
                   FROM theta_plus.imm2000_2004_all_authors_internal) aai                -- computed
                   GROUP BY aai.auid) icc ON cc.auid = icc.auid

  LEFT JOIN (SELECT auid,
             count(CASE WHEN tier = 'tier_1' THEN 1 END) AS tier_1,
             count(CASE WHEN tier = 'tier_2' THEN 1 END) AS tier_2,
             count(CASE WHEN tier = 'tier_3' THEN 1 END) AS tier_3
             FROM theta_plus.imm2000_2004_author_tiers_view
             GROUP BY auid) aut ON cc.auid = aut.auid;

-- for cluster size between 30 and 350

DROP TABLE IF EXISTS theta_plus.imm2000_2004_author_tiers_30_350;
CREATE TABLE theta_plus.imm2000_2004_author_tiers_30_350 AS
  SELECT cc.auid, cc.total_num_clusters, icc.num_clusters_int_edges, aut.tier_1, aut.tier_2, aut.tier_3
  FROM
     (SELECT auid, count(mcl_cluster_no) as total_num_clusters                    -- total number of clusters
      FROM theta_plus.imm2000_2004_authors_clusters
      WHERE cluster_size BETWEEN 30 and 350
      GROUP BY auid
      ORDER BY total_num_clusters DESC) cc

  LEFT JOIN (SELECT aai.auid, count(aai.cluster_no) as num_clusters_int_edges -- clusters with internal edges
             FROM (SELECT DISTINCT auid, cluster_no                           -- based on which article tiers were
                   FROM theta_plus.imm2000_2004_all_authors_internal
                   WHERE cluster_no IN (SELECT cluster_no
                                  FROM theta_plus.imm2000_2004_all_merged_unshuffled
                                  WHERE cluster_size BETWEEN 30 AND 350)) aai                -- computed
                   GROUP BY aai.auid) icc ON cc.auid = icc.auid

  LEFT JOIN (SELECT auid,
             count(CASE WHEN tier = 'tier_1' THEN 1 END) AS tier_1,
             count(CASE WHEN tier = 'tier_2' THEN 1 END) AS tier_2,
             count(CASE WHEN tier = 'tier_3' THEN 1 END) AS tier_3
            FROM
            (SELECT *
             FROM theta_plus.imm2000_2004_author_tiers_view
             WHERE cluster_no IN (SELECT cluster_no
                                  FROM theta_plus.imm2000_2004_all_merged_unshuffled
                                  WHERE cluster_size BETWEEN 30 AND 350)) clusters_30_350
             GROUP BY auid) aut ON cc.auid = aut.auid;


DROP TABLE IF EXISTS theta_plus.imm2000_2004_author_tiers_mcl_leiden;
CREATE TABLE theta_plus.imm2000_2004_author_tiers_mcl_leiden AS
  SELECT cc.auid, cc.total_num_clusters, icc.num_clusters_int_edges, aut.tier_1, aut.tier_2, aut.tier_3
  FROM
     (SELECT auid, count(mcl_cluster_no) as total_num_clusters                    -- total number of clusters
      FROM theta_plus.imm2000_2004_authors_clusters
      WHERE mcl_cluster_no IN (SELECT amu.cluster_no
                            FROM theta_plus."imm2000_2004_match_to_leiden_CPM_R0002" mtl
                          JOIN theta_plus.imm2000_2004_all_merged_unshuffled amu
                              ON amu.cluster_no=mtl.mcl_cluster_number
                          WHERE mtl.intersect_union_ratio >= 0.9)
      GROUP BY auid
      ORDER BY total_num_clusters DESC) cc

  LEFT JOIN (SELECT aai.auid, count(aai.cluster_no) as num_clusters_int_edges -- clusters with internal edges
             FROM (SELECT DISTINCT auid, cluster_no                           -- based on which article tiers were
                   FROM theta_plus.imm2000_2004_all_authors_internal
                   WHERE cluster_no IN (SELECT amu.cluster_no
                            FROM theta_plus."imm2000_2004_match_to_leiden_CPM_R0002" mtl
                          JOIN theta_plus.imm2000_2004_all_merged_unshuffled amu
                              ON amu.cluster_no=mtl.mcl_cluster_number
                          WHERE mtl.intersect_union_ratio >= 0.9)) aai                -- computed
                   GROUP BY aai.auid) icc ON cc.auid = icc.auid

  LEFT JOIN (SELECT auid,
             count(CASE WHEN tier = 'tier_1' THEN 1 END) AS tier_1,
             count(CASE WHEN tier = 'tier_2' THEN 1 END) AS tier_2,
             count(CASE WHEN tier = 'tier_3' THEN 1 END) AS tier_3
            FROM
            (SELECT *
             FROM theta_plus.imm2000_2004_author_tiers_view
             WHERE cluster_no IN (SELECT amu.cluster_no
                            FROM theta_plus."imm2000_2004_match_to_leiden_CPM_R0002" mtl
                          JOIN theta_plus.imm2000_2004_all_merged_unshuffled amu
                              ON amu.cluster_no=mtl.mcl_cluster_number
                          WHERE mtl.intersect_union_ratio >= 0.9)) clusters_30_350
             GROUP BY auid) aut ON cc.auid = aut.auid;


-- count of authors by tier in each cluster

DROP TABLE IF EXISTS theta_plus.imm2000_2004_cluster_author_tier_counts;
CREATE TABLE theta_plus.imm2000_2004_cluster_author_tier_counts AS
  SELECT cluster_no,
             count(CASE WHEN tier = 'tier_1' THEN 1 END) AS tier_1,
             count(CASE WHEN tier = 'tier_2' THEN 1 END) AS tier_2,
             count(CASE WHEN tier = 'tier_3' THEN 1 END) AS tier_3
 FROM imm2000_2004_author_tiers_view
 GROUP BY cluster_no
 ORDER BY cluster_no
  ;

ALTER TABLE theta_plus.imm2000_2004_cluster_author_tier_counts
ADD COLUMN cluster_size BIGINT,
ADD COLUMN num_authors BIGINT;

UPDATE theta_plus.imm2000_2004_cluster_author_tier_counts atc
SET cluster_size = amu.cluster_size
FROM theta_plus.imm2000_2004_all_merged_unshuffled amu
WHERE amu.cluster_no = atc.cluster_no;
--
-- UPDATE theta_plus.imm2000_2004_cluster_author_tier_counts atc
-- SET num_authors = amu.num_authors
-- FROM theta_plus.imm2000_2004_all_merged_unshuffled amu
-- WHERE amu.cluster_no = atc.cluster_no;
--
--

