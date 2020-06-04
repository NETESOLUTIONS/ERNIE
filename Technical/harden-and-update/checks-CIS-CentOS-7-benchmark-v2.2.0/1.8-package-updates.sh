#!/usr/bin/env bash
echo "1.8 Ensure updates, patches, and additional security software are installed"

echo "___CHECK___"
yum clean expire-cache
if ! yum check-update jenkins; then
  # When Jenkins is not installed, this is false
  readonly JENKINS_UPDATE=true
fi

if yum check-update --security --exclude=jenkins; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  ACCEPT_EULA=Y yum -y update --security --exclude=jenkins
fi
printf "\n\n"
