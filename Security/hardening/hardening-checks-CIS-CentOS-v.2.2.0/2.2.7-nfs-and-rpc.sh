#!/usr/bin/env bash
echo "2.2.7 Ensure NFS and RPC are not enabled"
disable_sysv_service nfs
disable_sysv_service nfs-server
disable_sysv_service rpcbind
