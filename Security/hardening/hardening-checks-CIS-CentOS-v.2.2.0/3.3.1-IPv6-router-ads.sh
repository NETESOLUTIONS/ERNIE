#!/usr/bin/env bash
echo '## 3.3 IPv6 ##'

echo "3.3.1 Ensure IPv6 router advertisements are not accepted"
ensure_kernel_net_param ipv6 conf..accept_ra 0
