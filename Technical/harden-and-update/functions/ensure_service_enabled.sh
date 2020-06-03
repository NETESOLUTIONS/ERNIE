#!/usr/bin/env bash

########################################
# Check and enable system service
#
# Arguments:
#   $1  service name
#
# Examples:
#   ensure_service_enabled chargen-dgram
########################################
ensure_service_enabled() {
  echo "___CHECK___"
  # If the service is not present, the check fails
  if systemctl is-enabled "$1"; then
#  output=$(systemctl list-unit-files | grep -w $1.service || echo "")
#  if [[ ("${output}") && ("$(systemctl is-enabled $1.service)" != "enabled") ]]; then
    echo "Check PASSED"
  else
    echo "Check FAILED, correcting ..."
    echo "___SET___"
    systemctl enable "$1"
  fi
  printf "\n\n"
}