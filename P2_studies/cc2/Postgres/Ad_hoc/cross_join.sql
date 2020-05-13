  WITH foo(scp, sgr) AS (
    VALUES
      (1, 5),
      (1, 6),
      (1, 7),
      (2, 5),
      (2, 9)
  )
SELECT f1.scp, f1.sgr AS cited_1, f2.sgr AS cited_2
  FROM foo f1
  JOIN foo f2 ON f1.scp = f2.scp AND f1.sgr < f2.sgr
 ORDER BY scp, cited_1, cited_2;