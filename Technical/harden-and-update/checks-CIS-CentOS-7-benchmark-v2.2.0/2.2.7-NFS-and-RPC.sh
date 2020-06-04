#!/usr/bin/env bash
echo "2.2.7 Ensure NFS and RPC are not enabled"
ensure_service_disabled nfs
ensure_service_disabled nfs-server
ensure_service_disabled rpcbind
