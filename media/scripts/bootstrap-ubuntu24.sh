#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root: sudo bash scripts/bootstrap-ubuntu24.sh"
  exit 1
fi

USERNAME="${1:-raiyan}"

echo "[1/6] Updating apt packages..."
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

echo "[2/6] Installing Docker official GPG key..."
install -m 0755 -d /etc/apt/keyrings
if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
fi

echo "[3/6] Adding Docker apt repository..."
ARCH="$(dpkg --print-architecture)"
CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
cat >/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable
EOF

echo "[4/6] Installing Docker Engine and Compose plugin..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[5/6] Enabling Docker service..."
systemctl enable docker
systemctl start docker

echo "[6/6] Adding user '${USERNAME}' to docker group..."
if id "${USERNAME}" >/dev/null 2>&1; then
  usermod -aG docker "${USERNAME}" || true
  echo "User '${USERNAME}' added to docker group."
else
  echo "User '${USERNAME}' not found, skipping docker group add."
fi

echo
echo "Bootstrap complete."
echo "Next:"
echo "  1) Log out and back in (or run: newgrp docker)"
echo "  2) Run create-folders.sh"
echo "  3) Copy your compose/.env and run docker compose up -d"