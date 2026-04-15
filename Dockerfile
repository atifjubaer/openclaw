# Use Node.js 22 LTS on Alpine Linux — lightweight and highly stable base image
FROM node:22-alpine

# Install git and build tools required for OpenClaw's internal dashboard update button to work smoothly!
RUN apk add --no-cache git python3 make g++

# Set working directory inside the container
WORKDIR /app

# Install OpenClaw CLI globally
RUN npm install -g openclaw@latest

# Declare port: 18789 is Gateway API & Dashboard UI
EXPOSE 18789

# On container start:
# 1. Allow dashboard to work without strict origin checking (required for Docker networking)
# 2. Start the gateway in unconfigured mode so onboard wizard can run after
# 3. Bind to LAN (0.0.0.0) so the dashboard is accessible from host machine browser
CMD openclaw config set gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback true && openclaw gateway run --allow-unconfigured --bind lan