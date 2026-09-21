# Task 1: Retail Platform Enterprise Release & Automated Rollback

## Overview
This service represents the online retail platform. It implements version tracking, payment processing, health checks, Docker containerization, and automated Jenkins deployment pipelines with automatic rollback capabilities.

## Architecture
- **Port:** 8081
- **Network:** `retail-network`
- **Security:** Non-root execution (`USER node`)
- **Health Check:** Native HTTP endpoint `/health` polled by Docker `HEALTHCHECK` and Jenkins validation stages.

## Endpoints
- `GET /health` - Service health status (HTTP 200 on healthy, HTTP 500 on simulated failure).
- `GET /version` - Returns running version and Git commit hash.
- `GET /api/payment` - Payment gateway endpoint (defective in v4.2.0, resolved in v4.2.1).
- `GET /api/products` - Product catalog.

## Version History
- `v4.2.0` - Initial production release with payment gateway defect.
- `v4.2.1` - Emergency hotfix release resolving payment issue.
- `v4.2.2` - Injected failure version (simulates healthcheck failure to trigger automated rollback).
