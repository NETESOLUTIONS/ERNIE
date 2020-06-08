#!/usr/bin/env bash

########################################################################################################################
# Check and set a kernel (`sysctl`) parameter
#
# Arguments:
#   $1  parameter
#   $2  expected value
#   $3  optional: additional correction ({flag}={value})
#
# Examples:
#   ensure_kernel_param fs.suid_dumpable 0
#   ensure_kernel_param net.ipv4.ip_forward 0 net.ipv4.route.flush=1
########################################################################################################################
ensure_kernel_param() {
  local param="$1"
  local expected="$param = ${2}"
  local additional_correction="${3}"
  # shellcheck disable=SC2155
  local actual=$(sysctl "$param")
  if [[ "$actual" == "$expected" ]]; then
    echo "Check PASSED"
  else
    echo "Check FAILED"
    echo "The actual value: '$actual'"

    echo "Correcting ..."
    echo "___SET___"
    # Spaces must be removed when setting the active kernel parameters: e.g. `sysctl -w net.ipv4.ip_forward=0`
    sysctl -w "${expected// /}"
    [[ $additional_correction ]] && sysctl -w "$additional_correction"
    upsert /etc/sysctl.conf "^$param" "$expected"
  fi
}
export -f ensure_kernel_param

