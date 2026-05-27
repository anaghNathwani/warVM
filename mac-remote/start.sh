#!/usr/bin/env bash
# mac-remote/start.sh — start Mac remote access, print a 6-char code

# ── CONFIG ─────────────────────────────────────────────────────────────
RELAY_URL="https://warvm-relay.anaghnathwani.workers.dev"

SITE="https://anaghnathwani.github.io/warVM"
VNC_PORT=5900
WS_PORT=6080
TTL=14400
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

# ── Dependencies ──────────────────────────────────────────────────
printf '  Checking dependencies...\n'

if ! command -v cloudflared &>/dev/null; then
  printf '  Installing cloudflared...\n'
  brew install cloudflared
fi

# Find websockify binary — pip --user installs to ~/.local/bin
WEBSOCKIFY=""
for p in websockify "$HOME/.local/bin/websockify" \
          "$(python3 -m site --user-base 2>/dev/null)/bin/websockify"; do
  if command -v "$p" &>/dev/null 2>&1 || [ -x "$p" ]; then
    WEBSOCKIFY="$p"
    break
  fi
done

if [ -z "$WEBSOCKIFY" ]; then
  printf '  Installing websockify...\n'
  pip3 install websockify --user -q
  WEBSOCKIFY="$HOME/.local/bin/websockify"
fi

# ── Screen Sharing check ──────────────────────────────────────────
if ! nc -z localhost $VNC_PORT 2>/dev/null; then
  printf '\n  ERROR: Screen Sharing is not running on port %d.\n\n' "$VNC_PORT"
  printf '  System Settings → General → Sharing\n'
  printf '  → Screen Sharing ON\n'
  printf '  → Computer Settings → set a VNC password\n\n'
  exit 1
fi
printf '  ✔  Screen Sharing active\n'

# ── Kill stale processes ──────────────────────────────────────────
pkill -f "websockify.*$WS_PORT" 2>/dev/null || true
pkill -f "cloudflared tunnel"   2>/dev/null || true
sleep 0.5

# ── websockify in background (don't use --daemon, manage ourselves) ──
printf '  Starting WebSocket bridge (port %d)...\n' "$WS_PORT"
"$WEBSOCKIFY" "$WS_PORT" "localhost:$VNC_PORT" \
  >/tmp/warvm-ws.log 2>&1 &
WS_PID=$!
sleep 1

if ! nc -z localhost $WS_PORT 2>/dev/null; then
  printf '  ERROR: websockify failed to start.\n'
  cat /tmp/warvm-ws.log
  exit 1
fi
printf '  ✔  WebSocket bridge ready\n'

# ── Cloudflare Quick Tunnel ───────────────────────────────────────
printf '  Starting Cloudflare tunnel (takes ~10s)...\n'
rm -f /tmp/warvm-cf.log
cloudflared tunnel --url "http://localhost:$WS_PORT" --no-autoupdate \
  >/tmp/warvm-cf.log 2>&1 &
CF_PID=$!

TUNNEL=""
for i in $(seq 1 30); do
  TUNNEL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' \
           /tmp/warvm-cf.log 2>/dev/null | head -1)
  [ -n "$TUNNEL" ] && break
  sleep 2
done

if [ -z "$TUNNEL" ]; then
  printf '  ERROR: No tunnel URL after 60s. cloudflared log:\n'
  cat /tmp/warvm-cf.log
  exit 1
fi
printf '  ✔  Tunnel: %s\n' "$TUNNEL"

# ── Generate code ────────────────────────────────────────────────
CODE=$(LC_ALL=C tr -dc 'A-Z0-9' </dev/urandom | head -c 6)

# ── Register with relay ───────────────────────────────────────────
printf '  Registering code...\n'
HTTP=$(curl -s -o /dev/null -w '%{http_code}' \
  -X POST "$RELAY_URL/register" \
  -H 'Content-Type: application/json' \
  -d "{\"code\":\"$CODE\",\"url\":\"$TUNNEL\",\"ttl\":$TTL}")

if [ "$HTTP" != "200" ]; then
  printf '  ERROR: Relay returned HTTP %s\n\n' "$HTTP"
  exit 1
fi

# ── Show code ────────────────────────────────────────────────────
printf '\n'
printf '  ╔══════════════════════════════════════╗\n'
printf '  ║                                      ║\n'
printf '  ║   Your access code:                  ║\n'
printf '  ║                                      ║\n'
printf '  ║        %s                            ║\n' "$CODE"
printf '  ║                                      ║\n'
printf '  ╚══════════════════════════════════════╝\n'
printf '\n'
printf '  Website: %s\n' "$SITE"
printf '  Code:    %s\n' "$CODE"
printf '  VNC pw:  your Mac Screen Sharing password\n'
printf '\n'
printf '  Code valid 4 hours. Ctrl-C to stop.\n\n'

# ── Cleanup on exit ───────────────────────────────────────────────
_cleanup() {
  printf '\n  Shutting down...\n'
  kill "$CF_PID" "$WS_PID" 2>/dev/null || true
  curl -s -X DELETE "$RELAY_URL/register/$CODE" &>/dev/null || true
  printf '  Done.\n\n'
}
trap _cleanup EXIT INT TERM

wait "$CF_PID"
