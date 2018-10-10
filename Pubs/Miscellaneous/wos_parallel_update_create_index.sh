#!/usr/bin/env bash
# Parallel index generating on temp tables.
# Author: Samet Keserci,
# Create Date: 08/11/2017
# Modified from serial loading process.

set -xe
set -o pipefail

parallel --halt soon,fail=1 "Job [s {%}]
  psql -c 'CREATE INDEX temp_update_wosid_idx{} ON temp_update_wosid_{} USING HASH (source_id) TABLESPACE index_tbs;'" \
  ::: 1 2 3 4