# WarVM

Two ways to access your Mac or a Windows VM from any browser (including a school Chromebook).

---

## Mac Remote Access (recommended)

Run one script → get a 6-char code → enter it on the website → full Mac desktop in the browser. All traffic (browsing, gaming) uses your Mac's Wi-Fi, not the Chromebook's network.

### Quick start

```bash
# One-time: follow mac-remote/README.md to deploy the relay and enable Screen Sharing
./mac-remote/start.sh
```

Prints a code like `A7KX3M`. Go to the website, enter the code, enter your Mac VNC password — done.

### How it works

```
Mac (home Wi-Fi)
  └─ Screen Sharing (VNC) :5900
       └─ websockify (WS bridge) :6080
            └─ Cloudflare Quick Tunnel
                    │
            Cloudflare Worker (free, code relay)
                    │
            browser — enters 6-char code
                    ▼
            noVNC — full Mac desktop
```

### Files

| File | Purpose |
|------|---------|
| `mac-remote/start.sh` | Run on Mac — starts tunnel, prints code |
| `mac-remote/stop.sh` | Kill tunnel + bridge processes |
| `mac-remote/relay/worker.js` | Cloudflare Worker that stores code → URL |
| `mac-remote/relay/wrangler.toml` | Worker deploy config |
| `docs/index.html` | GitHub Pages website (code input + noVNC) |
| `mac-remote/README.md` | Full setup guide |

### One-time setup (~10 min)

1. **Screen Sharing** — System Settings → General → Sharing → Screen Sharing ON → Computer Settings → set VNC password

2. **Deploy relay** (free Cloudflare Worker):
   ```bash
   npm install -g wrangler
   wrangler login
   cd mac-remote/relay
   wrangler kv:namespace create SESSIONS   # copy the printed id
   # paste id into mac-remote/relay/wrangler.toml
   wrangler deploy
   # copy the printed worker URL
   ```

3. **Paste the worker URL** into:
   - Line 8 of `mac-remote/start.sh` (`RELAY_URL=`)
   - Near bottom of `docs/index.html` (`const RELAY_URL =`)

4. **GitHub Pages** — Repo Settings → Pages → source: `main` branch, `/docs` folder

See `mac-remote/README.md` for full details and troubleshooting.

---

## Windows 11 VM (Docker, needs a Linux server)

Browser-accessible Windows 11 VM with Chrome and War Thunder pre-installed.

### Stack

| Component | Role |
|-----------|------|
| [`dockurr/windows`](https://github.com/dockurr/windows) | Windows 11 KVM/QEMU VM inside Docker |
| noVNC (built-in) | Browser-based remote desktop (port 8006) |
| Nginx | Reverse proxy + landing page |
| `scripts/install.bat` | Auto-installs Chrome + War Thunder on first boot |

### Requirements

- Linux host with **KVM** (`/dev/kvm` present)
- Docker Engine + Docker Compose v2
- ≥ 16 GB RAM, ≥ 150 GB free disk

### Quick start

```bash
./deploy.sh
```

Then open `http://<server-ip>/` and click **Launch VM**. First boot takes ~5–10 min.

### Credentials

| | |
|---|---|
| Windows user | `User` |
| Password | `WarThunder1!` |
| RDP | `<host>:3389` |

### Stop / reset

```bash
docker compose down       # stop (data kept)
docker compose down -v    # stop + wipe disk
```
