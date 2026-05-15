#!/usr/bin/env bash
# WarVM — start VM and tunnel, print the GitHub Pages connect URL
set -e

GITHUB_PAGES="https://anaghnathwani.github.io/warVM"

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
echo "  Starting Windows 11 VM..."
echo ""

# Start VM (no tunnel container — we use SSH instead)
docker compose up -d --pull missing

echo "  VM is starting up. Opening tunnel via localhost.run..."
echo "  (Press Ctrl+C to stop the tunnel and then run ./stop.sh to shut down the VM)"
echo ""

# localhost.run: SSH tunnel, built into every Mac, no install, lhr.life domain
# Port 8006 = noVNC WebSocket served by dockurr/windows
# We capture the URL and print the GitHub Pages connect link, then keep it alive
ssh -o StrictHostKeyChecking=no \
    -o ServerAliveInterval=30 \
    -R 80:localhost:8006 \
    nokey@localhost.run 2>&1 | while IFS= read -r line; do
  # localhost.run prints the URL on a line containing lhr.life
  if echo "$line" | grep -q 'lhr.life'; then
    TUNNEL=$(echo "$line" | grep -o 'https://[a-zA-Z0-9.-]*\.lhr\.life')
    if [ -n "$TUNNEL" ]; then
      # Encode tunnel URL for use as a query param
      ENCODED=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1],safe=''))" "$TUNNEL" 2>/dev/null || \
                node   -e "process.stdout.write(encodeURIComponent(process.argv[1]))" "$TUNNEL" 2>/dev/null || \
                echo "$TUNNEL" | sed 's|:|%3A|g;s|/|%2F|g')
      CONNECT_URL="${GITHUB_PAGES}/?stream=${ENCODED}"
      echo ""
      echo "  ┌──────────────────────────────────────────────────────────────┐"
      echo "  │                                                              │"
      echo "  │  Open this on your Chromebook (through GitHub Pages):        │"
      echo "  │                                                              │"
      echo "  │  ${CONNECT_URL}"
      echo "  │                                                              │"
      echo "  │  Windows 11 streams inside the page — no blocked domains.   │"
      echo "  │  First boot takes ~10 min. War Thunder installs itself.      │"
      echo "  │                                                              │"
      echo "  └──────────────────────────────────────────────────────────────┘"
      echo ""
      echo "  Credentials: User / WarThunder1!"
      echo "  Keep this terminal open while you play."
      echo ""
    fi
  fi
  # Show other tunnel output for debugging
done
