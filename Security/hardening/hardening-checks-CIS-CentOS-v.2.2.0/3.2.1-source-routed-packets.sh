#!/usr/bin/env bash
echo -e '## 3.2 Network Parameters (Host and Router) ##\n\n'

echo "3.2.1 Ensure source routed packets are not accepted"
echo "____CHECK 1/2____"
ensure_kernel_param net.ipv4.conf.all.accept_source_route 0 net.ipv4.route.flush=1

echo "____CHECK 2/2____"
ensure_kernel_param net.ipv4.conf.default.accept_source_route 0 net.ipv4.route.flush=1

printf "\n\n"
