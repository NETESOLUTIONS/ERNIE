/*
This script loads FDA CSV data files

1. Keep the newest version.
2. Insert rows from the previous version (fda_*) that have appl_no and
   patent_no not in the newest version.
3. Drop the oldest backup version tables: old_fda_*.
4. Rename tables: fda_* to old_fda_*; new_fda_* to fda_*.
5. Update the log table.

Author: Lingtian "Lindsay" Wan
Created: 03/08/2016

Modified:
  05/19/2016, Lindsay Wan, added documentation
  11/21/2016, Samet Keserci, revised wrt new schema plan
  01/25/2017, Mike Toubasi, added sequence number
  03/16/2017, Samet Keserci, updates are set for pardi_admin
  12/22/2017, Dmitriy "DK" Korobskiy, merged three SQL scripts into one
  01/01/2018, Dmitriy "DK" Korobskiy, migrated to Upserts and permanent schema
*/

\set ON_ERROR_STOP on
\set ECHO all

SELECT upsert_file('fda_exclusivities', :'work_dir' || '/exclusivity.csv', TRUE, '~');
SELECT upsert_file('fda_patents', :'work_dir' || '/patent.csv', TRUE, '~');
SELECT upsert_file('fda_products', :'work_dir' || '/products.csv', TRUE, '~');

-- Update log file.
INSERT INTO update_log_fda (last_updated, num_exclusivity, num_patent, num_products) --
VALUES (current_timestamp, --
        (SELECT count(1)
        FROM fda_exclusivities), --
        (SELECT count(1)
        FROM fda_patents), --
        (SELECT count(1)
        FROM fda_products));