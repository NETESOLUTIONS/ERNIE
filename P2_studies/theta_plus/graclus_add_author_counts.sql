----------- imm1985 ----------------

ALTER TABLE imm1985_all_merged_graclus
ADD COLUMN num_authors BIGINT,
ADD COLUMN max_author_count BIGINT;

UPDATE imm1985_all_merged_graclus
SET num_authors = authors.num_authors
FROM (SELECT elu.cluster_no, count(DISTINCT sa.auid) as num_authors
      FROM imm1985_edge_list_graclus elu
      LEFT JOIN public.scopus_authors sa
          ON elu.scp = sa.scp
      GROUP BY elu.cluster_no) authors
WHERE imm1985_all_merged_graclus.cluster_no = authors.cluster_no;

UPDATE imm1985_all_merged_graclus
SET max_author_count = num_authors.max_authors
FROM (SELECT authors.cluster_no, max(num_author) as max_authors
FROM
(SELECT elu.cluster_no, sa.auid, count(sa.auid) num_author
FROM imm1985_edge_list_graclus elu
LEFT JOIN public.scopus_authors sa
    ON elu.scp = sa.scp
GROUP BY elu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) num_authors
WHERE imm1985_all_merged_graclus.cluster_no = num_authors.cluster_no;

----------- imm1986 ----------------

ALTER TABLE imm1986_all_merged_graclus
ADD COLUMN num_authors BIGINT,
ADD COLUMN max_author_count BIGINT;

UPDATE imm1986_all_merged_graclus
SET num_authors = authors.num_authors
FROM (SELECT elu.cluster_no, count(DISTINCT sa.auid) as num_authors
      FROM imm1986_edge_list_graclus elu
      LEFT JOIN public.scopus_authors sa
          ON elu.scp = sa.scp
      GROUP BY elu.cluster_no) authors
WHERE imm1986_all_merged_graclus.cluster_no = authors.cluster_no;

UPDATE imm1986_all_merged_graclus
SET max_author_count = num_authors.max_authors
FROM (SELECT authors.cluster_no, max(num_author) as max_authors
FROM
(SELECT elu.cluster_no, sa.auid, count(sa.auid) num_author
FROM imm1986_edge_list_graclus elu
LEFT JOIN public.scopus_authors sa
    ON elu.scp = sa.scp
GROUP BY elu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) num_authors
WHERE imm1986_all_merged_graclus.cluster_no = num_authors.cluster_no;

----------- imm1987 ----------------

ALTER TABLE imm1987_all_merged_graclus
ADD COLUMN num_authors BIGINT,
ADD COLUMN max_author_count BIGINT;

UPDATE imm1987_all_merged_graclus
SET num_authors = authors.num_authors
FROM (SELECT elu.cluster_no, count(DISTINCT sa.auid) as num_authors
      FROM imm1987_edge_list_graclus elu
      LEFT JOIN public.scopus_authors sa
          ON elu.scp = sa.scp
      GROUP BY elu.cluster_no) authors
WHERE imm1987_all_merged_graclus.cluster_no = authors.cluster_no;

UPDATE imm1987_all_merged_graclus
SET max_author_count = num_authors.max_authors
FROM (SELECT authors.cluster_no, max(num_author) as max_authors
FROM
(SELECT elu.cluster_no, sa.auid, count(sa.auid) num_author
FROM imm1987_edge_list_graclus elu
LEFT JOIN public.scopus_authors sa
    ON elu.scp = sa.scp
GROUP BY elu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) num_authors
WHERE imm1987_all_merged_graclus.cluster_no = num_authors.cluster_no;

----------- imm1988 ----------------

ALTER TABLE imm1988_all_merged_graclus
ADD COLUMN num_authors BIGINT,
ADD COLUMN max_author_count BIGINT;

UPDATE imm1988_all_merged_graclus
SET num_authors = authors.num_authors
FROM (SELECT elu.cluster_no, count(DISTINCT sa.auid) as num_authors
      FROM imm1988_edge_list_graclus elu
      LEFT JOIN public.scopus_authors sa
          ON elu.scp = sa.scp
      GROUP BY elu.cluster_no) authors
WHERE imm1988_all_merged_graclus.cluster_no = authors.cluster_no;

UPDATE imm1988_all_merged_graclus
SET max_author_count = num_authors.max_authors
FROM (SELECT authors.cluster_no, max(num_author) as max_authors
FROM
(SELECT elu.cluster_no, sa.auid, count(sa.auid) num_author
FROM imm1988_edge_list_graclus elu
LEFT JOIN public.scopus_authors sa
    ON elu.scp = sa.scp
GROUP BY elu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) num_authors
WHERE imm1988_all_merged_graclus.cluster_no = num_authors.cluster_no;

----------- imm1989 ----------------

ALTER TABLE imm1989_all_merged_graclus
ADD COLUMN num_authors BIGINT,
ADD COLUMN max_author_count BIGINT;

UPDATE imm1989_all_merged_graclus
SET num_authors = authors.num_authors
FROM (SELECT elu.cluster_no, count(DISTINCT sa.auid) as num_authors
      FROM imm1989_edge_list_graclus elu
      LEFT JOIN public.scopus_authors sa
          ON elu.scp = sa.scp
      GROUP BY elu.cluster_no) authors
WHERE imm1989_all_merged_graclus.cluster_no = authors.cluster_no;

UPDATE imm1989_all_merged_graclus
SET max_author_count = num_authors.max_authors
FROM (SELECT authors.cluster_no, max(num_author) as max_authors
FROM
(SELECT elu.cluster_no, sa.auid, count(sa.auid) num_author
FROM imm1989_edge_list_graclus elu
LEFT JOIN public.scopus_authors sa
    ON elu.scp = sa.scp
GROUP BY elu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) num_authors
WHERE imm1989_all_merged_graclus.cluster_no = num_authors.cluster_no;

----------- imm1990 ----------------

ALTER TABLE imm1990_all_merged_graclus
ADD COLUMN num_authors BIGINT,
ADD COLUMN max_author_count BIGINT;

UPDATE imm1990_all_merged_graclus
SET num_authors = authors.num_authors
FROM (SELECT elu.cluster_no, count(DISTINCT sa.auid) as num_authors
      FROM imm1990_edge_list_graclus elu
      LEFT JOIN public.scopus_authors sa
          ON elu.scp = sa.scp
      GROUP BY elu.cluster_no) authors
WHERE imm1990_all_merged_graclus.cluster_no = authors.cluster_no;

UPDATE imm1990_all_merged_graclus
SET max_author_count = num_authors.max_authors
FROM (SELECT authors.cluster_no, max(num_author) as max_authors
FROM
(SELECT elu.cluster_no, sa.auid, count(sa.auid) num_author
FROM imm1990_edge_list_graclus elu
LEFT JOIN public.scopus_authors sa
    ON elu.scp = sa.scp
GROUP BY elu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) num_authors
WHERE imm1990_all_merged_graclus.cluster_no = num_authors.cluster_no;

----------- imm1991 ----------------

ALTER TABLE imm1991_all_merged_graclus
ADD COLUMN num_authors BIGINT,
ADD COLUMN max_author_count BIGINT;

UPDATE imm1991_all_merged_graclus
SET num_authors = authors.num_authors
FROM (SELECT elu.cluster_no, count(DISTINCT sa.auid) as num_authors
      FROM imm1991_edge_list_graclus elu
      LEFT JOIN public.scopus_authors sa
          ON elu.scp = sa.scp
      GROUP BY elu.cluster_no) authors
WHERE imm1991_all_merged_graclus.cluster_no = authors.cluster_no;

UPDATE imm1991_all_merged_graclus
SET max_author_count = num_authors.max_authors
FROM (SELECT authors.cluster_no, max(num_author) as max_authors
FROM
(SELECT elu.cluster_no, sa.auid, count(sa.auid) num_author
FROM imm1991_edge_list_graclus elu
LEFT JOIN public.scopus_authors sa
    ON elu.scp = sa.scp
GROUP BY elu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) num_authors
WHERE imm1991_all_merged_graclus.cluster_no = num_authors.cluster_no;

----------- imm1992 ----------------

ALTER TABLE imm1992_all_merged_graclus
ADD COLUMN num_authors BIGINT,
ADD COLUMN max_author_count BIGINT;

UPDATE imm1992_all_merged_graclus
SET num_authors = authors.num_authors
FROM (SELECT elu.cluster_no, count(DISTINCT sa.auid) as num_authors
      FROM imm1992_edge_list_graclus elu
      LEFT JOIN public.scopus_authors sa
          ON elu.scp = sa.scp
      GROUP BY elu.cluster_no) authors
WHERE imm1992_all_merged_graclus.cluster_no = authors.cluster_no;

UPDATE imm1992_all_merged_graclus
SET max_author_count = num_authors.max_authors
FROM (SELECT authors.cluster_no, max(num_author) as max_authors
FROM
(SELECT elu.cluster_no, sa.auid, count(sa.auid) num_author
FROM imm1992_edge_list_graclus elu
LEFT JOIN public.scopus_authors sa
    ON elu.scp = sa.scp
GROUP BY elu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) num_authors
WHERE imm1992_all_merged_graclus.cluster_no = num_authors.cluster_no;

----------- imm1993 ----------------

ALTER TABLE imm1993_all_merged_graclus
ADD COLUMN num_authors BIGINT,
ADD COLUMN max_author_count BIGINT;

UPDATE imm1993_all_merged_graclus
SET num_authors = authors.num_authors
FROM (SELECT elu.cluster_no, count(DISTINCT sa.auid) as num_authors
      FROM imm1993_edge_list_graclus elu
      LEFT JOIN public.scopus_authors sa
          ON elu.scp = sa.scp
      GROUP BY elu.cluster_no) authors
WHERE imm1993_all_merged_graclus.cluster_no = authors.cluster_no;

UPDATE imm1993_all_merged_graclus
SET max_author_count = num_authors.max_authors
FROM (SELECT authors.cluster_no, max(num_author) as max_authors
FROM
(SELECT elu.cluster_no, sa.auid, count(sa.auid) num_author
FROM imm1993_edge_list_graclus elu
LEFT JOIN public.scopus_authors sa
    ON elu.scp = sa.scp
GROUP BY elu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) num_authors
WHERE imm1993_all_merged_graclus.cluster_no = num_authors.cluster_no;

----------- imm1994 ----------------

ALTER TABLE imm1994_all_merged_graclus
ADD COLUMN num_authors BIGINT,
ADD COLUMN max_author_count BIGINT;

UPDATE imm1994_all_merged_graclus
SET num_authors = authors.num_authors
FROM (SELECT elu.cluster_no, count(DISTINCT sa.auid) as num_authors
      FROM imm1994_edge_list_graclus elu
      LEFT JOIN public.scopus_authors sa
          ON elu.scp = sa.scp
      GROUP BY elu.cluster_no) authors
WHERE imm1994_all_merged_graclus.cluster_no = authors.cluster_no;

UPDATE imm1994_all_merged_graclus
SET max_author_count = num_authors.max_authors
FROM (SELECT authors.cluster_no, max(num_author) as max_authors
FROM
(SELECT elu.cluster_no, sa.auid, count(sa.auid) num_author
FROM imm1994_edge_list_graclus elu
LEFT JOIN public.scopus_authors sa
    ON elu.scp = sa.scp
GROUP BY elu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) num_authors
WHERE imm1994_all_merged_graclus.cluster_no = num_authors.cluster_no;

----------- imm1995 ----------------

ALTER TABLE imm1995_all_merged_graclus
ADD COLUMN num_authors BIGINT,
ADD COLUMN max_author_count BIGINT;

UPDATE imm1995_all_merged_graclus
SET num_authors = authors.num_authors
FROM (SELECT elu.cluster_no, count(DISTINCT sa.auid) as num_authors
      FROM imm1995_edge_list_graclus elu
      LEFT JOIN public.scopus_authors sa
          ON elu.scp = sa.scp
      GROUP BY elu.cluster_no) authors
WHERE imm1995_all_merged_graclus.cluster_no = authors.cluster_no;

UPDATE imm1995_all_merged_graclus
SET max_author_count = num_authors.max_authors
FROM (SELECT authors.cluster_no, max(num_author) as max_authors
FROM
(SELECT elu.cluster_no, sa.auid, count(sa.auid) num_author
FROM imm1995_edge_list_graclus elu
LEFT JOIN public.scopus_authors sa
    ON elu.scp = sa.scp
GROUP BY elu.cluster_no, sa.auid) authors
GROUP BY authors.cluster_no) num_authors
WHERE imm1995_all_merged_graclus.cluster_no = num_authors.cluster_no;



