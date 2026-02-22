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
```

Prerequisites
Proxmox LXC settings

Set these on the container:

nesting=1

keyctl=1

Enable TUN passthrough in /etc/pve/lxc/<CTID>.conf on the Proxmox host:

lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net dev/net none bind,create=dir
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file

If /dev/net/tun is missing on the Proxmox host:

modprobe tun

Reboot the container:

pct reboot <CTID>

Verify inside the LXC:

ls -l /dev/net/tun
Quick start (first build)
1) Bootstrap Ubuntu 24 LXC

Run from repo root inside the LXC:

sudo bash scripts/bootstrap-ubuntu24.sh raiyan

Then refresh shell group membership:

newgrp docker
2) Create folder structure
sudo bash scripts/create-folders.sh /srv/media raiyan raiyan
3) Copy compose files

Put these files in /srv/media/compose/:

docker-compose.yml

.env (real secrets, not committed)

4) Start the stack
cd /srv/media/compose
docker compose up -d
5) Check status
docker compose ps
docker compose logs -f gluetun

Look for a Gluetun line showing a public IP (Mullvad IP).

Environment variables

Create /srv/media/compose/.env:

PUID=1000
PGID=1000
TZ=Europe/London

MULLVAD_WG_PRIVATE_KEY=REPLACE_ME
MULLVAD_WG_ADDRESS=10.x.x.x/32
MULLVAD_CITY=London

Notes:

MULLVAD_WG_PRIVATE_KEY and MULLVAD_WG_ADDRESS come from the Mullvad WireGuard config export

Do not commit .env to git

App URLs

Find LXC IP:

hostname -I

Then open:

qBittorrent: http://<LXC-IP>:8080

Sonarr: http://<LXC-IP>:8989

Radarr: http://<LXC-IP>:7878

Prowlarr: http://<LXC-IP>:9696

Bazarr: http://<LXC-IP>:6767

Jellyseerr: http://<LXC-IP>:5055

First-time app setup
qBittorrent

Change temporary admin password

Set default save path: /downloads/torrent

Create categories:

tv -> /downloads/torrent/tv

movies -> /downloads/torrent/movies

Sonarr

Root folder: /data/tv

qBittorrent download client:

Host: gluetun

Port: 8080

Category: tv

Radarr

Root folder: /data/movies

qBittorrent download client:

Host: gluetun

Port: 8080

Category: movies

Prowlarr

Add indexers

Add apps:

Sonarr -> http://sonarr:8989

Radarr -> http://radarr:7878

Why qBittorrent host is gluetun

qBittorrent uses:

network_mode: "service:gluetun"

This means qBittorrent shares Gluetun's network stack, so Sonarr/Radarr should connect to qBittorrent via:

Host: gluetun

Port: 8080

Scripts
Bootstrap host
sudo bash scripts/bootstrap-ubuntu24.sh raiyan
Create folders
sudo bash scripts/create-folders.sh /srv/media raiyan raiyan
Backup compose + app config
bash scripts/backup-config.sh
Restore compose + app config
bash scripts/restore-config.sh /path/to/media-config-YYYY-MM-DD-HHMMSS.tar.gz
Update stack
bash scripts/update-stack.sh
Health check (optional script)
bash scripts/check-stack.sh
Backup strategy

Minimum recommended backup:

/srv/media/compose

/srv/media/config

Optional backups:

/srv/media/data (media library)

/srv/media/downloads (temporary data)

Tip:
Copy backups off the LXC to a NAS or another node.

Rebuild on a new node
Rebuild workflow

Create new Proxmox LXC (Ubuntu 24)

Enable nesting=1, keyctl=1

Add TUN passthrough lines in LXC config

Reboot LXC and verify /dev/net/tun

Clone this repo

Run bootstrap-ubuntu24.sh

Run create-folders.sh

Copy docker-compose.yml and .env to /srv/media/compose

Restore config backup

Start stack with docker compose up -d

This restores most UI settings from the app config folders.

Troubleshooting
Gluetun fails with /dev/net/tun: no such file or directory

Fix TUN passthrough in Proxmox LXC config and reboot the container.

Sonarr/Radarr cannot connect to qBittorrent

Use:

Host: gluetun

Port: 8080

Do not use qbittorrent when qBittorrent is sharing Gluetun's network.

Permission errors during import

Run:

sudo chown -R raiyan:raiyan /srv/media
sudo find /srv/media -type d -exec chmod 775 {} \;
sudo find /srv/media -type f -exec chmod 664 {} \;
qBittorrent WebUI password unknown

Check logs:

docker compose logs qbittorrent | grep -i -E "password|temporary"
Confirm VPN is active
docker compose logs gluetun | tail -50
docker exec gluetun wget -qO- ifconfig.io

The IP should be a Mullvad IP, not your home ISP IP.

Git and secrets

Commit:

docker-compose.yml

.env.example

scripts/

docs/

Do not commit:

.env

/srv/media/config

/srv/media/data

/srv/media/downloads

Example .gitignore:

**/.env
backups/
tmp/
Future improvements

Add Jellyfin for streaming

Add Tailscale for remote access

Add Recyclarr for quality profile automation

Add Ansible for full host setup automation

Add Proxmox Terraform provider for LXC provisioning

Notes

Keep container paths stable (/downloads, /data) to avoid path migration issues

Back up /srv/media/config before major upgrades

Pin Docker image versions once stable for repeatable rebuilds