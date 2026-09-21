# Production Dockerfile for Retail Platform
FROM node:20-alpine AS base

# Install curl for reliable container health check
RUN apk add --no-cache curl

WORKDIR /usr/src/app

# Set production environment
ENV NODE_ENV=production \
    PORT=8081 \
    APP_VERSION=4.2.0

# Copy application files
COPY app/package.json ./
RUN npm install --only=production --silent

COPY app/ ./

# Enforce security best practice: run as non-root user (node)
USER node

# Expose required application port
EXPOSE 8081

# Container Healthcheck
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8081/health || exit 1

# Start command
CMD ["node", "server.js"]
