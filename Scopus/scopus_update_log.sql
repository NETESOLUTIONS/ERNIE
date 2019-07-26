/*
 Title: Scopus-update-log
 Author: Djamil Lakhdar-Hamina
 Date: 07/25/2019
 Purpose: Simply update the scopus log, which is a log that keeps a record on the number
 of scopus publications and the number of deletions thus far


 The tests are:
 1. do all tables exist
 2. do all tables have a pk
 3. do any of the tables have columns that are 100% NULL
 4. For various tables was there an increases ?
 */

\timing
\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- insert into using a values list
--
INSERT INTO update_log_scopus (update_time, num_scopus_pub, num_delete)
     SELECT *
     FROM
     (VALUES
       (
         (SELECT current_timestamp),
         (SELECT count(*) FROM scopus_publications),
         (SELECT count(*) FROM del_scps)
       )

      )
AS t (update_time, num_scopus_publications, num_deletes); 

SELECT *
FROM update_log_scopus
ORDER BY id DESC;
