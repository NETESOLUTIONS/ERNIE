#!/usr/bin/env bash
echo -e '## 1.4 Secure Boot Settings ##\n\n'

echo "1.4.1 Ensure permissions on bootloader config are configured"

echo "___CHECK 1/2___"
ensure_permissions /boot/grub2/grub.cfg

echo "___CHECK 2/2___"
ensure_permissions /boot/grub2/user.cfg

printf "\n\n"
