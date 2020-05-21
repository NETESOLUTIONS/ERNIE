#!/usr/bin/env bash
echo "1.4.2 Ensure bootloader password is set"

echo "___CHECK___"
ensure /boot/grub2/grub.cfg "^GRUB2_PASSWORD"
printf "\n\n"