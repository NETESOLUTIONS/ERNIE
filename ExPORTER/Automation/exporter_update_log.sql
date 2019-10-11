/*
 Title: exporter-update-log
 Author: Djamil Lakhdar-Hamina
 Date: 07/25/2019
 Purpose: Simply update the exporter log, which is a log that keeps a record on the number
 of exporter projects updated
 */

-- \timing
\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- insert into using a values list

INSERT INTO update_log_scopus (update_time, num_ex_project)
     SELECT *
     FROM
     (VALUES
       (
         (SELECT current_timestamp),
         (SELECT count(*) FROM exporter_projects)
       )

      )
AS t (update_time, num_ex_project);

SELECT *
FROM update_log_scopus
ORDER BY id DESC;
