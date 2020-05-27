#!/usr/bin/env bash
echo -e '## 3.1 Network Parameters (Host Only) ##\n\n'

echo "3.1.1 Ensure IP forwarding is disabled"
echo "____CHECK____"
ensure_kernel_param net.ipv4.ip_forward 0 net.ipv4.route.flush=1
printf "\n\n"
