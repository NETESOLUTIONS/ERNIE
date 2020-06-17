--- Create table for each chop file, load csv files from ERNIE server, and change the column type

CREATE TABLE IF NOT EXISTS sb_plus.sbp_1985
(
  cited_1 varchar(20),
  cited_2 varchar(20),
  frequency varchar(20));

COPY sb_plus.sbp_1985 FROM '/erniedev_data3/sb_plus/sbp_1985.csv' CSV HEADER;

ALTER TABLE sb_plus.sbp_1985 ALTER COLUMN cited_1 TYPE BIGINT USING cited_1::bigint;
ALTER TABLE sb_plus.sbp_1985 ALTER COLUMN cited_2 TYPE BIGINT USING cited_2::bigint;
ALTER TABLE sb_plus.sbp_1985 ALTER COLUMN frequency TYPE INT USING frequency::integer;


--- CHOP files: i = 1,2,...9

CREATE TABLE IF NOT EXISTS sb_plus.sbp_chop_i
(
  cited_1 varchar(20),
  cited_2 varchar(20),
  frequency varchar(20));

COPY sb_plus.sbp_chop_i FROM '/erniedev_data3/sb_plus/sb_plus_batch_chop_i.csv' CSV HEADER;

ALTER TABLE sb_plus.sbp_chop_i ALTER COLUMN cited_1 TYPE BIGINT USING cited_1::bigint;
ALTER TABLE sb_plus.sbp_chop_i ALTER COLUMN cited_2 TYPE BIGINT USING cited_2::bigint;
ALTER TABLE sb_plus.sbp_chop_i ALTER COLUMN frequency TYPE INT USING frequency::integer;


--- Create kinetics table for each kinetics file, load csv files from ERNIE server, and change the column type

CREATE TABLE IF NOT EXISTS sb_plus.sbp_1985_kinetics
(
  cited_1 varchar(20),
  cited_2 varchar(20),
  co_cited_year varchar(20),
  frequency varchar(20));

COPY sb_plus.sbp_1985_kinetics FROM '/erniedev_data3/sb_plus/sbp_1985_kinetics.csv' CSV HEADER;

ALTER TABLE sb_plus.sbp_1985_kinetics ALTER COLUMN cited_1 TYPE BIGINT USING cited_1::bigint;
ALTER TABLE sb_plus.sbp_1985_kinetics ALTER COLUMN cited_2 TYPE BIGINT USING cited_2::bigint;

ALTER TABLE sb_plus.sbp_1985_kinetics ALTER COLUMN co_cited_year TYPE SMALLINT USING case when co_cited_year ~ '^[-+0-9]+$' then co_cited_year::integer else null end;

ALTER TABLE sb_plus.sbp_1985_kinetics ALTER COLUMN frequency TYPE INT USING frequency::integer;


--- CHOP Kinetics: i = 1,2,...9

CREATE TABLE IF NOT EXISTS sb_plus.sbp_chop_i_kinetics
(
  cited_1 varchar(20),
  cited_2 varchar(20),
  co_cited_year varchar(20),
  frequency varchar(20));

COPY sb_plus.sbp_chop_i_kinetics FROM '/erniedev_data3/sb_plus/sb_plus_chop_i_kinetics.csv' CSV HEADER;

ALTER TABLE sb_plus.sbp_chop_i_kinetics ALTER COLUMN cited_1 TYPE BIGINT USING cited_1::bigint;
ALTER TABLE sb_plus.sbp_chop_i_kinetics ALTER COLUMN cited_2 TYPE BIGINT USING cited_2::bigint;

ALTER TABLE sb_plus.sbp_chop_i_kinetics ALTER COLUMN co_cited_year TYPE INT USING case when co_cited_year ~ '^[-+0-9]+$' then co_cited_year::integer else null end;

ALTER TABLE sb_plus.sbp_chop_i_kinetics ALTER COLUMN frequency TYPE INT USING frequency::integer;

