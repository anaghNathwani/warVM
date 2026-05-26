#!/usr/bin/env bash
# WarVM — launch from GitHub Codespaces (or any Linux host)
set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log()  { echo -e "${GREEN}[WarVM]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
info() { echo -e "${CYAN}[INFO]${NC}  $*"; }

echo ""
echo "  ██╗    ██╗ █████╗ ██████╗ ██╗   ██╗███╗   ███╗"
echo "  ██║    ██║██╔══██╗██╔══██╗██║   ██║████╗ ████║"
echo "  ██║ █╗ ██║███████║██████╔╝██║   ██║██╔████╔██║"
echo "  ██║███╗██║██╔══██║██╔══██╗╚██╗ ██╔╝██║╚██╔╝██║"
echo "  ╚███╔███╔╝██║  ██║██║  ██║ ╚████╔╝ ██║ ╚═╝ ██║"
echo "   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝     ╚═╝"
echo ""

if [ ! -e /dev/kvm ]; then
  warn "/dev/kvm not available — VM will use software emulation (expect a slower first boot)."
fi

log "Pulling images and starting Windows 11 VM..."
docker compose up -d --pull missing
echo ""

# ── Codespaces: build public URL and auto-open browser ──────────────────────
if [ -n "$CODESPACE_NAME" ]; then
  DOMAIN="${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-preview.app.github.dev}"
  VM_URL="https://${CODESPACE_NAME}-8006.${DOMAIN}"

  # Make the port public so the browser tab can actually reach it
  if command -v gh &>/dev/null; then
    gh codespace ports visibility 8006:public \
      --codespace "$CODESPACE_NAME" 2>/dev/null \
      && log "Port 8006 set to Public." \
      || warn "Couldn't auto-set port visibility — open the Ports tab and set 8006 to Public."
  else
    warn "gh CLI not found. Open the Ports tab in Codespaces and set port 8006 to Public."
  fi

  echo ""
  echo "  ┌────────────────────────────────────────────────────────────────┐"
  echo "  │                                                                │"
  echo "  │  A browser tab will open automatically when the VM is ready.  │"
  echo "  │  If it doesn't appear, open this URL manually:                │"
  echo "  │                                                                │"
  echo "  │  $VM_URL"
  echo "  │                                                                │"
  echo "  │  First boot: ~10 min (Windows setup + War Thunder install)    │"
  echo "  │  Login: User  |  Password: WarThunder1!                       │"
  echo "  │                                                                │"
  echo "  └────────────────────────────────────────────────────────────────┘"
  echo ""

# ── Plain Linux host: print IP-based URL ────────────────────────────────────
else
  HOST_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
  echo "  ┌──────────────────────────────────────────┐"
  echo "  │  Web UI  →  http://${HOST_IP}:8006       │"
  echo "  │  Landing →  http://${HOST_IP}/           │"
  echo "  │  RDP     →  ${HOST_IP}:3389              │"
  echo "  │  Login: User / WarThunder1!              │"
  echo "  └──────────────────────────────────────────┘"
  echo ""
fi

log "VM is booting. Keep this terminal open while you play."
log "Run './stop.sh' to shut down when you're done."
