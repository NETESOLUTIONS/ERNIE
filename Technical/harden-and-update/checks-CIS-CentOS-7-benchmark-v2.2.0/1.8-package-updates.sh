#!/usr/bin/env bash
echo "1.8 Ensure updates, patches, and additional security software are installed"

echo "___CHECK___"
echo "Checking for all package security patch updates, excluding Jenkins. Please, wait..."
if yum check-update --security --exclude=jenkins --quiet; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  ACCEPT_EULA=Y yum -y update --security --exclude=jenkins
fi
printf "\n\n"
