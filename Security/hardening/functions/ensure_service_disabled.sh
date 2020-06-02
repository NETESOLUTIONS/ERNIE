#!/usr/bin/env bash

########################################
# disable system service
# Arguments:
#   $1  service name
# Returns:
#   None
# Examples:
#   ensure_service_disabled chargen-dgram
########################################
ensure_service_disabled() {
  echo "___CHECK___"
  if systemctl is-enabled "$1"; then
#  output=$(systemctl list-unit-files | grep -w $1.service || echo "")
#  if [[ ${output} && "$(systemctl is-enabled $1.service)" == "enabled" ]]; then
    echo "Check FAILED, correcting ..."
    echo "___SET___"
    systemctl disable "$1"
  else
    echo "Check PASSED"
  fi
  printf "\n\n"
}
