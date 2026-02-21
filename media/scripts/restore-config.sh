#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/media-config-YYYY-MM-DD-HHMMSS.tar.gz [base_dir]"
  exit 1
fi

ARCHIVE_PATH="$1"
BASE_DIR="${2:-/srv/media}"

if [[ ! -f "${ARCHIVE_PATH}" ]]; then
  echo "Archive not found: ${ARCHIVE_PATH}"
  exit 1
fi

echo "Restoring ${ARCHIVE_PATH} into ${BASE_DIR} ..."
mkdir -p "${BASE_DIR}"

tar -xzf "${ARCHIVE_PATH}" -C "${BASE_DIR}"

echo "Restore complete."
echo
echo "Restored folders:"
find "${BASE_DIR}" -maxdepth 2 -type d | sort

echo
echo "Next:"
echo "  cd ${BASE_DIR}/compose"
echo "  docker compose up -d"