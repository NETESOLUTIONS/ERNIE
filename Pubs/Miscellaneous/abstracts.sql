-- Abstracts with different filenames
SELECT *
FROM wos_abstracts wa
JOIN wos_publications wp USING (source_id)
WHERE wa.source_filename <> wp.source_filename;

SELECT *
FROM wos_abstracts wa
WHERE wa.source_filename IS NULL;

SELECT string_agg(abstract_text, E'\n\n' ORDER BY id)
FROM wos_abstracts
WHERE source_id = :wos_id --'WOS:000381646800014'
GROUP BY source_id;

-- Original data
SELECT id, abstract_text
FROM wos_abstracts
WHERE source_id = 'WOS:000381646800014'
ORDER BY id;

-- region migrate wos_abstracts
CREATE TABLE tmp_wos_abstracts (
  source_id     VARCHAR(30) NOT NULL CONSTRAINT wos_abstracts_pk PRIMARY KEY,
  abstract_text TEXT NOT NULL,
  source_filename VARCHAR(200) NOT NULL
);

INSERT INTO tmp_wos_abstracts(source_id, abstract_text, source_filename)
SELECT source_id, string_agg(abstract_text, E'\n\n' ORDER BY id), source_filename
FROM wos_abstracts
GROUP BY source_id, source_filename;
-- endregion