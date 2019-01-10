-- Limited non-deterministic sample of publications
SELECT source_id
FROM wos_publications wp
WHERE publication_year = '1980'
LIMIT 5;
-- 0.1s

-- Limited deterministic sample of publications
SELECT source_id
FROM wos_publications wp
WHERE publication_year = '1980'
ORDER BY ctid
LIMIT 5;
-- 0.6s

-- Limited deterministic sample of publications
SELECT source_id
FROM wos_publications wp
WHERE publication_year = '1980'
ORDER BY source_id
LIMIT 5;

-- Base query
SELECT source_id, EXISTS(SELECT 1
                         FROM wos_addresses wa
                         WHERE wa.source_id = wp.source_id) AS address_exists
FROM wos_publications wp
WHERE publication_year = '1900';

-- Random 1% of source_ids for a given year
SELECT publication_year, count(source_id) AS pub_count, --
  count(NULL OR EXISTS(SELECT 1
                       FROM wos_addresses wa
                       WHERE wa.source_id = wp.source_id)) AS pub_with_an_address_count
FROM wos_publications wp
WHERE publication_year = '1900' AND random() < 0.01
GROUP BY wp.publication_year;

-- Random 1% of source_ids for all years
SELECT publication_year, count(source_id) AS pub_count, --
  -- Convert TRUE to TRUE and FALSE to NULL
  count(EXISTS(SELECT 1
               FROM wos_addresses wa
               WHERE wa.source_id = wp.source_id) OR NULL) AS pub_with_an_address_count
FROM wos_publications wp
WHERE random() < 0.01
GROUP BY wp.publication_year;

-- Random 1% of source_ids for a given year for all years
SELECT publication_year, count(source_id) AS pub_count, --
  -- Convert TRUE to TRUE and FALSE to NULL
  count(EXISTS(SELECT 1
               FROM wos_addresses wa
               WHERE wa.source_id = wp.source_id) OR NULL) AS pub_with_an_address_count
FROM wos_publications wp
WHERE source_id IN (SELECT source_id
FROM wos_publications wp2
WHERE wp2.publication_year = wp.publication_year AND random() < 0.01)
GROUP BY wp.publication_year;