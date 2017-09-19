# Automated data ETL process
This folder contains code used to update the ERNIE database of clinical guidelines from the AHRQ NGC site through a semi-automated ETL process.

## Scripts

`gw_download_cg.sh`: download CG data from gateway server.

`cg_update_auto.sh`: main script for downloading data, loading, and updating in dev server.

`cg_pmidextractor`: extract pmids from CG silverchair IDs.

`cg_update_tables.sql`: update PostgreSQL tables with new records.

`cg_flow_ref_count.sql`: calculate reference countings for CG and their references.

`cg_get_abstract_auto.sh`: extract abstract of CG.

`PmidToAbstract.java`: extract abstract of CG with pmids.

`prod_cg_update_auto.sh`: main script for updating tables in prod server.

## Usage

### Download data from website to gateway server:

    sh gw_download_cg.sh work_dir/

where `work_dir` specifies working directory that stores scripts above.

### Update tables in dev server:

    sh cg_update_auto.sh work_dir/

where `work_dir` specifies working directory that stores scripts above.

### Update tables in prod server:

    sh prod_cg_update_auto.sh
