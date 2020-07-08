-- Add author count info

ALTER TABLE imm1985_1995_all_merged_unshuffled
ADD COLUMN p_1_author_count BIGINT,
ADD COLUMN p_50_author_count BIGINT,
ADD COLUMN p_75_author_count BIGINT,
ADD COLUMN p_90_author_count BIGINT,
ADD COLUMN p_95_author_count BIGINT,
ADD COLUMN p_99_author_count BIGINT,
ADD COLUMN p_100_author_count BIGINT;

UPDATE imm1985_1995_all_merged_unshuffled
SET p_1_author_count = percentile_val.p_1_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(0.1) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_1_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1985_1995_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1985_1995_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;

UPDATE imm1985_1995_all_merged_unshuffled
SET p_50_author_count = percentile_val.p_50_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(0.5) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_50_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1985_1995_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1985_1995_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;

UPDATE imm1985_1995_all_merged_unshuffled
SET p_75_author_count = percentile_val.p_75_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(0.75) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_75_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1985_1995_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1985_1995_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;

UPDATE imm1985_1995_all_merged_unshuffled
SET p_90_author_count = percentile_val.p_90_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(0.9) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_90_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1985_1995_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1985_1995_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;

UPDATE imm1985_1995_all_merged_unshuffled
SET p_95_author_count = percentile_val.p_95_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(0.95) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_95_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1985_1995_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1985_1995_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;


UPDATE imm1985_1995_all_merged_unshuffled
SET p_99_author_count = percentile_val.p_99_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(0.99) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_99_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1985_1995_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1985_1995_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;


UPDATE imm1985_1995_all_merged_unshuffled
SET p_100_author_count = percentile_val.p_100_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(1) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_100_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1985_1995_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1985_1995_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;



SELECT authors.cluster_no,
  percentile_disc(0.1) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_1_author_count,
  percentile_disc(0.5) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_50_author_count,
  percentile_disc(0.75) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_75_author_count,
  percentile_disc(0.90) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_90_author_count,
  percentile_disc(0.95) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_95_author_count,
  percentile_disc(0.99) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_99_author_count,
  percentile_disc(1) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_100_author_count
FROM
(SELECT rated.cluster_no, sa.auid, count(sa.auid) num_articles
FROM
(SELECT *
FROM imm1985_1995_cluster_scp_list_unshuffled cslu
JOIN expert_ratings er
    ON cslu.cluster_no = er.imm1985_1995_cluster_no) rated
LEFT JOIN public.scopus_authors sa
    ON rated.scp = sa.scp
GROUP BY rated.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no
;
