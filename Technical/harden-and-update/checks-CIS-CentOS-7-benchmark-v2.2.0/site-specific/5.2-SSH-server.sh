#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '## 5.2 SSH Server Configuration ##\n\n'

# Make sure that new configurations keys are not appended to a conditional block at the end of file
ensure /etc/ssh/sshd_config '^\s*Match All' 'Match All'

echo "5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured"
echo "____CHECK____"
ensure_permissions /etc/ssh/sshd_config
printf "\n\n"

echo "5.2.2 Ensure SSH Protocol is set to 2"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^\s*Protocol.*' 'Protocol 2'
printf "\n\n"

echo "5.2.3 Ensure SSH LogLevel is set to INFO"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^\s*LogLevel' 'LogLevel INFO'
printf "\n\n"

# WARNING: X11 is needed to run DataGrip and other GUI apps on the server
echo "5.2.4 Ensure SSH X11 forwarding is disabled"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^\s*X11Forwarding' 'X11Forwarding no'
printf "\n\n"

echo "5.2.5 Ensure SSH MaxAuthTries is set to 4 or less"
echo "____CHECK____"
# value defaults to 0 when not found
declare -i value=$(pcregrep --only-matching=1 '^MaxAuthTries (.*)' /etc/ssh/sshd_config)
if ((value > 0 && value <= 4)); then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config '#*\s*MaxAuthTries ' 'MaxAuthTries 4'
fi
printf "\n\n"

echo "5.2.6 Ensure SSH IgnoreRhosts is enabled"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^\s*IgnoreRhosts ' 'IgnoreRhosts yes'
printf "\n\n"

echo "5.2.7 Ensure SSH HostbasedAuthentication is disabled"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^\s*HostbasedAuthentication ' 'HostbasedAuthentication no'
printf "\n\n"

echo "5.2.8 Ensure SSH root login is disabled"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^\s*PermitRootLogin ' 'PermitRootLogin no'
printf "\n\n"

echo "5.2.9 Ensure SSH PermitEmptyPasswords is disabled"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^\s*PermitEmptyPasswords ' 'PermitEmptyPasswords no'
printf "\n\n"

echo "5.2.10 Ensure SSH PermitUserEnvironment is disabled"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^\s*PermitUserEnvironment ' 'PermitUserEnvironment no'
printf "\n\n"

echo "5.2.11 Ensure only approved MAC algorithms are used"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^\s*MACs ' "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,\
umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com"
printf "\n\n"

echo "5.2.12 Ensure SSH Idle Timeout Interval is configured"

echo "____CHECK 1/2____"
# Site policy-specific interval (recommended = 300)
ensure /etc/ssh/sshd_config '^\s*ClientAliveInterval ' 'ClientAliveInterval 3600'

echo "____CHECK 2/2____"
ensure /etc/ssh/sshd_config '^\s*ClientAliveCountMax ' 'ClientAliveCountMax 0'

printf "\n\n"

echo "5.2.13 Ensure SSH LoginGraceTime is set to one minute or less"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^\s*LoginGraceTime ' 'LoginGraceTime 60'
printf "\n\n"

echo "5.2.15 Ensure SSH warning banner is configured"
echo "____CHECK____"
if [[ ! -f /etc/issue.ssh ]]; then
    cat > /etc/issue.ssh << 'HEREDOC'
           WARNING ** WARNING ** WARNING ** WARNING ** WARNING

This is a U.S. Government computer system, which may be accessed and used
only for authorized Government business by authorized personnel.
Unauthorized access or use of this computer system may subject violators to
criminal, civil, and/or administrative action.  All information on this
computer system may be intercepted, recorded, read, copied, and disclosed by
and to authorized personnel for official purposes, including criminal
investigations.  Such information includes sensitive data encrypted to comply
with confidentiality and privacy requirements.  Access or use of this computer
system by any person, whether authorized or unauthorized, constitutes consent
to these terms.  There is no right of privacy in this system.

          WARNING ** WARNING ** WARNING ** WARNING ** WARNING

HEREDOC
fi
ensure /etc/ssh/sshd_config '^\s*Banner ' 'Banner /etc/issue.ssh'
printf "\n\n"

# Reload configuration for changes to take effect
systemctl reload sshd
