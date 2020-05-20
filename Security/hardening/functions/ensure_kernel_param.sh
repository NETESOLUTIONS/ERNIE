#!/usr/bin/env bash

########################################
# Ensure kernel (`sysctl`) parameter is set correctly
# Arguments:
#   $1  parameter
#   $2  expected value
# Returns:
#   None
# Examples:
#   ensure_kernel_param fs.suid_dumpable 0
########################################
ensure_kernel_param() {
  set -e
  set -o pipefail

  local param="$1"
  local expected="${2}"
  local actual
  actual=$(sysctl "$param")
  if [[ "$actual" == "$expected" ]]; then
    echo "Check PASSED"
  else
    echo "Check FAILED"
    echo "The actual value for $param: $actual"

    echo "Correcting ..."
    echo "___SET___"
    upsert "^$param" "$param = $expected" /etc/sysctl.conf
    sysctl -w "$param=$expected"
  fi
}
