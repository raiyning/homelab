# Media Stack on Kubernetes (Homelab)

## Overview

This document describes the setup of a self-hosted media stack
(Jellyfin, qBittorrent, Sonarr, Radarr, Prowlarr) running on a
Kubernetes homelab cluster.

The goal was to:
- Use a single large 4 TB disk for media
- Avoid distributed storage (Longhorn) for large files
- Keep the setup simple, debuggable, and reproducible
  

## Hardware & Node Layout

### Nodes
- rpi5: control-plane
- mbp13-2015: worker, primary media storage (4 TB USB HDD)
- laptop-samsung: worker (no media storage)

### Node labels
The media storage node is labeled:

kubectl label node mbp13-2015 media-storage=true

## Storage Architecture Decisions

### Why hostPath for media?
- Media files are large, sequential, and non-HA-critical
- Longhorn adds replication overhead and complexity
- The 4 TB disk is physically attached to one node

### What uses hostPath
- /downloads
- /tv
- /movie
- /appdata/* (config where needed)

### What does NOT use PVCs
- Media libraries (TV / Movies)


## Final Directory Layout
```
/mnt/media
├── downloads
├── tv
├── movie
└── appdata
    ├── jellyfin
    ├── radarr
    ├── sonarr
    └── qbittorrent
```
Permissions:
``` bash
chown -R 1000:1000 /mnt/media
chmod -R 775 /mnt/media
```
## Application Configuration
  - Jellyfin
      - Node: mbp13-2015
      - Mounts:
          - /mnt/media/tv     → /tv (read-only)
          - /mnt/media/movie  → /movie (read-only)
      - Config: PVC or hostPath
  - qBittorrent
      - Download path: /downloads
      - Categories:
        - tv
        - movie
      - Category save paths: left blank
  - Sonarr
      - Root folder: /tv
      - Download client category: tv
      - No remote path mappings
  - Radarr
      - Root folder: /movie
      - Download client category: movie
      - No remote path mappings
  - Prowlarr
      - Manages indexers for Sonarr and Radarr
      - Sync enabled for RSS and Automatic Search
## Networking & Access

### Local testing
- kubectl port-forward for quick tests
- NodePort preferred for mobile apps (more stable)

### iOS Jellyfin app
- Use Node IP + NodePort
- Port-forward may log "broken pipe" errors (harmless)
  
## Common Pitfalls & Fixes

## Common Pitfalls & Fixes

### 1. Pods scheduled on wrong node
Cause:
- nodeSelector overwritten by duplicate YAML keys

Fix:
- Ensure a single `pod:` block in Helm values
- Use nodeSelector: media-storage=true

### 2. hostPath mounted but showing small disk
Cause:
- Pod scheduled on node without the disk
- Kubernetes created /mnt/media on root filesystem

Fix:
- Pin pods to mbp13-2015
- Verify with `df -h` inside the container

### 3. PVC prevents pod scheduling
Cause:
- local-path PVC bound to old node
- nodeSelector forces pod to new node

Fix:
- Migrate config from PVC → hostPath
- Or recreate PVC after pinning node

### 4. Radarr cannot write to /movie
Cause:
- /movie not actually mounted (rootfs)
- Permissions mismatch

Fix:
- Verify mount source with `mount | grep /movie`
- Ensure PUID/PGID = 1000


## Backup & Recovery Strategy
## Reprovisioning Checklist
