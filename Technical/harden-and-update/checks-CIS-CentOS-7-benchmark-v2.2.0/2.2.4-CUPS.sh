#!/usr/bin/env bash
set -e
set -o pipefail
echo "2.2.4 Ensure CUPS is not enabled"
ensure_service_disabled cups
