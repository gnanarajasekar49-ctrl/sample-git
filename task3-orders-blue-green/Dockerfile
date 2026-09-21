# Production Dockerfile for Orders API
FROM node:20-alpine AS base

RUN apk add --no-cache curl

WORKDIR /usr/src/app

ENV NODE_ENV=production \
    PORT=8081 \
    APP_VERSION=7.8.0 \
    COLOR_SLOT=BLUE \
    DB_HOST=orders-db \
    DB_PORT=5432 \
    DB_PASSWORD=orders_secure_pw

COPY app/package.json ./
RUN npm install --only=production --silent

COPY app/ ./

USER node

EXPOSE 8081 8082

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:${PORT}/health || exit 1

CMD ["node", "server.js"]

