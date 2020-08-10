-- SQl ad-hoc script

-- Get cluster number and number of articles per cluster for each author

CREATE TABLE theta_plus.imm1985_1995_authors_clusters AS
    SELECT auid, cluster_no, count(scp) count_articles
    FROM
        (SELECT DISTINCT scp, cluster_no, auid
        FROM theta_plus.imm1985_1995_all_authors ac) distinct_authors
    GROUP BY auid, cluster_no
    ORDER BY auid ASC;