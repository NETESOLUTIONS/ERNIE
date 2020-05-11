echo -e '## Install Updates, Patches and Additional Security Software ##\n\n'

yum clean expire-cache

echo '1.0.7 Use the Latest OS Kernel'
echo '(1.2.3 Check that all OS packages are updated)'
# Install an updated kernel package if available
yum --enablerepo=elrepo-kernel install -y kernel-ml python-perf

kernel_version=$(uname -r)
latest_kernel_package_version=$(rpm --query --last kernel-ml | head -1 | pcregrep -o1 'kernel-ml-([^ ]*)')
# RPM can't format --last output and
#available_kernel_version=$(rpm --query --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-ml)

if [[ ${kernel_version} == ${latest_kernel_package_version} ]]; then
  echo "Check PASSED"
  notify "Hardening: kernel check" "The kernel version is up to date: v${kernel_version}"
else
  readonly KERNEL_UPDATE=true
  echo "Check FAILED, correcting ..."
  echo "___SET___"

  # Keep 2 kernels including the current one
  package-cleanup -y --oldkernels --count=2

  grub2-set-default 0
  grub2-mkconfig -o /boot/grub2/grub.cfg
fi

if ! yum check-update jenkins; then
  # When Jenkins is not installed, this is false
  readonly JENKINS_UPDATE=true
fi
