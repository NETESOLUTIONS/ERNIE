#!/usr/bin/env bash

########################################################################################################################
# Check and set kernel `net.` parameter or both `.all` and `.default` params
#
# Arguments:
#   $1  protocol: `ipv4` or `ipv6`
#   $2  parameter: in `net.{protocol}.`{parameter}.
#       `..` placeholder is replaced by `.all.` + `.default.`
#   $3  expected value
#
# Examples:
#   ensure_kernel_net_param ipv4 ip_forward 0
#   ensure_kernel_net_param ipv4 conf..log_martians 1
########################################################################################################################
ensure_kernel_net_param() {
  local protocol="$1"
  local param="$2"
  local expected="$3"

  if [[ "$param" != *..* ]]; then
    echo "____CHECK____"
    ensure_kernel_param "net.${protocol}.${param}" "${expected}" net.ipv4.route.flush=1
  else
    echo "____CHECK 1/2____"
    # .all.
    ensure_kernel_param "net.${protocol}.${param/../.all.}" "${expected}"
    echo "____CHECK 2/2____"
    # .default.
    ensure_kernel_param "net.${protocol}.${param/../.default.}" "${expected}" net.ipv4.route.flush=1
  fi
  printf "\n\n"
}
