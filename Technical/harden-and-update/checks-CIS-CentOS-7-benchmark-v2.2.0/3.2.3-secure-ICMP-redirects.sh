#!/usr/bin/env bash
set -e
set -o pipefail
echo "3.2.3 Ensure secure ICMP redirects are not accepted"
ensure_kernel_net_param ipv4 conf..secure_redirects 0