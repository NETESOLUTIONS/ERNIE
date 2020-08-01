/*
author: Shreya Chandrasekharan

This script is used to generate and populate all columns pertaining to 
author counts - number of authors, papers per author, co-authorship

This script is particularly written for the imm1993 table

*/

-- set schema
SET search_path = theta_plus;

-- Add author count info for the imm1993 table

-- region: add columns
ALTER TABLE imm1993_all_merged_unshuffled

ADD COLUMN p_1_author_count BIGINT,
ADD COLUMN p_50_author_count BIGINT,
ADD COLUMN p_75_author_count BIGINT,
ADD COLUMN p_90_author_count BIGINT,
ADD COLUMN p_95_author_count BIGINT,
ADD COLUMN p_99_author_count BIGINT,
ADD COLUMN p_100_author_count BIGINT,

ADD COLUMN num_authors BIGINT,
ADD COLUMN num_authors_1_count BIGINT,
ADD COLUMN num_authors_50 BIGINT,
ADD COLUMN num_authors_75 BIGINT,
ADD COLUMN num_authors_95 BIGINT,
ADD COLUMN num_authors_99 BIGINT,
ADD COLUMN num_articles_50 BIGINT,
ADD COLUMN num_articles_75 BIGINT,
ADD COLUMN num_articles_95 BIGINT,
ADD COLUMN num_articles_99 BIGINT,

ADD COLUMN coauthor_counts BIGINT,
ADD COLUMN distinct_coauthor_counts BIGINT,
ADD COLUMN coauthor_prop DOUBLE PRECISION,
ADD COLUMN coauthorship_ratio DOUBLE PRECISION,

ADD COLUMN coauthor_counts_50 BIGINT,
ADD COLUMN distinct_coauthor_counts_50 BIGINT,
ADD COLUMN coauthor_prop_50 DOUBLE PRECISION,
ADD COLUMN coauthorship_ratio_50 DOUBLE PRECISION,

ADD COLUMN coauthor_counts_75 BIGINT,
ADD COLUMN distinct_coauthor_counts_75 BIGINT,
ADD COLUMN coauthor_prop_75 DOUBLE PRECISION,
ADD COLUMN coauthorship_ratio_75 DOUBLE PRECISION,

ADD COLUMN coauthor_counts_95 BIGINT,
ADD COLUMN distinct_coauthor_counts_95 BIGINT,
ADD COLUMN coauthor_prop_95 DOUBLE PRECISION,
ADD COLUMN coauthorship_ratio_95 DOUBLE PRECISION,

ADD COLUMN coauthor_counts_99 BIGINT,
ADD COLUMN distinct_coauthor_counts_99 BIGINT,
ADD COLUMN coauthor_prop_99 DOUBLE PRECISION,
ADD COLUMN coauthorship_ratio_99 DOUBLE PRECISION;
-- end region



-- region: percentile values of papers per author in the cluster

-- 1st percentile papers per author
UPDATE imm1993_all_merged_unshuffled
SET p_1_author_count = percentile_val.p_1_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(0.1) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_1_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1993_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1993_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;

-- 50th percentile (median) papers per author
UPDATE imm1993_all_merged_unshuffled
SET p_50_author_count = percentile_val.p_50_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(0.5) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_50_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1993_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1993_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;

-- 75th percentile (Q3) papers per author
UPDATE imm1993_all_merged_unshuffled
SET p_75_author_count = percentile_val.p_75_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(0.75) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_75_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1993_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1993_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;

-- 90th percentile papers per author
UPDATE imm1993_all_merged_unshuffled
SET p_90_author_count = percentile_val.p_90_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(0.9) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_90_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1993_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1993_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;

-- 95th percentile papers per author
UPDATE imm1993_all_merged_unshuffled
SET p_95_author_count = percentile_val.p_95_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(0.95) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_95_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1993_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1993_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;

-- 99th percentile papers per author
UPDATE imm1993_all_merged_unshuffled
SET p_99_author_count = percentile_val.p_99_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(0.99) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_99_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1993_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1993_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;

-- 100th percentile (Q4) papers per author
UPDATE imm1993_all_merged_unshuffled
SET p_100_author_count = percentile_val.p_100_author_count
FROM
(SELECT authors.cluster_no,
  percentile_disc(1) WITHIN GROUP ( ORDER BY authors.num_articles ) as p_100_author_count
  FROM
(SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
FROM imm1993_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) percentile_val

WHERE imm1993_all_merged_unshuffled.cluster_no = percentile_val.cluster_no
;


-- end region

-- region: get the total number of authors in the cluster
UPDATE imm1993_all_merged_unshuffled
SET num_authors = authors.num_authors
FROM
(SELECT cslu.cluster_no, count(DISTINCT sa.auid) num_authors
FROM imm1993_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_authors sa
  ON cslu.scp = sa.scp
GROUP BY cslu.cluster_no) authors
WHERE imm1993_all_merged_unshuffled.cluster_no = authors.cluster_no
;
-- end region

-- region: get count of authors who have only 1 article in the cluster
UPDATE imm1993_all_merged_unshuffled
   SET  num_authors_1_count = all_authors.num_author_1_count
 FROM
    (SELECT authors_1.cluster_no, count(authors_1.authors) num_author_1_count
FROM
        (SELECT cslu.cluster_no, sa.auid authors, count(sa.auid) num_articles
        FROM imm1993_cluster_scp_list_unshuffled cslu
        LEFT JOIN public.scopus_authors sa
            ON cslu.scp = sa.scp
        GROUP BY cslu.cluster_no, sa.auid
        HAVING count(sa.auid) = 1) authors_1
GROUP BY authors_1.cluster_no) all_authors
WHERE imm1993_all_merged_unshuffled.cluster_no = all_authors.cluster_no;

-- end region


-- region: get counts of authors who have at least p percentile papers per author in the cluster

-- number of authors who have >= 50th percentile papers per authors
UPDATE imm1993_all_merged_unshuffled
   SET  num_authors_50 = all_authors.num_author_50
 FROM
    (SELECT authors_50.cluster_no, count(authors_50.auid) as num_author_50
    FROM
            (SELECT authors.cluster_no, authors.auid, authors.num_articles
            FROM
                    (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                    FROM imm1993_cluster_scp_list_unshuffled cslu
                    LEFT JOIN public.scopus_authors sa
                        ON cslu.scp = sa.scp
                    GROUP BY cslu.cluster_no, sa.auid) authors

            LEFT JOIN imm1993_all_merged_unshuffled amu
                ON authors.cluster_no = amu.cluster_no
            WHERE authors.num_articles >= amu.p_50_author_count) authors_50
    GROUP BY authors_50.cluster_no) all_authors
WHERE imm1993_all_merged_unshuffled.cluster_no = all_authors.cluster_no;


-- number of authors who have >= 75th percentile papers per authors
UPDATE imm1993_all_merged_unshuffled
   SET  num_authors_75 = all_authors.num_author_75
 FROM
    (SELECT authors_75.cluster_no, count(authors_75.auid) as num_author_75
    FROM
            (SELECT authors.cluster_no, authors.auid, authors.num_articles
            FROM
                    (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                    FROM imm1993_cluster_scp_list_unshuffled cslu
                    LEFT JOIN public.scopus_authors sa
                        ON cslu.scp = sa.scp
                    GROUP BY cslu.cluster_no, sa.auid) authors

            LEFT JOIN imm1993_all_merged_unshuffled amu
                ON authors.cluster_no = amu.cluster_no
            WHERE authors.num_articles >= amu.p_75_author_count) authors_75
    GROUP BY authors_75.cluster_no) all_authors
WHERE imm1993_all_merged_unshuffled.cluster_no = all_authors.cluster_no;


-- number of authors who have >= 95th percentile papers per authors
UPDATE imm1993_all_merged_unshuffled
   SET  num_authors_95 = all_authors.num_author_95
 FROM
    (SELECT authors_95.cluster_no, count(authors_95.auid) as num_author_95
    FROM
            (SELECT authors.cluster_no, authors.auid, authors.num_articles
            FROM
                    (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                    FROM imm1993_cluster_scp_list_unshuffled cslu
                    LEFT JOIN public.scopus_authors sa
                        ON cslu.scp = sa.scp
                    GROUP BY cslu.cluster_no, sa.auid) authors

            LEFT JOIN imm1993_all_merged_unshuffled amu
                ON authors.cluster_no = amu.cluster_no
            WHERE authors.num_articles >= amu.p_95_author_count) authors_95
    GROUP BY authors_95.cluster_no) all_authors
WHERE imm1993_all_merged_unshuffled.cluster_no = all_authors.cluster_no;

-- number of authors who have >= 99th percentile papers per authors
UPDATE imm1993_all_merged_unshuffled
   SET  num_authors_99 = all_authors.num_author_99
 FROM
    (SELECT authors_99.cluster_no, count(authors_99.auid) as num_author_99
    FROM
            (SELECT authors.cluster_no, authors.auid, authors.num_articles
            FROM
                    (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                    FROM imm1993_cluster_scp_list_unshuffled cslu
                    LEFT JOIN public.scopus_authors sa
                        ON cslu.scp = sa.scp
                    GROUP BY cslu.cluster_no, sa.auid) authors

            LEFT JOIN imm1993_all_merged_unshuffled amu
                ON authors.cluster_no = amu.cluster_no
            WHERE authors.num_articles >= amu.p_99_author_count) authors_99
    GROUP BY authors_99.cluster_no) all_authors
WHERE imm1993_all_merged_unshuffled.cluster_no = all_authors.cluster_no;



-- region: get counts of articles written by authors 
-- who have at least p percentile papers per author in the cluster

-- number of articles by authors who have >= 50th percentile papers per authors
UPDATE imm1993_all_merged_unshuffled
    SET num_articles_50 = articles_50.num_articles_50
FROM
        (SELECT scps.cluster_no, count(DISTINCT scps.scp) as num_articles_50
        FROM
                    (SELECT cslu.cluster_no, cslu.scp, sa.auid
                    FROM imm1993_cluster_scp_list_unshuffled cslu
                    LEFT JOIN public.scopus_authors sa
                        ON cslu.scp = sa.scp) scps
        JOIN
                    (SELECT authors.cluster_no, authors.auid
                    FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                          FROM imm1993_cluster_scp_list_unshuffled cslu
                          LEFT JOIN public.scopus_authors sa
                              ON cslu.scp = sa.scp
                          GROUP BY cslu.cluster_no, sa.auid) authors

                     JOIN imm1993_all_merged_unshuffled amu
                        ON authors.cluster_no = amu.cluster_no
                    WHERE authors.num_articles >= amu.p_50_author_count ) authors_50

            ON scps.auid = authors_50.auid and scps.cluster_no = authors_50.cluster_no
        GROUP BY scps.cluster_no) articles_50
WHERE imm1993_all_merged_unshuffled.cluster_no = articles_50.cluster_no;


-- number of articles by authors who have >= 75th percentile papers per authors
UPDATE imm1993_all_merged_unshuffled
    SET num_articles_75 = articles_75.num_articles_75
FROM
        (SELECT scps.cluster_no, count(DISTINCT scps.scp) as num_articles_75
        FROM
                    (SELECT cslu.cluster_no, cslu.scp, sa.auid
                    FROM imm1993_cluster_scp_list_unshuffled cslu
                    LEFT JOIN public.scopus_authors sa
                        ON cslu.scp = sa.scp) scps
        JOIN
                    (SELECT authors.cluster_no, authors.auid
                    FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                          FROM imm1993_cluster_scp_list_unshuffled cslu
                          LEFT JOIN public.scopus_authors sa
                              ON cslu.scp = sa.scp
                          GROUP BY cslu.cluster_no, sa.auid) authors

                     JOIN imm1993_all_merged_unshuffled amu
                        ON authors.cluster_no = amu.cluster_no
                    WHERE authors.num_articles >= amu.p_75_author_count ) authors_75

            ON scps.auid = authors_75.auid and scps.cluster_no = authors_75.cluster_no
        GROUP BY scps.cluster_no) articles_75
WHERE imm1993_all_merged_unshuffled.cluster_no = articles_75.cluster_no;


-- number of articles by authors who have >= 95th percentile papers per authors
UPDATE imm1993_all_merged_unshuffled
    SET num_articles_95 = articles_95.num_articles_95
FROM
        (SELECT scps.cluster_no, count(DISTINCT scps.scp) as num_articles_95
        FROM
                    (SELECT cslu.cluster_no, cslu.scp, sa.auid
                    FROM imm1993_cluster_scp_list_unshuffled cslu
                    LEFT JOIN public.scopus_authors sa
                        ON cslu.scp = sa.scp) scps
        JOIN
                    (SELECT authors.cluster_no, authors.auid
                    FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                          FROM imm1993_cluster_scp_list_unshuffled cslu
                          LEFT JOIN public.scopus_authors sa
                              ON cslu.scp = sa.scp
                          GROUP BY cslu.cluster_no, sa.auid) authors

                     JOIN imm1993_all_merged_unshuffled amu
                        ON authors.cluster_no = amu.cluster_no
                    WHERE authors.num_articles >= amu.p_95_author_count ) authors_95

            ON scps.auid = authors_95.auid and scps.cluster_no = authors_95.cluster_no
        GROUP BY scps.cluster_no) articles_95
WHERE imm1993_all_merged_unshuffled.cluster_no = articles_95.cluster_no;


-- number of articles by authors who have >= 99th percentile papers per authors
UPDATE imm1993_all_merged_unshuffled
    SET num_articles_99 = articles_99.num_articles_99
FROM
        (SELECT scps.cluster_no, count(DISTINCT scps.scp) as num_articles_99
        FROM
                    (SELECT cslu.cluster_no, cslu.scp, sa.auid
                    FROM imm1993_cluster_scp_list_unshuffled cslu
                    LEFT JOIN public.scopus_authors sa
                        ON cslu.scp = sa.scp) scps
        JOIN
                    (SELECT authors.cluster_no, authors.auid
                    FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                          FROM imm1993_cluster_scp_list_unshuffled cslu
                          LEFT JOIN public.scopus_authors sa
                              ON cslu.scp = sa.scp
                          GROUP BY cslu.cluster_no, sa.auid) authors

                     JOIN imm1993_all_merged_unshuffled amu
                        ON authors.cluster_no = amu.cluster_no
                    WHERE authors.num_articles >= amu.p_99_author_count ) authors_99

            ON scps.auid = authors_99.auid and scps.cluster_no = authors_99.cluster_no
        GROUP BY scps.cluster_no) articles_99
WHERE imm1993_all_merged_unshuffled.cluster_no = articles_99.cluster_no;

-- end region


-- region: co-authorship counts: total, distinct, co-authorship proportion, co-authorship ratio

/*
coauthorship_prop  : (distinct co-authorship counts) / NC2  
        where, N is the number of authors
It is the total number of individual co-authorship instances out of the theoretical max possible instances


coauthorship_ratio  : (total co-authorship counts) / (distinct co-authorship counts)
Avg. number of times 2 authors collaborate within a cluster
*/

-- total number of co-authorship occurrences (edges) in the cluster
UPDATE imm1993_all_merged_unshuffled
SET coauthor_counts = coauthor.coauthor_counts
FROM
              (SELECT set1.cluster_no, COUNT(set2.scp) as coauthor_counts
              FROM
                        (SELECT cslu.cluster_no, cslu.scp, sa.auid
                                  FROM imm1993_cluster_scp_list_unshuffled cslu
                                  LEFT JOIN public.scopus_authors sa
                                      ON cslu.scp = sa.scp)  set1
                    JOIN

                          (SELECT cslu.cluster_no, cslu.scp, sa.auid
                                  FROM imm1993_cluster_scp_list_unshuffled cslu
                                  LEFT JOIN public.scopus_authors sa
                                      ON cslu.scp = sa.scp)  set2

                      ON set1.scp=set2.scp AND set1.auid<set2.auid

              GROUP BY set1.cluster_no) coauthor

WHERE imm1993_all_merged_unshuffled.cluster_no = coauthor.cluster_no;


-- total number of distinct co-authorship occurrences (edges) in the cluster
UPDATE imm1993_all_merged_unshuffled
SET distinct_coauthor_counts = dist_coauthors.distinct_coauthor_counts
FROM
      (SELECT coauthors_distinct.cluster_no, count(*) as distinct_coauthor_counts
      FROM
        (SELECT DISTINCT coauthors.cluster_no, coauthors.auid_1, coauthors.auid_2
          FROM
              (SELECT set1.cluster_no, set1.scp, set1.auid auid_1, set2.auid auid_2
              FROM
                        (SELECT cslu.cluster_no, cslu.scp, sa.auid
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp) set1
              JOIN
                        (SELECT cslu.cluster_no, cslu.scp, sa.auid
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp) set2

                      ON set1.scp=set2.scp AND set1.auid < set2.auid ) coauthors

                        ) coauthors_distinct
              GROUP BY coauthors_distinct.cluster_no) dist_coauthors
WHERE imm1993_all_merged_unshuffled.cluster_no = dist_coauthors.cluster_no;


-- number of distinct co-authorship occurrences (edges) in the cluster over theoretical maximum
UPDATE imm1993_all_merged_unshuffled
SET coauthor_prop = prop.prop
FROM
      (SELECT *,
          coalesce(round(1.0*distinct_coauthor_counts / ((num_authors*(num_authors-1))/2), 3), 0) as prop
      FROM imm1993_all_merged_unshuffled ) prop
WHERE imm1993_all_merged_unshuffled.cluster_no = prop.cluster_no;


-- total number of co-authorship occurrences (edges) in the cluster over distinct occurrences 
UPDATE imm1993_all_merged_unshuffled
SET coauthorship_ratio = prop.prop
FROM
      (SELECT *,
          coalesce(round(1.0*coauthor_counts / distinct_coauthor_counts, 3), 0) as prop
      FROM imm1993_all_merged_unshuffled ) prop
WHERE imm1993_all_merged_unshuffled.cluster_no = prop.cluster_no;



-- total number of co-authorship occurrences (edges) among authors 
-- with >= 50th percentile papers per author in the cluster
UPDATE imm1993_all_merged_unshuffled
SET coauthor_counts_50 = coauthor.coauthor_counts
FROM
      (SELECT set1.cluster_no, COUNT(set2.scp) as coauthor_counts
      FROM
            (SELECT scps.cluster_no, scps.scp, authors_50.auid
             FROM
                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                  FROM imm1993_cluster_scp_list_unshuffled cslu
                  LEFT JOIN public.scopus_authors sa
                      ON cslu.scp = sa.scp) scps
             JOIN
                  (SELECT authors.cluster_no, authors.auid
                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp
                        GROUP BY cslu.cluster_no, sa.auid) authors

                   JOIN imm1993_all_merged_unshuffled amu
                      ON authors.cluster_no = amu.cluster_no
                  WHERE authors.num_articles >= amu.p_50_author_count ) authors_50

              ON scps.auid = authors_50.auid and
                 scps.cluster_no = authors_50.cluster_no ) set1
    JOIN
            (SELECT scps.cluster_no, scps.scp, authors_50.auid
             FROM
                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                  FROM imm1993_cluster_scp_list_unshuffled cslu
                  LEFT JOIN public.scopus_authors sa
                      ON cslu.scp = sa.scp) scps
             JOIN
                  (SELECT authors.cluster_no, authors.auid
                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp
                        GROUP BY cslu.cluster_no, sa.auid) authors

                   JOIN imm1993_all_merged_unshuffled amu
                      ON authors.cluster_no = amu.cluster_no
                  WHERE authors.num_articles >= amu.p_50_author_count ) authors_50

              ON scps.auid = authors_50.auid and
                 scps.cluster_no = authors_50.cluster_no ) set2

          ON set1.scp=set2.scp AND set1.auid<set2.auid

      GROUP BY set1.cluster_no) coauthor
WHERE imm1993_all_merged_unshuffled.cluster_no = coauthor.cluster_no;


-- total number of distinct co-authorship occurrences (edges) among authors 
-- with >= 50th percentile papers per author in the cluster
UPDATE imm1993_all_merged_unshuffled
SET distinct_coauthor_counts_50 = dist_coauthors.distinct_coauthor_counts
FROM
  (SELECT coauthors_distinct.cluster_no, count(*) as distinct_coauthor_counts
  FROM
    (
      SELECT DISTINCT coauthors.cluster_no, coauthors.auid_1, coauthors.auid_2
      FROM
          (SELECT set1.cluster_no, set1.scp, set1.auid auid_1, set2.auid auid_2
          FROM
            (SELECT scps.cluster_no, scps.scp, authors_50.auid
             FROM
                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                  FROM imm1993_cluster_scp_list_unshuffled cslu
                  LEFT JOIN public.scopus_authors sa
                      ON cslu.scp = sa.scp) scps
         JOIN
                  (SELECT authors.cluster_no, authors.auid
                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp
                  GROUP BY cslu.cluster_no, sa.auid) authors

                   JOIN imm1993_all_merged_unshuffled amu
                      ON authors.cluster_no = amu.cluster_no
                  WHERE authors.num_articles >= amu.p_50_author_count ) authors_50

              ON scps.auid = authors_50.auid and
                 scps.cluster_no = authors_50.cluster_no ) set1
  JOIN
            (SELECT scps.cluster_no, scps.scp, authors_50.auid
             FROM
                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                  FROM imm1993_cluster_scp_list_unshuffled cslu
                  LEFT JOIN public.scopus_authors sa
                      ON cslu.scp = sa.scp) scps
         JOIN
                  (SELECT authors.cluster_no, authors.auid
                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp
                   GROUP BY cslu.cluster_no, sa.auid) authors

                   JOIN imm1993_all_merged_unshuffled amu
                      ON authors.cluster_no = amu.cluster_no
                  WHERE authors.num_articles >= amu.p_50_author_count ) authors_50

              ON scps.auid = authors_50.auid and
                 scps.cluster_no = authors_50.cluster_no ) set2

          ON set1.scp=set2.scp AND set1.auid < set2.auid ) coauthors
          ) coauthors_distinct
      GROUP BY coauthors_distinct.cluster_no) dist_coauthors
WHERE imm1993_all_merged_unshuffled.cluster_no = dist_coauthors.cluster_no;


-- number of distinct co-authorship occurrences (edges) in the cluster over theoretical maximum
-- among authors with >= 50th percentile papers per author
UPDATE imm1993_all_merged_unshuffled
SET coauthor_prop_50 = prop.prop
FROM
  (SELECT *,
      coalesce(round(1.0*distinct_coauthor_counts_50 / ((num_authors_50*(num_authors_50-1))/2), 3), 0) as prop
  FROM imm1993_all_merged_unshuffled ) prop
WHERE imm1993_all_merged_unshuffled.cluster_no = prop.cluster_no;


-- total number of co-authorship occurrences (edges) in the cluster over distinct occurrences 
-- among authors with >= 50th percentile papers per author
UPDATE imm1993_all_merged_unshuffled
SET coauthorship_ratio_50 = prop.prop
FROM
  (SELECT *,
      coalesce(round(1.0*coauthor_counts_50 / distinct_coauthor_counts_50, 3), 0) as prop
      FROM imm1993_all_merged_unshuffled ) prop
WHERE imm1993_all_merged_unshuffled.cluster_no = prop.cluster_no;


-- total number of co-authorship occurrences (edges) among authors 
-- with >= 75th percentile papers per author in the cluster
UPDATE imm1993_all_merged_unshuffled
SET coauthor_counts_75 = coauthor.coauthor_counts
FROM
      (SELECT set1.cluster_no, COUNT(set2.scp) as coauthor_counts
      FROM
            (SELECT scps.cluster_no, scps.scp, authors_75.auid
             FROM
                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                  FROM imm1993_cluster_scp_list_unshuffled cslu
                  LEFT JOIN public.scopus_authors sa
                      ON cslu.scp = sa.scp) scps
         JOIN
                  (SELECT authors.cluster_no, authors.auid
                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp
                        GROUP BY cslu.cluster_no, sa.auid) authors

                   JOIN imm1993_all_merged_unshuffled amu
                      ON authors.cluster_no = amu.cluster_no
                  WHERE authors.num_articles >= amu.p_75_author_count ) authors_75

              ON scps.auid = authors_75.auid and
                 scps.cluster_no = authors_75.cluster_no ) set1
      JOIN
            (SELECT scps.cluster_no, scps.scp, authors_75.auid
             FROM
                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                  FROM imm1993_cluster_scp_list_unshuffled cslu
                  LEFT JOIN public.scopus_authors sa
                      ON cslu.scp = sa.scp) scps
         JOIN
                  (SELECT authors.cluster_no, authors.auid
                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp
                        GROUP BY cslu.cluster_no, sa.auid) authors

                   JOIN imm1993_all_merged_unshuffled amu
                      ON authors.cluster_no = amu.cluster_no
                  WHERE authors.num_articles >= amu.p_75_author_count ) authors_75

              ON scps.auid = authors_75.auid and
                 scps.cluster_no = authors_75.cluster_no ) set2

              ON set1.scp=set2.scp AND set1.auid<set2.auid

      GROUP BY set1.cluster_no) coauthor
WHERE imm1993_all_merged_unshuffled.cluster_no = coauthor.cluster_no;


-- total number of distinct co-authorship occurrences (edges) among authors 
-- with >= 75th percentile papers per author in the cluster
UPDATE imm1993_all_merged_unshuffled
SET distinct_coauthor_counts_75 = dist_coauthors.distinct_coauthor_counts
FROM
  (SELECT coauthors_distinct.cluster_no, count(*) as distinct_coauthor_counts
  FROM
    (
      SELECT DISTINCT coauthors.cluster_no, coauthors.auid_1, coauthors.auid_2
      FROM
          (SELECT set1.cluster_no, set1.scp, set1.auid auid_1, set2.auid auid_2
          FROM
            (SELECT scps.cluster_no, scps.scp, authors_75.auid
             FROM
                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                  FROM imm1993_cluster_scp_list_unshuffled cslu
                  LEFT JOIN public.scopus_authors sa
                      ON cslu.scp = sa.scp) scps
             JOIN
                  (SELECT authors.cluster_no, authors.auid
                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp
                  GROUP BY cslu.cluster_no, sa.auid) authors

                   JOIN imm1993_all_merged_unshuffled amu
                      ON authors.cluster_no = amu.cluster_no
                  WHERE authors.num_articles >= amu.p_75_author_count ) authors_75

              ON scps.auid = authors_75.auid and
                 scps.cluster_no = authors_75.cluster_no ) set1
      JOIN
            (SELECT scps.cluster_no, scps.scp, authors_75.auid
             FROM
                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                  FROM imm1993_cluster_scp_list_unshuffled cslu
                  LEFT JOIN public.scopus_authors sa
                      ON cslu.scp = sa.scp) scps
             JOIN
                  (SELECT authors.cluster_no, authors.auid
                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp
                   GROUP BY cslu.cluster_no, sa.auid) authors

                   JOIN imm1993_all_merged_unshuffled amu
                      ON authors.cluster_no = amu.cluster_no
                  WHERE authors.num_articles >= amu.p_75_author_count ) authors_75

              ON scps.auid = authors_75.auid and
                 scps.cluster_no = authors_75.cluster_no ) set2

          ON set1.scp=set2.scp AND set1.auid < set2.auid ) coauthors
          ) coauthors_distinct
          GROUP BY coauthors_distinct.cluster_no) dist_coauthors
WHERE imm1993_all_merged_unshuffled.cluster_no = dist_coauthors.cluster_no;


-- number of distinct co-authorship occurrences (edges) in the cluster over theoretical maximum
-- among authors with >= 75th percentile papers per author
UPDATE imm1993_all_merged_unshuffled
SET coauthor_prop_75 = prop.prop
FROM
  (SELECT *,
      coalesce(round(1.0*distinct_coauthor_counts_75 / ((num_authors_75*(num_authors_75-1))/2), 3), 0) as prop
  FROM imm1993_all_merged_unshuffled ) prop
WHERE imm1993_all_merged_unshuffled.cluster_no = prop.cluster_no;


-- total number of co-authorship occurrences (edges) in the cluster over distinct occurrences 
-- among authors with >= 75th percentile papers per author
UPDATE imm1993_all_merged_unshuffled
SET coauthorship_ratio_75 = prop.prop
FROM
  (SELECT *,
      coalesce(round(1.0*coauthor_counts_75 / distinct_coauthor_counts_75, 3), 0) as prop
  FROM imm1993_all_merged_unshuffled ) prop
WHERE imm1993_all_merged_unshuffled.cluster_no = prop.cluster_no;


-- total number of co-authorship occurrences (edges) among authors 
-- with >= 95th percentile papers per author in the cluster
UPDATE imm1993_all_merged_unshuffled
SET coauthor_counts_95 = coauthor.coauthor_counts
FROM
      (SELECT set1.cluster_no, COUNT(set2.scp) as coauthor_counts
      FROM
            (SELECT scps.cluster_no, scps.scp, authors_95.auid
             FROM
                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                  FROM imm1993_cluster_scp_list_unshuffled cslu
                  LEFT JOIN public.scopus_authors sa
                      ON cslu.scp = sa.scp) scps
             JOIN
                  (SELECT authors.cluster_no, authors.auid
                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp
                        GROUP BY cslu.cluster_no, sa.auid) authors

                   JOIN imm1993_all_merged_unshuffled amu
                      ON authors.cluster_no = amu.cluster_no
                  WHERE authors.num_articles >= amu.p_95_author_count ) authors_95

              ON scps.auid = authors_95.auid and
                 scps.cluster_no = authors_95.cluster_no ) set1
  JOIN
            (SELECT scps.cluster_no, scps.scp, authors_95.auid
             FROM
                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                  FROM imm1993_cluster_scp_list_unshuffled cslu
                  LEFT JOIN public.scopus_authors sa
                      ON cslu.scp = sa.scp) scps
             JOIN
                  (SELECT authors.cluster_no, authors.auid
                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp
                        GROUP BY cslu.cluster_no, sa.auid) authors

                   JOIN imm1993_all_merged_unshuffled amu
                      ON authors.cluster_no = amu.cluster_no
                  WHERE authors.num_articles >= amu.p_95_author_count ) authors_95

              ON scps.auid = authors_95.auid and
                 scps.cluster_no = authors_95.cluster_no ) set2

          ON set1.scp=set2.scp AND set1.auid<set2.auid

      GROUP BY set1.cluster_no) coauthor
WHERE imm1993_all_merged_unshuffled.cluster_no = coauthor.cluster_no;


-- total number of distinct co-authorship occurrences (edges) among authors 
-- with >= 95th percentile papers per author in the cluster
UPDATE imm1993_all_merged_unshuffled
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
                      FROM imm1993_cluster_scp_list_unshuffled cslu
                      LEFT JOIN public.scopus_authors sa
                          ON cslu.scp = sa.scp) scps
                 JOIN
                      (SELECT authors.cluster_no, authors.auid
                       FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                            FROM imm1993_cluster_scp_list_unshuffled cslu
                            LEFT JOIN public.scopus_authors sa
                                ON cslu.scp = sa.scp
                      GROUP BY cslu.cluster_no, sa.auid) authors

                       JOIN imm1993_all_merged_unshuffled amu
                          ON authors.cluster_no = amu.cluster_no
                      WHERE authors.num_articles >= amu.p_95_author_count ) authors_95

                  ON scps.auid = authors_95.auid and
                     scps.cluster_no = authors_95.cluster_no ) set1
              JOIN
                (SELECT scps.cluster_no, scps.scp, authors_95.auid
                 FROM
                      (SELECT cslu.cluster_no, cslu.scp, sa.auid
                      FROM imm1993_cluster_scp_list_unshuffled cslu
                      LEFT JOIN public.scopus_authors sa
                          ON cslu.scp = sa.scp) scps
                 JOIN
                      (SELECT authors.cluster_no, authors.auid
                       FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                            FROM imm1993_cluster_scp_list_unshuffled cslu
                            LEFT JOIN public.scopus_authors sa
                                ON cslu.scp = sa.scp
                       GROUP BY cslu.cluster_no, sa.auid) authors

                       JOIN imm1993_all_merged_unshuffled amu
                          ON authors.cluster_no = amu.cluster_no
                      WHERE authors.num_articles >= amu.p_95_author_count ) authors_95

                  ON scps.auid = authors_95.auid and
                     scps.cluster_no = authors_95.cluster_no ) set2

              ON set1.scp=set2.scp AND set1.auid < set2.auid ) coauthors
              ) coauthors_distinct
      GROUP BY coauthors_distinct.cluster_no) dist_coauthors
WHERE imm1993_all_merged_unshuffled.cluster_no = dist_coauthors.cluster_no;


-- number of distinct co-authorship occurrences (edges) in the cluster over theoretical maximum
-- among authors with >= 95th percentile papers per author
UPDATE imm1993_all_merged_unshuffled
SET coauthor_prop_95 = prop.prop
FROM
  (SELECT *,
      coalesce(round(1.0*distinct_coauthor_counts_95 / ((num_authors_95*(num_authors_95-1))/2), 3), 0) as prop
  FROM imm1993_all_merged_unshuffled ) prop
WHERE imm1993_all_merged_unshuffled.cluster_no = prop.cluster_no;


-- total number of co-authorship occurrences (edges) in the cluster over distinct occurrences 
-- among authors with >= 95th percentile papers per author
UPDATE imm1993_all_merged_unshuffled
SET coauthorship_ratio_95 = prop.prop
FROM
  (SELECT *,
      coalesce(round(1.0*coauthor_counts_95 / distinct_coauthor_counts_95, 3), 0) as prop
  FROM imm1993_all_merged_unshuffled ) prop
WHERE imm1993_all_merged_unshuffled.cluster_no = prop.cluster_no;



-- total number of co-authorship occurrences (edges) among authors 
-- with >= 99th percentile papers per author in the cluster
UPDATE imm1993_all_merged_unshuffled
SET coauthor_counts_99 = coauthor.coauthor_counts
FROM
      (SELECT set1.cluster_no, COUNT(set2.scp) as coauthor_counts
      FROM
        (SELECT scps.cluster_no, scps.scp, authors_99.auid
         FROM
          (SELECT cslu.cluster_no, cslu.scp, sa.auid
          FROM imm1993_cluster_scp_list_unshuffled cslu
          LEFT JOIN public.scopus_authors sa
              ON cslu.scp = sa.scp) scps
      JOIN
          (SELECT authors.cluster_no, authors.auid
           FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                FROM imm1993_cluster_scp_list_unshuffled cslu
                LEFT JOIN public.scopus_authors sa
                    ON cslu.scp = sa.scp
                GROUP BY cslu.cluster_no, sa.auid) authors

           JOIN imm1993_all_merged_unshuffled amu
              ON authors.cluster_no = amu.cluster_no
          WHERE authors.num_articles >= amu.p_99_author_count ) authors_99

          ON scps.auid = authors_99.auid and
             scps.cluster_no = authors_99.cluster_no ) set1
      JOIN
        (SELECT scps.cluster_no, scps.scp, authors_99.auid
         FROM
          (SELECT cslu.cluster_no, cslu.scp, sa.auid
          FROM imm1993_cluster_scp_list_unshuffled cslu
          LEFT JOIN public.scopus_authors sa
              ON cslu.scp = sa.scp) scps
      JOIN
          (SELECT authors.cluster_no, authors.auid
           FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                FROM imm1993_cluster_scp_list_unshuffled cslu
                LEFT JOIN public.scopus_authors sa
                    ON cslu.scp = sa.scp
                GROUP BY cslu.cluster_no, sa.auid) authors

           JOIN imm1993_all_merged_unshuffled amu
              ON authors.cluster_no = amu.cluster_no
          WHERE authors.num_articles >= amu.p_99_author_count ) authors_99

          ON scps.auid = authors_99.auid and
             scps.cluster_no = authors_99.cluster_no ) set2

      ON set1.scp=set2.scp AND set1.auid<set2.auid

      GROUP BY set1.cluster_no) coauthor
WHERE imm1993_all_merged_unshuffled.cluster_no = coauthor.cluster_no;


-- total number of distinct co-authorship occurrences (edges) among authors 
-- with >= 99th percentile papers per author in the cluster
UPDATE imm1993_all_merged_unshuffled
SET distinct_coauthor_counts_99 = dist_coauthors.distinct_coauthor_counts
FROM
      (SELECT coauthors_distinct.cluster_no, count(*) as distinct_coauthor_counts
      FROM
        (
  SELECT DISTINCT coauthors.cluster_no, coauthors.auid_1, coauthors.auid_2
  FROM
      (SELECT set1.cluster_no, set1.scp, set1.auid auid_1, set2.auid auid_2
      FROM
        (SELECT scps.cluster_no, scps.scp, authors_99.auid
         FROM
                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                  FROM imm1993_cluster_scp_list_unshuffled cslu
                  LEFT JOIN public.scopus_authors sa
                      ON cslu.scp = sa.scp) scps
             JOIN
                  (SELECT authors.cluster_no, authors.auid
                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp
                  GROUP BY cslu.cluster_no, sa.auid) authors

                   JOIN imm1993_all_merged_unshuffled amu
                      ON authors.cluster_no = amu.cluster_no
                  WHERE authors.num_articles >= amu.p_99_author_count ) authors_99

          ON scps.auid = authors_99.auid and
             scps.cluster_no = authors_99.cluster_no ) set1
      JOIN
        (SELECT scps.cluster_no, scps.scp, authors_99.auid
         FROM
                  (SELECT cslu.cluster_no, cslu.scp, sa.auid
                  FROM imm1993_cluster_scp_list_unshuffled cslu
                  LEFT JOIN public.scopus_authors sa
                      ON cslu.scp = sa.scp) scps
             JOIN
                  (SELECT authors.cluster_no, authors.auid
                   FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                        FROM imm1993_cluster_scp_list_unshuffled cslu
                        LEFT JOIN public.scopus_authors sa
                            ON cslu.scp = sa.scp
                   GROUP BY cslu.cluster_no, sa.auid) authors

                   JOIN imm1993_all_merged_unshuffled amu
                      ON authors.cluster_no = amu.cluster_no
                  WHERE authors.num_articles >= amu.p_99_author_count ) authors_99

          ON scps.auid = authors_99.auid and
             scps.cluster_no = authors_99.cluster_no ) set2

      ON set1.scp=set2.scp AND set1.auid < set2.auid ) coauthors
      ) coauthors_distinct
      GROUP BY coauthors_distinct.cluster_no) dist_coauthors
WHERE imm1993_all_merged_unshuffled.cluster_no = dist_coauthors.cluster_no;


-- number of distinct co-authorship occurrences (edges) in the cluster over theoretical maximum
-- among authors with >= 99th percentile papers per author
UPDATE imm1993_all_merged_unshuffled
SET coauthor_prop_99 = prop.prop
FROM
  (SELECT *,
      coalesce(round(1.0*distinct_coauthor_counts_99 / ((num_authors_99*(num_authors_99-1))/2), 3), 0) as prop
  FROM imm1993_all_merged_unshuffled ) prop
WHERE imm1993_all_merged_unshuffled.cluster_no = prop.cluster_no;


-- total number of co-authorship occurrences (edges) in the cluster over distinct occurrences 
-- among authors with >= 99th percentile papers per author
UPDATE imm1993_all_merged_unshuffled
SET coauthorship_ratio_99 = prop.prop
FROM
  (SELECT *,
      coalesce(round(1.0*coauthor_counts_99 / distinct_coauthor_counts_99, 3), 0) as prop
  FROM imm1993_all_merged_unshuffled ) prop
WHERE imm1993_all_merged_unshuffled.cluster_no = prop.cluster_no;

