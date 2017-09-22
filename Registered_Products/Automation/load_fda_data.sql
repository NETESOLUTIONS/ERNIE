-- This script loads FDA data csv files to new FDA tables (new_fda_*).

-- Usage: psql -d pardi -f load_fda_data.sql

-- Author: Lingtian "Lindsay" Wan
-- Create Date: 03/08/2016
-- Modified: 05/19/2016, Lindsay Wan, added documentation
--         : 11/21/2016, Samet Keserci, revised wrt new schema plan
--           01/25/2017, Mike Toubasi, added sequence number
--           03/16/2017, Samet Keserci, updates are set for pardi_admin


set search_path to public;

-- copy new_fda_exclusivities from :exclusivity delimiter '~' header CSV;

copy new_fda_exclusivities
(
	 appl_type,
    appl_no,
    product_no,
    exclusivity_code,
    exclusivity_date
)
from :exclusivity delimiter '~' header CSV;

-- copy new_fda_patents from :patent delimiter '~' header CSV;
copy new_fda_patents
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
from :patent delimiter '~' header CSV;


-- copy new_fda_products from :products delimiter '~' header CSV;
copy new_fda_products
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
from :products delimiter '~' header CSV;
