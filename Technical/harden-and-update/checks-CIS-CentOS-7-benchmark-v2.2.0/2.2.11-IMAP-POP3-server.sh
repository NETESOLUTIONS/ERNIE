#!/usr/bin/env bash
set -e
set -o pipefail
echo '2.2.11 Ensure IMAP and POP3 server is not enabled'
ensure_service_disabled dovecot