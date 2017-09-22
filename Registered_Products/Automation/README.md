# Automated data ETL process
Code related to FDA Orange Book data automated ETL process.

## Scripts

`fda_update_auto.sh`: main script for downloading data, loading, and updating in dev server.

`createtable_new_fda.sql`: create a set of new FDA tables new_fda_*.

`load_fda_data.sql`: load fda data to new FDA tables new_fda_*.

`fda_update_tables.sql`: update tables with new records.

`gw_download_fda_orange.sh`: download FDA orange book data from Gateway Server.

`prod_fda_update_auto.sh`: updating tables in prod server.

## Usage

### Download FDA data from website to gateway server:

    sh gw_download_fda_orange.sh work_dir/

where `work_dir` specifies working directory that stores scripts above.

### Update tables in dev server:

    sh fda_update_auto.sh work_dir/

where `work_dir` specifies working directory that stores scripts above.
