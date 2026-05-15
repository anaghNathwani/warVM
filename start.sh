#!/usr/bin/env bash
# WarVM — start everything and print your public streaming URL
set -e

# ── Docker Desktop check ──────────────────────────────────────────────────────
if ! docker info &>/dev/null; then
  echo ""
  echo "  Docker Desktop is not running."
  echo "  Open Docker Desktop, wait for it to start, then run ./start.sh again."
  echo ""
  exit 1
fi

echo ""
echo "  ██╗    ██╗ █████╗ ██████╗ ██╗   ██╗███╗   ███╗"
echo "  ██║    ██║██╔══██╗██╔══██╗██║   ██║████╗ ████║"
echo "  ██║ █╗ ██║███████║██████╔╝██║   ██║██╔████╔██║"
echo "  ██║███╗██║██╔══██║██╔══██╗╚██╗ ██╔╝██║╚██╔╝██║"
echo "  ╚███╔███╔╝██║  ██║██║  ██║ ╚████╔╝ ██║ ╚═╝ ██║"
echo "   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝     ╚═╝"
echo ""
echo "  Starting Windows 11 VM + Cloudflare stream tunnel..."
echo ""

# Start the stack
docker compose up -d --pull missing

echo ""
echo "  Waiting for the tunnel URL (up to 30s)..."

# Poll tunnel logs until we get the trycloudflare.com URL
URL=""
for i in $(seq 1 30); do
  URL=$(docker compose logs tunnel 2>/dev/null | grep -o 'https://[a-zA-Z0-9.-]*\.trycloudflare\.com' | tail -1)
  if [ -n "$URL" ]; then break; fi
  sleep 1
done

echo ""
if [ -n "$URL" ]; then
  echo "  ┌─────────────────────────────────────────────────────┐"
  echo "  │                                                     │"
  echo "  │   Open this URL on your Chromebook:                 │"
  echo "  │                                                     │"
  echo "  │   $URL"
  echo "  │                                                     │"
  echo "  │   Then click Launch VM → Windows 11 streams live.   │"
  echo "  │                                                     │"
  echo "  │   First boot takes ~10 min (only the first time).   │"
  echo "  │   War Thunder installs automatically after that.    │"
  echo "  │                                                     │"
  echo "  └─────────────────────────────────────────────────────┘"
  echo ""
  echo "  Credentials: User / WarThunder1!"
  echo ""
  echo "  To stop:  ./stop.sh"
  echo "  To get the URL again:  docker compose logs tunnel | grep trycloudflare"
  echo ""
else
  echo "  Could not detect tunnel URL yet. Run this to get it:"
  echo "  docker compose logs tunnel | grep trycloudflare"
  echo ""
fi
