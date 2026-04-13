# Use Node.js 22 on Alpine Linux — lightweight base image (~50MB vs ~350MB for full)
FROM node:22-alpine

# Set working directory inside the container (doesn't affect host)
WORKDIR /app

# Install OpenClaw CLI globally so all 'openclaw' commands are available
RUN npm install -g openclaw@latest

# Declare ports: 18789 = Gateway API, 3000 = Dashboard UI
EXPOSE 18789 3000

# On container start:
# 1. Allow dashboard to work without strict origin checking (required for Docker networking)
# 2. Start the gateway in unconfigured mode so onboard wizard can run after
# 3. Bind to LAN (0.0.0.0) so the dashboard is accessible from host machine browser
CMD openclaw config set gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback true && openclaw gateway run --allow-unconfigured --bind lan