# Automated data ETL process
Code related to Clinical Trials data automated ETL process.

## Scripts


`createtable_new_ct_tables.sql`: create new children tables: new_ct_*.

`ct_update_auto.sh`: main script for downloading data, parsing, loading, and updating in dev server.

`ct_xml_update_parser.py`: parse XML files to CSV format.

`ct_update_tables.sql`: update tables with new records.
