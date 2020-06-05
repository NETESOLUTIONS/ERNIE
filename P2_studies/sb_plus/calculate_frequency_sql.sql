SET SEARCH_PATH = wenxi;

CREATE UNLOGGED TABLE IF NOT EXISTS test_one_million_pairs
(
  cited_1 BIGINT,
  cited_2 BIGINT,
  CONSTRAINT test_one_million_pairs_pk PRIMARY KEY (cited_1, cited_2) USING INDEX TABLESPACE index_tbs
);

COPY test_one_million_pairs FROM '/erniedev_data2/jenkins_home/workspace/ERNIE-Neo4j-sb-plus/build/test_1000000.csv' CSV HEADER;

-- Query for calculate frequency
/*  WITH cte AS (
    SELECT sr.scp, tomp.cited_1, tomp.cited_2 FROM test_one_million_pairs tomp
    INNER JOIN public.scopus_references sr
               ON tomp.cited_1 = sr.ref_sgr
     WHERE (scp, cited_2) IN (SELECT sr.scp, sr.ref_sgr
                                FROM public.scopus_references sr
                               WHERE tomp.cited_2 = sr.ref_sgr)
  )
SELECT cited_1, cited_2, COUNT(*) FROM cte
 GROUP BY cited_1, cited_2;*/

CREATE OR REPLACE FUNCTION calculate_frequency() RETURNS TABLE (cited_1 BIGINT, cited_2 BIGINT, frequency INT)
  LANGUAGE plpgsql AS
$func$
DECLARE
  cited_1 BIGINT;
  cited_2 BIGINT;
BEGIN
  FOR cited_1, cited_2 IN
    SELECT cited_1, cited_2 FROM test_one_million_pairs LIMIT 1000
  LOOP
    EXECUTE 'WITH cte AS (SELECT sr.scp, tomp.cited_1, tomp.cited_2 FROM test_one_million_pairs tomp
              INNER JOIN public.scopus_references sr
              ON tomp.cited_1 = sr.ref_sgr
              WHERE (scp, cited_2) IN (SELECT sr.scp, sr.ref_sgr
              FROM public.scopus_references sr
              WHERE tomp.cited_2 = sr.ref_sgr))
        SELECT cited_1, cited_2, COUNT(*) FROM cte
        GROUP BY cited_1, cited_2';
  END LOOP;
  RETURN;
END
$func$;