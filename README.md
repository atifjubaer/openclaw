# OpenClaw Docker Setup

A clean, simple Docker installation for OpenClaw. Everything runs inside an isolated Linux container — no Node.js needed on your host.

Works on **Windows, macOS, and Linux**.

---

## Step 1 — Prerequisites

Make sure Docker is installed and running.

```bash
docker --version
```

If that fails, install [Docker Desktop](https://docs.docker.com/get-docker/) and restart your terminal.

---

## Step 2 — Install & Launch

```bash
git clone https://github.com/atifjubaer/openclaw.git
cd openclaw
docker compose up -d --build
```

Verify it's running:

```bash
docker ps
```

You should see `openclaw-agent` with status `Up`.

---

## Step 3 — Setup Wizard

```bash
docker exec -it openclaw-agent openclaw onboard
```

The wizard will ask:

1. **Gateway** — Choose "This machine"
2. **AI Provider** — Pick your provider and paste your API key
3. **Gateway Token** — Press Enter to auto-generate
4. **Channels** — Skip for now, or add a Telegram bot token

After the wizard, restart to lock in your config:

```bash
docker compose restart
```

---

## Step 4 — Open the Dashboard

### Get your token

```bash
docker exec openclaw-agent openclaw config get gateway.auth.token
```

If the output shows `__OPENCLAW_REDACTED__`, open the config file instead:

- **Windows:** `notepad claw-data\openclaw.json`
- **macOS/Linux:** `cat claw-data/openclaw.json`

Copy the `"token"` value.

### Open the dashboard

```
http://127.0.0.1:18789/#token=YOUR_TOKEN_HERE
```

An alternative dashboard is also available on port 3000:

```
http://127.0.0.1:3000
```

### Approve your browser (first time only)

The dashboard will show a "Pairing Required" screen. Get your device ID:

```bash
docker exec openclaw-agent openclaw devices list
```

Then approve it:

```bash
docker exec openclaw-agent openclaw devices approve DEVICE_ID
```

Hard-refresh your browser (`Ctrl+Shift+R` / `Cmd+Shift+R`) — you're in.

---

## Step 5 — Add Modules & Providers

Use the **Dashboard UI** to add modules, providers, and channels. Do **not** edit `claw-data/openclaw.json` manually — a single syntax error will break your installation.

1. **Modules & Skills** — Modules/Skills tab in the UI. OpenClaw handles folder creation automatically.
2. **Multiple Providers** — Click the Settings/Config gear icon to add AI providers and API keys.
3. **Telegram Channels** — Add bot tokens through the UI's channel settings.

---

## Step 6 — Telegram Pairing (Optional)

If you added a Telegram bot, message it and it will reply with a pairing code:

```
Your Telegram user id: 123456789
Pairing code: ABCD1234
```

Approve your account:

```bash
docker exec openclaw-agent openclaw pairing approve telegram ABCD1234
```

---

## Important — AI Self-Configuration Warning

**Never ask your OpenClaw AI assistant to edit its own configuration.** The AI runs inside the Docker container and may corrupt or erase its own config if asked to modify it.

The file paths:
- Your host machine: `claw-data/openclaw.json`
- Inside the container: `/root/.openclaw/openclaw.json`

These are the **same file** (mounted via Docker volume).

**If the AI breaks your config**, re-run the wizard:

```bash
docker exec -it openclaw-agent openclaw onboard
docker compose restart
```

---

## Ports

| Port | Purpose |
|------|---------|
| 18789 | Gateway API & Dashboard UI |
| 3000 | Alternative Dashboard UI |

Both ports are exposed in the Dockerfile and mapped in `docker-compose.yml`. To change a port, edit `docker-compose.yml` (e.g. `"19000:18789"` to use port 19000 instead).

---

## Common Issues

**"unauthorized" when visiting localhost:18789**
You need the token in the URL. See [Step 4](#step-4--open-the-dashboard).

**Container keeps restarting**
```bash
docker compose logs --tail 50
```
Likely a corrupted `openclaw.json`. Delete it and re-run the wizard:
```bash
rm claw-data/openclaw.json
docker exec -it openclaw-agent openclaw onboard
docker compose restart
```

**Port already in use**
Edit `docker-compose.yml` to use a different port (e.g. `"19000:18789"`).

**"Update Available" banner in the UI**
Safe to click. The Dockerfile includes all build tools (`git`, `python3`, `make`, `g++`) so in-UI updates compile successfully.

**Want a specific OpenClaw version?**
Edit the Dockerfile and change `openclaw@latest` to a pinned version (e.g. `openclaw@2026.4.12`), then rebuild:
```bash
docker compose up -d --build
```

---

## Migrating to a VPS

Copy the entire project folder (especially `claw-data/`) to your VPS, then:

```bash
docker compose up -d
```

All your configuration, providers, and channels will be intact.

---

## Uninstall

```bash
docker compose down
docker rmi openclaw-openclaw
```

Your data in `claw-data/` stays on disk. Delete the entire project folder to remove it completely.
