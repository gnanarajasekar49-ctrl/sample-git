# Task 3: Production Incident Recovery & Zero-Downtime Blue-Green Deployment

## Overview
This component implements a production-grade Blue-Green deployment architecture with automated Candidate validation, Nginx reverse proxy routing on port `8080`, continuous availability, and automated failure abort.

## Architecture
- **Host Traffic Port:** `8080` (Reverse Proxy Nginx)
- **Blue Slot Container:** `orders-blue` (Port `8081`, Version `7.8.0`)
- **Green Slot Container:** `orders-green` (Port `8082`, Version `7.9.0`)
- **Database Container:** `orders-db` (Port `5432` internal)
- **Shared Network:** `orders-network`

## 12-Stage Jenkins Pipeline Flow
1. `Checkout`
2. `Validate Version`
3. `Unit/Application Test`
4. `Docker Build`
5. `Docker Image Validation`
6. `Start Candidate`
7. `Container Validation`
8. `Application Health Check`
9. `Integration Check`
10. `Traffic Switch`
11. `Old Version Cleanup`
12. `Deployment Verification`

