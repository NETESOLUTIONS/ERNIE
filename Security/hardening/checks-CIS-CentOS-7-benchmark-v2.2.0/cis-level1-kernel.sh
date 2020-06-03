#!/usr/bin/env bash
echo -e '1.8 Ensure updates, patches, and additional security software are installed'

yum clean expire-cache

echo '1.0.7 Use the Latest OS Kernel'
# Install an updated kernel package if available
yum --enablerepo=elrepo-kernel install -y kernel-ml python-perf

kernel_version=$(uname -r)
latest_kernel_package_version=$(rpm --query --last kernel-ml | head -1 | pcregrep -o1 'kernel-ml-([^ ]*)')
# RPM can't format --last output and
#available_kernel_version=$(rpm --query --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-ml)

if [[ ${kernel_version} == ${latest_kernel_package_version} ]]; then
  echo "Check PASSED"
  if [[ $NOTIFICATION_ADDRESS ]]; then
    echo "The kernel version is up to date: v${kernel_version}" \
        | mailx -S smtp=localhost -s "Hardening: kernel check" "$NOTIFICATION_ADDRESS"
  fi
else
  readonly KERNEL_UPDATE_MESSAGE="Kernel update from v${kernel_version} to v${latest_kernel_package_version}"
  echo "Check FAILED, correcting ..."
  echo "___SET___"

  # Keep 2 kernels including the current one
  package-cleanup -y --oldkernels --count=2

  grub2-set-default 0
  grub2-mkconfig -o /boot/grub2/grub.cfg
fi
