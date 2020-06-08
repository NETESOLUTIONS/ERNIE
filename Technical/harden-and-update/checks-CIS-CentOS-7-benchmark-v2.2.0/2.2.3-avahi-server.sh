#!/usr/bin/env bash
set -e
set -o pipefail
echo "2.2.3 Ensure Avahi Server is not enabled"
ensure_service_disabled avahi-daemon
