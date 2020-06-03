#!/usr/bin/env bash
echo "3.2.8 Ensure TCP SYN Cookies is enabled"
ensure_kernel_net_param ipv4 tcp_syncookies 1
