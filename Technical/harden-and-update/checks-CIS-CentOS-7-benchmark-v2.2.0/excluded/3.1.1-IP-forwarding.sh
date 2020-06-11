#!/usr/bin/env bash
# TBD DISABLED This causes a break of functionality in Docker containers (or Docker image builds) that access the Net
# See https://stackoverflow.com/questions/41453263/docker-networking-disabled-warning-ipv4-forwarding-is-disabled-networking-wil
set -e
set -o pipefail
echo -e '## 3.1 Network Parameters (Host Only) ##\n\n'

echo "3.1.1 Ensure IP forwarding is disabled"
ensure_kernel_net_param ipv4 ip_forward 0

