#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '## 1.2 Configure Software Updates ##\n\n'

echo "1.2.2 Ensure GPG keys are configured"
echo "___CHECK___"
readonly GPG_KEY_PACKAGES=$(rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey)
if [[ "$GPG_KEY_PACKAGES" == *"gpg(CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>)"* ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "Actual GPG keys: $GPG_KEY_PACKAGES"
  echo "___SET___"
  # CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>
  gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
fi
printf "\n\n"
