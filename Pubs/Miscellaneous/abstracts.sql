-- Abstracts with different filenames
SELECT *
FROM wos_abstracts wa
JOIN wos_publications wp USING (source_id)
WHERE wa.source_filename <> wp.source_filename;

SELECT *
FROM wos_abstracts wa
WHERE wa.source_filename IS NULL;

SELECT string_agg(abstract_text, E'\n\n'
ORDER BY id)
FROM wos_abstracts
WHERE source_id = :wos_id --'WOS:000381646800014'
GROUP BY source_id;

-- Abstracts per a publication
SELECT abstract_text
FROM wos_abstracts
WHERE source_id = 'WOS:000381646800014';

-- region migrate wos_abstracts
SET default_tablespace = wos;

CREATE TABLE tmp_wos_abstracts (
  source_id       VARCHAR(30)  NOT NULL CONSTRAINT tmp_wos_abstracts_pk PRIMARY KEY,
  abstract_text   TEXT         NOT NULL,
  source_filename VARCHAR(200) NOT NULL
);

INSERT INTO tmp_wos_abstracts (source_id, abstract_text, source_filename)
  SELECT
    source_id,
    string_agg(abstract_text, E'\n\n'
    ORDER BY id),
    source_filename
  FROM wos_abstracts
  GROUP BY source_id, source_filename;

ALTER TABLE wos_abstracts
  RENAME TO tmp_bak_wos_abstracts;
ALTER TABLE tmp_wos_abstracts
  RENAME TO wos_abstracts;
-- endregion

-- region migrate del_wos_abstracts
ALTER TABLE del_wos_abstracts
  DROP COLUMN id;
ALTER TABLE del_wos_abstracts
  ALTER COLUMN abstract_text TYPE TEXT USING abstract_text :: TEXT;
-- endregion

-- region migrate uhs_wos_abstracts
ALTER TABLE uhs_wos_abstracts
  ALTER COLUMN abstract_text TYPE TEXT USING abstract_text :: TEXT;
-- endregion