\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

UPDATE update_log_scopus
SET
  last_updated = current_timestamp, --
  num_scopus_publications =
    (SELECT count(1)
     FROM scopus_publications),
  num_update =
    (SELECT count(1)
     FROM update_scps_tmp a
     WHERE last_update_time >
             (SELECT last_update_time
              FROM update_log_scopus
              ORDER BY id DESC
              LIMIT 1)),
  num_delete =
    (SELECT count(1)
     FROM del_scps_st b
     WHERE del_time >
             (SELECT last_update_time
              FROM update_log_scopus
              ORDER BY id DESC
              LIMIT 1)),
  num_new =
    (SELECT count(1)
     FROM scopus_publications c
     WHERE last_updated_time >
             (SELECT process_start_time
              FROM update_log_scopus
              ORDER BY id DESC
              LIMIT 1) AND source_id NOT IN
             (SELECT DISTINCT source_id
              FROM uhs_scopus_publications
              WHERE uhs_updated_time >
                      (SELECT process_start_time
                       FROM update_log_scopus
                       ORDER BY id DESC
                       LIMIT 1)))
WHERE id =
        (SELECT max(id)
         FROM update_log_scopus);

SELECT *
FROM update_log_scopus
ORDER BY id DESC;
