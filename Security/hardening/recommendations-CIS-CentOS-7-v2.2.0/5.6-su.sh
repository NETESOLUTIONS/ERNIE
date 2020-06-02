#!/usr/bin/env bash
echo "5.6 Ensure access to the su command is restricted"
echo "___CHECK___"
ensure /etc/pam.d/su '^#*auth\s+required\s+pam_wheel.so' 'auth\t\trequired\tpam_wheel.so use_uid'
printf "\n\n"