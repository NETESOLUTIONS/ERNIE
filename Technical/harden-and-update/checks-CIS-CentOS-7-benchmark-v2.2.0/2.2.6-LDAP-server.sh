#!/usr/bin/env bash
set -e
set -o pipefail
echo "2.2.6 Ensure LDAP server is not enabled"
ensure_service_disabled slapd