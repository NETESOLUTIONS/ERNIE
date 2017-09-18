# Automated data ETL process
Code related to Clinical Trials data automated ETL process.

## Scripts

`createtable_new_ct_clinical_studies.sql`: create new table: new_ct_clinical_studies.

`createtable_new_ct_subs.sql`: create new children tables: new_ct_*.

`ct_update_auto.sh`: main script for downloading data, parsing, loading, and updating in dev server.

`ct_xml_update_parser.py`: parse XML files to CSV format.

`ct_update_tables.sql`: update tables with new records.

`load_ct_to_irdb.py`: import ct_clinical_studies table to IRDB database.

`gw_download_ct.sh`: download CT data from gateway server.

`prod_ct_update_auto.sh`: main script for updating tables in prod server.

## Usage

### Download data from website to gateway server:

    sh gw_download_ct.sh work_dir/
where  `work_dir` specifies working directory that stores script above.

### Update tables in dev server:

    sh ct_update_auto.sh work_dir/ pswd

where `work_dir` specifies working directory that stores scripts above, and `pswd` specifies password to connect to IRDB database.

### Update tables in prod server:

    sh prod_ct_update_auto.sh
