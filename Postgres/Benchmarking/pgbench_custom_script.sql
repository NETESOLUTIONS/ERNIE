\set year random(1950, 2018)

SELECT sum(1) AS number_of_citations
FROM scopus_references
WHERE scp IN (
  SELECT sgr
  FROM scopus_publication_groups
  WHERE pub_year = :year
  ORDER BY random()
  LIMIT 10
);
