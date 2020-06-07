#!/usr/bin/env bash
echo -e '## 1.2 Configure Software Updates ##\n\n'

echo "1.2.2 Ensure GPG keys are configured"
echo "___CHECK___"
actual=$(rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey)
expected='gpg(CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>)'
if [[ "$actual" == *"$expected"* ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "Actual GPG key: $actual"
  echo "___SET___"
  # CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>
  gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
fi
printf "\n\n"
