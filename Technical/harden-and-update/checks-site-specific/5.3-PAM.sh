#!/usr/bin/env bash
echo -e '## 5.3 Configure PAM ##\n\n'

echo "5.3.1 Ensure password creation requirements are configured"
echo "____CHECK____"
# Site-specific policy
PWD_CREATION_REQUIREMENTS="password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 \
authtok_type= ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1"
# TBD Recommendations use `/etc/pam.d/password-auth` and `/etc/pam.d/system-auth`
ensure /etc/pam.d/system-auth-ac 'pam_pwquality.so' "${PWD_CREATION_REQUIREMENTS}"
printf "\n\n"

echo "5.3.3 Ensure password reuse is limited"
echo "___CHECK___"
# TBD Recommendations use `/etc/pam.d/password-auth` and `/etc/pam.d/system-auth`
ensure /etc/pam.d/system-auth-ac '^password.*remember=5'
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
