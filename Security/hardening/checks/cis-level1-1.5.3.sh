#!/usr/bin/env bash
echo "1.5.3 Set Boot Loader Password"
echo "___CHECK___"
matches=$(grep "^password" ${BOOT_CONFIG}) || :
if [[ "$matches" == 'password --md5' || -z "$matches" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED"
  exit 1
#  echo "Check FAILED, correcting ..."
#  echo "___SET___"
#  sed -i '/^password/d' ${BOOT_CONFIG}
#  echo "password --md5 _[Encrypted Password]_" >>${BOOT_CONFIG}
fi
printf "\n\n"
