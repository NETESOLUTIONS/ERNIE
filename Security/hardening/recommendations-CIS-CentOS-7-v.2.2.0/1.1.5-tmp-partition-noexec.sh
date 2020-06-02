#!/usr/bin/env bash
echo '1.1.5 Ensure noexec option set on /tmp partition'

echo "___CHECK___"
ensure /etc/fstab '/tmp.*noexec'
printf "\n\n"