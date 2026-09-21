# Task 2: Multi-Environment CI/CD with Docker Network & Configuration Isolation

## Overview
This service demonstrates automated multi-environment deployment (DEV, UAT, and PRODUCTION) across isolated Docker bridge networks, database containers, and persistent named volumes with 8-point automated validation and automated rollback.

## Environment Matrix

| Environment | Git Branch | App Container | Port | Docker Network | Database Container | Volume |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **DEV** | `develop` | `customer-app-dev` | `8081` | `customer-dev-net` | `customer-db-dev` | `customer-db-dev-data` |
| **UAT** | `release` | `customer-app-uat` | `8082` | `customer-uat-net` | `customer-db-uat` | `customer-db-uat-data` |
| **PROD** | `main` | `customer-app-prod` | `8083` | `customer-prod-net` | `customer-db-prod` | `customer-db-prod-data` |

## 8-Point Deployment Validation Checklist
1. **[Check 18]** Docker image exists.
2. **[Check 19]** Application container is running.
3. **[Check 20]** Database container is running.
4. **[Check 21]** Containers are attached to expected environment network.
5. **[Check 22]** Application health endpoint (`/health`) returns HTTP 200.
6. **[Check 23]** Application can reach the database (`/api/db-status`).
7. **[Check 24]** Expected environment value is displayed by application.
8. **[Check 25]** Deployed version matches requested version.
