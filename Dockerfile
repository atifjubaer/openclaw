# Use Node.js 22 LTS on Alpine Linux — lightweight and highly stable base image
FROM node:22-alpine

# Install git and build tools required for OpenClaw's internal dashboard update button to work smoothly!
RUN apk add --no-cache git python3 make g++

# Set working directory inside the container
WORKDIR /app

# Install OpenClaw CLI globally — always get the latest stable release
# If a specific version has a bug, pin it temporarily: openclaw@2026.4.12
RUN npm install -g openclaw@latest

# Expose the Gateway port (18789) and potential Dashboard port (3000)
EXPOSE 18789 3000

# On container start:
# 1. Allow dashboard to work without strict origin checking (required for Docker networking)
# 2. Start the gateway in unconfigured mode so onboard wizard can run after
# 3. Bind to LAN (0.0.0.0) so the dashboard is accessible from host machine browser
CMD openclaw config set gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback true && openclaw gateway run --allow-unconfigured --bind lan