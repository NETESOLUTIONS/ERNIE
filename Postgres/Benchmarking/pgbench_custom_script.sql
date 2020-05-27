-- Use a fixed past year to reduce random deviation
\set year 1991
--\set year random(1950, 2018)

SELECT sum(1) AS number_of_citations
FROM scopus_references
WHERE scp IN (
  SELECT sgr
  FROM scopus_publication_groups
  WHERE pub_year = :year
  -- Randomize sample to discount effects of caching
  ORDER BY random()
  LIMIT 10
);
