#!/usr/bin/env bash

########################################################################################################################
# Check and disable a kernel module
#
# Arguments:
#   $1 kernel module
#
# Examples:
#   ensure_disabled_kernel_module dccp
########################################################################################################################
ensure_disabled_kernel_module() {
  local kernel_module="$1"
  echo "___CHECK___"

  # `modprobe` might not found such a module and error out with `modprobe: FATAL: Module {module} not found.`
  # The result may include a trailing space, e.g. `install /bin/true `
  # shellcheck disable=SC2155 # intentionally suppressing failures
  local modprobe_actual=$(modprobe -n -v "$kernel_module" 2> /dev/null)
  # shellcheck disable=SC2155 # intentionally suppressing modules not found by `lsmod`
  local lsmod_actual=$(lsmod | grep "$kernel_module")
  if [[ ( ! "$modprobe_actual" || "$modprobe_actual" == "install /bin/true"*( ) ) && ! "$lsmod_actual" ]]; then
    echo "Check PASSED"
  else
    echo "Check FAILED, correcting ..."
    echo "modprobe result: '$modprobe_actual', lsmod result: '$lsmod_actual'"
    echo "___SET___"

    # This command instructs `modprobe` to run `/bin/true` instead of inserting the module in the kernel as normal
    # See `man modprobe.d`
    upsert /etc/modprobe.d/CIS.conf "install $kernel_module" "install $kernel_module /bin/true"
  fi
  printf "\n\n"
}
export -f ensure_disabled_kernel_module

