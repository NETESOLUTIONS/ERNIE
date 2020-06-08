#!/usr/bin/env bash
set -e
set -o pipefail
echo "1.5.3 Ensure address space layout randomization (ASLR) is enabled"
echo "____CHECK____"
ensure_kernel_param kernel.randomize_va_space 2
printf "\n\n"
