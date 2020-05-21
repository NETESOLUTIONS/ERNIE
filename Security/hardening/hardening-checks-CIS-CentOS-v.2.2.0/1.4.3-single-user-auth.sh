#!/usr/bin/env bash
echo "1.4.3 Ensure authentication required for single user mode"

pattern='/sbin/sulogin'
expected='ExecStart=-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'

echo "___CHECK 1/2___"
ensure /usr/lib/systemd/system/rescue.service "$pattern" "$expected"

echo "___CHECK 2/2___"
ensure /usr/lib/systemd/system/emergency.service "$pattern" "$expected"

printf "\n\n"