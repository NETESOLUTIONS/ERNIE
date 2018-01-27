#!/usr/bin/env bash
# Parallel index generating on temp tables.
# Author: Samet Keserci,
# Create Date: 08/11/2017
# Modified from serial loading process.

set -xe
set -o pipefail

parallel --halt soon,fail=1 "Job [s {%}]
  psql -c "create index temp_update_wosid_idx{} on temp_update_wosid_{} using hash (source_id) tablespace indexes;"" \
  ::: 1 2 3 4