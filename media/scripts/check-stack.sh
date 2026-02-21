#!/usr/bin/env bash
set -euo pipefail

COMPOSE_DIR="${1:-/srv/media/compose}"

cd "${COMPOSE_DIR}"

echo "Container status:"
docker compose ps

echo
echo "Gluetun public IP:"
docker exec gluetun wget -qO- ifconfig.io || true
echo

echo
echo "Recent gluetun logs:"
docker compose logs --tail=20 gluetun