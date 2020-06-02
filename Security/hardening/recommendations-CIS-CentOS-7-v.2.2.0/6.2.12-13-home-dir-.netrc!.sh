#!/usr/bin/env bash
echo "6.2.12 Ensure no users have .netrc files"
# 6.2.13 is ensured by 6.2.12
echo "6.2.13 Ensure users' .netrc Files are not group or world accessible"
ensure_no_home_dir_files .netrc