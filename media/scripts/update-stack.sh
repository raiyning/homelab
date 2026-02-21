#!/usr/bin/env bash
set -euo pipefail

COMPOSE_DIR="${1:-/srv/media/compose}"

cd "${COMPOSE_DIR}"

echo "[1/4] Pulling latest images..."
docker compose pull

echo "[2/4] Recreating containers..."
docker compose up -d

echo "[3/4] Showing status..."
docker compose ps

echo "[4/4] Pruning unused images..."
docker image prune -f

echo "Update complete."