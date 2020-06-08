#!/usr/bin/env bash
set -e
set -o pipefail
echo "2.2.5 Ensure DHCP Server is not enabled"
ensure_service_disabled dhcpd