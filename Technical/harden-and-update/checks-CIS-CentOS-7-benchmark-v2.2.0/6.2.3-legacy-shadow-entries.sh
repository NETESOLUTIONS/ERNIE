#!/usr/bin/env bash
echo '6.2.3 Ensure no legacy "+" entries exist in /etc/shadow'
echo "____CHECK____"
ensure_not /etc/shadow '^\+:'
printf "\n\n"