#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '## 3.2 Network Parameters (Host and Router) ##\n\n'

echo "3.2.1 Ensure source routed packets are not accepted"
ensure_kernel_net_param ipv4 conf..accept_source_route 0
