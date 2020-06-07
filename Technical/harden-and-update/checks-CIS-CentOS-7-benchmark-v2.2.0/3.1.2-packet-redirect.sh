#!/usr/bin/env bash
set -e
set -o pipefail
echo "3.1.2 Ensure packet redirect sending is disabled"
ensure_kernel_net_param ipv4 conf..send_redirects 0