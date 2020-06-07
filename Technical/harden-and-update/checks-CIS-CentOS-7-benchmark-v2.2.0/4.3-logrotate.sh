#!/usr/bin/env bash
set -e
set -o pipefail
# The configuration below is site policy and is not specified by the benchmark
echo "4.3 Ensure logrotate is configured"

echo "___CHECK 1/6___"
ensure /etc/logrotate.d/syslog '^/var/log/cron' /var/log/cron ^

echo "___CHECK 2/6___"
ensure /etc/logrotate.d/syslog '^/var/log/maillog' /var/log/maillog ^

echo "___CHECK 3/6___"
ensure /etc/logrotate.d/syslog '^/var/log/messages' /var/log/messages ^

echo "___CHECK 4/6___"
ensure /etc/logrotate.d/syslog '^/var/log/secure' /var/log/secure ^

echo "___CHECK 5/6___"
ensure /etc/logrotate.d/syslog '^/var/log/boot.log' /var/log/boot.log ^

echo "___CHECK 6/6___"
ensure /etc/logrotate.d/syslog '^/var/log/spooler' /var/log/spooler ^

printf "\n\n"