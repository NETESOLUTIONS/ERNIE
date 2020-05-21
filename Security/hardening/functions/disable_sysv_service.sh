#!/usr/bin/env bash

########################################
# disable system service
# Arguments:
#   $1  service name
# Returns:
#   None
# Examples:
#   disable_sysv_service chargen-dgram
########################################

disable_sysv_service() {
  echo "___CHECK___"
  # By default, the on and off options affect only runlevels 2, 3, 4, and 5, while reset and reset priorities affect all
  # of the runlevels. The --level option may be used to specify which runlevels are affected.
  # If the service is not present, the check should return success
  output=$(systemctl list-unit-files | grep -w $1.service || echo "")
  if [[ ${output} && "$(systemctl is-enabled $1.service)" == "enabled" ]]; then
    echo "Check FAILED, correcting ..."
    echo "___SET___"
    systemctl disable $1.service
  else
    echo "Check PASSED"
  fi
  printf "\n\n"
}
