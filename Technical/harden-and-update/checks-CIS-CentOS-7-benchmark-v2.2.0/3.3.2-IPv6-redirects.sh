#!/usr/bin/env bash
echo "3.3.2 Ensure IPv6 redirects are not accepted"
ensure_kernel_net_param ipv6 conf..accept_redirects 0
