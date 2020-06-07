#!/usr/bin/env bash
set -e
set -o pipefail
echo '2.2.10 Ensure HTTP server is not enabled'
ensure_service_disabled httpd
