#!/usr/bin/env bash
echo "1.4.3 Ensure authentication required for single user mode"

# /sbin is sym-linked to /usr/sbin
expected="ExecStart=-/bin/sh -c \"/usr/sbin/sulogin; /usr/bin/systemctl --fail --no-block default\""

echo "___CHECK 1/2___"
ensure /usr/lib/systemd/system/rescue.service "^#*ExecStart" "$expected"

echo "___CHECK 2/2___"
ensure /usr/lib/systemd/system/emergency.service "^#*ExecStart" "$expected"

printf "\n\n"