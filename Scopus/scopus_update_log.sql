\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- created a delete table which will be counted like scopus_pub

UPDATE update_log_scopus
SET
  id= id+ 1 ,
  update_time = current_timestamp, --
  num_scopus_pub =
    (SELECT count(1)
     FROM scopus_publications a),
  num_delete =
    (SELECT count(1)
     FROM del_scps_stg b)
WHERE id= > 1 ;

SELECT *
FROM update_log_scopus
ORDER BY id DESC;
