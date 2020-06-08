#!/usr/bin/env bash
set -e
set -o pipefail
echo '1.1.4 Ensure nosuid option set on /tmp partition'

echo "___CHECK___"
ensure_mount_option /tmp nosuid
printf "\n\n"