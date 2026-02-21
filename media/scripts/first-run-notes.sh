#!/usr/bin/env bash
set -euo pipefail

IP="$(hostname -I | awk '{print $1}')"

cat <<EOF
Use these URLs on your LAN:

qBittorrent: http://${IP}:8080
Sonarr:      http://${IP}:8989
Radarr:      http://${IP}:7878
Prowlarr:    http://${IP}:9696
Bazarr:      http://${IP}:6767
Jellyseerr:  http://${IP}:5055

Reminder:
- In Sonarr/Radarr, qBittorrent host should be: gluetun
- qBittorrent port: 8080
EOF