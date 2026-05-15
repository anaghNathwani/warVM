# WarVM — Stream War Thunder: MacBook → Chromebook

The Chromebook only ever talks to **GitHub Pages** (`anaghnathwani.github.io`). The game streams through a tunnel using `*.lhr.life` (localhost.run, SSH-based — far less commonly blocked than other tunnel services).

```
MacBook (runs VM) ──SSH tunnel──► lhr.life ──► GitHub Pages noVNC client ──► Chromebook
```

---

## One-time setup (MacBook)

### 1. Install Docker Desktop
Download from https://www.docker.com/products/docker-desktop/ and open it. Wait for the whale icon in the menu bar to stop animating.

### 2. Clone WarVM
```bash
git clone https://github.com/anaghnathwani/warvm.git
cd warvm
chmod +x start.sh stop.sh
```

---

## Every time you want to play

### On your MacBook:
```bash
./start.sh
```

After ~30 seconds it prints:

```
Open this on your Chromebook (through GitHub Pages):

https://anaghnathwani.github.io/warVM/?stream=https%3A%2F%2Fabc123.lhr.life
```

### On your Chromebook:
1. Open that URL in Chrome — it loads the WarVM page on GitHub Pages
2. The stream URL is pre-filled automatically — just click **Connect**
3. Windows 11 appears in the browser tab
4. First boot takes ~10 min (one time only), then War Thunder installs itself
5. Play

> **Alternatively:** Go to `https://anaghnathwani.github.io/warVM/` and paste the `lhr.life` URL from your Mac manually.

---

## When you're done

Press `Ctrl+C` in the terminal on your Mac to stop the tunnel, then:

```bash
./stop.sh
```

Game data and War Thunder are saved. Next `./start.sh` resumes where you left off.

---

## Notes

- **MacBook must stay on** (lid open, plugged in) while playing at school.
- **URL changes each session** — the `lhr.life` URL is new every time. Send yourself the GitHub Pages URL before leaving home.
- **First boot only** — Windows setup + Chrome + War Thunder install takes ~10–15 min once. After that starts in ~1–2 min.
- **War Thunder performance** — runs via software rendering (no GPU passthrough). Set graphics to **Minimum** in the launcher for best results.
- **SSH is built into macOS** — no installs needed for the tunnel.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Docker Desktop is not running" | Open Docker Desktop from Applications and wait |
| Black screen | Windows is still booting — wait and refresh |
| "Lost connection" banner | Check that `./start.sh` is still running on your Mac |
| lhr.life URL is blocked too | Open an issue — we can switch to a different tunnel |
