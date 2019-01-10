\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

DO $block$
  BEGIN
    FOR year IN 1986..2005 LOOP
      EXECUTE format($$DROP TABLE IF EXISTS wos_article_references_%s$$, year);

      EXECUTE format($$CREATE TABLE wos_article_references_%s (
          reference_id VARCHAR(30)
            CONSTRAINT wos_article_references_%1$s_pk PRIMARY KEY USING INDEX TABLESPACE index_tbs,
          cit_count INTEGER,
          ratio DOUBLE PRECISION
        ) TABLESPACE wos_tbs$$, year);
    END LOOP;
  END $block$;