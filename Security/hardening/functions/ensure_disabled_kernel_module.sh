#!/usr/bin/env bash

####################################################
# Check and disabled a kernel module
# Arguments:
#   $1 kernel module
# Returns:
#   None
# Examples:
#   ensure_disabled_kernel_module dccp
####################################################
ensure_disabled_kernel_module() {
  local kernel_module="$1"
  echo "___CHECK___"
  local modprobe_actual
  modprobe_actual=$(modprobe -n -v "$kernel_module")
  local lsmod_actual=$(lsmod | grep dccp)
  if [[ "$modprobe_actual" == "install /bin/true" && ! "$lsmod_actual" ]]; then
    echo "Check PASSED"
  else
    echo "Check FAILED, correcting ..."
    echo "modprobe result: '$modprobe_actual', lsmod result: '$lsmod_actual'"
    echo "___SET___"

    # This command instructs `modprobe` to run `/bin/true` instead of inserting the module in the kernel as normal
    # See `man modprobe.d`
    upsert "install $kernel_module" "install $kernel_module /bin/true" /etc/modprobe.d/CIS.conf
  fi
  printf "\n\n"
}
