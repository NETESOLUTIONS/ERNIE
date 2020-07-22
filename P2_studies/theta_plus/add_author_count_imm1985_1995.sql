-- Add author count info

ALTER TABLE imm1985_1995_all_merged_unshuffled
ADD COLUMN p_1_author_count BIGINT,
ADD COLUMN p_50_author_count BIGINT,
ADD COLUMN p_75_author_count BIGINT,
ADD COLUMN p_90_author_count BIGINT,
ADD COLUMN p_95_author_count BIGINT,
ADD COLUMN p_99_author_count BIGINT,
ADD COLUMN p_100_author_count BIGINT,
ADD COLUMN num_authors BIGINT,
ADD COLUMN num_authors_95 BIGINT,
ADD COLUMN num_articles_95 BIGINT,
ADD COLUMN coauthor_counts_95 BIGINT,
ADD COLUMN distinct_coauthor_counts_95 BIGINT,
ADD COLUMN coauthor_prop_95 DOUBLE PRECISION,
ADD COLUMN coauthorship_ratio_95 DOUBLE PRECISION,
ADD COLUMN coauthor_counts BIGINT,
ADD COLUMN distinct_coauthor_counts BIGINT,
ADD COLUMN coauthor_prop DOUBLE PRECISION,
ADD COLUMN coauthorship_ratio DOUBLE PRECISION;






UPDATE imm1985_1995_all_merged_unshuffled
SET num_authors = authors.num_authors
FROM
(SELECT cslu.cluster_no, count(DISTINCT sa.auid) num_authors
FROM imm1985_1995_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no) authors
WHERE imm1985_1995_all_merged_unshuffled.cluster_no = authors.cluster_no
;


UPDATE imm1985_1995_all_merged_unshuffled
   SET  num_authors_95 = all_authors.num_author_95
 FROM
    (SELECT authors_95.cluster_no, count(authors_95.auid) as num_author_95
    FROM
            (SELECT authors.cluster_no, authors.auid, authors.num_articles
            FROM
                    (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                    FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                    LEFT JOIN public.scopus_authors sa
                        ON cslu.scp = sa.scp
                    GROUP BY cslu.cluster_no, sa.auid) authors

            LEFT JOIN imm1985_1995_all_merged_unshuffled amu
                ON authors.cluster_no = amu.cluster_no
            WHERE authors.num_articles >= amu.p_95_author_count) authors_95
    GROUP BY authors_95.cluster_no) all_authors
WHERE imm1985_1995_all_merged_unshuffled.cluster_no = all_authors.cluster_no;

-- For each cluster, get counts of all articles by authors >= 95th percentile


UPDATE imm1985_1995_all_merged_unshuffled
    SET num_articles_95 = articles_95.num_articles_95
FROM
        (SELECT scps.cluster_no, count(DISTINCT scps.scp) as num_articles_95
        FROM
                    (SELECT cslu.cluster_no, cslu.scp, sa.auid
                    FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                    LEFT JOIN public.scopus_authors sa
                        ON cslu.scp = sa.scp) scps
        JOIN
                    (SELECT authors.cluster_no, authors.auid
                    FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                          FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                          LEFT JOIN public.scopus_authors sa
                              ON cslu.scp = sa.scp
                          GROUP BY cslu.cluster_no, sa.auid) authors

                     JOIN imm1985_1995_all_merged_unshuffled amu
                        ON authors.cluster_no = amu.cluster_no
                    WHERE authors.num_articles >= amu.p_95_author_count ) authors_95

            ON scps.auid = authors_95.auid and scps.cluster_no = authors_95.cluster_no
        GROUP BY scps.cluster_no) articles_95
WHERE imm1985_1995_all_merged_unshuffled.cluster_no = articles_95.cluster_no;

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




UPDATE imm1985_1995_all_merged_unshuffled
SET coauthor_counts_95 = coauthor.coauthor_counts
FROM
              (SELECT set1.cluster_no, COUNT(set2.scp) as coauthor_counts
              FROM
                        (SELECT scps.cluster_no, scps.scp, authors_95.auid
                         FROM
                                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                                  FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                                  LEFT JOIN public.scopus_authors sa
                                      ON cslu.scp = sa.scp) scps
                         JOIN
                                  (SELECT authors.cluster_no, authors.auid
                                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                                        FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                                        LEFT JOIN public.scopus_authors sa
                                            ON cslu.scp = sa.scp
                                        GROUP BY cslu.cluster_no, sa.auid) authors

                                   JOIN imm1985_1995_all_merged_unshuffled amu
                                      ON authors.cluster_no = amu.cluster_no
                                  WHERE authors.num_articles >= amu.p_95_author_count ) authors_95

                          ON scps.auid = authors_95.auid and
                             scps.cluster_no = authors_95.cluster_no ) set1
              JOIN
                        (SELECT scps.cluster_no, scps.scp, authors_95.auid
                         FROM
                                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                                  FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                                  LEFT JOIN public.scopus_authors sa
                                      ON cslu.scp = sa.scp) scps
                         JOIN
                                  (SELECT authors.cluster_no, authors.auid
                                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                                        FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                                        LEFT JOIN public.scopus_authors sa
                                            ON cslu.scp = sa.scp
                                        GROUP BY cslu.cluster_no, sa.auid) authors

                                   JOIN imm1985_1995_all_merged_unshuffled amu
                                      ON authors.cluster_no = amu.cluster_no
                                  WHERE authors.num_articles >= amu.p_95_author_count ) authors_95

                          ON scps.auid = authors_95.auid and
                             scps.cluster_no = authors_95.cluster_no ) set2

                      ON set1.scp=set2.scp AND set1.auid<set2.auid

              GROUP BY set1.cluster_no) coauthor
WHERE imm1985_1995_all_merged_unshuffled.cluster_no = coauthor.cluster_no;



UPDATE imm1985_1995_all_merged_unshuffled
SET distinct_coauthor_counts_95 = dist_coauthors.distinct_coauthor_counts
FROM
      (SELECT coauthors_distinct.cluster_no, count(*) as distinct_coauthor_counts
      FROM
        (
          SELECT DISTINCT coauthors.cluster_no, coauthors.auid_1, coauthors.auid_2
          FROM
              (SELECT set1.cluster_no, set1.scp, set1.auid auid_1, set2.auid auid_2
              FROM
                        (SELECT scps.cluster_no, scps.scp, authors_95.auid
                         FROM
                                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                                  FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                                  LEFT JOIN public.scopus_authors sa
                                      ON cslu.scp = sa.scp) scps
                         JOIN
                                  (SELECT authors.cluster_no, authors.auid
                                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                                        FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                                        LEFT JOIN public.scopus_authors sa
                                            ON cslu.scp = sa.scp
                                  GROUP BY cslu.cluster_no, sa.auid) authors

                                   JOIN imm1985_1995_all_merged_unshuffled amu
                                      ON authors.cluster_no = amu.cluster_no
                                  WHERE authors.num_articles >= amu.p_95_author_count ) authors_95

                          ON scps.auid = authors_95.auid and
                             scps.cluster_no = authors_95.cluster_no ) set1
              JOIN
                        (SELECT scps.cluster_no, scps.scp, authors_95.auid
                         FROM
                                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                                  FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                                  LEFT JOIN public.scopus_authors sa
                                      ON cslu.scp = sa.scp) scps
                         JOIN
                                  (SELECT authors.cluster_no, authors.auid
                                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                                        FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                                        LEFT JOIN public.scopus_authors sa
                                            ON cslu.scp = sa.scp
                                   GROUP BY cslu.cluster_no, sa.auid) authors

                                   JOIN imm1985_1995_all_merged_unshuffled amu
                                      ON authors.cluster_no = amu.cluster_no
                                  WHERE authors.num_articles >= amu.p_95_author_count ) authors_95

                          ON scps.auid = authors_95.auid and
                             scps.cluster_no = authors_95.cluster_no ) set2

                      ON set1.scp=set2.scp AND set1.auid < set2.auid ) coauthors
                      ) coauthors_distinct
              GROUP BY coauthors_distinct.cluster_no) dist_coauthors
WHERE imm1985_1995_all_merged_unshuffled.cluster_no = dist_coauthors.cluster_no;



UPDATE imm1985_1995_all_merged_unshuffled
SET coauthor_prop_95 = prop.prop
FROM
      (SELECT *,
          coalesce(round(1.0*distinct_coauthor_counts_95 / ((num_authors_95*(num_authors_95-1))/2), 3), 0) as prop
      FROM imm1985_1995_all_merged_unshuffled ) prop
WHERE imm1985_1995_all_merged_unshuffled.cluster_no = prop.cluster_no;



UPDATE imm1985_1995_all_merged_unshuffled
SET coauthorship_ratio_95 = prop.prop
FROM
      (SELECT *,
          coalesce(round(1.0*coauthor_counts_95 / distinct_coauthor_counts_95, 3), 0) as prop
      FROM imm1985_1995_all_merged_unshuffled ) prop
WHERE imm1985_1995_all_merged_unshuffled.cluster_no = prop.cluster_no;




UPDATE imm1985_1995_all_merged_unshuffled
SET coauthor_counts = coauthor.coauthor_counts
FROM
              (SELECT set1.cluster_no, COUNT(set2.scp) as coauthor_counts
              FROM
                        (SELECT cslu.cluster_no, cslu.scp, sa.auid
                                  FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                                  LEFT JOIN public.scopus_authors sa
                                      ON cslu.scp = sa.scp)  set1
                    JOIN

                          (SELECT cslu.cluster_no, cslu.scp, sa.auid
                                  FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                                  LEFT JOIN public.scopus_authors sa
                                      ON cslu.scp = sa.scp)  set2

                      ON set1.scp=set2.scp AND set1.auid<set2.auid

              GROUP BY set1.cluster_no) coauthor

WHERE imm1985_1995_all_merged_unshuffled.cluster_no = coauthor.cluster_no;



UPDATE imm1985_1995_all_merged_unshuffled
SET distinct_coauthor_counts = dist_coauthors.distinct_coauthor_counts
FROM
      (SELECT coauthors_distinct.cluster_no, count(*) as distinct_coauthor_counts
      FROM
        (SELECT DISTINCT coauthors.cluster_no, coauthors.auid_1, coauthors.auid_2
          FROM
              (SELECT set1.cluster_no, set1.scp, set1.auid auid_1, set2.auid auid_2
              FROM
                        (SELECT cslu.cluster_no, cslu.scp, sa.auid
                        FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp) set1
              JOIN
                        (SELECT cslu.cluster_no, cslu.scp, sa.auid
                        FROM imm1985_1995_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp) set2

                      ON set1.scp=set2.scp AND set1.auid < set2.auid ) coauthors

                        ) coauthors_distinct
              GROUP BY coauthors_distinct.cluster_no) dist_coauthors
WHERE imm1985_1995_all_merged_unshuffled.cluster_no = dist_coauthors.cluster_no;



UPDATE imm1985_1995_all_merged_unshuffled
SET coauthor_prop = prop.prop
FROM
      (SELECT *,
          coalesce(round(1.0*distinct_coauthor_counts / ((num_authors*(num_authors-1))/2), 3), 0) as prop
      FROM imm1985_1995_all_merged_unshuffled ) prop
WHERE imm1985_1995_all_merged_unshuffled.cluster_no = prop.cluster_no;


UPDATE imm1985_1995_all_merged_unshuffled
SET coauthorship_ratio = prop.prop
FROM
      (SELECT *,
          coalesce(round(1.0*coauthor_counts / distinct_coauthor_counts, 3), 0) as prop
      FROM imm1985_1995_all_merged_unshuffled ) prop
WHERE imm1985_1995_all_merged_unshuffled.cluster_no = prop.cluster_no;











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
