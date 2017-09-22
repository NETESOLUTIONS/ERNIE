-- This script updates the FDA tables: fda_*. Specifically:
-- 1. Keep the newest version.
-- 2. Insert rows from the previous version (fda_*) that have appl_no and
--    patent_no not in the newest version.
-- 3. Drop the oldest backup version tables: old_fda_*.
-- 4. Rename tables: fda_* to old_fda_*;
--                   new_fda_* to fda_*.
-- 5. Update the log table.

-- Note: The FDA tables always have two version: fda_* as the current tables,
-- and old_fda_* as backup for previous version.

-- Author: Lingtian "Lindsay" Wan
-- Create Date: 03/07/2016
-- Modified: 05/19/2016, Lindsay Wan, added documentation
--           11/21/2016, Samet Keserci, revised wrt new schema plan
--           01/25/2017, Mike Toubasi & Lindsay Wan, added sequence number
--           03/16/2017, Samet Keserci, updates are set for pardi_admin


set search_path to public;

--Inserting old records to new tables.
\echo ***UPDATING TABLE: fda_exclusivities
insert into new_fda_exclusivities
(
	appl_type,
  appl_no,
  product_no,
  exclusivity_code,
  exclusivity_date
)
  select
    a.appl_type,
    a.appl_no,
    a.product_no,
    a.exclusivity_code,
    a.exclusivity_date
  from fda_exclusivities as a
  where not exists
  (select 1 from new_fda_exclusivities nfe where a.appl_no = nfe.appl_no);

\echo ***UPDATING TABLE: fda_patents
insert into new_fda_patents
(
    appl_type,
    appl_no,
    product_no,
    patent_no,
    patent_expire_date_text,
    drug_substance_flag,
    drug_product_flag,
    patent_use_code,
    delist_flag
  )
  select
    a.appl_type,
    a.appl_no,
    a.product_no,
    a.patent_no,
    a.patent_expire_date_text,
    a.drug_substance_flag,
    a.drug_product_flag,
    a.patent_use_code,
    a.delist_flag
  from fda_patents as a
  where not exists
  (select 1 from new_fda_patents nfp where a.appl_no = nfp.appl_no);

\echo ***UPDATING TABLE: fda_products
insert into new_fda_products
(
	ingredient,
  df_route,
  trade_name,
  applicant,
  strength,
  appl_type,
  appl_no,
  product_no,
  te_code,
  approval_date,
  rld,
	rs,
  type,
  applicant_full_name
)
  select
    a.ingredient,
    a.df_route,
    a.trade_name,
    a.applicant,
    a.strength,
    a.appl_type,
    a.appl_no,
    a.product_no,
    a.te_code,
    a.approval_date,
    a.rld,
		a.rs
    a.type,
    a.applicant_full_name
  from fda_products as a
  where not exists
  (select 1 from new_fda_products nfp where a.appl_no = nfp.appl_no);

-- Drop oldest version of tables.
\echo ***DROPPING OLDEST VERSION OF TABLES
drop table if exists old_fda_exclusivities;
drop table if exists old_fda_patents;
drop table if exists old_fda_products;

-- Rename previous version of tables to oldest version: fda_* to old_fda_*.
\echo ***RENAMING TABLES
alter table fda_exclusivities rename to old_fda_exclusivities;
alter table fda_patents rename to old_fda_patents;
alter table fda_products rename to old_fda_products;

-- Rename newest version of tables to current version: new_fda_* to fda_*.
alter table new_fda_exclusivities rename to fda_exclusivities;
alter table new_fda_patents rename to fda_patents;
alter table new_fda_products rename to fda_products;

-- Update log file.
insert into update_log_fda (last_updated, num_exclusivity)
  select current_timestamp, count(*) from fda_exclusivities;
update update_log_fda set num_patent =
  (select count(*) from fda_patents)
  where id = (select max(id) from update_log_fda);
update update_log_fda set num_products =
  (select count(*) from fda_products)
  where id = (select max(id) from update_log_fda);
