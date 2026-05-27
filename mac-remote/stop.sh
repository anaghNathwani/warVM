#!/usr/bin/env bash
# mac-remote/stop.sh — kill all remote-access processes
set -euo pipefail

WS_PORT=6080

printf '\n  Stopping mac-remote processes...\n'
pkill -f "websockify.*$WS_PORT" 2>/dev/null && printf '  ✔  websockify stopped\n' || printf '  –  websockify not running\n'
pkill -f "cloudflared tunnel"   2>/dev/null && printf '  ✔  cloudflared stopped\n' || printf '  –  cloudflared not running\n'
printf '\n'
