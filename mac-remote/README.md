# Mac Remote Access — setup guide

Run one script on your Mac → get a 6-char code → enter it on the website → full Mac desktop in the browser.

Your Mac's WiFi is used for everything (browsing, gaming), not the school Chromebook's network.

---

## How it works

```
Mac (home WiFi)
  └─ Screen Sharing (VNC, built-in) :5900
       └─ websockify (WS bridge)     :6080
            └─ Cloudflare Quick Tunnel ──► trycloudflare.com/xxxxx
                                              ▲
                                      code relay (Cloudflare Worker)
                                              ▲
                                   browser enters 6-char code
                                              ▼
                                        noVNC (in browser)
                                   full Mac desktop, Mac's WiFi
```

---

## Step 1 — Enable Mac Screen Sharing

1. **System Settings → General → Sharing**
2. Toggle **Screen Sharing** ON
3. Click **Computer Settings…**
4. Tick **VNC viewers may control screen with password**
5. Set a password (you'll enter this in the browser later)

---

## Step 2 — Deploy the code relay (one-time, ~10 min)

The relay is a tiny Cloudflare Worker that stores your 6-char code for 4 hours.  
It's **free** — Cloudflare's free tier allows 100,000 requests/day.

### 2a. Create a free Cloudflare account
Go to [dash.cloudflare.com](https://dash.cloudflare.com) → sign up.

### 2b. Install Wrangler (Cloudflare's CLI)
```bash
npm install -g wrangler
wrangler login          # opens browser to authenticate
```

### 2c. Create a KV namespace
```bash
cd mac-remote/relay
wrangler kv namespace create SESSIONS
```
Copy the `id` from the output, then open `mac-remote/relay/wrangler.toml` and replace:
```
id = "REPLACE_WITH_YOUR_KV_NAMESPACE_ID"
```
with the actual id.

### 2d. Deploy the worker
```bash
wrangler deploy
```
It prints a URL like:
```
https://warvm-relay.YOUR_NAME.workers.dev
```
Copy that URL.

---

## Step 3 — Add your relay URL to two files

**`mac-remote/start.sh`** — line 8:
```bash
RELAY_URL="https://warvm-relay.YOUR_NAME.workers.dev"
```

**`docs/index.html`** — near the bottom of the `<script>` block:
```js
const RELAY_URL = 'https://warvm-relay.YOUR_NAME.workers.dev';
```

---

## Step 4 — Enable GitHub Pages for the website

1. Push this repo to GitHub (if not already)
2. Repo **Settings → Pages**
3. Source: **Deploy from a branch** → branch `main` → folder `/docs`
4. Save — your site will be at `https://anaghnathwani.github.io/warVM`

---

## Step 5 — Using it

**On your Mac at home:**
```bash
./mac-remote/start.sh
```

You'll see:
```
  ╔══════════════════════════════════════╗
  ║                                      ║
  ║   Your access code:                  ║
  ║                                      ║
  ║        A7KX3M                        ║
  ║                                      ║
  ╚══════════════════════════════════════╝
```

**On your Chromebook at school:**
1. Go to `https://anaghnathwani.github.io/warVM`
2. Type the 6-char code, press Connect
3. Enter your Mac VNC password when the browser asks
4. Your Mac desktop appears — full control, using your Mac's WiFi

Press **⛶ Fullscreen** to go fullscreen. Move mouse to top to see the HUD.

To stop, press `Ctrl-C` in the terminal on your Mac (or run `./mac-remote/stop.sh`).

---

## Troubleshooting

| Problem | Fix |
|---|---|
| "Screen Sharing is not running" | Follow Step 1 above |
| "Code not found" in browser | Mac script must be running; check terminal |
| Wrong password in browser | Check System Settings → Sharing → Computer Settings |
| Black screen after connecting | Wait 5–10s; VNC server may be slow to send first frame |
| Tunnel URL never appears | Run `cat /tmp/warvm-cf.log` to see cloudflared errors |
