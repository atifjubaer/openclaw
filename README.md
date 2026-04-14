# OpenClaw Dockerized Agent Setup Guide

This guide provides a clean, step-by-step manual installation path for OpenClaw using Docker. It preserves the flexibility of OpenClaw's official setup, allowing you to choose any AI provider or messaging channel via the interactive onboarding wizard.

---

## Prerequisites
- **Git** (to clone the repository).
- **Docker** and **Docker Compose** installed ([Docker Desktop](https://docs.docker.com/get-docker/)).

> 💡 **Fun Fact:** You do **NOT** need Node.js installed on your computer! The entire OpenClaw framework runs safely isolated inside the Docker container. 

---

## 📥 Step 1: Download the Project

Clone this repository and enter the directory. Look at the folder structure — notice `claw-data`; this is your persistent workspace where all OpenClaw configuration files, agents, and logs will be permanently saved so they won't disappear when Docker shuts down!

```bash
git clone https://github.com/atifjubaer/openclaw-setup.git
cd openclaw-setup
```

---

## 🚢 Step 2: Build & Start the Container

Run the following command to build the image and bring the container online:

```bash
docker compose up -d --build
```

**What this does:**
- `-d` runs the container in the background.
- It exposes **Port 18789**, which handles both OpenClaw's Gateway and the Web Dashboard. *(Note: Port 3000 is no longer used by OpenClaw!)*

---

## ⚙️ Step 3: Run the Interactive Onboard Wizard

Now we need to configure your agent! We do this by jumping inside the running container and triggering the official installation wizard.

```bash
docker exec -it openclaw-agent openclaw onboard
```

### Navigating the Wizard
1. Choose to set up a **Local gateway**.
2. Select your AI provider (e.g., Z.AI, OpenAI, OpenRouter, Anthropic) and enter your API Key.
3. Choose to generate a **plaintext token** for the gateway. *(Leave it blank to let OpenClaw generate a secure one for you).*
4. Select which messaging channels you want (e.g., Telegram) and paste your Bot Token.
5. Exit the wizard. OpenClaw will automatically write all this data to your local `claw-data/openclaw.json` file!

**CRUCIAL STEP:** You must reboot the container to apply these new settings!
```bash
docker compose restart
```

---

## 🔐 Step 4: Accessing the Dashboard UI (Fixing the "Unauthorized" Error)

If you simply navigate to `http://localhost:18789/`, you **will** receive the following error:
> ❌ `unauthorized: gateway token missing (open the dashboard URL and paste the token)`
> ❌ `unauthorized: too many failed authentication attempts (retry later)`

This happens because OpenClaw enforces strict security, and the Web UI requires your gateway token to be embedded in the URL.

### How to Fix It & Log In

**1. Retrieve your gateway token:**
Run this command in your terminal to securely extract the token that the wizard generated for you:
```bash
docker exec openclaw-agent openclaw config get gateway.auth.token
```

**2. Form your Dashboard URL:**
Copy the token printed in your terminal and append it to `http://127.0.0.1:18789/#token=` 

**Example URL:**
> `http://127.0.0.1:18789/#token=YOUR_LONG_TOKEN_STRING_HERE`

Open that full URL in your browser!

---

## 🛡️ Step 5: Device Pairing Approval

Once you successfully load the Dashboard with your token URL, you will likely hit one final security screen: **Pairing Required**. OpenClaw considers your web browser an "untrusted device" until you explicitly approve it.

**How to approve your browser:**

You have two ways to do this. You can manually copy the UUID, or use our "Magic One-Liner" to auto-approve all pending devices so you don't have to highlight anything!

### Method A: The Magic Auto-Approve (Easiest)
If you don't want to struggle with copying the long UUID string from the confusing table, just run this single command. It searches for all pending devices and approves them instantly!
```bash
docker exec openclaw-agent /bin/sh -c "openclaw devices list | grep -i pending | grep -oE '[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}' | xargs -I {} openclaw devices approve {}"
```
Once run, just **Hard Refresh** your browser (Ctrl+F5 or Cmd+Shift+R) and you are securely inside the admin dashboard!

### Method B: Manual Copy-Paste
1. Leave the Dashboard open in your browser on the "Pairing Required" screen.
2. Go back to your terminal and view your device list:
   ```bash
   docker exec openclaw-agent openclaw devices list
   ```
3. You will see a list. Carefully highlight and copy the UUID string of the device marked as **Pending** (e.g., `40c4e10d...`).
4. Run the approval command with that exact ID:
   ```bash
   docker exec openclaw-agent openclaw devices approve <PASTE_YOUR_DEVICE_UUID>
   ```
5. **Hard Refresh** your browser.

### Want to just check your devices? (Optional)
If you ever just want to see a list of every active, pending, or revoked device connected to your agent, simply run:
```bash
docker exec openclaw-agent openclaw devices list
```

**🎉 Congratulations! You are now inside the OpenClaw Control UI!** 

---

## 📁 Workspace File Structure

Because of our Docker configuration, your local workspace perfectly mirrors a standard OpenClaw installation. If you explore the `claw-data/` folder on your machine, you'll see:

```
openclaw-setup/
├── claw-data/              # Your persistent .openclaw folder!
│   ├── openclaw.json       # Modify this directly anytime to change API keys!
│   ├── agents/             # Where your agent's memory and sessions live
│   ├── credentials/        # Securely stored tokens
│   ├── devices/            # Records of your paired web browsers
│   └── logs/               # Live system logs
├── Dockerfile              
├── docker-compose.yml      
└── README.md               
```

---

## 🔧 Managing Your Settings & Adding Multiple Providers

The manual setup architecture gives you complete freedom to scale your agent. If you ever want to change your primary AI Provider, swap a Telegram token, or add **multiple AI providers** at once, you have two flexible choices:

**Option 1: Re-run the Wizard (Safest & Recommended)**
You can run the onboarding command as many times as you want! It will simply update or add to your configuration without breaking what you already have.
```bash
docker exec -it openclaw-agent openclaw onboard
```
*Tip: Go through the wizard to easily add as many new providers or channels as you want. Afterwards, always remember to reboot the container to apply changes:*
```bash
docker compose restart
```

**Option 2: Direct Manual Edit**
Since everything is mapped out beautifully, you can literally open `claw-data/openclaw.json` in VS Code or Notepad, manually type in new API keys, multiple providers, save the file, and then run `docker compose restart`.

---

## ☁️ Migrating to a VPS or Another Computer

One of the massive benefits of this Dockerized manual setup is **extreme portability**. Moving your entire OpenClaw setup (including your API keys, paired devices, configuration, and agent memory) to a live VPS or another computer is incredibly simple and highly secure.

**Step 1: Zip your project directory**
Compress the entire `openclaw-setup` folder on your local computer. Crucially, make sure the `claw-data/` folder is included inside the zip, as that is where all your state and configuration live.

**Step 2: Transfer to the remote server**
Upload the zipped file (via SCP, SFTP, etc.) to your VPS or second computer and unzip it.

**Step 3: Run the project**
Assuming Docker is installed on your VPS, open a terminal, navigate into the unzipped folder, and run:
```bash
docker compose up -d --build
```

That's it! Because your `claw-data/` folder was transferred, the container will instantly boot up exactly as it was on your first computer—using the exact same configuration, API keys, and previously approved browser sessions. You won't even need to pair your dashboard again!

---

## 🔄 Fresh Install / Reset

To start completely fresh, eradicate your config, and start over from zero, just delete everything inside `claw-data/` and re-run Step 1:

```bash
# Force stop the container
docker compose down

# Windows PowerShell: Delete all data
Remove-Item -Path .\claw-data\* -Recurse -Force

# Mac/Linux: Delete all data
rm -rf claw-data/*

# Then rebuild
docker compose up -d --build
docker exec -it openclaw-agent openclaw onboard
```
