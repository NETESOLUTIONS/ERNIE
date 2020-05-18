#!/usr/bin/env bash
echo "1.5.2 Set Permissions on the boot loader config"
echo "___CHECK___"
if stat --dereference --format="%a" ${BOOT_CONFIG} | grep ".00"; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  chmod og-rwx ${BOOT_CONFIG}
fi
printf "\n\n"
