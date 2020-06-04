#!/usr/bin/env bash
echo '2.2.9 Ensure FTP Server is not enabled'
ensure_service_disabled vsftpd
