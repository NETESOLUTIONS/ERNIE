#!/usr/bin/env bash
echo "6.1.13 Audit SUID executables"
# TODO Disk scanning takes significant time. This could be halved by combining SUID and SGID checks.
ensure_whitelisting_of_special_file_perm 4000 SUID