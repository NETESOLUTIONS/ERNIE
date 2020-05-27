#!/usr/bin/env bash
echo "3.2.3 Ensure secure ICMP redirects are not accepted"

echo "____CHECK 1/2____"
ensure_kernel_param net.ipv4.conf.all.secure_redirects 0 net.ipv4.route.flush=1

echo "____CHECK 2/2____"
ensure_kernel_param net.ipv4.conf.default.secure_redirects 0 net.ipv4.route.flush=1

printf "\n\n"