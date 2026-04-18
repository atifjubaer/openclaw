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

### Fixing "Pairing Required"

Because OpenClaw enforces strict device security on the dashboard, the first time you visit the URL from a new browser, you will likely see a pairing required error.

To authorize your browser:

1. Keep the dashboard open in your browser.
2. Run the following command in your terminal to list pending connections:
   ```bash
   docker exec openclaw-agent openclaw devices list
   ```
3. Look for the pending request ID (e.g., `40c4e10d-eb96-4eea...`) under the "Pending" list.
4. Approve the connection by running:
   ```bash
   docker exec openclaw-agent openclaw devices approve <PENDING_REQUEST_ID>
   ```
   *(e.g. `docker exec openclaw-agent openclaw devices approve 89c2f148-0cb9-4fca`)*
5. Hard refresh (`Cmd+Shift+R` or `Ctrl+F5`) the dashboard page in your browser. You will immediately be granted access to the web chat.

---

## Step 5 — Add Modules & Providers

Use the **Dashboard UI** to add modules, providers, and channels. Do **not** edit `claw-data/openclaw.json` manually — a single syntax error will break your installation.

1. **Modules & Skills** — Modules/Skills tab in the UI. OpenClaw handles folder creation automatically.
2. **Multiple Providers** — Click the Settings/Config gear icon to add AI providers and API keys.
3. **Telegram Channels** — Add bot tokens through the UI's channel settings.

---

## Step 6 — Pinning a Default Model & Fallbacks

If you configure a provider like **OpenRouter**, the dashboard will fetch and display *hundreds* of models automatically. To avoid picking a model every time, you can pin a specific model and set up fallbacks (in case the primary model goes down).

Run the interactive configuration wizard:

```bash
docker exec -it openclaw-agent openclaw configure
```
1. Select **Agent Defaults** or **Profiles**.
2. Enter your exact model ID when prompted for the default model (e.g., `openrouter/anthropic/claude-3.5-sonnet`).
3. You can also specify **Fallback Models** to switch to automatically if your main model fails.

**Or set it directly via command line:**
```bash
# Set your primary model
docker exec openclaw-agent openclaw config set agents.defaults.model "openrouter/anthropic/claude-3.5-sonnet"

# Set your fallback models
docker exec openclaw-agent openclaw config set agents.defaults.fallbacks '["openai/gpt-4o", "google/gemini-1.5-pro"]'
```

**IMPORTANT**: Remember to restart the container after running these commands!
```bash
docker compose restart
```

---

## Step 7 — Telegram Configuration (Optional)

By default, OpenClaw enforces strict **DM Pairing** for messaging channels. This means if someone messages your Telegram bot, it will ignore their prompt and reply with a pairing code that must be manually approved via CLI.

If you want your bot to be public or just want it to immediately talk to anyone (giving it "superior permissions"), you must open the policy and allow all senders.

Run these two commands:
```bash
docker exec openclaw-agent openclaw config set channels.telegram.dmPolicy "open"
docker exec openclaw-agent openclaw config set channels.telegram.allowFrom '["*"]'
docker compose restart
```

*(Alternatively, if you want to keep strict mode on and only authorize yourself, message the bot to receive your Pairing Code, then run `docker exec openclaw-agent openclaw pairing approve telegram YOUR_CODE_HERE`)*

---

## Important — AI Self-Configuration Warning

**Never ask your OpenClaw AI assistant to edit its own configuration.** The AI runs inside the Docker container and may corrupt or erase its own config if asked to modify it.

The file paths:
- Your host machine: `claw-data/openclaw.json`
- Inside the container: `/root/.openclaw/openclaw.json`

These are the **same file** (mounted via Docker volume).

**Why is my openclaw.json empty?**
In newer versions of OpenClaw, `openclaw.json` handles only Gateway settings (like tokens and ports). AI Provider Configurations (API keys) are securely stored in a separate file:
- `claw-data/agents/main/agent/auth-profiles.json`
This is why `openclaw.json` looks empty when you add a provider!

**IMPORTANT: Restarting is Required!**
Every time you use the CLI (like `openclaw onboard`, `configure`, or `pairing approve`), you **MUST restart the container** for the running agent to reload its settings from those files. Otherwise, the AI will say "No API key found".

```bash
docker compose restart
```

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

### 🚀 How to run the doctor --fix command

Once you have saved your configuration files or if the system states an environment error, run these commands in your PowerShell terminal to repair the environment and start the server:

**Run the Doctor:**
```powershell
docker exec -it openclaw-agent openclaw doctor --fix
```

**Restart the Container:**
```powershell
docker compose restart
```

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
