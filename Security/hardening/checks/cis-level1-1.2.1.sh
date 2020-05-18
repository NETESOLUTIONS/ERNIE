#!/usr/bin/env bash
echo -e '## Configure Software Updates ##\n\n'

echo "1.2.1 Verify CentOS GPG Key is Installed"
echo "___CHECK___"
rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey
matches=$(rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey)
b='gpg(CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>) gpg(OpenLogic Inc (OpenLogic RPM Development) <support@openlogic.com>)'
if [[ "$(echo $matches)" == *"$b"* ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
fi
printf "\n\n"
