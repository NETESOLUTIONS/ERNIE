#!/usr/bin/env bash
# TBD DISABLED Either ntp or chrony is required.
#   In Red Hat / CentOS 7 ntpd is replaced by chronyd as the default network time protocol daemon.
#   Chronyd is more accurate and smart time sync mechanism.
#   See https://medium.com/@codingmaths/centos-rhel-7-chronyd-v-s-ntp-service-5d65765fdc5f
set -e
set -o pipefail

echo "2.2.1.2 Ensure ntp is configured"

# `restrict default kod nomodify notrap nopeer noquery` = `restrict -4 default kod nomodify notrap nopeer noquery`
# options after default can appear in any order
# FIXME Does not work
# TBD Additional restriction lines may exist. These would fail the check every time, but hardening should succeed.
ensure /etc/ntp.conf '^restrict\s+(-4\s+)?default' 'restrict default kod nomodify notrap nopeer noquery'
ensure /etc/ntp.conf '^restrict\s+-6\s+default' 'restrict -6 default kod nomodify notrap nopeer noquery'
ensure /etc/ntp.conf '^(server|pool)'
# grep "^OPTIONS" /etc/sysconfig/ntpd
#   OPTIONS="-u ntp:ntp"
# grep "^ExecStart" /usr/lib/systemd/system/ntpd.service
#   ExecStart=/usr/sbin/ntpd -u ntp:ntp $OPTIONS

printf "\n\n"