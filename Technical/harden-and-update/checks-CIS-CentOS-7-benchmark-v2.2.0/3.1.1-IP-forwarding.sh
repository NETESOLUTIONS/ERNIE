#!/usr/bin/env bash
echo -e '## 3.1 Network Parameters (Host Only) ##\n\n'

echo "3.1.1 Ensure IP forwarding is disabled"
ensure_kernel_net_param ipv4 ip_forward 0

