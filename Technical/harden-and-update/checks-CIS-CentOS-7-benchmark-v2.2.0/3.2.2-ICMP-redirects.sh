#!/usr/bin/env bash
set -e
set -o pipefail
echo "3.2.2 Ensure ICMP redirects are not accepted"
ensure_kernel_net_param ipv4 conf..accept_redirects 0