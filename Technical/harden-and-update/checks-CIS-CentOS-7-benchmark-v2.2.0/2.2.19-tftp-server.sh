#!/usr/bin/env bash
set -e
set -o pipefail
echo "2.2.19 Ensure tftp server is not enabled"
ensure_service_disabled tftp.socket
