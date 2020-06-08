#!/usr/bin/env bash
set -e
set -o pipefail
echo "3.2.7 Ensure Reverse Path Filtering is enabled"
ensure_kernel_net_param ipv4 conf..rp_filter 1
