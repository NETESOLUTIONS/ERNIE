#!/usr/bin/env bash
set -e
set -o pipefail
echo "2.2.21 Ensure talk server is not enabled"
ensure_service_disabled ntalk
