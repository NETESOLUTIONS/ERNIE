#!/usr/bin/env bash
set -e
set -o pipefail
echo "6.2.14 Ensure no users have .rhosts files"
ensure_no_home_dir_files .rhosts