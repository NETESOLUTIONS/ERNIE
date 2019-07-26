\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

UPDATE update_log_scopus
SET
  update_time = current_timestamp, --
  num_scopus_pub =
    (SELECT count(1)
     FROM scopus_publications a),
  num_delete =
    (SELECT count(1)
     FROM del_scps b)
WHERE id =
        (SELECT max(id)
         FROM update_log_scopus);

SELECT *
FROM update_log_scopus
ORDER BY id DESC;
drop table del_scps_stg if exists ;
