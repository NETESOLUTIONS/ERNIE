#!/usr/bin/env bash
set -e
set -o pipefail
echo "2.2.8 Ensure DNS Server is not enabled"
ensure_service_disabled named