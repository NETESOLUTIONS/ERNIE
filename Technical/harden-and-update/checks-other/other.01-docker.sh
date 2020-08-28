#!/usr/bin/env bash
set -e
set -o pipefail
if command -v docker; then
  echo "other.01 Docker: remove all unused containers, networks, images"
  echo -e "____CHECK____"

  docker system prune --all
  echo "Check PASSED"
  printf "\n\n"
fi
