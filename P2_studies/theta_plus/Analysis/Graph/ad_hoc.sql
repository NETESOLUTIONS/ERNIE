-- SQl ad-hoc script

-- Get cluster number and number of articles per cluster for each author

CREATE TABLE theta_plus.imm1985_1995_authors_clusters AS
    SELECT auid, cluster_no, count(scp) count_articles
    FROM
        (SELECT DISTINCT scp, cluster_no, auid
        FROM theta_plus.imm1985_1995_all_authors_full_graph ac) distinct_authors
    GROUP BY auid, cluster_no
    ORDER BY auid ASC;

ALTER TABLE imm1985_1995_authors_clusters
ADD COLUMN count_cited_articles BIGINT;

UPDATE imm1985_1995_authors_clusters
   SET count_cited_articles = cited_articles.count_cited_articles
FROM (SELECT cluster_no, auid, count(cluster_in_degrees) count_cited_articles
      FROM
    (SELECT DISTINCT *
    FROM theta_plus.imm1985_1995_all_authors_internal
    WHERE cluster_in_degrees > 0) aai
    GROUP BY cluster_no, auid) cited_articles
 WHERE imm1985_1995_authors_clusters.auid = cited_articles.auid
   AND imm1985_1995_authors_clusters.cluster_no=cited_articles.cluster_no;


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

DROP VIEW IF EXISTS author_tiers_view;
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
     (SELECT auid, count(cluster_no) as total_num_clusters                    -- total number of clusters
      FROM imm1985_1995_authors_clusters
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
             FROM author_tiers_view
             GROUP BY auid) aut ON cc.auid = aut.auid;

-- External degrees by authors table with cluster sizes -

CREATE TABLE imm1985_1995_all_authors_external AS
SELECT ecd.*, aafg.auid, amu.cluster_size
FROM imm1985_1995_external_cluster_degrees ecd
JOIN imm1985_1995_all_authors_full_graph aafg ON ecd.scp = aafg.scp
    AND ecd.cluster_no = aafg.cluster_no
JOIN imm1985_1995_all_merged_unshuffled amu ON ecd.cluster_no = amu.cluster_no
ORDER BY cluster_no ASC, ext_cluster_total_degrees DESC , scp ASC;