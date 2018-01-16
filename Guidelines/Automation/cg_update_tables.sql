/*
This script updates the Clinical Guidelines (CG) tables in database:

1. Upserts data into cg_uids
2. Sets expired_date to today and status='expired' for expired records that are not found in new data.
3. Upserts data into cg_uid_pmid_mapping
4. Updates the log.

Author: Lingtian "Lindsay" Wan
Ceated: 03/23/2016
Modified:
* 05/20/2016, Lindsay Wan, added documentation
* 11/21/2016, Samet Keserci, revision wrt new schema plan
* 03/20/2017, Samet Keserci, revised according to migration from dev2 to dev3
* 01/15/2018, Dmitriy "DK" Korobskiy, migrated from table recreation to upserts and permanent schema
*/


\set ON_ERROR_STOP on
\set ECHO all

-- region cg_uids
\echo ***LOADING TO CG_UIDS

-- Mark the uids as expired prior to upsert and set expire date as current date.
UPDATE cg_uids SET expire_date = current_date, status = 'expired';

SELECT upsert_file('cg_uids', :'combined', csvHeaders => FALSE, delimiter => E'\t', dataFormat => 'TEXT',
  columnList => 'uid, title',
  alterDeltaTable => $$
    ALTER COLUMN load_date SET DEFAULT current_date,
    ALTER COLUMN status SET DEFAULT 'current'
  $$);
-- endregion

-- region cg_uid_pmid_mapping
\echo ***LOADING TO CG_UID_PMID_MAPPING
SELECT upsert_file('cg_uid_pmid_mapping', :'mapping', csvHeaders => FALSE);
-- endregion

\echo ***UPDATING LOG
INSERT INTO update_log_cg (num_current_uid, num_expired_uid, num_pmid, last_updated) --
VALUES ((SELECT count(uid) FROM cg_uids WHERE status = 'current'), --
        (SELECT count(uid) FROM cg_uids WHERE status = 'expired'),
        (SELECT count(1) FROM cg_uid_pmid_mapping),
        current_timestamp);