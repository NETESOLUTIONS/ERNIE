SET default_tablespace = wos;

CREATE TABLE tmp_wos_keywords (
  id              INTEGER AUTO_INCREMENT,
  source_id       VARCHAR(30)  NOT NULL,
  keyword         VARCHAR(200) NOT NULL,
  source_filename VARCHAR(200),
  CONSTRAINT wos_keywords_pk PRIMARY KEY (source_id,keyword) USING INDEX TABLESPACE indexes
);

INSERT INTO tmp_wos_keywords (source_id, keyword, source_filename)
  SELECT
    source_id ,
    keyword,
    source_filename
  FROM wos_keywords
  GROUP BY source_id, source_filename;

ALTER TABLE wos_keywords
  RENAME TO tmp_bak_wos_keywords;
ALTER TABLE tmp_wos_keywords
  RENAME TO wos_keywords;


CREATE TABLE tmp_wos_keywords (
  id              INTEGER AUTO_INCREMENT,
  source_id       VARCHAR(30)  NOT NULL,
  keyword         VARCHAR(200) NOT NULL,
  source_filename VARCHAR(200),
  CONSTRAINT wos_keywords_pk PRIMARY KEY (source_id,keyword) USING INDEX TABLESPACE indexes
);

INSERT INTO tmp_wos_keywords (source_id, keyword, source_filename)
  SELECT
    source_id ,
    keyword,
    source_filename
  FROM wos_keywords
  GROUP BY source_id, source_filename;

ALTER TABLE wos_keywords
  RENAME TO tmp_bak_wos_keywords;
ALTER TABLE tmp_wos_keywords
  RENAME TO wos_keywords;