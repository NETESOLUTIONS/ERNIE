#!/usr/bin/env bash

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
  set -e
  set -o pipefail

  local msg=$1
  local package=$2
  echo "$msg: package $package should not be installed"
  echo "___CHECK___"
  if ! rpm -q "$package"; then
    echo "Check PASSED"
  else
    echo "Check FAILED, correcting ..."
    echo "___SET___"
    yum autoremove -y "$package"
  fi
  printf "\n\n"
}