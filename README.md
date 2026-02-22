# homelab
TODO
git clone git@github-second:raiyning/homelab.git

# Homelab Media Stack

Docker-based Servarr stack running in a Proxmox LXC (Ubuntu 24), with qBittorrent routed through Gluetun using Mullvad WireGuard.

## Stack

- Gluetun (VPN)
- qBittorrent (through Gluetun)
- Sonarr
- Radarr
- Prowlarr
- Bazarr
- Jellyseerr
- (Optional) Jellyfin
- (Optional) Tailscale

---

## Folder layout

Host paths (inside the LXC):

- `/srv/media/compose` -> Docker Compose files
- `/srv/media/config` -> App configs (UI settings, DBs, API keys)
- `/srv/media/downloads` -> Incomplete/completed downloads
- `/srv/media/data` -> Final media library
- `/srv/media/backups` -> Config backups

Example structure:

```text
/srv/media/
├─ compose/
│  ├─ docker-compose.yml
│  └─ .env
├─ config/
│  ├─ gluetun/
│  ├─ qbittorrent/
│  ├─ sonarr/
│  ├─ radarr/
│  ├─ prowlarr/
│  ├─ bazarr/
│  └─ jellyseerr/
├─ downloads/
│  ├─ torrent/
│  └─ usenet/
├─ data/
│  ├─ movies/
│  ├─ tv/
│  ├─ music/
│  └─ books/
└─ backups/