
CREATE TABLE sb_plus.co_citation_frequency_100 TABLESPACE sb_plus_tbs AS
SELECT cited_1, cited_2, SUM(frequency) FROM sb_plus.sb_plus_complete_kinetics
GROUP BY cited_1, cited_2
HAVING SUM(frequency) >= 100;


CREATE TABLE IF NOT EXISTS sb_plus.triplets_frequency_with_limit
(
  scp1 bigint,
  scp2 bigint,
  scp3 bigint,
  frequency integer);

COPY sb_plus.triplets_frequency_with_limit FROM '/erniedev_data3/sb_plus/triplets_frequency_with_limit.csv' CSV HEADER;

SELECT scp, title
FROM public.scopus_titles
WHERE scp = 189651 or scp = 345491105 or scp = 4243553426;



CREATE TABLE IF NOT EXISTS sb_plus.triplets_99th_tri_citation_frequency
(
  scp1 bigint,
  scp2 bigint,
  scp3 bigint,
  scp1_year SMALLINT,
  scp2_year SMALLINT,
  scp3_year SMALLINT,
  first_triple_citation_year integer,
  frequency INT);

COPY sb_plus.triplets_99th_tri_citation_year FROM '/erniedev_data3/sb_plus/merged.csv' CSV HEADER;


SELECT * FROM sb_plus.triplets_99th_tri_citation_year
WHERE first_triple_citation_year < scp1_year OR first_triple_citation_year < scp2_year OR first_triple_citation_year < scp3_year;


CREATE TABLE IF NOT EXISTS sb_plus.triplets_99th_tri_citation_frequency
(
  scp1 bigint,
  scp2 bigint,
  scp3 bigint,
  scp1_year SMALLINT,
  scp2_year SMALLINT,
  scp3_year SMALLINT,
  first_triple_citation_year integer,
  frequency INT);



SELECT a.citing_paper, b.ref_sgr INTO sb_plus.triplets_citing_cited
FROM wenxi.triplets_citing_papers a
INNER JOIN public.scopus_references b
ON a.citing_paper = b.scp
WHERE b.ref_sgr IN (SELECT citing_paper FROM wenxi.triplets_citing_papers);


COPY sb_plus.triplets_citing_cited TO '/erniedev_data3/sb_plus/triplets_citing_cited.csv' CSV HEADER;


SELECT major_subject_area, COUNT(*) FROM (
  SELECT DISTINCT a.citing_paper, c.major_subject_area FROM sb_plus.triplets_citing_papers a
  LEFT JOIN public.scopus_asjc_pubs b
       ON a.citing_paper = b.scp
  LEFT JOIN public.scopus_asjc_codes c
       ON b.class_code = CAST(c.code AS TEXT)) d
 GROUP BY major_subject_area
ORDER BY COUNT(*) DESC;

SELECT minor_subject_area, COUNT(*) FROM (
  SELECT DISTINCT a.citing_paper, c.minor_subject_area FROM sb_plus.triplets_citing_papers a
  LEFT JOIN public.scopus_asjc_pubs b
            ON a.citing_paper = b.scp
  LEFT JOIN public.scopus_asjc_codes c
            ON b.class_code = CAST(c.code AS TEXT)) d
                         GROUP BY minor_subject_area
                         ORDER BY COUNT(*) DESC;

SELECT subject_area, COUNT(*) FROM (
  SELECT DISTINCT a.citing_paper, c.subject_area FROM sb_plus.triplets_citing_papers a
  LEFT JOIN public.scopus_asjc_pubs b
            ON a.citing_paper = b.scp
  LEFT JOIN public.scopus_asjc_codes c
            ON b.class_code = CAST(c.code AS TEXT)) d
                         GROUP BY subject_area
                         ORDER BY COUNT(*) DESC;


SELECT citing FROM sb_plus.triplets_citing_cited
UNION
SELECT cited FROM sb_plus.triplets_citing_cited;


SELECT cluster_no, COUNT(*) FROM sb_plus.triplets_cluster_scp_list_graclus_triplets_10
 GROUP BY cluster_no
ORDER BY COUNT(*) DESC;

SELECT cluster_no, COUNT(*) FROM sb_plus.triplets_cluster_scp_list_graclus_triplets_100
 GROUP BY cluster_no
 ORDER BY COUNT(*) DESC;

SELECT cluster_no, major_subject_area, count, rank FROM (
SELECT cluster_no, major_subject_area, count, RANK() over (PARTITION BY cluster_no ORDER BY count DESC) AS RANK FROM (
SELECT cluster_no, major_subject_area, COUNT(*) as count FROM(
SELECT DISTINCT a.*, c.major_subject_area FROM sb_plus.triplets_cluster_scp_list_graclus_triplets_10 a
LEFT JOIN public.scopus_asjc_pubs b
          ON a.scp = b.scp
LEFT JOIN public.scopus_asjc_codes c
          ON b.class_code = CAST(c.code AS TEXT)) d
GROUP BY cluster_no, major_subject_area
ORDER BY cluster_no, count(*) DESC) e) f
WHERE rank <= 3;

SELECT cluster_no, minor_subject_area, count, rank FROM (
  SELECT cluster_no, minor_subject_area, count, RANK() over (PARTITION BY cluster_no ORDER BY count DESC) AS RANK FROM (
    SELECT cluster_no, minor_subject_area, COUNT(*) as count FROM(
      SELECT DISTINCT a.*, c.minor_subject_area FROM sb_plus.triplets_cluster_scp_list_graclus_triplets_10 a
      LEFT JOIN public.scopus_asjc_pubs b
                ON a.scp = b.scp
      LEFT JOIN public.scopus_asjc_codes c
                ON b.class_code = CAST(c.code AS TEXT)) d
     GROUP BY cluster_no, minor_subject_area
     ORDER BY cluster_no, count(*) DESC) e) f
 WHERE rank <= 3;


SELECT DISTINCT scp1, scp2, scp3, c.subject_area AS scp1_subject_area, f.subject_area AS scp2_subject_area, h.subject_area AS scp3_subject_area
INTO sb_plus.triplets_ASJC
FROM sb_plus.triplets_99th_tri_citation_year a
LEFT JOIN public.scopus_asjc_pubs b
ON a.scp1 = b.scp
LEFT JOIN public.scopus_asjc_codes c
ON b.class_code = CAST(c.code AS TEXT)
LEFT JOIN public.scopus_asjc_pubs e
          ON a.scp2 = e.scp
LEFT JOIN public.scopus_asjc_codes f
          ON e.class_code = CAST(f.code AS TEXT)
LEFT JOIN public.scopus_asjc_pubs g
          ON a.scp2 = g.scp
LEFT JOIN public.scopus_asjc_codes h
          ON g.class_code = CAST(h.code AS TEXT)
ORDER BY scp1, scp2, scp3;
----



CREATE TABLE IF NOT EXISTS sb_plus.triplets_top_100
(
  scp1 bigint,
  scp2 bigint,
  scp3 bigint,
  citing_paper bigint);

COPY sb_plus.triplets_top_100 FROM '/erniedev_data3/sb_plus/triplets_top_citing_paper.csv' CSV HEADER;

CREATE TABLE IF NOT EXISTS sb_plus.triplets_bottom_100
(
  scp1 bigint,
  scp2 bigint,
  scp3 bigint,
  citing_paper bigint);

COPY sb_plus.triplets_bottom_100 FROM '/erniedev_data3/sb_plus/triplets_bottom_citing_paper.csv' CSV HEADER;

SELECT subject_area, COUNT(*) FROM (
SELECT DISTINCT citing_paper, c.subject_area AS subject_area
  FROM sb_plus.triplets_bottom_100 a
  LEFT JOIN public.scopus_asjc_pubs b
            ON a.citing_paper = b.scp
  LEFT JOIN public.scopus_asjc_codes c
            ON b.class_code = CAST(c.code AS TEXT)) d
GROUP BY subject_area
ORDER BY COUNT(*) DESC;


-- Life Sciences,566
-- Physical Sciences,375
-- Health Sciences,288
-- Social Sciences,36
-- General,29
-- Null,19

SELECT subject_area, COUNT(*) FROM (
  SELECT DISTINCT citing_paper, c.subject_area AS subject_area
    FROM sb_plus.triplets_top_100 a
    LEFT JOIN public.scopus_asjc_pubs b
              ON a.citing_paper = b.scp
    LEFT JOIN public.scopus_asjc_codes c
              ON b.class_code = CAST(c.code AS TEXT)) d
 GROUP BY subject_area
 ORDER BY COUNT(*) DESC;


-- Physical Sciences,75061
-- Life Sciences,22473
-- Null,4634
-- Health Sciences,2148
-- Social Sciences,1933
-- General,971

