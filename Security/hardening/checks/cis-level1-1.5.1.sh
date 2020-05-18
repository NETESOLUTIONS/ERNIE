#!/usr/bin/env bash
echo -e '## Advanced Intrusion Detection Environment (AIDE) ##\n\n'

echo -e '## Configure SELinux ##\n\n'

echo -e '## Secure Boot Settings ##\n\n'

echo "1.5.1 Set User/Group Owner on the boot loader config"
echo "___CHECK___"
BOOT_CONFIG=/etc/grub2.cfg
if stat --dereference --format="%u %g" ${BOOT_CONFIG} | grep "0 0"; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  chown root:root ${BOOT_CONFIG}
fi
printf "\n\n"
