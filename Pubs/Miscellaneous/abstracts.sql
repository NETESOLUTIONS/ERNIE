SELECT *
FROM wos_abstracts wa
JOIN wos_publications wp USING (source_id)
WHERE wa.source_filename <> wp.source_filename;

CREATE TABLE tmp_wos_abstracts (
  source_id     VARCHAR(30) CONSTRAINT tmp_wos_abstracts_pk PRIMARY KEY,
  abstract_text TEXT
);

SELECT string_agg(abstract_text, E'\n' ORDER BY id)
FROM wos_abstracts
WHERE source_id = 'WOS:000381646800014'
GROUP BY source_id;

-- Original data
SELECT id, abstract_text
FROM wos_abstracts
WHERE source_id = 'WOS:000381646800014'
ORDER BY id;