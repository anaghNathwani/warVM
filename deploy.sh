#!/usr/bin/env bash
# WarVM — one-shot cloud deploy helper
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log()  { echo -e "${GREEN}[WarVM]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()  { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ---- Pre-flight checks ----
command -v docker      &>/dev/null || die "Docker not found. Install Docker Engine first."
command -v docker compose &>/dev/null 2>&1 || \
  command -v docker-compose &>/dev/null    || die "docker compose not found."

# KVM availability
if [ ! -e /dev/kvm ]; then
  warn "/dev/kvm not found — VM will run in software emulation (slow)."
  warn "On a VPS, enable nested virtualisation or use a bare-metal host."
  # Patch compose to remove kvm device requirement
  sed -i 's|      - /dev/kvm||g' docker-compose.yml
fi

# ---- Optional: self-signed TLS cert ----
if [ ! -f nginx/certs/server.crt ]; then
  log "Generating self-signed TLS certificate..."
  mkdir -p nginx/certs
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout nginx/certs/server.key \
    -out    nginx/certs/server.crt \
    -subj   "/CN=warvm/O=WarVM/C=US" 2>/dev/null
  log "Cert written to nginx/certs/"
fi

# ---- Pull images ----
log "Pulling Docker images (this may take a while)..."
docker compose pull

# ---- Start stack ----
log "Starting WarVM stack..."
docker compose up -d

HOST_IP=$(hostname -I | awk '{print $1}')
log "========================================"
log "  WarVM is starting up!"
log "  Web UI  →  http://${HOST_IP}/vm/"
log "  Landing →  http://${HOST_IP}/"
log "  RDP     →  ${HOST_IP}:3389"
log "  Creds   →  User / WarThunder1!"
log ""
log "  Windows 11 first-boot takes ~5-10 min."
log "  Chrome + War Thunder auto-install after."
log "========================================"
