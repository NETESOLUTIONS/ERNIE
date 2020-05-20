#!/usr/bin/env bash

########################################
# Check and uninstall a package
# Arguments:
#   $1  YUM package name
# Returns:
#   None
# Examples:
#   uninstall '3.9 Remove DNS Server' bind
########################################
ensure_installed() {
  set -e
  set -o pipefail

  local package=$1
  echo "___CHECK___"
  if rpm -q "$package"; then
    echo "Check PASSED"
  else
    echo "Check FAILED, correcting ..."
    echo "Package $package should be installed"
    echo "___SET___"
    yum install -y "$package"
  fi
  printf "\n\n"
}