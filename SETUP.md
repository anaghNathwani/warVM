# WarVM — Stream War Thunder from MacBook to Chromebook

Run War Thunder on your MacBook, stream it to any browser (including your Chromebook at school) — free, no credit card, no port forwarding.

---

## How it works

```
MacBook (runs the VM) ──► Cloudflare Tunnel ──► Public URL ──► Chromebook browser
```

Your MacBook runs Windows 11 + War Thunder inside Docker. A Cloudflare tunnel punches through your home router and gives you a public HTTPS link you can open anywhere.

---

## One-time setup (MacBook)

### 1. Install Docker Desktop

Download and install from: https://www.docker.com/products/docker-desktop/

Open Docker Desktop and wait until the whale icon in the menu bar stops animating.

### 2. Clone WarVM

Open Terminal and run:

```bash
git clone https://github.com/anaghnathwani/warvm.git
cd warvm
chmod +x start.sh stop.sh
```

---

## Every time you want to play

### On your MacBook — run:

```bash
./start.sh
```

It will print something like:

```
  ┌─────────────────────────────────────────────────────┐
  │                                                     │
  │   Open this URL on your Chromebook:                 │
  │                                                     │
  │   https://random-words.trycloudflare.com            │
  │                                                     │
  │   Then click Launch VM → Windows 11 streams live.   │
  │                                                     │
  └─────────────────────────────────────────────────────┘
```

### On your Chromebook — open that URL in Chrome

- Click **Launch VM**
- Windows 11 streams directly in the browser tab
- First boot takes ~10 minutes (one time only)
- War Thunder installs automatically after Windows sets up

**Login:** `User` / `WarThunder1!`

---

## When you're done

On your MacBook:

```bash
./stop.sh
```

Your game data and War Thunder progress are saved. Next time you run `./start.sh` it resumes where you left off.

---

## Notes

- **URL changes each session** — the Cloudflare tunnel gives a new URL every time you start. Just send yourself the URL (text, Discord, etc.) before leaving home.
- **MacBook must stay on and lid open** while you're playing at school.
- **Internet speed matters** — WarVM streams the screen from your MacBook. The faster your home upload speed, the smoother it runs.
- **First boot only** — Windows 11 setup + Chrome + War Thunder install takes ~10–15 min the first time. After that, starts in ~1–2 min.

---

## Troubleshooting

**"Docker Desktop is not running"**
→ Open Docker Desktop from Applications and wait for it to fully start.

**URL didn't appear**
→ Run `docker compose logs tunnel | grep trycloudflare` to get the URL manually.

**Black screen in browser**
→ Windows is still booting. Wait a minute and refresh.

**War Thunder won't launch**
→ The VM uses software rendering (no GPU passthrough). War Thunder may run slowly. In the launcher, set graphics to **Minimum** for best performance.
