#!/usr/bin/env bash

####################################################
# Check and uninstall a package
#
# Arguments:
#   $1  message
#   $2  YUM package name
#
# Examples:
#   ensure_uninstalled '3.9 Remove DNS Server' bind
####################################################
ensure_uninstalled() {
  set -e
  set -o pipefail

  local msg=$1
  local package=$2
  echo "$msg"
  echo "___CHECK___"
  if ! rpm -q "$package"; then
    echo "Check PASSED"
  else
    echo "Check FAILED, correcting ..."
    echo "Package $package should not be installed"
    echo "___SET___"
    yum autoremove -y "$package"
  fi
  printf "\n\n"
}