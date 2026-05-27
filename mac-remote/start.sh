#!/usr/bin/env bash
# mac-remote/start.sh — start Mac remote access, print a 6-char code
set -euo pipefail

# ── CONFIG ─────────────────────────────────────────────────────────────
# After deploying the relay worker, paste its URL here (no trailing slash)
RELAY_URL=""
# e.g. RELAY_URL="https://warvm-relay.YOUR_NAME.workers.dev"

SITE="https://anaghnathwani.github.io/warVM"
VNC_PORT=5900     # Mac Screen Sharing (VNC) port — do not change
WS_PORT=6080      # websockify WebSocket bridge port
TTL=14400         # code lifetime in seconds (4 hours)
# ────────────────────────────────────────────────────────────────────────

clear
printf '\n'
printf '  ██╗    ██╗ █████╗ ██████╗ ██╗   ██╗███╗   ███╗\n'
printf '  ██║    ██║██╔══██╗██╔══██╗██║   ██║████╗ ████║\n'
printf '  ██║ █╗ ██║███████║██████╔╝██║   ██║██╔████╔██║\n'
printf '  ██║███╗██║██╔══██║██╔══██╗╚██╗ ██╔╝██║╚██╔╝██║\n'
printf '  ╚███╔███╔╝██║  ██║██║  ██║ ╚████╔╝ ██║ ╚═╝ ██║\n'
printf '   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝     ╚═╝\n'
printf '\n'
printf '  Mac Remote Access\n\n'

# ── Config check ──────────────────────────────────────────────────
if [[ -z "$RELAY_URL" ]]; then
  printf '  ERROR: Set RELAY_URL at the top of this script.\n'
  printf '         See mac-remote/README.md for deploy instructions.\n\n'
  exit 1
fi

# ── Dependencies ──────────────────────────────────────────────────
printf '  Checking dependencies...\n'

if ! command -v cloudflared &>/dev/null; then
  printf '  Installing cloudflared via Homebrew...\n'
  brew install cloudflared
fi

if ! python3 -c "import websockify" 2>/dev/null; then
  printf '  Installing websockify...\n'
  pip3 install websockify --user -q
fi

# ── Check Screen Sharing is enabled ──────────────────────────────
if ! nc -z localhost $VNC_PORT 2>/dev/null; then
  printf '\n'
  printf '  ERROR: Screen Sharing is not running on port %d.\n' "$VNC_PORT"
  printf '\n'
  printf '  To enable it:\n'
  printf '    System Settings → General → Sharing\n'
  printf '    → Screen Sharing  →  toggle ON\n'
  printf '    → click "Computer Settings" → set a VNC password\n'
  printf '\n'
  printf '  Then run this script again.\n\n'
  exit 1
fi
printf '  ✔  Screen Sharing is active on port %d\n' "$VNC_PORT"

# ── Kill any stale processes ──────────────────────────────────────
pkill -f "websockify.*$WS_PORT"       2>/dev/null || true
pkill -f "cloudflared tunnel"          2>/dev/null || true
sleep 0.5

# ── websockify: bridge VNC TCP → WebSocket ────────────────────────
printf '  Starting WebSocket bridge (port %d)...\n' "$WS_PORT"
python3 -m websockify --daemon --log-file /tmp/warvm-ws.log \
  $WS_PORT localhost:$VNC_PORT
sleep 1

if ! nc -z localhost $WS_PORT 2>/dev/null; then
  printf '  ERROR: websockify failed. See /tmp/warvm-ws.log\n'
  exit 1
fi
printf '  ✔  WebSocket bridge ready\n'

# ── Cloudflare Quick Tunnel ───────────────────────────────────────
printf '  Starting Cloudflare tunnel...\n'
rm -f /tmp/warvm-cf.log
cloudflared tunnel --url "http://localhost:$WS_PORT" --no-autoupdate \
  >/tmp/warvm-cf.log 2>&1 &
CF_PID=$!

TUNNEL=""
for i in $(seq 1 25); do
  TUNNEL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' \
           /tmp/warvm-cf.log 2>/dev/null | head -1)
  [[ -n "$TUNNEL" ]] && break
  sleep 2
done

if [[ -z "$TUNNEL" ]]; then
  printf '  ERROR: No tunnel URL after 50s.\n'
  printf '  cloudflared log:\n'
  cat /tmp/warvm-cf.log
  exit 1
fi
printf '  ✔  Tunnel: %s\n' "$TUNNEL"

# ── Generate 6-char alphanumeric code ────────────────────────────
CODE=$(LC_ALL=C tr -dc 'A-Z0-9' </dev/urandom | head -c 6)

# ── Register code with relay ──────────────────────────────────────
printf '  Registering code with relay...\n'
HTTP=$(curl -sf -o /dev/null -w '%{http_code}' \
  -X POST "$RELAY_URL/register" \
  -H 'Content-Type: application/json' \
  -d "{\"code\":\"$CODE\",\"url\":\"$TUNNEL\",\"ttl\":$TTL}")

if [[ "$HTTP" != "200" ]]; then
  printf '  ERROR: Relay returned HTTP %s\n' "$HTTP"
  printf '  Check RELAY_URL or redeploy the worker.\n\n'
  exit 1
fi

# ── Print the code ────────────────────────────────────────────────
printf '\n'
printf '  ╔══════════════════════════════════════╗\n'
printf '  ║                                      ║\n'
printf '  ║   Your access code:                  ║\n'
printf '  ║                                      ║\n'
printf '  ║        %-6s                         ║\n' "$CODE"
printf '  ║                                      ║\n'
printf '  ╚══════════════════════════════════════╝\n'
printf '\n'
printf '  1. Open on your Chromebook: %s\n' "$SITE"
printf '  2. Enter code: %s\n' "$CODE"
printf '  3. Enter your Mac VNC password when prompted\n'
printf '\n'
printf '  Code valid for 4 hours. Press Ctrl-C to disconnect.\n\n'

# ── Wait / cleanup ────────────────────────────────────────────────
_cleanup() {
  printf '\n  Shutting down...\n'
  kill "$CF_PID" 2>/dev/null || true
  pkill -f "websockify.*$WS_PORT" 2>/dev/null || true
  curl -sf -X DELETE "$RELAY_URL/register/$CODE" &>/dev/null || true
  printf '  Done.\n\n'
}
trap _cleanup EXIT INT TERM

wait "$CF_PID"
