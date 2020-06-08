#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '### Warning Banners ###\n\n'

echo "1.7.1.1 Ensure message of the day is configured properly"
echo "___CHECK___"
ensure_not /etc/motd '(\\v\|\\r\|\\m\|\\s)'
printf "\n\n"

echo "1.7.1.2 Ensure local login warning banner is configured properly"
echo "___CHECK___"
ensure_not /etc/issue '(\\v\|\\r\|\\m\|\\s)'
printf "\n\n"

echo "1.7.1.3 Ensure remote login warning banner is configured properly"
echo "___CHECK___"
ensure_not /etc/issue.net '(\\v\|\\r\|\\m\|\\s)'
printf "\n\n"

echo "1.7.1.4 Ensure permissions on /etc/motd are configured"
echo "___CHECK__"
ensure_permissions /etc/motd 644
printf "\n\n"

echo "1.7.1.5 Ensure permissions on /etc/issue are configured"
echo "___CHECK__"
ensure_permissions /etc/issue 644
printf "\n\n"

echo "1.7.1.6 Ensure permissions on/etc/issue.net are configured"
echo "___CHECK__"
ensure_permissions /etc/issue.net 644
printf "\n\n"
