#!/usr/bin/env bash
set -e
set -o pipefail
echo "1.4.3 Ensure authentication required for single user mode"

# /sbin is sym-linked to /usr/sbin
readonly SU_MODE_SRV_EXEC="ExecStart=-/bin/sh -c \"/usr/sbin/sulogin; /usr/bin/systemctl --fail --no-block default\""

echo "___CHECK 1/2___"
ensure /usr/lib/systemd/system/rescue.service "^ExecStart=" "$SU_MODE_SRV_EXEC"

echo "___CHECK 2/2___"
ensure /usr/lib/systemd/system/emergency.service "^ExecStart=" "$SU_MODE_SRV_EXEC"

printf "\n\n"