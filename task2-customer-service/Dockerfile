# Production Dockerfile for Customer Service
FROM node:20-alpine AS base

# Install curl for health monitoring
RUN apk add --no-cache curl

WORKDIR /usr/src/app

ENV NODE_ENV=production \
    PORT=8081 \
    APP_VERSION=5.0.0 \
    ENVIRONMENT=DEV \
    DB_HOST=customer-db-dev \
    DB_PORT=5432

COPY app/package.json ./
RUN npm install --only=production --silent

COPY app/ ./

# Non-root user
USER node

EXPOSE 8081 8082 8083

# Docker HEALTHCHECK
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:${PORT}/health || exit 1

CMD ["node", "server.js"]

