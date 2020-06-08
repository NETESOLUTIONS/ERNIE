#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '## 3.5 Uncommon Network Protocols ##\n\n'

echo "3.5.1 Ensure DCCP is disabled"
ensure_disabled_kernel_module dccp

echo "3.5.2 Ensure SCTP is disabled"
ensure_disabled_kernel_module sctp

echo "3.5.3 Ensure RDS is disabled"
ensure_disabled_kernel_module rds

echo "3.5.4 Ensure TIPC is disabled"
ensure_disabled_kernel_module tipc