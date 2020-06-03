#!/usr/bin/env bash
echo "3.2.7 Ensure Reverse Path Filtering is enabled"
ensure_kernel_net_param ipv4 conf..rp_filter 1
