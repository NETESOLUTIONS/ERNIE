#!/usr/bin/env bash
echo "2.2.20 Ensure rsync service is not enabled"
disable_sysv_service rsyncd
