#!/usr/bin/env bash
set -e
set -o pipefail
########################################
# Check and uninstall a package
# Arguments:
#   $1  message
#   $2  YUM package name
# Returns:
#   None
# Examples:
#   uninstall '3.9 Remove DNS Server' bind
########################################
uninstall() {
  echo "$1: package $2 should not be installed"
  echo "___CHECK___"
  if ! rpm -q $2; then
    echo "Check PASSED"
  else
    echo "Check FAILED, correcting ..."
    echo "___SET___"
    yum autoremove -y $2
  fi
  printf "\n\n"
}