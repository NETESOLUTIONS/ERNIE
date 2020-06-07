#!/usr/bin/env bash
set -e
set -o pipefail
ensure_uninstalled "2.2.2 Ensure X Window System is not installed" 'xorg-x11*'
