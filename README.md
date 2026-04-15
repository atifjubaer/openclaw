# OpenClaw Dockerized Setup Guide 🦀

Welcome to the pure, manual, and completely perfect Docker installation for OpenClaw. This architecture gives you the extreme stability of an isolated Linux environment (using Node 22 LTS to perfectly support all native modules) while retaining 100% of the advanced skills, flows, and capabilities of a native installation.

---

## 📥 1. Fresh Complete Installation

Because we are using Docker, you do not need Node.js installed on your host computer. Everything runs purely and securely in the background.

```bash
git clone https://github.com/atifjubaer/openclaw-setup.git
cd openclaw-setup
docker compose up -d --build
```
> **What this does:** It pulls the highly stable Node 22 Alpine image, installs the necessary C++ build tools (`git`, `python3`, `g++`), and boots OpenClaw. Your configuration will be permanently saved in the local `claw-data/` folder.

---

## ⚙️ 2. The Core Wizard (Terminal Setup)

For a fresh install, OpenClaw needs identity and gateway credentials. We configure this via the secure terminal wizard.

```bash
docker exec -it openclaw-agent openclaw onboard
```

1. **Select Local Gateway:** Choose this machine.
2. **AI Provider:** Pick your starting provider (e.g., Z.AI, OpenAI) and paste your API key.
3. **Gateway Token:** Leave it blank to generate a highly secure token.
4. **Channels:** Skip for now or add your basic Telegram bot token.

**CRITICAL:** Once the wizard finishes, lock in your new configuration by rebooting the container:
```bash
docker compose restart
```

---

## 🔐 3. Accessing the Web Dashboard (Bypassing Errors)

If you simply visit `http://localhost:18789`, you will get an `unauthorized` error because OpenClaw heavily protects your control interface. 

### Step 3A: Get Your Secure URL
Run this command to securely retrieve your gateway token:
```bash
docker exec openclaw-agent openclaw config get gateway.auth.token
```
*(If the console says `__OPENCLAW_REDACTED__`, simply open the `claw-data/openclaw.json` file in VS Code or Notepad on your computer and copy the `token` string manually!)*

Append that token to your URL like this:
> `http://127.0.0.1:18789/#token=YOUR_TOKEN_HERE`

### Step 3B: Magic Auto-Approve (Device Pairing)
Opening the URL will present a "Pairing Required" block. To instantly approve your browser without messing with manual copy-pasting, run this Magic Auto-Approve command in your terminal:

```bash
docker exec openclaw-agent /bin/sh -c "openclaw devices list | grep -i pending | grep -oE '[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}' | xargs -I {} openclaw devices approve {}"
```
**Hard-refresh your browser (F5), and you are inside the Dashboard!**

---

## 📦 4. Installing Modules & Smooth Configuration

In the past, manually editing JSON files to add multiple modules caused syntax errors that broke the installation. **Never edit the JSON file manually if you don't have to!** 

Your new installation is 100% capable of doing everything your old OpenClaw setup did. The **smoothest, perfect, error-free way** to add multiple modules, providers, or channels is through the glowing **Control UI Dashboard**.

1. **Modules & Skills:** Go to the UI, find the Modules/Skills tab, and you can instantly add back all your favorite plugins! OpenClaw will handle all the complex folder generation inside your `claw-data/` folder automatically.
2. **Multiple Providers:** Click the **Settings/Config** gear icon in the UI. You can visually add as many AI providers and Telegram tokens as you want. The UI mathematically guarantees you won't get a formatting error that breaks your setup!

---

## 📱 5. Telegram Setup & Pairing

If you set up a Telegram Bot, OpenClaw blocks strangers by default. When you message your bot for the first time, it will reply with a security warning and a pairing code.

> `Your Telegram user id: 123456789`
> `Pairing code: ABCD1234`

To permanently authorize your account, take that code and run:
```bash
docker exec openclaw-agent openclaw pairing approve telegram <PASTE_CODE_HERE>
```

---

## ❓ 6. Troubleshooting & FAQs

**1. "Update Available" banner in UI?**
We baked all the necessary compilation tools (`git`, `make`, `python3`) directly into the `node:22-alpine` environment. This means if you click **"Update Now"** inside the UI, it will successfully download and compile OpenClaw without failing! 

**2. Why does the AI erase my files if I ask it to configure itself?**
If you tell your AI Assistant to edit `D:\Ai\.openclaw\openclaw.json` or `F:\openclaw`, it will fail or erase data. The AI is trapped inside the Linux Docker Container. To the AI, your files are strictly located at `/root/.openclaw/openclaw.json`. 

**3. Migrating to VPS?**
Just zip your entire folder (especially `claw-data/`) and move it to your VPS. Run `docker compose up -d` and it will instantly boot with all your configurations flawlessly intact!
