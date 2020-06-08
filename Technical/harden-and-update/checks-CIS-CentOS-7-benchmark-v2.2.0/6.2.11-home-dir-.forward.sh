#!/usr/bin/env bash
set -e
set -o pipefail
echo "6.2.11 Ensure no users have .forward files"
ensure_no_home_dir_files .forward