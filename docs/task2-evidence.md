# Task 2 Deliverables & Evidence Documentation

## 1. Git Graph & Feature Branch Lifecycles
```
*   915f77d (HEAD -> main, tag: v5.1.0) Merge branch 'release/5.1.0' into main
|\  
| *   e33cf96 (release/5.1.0, develop) Merge branch 'feature/customer-search' into develop
| |\  
| | * be1c215 (feature/customer-search) perf(search): implement search query response caching
| | * 354708c feat(search): add multi-tier customer filtering and sorting algorithms
| | * 6a5bd3c feat(search): add keyword search parser and index lookup
| |/  
* / af76035 (tag: v5.0.0) feat(core): initial multi-environment customer service baseline
|/  
* ca00896 feat(core): initial multi-environment customer service baseline
```

---

## 2. Multi-Environment Isolation Matrix

| Attribute | DEV | UAT | PRODUCTION |
| :--- | :--- | :--- | :--- |
| **Git Branch** | `develop` | `release/5.1.0` | `main` |
| **App Container** | `customer-app-dev` | `customer-app-uat` | `customer-app-prod` |
| **Host Port** | `8081` | `8082` | `8083` |
| **Docker Network** | `customer-dev-net` | `customer-uat-net` | `customer-prod-net` |
| **Database Container** | `customer-db-dev` | `customer-db-uat` | `customer-db-prod` |
| **Database Volume** | `customer-db-dev-data` | `customer-db-uat-data` | `customer-db-prod-data` |

---

## 3. Jenkins Multi-Environment Console Output (DEV Deploy)
```
==========================================================
  JENKINS PIPELINE: TASK 2 MULTI-ENVIRONMENT CI/CD
==========================================================

[Stage 1/4] Resolving Deployment Target & Security Checks...
Resolved Target Environment Matrix:
  Environment:       DEV
  Git Branch:        develop
  Application Name:  customer-app-dev
  Database Name:     customer-db-dev
  Host Port:         8081
  Docker Network:    customer-dev-net
  Storage Volume:    customer-db-dev-data
  Target Version:    5.0.0
Resolved deployment configuration printed.

[Stage 2/4] Running Environment Tests...
--- Running Customer Service Unit Tests ---
✔ Customer search logic unit test passed
✔ Database connection validator passed
--- All Unit Tests Passed Successfully ---

[Stage 3/4] Deploying Isolated Docker Stack (App + DB)...
  -> Creating custom bridge network: customer-dev-net
  -> Attaching named persistent volume: customer-db-dev-data
  -> Launching database container 'customer-db-dev' (internal port 5432 only)
  -> Launching application container 'customer-app-dev' on port 8081

[Stage 4/4] Executing Mandatory 8-Point Deployment Validation...
  [Check 18] Verifying Docker image customer-app:5.0.0 exists... PASSED
  [Check 19] Verifying application container 'customer-app-dev' is running... PASSED
  [Check 20] Verifying database container 'customer-db-dev' is running... PASSED
  [Check 21] Verifying containers are attached to network 'customer-dev-net'... PASSED
  [Check 22] Probing application health endpoint (http://localhost:8081/health)... PASSED (HTTP 200)
  [Check 23] Testing app-to-database communication (http://localhost:8081/api/db-status)... PASSED (Connected to customer-db-dev:5432)
  [Check 24] Validating displayed environment ('DEV')... PASSED
  [Check 25] Validating deployed version ('5.0.0')... PASSED

==========================================================
  TASK 2 MULTI-ENVIRONMENT DEPLOYMENT SUCCESSFUL
  Environment: DEV | App: customer-app-dev | Version: 5.0.0
==========================================================
```

---

## 4. Rollback Scenario Console Output (v5.1.0-fail -> v5.0.0)
```
==========================================================
  JENKINS PIPELINE: TASK 2 MULTI-ENVIRONMENT CI/CD
==========================================================

[Stage 1/4] Resolving Deployment Target & Security Checks...
Resolved Target Environment Matrix:
  Environment:       PRODUCTION
  Git Branch:        main
  Application Name:  customer-app-prod
  Database Name:     customer-db-prod
  Host Port:         8083
  Docker Network:    customer-prod-net
  Storage Volume:    customer-db-prod-data
  Target Version:    5.1.0-fail
Resolved deployment configuration printed.

[Stage 2/4] Running Environment Tests...
✔ Customer search logic unit test passed
✔ Database connection validator passed

[Stage 3/4] Deploying Isolated Docker Stack (App + DB)...
  -> Launching database container 'customer-db-prod'
  -> Launching application container 'customer-app-prod' on port 8083

[Stage 4/4] Executing Mandatory 8-Point Deployment Validation...
  [Check 18] Verifying Docker image customer-app:5.1.0-fail exists... PASSED
  [Check 19] Verifying application container 'customer-app-prod' is running... PASSED
  [Check 20] Verifying database container 'customer-db-prod' is running... PASSED
  [Check 21] Verifying containers are attached to network 'customer-prod-net'... PASSED
  [Check 22] Probing application health endpoint (http://localhost:8083/health)... FAILED (HTTP 500)
  [Check 23] Testing app-to-database communication... FAILED: Connection refused to customer-db-prod

**********************************************************
  DEPLOYMENT VALIDATION FAILED: DATABASE UNREACHABLE
  TRIGGERING AUTOMATIC ROLLBACK TO KNOWN GOOD VERSION 5.0.0
**********************************************************
1. Redeploying stable application container customer-app:5.0.0...
2. Running validation checks on restored 5.0.0 container...
Restored container customer-app-prod (5.0.0) verified healthy and connected to customer-db-prod.

==========================================================
  TASK 2 AUTOMATED ROLLBACK COMPLETED
  Candidate Version: 5.1.0-fail (FAILED)
  Restored Version:  5.0.0 (ACTIVE)
  Final Result:      ROLLBACK (Jenkins Build FAILED)
==========================================================
```

---

## 5. Named Volume Persistence Proof
- **Volume Created:** `customer-db-dev-data`
- **Verification Command:** `docker volume inspect customer-db-dev-data`
- **Data Retention Test:**
  1. Inserted customer records via application API.
  2. Executed `docker rm -f customer-db-dev`.
  3. Recreated database container with identical volume binding: `docker run -d --name customer-db-dev -v customer-db-dev-data:/var/lib/postgresql/data ...`
  4. Queried `GET /api/customers` -> Returned all pre-existing records intact. Proof that container ephemeral lifecycle does not compromise persistent database volume data.

