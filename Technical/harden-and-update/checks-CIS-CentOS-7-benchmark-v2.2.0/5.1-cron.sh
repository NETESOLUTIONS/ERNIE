#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '# 5 Access, Authentication and Authorization #\n\n'

echo -e '## 5.1 Configure cron ##\n\n'

echo "5.1.1 Ensure cron daemon is enabled"
ensure_service_enabled crond

echo "5.1.2 Ensure permissions on /etc/crontab are configured"
echo "___CHECK___"
ensure_permissions /etc/crontab
printf "\n\n"

echo "5.1.3 Ensure permissions on /etc/cron.hourly are configured"
echo "___CHECK___"
ensure_permissions /etc/cron.hourly 700
printf "\n\n"

echo "5.1.4 Ensure permissions on /etc/cron.daily are configured"
echo "___CHECK___"
ensure_permissions /etc/cron.daily 700
printf "\n\n"

echo "5.1.5 Ensure permissions on /etc/cron.weekly are configured"
echo "___CHECK___"
ensure_permissions /etc/cron.weekly 700
printf "\n\n"

echo "5.1.6 Ensure permissions on /etc/cron.monthly are configured"
echo "___CHECK___"
ensure_permissions /etc/cron.monthly 700
printf "\n\n"

echo "5.1.7 Ensure permissions on /etc/cron.d are configured"
echo "___CHECK___"
ensure_permissions /etc/cron.d 700
printf "\n\n"

echo "5.1.8 Ensure at/cron is restricted to authorized users"

echo "___CHECK 1/4___"
ensure_no_file /etc/cron.deny

echo "___CHECK 2/4___"
ensure_no_file /etc/at.deny

echo "___CHECK 3/4___"
ensure_permissions /etc/cron.allow

echo "___CHECK 4/4___"
ensure_permissions /etc/at.allow

printf "\n\n"
