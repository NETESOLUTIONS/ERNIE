#!/usr/bin/env bash
# TBD DISABLED This might be problematic for VMs
set -e
set -o pipefail
echo "1.4.2 Ensure bootloader password is set"

echo "___CHECK___"
ensure /boot/grub2/grub.cfg "^GRUB2_PASSWORD"
printf "\n\n"