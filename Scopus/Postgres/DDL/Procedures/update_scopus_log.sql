/*
Author: Djamil Lakhdar-Hamina
Date: July 22, 2019

Runs and creates a update-log. Before update takes tally, after tally, compares difference.
*/

DROP TABLE IF EXISTS update_log_scopus;
CREATE TABLE public.update_log_scopus (
  id           SERIAL,
  last_updated TIMESTAMP,
  num_nct      INTEGER,
  CONSTRAINT update_log_scopus_pk PRIMARY KEY (id) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE update_log_scopus
IS 'Scopus tables - update log table for scopus';
