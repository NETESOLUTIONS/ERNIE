#!/usr/bin/env bash
echo "3.2.6 Ensure bogus ICMP responses are ignored"
ensure_kernel_net_param ipv4 icmp_ignore_bogus_error_responses 1
