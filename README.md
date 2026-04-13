# OpenClaw Dockerized Agent Setup Guide

This guide covers everything you need to set up your own OpenClaw agent locally using Docker Desktop. **No manual file editing required** — the interactive onboard wizard handles all configuration.

## Prerequisites
- [Docker Desktop](https://docs.docker.com/get-docker/) installed and running.

That's it! The onboard wizard will walk you through getting API keys and tokens during setup.

---

## 🚢 Step 1: Build & Start the Container

Open your terminal in this project's root directory and run:

```bash
docker compose up -d --build
```

**What this does:**
- `docker compose up` — Creates and starts the container
- `-d` — Runs in the background (detached mode)
- `--build` — Builds the Docker image from the Dockerfile first

The container will start the OpenClaw gateway in **unconfigured mode**, ready for the onboard wizard.

---

## ⚙️ Step 2: Run the Interactive Onboard Wizard

```bash
docker exec -it openclaw-agent openclaw onboard
```

**What this does:**
- `docker exec` — Runs a command inside the running container
- `-it` — Interactive mode (so you can type and see the prompts)
- `openclaw onboard` — Launches the setup wizard

**The wizard will guide you through:**
- ✅ Choosing your AI provider (OpenRouter, OpenAI, Anthropic, etc.)
- ✅ Selecting your model (free or paid)
- ✅ Entering your API key
- ✅ Setting up Telegram (paste your BotFather token)
- ✅ **Auto-generating your dashboard auth token**

> 💡 Everything is saved inside the `claw-data/` folder on your machine automatically.

After the wizard completes, **restart the container** to apply the new config:

```bash
docker compose restart
```

---

## 🖥️ Step 3: Access the Dashboard

**1. Get your auto-generated gateway token:**
```bash
docker exec openclaw-agent openclaw config get gateway.auth.token
```

**2. Open the dashboard in your browser:**
```
http://127.0.0.1:3000/#token=PASTE_YOUR_TOKEN_HERE
```

**3. Approve the browser pairing:**
```bash
docker exec openclaw-agent openclaw devices list
docker exec openclaw-agent openclaw devices approve <DEVICE_ID>
```

**4. Hard refresh your browser** (Ctrl+F5) — you're in! ✅

> This pairing is a one-time step per browser.

---

## 🤖 Step 4: Start Chatting!
- Talk to the agent in the **Local Dashboard** at `http://127.0.0.1:3000`
- Open **Telegram** and message your bot — the agent responds natively.

---

## 📁 How It Works

```
openclaw-setup/
├── Dockerfile              # Installs OpenClaw in a Node.js Alpine container
├── docker-compose.yml      # Mounts claw-data, exposes ports 3000 & 18789
├── claw-data/              # ← ALL data lives here (mounted Docker volume)
│   ├── openclaw.json       #    Main config (created by onboard wizard)
│   ├── credentials/        #    API keys (created by onboard wizard)
│   ├── agents/             #    Agent data
│   ├── devices/            #    Paired browser sessions
│   └── logs/               #    Runtime logs
└── README.md               # This file
```

**The magic:** `docker-compose.yml` mounts `./claw-data` → `/root/.openclaw` inside the container. So when the onboard wizard writes config inside the container, it's actually writing to your local `claw-data/` folder. Your data persists even if the container is rebuilt.

---

## 🔧 Useful Commands

| Command | What It Does |
|---|---|
| `docker compose up -d --build` | Build image & start container |
| `docker exec -it openclaw-agent openclaw onboard` | Run interactive setup wizard |
| `docker compose restart` | Restart after config changes |
| `docker exec openclaw-agent openclaw config get gateway.auth.token` | Get your dashboard token |
| `docker exec openclaw-agent openclaw devices list` | List pending device pairings |
| `docker exec openclaw-agent openclaw devices approve <ID>` | Approve a device |
| `docker logs --tail 50 openclaw-agent` | View recent container logs |
| `docker compose down` | Stop & remove the container |
| `docker compose up -d` | Up the container again|
---

## ✏️ Managing Configuration (Changing Providers, Keys)

If you need to change your AI provider, update your API keys, or change any settings later, you have three ways to do it:

**1. Using the Interactive Wizard (Recommended)**
You can re-run the setup wizard at any time while the container is running. It will safely update your configuration:
```bash
docker exec -it openclaw-agent openclaw onboard
```
*Note: Always run `docker compose restart` to apply changes after finishing the wizard.*

**2. Using the CLI Commands**
If you know the specific configuration key you want to change, you can bypass the wizard and use the CLI `config set` command:
```bash
# Example: Change AI provider to OpenAI
docker exec openclaw-agent openclaw config set ai.provider openai

# Example: Update your Anthropic API Key
docker exec openclaw-agent openclaw config set ai.anthropic.apiKey "sk-ant-your-new-key"
```
*Note: You must restart the container (`docker compose restart`) for CLI config changes to take effect.*

**3. Direct File Editing**
Because your data is synced locally, you can open `claw-data/openclaw.json` directly in a text editor (like VS Code or Notepad), manually change the values, save the file, and then run `docker compose restart`.

---

## ☁️ Migrating to a VPS or Another Computer

One of the massive benefits of this Dockerized setup is **extreme portability**. Moving your entire OpenClaw setup (including your API keys, paired devices, configuration, and agent data) to a live VPS or another computer is incredibly simple.

**Step 1: Zip your project directory**
Compress the entire `openclaw-setup` folder on your local computer. Crucially, make sure the `claw-data/` folder is included inside the zip, as that is where all your state and configuration live.

**Step 2: Transfer to the remote server**
Upload the zipped file (via SCP, SFTP, etc.) to your VPS or second computer and unzip it.

**Step 3: Run the project**
Assuming Docker is installed on your VPS, open a terminal, navigate into the unzipped folder, and run:
```bash
docker compose up -d --build
```

That's it! Because your `claw-data/` folder was transferred, the container will instantly boot up exactly as it was on your first computer—using the exact same configuration, API keys, and paired browser sessions. You won't even need to pair your dashboard again!

---

## 🔄 Fresh Install / Reset

To start completely fresh, just delete everything inside `claw-data/` and re-run from Step 1:

```bash
# Windows PowerShell
Remove-Item -Path .\claw-data\* -Recurse -Force

# Then rebuild
docker compose up -d --build
docker exec -it openclaw-agent openclaw onboard
docker compose restart
```
