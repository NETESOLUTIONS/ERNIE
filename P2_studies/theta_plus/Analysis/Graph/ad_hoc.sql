-- SQl ad-hoc script

-- Get cluster number and number of articles per cluster for each author

CREATE TABLE theta_plus.imm1985_1995_authors_clusters AS
    SELECT auid, cluster_no, count(scp) count_articles
    FROM
        (SELECT DISTINCT scp, cluster_no, auid
        FROM theta_plus.imm1985_1995_all_authors ac) distinct_authors
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