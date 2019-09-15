/*
 Title: Scopus-update-log
 Author: Djamil Lakhdar-Hamina
 Date: 07/25/2019
 Purpose: Simply update the scopus log, which is a log that keeps a record on the number
 of scopus publications and the number of deletions thus far
 */

--\timing
\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

INSERT INTO update_log_scopus
    (update_time, num_scopus_pub)
SELECT current_timestamp, count(1)
  FROM scopus_publications;