#!/usr/bin/env bash
echo "1.2.3 Obtain Software Package Updates with yum"
echo '(1.2.3 Check that all OS packages are updated)'
echo "___CHECK___"

if ! yum check-update jenkins; then
  # When Jenkins is not installed, this is false
  readonly JENKINS_UPDATE=true
fi

if yum check-update --exclude=jenkins; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  ACCEPT_EULA=Y yum -y update --exclude=jenkins
fi
printf "\n\n"
