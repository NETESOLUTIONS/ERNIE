#!/usr/bin/env bash
set -e
set -o pipefail
echo "2.2.16 Ensure NIS Server is not enabled"
ensure_service_disabled ypserv
