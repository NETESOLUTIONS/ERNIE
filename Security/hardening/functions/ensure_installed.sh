#!/usr/bin/env bash

########################################################################################################################
# Check and install package(s)
#
# Arguments:
#   $@  YUM package(s)
#
# Examples:
#   ensure_installed ntp
#   ensure_installed tcp_wrappers tcp_wrappers-libs
########################################################################################################################
ensure_installed() {
  local package
  for package in "$@"; do
    echo "___CHECK___"
    if rpm -q "$package"; then
      echo "Check PASSED"
    else
      echo "Check FAILED, correcting ..."
      echo "Package $package should be installed"
      echo "___SET___"
      yum install -y "$package"
    fi
  done
  printf "\n\n"
}