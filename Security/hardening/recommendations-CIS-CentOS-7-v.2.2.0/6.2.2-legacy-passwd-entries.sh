#!/usr/bin/env bash
echo '6.2.2 Ensure no legacy "+" entries exist in /etc/passwd'
echo "____CHECK____"
ensure_not /etc/passwd '^\+:'
printf "\n\n"