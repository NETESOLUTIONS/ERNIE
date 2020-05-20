#!/usr/bin/env bash
echo "1.6.3	Enable Randomized Virtual Memory Region Placement"
echo "____CHECK____"
sysctl kernel.randomize_va_space
if [[ "$(sysctl kernel.randomize_va_space)" == "kernel.randomize_va_space = 2" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/kernel.randomize_va_space =/d' /etc/security/limits.conf
  echo "kernel.randomize_va_space = 2" >> /etc/security/limits.conf
fi
printf "\n\n"
