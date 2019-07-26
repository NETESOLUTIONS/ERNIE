\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- created a delete table which will be counted like scopus_pub

INSERT INTO update_log_scopus (update_time, num_scopus_pub,num_delete)
SELECT
  current_timestamp,  --
  count(a.scp),
  count(b.scp)
FROM scopus_publications a, del_scps b;

SELECT *
FROM update_log_scopus
ORDER BY id DESC;
