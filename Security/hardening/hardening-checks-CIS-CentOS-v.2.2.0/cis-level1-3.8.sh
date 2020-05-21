#!/usr/bin/env bash
echo "3.8 Disable NFS and RPC"
disable_sysv_service nfslock
disable_sysv_service rpcgssd
disable_sysv_service rpcbind
disable_sysv_service rpcidmapd
disable_sysv_service rpcsvcgssd
