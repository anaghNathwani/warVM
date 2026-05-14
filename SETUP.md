# WarVM — Setup Guide

## Option A — Run Locally (Free, No Credit Card)

Run WarVM on your own PC using Docker Desktop. Uses your own machine and internet connection — completely free.

### Requirements
- Windows 10/11, macOS, or Linux
- 16 GB RAM on your machine (8 GB reserved for the VM)
- 150 GB free disk space
- CPU with virtualisation support (most modern CPUs have this)

### Step 1 — Install Docker Desktop

| OS | Download |
|----|----------|
| Windows | https://docs.docker.com/desktop/install/windows-install/ |
| macOS | https://docs.docker.com/desktop/install/mac-install/ |
| Linux | https://docs.docker.com/desktop/install/linux-install/ |

After installing, open Docker Desktop and make sure it's running.

**Windows users:** Docker Desktop will ask to enable WSL 2 — click Yes.

### Step 2 — Enable KVM / Virtualisation

**Windows:** Open PowerShell as Admin and run:
```powershell
# Check if virtualisation is enabled
Get-ComputerInfo -Property HyperVisorPresent
# Should say "True" — if not, enable it in BIOS
```

**macOS:** Virtualisation is on by default (Apple Silicon and Intel both work).

**Linux:**
```bash
sudo apt install -y cpu-checker && kvm-ok
# Should say "KVM acceleration can be used"
```

### Step 3 — Clone and Start WarVM

```bash
git clone https://github.com/anaghnathwani/warvm.git
cd warvm
docker compose up -d
```

### Step 4 — Open in your browser

```
http://localhost/
```

Click **Launch VM** → Windows 11 boots in your browser.

First boot takes **~10 minutes**. After that, Chrome and the War Thunder launcher install automatically.

**Credentials:** `User` / `WarThunder1!`

### Stop / Start

```bash
docker compose stop    # pause (saves state)
docker compose start   # resume
docker compose down    # shut down (data kept)
docker compose down -v # full wipe
```

---

## Option B — Cloud Server (Access from anywhere)

If you want the VM running 24/7 in the cloud so you can connect from any device, you'll need a server. Every cloud provider that supports KVM virtualisation requires a credit card for verification.

Cheapest options (~$12–20/month):

| Provider | Notes |
|----------|-------|
| **Hetzner Cloud** | Cheapest, great KVM support, EU/US regions |
| **Vultr** | Bare-metal plans with KVM |
| **DigitalOcean** | Droplets with nested virt |
| **Google Cloud** | $300 free credit for new accounts |

### Deploy to any Linux server

SSH into your server, then:

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER && newgrp docker

# Clone and start
git clone https://github.com/anaghnathwani/warvm.git
cd warvm
chmod +x deploy.sh && ./deploy.sh
```

Then open `http://YOUR_SERVER_IP/` in a browser.

For automated Google Cloud provisioning (Terraform), see [`terraform/`](terraform/).
