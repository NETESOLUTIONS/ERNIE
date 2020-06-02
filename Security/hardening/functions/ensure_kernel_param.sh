#!/usr/bin/env bash

########################################
# Ensure kernel (`sysctl`) parameter is set correctly
# Arguments:
#   $1  parameter
#   $2  expected value
#   $3  optional: additional correction ({flag}={value})
# Returns:
#   None
# Examples:
#   ensure_kernel_param fs.suid_dumpable 0
#   ensure_kernel_param net.ipv4.ip_forward 0 net.ipv4.route.flush=1
########################################
ensure_kernel_param() {
  local param="$1"
  local expected="${2}"
  local additional_correction="${3}"
  # shellcheck disable=SC2155
  local actual=$(sysctl "$param")
  if [[ "$actual" == "$expected" ]]; then
    echo "Check PASSED"
  else
    echo "Check FAILED"
    echo "The actual value for $param: '$actual'"

    echo "Correcting ..."
    echo "___SET___"
    upsert /etc/sysctl.conf "^$param" "$param = $expected"
    sysctl -w "$param=$expected"
    [[ $additional_correction ]] && sysctl -w "$additional_correction"
  fi
}
