#!/usr/bin/env bash
echo "3.1.2 Ensure packet redirect sending is disabled"

echo "____CHECK 1/2____"
ensure_kernel_param net.ipv4.conf.all.send_redirects 0 net.ipv4.route.flush=1
echo "____CHECK 2/2____"
ensure_kernel_param net.ipv4.conf.default.send_redirects 0 net.ipv4.route.flush=1

printf "\n\n"