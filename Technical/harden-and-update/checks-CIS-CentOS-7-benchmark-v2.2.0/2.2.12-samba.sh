#!/usr/bin/env bash
set -e
set -o pipefail
echo '2.2.12 Ensure Samba is not enabled'
ensure_service_disabled smb