#!/usr/bin/env bash
set -ex

# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
absolute_script_dir=$(cd "${script_dir}" && pwd)

echo '1.0.7 Use the Latest OS Kernel'
echo '(1.2.3 checks that all OS packages are updated)'
# Install an updated kernel package if available
yum --enablerepo=elrepo-kernel install -y kernel-ml python-perf

kernel_version=$(uname -r)
last_installed_kernel_package=$(rpm --query --last kernel-ml | head -1 | pcregrep -o1 'kernel-ml-([^ ]*)')
# RPM can't format --last output and
#available_kernel_version=$(rpm --query --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-ml)
if [[ ${kernel_version} == ${last_installed_kernel_package} ]]; then
  echo "Check PASSED"
  echo "Sending email notification..."
  printf "Kernel version was checked and is up-to-date\n Current version: ${kernel_version}" | mailx -S smtp=localhost -s "Hardening: kernel check" j1c0b0d0w9w7g7v2@neteteam.slack.com
  echo "Disabling cron job..."
  ( crontab -l | grep -v -F "$absolute_script_dir/update_and_reboot_ernie.sh >> $absolute_script_dir/log/reboot.log" ) | crontab -   
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  # Keep 2 kernels including the current one
  package-cleanup -y --oldkernels --count=2

  grub2-set-default 0
  grub2-mkconfig -o /boot/grub2/grub.cfg

  ## Wait loop for running sql query and end-user linux process##
  if [[ $(sudo -u ernie_admin psql ernie -Atf $absolute_script_dir/check_running.sql 2>&1) != "sudo: psql: command not found" ]]; then
    running_postgres_pids=$(sudo -u ernie_admin psql ernie -Atf $absolute_script_dir/check_running.sql) 
  else 
    running_postgres_pids=""
  fi
  jenkins_process_count=$(ps ax o user,group | grep jenkins | wc -l || :)
  remote_server_processes_count=$(ps ax o user | grep ernie_admin | wc -l || :)
  end_user_processes=$(ps ax o group | grep ernieusers || :)

  #If there is no running postgres sql, no other Jenkins job but only Jenkins server, and no end user process
  #Disable cron job from crontab and reboot
  #Otherwise the cron job will check every 10min until the system can be rebooted
  if [[ ${running_postgres_pids} == "" && ${jenkins_process_count} -eq 1 && ${remote_server_processes_count} == 0 && ${end_user_processes} == "" ]];then
    echo "Disabling cron job..."
    ( crontab -l | grep -v -F "$absolute_script_dir/update_and_reboot_ernie.sh >> $absolute_script_dir/log/reboot.log" ) | crontab -
    
    echo "Sending email notification..."
    printf "Kernel updates from:\n Current kernel version: ${kernel_version}\n To\n Latest kernel version: ${last_installed_kernel_package}\n" | mailx -S smtp=localhost -s "Reboot notification" j1c0b0d0w9w7g7v2@neteteam.slack.com
    
    sleep 10
    echo "**Rebooting**, please wait for 2 minutes, then reconnect"
    reboot
  else
    echo "There are running processes, try later..."
    #echo "psql job: ${pid}, # of Jenkins job: ${jenkins_job}, end user job: ${end_user_job}"
    ps -eww -o pid,lstart,args
  fi
fi
printf "\n\n"
