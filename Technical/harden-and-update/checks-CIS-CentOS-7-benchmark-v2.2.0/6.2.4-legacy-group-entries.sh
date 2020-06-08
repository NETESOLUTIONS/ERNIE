#!/usr/bin/env bash
set -e
set -o pipefail
echo '6.2.4 Ensure no legacy "+" entries exist in /etc/group'
echo "____CHECK____"
ensure_not /etc/group '^\+:'
printf "\n\n"