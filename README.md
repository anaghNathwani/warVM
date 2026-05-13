# WarVM — Cloud Windows 11 Gaming VM

Browser-accessible Windows 11 VM with **Google Chrome** and **War Thunder** pre-installed, proxied through Nginx with a slick landing page.

## Stack

| Component | Role |
|-----------|------|
| [`dockurr/windows`](https://github.com/dockurr/windows) | Windows 11 KVM/QEMU VM inside Docker |
| noVNC (built-in) | Browser-based remote desktop (port 8006) |
| Nginx | Reverse proxy + landing page |
| `scripts/install.bat` | Auto-installs Chrome + War Thunder on first boot |

## Requirements

- Linux host with **KVM** enabled (`/dev/kvm` present)
- Docker Engine + Docker Compose v2
- **≥ 16 GB RAM** on host, **≥ 150 GB** free disk
- Open ports: `80`, `443`, `3389`, `8006`

> **Cloud VPS**: Use a bare-metal or KVM-enabled VPS (Hetzner, OVH, Vultr bare-metal). Pure container hosts (most AWS/GCP t-series) won't have `/dev/kvm` — the deploy script will warn you and fall back to slow software emulation.

## Quick Start

```bash
git clone https://github.com/anaghnathwani/warvm.git
cd warvm
chmod +x deploy.sh
./deploy.sh
```

Then open **`http://<your-server-ip>/`** in a browser and click **Launch VM**.

First boot takes ~5–10 minutes for Windows setup, then `install.bat` runs automatically to install Chrome and the War Thunder launcher.

## Credentials

| | |
|---|---|
| **Windows user** | `User` |
| **Password** | `WarThunder1!` |
| **RDP** | `<host>:3389` |

## Configuration

Edit `docker-compose.yml` environment variables to tune resources:

```yaml
RAM_SIZE: "8G"      # increase for better gaming
CPU_CORES: "4"
DISK_SIZE: "120G"
```

## Networking

The VM uses QEMU user-mode networking (`NETWORK: "user"`) — it NATs through the host's internet connection automatically. No extra VPN or TAP setup required.

## Stopping / Resetting

```bash
docker compose down          # stop (data preserved)
docker compose down -v       # stop + wipe disk (full reset)
```
