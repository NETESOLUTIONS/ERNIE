#!/usr/bin/env bash

########################################################################################################################
# Enable script execution via cron (every 10 minutes)
# Prevents multiple executions via `flock`
#
# Globals:
#   $CRON_JOB a full path to the script to be executed
#   $CRON_LOG a full path to the log
#
# Arguments:
#   $*  job parameters
########################################################################################################################
enable_cron_job() {
  if ! crontab -l | grep -F "$CRON_JOB"; then
    echo "Scheduling to check for a safe period every 10 minutes"

    # Append the job to `crontab`
    # Use `flock` to prevent launching of additional processes if the first launch hasn't finished for some reason
    {
      crontab -l
      echo "*/10 * * * * flock --nonblock '$CRON_JOB.lock' sudo '$CRON_JOB' $* >> $CRON_LOG"
    } | crontab -
  fi
}