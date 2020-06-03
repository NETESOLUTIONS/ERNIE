#!/usr/bin/env bash
echo -e '## 2.2 Special Purpose Services ##\n\n'

echo "## 2.2.1 Time Synchronization ##"

echo "2.2.1.1 Ensure time synchronization is in use"
ensure_installed ntp

echo "2.2.1.2 Ensure ntp is configured"

# `restrict default kod nomodify notrap nopeer noquery` = `restrict -4 default kod nomodify notrap nopeer noquery`
# options after default can appear in any order
# TBD Additional restriction lines may exist. These would fail the check every time, but hardening should succeed.
ensure /etc/ntp.conf '^restrict.*default' 'restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery'

printf "\n\n"

echo "2.2.1.3 Ensure chrony is configured"
ensure /etc/chrony.conf '^(server|pool)' '*'
