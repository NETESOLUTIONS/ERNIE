#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '## 5.3 Configure PAM ##\n\n'

# Edit the symlink target files `/etc/pam.d/*-auth-local` rather than `/etc/pam.d/*-auth` symlinks.
# See https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/chap-hardening_your_system_with_tools_and_services

echo "5.3.1 Ensure password creation requirements are configured"
echo "____CHECK____"

if [[ ! -s /etc/pam.d/password-auth-local || ! -s /etc/pam.d/system-auth-local ]]; then
  cat <<HEREDOC
Check FAILED
Create custom authentication settings.
See https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/chap-hardening_your_system_with_tools_and_services for more info.
HEREDOC
  exit 1
fi

# Site-specific policy:
readonly PWD_CFG='password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type='

ensure /etc/pam.d/password-auth-local 'pam_pwquality.so' "$PWD_CFG"
ensure /etc/pam.d/system-auth-local 'pam_pwquality.so' "$PWD_CFG"
ensure /etc/security/pwquality.conf '^minlen' 'minlen = 14'
ensure /etc/security/pwquality.conf '^dcredit' 'dcredit = -1'
ensure /etc/security/pwquality.conf '^lcredit' 'lcredit = -1'
ensure /etc/security/pwquality.conf '^ocredit' 'ocredit = -1'
ensure /etc/security/pwquality.conf '^ucredit' 'ucredit = -1'
printf "\n\n"

echo "5.3.3 Ensure password reuse is limited"
echo "___CHECK___"
ensure /etc/pam.d/password-auth-local '^password\s+sufficient\s+pam_unix.so.*remember=5'
ensure /etc/pam.d/system-auth-local '^password\s+sufficient\s+pam_unix.so.*remember=5'
printf "\n\n"

echo "5.3.4 Ensure password hashing algorithm is SHA-512"
echo "____CHECK____"
if authconfig --test | grep 'password hashing algorithm is sha512'; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  authconfig --passalgo=sha512 --update
fi
printf "\n\n"
