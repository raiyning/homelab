#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${1:-/srv/media}"
OWNER_USER="${2:-raiyan}"
OWNER_GROUP="${3:-raiyan}"

echo "Creating folder structure under ${BASE_DIR}..."

mkdir -p "${BASE_DIR}/compose"
mkdir -p "${BASE_DIR}/config"/{gluetun,qbittorrent,sonarr,radarr,prowlarr,bazarr,jellyseerr}
mkdir -p "${BASE_DIR}/downloads"/{torrent,usenet}
mkdir -p "${BASE_DIR}/data"/{movies,tv,music,books}
mkdir -p "${BASE_DIR}/backups"

chown -R "${OWNER_USER}:${OWNER_GROUP}" "${BASE_DIR}"

echo "Created folders:"
find "${BASE_DIR}" -maxdepth 2 -type d | sort

echo
echo "Done. Next:"
echo "  - Put docker-compose.yml in ${BASE_DIR}/compose"
echo "  - Put .env in ${BASE_DIR}/compose"
echo "  - Start stack: cd ${BASE_DIR}/compose && docker compose up -d"