#!/usr/bin/env bash
echo "1.4.3 Ensure authentication required for single user mode"

# /sbin is symlinked to /usr/sbin
expected="ExecStart=-/bin/sh -c \"/usr/sbin/sulogin; /usr/bin/systemctl --fail --no-block default\""

echo "___CHECK 1/2___"
ensure /usr/lib/systemd/system/rescue.service "$absolute_sulogin_filename" "$expected"

echo "___CHECK 2/2___"
ensure /usr/lib/systemd/system/emergency.service "$absolute_sulogin_filename" "$expected"

printf "\n\n"