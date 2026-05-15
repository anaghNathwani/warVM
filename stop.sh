#!/usr/bin/env bash
echo "Stopping WarVM..."
docker compose stop
echo "Done. Your game data is saved. Run ./start.sh to resume."
