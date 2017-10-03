# Parallel index generating on temp tables.
# Author: Samet Keserci,
# Create Date: 08/11/2017
# Modified from serial loading process.

psql -d ernie -c "create index temp_update_wosid_idx1 on temp_update_wosid_1 using hash (source_id) tablespace ernie_index_tbs;" &
psql -d ernie -c "create index temp_update_wosid_idx2 on temp_update_wosid_2 using hash (source_id) tablespace ernie_index_tbs;" &
psql -d ernie -c "create index temp_update_wosid_idx3 on temp_update_wosid_3 using hash (source_id) tablespace ernie_index_tbs;" &
psql -d ernie -c "create index temp_update_wosid_idx4 on temp_update_wosid_4 using hash (source_id) tablespace ernie_index_tbs;" &

wait
