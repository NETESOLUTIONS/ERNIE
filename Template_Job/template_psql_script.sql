\set ON_ERROR_STOP on
\set ECHO all

-- region Create objects if not present
--@formatter:off
DO $block$ BEGIN
  IF NOT EXISTS(SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'public' AND table_name = 'tmp_template_job')
  THEN
    CREATE TABLE tmp_template_job (
      id   INT          NOT NULL PRIMARY KEY,
      col1 VARCHAR(100) NOT NULL,
      col2 VARCHAR(100),
      load_date DATE DEFAULT current_date
    );
    RAISE NOTICE 'Created';
  END IF;
END $block$;
--@formatter:on
-- endregion

-- Server COPY exports file under postgres:postgres ownership
-- Use client copy to generate the file under the current user ownership
\copy tmp_template_job TO 'template_job_export.csv' (FORMAT CSV, HEADER ON)

-- Import from a CSV via an upsert (does not require TRUNCATE)
SELECT upsert_file('tmp_template_job', :'work_dir' || '/template_job_lf.csv', columnList => 'id, col1, col2',
  alterDeltaTable => 'ALTER COLUMN load_date SET DEFAULT current_date');