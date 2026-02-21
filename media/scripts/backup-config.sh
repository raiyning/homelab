#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${1:-/srv/media}"
BACKUP_DIR="${2:-${BASE_DIR}/backups}"

TS="$(date +%F-%H%M%S)"
ARCHIVE="${BACKUP_DIR}/media-config-${TS}.tar.gz"

mkdir -p "${BACKUP_DIR}"

echo "Creating backup archive: ${ARCHIVE}"

tar -czf "${ARCHIVE}" \
  -C "${BASE_DIR}" \
  compose \
  config

echo "Backup complete:"
ls -lh "${ARCHIVE}"

echo
echo "Tip: copy this archive off the LXC to another node/NAS for disaster recovery."