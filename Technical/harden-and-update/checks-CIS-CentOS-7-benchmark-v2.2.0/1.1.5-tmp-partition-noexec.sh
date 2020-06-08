#!/usr/bin/env bash
set -e
set -o pipefail
echo '1.1.5 Ensure noexec option set on /tmp partition'

echo "___CHECK___"
ensure_mount_option /tmp noexec
printf "\n\n"