#!/usr/bin/env bash
echo "2.2.16 Ensure NIS Server is not enabled"
disable_sysv_service ypserv
